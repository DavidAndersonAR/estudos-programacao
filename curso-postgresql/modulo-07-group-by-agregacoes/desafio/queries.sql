-- =============================================
-- Módulo 07 — Desafio: Estatísticas de Vendas
-- Resolva cada TODO. As soluções estão dentro de /* */
-- após cada bloco — descomente só depois de tentar.
-- =============================================

-- ---------------------------------------------
-- 1) Total vendido por mês
-- TODO: para cada mês, calcule o valor total faturado
--       (some quantidade * preco_unitario dos itens dos pedidos).
--       Ignore pedidos cancelados. Ordene do mês mais recente pro mais antigo.
--       Dica: date_trunc('month', p.data_pedido) agrupa por mês.
-- ---------------------------------------------

/*
SELECT
    date_trunc('month', p.data_pedido)::date AS mes,
    sum(ip.quantidade * ip.preco_unitario)   AS total_vendido
FROM pedidos p
JOIN itens_pedido ip ON ip.pedido_id = p.id
WHERE p.status <> 'cancelado'
GROUP BY date_trunc('month', p.data_pedido)
ORDER BY mes DESC;
*/


-- ---------------------------------------------
-- 2) Ticket médio por cliente
-- TODO: para cada cliente, calcule:
--       - quantos pedidos não-cancelados ele tem
--       - quanto ele gastou no total
--       - qual o ticket médio (gasto / qtd pedidos)
--       Ordene por ticket médio decrescente.
--       Dica: precisa agregar uma subquery por pedido pra não duplicar
--             ao juntar com itens_pedido. Use subquery ou CTE.
-- ---------------------------------------------

/*
WITH valor_por_pedido AS (
    SELECT
        p.id AS pedido_id,
        p.cliente_id,
        sum(ip.quantidade * ip.preco_unitario) AS valor
    FROM pedidos p
    JOIN itens_pedido ip ON ip.pedido_id = p.id
    WHERE p.status <> 'cancelado'
    GROUP BY p.id, p.cliente_id
)
SELECT
    c.id,
    c.nome,
    count(v.pedido_id)        AS qtd_pedidos,
    sum(v.valor)              AS gasto_total,
    round(avg(v.valor), 2)    AS ticket_medio
FROM clientes c
JOIN valor_por_pedido v ON v.cliente_id = c.id
GROUP BY c.id, c.nome
ORDER BY ticket_medio DESC;
*/


-- ---------------------------------------------
-- 3) Top 3 clientes que mais compraram em QUANTIDADE de pedidos
-- TODO: liste os 3 clientes com mais pedidos (qualquer status).
--       Mostre id, nome, qtd_pedidos.
-- ---------------------------------------------

/*
SELECT
    c.id,
    c.nome,
    count(p.id) AS qtd_pedidos
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.id
GROUP BY c.id, c.nome
ORDER BY qtd_pedidos DESC, c.nome
LIMIT 3;
*/


-- ---------------------------------------------
-- 4) Top 3 clientes que mais compraram em VALOR
-- TODO: liste os 3 clientes que mais gastaram (somando qtd * preco_unitario).
--       Ignore cancelados. Mostre id, nome, gasto_total.
-- ---------------------------------------------

/*
SELECT
    c.id,
    c.nome,
    sum(ip.quantidade * ip.preco_unitario) AS gasto_total
FROM clientes c
JOIN pedidos p       ON p.cliente_id = c.id
JOIN itens_pedido ip ON ip.pedido_id = p.id
WHERE p.status <> 'cancelado'
GROUP BY c.id, c.nome
ORDER BY gasto_total DESC, c.nome
LIMIT 3;
*/


-- ---------------------------------------------
-- 5) Receita por categoria
-- TODO: para cada categoria, calcule a receita total
--       (sum(quantidade * preco_unitario) dos itens vendidos).
--       Ignore cancelados. Mostre o nome da categoria e ordene
--       da maior pra menor receita.
-- ---------------------------------------------

/*
SELECT
    cat.id,
    cat.nome AS categoria,
    sum(ip.quantidade * ip.preco_unitario) AS receita
FROM categorias cat
JOIN produtos prd     ON prd.categoria_id = cat.id
JOIN itens_pedido ip  ON ip.produto_id    = prd.id
JOIN pedidos p        ON p.id             = ip.pedido_id
WHERE p.status <> 'cancelado'
GROUP BY cat.id, cat.nome
ORDER BY receita DESC;
*/


-- ---------------------------------------------
-- 6) Pedidos cancelados vs total por mês
-- TODO: por mês, mostre:
--       - total de pedidos
--       - pedidos cancelados
--       - pedidos entregues
--       - taxa de cancelamento (% com 2 casas)
--       Use FILTER pra fazer tudo numa só query.
-- ---------------------------------------------

/*
SELECT
    date_trunc('month', data_pedido)::date AS mes,
    count(*)                                          AS total,
    count(*) FILTER (WHERE status = 'cancelado')      AS cancelados,
    count(*) FILTER (WHERE status = 'entregue')       AS entregues,
    round(
        100.0 * count(*) FILTER (WHERE status = 'cancelado') / count(*),
        2
    ) AS taxa_cancelamento_pct
FROM pedidos
GROUP BY date_trunc('month', data_pedido)
ORDER BY mes DESC;
*/


-- ---------------------------------------------
-- 7) Total acumulado de itens vendidos (running total)
-- TODO: liste, por mês, a quantidade de itens vendidos no mês
--       E o acumulado desde o primeiro mês.
--       Dica: sum(...) OVER (ORDER BY mes) — janela!
--       Aqui você já flerta com window functions (módulo futuro).
--       Ignore cancelados.
-- ---------------------------------------------

/*
WITH por_mes AS (
    SELECT
        date_trunc('month', p.data_pedido)::date AS mes,
        sum(ip.quantidade) AS qtd_mes
    FROM pedidos p
    JOIN itens_pedido ip ON ip.pedido_id = p.id
    WHERE p.status <> 'cancelado'
    GROUP BY date_trunc('month', p.data_pedido)
)
SELECT
    mes,
    qtd_mes,
    sum(qtd_mes) OVER (ORDER BY mes) AS qtd_acumulada
FROM por_mes
ORDER BY mes;
*/


-- ---------------------------------------------
-- 8) Relatório consolidado por status + total geral (GROUPING SETS)
-- TODO: monte um relatório com:
--       - qtd de pedidos por status
--       - receita total por status
--       - uma linha final de TOTAL GERAL (status NULL)
--       Use GROUPING SETS. Ignore cancelados na receita
--       (mas mantenha-os na contagem de pedidos).
-- ---------------------------------------------

/*
SELECT
    p.status,
    count(DISTINCT p.id) AS qtd_pedidos,
    COALESCE(
        sum(ip.quantidade * ip.preco_unitario)
            FILTER (WHERE p.status <> 'cancelado'),
        0
    ) AS receita
FROM pedidos p
LEFT JOIN itens_pedido ip ON ip.pedido_id = p.id
GROUP BY GROUPING SETS ((p.status), ())
ORDER BY p.status NULLS LAST;
*/
