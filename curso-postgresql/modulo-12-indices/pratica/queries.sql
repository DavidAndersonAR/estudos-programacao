-- =============================================
-- Módulo 12 — Índices
-- Prática: criar, inspecionar e remover índices
-- Pré-requisito: schema + seed do Módulo 01 carregados
-- =============================================

-- Antes de começar: habilita extensão de busca por similaridade
-- (vamos usar no exercício de GIN e no desafio)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Exercício 1: B-tree simples
-- Índice clássico em coluna usada em WHERE/JOIN
CREATE INDEX idx_produtos_categoria ON produtos (categoria_id);

-- Exercício 2: índice multi-coluna
-- Útil quando os dois campos aparecem juntos no WHERE.
-- Ordem importa: cliente_id (mais seletivo) primeiro.
CREATE INDEX idx_pedidos_cliente_data ON pedidos (cliente_id, data_pedido);

-- Exercício 3: partial index
-- Só indexa pedidos que ainda interessam (não cancelados).
-- Resultado: índice menor, mais rápido, e o planner usa quando a
-- query repetir a mesma condição.
CREATE INDEX idx_pedidos_ativos ON pedidos (cliente_id, data_pedido)
WHERE status <> 'cancelado';

-- Exercício 4: expression index
-- Permite busca case-insensitive usando lower(email) e ainda usar índice.
CREATE INDEX idx_clientes_email_lower ON clientes (lower(email));

-- Teste (deve usar o índice acima):
EXPLAIN SELECT * FROM clientes WHERE lower(email) = 'maria@exemplo.com';

-- Exercício 5: GIN com pg_trgm em coluna texto
-- Acelera buscas por SUBSTRING tipo: WHERE nome ILIKE '%fone%'
CREATE INDEX idx_produtos_nome_trgm ON produtos USING GIN (nome gin_trgm_ops);

-- Teste:
EXPLAIN SELECT * FROM produtos WHERE nome ILIKE '%fone%';

-- Exercício 6: índice UNIQUE manual
-- (PK e UNIQUE já criam índice automático; este aqui é exemplo de
-- uma regra de negócio: garantir que não exista cliente duplicado
-- por nome+cidade)
CREATE UNIQUE INDEX uq_clientes_nome_cidade ON clientes (nome, cidade);

-- Exercício 7: listar índices da tabela produtos
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'produtos'
ORDER BY indexname;

-- Exercício 8: tamanho de cada índice da tabela pedidos
SELECT
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS tamanho
FROM pg_indexes
WHERE tablename = 'pedidos';

-- Exercício 9: tamanho da tabela vs. tamanho total (tabela + índices)
SELECT
    pg_size_pretty(pg_relation_size('produtos')) AS tabela,
    pg_size_pretty(pg_indexes_size('produtos'))  AS indices,
    pg_size_pretty(pg_total_relation_size('produtos')) AS total;

-- Exercício 10: removendo um índice (use quando perceber que não compensa)
DROP INDEX IF EXISTS uq_clientes_nome_cidade;
