-- =============================================
-- Módulo 15 — Desafio: Transferência entre Saldos
-- =============================================
--
-- 💼 Cenário
-- Você é o(a) dev de um sistema de pagamentos. Precisa implementar a
-- função `transferir(de, para, valor)` que move dinheiro entre contas.
--
-- Requisitos:
--   1. Criar a tabela `contas` (id, titular, saldo).
--   2. Implementar a transferência DENTRO de uma transação:
--      - Travar AS DUAS contas com SELECT ... FOR UPDATE (evita race).
--      - Travar sempre na ORDEM do menor id pro maior (evita deadlock).
--      - Validar saldo da conta de origem ANTES de debitar.
--      - Se saldo insuficiente → ROLLBACK e mensagem clara.
--      - Usar SAVEPOINT pra registrar uma tentativa de log mesmo que
--        algum passo intermediário falhe.
--   3. Testar com cenários: ok, saldo insuficiente, conta inexistente,
--      transferência pra mesma conta.
--
-- 📐 Modelo
--   contas
--     id       SERIAL PK
--     titular  TEXT NOT NULL
--     saldo    NUMERIC(12,2) NOT NULL CHECK (saldo >= 0)
--
--   transferencias_log (auditoria, opcional mas recomendado)
--     id          SERIAL PK
--     conta_de    INT
--     conta_para  INT
--     valor       NUMERIC(12,2)
--     resultado   TEXT   -- 'ok' | 'saldo insuficiente' | 'conta inexistente' | ...
--     criado_em   TIMESTAMPTZ DEFAULT NOW()
--
-- =============================================


-- =============================================
-- TODO 1: criar as tabelas e popular com 3 contas
-- =============================================
-- DROP TABLE IF EXISTS ...
-- CREATE TABLE contas (...);
-- CREATE TABLE transferencias_log (...);
-- INSERT INTO contas (titular, saldo) VALUES (...);


-- =============================================
-- TODO 2: implementar a função transferir(de INT, para INT, valor NUMERIC)
-- - Lock das DUAS contas em ordem fixa (menor id primeiro)
-- - Validar existência das duas contas
-- - Validar saldo
-- - Debitar e creditar
-- - SAVEPOINT antes do log (se o log falhar, NÃO derruba a transferência)
-- - Inserir registro em transferencias_log com o resultado
-- =============================================
-- CREATE OR REPLACE FUNCTION transferir(...) RETURNS TEXT AS $$
-- ...
-- $$ LANGUAGE plpgsql;


-- =============================================
-- TODO 3: testar
--   SELECT transferir(1, 2, 100);     -- ok
--   SELECT transferir(1, 2, 999999);  -- saldo insuficiente
--   SELECT transferir(1, 99, 10);     -- conta inexistente
--   SELECT transferir(1, 1, 10);      -- mesma conta (regra de negócio)
-- =============================================



-- =============================================
-- ========== SOLUÇÃO ==========
-- =============================================

-- --- Schema ----------------------------------
DROP TABLE IF EXISTS transferencias_log CASCADE;
DROP TABLE IF EXISTS contas CASCADE;

CREATE TABLE contas (
    id       SERIAL PRIMARY KEY,
    titular  TEXT NOT NULL,
    saldo    NUMERIC(12,2) NOT NULL CHECK (saldo >= 0)
);

