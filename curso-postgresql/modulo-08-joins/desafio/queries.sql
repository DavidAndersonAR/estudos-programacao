-- =============================================
-- Módulo 08 — Desafio
-- Relatório de Vendas Detalhado
-- Sua missão: responda as perguntas usando JOINs.
-- Tente sozinho ANTES de olhar a solução abaixo de cada bloco.
-- =============================================

-- ---------------------------------------------
-- TODO 1: Liste TODOS os itens de pedido com:
--   cliente_nome, produto_nome, categoria_nome, quantidade,
--   preco_unitario e total_item (qtd * preco_unitario).
-- Ordene por pedido_id e produto_nome.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    pe.id                              AS pedido_id,
    cli.nome                           AS cliente_nome,
    pr.nome                            AS produto_nome,
    cat.nome                           AS categoria_nome,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS total_item
FROM itens_pedido ip
INNER JOIN pedidos    pe  ON ip.pedido_id  = pe.id
INNER JOIN clientes   cli ON pe.cliente_id = cli.id
INNER JOIN produtos   pr  ON ip.produto_id = pr.id
INNER JOIN categorias cat ON pr.categoria_id = cat.id
ORDER BY pe.id, pr.nome;


-- ---------------------------------------------
-- TODO 2: Total de vendas por CATEGORIA.
-- Inclua categorias SEM vendas (devem aparecer com total = 0).
-- Dica: LEFT JOIN começando em categorias + COALESCE.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    cat.nome                                                     AS categoria,
    COUNT(DISTINCT pe.id)                                        AS qtd_pedidos,
    COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0)          AS total_vendido
FROM categorias cat
LEFT JOIN produtos    pr ON pr.categoria_id = cat.id
LEFT JOIN itens_pedido ip ON ip.produto_id  = pr.id
LEFT JOIN pedidos     pe ON ip.pedido_id    = pe.id
GROUP BY cat.id, cat.nome
ORDER BY total_vendido DESC;


-- ---------------------------------------------
-- TODO 3: Clientes que NUNCA compraram nada da categoria "Livros".
-- Inclui também quem nunca comprou nada (não tem pedido).
-- Dica: LEFT JOIN filtrando pela categoria DENTRO do ON, depois WHERE IS NULL.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    cli.id,
    cli.nome,
    cli.email
FROM clientes cli
LEFT JOIN pedidos      pe  ON pe.cliente_id   = cli.id
LEFT JOIN itens_pedido ip  ON ip.pedido_id    = pe.id
LEFT JOIN produtos     pr  ON ip.produto_id   = pr.id
LEFT JOIN categorias   cat ON pr.categoria_id = cat.id
                          AND cat.nome        = 'Livros'
GROUP BY cli.id, cli.nome, cli.email
HAVING COUNT(cat.id) = 0
ORDER BY cli.nome;


-- ---------------------------------------------
-- TODO 4: Produtos NUNCA vendidos (não aparecem em itens_pedido).
-- Dica: anti-join clássico — LEFT JOIN + IS NULL.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    pr.id,
    pr.nome     AS produto,
    pr.preco,
    pr.estoque,
    cat.nome    AS categoria
FROM produtos pr
LEFT JOIN itens_pedido ip  ON ip.produto_id   = pr.id
LEFT JOIN categorias   cat ON pr.categoria_id = cat.id
WHERE ip.produto_id IS NULL
ORDER BY cat.nome, pr.nome;


-- ---------------------------------------------
-- TODO 5: Top 5 clientes que mais GASTARAM no total.
-- Considere apenas pedidos NÃO cancelados.
-- Mostre: cliente, qtd_pedidos, total_gasto.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    cli.nome                                       AS cliente,
    COUNT(DISTINCT pe.id)                          AS qtd_pedidos,
    SUM(ip.quantidade * ip.preco_unitario)         AS total_gasto
FROM clientes cli
INNER JOIN pedidos      pe ON pe.cliente_id = cli.id
INNER JOIN itens_pedido ip ON ip.pedido_id  = pe.id
WHERE pe.status <> 'cancelado'
GROUP BY cli.id, cli.nome
ORDER BY total_gasto DESC
LIMIT 5;


-- ---------------------------------------------
-- TODO 6: Para cada pedido, mostre o "ticket": pedido_id, cliente,
-- qtd_itens_distintos, qtd_unidades, valor_total.
-- Ordene pelos pedidos mais caros primeiro.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    pe.id                                          AS pedido_id,
    pe.data_pedido,
    pe.status,
    cli.nome                                       AS cliente,
    COUNT(ip.produto_id)                           AS itens_distintos,
    SUM(ip.quantidade)                             AS unidades,
    SUM(ip.quantidade * ip.preco_unitario)         AS valor_total
FROM pedidos pe
INNER JOIN clientes     cli ON pe.cliente_id = cli.id
INNER JOIN itens_pedido ip  ON ip.pedido_id  = pe.id
GROUP BY pe.id, pe.data_pedido, pe.status, cli.nome
ORDER BY valor_total DESC;


-- ---------------------------------------------
-- TODO 7: Categorias x cidades — matriz cruzada.
-- Para cada combinação (categoria, cidade_do_cliente), quanto foi vendido?
-- Mostre só combinações com venda > 0.
-- ---------------------------------------------
-- Sua tentativa:


-- Solução:
SELECT
    cat.nome                                       AS categoria,
    cli.cidade                                     AS cidade,
    SUM(ip.quantidade * ip.preco_unitario)         AS total_vendido
FROM categorias cat
INNER JOIN produtos     pr  ON pr.categoria_id = cat.id
INNER JOIN itens_pedido ip  ON ip.produto_id   = pr.id
INNER JOIN pedidos      pe  ON ip.pedido_id    = pe.id
INNER JOIN clientes     cli ON pe.cliente_id   = cli.id
WHERE pe.status <> 'cancelado'
GROUP BY cat.nome, cli.cidade
ORDER BY cat.nome, total_vendido DESC;
