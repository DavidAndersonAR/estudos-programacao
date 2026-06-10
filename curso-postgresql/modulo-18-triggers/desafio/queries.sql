-- =============================================
-- Módulo 18 — Desafio: Auditoria Automática de Pedidos
-- =============================================
-- Cenário: o dono da loja descobriu que pedidos somem, status muda
-- "sozinho" e ninguém sabe quem fez. Sua missão: instalar uma malha
-- de triggers que torna IMPOSSÍVEL mexer em pedidos sem deixar rastro.
--
-- Você vai entregar 3 triggers:
--   1) AUDITAR — toda INSERT/UPDATE/DELETE em pedidos grava em
--      pedidos_auditoria com snapshot JSONB de antes/depois e usuário.
--   2) PROTEGER — bloquear DELETE de pedido com status 'entregue'.
--   3) TOTALIZAR — recalcular total do pedido automaticamente sempre
--      que itens_pedido for alterado (INSERT/UPDATE/DELETE).
--
-- Pré-requisitos: schema + seed do Módulo 01 carregados.
-- =============================================


-- ---------------------------------------------
-- TODO 1: criar tabela de auditoria
-- ---------------------------------------------
-- Crie pedidos_auditoria com as colunas:
--   id           SERIAL PRIMARY KEY
--   pedido_id    INTEGER NOT NULL
--   operacao     TEXT NOT NULL          -- 'INSERT' / 'UPDATE' / 'DELETE'
--   dados_antigos JSONB                 -- snapshot de OLD (NULL no INSERT)
--   dados_novos   JSONB                 -- snapshot de NEW (NULL no DELETE)
--   usuario      TEXT NOT NULL DEFAULT current_user
--   quando       TIMESTAMP NOT NULL DEFAULT NOW()
--
-- Por que JSONB? guarda a linha INTEIRA com tipos preservados.
-- Não precisa adivinhar quais colunas vão existir amanhã.


-- ---------------------------------------------
-- TODO 2: trigger function de auditoria
-- ---------------------------------------------
-- Crie auditar_pedido() que:
--   - Usa TG_OP pra saber qual operação foi
--   - No INSERT: dados_antigos=NULL, dados_novos=to_jsonb(NEW)
--   - No UPDATE: dados_antigos=to_jsonb(OLD), dados_novos=to_jsonb(NEW)
--   - No DELETE: dados_antigos=to_jsonb(OLD), dados_novos=NULL
--   - Retorna NEW em INSERT/UPDATE, OLD em DELETE
-- Liga ela como AFTER INSERT OR UPDATE OR DELETE FOR EACH ROW.
-- Por que AFTER? porque queremos auditar o que REALMENTE aconteceu —
-- se a operação for abortada por outra restrição, a auditoria não roda.


-- ---------------------------------------------
-- TODO 3: trigger pra impedir DELETE de pedido entregue
-- ---------------------------------------------
-- Crie impedir_delete_entregue() BEFORE DELETE em pedidos.
-- Se OLD.status = 'entregue', dispara RAISE EXCEPTION com mensagem útil
-- ("não é permitido excluir pedido entregue (id=X)").
-- Senão, retorna OLD pra deixar a deleção seguir.


-- ---------------------------------------------
-- TODO 4: coluna total + trigger que recalcula
-- ---------------------------------------------
-- 4a) Adicione coluna em pedidos: total NUMERIC(12,2) NOT NULL DEFAULT 0
--
-- 4b) Crie recalcular_total_pedido() que, dado um pedido_id, faz:
--        SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
--        FROM itens_pedido WHERE pedido_id = ?
--     e atualiza a coluna total do pedido correspondente.
--
-- 4c) Liga ela como AFTER INSERT OR UPDATE OR DELETE em itens_pedido,
--     FOR EACH ROW. Atenção: no DELETE, o pedido vem de OLD;
--     no INSERT/UPDATE, vem de NEW. Cuidado também com UPDATE que
--     muda o pedido_id (raro, mas possível) — nesse caso ambos
--     OLD.pedido_id e NEW.pedido_id precisam ser recalculados.


-- =============================================
-- SOLUÇÃO
-- =============================================