CREATE TABLE transferencias_log (
    id          SERIAL PRIMARY KEY,
    conta_de    INTEGER,
    conta_para  INTEGER,
    valor       NUMERIC(12,2),
    resultado   TEXT NOT NULL,
    criado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO contas (titular, saldo) VALUES
  ('Alice',  1000.00),
  ('Bruno',   500.00),
  ('Carla',     0.00);


-- --- Função transferir -----------------------
CREATE OR REPLACE FUNCTION transferir(
    p_de    INTEGER,
    p_para  INTEGER,
    p_valor NUMERIC
) RETURNS TEXT AS $$
DECLARE
    v_saldo_de    NUMERIC(12,2);
    v_existe_para BOOLEAN;
    v_menor_id    INTEGER;
    v_maior_id    INTEGER;
BEGIN
    -- regra básica
    IF p_valor <= 0 THEN
        INSERT INTO transferencias_log (conta_de, conta_para, valor, resultado)
        VALUES (p_de, p_para, p_valor, 'valor invalido');
        RETURN 'valor invalido';
    END IF;

    IF p_de = p_para THEN
        INSERT INTO transferencias_log (conta_de, conta_para, valor, resultado)
        VALUES (p_de, p_para, p_valor, 'mesma conta');
        RETURN 'mesma conta';
    END IF;

    -- IMPORTANTE: travar na MESMA ORDEM em qualquer chamada concorrente.
    -- Trava primeiro o menor id, depois o maior. Evita deadlock clássico.
    v_menor_id := LEAST(p_de, p_para);
    v_maior_id := GREATEST(p_de, p_para);

    PERFORM 1 FROM contas WHERE id = v_menor_id FOR UPDATE;
    PERFORM 1 FROM contas WHERE id = v_maior_id FOR UPDATE;

    -- conta de origem existe?
    SELECT saldo INTO v_saldo_de FROM contas WHERE id = p_de;
    IF NOT FOUND THEN
        INSERT INTO transferencias_log (conta_de, conta_para, valor, resultado)
        VALUES (p_de, p_para, p_valor, 'conta origem inexistente');
        RETURN 'conta origem inexistente';
    END IF;

    -- conta destino existe?
    SELECT TRUE INTO v_existe_para FROM contas WHERE id = p_para;
    IF NOT FOUND THEN
        INSERT INTO transferencias_log (conta_de, conta_para, valor, resultado)
        VALUES (p_de, p_para, p_valor, 'conta destino inexistente');
        RETURN 'conta destino inexistente';
    END IF;

    -- saldo suficiente?
    IF v_saldo_de < p_valor THEN
        INSERT INTO transferencias_log (conta_de, conta_para, valor, resultado)
        VALUES (p_de, p_para, p_valor, 'saldo insuficiente');
        RETURN 'saldo insuficiente';
    END IF;

    -- debita e credita
    UPDATE contas SET saldo = saldo - p_valor WHERE id = p_de;
    UPDATE contas SET saldo = saldo + p_valor WHERE id = p_para;

    -- SAVEPOINT antes do log: se a auditoria falhar, NÃO derruba a movimentação.
    -- (PL/pgSQL não tem SAVEPOINT literal, mas BEGIN/EXCEPTION cria um subbloco
    --  com semântica equivalente — internamente vira savepoint.)
    BEGIN
        INSERT INTO transferencias_log (conta_de, conta_para, valor, resultado)
        VALUES (p_de, p_para, p_valor, 'ok');
    EXCEPTION WHEN OTHERS THEN
        -- log falhou (ex: tabela cheia, trigger lançou erro), mas a transferência
        -- em si está OK. Apenas relata.
        RAISE NOTICE 'log de auditoria falhou: %', SQLERRM;
    END;

    RETURN 'ok';
END;
$$ LANGUAGE plpgsql;


-- --- Testes ----------------------------------

-- Estado inicial
SELECT * FROM contas ORDER BY id;

-- 1. Transferência OK: Alice (1) → Bruno (2), R$ 100
SELECT transferir(1, 2, 100);
SELECT * FROM contas ORDER BY id;

-- 2. Saldo insuficiente
SELECT transferir(3, 1, 50);   -- Carla tem 0
SELECT * FROM contas ORDER BY id;

-- 3. Conta destino inexistente
SELECT transferir(1, 999, 10);

-- 4. Mesma conta
SELECT transferir(1, 1, 10);

-- 5. Valor inválido
SELECT transferir(1, 2, -5);

-- Log final
SELECT id, conta_de, conta_para, valor, resultado, criado_em
FROM transferencias_log
ORDER BY id;


-- =============================================
-- 🧪 Bônus: testar concorrência em 2 sessões
-- Sessão A: BEGIN; SELECT transferir(1, 2, 100); -- não comita
-- Sessão B: BEGIN; SELECT transferir(2, 1, 100); -- vai esperar o FOR UPDATE
-- Sessão A: COMMIT;
-- Sessão B: prossegue e comita.
-- Sem o lock + ordem fixa, isso poderia gerar deadlock ou saldo errado.
-- =============================================
