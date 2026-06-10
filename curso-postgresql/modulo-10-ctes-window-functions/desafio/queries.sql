-- =============================================
-- Módulo 10 — Desafio: Ranking de Produtos por Categoria
-- 6 perguntas — cada uma com TODO + solução logo abaixo.
-- Tente fazer SEM olhar a solução primeiro!
-- =============================================

-- ---------------------------------------------
-- Pergunta 1: Top 3 produtos mais caros de cada categoria
-- TODO: monte uma CTE com ROW_NUMBER() particionado por categoria_id
-- ordenado por preco DESC. Depois filtre WHERE posicao <= 3.
-- ---------------------------------------------
WITH ranking AS (
    SELECT
        p.id,
        p.nome,
        p.preco,
        c.nome AS categoria,
        ROW_NUMBER() OVER (PARTITION BY p.categoria_id ORDER BY p.preco DESC) AS posicao
    FROM produtos p
    JOIN categorias c ON c.id = p.categoria_id
)
SELECT categoria, posicao, nome, preco
FROM ranking
WHERE posicao <= 3
ORDER BY categoria, posicao;

-- ---------------------------------------------
-- Pergunta 2: Ranking de clientes por valor total comprado
-- TODO: some itens_pedido por cliente (só pedidos pagos/enviados/entregues),
-- aplique RANK() ordenado pelo total DESC. Mostre top 10.
-- ---------------------------------------------
WITH compras_por_cliente AS (
    SELECT
        c.id,
        c.nome,
        SUM(i.quantidade * i.preco_unitario) AS total_gasto
    FROM clientes c
    JOIN pedidos p     ON p.cliente_id = c.id
    JOIN itens_pedido i ON i.pedido_id  = p.id
    WHERE p.status IN ('pago','enviado','entregue')
    GROUP BY c.id, c.nome
)
SELECT
    RANK() OVER (ORDER BY total_gasto DESC) AS posicao,
    nome,
    total_gasto
FROM compras_por_cliente
ORDER BY posicao
LIMIT 10;

-- ---------------------------------------------
-- Pergunta 3: Diferença % entre preço atual e mediana da categoria
-- TODO: use PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco) OVER (PARTITION BY categoria_id)
-- — ou subquery com mediana — e calcule (preco - mediana) / mediana * 100.
-- ---------------------------------------------
WITH com_mediana AS (
    SELECT
        p.id,
        p.nome,
        p.preco,
        p.categoria_id,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.preco)
            OVER (PARTITION BY p.categoria_id) AS mediana_categoria
    FROM produtos p
)
SELECT
    categoria_id,
    nome,
    preco,
    ROUND(mediana_categoria::numeric, 2) AS mediana,
    ROUND(((preco - mediana_categoria) / mediana_categoria * 100)::numeric, 2) AS dif_percentual
FROM com_mediana
ORDER BY categoria_id, dif_percentual DESC;

-- ---------------------------------------------
-- Pergunta 4: Total acumulado de vendas por mês
-- TODO: agregue itens_pedido por mês (date_trunc('month', data_pedido)),
-- depois aplique SUM(vendas) OVER (ORDER BY mes) pra acumular.
-- ---------------------------------------------
WITH vendas_mes AS (
    SELECT
        date_trunc('month', p.data_pedido)::date AS mes,
        SUM(i.quantidade * i.preco_unitario) AS vendas
    FROM pedidos p
    JOIN itens_pedido i ON i.pedido_id = p.id
    WHERE p.status IN ('pago','enviado','entregue')
    GROUP BY date_trunc('month', p.data_pedido)
)
SELECT
    mes,
    vendas,
    SUM(vendas) OVER (ORDER BY mes) AS acumulado,
    ROUND(
        (vendas / NULLIF(LAG(vendas) OVER (ORDER BY mes), 0) - 1) * 100,
        2
    ) AS crescimento_pct_vs_mes_anterior
FROM vendas_mes
ORDER BY mes;

-- ---------------------------------------------
-- Pergunta 5: Classificar clientes em quartis de gasto (NTILE(4))
-- TODO: mesmo padrão da Q2, mas em vez de RANK use NTILE(4).
-- Mostre quantos clientes caem em cada quartil e gasto médio do quartil.
-- ---------------------------------------------
WITH gasto_cliente AS (
    SELECT
        c.id,
        c.nome,
        SUM(i.quantidade * i.preco_unitario) AS total_gasto
    FROM clientes c
    JOIN pedidos p     ON p.cliente_id = c.id
    JOIN itens_pedido i ON i.pedido_id  = p.id
    WHERE p.status IN ('pago','enviado','entregue')
    GROUP BY c.id, c.nome
),
com_quartil AS (
    SELECT
        nome,
        total_gasto,
        NTILE(4) OVER (ORDER BY total_gasto) AS quartil
    FROM gasto_cliente
)
SELECT
    quartil,
    COUNT(*) AS qtd_clientes,
    ROUND(AVG(total_gasto)::numeric, 2) AS gasto_medio,
    ROUND(MIN(total_gasto)::numeric, 2) AS gasto_min,
    ROUND(MAX(total_gasto)::numeric, 2) AS gasto_max
FROM com_quartil
GROUP BY quartil
ORDER BY quartil;

-- ---------------------------------------------
-- Pergunta 6 (bônus): produto mais caro vs. mais barato da categoria, em cada linha
-- TODO: use FIRST_VALUE (mais caro) e LAST_VALUE (mais barato) com frame
-- BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING — atenção à pegadinha do LAST_VALUE!
-- ---------------------------------------------
SELECT
    c.nome AS categoria,
    p.nome AS produto,
    p.preco,
    FIRST_VALUE(p.nome) OVER w AS produto_mais_caro,
    LAST_VALUE(p.nome)  OVER w AS produto_mais_barato,
    MAX(p.preco) OVER (PARTITION BY p.categoria_id)
        - MIN(p.preco) OVER (PARTITION BY p.categoria_id) AS amplitude_preco_categoria
FROM produtos p
JOIN categorias c ON c.id = p.categoria_id
WINDOW w AS (
    PARTITION BY p.categoria_id
    ORDER BY p.preco DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
ORDER BY categoria, p.preco DESC;
