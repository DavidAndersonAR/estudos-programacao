-- =============================================
-- Módulo 09 — Desafio: Clientes Acima da Média
-- Tema: usar subqueries pra encontrar quem/o quê está
--       "acima da média" em diferentes recortes da loja.
-- Recomendado: tente cada TODO primeiro, depois compare
--              com a SOLUÇÃO comentada logo abaixo.
-- =============================================


-- ---------------------------------------------
-- Pergunta 1: Quais clientes gastaram acima da
-- média geral de gasto por cliente?
-- ("gasto" = SUM(quantidade * preco_unitario) dos itens
--  dos pedidos do cliente, ignorando pedidos cancelados)
-- ---------------------------------------------

-- TODO 1: calcule o gasto por cliente, depois compare
--         com a média desses gastos. Dica: derived table
--         + subquery escalar no WHERE.

/* SOLUÇÃO 1
SELECT g.cliente_id, g.nome, g.total_gasto
FROM (
    SELECT c.id   AS cliente_id,
           c.nome,
           SUM(ip.quantidade * ip.preco_unitario) AS total_gasto
    FROM clientes c
    JOIN pedidos p      ON p.cliente_id = c.id
    JOIN itens_pedido ip ON ip.pedido_id = p.id
    WHERE p.status <> 'cancelado'
    GROUP BY c.id, c.nome
) AS g
WHERE g.total_gasto > (
    -- média do gasto por cliente (não a média de itens!)
    SELECT AVG(total_gasto)
    FROM (
        SELECT SUM(ip.quantidade * ip.preco_unitario) AS total_gasto
        FROM pedidos p
        JOIN itens_pedido ip ON ip.pedido_id = p.id
        WHERE p.status <> 'cancelado'
        GROUP BY p.cliente_id
    ) AS por_cliente
)
ORDER BY g.total_gasto DESC;
*/


-- ---------------------------------------------
-- Pergunta 2: Quais produtos estão mais caros
-- que a média da SUA própria categoria?
-- (correlated subquery clássica)
-- ---------------------------------------------

-- TODO 2: pra cada produto, compare seu preço com a média
--         da categoria dele.

/* SOLUÇÃO 2
SELECT p.id,
       p.nome,
       p.preco,
       p.categoria_id,
       (SELECT AVG(preco)
        FROM produtos p2
        WHERE p2.categoria_id = p.categoria_id) AS media_categoria
FROM produtos p
WHERE p.preco > (
    SELECT AVG(preco)
    FROM produtos p2
    WHERE p2.categoria_id = p.categoria_id
)
ORDER BY p.categoria_id, p.preco DESC;
*/


-- ---------------------------------------------
-- Pergunta 3: Quais clientes NUNCA tiveram um
-- pedido com status 'entregue'?
-- (pode incluir quem nunca pediu nada)
-- ---------------------------------------------

-- TODO 3: use NOT EXISTS (mais seguro que NOT IN).

/* SOLUÇÃO 3
SELECT c.id, c.nome, c.email
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
      AND p.status = 'entregue'
)
ORDER BY c.nome;
*/


-- ---------------------------------------------
-- Pergunta 4: Quais categorias têm pelo menos
-- um produto acima de R$ 1000?
-- ---------------------------------------------

-- TODO 4: use EXISTS — só queremos saber se existe,
--         não nos importa quantos ou quais.

/* SOLUÇÃO 4
SELECT cat.id, cat.nome
FROM categorias cat
WHERE EXISTS (
    SELECT 1
    FROM produtos p
    WHERE p.categoria_id = cat.id
      AND p.preco > 1000
)
ORDER BY cat.nome;
*/


-- ---------------------------------------------
-- Pergunta 5: Pra cada categoria, qual é o
-- produto MAIS CARO?
-- (use LATERAL — top 1 por grupo)
-- ---------------------------------------------

-- TODO 5: junte categorias com uma LATERAL que pega
--         o produto top 1 por preço daquela categoria.

/* SOLUÇÃO 5
SELECT cat.nome AS categoria,
       top.nome AS produto_mais_caro,
       top.preco
FROM categorias cat
LEFT JOIN LATERAL (
    SELECT nome, preco
    FROM produtos p
    WHERE p.categoria_id = cat.id
    ORDER BY p.preco DESC
    LIMIT 1
) AS top ON TRUE
ORDER BY top.preco DESC NULLS LAST;
*/


-- ---------------------------------------------
-- Pergunta 6 (bônus / integradora):
-- Mostre os clientes "acima da média" da Pergunta 1,
-- junto com a quantidade de pedidos deles e o ticket
-- médio (gasto / nº de pedidos não cancelados).
-- ---------------------------------------------

-- TODO 6: combine derived table com correlated subquery
--         pra produzir uma "fichinha" do cliente premium.

/* SOLUÇÃO 6
SELECT g.cliente_id,
       g.nome,
       g.total_gasto,
       (SELECT COUNT(*)
        FROM pedidos p
        WHERE p.cliente_id = g.cliente_id
          AND p.status <> 'cancelado') AS qtd_pedidos,
       ROUND(
           g.total_gasto /
           NULLIF((SELECT COUNT(*)
                   FROM pedidos p
                   WHERE p.cliente_id = g.cliente_id
                     AND p.status <> 'cancelado'), 0),
           2
       ) AS ticket_medio
FROM (
    SELECT c.id   AS cliente_id,
           c.nome,
           SUM(ip.quantidade * ip.preco_unitario) AS total_gasto
    FROM clientes c
    JOIN pedidos p       ON p.cliente_id = c.id
    JOIN itens_pedido ip ON ip.pedido_id = p.id
    WHERE p.status <> 'cancelado'
    GROUP BY c.id, c.nome
) AS g
WHERE g.total_gasto > (
    SELECT AVG(total_gasto)
    FROM (
        SELECT SUM(ip.quantidade * ip.preco_unitario) AS total_gasto
        FROM pedidos p
        JOIN itens_pedido ip ON ip.pedido_id = p.id
        WHERE p.status <> 'cancelado'
        GROUP BY p.cliente_id
    ) AS por_cliente
)
ORDER BY g.total_gasto DESC;
*/

-- =============================================
-- Quando terminar:
--  - Reflita: em quais perguntas o EXISTS substituiria
--    o IN com vantagem? Em quais o LATERAL seria mais
--    elegante que uma correlated subquery?
--  - Próximo módulo: CTEs (WITH) e Window Functions.
-- =============================================
