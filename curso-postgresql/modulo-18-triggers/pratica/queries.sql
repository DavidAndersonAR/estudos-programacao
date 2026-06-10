-- =============================================
-- Módulo 18 — Triggers
-- Prática: 7 triggers cobrindo os casos clássicos
-- Pré-requisito: schema.sql + seed.sql do Módulo 01
-- =============================================

-- Antes de tudo: garantir colunas auxiliares que vamos usar.
-- (Em projeto real, isso entraria numa migração — aqui é só pra demo.)
ALTER TABLE clientes  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();
ALTER TABLE produtos  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();

-- Tabela de histórico genérica usada pelos exemplos
CREATE TABLE IF NOT EXISTS historico (
    id          SERIAL PRIMARY KEY,
    tabela      TEXT NOT NULL,
    operacao    TEXT NOT NULL,
    dados_antigos JSONB,
    dados_novos   JSONB,
    quando      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Tabela de lixeira pro soft-delete
CREATE TABLE IF NOT EXISTS clientes_excluidos (
    id            INTEGER,
    nome          VARCHAR(200),
    email         VARCHAR(200),
    cidade        VARCHAR(100),
    estado        CHAR(2),
    data_cadastro DATE,
    excluido_em   TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ---------------------------------------------
-- Exercício 1: BEFORE INSERT — normalizar email
-- Toda inserção em clientes vai ter o email forçado pra minúsculo
-- e sem espaços. Validação de consistência feita no banco.
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION normalizar_email()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email := LOWER(TRIM(NEW.email));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_normalizar_email ON clientes;
CREATE TRIGGER tg_normalizar_email
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION normalizar_email();

-- Testa:
INSERT INTO clientes (nome, email, cidade, estado)
VALUES ('Teste Trigger', '  TESTE@EXEMPLO.COM  ', 'SP', 'SP');

SELECT email FROM clientes WHERE nome = 'Teste Trigger';
-- Deve aparecer 'teste@exemplo.com'


-- ---------------------------------------------
-- Exercício 2: AFTER UPDATE — logar mudanças em historico
-- Toda alteração em produtos vira linha no historico, com snapshot
-- antes (OLD) e depois (NEW) como JSONB.
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION logar_update_produtos()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico (tabela, operacao, dados_antigos, dados_novos)
    VALUES ('produtos', TG_OP, to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_log_update_produtos ON produtos;
CREATE TRIGGER tg_log_update_produtos
AFTER UPDATE ON produtos
FOR EACH ROW
EXECUTE FUNCTION logar_update_produtos();

-- Testa:
UPDATE produtos SET preco = preco * 1.10 WHERE id = 1;
SELECT operacao, dados_antigos->>'preco' AS antes, dados_novos->>'preco' AS depois
FROM historico WHERE tabela = 'produtos' ORDER BY id DESC LIMIT 1;


-- ---------------------------------------------
-- Exercício 3: BEFORE UPDATE — atualizar updated_at automaticamente
-- O clássico. Toda vez que a linha muda, a coluna updated_at
-- recebe NOW(). Aplicado em produtos e clientes.
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_produtos_updated_at ON produtos;
CREATE TRIGGER tg_produtos_updated_at
BEFORE UPDATE ON produtos
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS tg_clientes_updated_at ON clientes;
CREATE TRIGGER tg_clientes_updated_at
BEFORE UPDATE ON clientes
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Testa:
UPDATE clientes SET cidade = 'Campinas' WHERE nome = 'Teste Trigger';
SELECT nome, cidade, updated_at FROM clientes WHERE nome = 'Teste Trigger';


-- ---------------------------------------------
-- Exercício 4: AFTER DELETE — soft-delete em clientes_excluidos
-- Não perde o histórico: toda linha deletada é copiada pra
-- clientes_excluidos antes de ir embora de verdade.
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION soft_delete_cliente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO clientes_excluidos (id, nome, email, cidade, estado, data_cadastro)
    VALUES (OLD.id, OLD.nome, OLD.email, OLD.cidade, OLD.estado, OLD.data_cadastro);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_soft_delete_cliente ON clientes;
CREATE TRIGGER tg_soft_delete_cliente
AFTER DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION soft_delete_cliente();

-- Testa:
DELETE FROM clientes WHERE nome = 'Teste Trigger';
SELECT * FROM clientes_excluidos ORDER BY excluido_em DESC LIMIT 1;


-- ---------------------------------------------
-- Exercício 5: WHEN condicional — só loga se o status mudou
-- Trigger dispara em UPDATE em pedidos, mas SÓ executa a função
-- quando a coluna status realmente mudou. WHEN é mais barato
-- que IF dentro da função, porque filtra antes.
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION logar_mudanca_status()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico (tabela, operacao, dados_antigos, dados_novos)
    VALUES (
        'pedidos',
        'STATUS_CHANGE',
        jsonb_build_object('id', OLD.id, 'status', OLD.status),
        jsonb_build_object('id', NEW.id, 'status', NEW.status)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_log_status ON pedidos;
CREATE TRIGGER tg_log_status
AFTER UPDATE ON pedidos
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION logar_mudanca_status();

-- Testa: UPDATE sem mudar status NÃO loga, UPDATE mudando status loga
UPDATE pedidos SET status = status WHERE id = 1;          -- não loga
UPDATE pedidos SET status = 'pago' WHERE id = 1;          -- loga
SELECT operacao, dados_antigos, dados_novos
FROM historico WHERE tabela = 'pedidos' ORDER BY id DESC LIMIT 3;


-- ---------------------------------------------
-- Exercício 6: DROP TRIGGER — removendo um trigger
-- Útil quando você quer reescrever ou desabilitar de vez.
-- ---------------------------------------------
DROP TRIGGER IF EXISTS tg_normalizar_email ON clientes;

-- Recria pra continuar funcionando no resto dos exercícios
CREATE TRIGGER tg_normalizar_email
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION normalizar_email();

-- Variação: desabilitar sem dropar (útil em migrações pesadas)
ALTER TABLE clientes DISABLE TRIGGER tg_normalizar_email;
-- ...rodar bulk load aqui...
ALTER TABLE clientes ENABLE TRIGGER tg_normalizar_email;


-- ---------------------------------------------
-- Exercício 7: listar triggers via catálogo (pg_trigger)
-- Útil pra auditoria/inventário — saber o que está acionando o quê.
-- ---------------------------------------------
SELECT
    tgname                       AS trigger_nome,
    tgrelid::regclass            AS tabela,
    CASE tgtype::int & 2 WHEN 2 THEN 'BEFORE' ELSE 'AFTER' END AS momento,
    CASE tgenabled
        WHEN 'O' THEN 'enabled'
        WHEN 'D' THEN 'disabled'
        WHEN 'R' THEN 'replica only'
        WHEN 'A' THEN 'always'
    END                          AS estado,
    pg_get_triggerdef(oid)       AS definicao
FROM pg_trigger
WHERE NOT tgisinternal
ORDER BY tabela, trigger_nome;

-- Atalho via psql:
--   \dS pedidos     (mostra triggers de pedidos)
