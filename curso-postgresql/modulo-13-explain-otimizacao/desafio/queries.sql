-- =============================================
-- Módulo 13 — DESAFIO: Diagnosticar queries lentas
-- =============================================
-- Você é o(a) DBA de plantão. Devs reclamando que 5 queries
-- "estão lentas". Sua missão pra cada uma:
--   1. Rodar EXPLAIN ANALYZE
--   2. Identificar o GARGALO (Seq Scan? estimativa errada? sort em disco?)
--   3. Corrigir (criar índice / refatorar query / rodar ANALYZE)
--   4. Rodar EXPLAIN ANALYZE de novo e MEDIR a diferença
--
-- Cada tarefa tem TODOs pra você fazer, e logo abaixo
-- a SOLUÇÃO COMENTADA explicando o plano.
-- =============================================


-- ┌──────────────────────────────────────────────────────────┐
-- │ TAREFA 1 — Busca de cliente por email                    │
-- └──────────────────────────────────────────────────────────┘
-- Problema: o sistema de login chama essa query a cada autenticação.
-- Está demorando ~200ms num banco de 1M de clientes.
--
-- Query problema:
--   SELECT id, nome FROM clientes WHERE email = 'fulano@example.com';

-- TODO 1.1: rode com EXPLAIN ANALYZE e copie o plano abaixo (em comentário)
-- TODO 1.2: identifique o gargalo
-- TODO 1.3: aplique a correção
-- TODO 1.4: rode EXPLAIN ANALYZE de novo

-- ───── SOLUÇÃO ─────
-- Gargalo: Seq Scan + filtro em coluna sem índice. Em 1M de linhas vira ~200ms.
-- O plano antes mostra algo como:
--   Seq Scan on clientes (cost=0..18500 rows=1)
--     Filter: (email = 'fulano@example.com')
--     Rows Removed by Filter: 999999
-- Correção: índice em email (já é UNIQUE no schema, então pode até já existir).

-- CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);
-- ANALYZE clientes;
-- EXPLAIN ANALYZE SELECT id, nome FROM clientes WHERE email = 'fulano@example.com';
--
-- Depois: Index Scan using clientes_email_key — actual time cai pra <1ms.


-- ┌──────────────────────────────────────────────────────────┐
-- │ TAREFA 2 — Relatório de pedidos por período              │
-- └──────────────────────────────────────────────────────────┘
-- Problema: dashboard puxa pedidos do mês corrente; demora 3s.
--
-- Query problema:
--   SELECT id, cliente_id, status
--   FROM pedidos
--   WHERE data_pedido >= DATE_TRUNC('month', CURRENT_DATE);

-- TODO 2.1: EXPLAIN ANALYZE
-- TODO 2.2: identifique o gargalo
-- TODO 2.3: corrija
-- TODO 2.4: meça de novo

-- ───── SOLUÇÃO ─────
-- Gargalo: Seq Scan na tabela pedidos (cresce com o tempo). O filtro é range em data,
-- e não há índice em data_pedido. Range com índice B-tree resolve.
--
-- CREATE INDEX IF NOT EXISTS idx_pedidos_data ON pedidos(data_pedido);
-- ANALYZE pedidos;
--
-- O plano vira Index Scan (ou Bitmap Index Scan se o range for grande, ex: ano inteiro).
-- Dica extra: se o relatório SEMPRE filtra por status='pago' também, considere índice
-- composto: (data_pedido, status). A ordem importa: a coluna mais seletiva
-- usada em "=" primeiro, e a coluna de range por último.


-- ┌──────────────────────────────────────────────────────────┐
-- │ TAREFA 3 — Top produtos vendidos                         │
-- └──────────────────────────────────────────────────────────┘
-- Problema: query roda em background mas trava o servidor.
-- Suspeita: sort em disco.
--
-- Query problema:
--   SELECT p.nome, SUM(ip.quantidade) AS total_vendido
--   FROM produtos p
--   JOIN itens_pedido ip ON ip.produto_id = p.id
--   GROUP BY p.nome
--   ORDER BY total_vendido DESC
--   LIMIT 20;

-- TODO 3.1: EXPLAIN (ANALYZE, BUFFERS)
-- TODO 3.2: olhe se aparece "Sort Method: external merge Disk: NNNkB"
-- TODO 3.3: aumente work_mem na sessão e rode de novo
-- TODO 3.4: avalie se vale índice em itens_pedido(produto_id)

-- ───── SOLUÇÃO ─────
-- Gargalo típico: Hash Aggregate ou Sort em DISCO porque work_mem padrão é 4MB.
-- Veja a linha: "Sort Method: external merge  Disk: 18432kB" — disco é o vilão.
--
-- SET work_mem = '64MB';   -- só nessa sessão; em produção, ajuste no postgresql.conf
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT p.nome, SUM(ip.quantidade) ... (mesma query)
--
-- Resultado: "Sort Method: quicksort  Memory: 12000kB" — fica em RAM, várias vezes mais rápido.
-- Bônus: índice em itens_pedido(produto_id) pode trocar Hash Join por Merge Join se vier
-- ordenado, mas Hash Join costuma ser o vencedor aqui.


