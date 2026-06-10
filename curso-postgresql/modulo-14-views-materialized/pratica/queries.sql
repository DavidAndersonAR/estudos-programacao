-- =============================================
-- Módulo 14 — Views e Materialized Views
-- Prática: criar, consultar, atualizar e indexar
-- Pré-requisito: schema + seed do Módulo 1 carregados
-- =============================================

-- Exercício 1: criar uma VIEW simples
-- "produtos_em_estoque" = só produtos com estoque > 0
CREATE OR REPLACE VIEW produtos_em_estoque AS
SELECT id, nome, preco, estoque, categoria_id
FROM produtos
WHERE estoque > 0;

-- Exercício 2: consultar a view (parece tabela)
SELECT * FROM produtos_em_estoque LIMIT 10;
SELECT count(*) AS qtd_em_estoque FROM produtos_em_estoque;

-- Exercício 3: view com JOIN (produto + nome da categoria)
CREATE OR REPLACE VIEW produtos_com_categoria AS
SELECT
    p.id,
    p.nome           AS produto,
    p.preco,
    p.estoque,
    c.nome           AS categoria
FROM produtos p
LEFT JOIN categorias c ON c.id = p.categoria_id;

SELECT * FROM produtos_com_categoria ORDER BY categoria, produto LIMIT 15;

-- Exercício 4: CREATE OR REPLACE VIEW — adicionando coluna calculada
-- Mostra também o valor total em estoque (preco * quantidade)
CREATE OR REPLACE VIEW produtos_em_estoque AS
SELECT
    id,
    nome,
    preco,
    estoque,
    categoria_id,
    (preco * estoque) AS valor_total_estoque
FROM produtos
WHERE estoque > 0;

SELECT nome, valor_total_estoque
FROM produtos_em_estoque
ORDER BY valor_total_estoque DESC
LIMIT 5;

-- Exercício 5: criar uma MATERIALIZED VIEW
-- "vendas_por_mes" — total de vendas por mês (só pedidos pagos/enviados/entregues)
CREATE MATERIALIZED VIEW vendas_por_mes AS
SELECT
    date_trunc('month', p.data_pedido)::date     AS mes,
    COUNT(DISTINCT p.id)                          AS qtd_pedidos,
    SUM(i.quantidade * i.preco_unitario)          AS total_vendido
FROM pedidos p
JOIN itens_pedido i ON i.pedido_id = p.id
WHERE p.status IN ('pago', 'enviado', 'entregue')
GROUP BY 1
ORDER BY 1;

SELECT * FROM vendas_por_mes;

-- Exercício 6: REFRESH simples (bloqueia leituras durante o refresh)
REFRESH MATERIALIZED VIEW vendas_por_mes;

-- Exercício 7: criar UNIQUE index pra liberar REFRESH CONCURRENTLY
-- (cada mês aparece uma vez — coluna mes serve como chave única)
CREATE UNIQUE INDEX idx_vendas_por_mes_mes ON vendas_por_mes(mes);

-- Agora dá pra atualizar sem bloquear leitores:
REFRESH MATERIALIZED VIEW CONCURRENTLY vendas_por_mes;

-- Índice extra de performance: ordenar/filtrar por total
CREATE INDEX idx_vendas_por_mes_total ON vendas_por_mes(total_vendido DESC);

SELECT * FROM vendas_por_mes ORDER BY total_vendido DESC LIMIT 3;

-- Exercício 8: DROP MV (e a view também, pra limpar)
DROP MATERIALIZED VIEW IF EXISTS vendas_por_mes;
DROP VIEW IF EXISTS produtos_com_categoria;
DROP VIEW IF EXISTS produtos_em_estoque;
