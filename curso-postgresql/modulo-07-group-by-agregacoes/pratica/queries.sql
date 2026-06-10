-- =============================================
-- Módulo 07 — GROUP BY e Agregações
-- Prática: agregando dados da loja
-- Pré-requisito: schema.sql + seed.sql carregados
-- =============================================

-- Exercício 1: contagem de produtos por categoria
-- COUNT(*) por categoria + nome da categoria via JOIN
SELECT c.id, c.nome AS categoria, count(p.id) AS qtd_produtos
FROM categorias c
LEFT JOIN produtos p ON p.categoria_id = c.id
GROUP BY c.id, c.nome
ORDER BY qtd_produtos DESC, categoria;

-- Exercício 2: total, médio, min e max de preço por categoria
-- Combinando várias agregações em uma query só
SELECT
    categoria_id,
    count(*)           AS qtd,
    sum(preco)         AS preco_total,
    round(avg(preco), 2) AS preco_medio,
    min(preco)         AS mais_barato,
    max(preco)         AS mais_caro
FROM produtos
GROUP BY categoria_id
ORDER BY categoria_id;

-- Exercício 3: quantos clientes por estado
-- Agrupando por uma coluna simples
SELECT estado, count(*) AS qtd_clientes
FROM clientes
GROUP BY estado
ORDER BY qtd_clientes DESC, estado;

-- Exercício 4: pedidos por status
-- Funciona com enum normalmente
SELECT status, count(*) AS qtd
FROM pedidos
GROUP BY status
ORDER BY qtd DESC;

-- Exercício 5: HAVING — categorias com mais de 2 produtos
-- Filtro pós-agrupamento (não dá pra usar WHERE aqui!)
SELECT categoria_id, count(*) AS qtd
FROM produtos
GROUP BY categoria_id
HAVING count(*) > 2
ORDER BY qtd DESC;

-- Exercício 6: FILTER — agregação condicional em uma query só
-- Total de pedidos + recortes por status sem precisar de UNION
SELECT
    count(*)                                       AS total_pedidos,
    count(*) FILTER (WHERE status = 'entregue')    AS entregues,
    count(*) FILTER (WHERE status = 'cancelado')   AS cancelados,
    count(*) FILTER (WHERE status = 'pendente')    AS pendentes,
    count(*) FILTER (WHERE status = 'pago')        AS pagos,
    count(*) FILTER (WHERE status = 'enviado')     AS enviados
FROM pedidos;

-- Exercício 7: GROUPING SETS — produtos por categoria + total geral
-- Subtotal por categoria + linha de TOTAL no mesmo resultado
SELECT
    categoria_id,
    count(*) AS qtd
FROM produtos
GROUP BY GROUPING SETS ((categoria_id), ())
ORDER BY categoria_id NULLS LAST;

-- Exercício 8: string_agg — lista de nomes de produtos por categoria
-- Concatena os nomes em uma string única, ordenada
SELECT
    categoria_id,
    string_agg(nome, ', ' ORDER BY nome) AS produtos
FROM produtos
GROUP BY categoria_id
ORDER BY categoria_id;

-- Exercício 9: WHERE + HAVING combinados
-- Filtra linhas antes (estoque > 0) e grupos depois (mais de 1 SKU)
SELECT categoria_id, count(*) AS skus_em_estoque
FROM produtos
WHERE estoque > 0
GROUP BY categoria_id
HAVING count(*) > 1
ORDER BY skus_em_estoque DESC;

-- Exercício 10: ROLLUP — clientes por (estado, cidade) + subtotais
-- Hierarquia: cada cidade, subtotal por estado, total geral
SELECT
    estado,
    cidade,
    count(*) AS qtd
FROM clientes
GROUP BY ROLLUP (estado, cidade)
ORDER BY estado NULLS LAST, cidade NULLS LAST;