-- ┌──────────────────────────────────────────────────────────┐
-- │ TAREFA 4 — Plano errado por estatística desatualizada    │
-- └──────────────────────────────────────────────────────────┘
-- Problema: após carga massiva de produtos via COPY, a query abaixo
-- ficou 50x mais lenta. Nenhum índice mudou.
--
-- Query problema:
--   SELECT * FROM produtos WHERE categoria_id = 5 AND estoque > 0;

-- TODO 4.1: EXPLAIN ANALYZE — compare "rows" estimado vs "actual rows"
-- TODO 4.2: se estiver muito diferente, rode ANALYZE
-- TODO 4.3: rode EXPLAIN ANALYZE de novo

-- ───── SOLUÇÃO ─────
-- Gargalo: planner pensou que ia voltar 10 linhas e escolheu Nested Loop / Index Scan
-- com pouco ganho. Na verdade voltam 50.000 linhas → caminho errado.
-- Sintoma no plano: "rows=10 ... actual rows=50000".
--
-- Causa: COPY/INSERT em massa NÃO dispara autoanalyze imediato. Estatísticas ficam podres.
--
-- ANALYZE produtos;
-- EXPLAIN ANALYZE SELECT * FROM produtos WHERE categoria_id = 5 AND estoque > 0;
--
-- Com estatísticas corretas, o planner pode escolher Bitmap Heap Scan
-- (ou Seq Scan se 50k de 60k linhas — aí Seq Scan é MELHOR que índice!).
-- Lição: depois de carga em massa, SEMPRE rode ANALYZE.


-- ┌──────────────────────────────────────────────────────────┐
-- │ TAREFA 5 — Join lento de pedidos + clientes + itens      │
-- └──────────────────────────────────────────────────────────┘
-- Problema: relatório de "pedidos do mês com nome do cliente e total de itens"
-- demora 8s. Tabelas grandes.
--
-- Query problema:
--   SELECT p.id, c.nome, COUNT(ip.produto_id) AS qtd_itens, SUM(ip.preco_unitario * ip.quantidade) AS valor
--   FROM pedidos p
--   JOIN clientes c ON c.id = p.cliente_id
--   JOIN itens_pedido ip ON ip.pedido_id = p.id
--   WHERE p.data_pedido >= CURRENT_DATE - INTERVAL '30 days'
--   GROUP BY p.id, c.nome
--   ORDER BY valor DESC
--   LIMIT 50;

-- TODO 5.1: EXPLAIN (ANALYZE, BUFFERS)
-- TODO 5.2: identifique qual nó está custando mais (cost total e actual time mais altos)
-- TODO 5.3: crie os índices que faltam
-- TODO 5.4: rode novamente e compare

-- ───── SOLUÇÃO ─────
-- Gargalos comuns aqui:
--   1) Seq Scan em pedidos por causa do filtro de data → falta índice em data_pedido.
--   2) Nested Loop em itens_pedido com Seq Scan → falta índice em pedido_id
--      (a PK já cobre, mas se for (pedido_id, produto_id) já serve o range por pedido_id).
--   3) Hash em clientes pesado se a tabela for muito grande, mas com PK normalmente é OK.
--
-- CREATE INDEX IF NOT EXISTS idx_pedidos_data       ON pedidos(data_pedido);
-- CREATE INDEX IF NOT EXISTS idx_pedidos_cliente_id ON pedidos(cliente_id);
-- -- itens_pedido já tem PK (pedido_id, produto_id) → cobre o join por pedido_id
-- ANALYZE pedidos; ANALYZE itens_pedido; ANALYZE clientes;
--
-- EXPLAIN (ANALYZE, BUFFERS) <mesma query>
--
-- Plano esperado:
--   Limit
--     -> Sort (top-N heapsort, em memória)
--       -> HashAggregate
--         -> Hash Join (clientes)
--           -> Nested Loop (pedidos -> itens_pedido)
--             -> Bitmap Heap Scan on pedidos  (uses idx_pedidos_data)
--             -> Index Scan on itens_pedido_pkey
--
-- Tempo cai de 8s pra <500ms tranquilo. Se ainda houver "external merge Disk" no Sort,
-- aumente work_mem como na Tarefa 3.


-- =============================================
-- Checklist final do desafio:
--   [ ] Rodei EXPLAIN ANALYZE antes de tudo nas 5 tarefas
--   [ ] Identifiquei o gargalo (Seq Scan, estatística, sort em disco, plano errado)
--   [ ] Apliquei a correção (índice, ANALYZE, work_mem)
--   [ ] Medi a diferença com EXPLAIN ANALYZE depois
--   [ ] Sei explicar POR QUE o plano mudou
-- =============================================

SELECT 'Desafio 13 concluído — agora você diagnostica query lenta!' AS resultado;
