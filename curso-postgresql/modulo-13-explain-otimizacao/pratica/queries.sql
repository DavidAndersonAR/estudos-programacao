-- =============================================
-- Módulo 13 — EXPLAIN e Otimização
-- Prática: lendo planos e medindo o efeito de índices
-- Pré-requisito: schema + seed dos módulos anteriores carregados
-- Dica: rode cada bloco e LEIA o plano antes de seguir.
-- =============================================

-- Exercício 1: EXPLAIN simples (só o plano, sem executar)
-- Observe: aparece Seq Scan ou Index Scan? Qual o cost? E o rows estimado?
EXPLAIN
SELECT * FROM produtos WHERE preco > 100;

-- Exercício 2: EXPLAIN ANALYZE (executa de verdade e mede)
-- Compare "rows" estimado vs "actual rows". Se forem muito diferentes → ANALYZE precisa rodar.
EXPLAIN ANALYZE
SELECT * FROM produtos WHERE preco > 100;

-- Exercício 3: Comparar com vs sem índice
-- 3a) Antes do índice — filtre por uma coluna que NÃO é PK (deve dar Seq Scan)
EXPLAIN ANALYZE
SELECT * FROM clientes WHERE email = 'joao@example.com';

-- 3b) Criar o índice
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes(email);

-- 3c) Depois do índice — refaça a mesma query e veja o plano virar Index Scan
EXPLAIN ANALYZE
SELECT * FROM clientes WHERE email = 'joao@example.com';

-- 3d) Removendo pra próxima prática (opcional — comente se quiser manter)
-- DROP INDEX idx_clientes_email;

-- Exercício 4: EXPLAIN (ANALYZE, BUFFERS) — ver cache vs disco
-- shared hit = veio do cache (rápido) | read = veio do disco (lento)
-- Rode 2 vezes! Na segunda quase tudo vira "hit".
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.nome, c.nome AS categoria
FROM produtos p
JOIN categorias c ON c.id = p.categoria_id
WHERE p.estoque > 0;

-- Exercício 5: Formato JSON (pra colar em explain.depesz.com / dalibo)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT cliente_id, count(*) AS qtd_pedidos
FROM pedidos
GROUP BY cliente_id
ORDER BY qtd_pedidos DESC
LIMIT 10;

-- Exercício 6: ANALYZE numa tabela (atualiza estatísticas)
-- Útil depois de COPY, INSERT em massa, ou quando o plano "do nada" piora.
ANALYZE produtos;

-- E se quiser uma coluna específica:
ANALYZE produtos (preco);

-- Exercício 7: pg_stat_user_tables — saúde das tabelas
-- seq_scan alto e idx_scan baixo → faltam índices ou tabela é pequena demais pra usá-los
-- n_dead_tup alto → vacuum atrasado
SELECT relname,
       seq_scan, seq_tup_read,
       idx_scan, idx_tup_fetch,
       n_live_tup, n_dead_tup,
       last_analyze, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

-- Exercício 8: Query problemática (full scan grande) + criar índice e comparar
-- Cenário: buscar pedidos de um cliente específico. Sem índice em cliente_id → Seq Scan.

-- 8a) ANTES — observe Seq Scan e "Rows Removed by Filter"
EXPLAIN ANALYZE
SELECT * FROM pedidos WHERE cliente_id = 42;

-- 8b) Cria o índice
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente_id ON pedidos(cliente_id);

-- 8c) Atualiza estatísticas (sempre depois de mexer em índice/dados grandes)
ANALYZE pedidos;

-- 8d) DEPOIS — agora deve aparecer Index Scan, com actual time MUITO menor
EXPLAIN ANALYZE
SELECT * FROM pedidos WHERE cliente_id = 42;

-- 8e) BÔNUS: query mais pesada que se beneficia do mesmo índice
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.nome, count(p.id) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id
GROUP BY c.nome
ORDER BY total_pedidos DESC
LIMIT 20;

-- Mensagem final
SELECT 'Prática 13 concluída — você sabe ler EXPLAIN agora!' AS resultado;