-- TODO 1: tabela de auditoria ------------------------------------
DROP TABLE IF EXISTS pedidos_auditoria;
CREATE TABLE pedidos_auditoria (
    id            SERIAL PRIMARY KEY,
    pedido_id     INTEGER NOT NULL,
    operacao      TEXT NOT NULL CHECK (operacao IN ('INSERT','UPDATE','DELETE')),
    dados_antigos JSONB,
    dados_novos   JSONB,
    usuario       TEXT NOT NULL DEFAULT current_user,
    quando        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_aud_pedido ON pedidos_auditoria(pedido_id);
CREATE INDEX idx_aud_quando ON pedidos_auditoria(quando);


-- TODO 2: trigger function de auditoria --------------------------
CREATE OR REPLACE FUNCTION auditar_pedido()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO pedidos_auditoria (pedido_id, operacao, dados_antigos, dados_novos)
        VALUES (NEW.id, TG_OP, NULL, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO pedidos_auditoria (pedido_id, operacao, dados_antigos, dados_novos)
        VALUES (NEW.id, TG_OP, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO pedidos_auditoria (pedido_id, operacao, dados_antigos, dados_novos)
        VALUES (OLD.id, TG_OP, to_jsonb(OLD), NULL);
        RETURN OLD;
    END IF;

    RETURN NULL; -- nunca chega aqui, mas o linter agradece
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_auditar_pedido ON pedidos;
CREATE TRIGGER tg_auditar_pedido
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH ROW EXECUTE FUNCTION auditar_pedido();


-- TODO 3: bloquear DELETE de pedido entregue ---------------------
CREATE OR REPLACE FUNCTION impedir_delete_entregue()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'entregue' THEN
        RAISE EXCEPTION
            'Não é permitido excluir pedido entregue (id=%)', OLD.id
            USING HINT = 'Cancele ou crie um pedido de devolução em vez de deletar.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_impedir_delete_entregue ON pedidos;
CREATE TRIGGER tg_impedir_delete_entregue
BEFORE DELETE ON pedidos
FOR EACH ROW EXECUTE FUNCTION impedir_delete_entregue();


-- TODO 4: total automático ---------------------------------------
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS total NUMERIC(12,2) NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION recalcular_total_pedido()
RETURNS TRIGGER AS $$
DECLARE
    pid INTEGER;
BEGIN
    -- Atualiza o pedido apontado por NEW (INSERT/UPDATE)
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        pid := NEW.pedido_id;
        UPDATE pedidos
        SET total = (
            SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
            FROM itens_pedido WHERE pedido_id = pid
        )
        WHERE id = pid;
    END IF;

    -- Se for UPDATE que mudou de pedido OU DELETE, recalcula o antigo também
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        pid := OLD.pedido_id;
        -- evita atualizar duas vezes quando pedido_id não mudou
        IF TG_OP = 'DELETE' OR OLD.pedido_id <> NEW.pedido_id THEN
            UPDATE pedidos
            SET total = (
                SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
                FROM itens_pedido WHERE pedido_id = pid
            )
            WHERE id = pid;
        END IF;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_recalcular_total ON itens_pedido;
CREATE TRIGGER tg_recalcular_total
AFTER INSERT OR UPDATE OR DELETE ON itens_pedido
FOR EACH ROW EXECUTE FUNCTION recalcular_total_pedido();

-- Backfill: zerar totais e deixar o trigger calcular do zero
UPDATE pedidos p
SET total = COALESCE((
    SELECT SUM(quantidade * preco_unitario)
    FROM itens_pedido WHERE pedido_id = p.id
), 0);


-- =============================================
-- TESTES DE VERIFICAÇÃO
-- =============================================

-- 1) Auditoria: cria, altera, deleta e confere
INSERT INTO pedidos (cliente_id, status) VALUES (1, 'pendente') RETURNING id;
-- pega o id retornado (ex.: :p_id) e usa abaixo
-- UPDATE pedidos SET status = 'pago' WHERE id = :p_id;
-- DELETE FROM pedidos WHERE id = :p_id;
SELECT pedido_id, operacao, usuario, quando,
       dados_antigos->>'status' AS antes,
       dados_novos->>'status'   AS depois
FROM pedidos_auditoria
ORDER BY id DESC LIMIT 5;

-- 2) Proteção: tentar deletar pedido entregue
-- Primeiro, força um pedido pra 'entregue'
UPDATE pedidos SET status = 'entregue' WHERE id = (SELECT id FROM pedidos LIMIT 1);
-- Agora tenta deletar (deve estourar EXCEPTION)
-- DELETE FROM pedidos WHERE status = 'entregue';
-- ERROR:  Não é permitido excluir pedido entregue (id=...)

-- 3) Total automático: muda item e confere total
SELECT id, total FROM pedidos ORDER BY id LIMIT 3;
-- Pega um pedido_id que tenha itens:
-- UPDATE itens_pedido SET quantidade = quantidade + 1
--   WHERE pedido_id = 1 AND produto_id = (
--       SELECT produto_id FROM itens_pedido WHERE pedido_id = 1 LIMIT 1
--   );
SELECT id, total FROM pedidos WHERE id = 1;
-- O total deve ter aumentado sem ninguém calcular na mão.


-- =============================================
-- BÔNUS — Perguntas pra refletir
-- =============================================
-- a) Por que a auditoria é AFTER e a proteção é BEFORE?
-- b) O que aconteceria se o trigger de total fosse BEFORE em vez de AFTER?
--    (dica: NEW ainda não está visível pra SELECT na própria tabela)
-- c) Se um app malicioso fizer "ALTER TABLE pedidos DISABLE TRIGGER ALL",
--    o que protege a auditoria? (resposta curta: GRANTs e revogar permissões
--    de ALTER pra usuários comuns — trigger não é blindagem total,
--    é parte de uma política de segurança maior)
