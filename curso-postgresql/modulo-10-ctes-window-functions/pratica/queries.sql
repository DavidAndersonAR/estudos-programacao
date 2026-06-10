-- =============================================
-- Módulo 10 — CTEs + Window Functions
-- Prática: 10 queries pra fixar WITH e OVER
-- Pré-requisito: schema + seed da loja carregados
-- =============================================

-- Exercício 1: CTE simples — top 5 produtos mais caros
-- A CTE filtra/ordena; a query principal só pega o LIMIT.
WITH produtos_ordenados AS (
    SELECT id, nome, preco
    FROM produtos
    ORDER BY preco DESC
)
SELECT * FROM produtos_ordenados LIMIT 5;

-- Exercício 2: múltiplas CTEs encadeadas
-- Etapa 1: pedidos pagos. Etapa 2: valor por pedido. Final: total por cliente.
WITH
pedidos_pagos AS (
    SELECT id, cliente_id FROM pedidos WHERE status IN ('pago','enviado','entregue')
),
valor_por_pedido AS (
    SELECT p.cliente_id, p.id AS pedido_id,
           SUM(i.quantidade * i.preco_unitario) AS total
    FROM pedidos_pagos p
    JOIN itens_pedido i ON i.pedido_id = p.id
    GROUP BY p.cliente_id, p.id
)
SELECT cliente_id, COUNT(*) AS qtd_pedidos, SUM(total) AS faturado
FROM valor_por_pedido
GROUP BY cliente_id
ORDER BY faturado DESC
LIMIT 10;

-- Exercício 3: WITH RECURSIVE — gerar sequência 1..10
WITH RECURSIVE numeros AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numeros WHERE n < 10
)
SELECT n FROM numeros;

-- Exercício 4: ROW_NUMBER por categoria — numerar produtos do mais caro pro mais barato
SELECT
    categoria_id,
    nome,
    preco,
    ROW_NUMBER() OVER (PARTITION BY categoria_id ORDER BY preco DESC) AS posicao
FROM produtos
ORDER BY categoria_id, posicao;

-- Exercício 5: RANK em todos os produtos por preço (sem partition)
-- Note como empates compartilham a mesma posição e a próxima pula.
SELECT
    nome,
    preco,
    RANK()       OVER (ORDER BY preco DESC) AS rank_preco,
    DENSE_RANK() OVER (ORDER BY preco DESC) AS dense_rank_preco
FROM produtos
ORDER BY preco DESC;

-- Exercício 6: LAG — comparar preço de cada produto com o anterior (ordenado por preço)
SELECT
    nome,
    preco,
    LAG(preco)        OVER (ORDER BY preco) AS preco_anterior,
    preco - LAG(preco) OVER (ORDER BY preco) AS diferenca
FROM produtos
ORDER BY preco;

-- Exercício 7: SUM OVER — total acumulado de vendas por dia
-- Primeiro agregamos por dia, depois acumulamos com OVER.
WITH vendas_dia AS (
    SELECT
        p.data_pedido::date AS dia,
        SUM(i.quantidade * i.preco_unitario) AS vendas
    FROM pedidos p
    JOIN itens_pedido i ON i.pedido_id = p.id
    WHERE p.status IN ('pago','enviado','entregue')
    GROUP BY p.data_pedido::date
)
SELECT
    dia,
    vendas,
    SUM(vendas) OVER (ORDER BY dia) AS acumulado
FROM vendas_dia
ORDER BY dia;

-- Exercício 8: NTILE(4) — dividir produtos em quartis de preço
SELECT
    nome,
    preco,
    NTILE(4) OVER (ORDER BY preco) AS quartil
FROM produtos
ORDER BY quartil, preco;

-- Exercício 9: FIRST_VALUE — produto mais caro de cada categoria ao lado de cada linha
SELECT
    categoria_id,
    nome,
    preco,
    FIRST_VALUE(nome)  OVER (PARTITION BY categoria_id ORDER BY preco DESC) AS mais_caro_da_categoria,
    FIRST_VALUE(preco) OVER (PARTITION BY categoria_id ORDER BY preco DESC) AS preco_topo_categoria
FROM produtos
ORDER BY categoria_id, preco DESC;

-- Exercício 10: média móvel de 3 períodos (frame clause)
-- Usa as últimas 3 linhas (atual + 2 anteriores) pra suavizar a curva de vendas diárias.
WITH vendas_dia AS (
    SELECT
        p.data_pedido::date AS dia,
        SUM(i.quantidade * i.preco_unitario) AS vendas
    FROM pedidos p
    JOIN itens_pedido i ON i.pedido_id = p.id
    WHERE p.status IN ('pago','enviado','entregue')
    GROUP BY p.data_pedido::date
)
SELECT
    dia,
    vendas,
    AVG(vendas) OVER (
        ORDER BY dia
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS media_movel_3d
FROM vendas_dia
ORDER BY dia;
