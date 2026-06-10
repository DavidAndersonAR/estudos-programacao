-- =============================================
-- Módulo 19 — Particionamento
-- DESAFIO: particionar pedidos por mês
--
-- Cenário: a tabela `pedidos` da loja virou um monstro.
-- Você vai simular a reformulação:
--   1) criar `pedidos_particionado` por RANGE(data_pedido) mensal
--   2) migrar os dados antigos via INSERT...SELECT
--   3) criar partições pra todos os meses de 2025 (jan a dez)
--   4) criar um índice global na coluna de busca mais comum
--
-- Pré-requisito: schema + seed da loja já carregados.
-- =============================================

-- ===== TODO 1 =====
-- Crie a tabela `pedidos_particionado` com as mesmas colunas de `pedidos`
-- (id, cliente_id, data_pedido, status), particionada por RANGE em data_pedido.
-- Lembrete: a PK precisa incluir a coluna de partição (data_pedido).

-- CREATE TABLE pedidos_particionado (...)
-- PARTITION BY RANGE (data_pedido);


-- ===== TODO 2 =====
-- Crie as 12 partições mensais para 2025
-- (pedidos_particionado_2025_01 ... pedidos_particionado_2025_12).
-- Cada uma cobre [primeiro dia do mês, primeiro dia do mês seguinte).

-- CREATE TABLE pedidos_particionado_2025_01 PARTITION OF pedidos_particionado
--     FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
-- ... (repita para os outros meses)


-- ===== TODO 3 =====
-- Crie uma DEFAULT partition para o que cair fora de 2025
-- (pedidos antigos da migração, futuros sem partição ainda).


-- ===== TODO 4 =====
-- Migre os dados: INSERT INTO pedidos_particionado (...)
-- SELECT ... FROM pedidos;
-- IMPORTANTE: inclua a coluna id explicitamente pra preservar os IDs originais.


-- ===== TODO 5 =====
-- Crie um índice global em (cliente_id) — o Postgres propaga pra todas as partições.
-- Esse é o filtro mais comum em telas de "meus pedidos".


-- ===== TODO 6 =====
-- Valide: conte quantos pedidos caíram em cada partição usando tableoid::regclass.


-- ===== TODO 7 =====
-- Rode um EXPLAIN com filtro em data_pedido (ex.: WHERE data_pedido >= '2025-03-01'
-- AND data_pedido < '2025-04-01') e confirme que só a partição de março aparece.


-- =============================================
-- SOLUÇÃO
-- (Tenta antes de ler. Vale mais errar e voltar.)
-- =============================================

DROP TABLE IF EXISTS pedidos_particionado CASCADE;

-- Solução TODO 1: tabela pai particionada por RANGE em data_pedido
-- Note que a PK virou composta (id, data_pedido) — exigência do particionamento.
CREATE TABLE pedidos_particionado (
    id          INTEGER NOT NULL,
    cliente_id  INTEGER NOT NULL REFERENCES clientes(id),
    data_pedido TIMESTAMP NOT NULL DEFAULT NOW(),
    status      status_pedido NOT NULL DEFAULT 'pendente',
    PRIMARY KEY (id, data_pedido)
) PARTITION BY RANGE (data_pedido);

-- Solução TODO 2: 12 partições mensais para 2025
CREATE TABLE pedidos_particionado_2025_01 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE pedidos_particionado_2025_02 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE pedidos_particionado_2025_03 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE pedidos_particionado_2025_04 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE pedidos_particionado_2025_05 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE pedidos_particionado_2025_06 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE pedidos_particionado_2025_07 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE pedidos_particionado_2025_08 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE pedidos_particionado_2025_09 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE pedidos_particionado_2025_10 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE pedidos_particionado_2025_11 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE pedidos_particionado_2025_12 PARTITION OF pedidos_particionado
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- Solução TODO 3: DEFAULT pra capturar o que sobrar
CREATE TABLE pedidos_particionado_default PARTITION OF pedidos_particionado DEFAULT;

-- Solução TODO 4: migração — inclui id explicitamente
-- (em produção real, isso vai dentro de uma transação com lock controlado)
INSERT INTO pedidos_particionado (id, cliente_id, data_pedido, status)
SELECT id, cliente_id, data_pedido, status
FROM pedidos;

-- Solução TODO 5: índice global em cliente_id (propaga pras partições)
CREATE INDEX idx_pedidos_part_cliente ON pedidos_particionado (cliente_id);

-- Solução TODO 6: distribuição por partição
SELECT tableoid::regclass AS particao, count(*) AS total
FROM pedidos_particionado
GROUP BY tableoid
ORDER BY tableoid::regclass::text;

-- Solução TODO 7: comprovar pruning
EXPLAIN
SELECT * FROM pedidos_particionado
WHERE data_pedido >= '2025-03-01' AND data_pedido < '2025-04-01';

-- Bônus: ver as partições cadastradas no catálogo
SELECT
    parent.relname  AS tabela_pai,
    child.relname   AS particao,
    pg_get_expr(child.relpartbound, child.oid) AS bound
FROM pg_inherits i
JOIN pg_class parent ON parent.oid = i.inhparent
JOIN pg_class child  ON child.oid  = i.inhrelid
WHERE parent.relname = 'pedidos_particionado'
ORDER BY child.relname;
