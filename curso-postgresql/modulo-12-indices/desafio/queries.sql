-- =============================================
-- Módulo 12 — DESAFIO
-- Indexar uma query lenta
-- =============================================
-- Cenário: o time de produto reclama que algumas telas estão
-- LENTAS. Você abre o log e identifica as queries críticas
-- abaixo. Sua missão: criar os ÍNDICES CERTOS pra cada uma.
--
-- Pré-requisito: extensão pg_trgm habilitada (vide pratica)
--    CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- =============================================


-- ──────────────────────────────────────────────
-- Pergunta 1
-- ──────────────────────────────────────────────
-- A busca "produto por nome contendo X" (ILIKE '%termo%')
-- está fazendo Seq Scan em produtos. Qual índice resolve?
--
-- Query alvo:
--   SELECT id, nome, preco FROM produtos WHERE nome ILIKE '%fone%';
--
-- TODO: criar o índice
-- DICA: B-tree não serve com % no início. Pensa em GIN + trigram.

-- (sua resposta aqui)


-- ──────────────────────────────────────────────
-- Pergunta 2
-- ──────────────────────────────────────────────
-- A tela "Meus Pedidos" busca todos os pedidos de UM cliente,
-- ordenados por data desc. Hoje faz Seq Scan + Sort.
--
-- Query alvo:
--   SELECT * FROM pedidos
--   WHERE cliente_id = 42
--   ORDER BY data_pedido DESC;
--
-- TODO: criar índice que resolva filtro + ordenação juntos.

-- (sua resposta aqui)


-- ──────────────────────────────────────────────
-- Pergunta 3
-- ──────────────────────────────────────────────
-- Um job roda toda hora: "listar pedidos pendentes ou pagos
-- por cliente". O status 'cancelado' é maioria histórica e
-- nunca cai nesse job.
--
-- Query alvo:
--   SELECT * FROM pedidos
--   WHERE status IN ('pendente','pago') AND cliente_id = 42;
--
-- TODO: criar PARTIAL index — assim ele fica pequeno e rápido.

-- (sua resposta aqui)


-- ──────────────────────────────────────────────
-- Pergunta 4
-- ──────────────────────────────────────────────
-- Login do cliente: a app sempre compara o email em minúsculas
-- (o usuário pode digitar "Foo@BAR.com"). Hoje é Seq Scan.
--
-- Query alvo:
--   SELECT id, nome FROM clientes
--   WHERE lower(email) = lower('Foo@Bar.com');
--
-- TODO: criar EXPRESSION index pra resolver case-insensitive.

-- (sua resposta aqui)


-- ──────────────────────────────────────────────
-- Pergunta 5
-- ──────────────────────────────────────────────
-- Listar índices NUNCA usados desde o último restart
-- (candidatos a DROP — gastam disco e desaceleram escrita
-- sem entregar nada).
--
-- TODO: escrever a query usando pg_stat_user_indexes.

-- (sua resposta aqui)


-- ──────────────────────────────────────────────
-- Pergunta 6
-- ──────────────────────────────────────────────
-- A query do dashboard lista nome+preço por categoria:
--   SELECT nome, preco FROM produtos WHERE categoria_id = 3;
--
-- TODO: criar um COVERING INDEX (INCLUDE) que permita
-- Index-Only Scan, sem nem tocar na tabela.

-- (sua resposta aqui)


-- =============================================
-- SOLUÇÃO
-- =============================================
-- (Tente antes de olhar! O aprendizado tá na luta.)

-- Resposta 1 — GIN com pg_trgm pra ILIKE '%...%':
--   B-tree comum não cobre busca com % no início. O operador
--   de classe gin_trgm_ops quebra a string em trigramas e
--   indexa cada um, viabilizando substring search.
CREATE INDEX idx_produtos_nome_trgm
    ON produtos USING GIN (nome gin_trgm_ops);


-- Resposta 2 — B-tree multi-coluna (cliente_id, data_pedido DESC):
--   Pega o filtro pelo cliente E já entrega ordenado pela data,
--   evitando Sort. Coluna mais seletiva (cliente_id) vem primeiro.
CREATE INDEX idx_pedidos_cliente_data
    ON pedidos (cliente_id, data_pedido DESC);


-- Resposta 3 — Partial index com a mesma condição da query:
--   Reduz drasticamente o tamanho do índice porque não inclui
--   pedidos cancelados. O planner só usa esse índice quando a
--   query repete o mesmo predicado (ou mais restritivo).
CREATE INDEX idx_pedidos_ativos_por_cliente
    ON pedidos (cliente_id)
    WHERE status IN ('pendente', 'pago');


-- Resposta 4 — Expression index em lower(email):
--   Sem essa, qualquer função aplicada na coluna invalida
--   o índice comum. Aqui o Postgres indexa direto o resultado.
CREATE INDEX idx_clientes_email_lower
    ON clientes (lower(email));


-- Resposta 5 — Índices nunca usados:
--   idx_scan = 0 significa "ninguém leu via esse índice".
--   Ignoramos UNIQUE/PK porque servem pra integridade, não só leitura.
SELECT
    s.schemaname,
    s.relname     AS tabela,
    s.indexrelname AS indice,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS tamanho,
    s.idx_scan    AS leituras
FROM pg_stat_user_indexes s
JOIN pg_index i ON i.indexrelid = s.indexrelid
WHERE s.idx_scan = 0
  AND NOT i.indisunique          -- não conta PK/UNIQUE
  AND NOT i.indisprimary
ORDER BY pg_relation_size(s.indexrelid) DESC;


-- Resposta 6 — Covering index (INCLUDE, PG 11+):
--   Chave de busca = categoria_id. As colunas extras vão como
--   "payload" no índice, então a leitura nem visita a tabela
--   (Index-Only Scan). Cuidado: aumenta tamanho do índice.
CREATE INDEX idx_produtos_categoria_inc
    ON produtos (categoria_id)
    INCLUDE (nome, preco);


-- =============================================
-- Bônus: comparando antes/depois
-- =============================================
-- Rode EXPLAIN ANALYZE antes e depois de cada índice pra
-- ver Seq Scan virar Index Scan / Bitmap Index Scan / Index-Only Scan.
-- Veremos esse plano em detalhe no Módulo 13.

EXPLAIN ANALYZE SELECT id, nome, preco FROM produtos WHERE nome ILIKE '%fone%';
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE cliente_id = 42 ORDER BY data_pedido DESC;
EXPLAIN ANALYZE SELECT nome, preco FROM produtos WHERE categoria_id = 3;
