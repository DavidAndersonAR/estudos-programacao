-- =============================================
-- Módulo 09 — Subqueries
-- Prática: subquery escalar, derived table, IN, EXISTS,
--          correlated e LATERAL JOIN
-- Pré-requisito: schema + seed do Módulo 01 carregados
-- =============================================

-- Exercício 1: subquery escalar — média de preço da loja
-- Retorna 1 número. Bom pra usar em WHERE ou SELECT.
SELECT AVG(preco) AS media_geral FROM produtos;


-- Exercício 2: produtos acima da média geral
-- Caso clássico de subquery escalar no WHERE.
SELECT nome, preco
FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos)
ORDER BY preco DESC;


-- Exercício 3: subquery escalar no SELECT (mostra a média em cada linha)
-- Útil pra comparação visual; em tabela grande, prefira derived table.
SELECT nome,
       preco,
       (SELECT AVG(preco) FROM produtos) AS media_geral,
       preco - (SELECT AVG(preco) FROM produtos) AS diferenca
FROM produtos
ORDER BY diferenca DESC
LIMIT 10;


-- Exercício 4: IN (SELECT ...) — clientes que já fizeram pedido
SELECT id, nome, email
FROM clientes
WHERE id IN (SELECT DISTINCT cliente_id FROM pedidos)
ORDER BY nome;


-- Exercício 5: NOT EXISTS — clientes SEM nenhum pedido
-- Preferimos NOT EXISTS a NOT IN por causa do problema com NULL.
SELECT c.id, c.nome, c.email
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.id
)
ORDER BY c.nome;


-- Exercício 6: subquery no FROM (derived table)
-- Primeiro agrega contagem de produtos por categoria, depois filtra.
SELECT cat_nome, total_produtos
FROM (
    SELECT c.nome AS cat_nome, COUNT(p.id) AS total_produtos
    FROM categorias c
    LEFT JOIN produtos p ON p.categoria_id = c.id
    GROUP BY c.nome
) AS resumo                              -- alias obrigatório
WHERE total_produtos > 0
ORDER BY total_produtos DESC;


-- Exercício 7: correlated subquery — pra cada cliente, contar pedidos
-- A subquery referencia c.id (coluna da query externa).
SELECT c.nome,
       (SELECT COUNT(*)
        FROM pedidos p
        WHERE p.cliente_id = c.id) AS qtd_pedidos
FROM clientes c
ORDER BY qtd_pedidos DESC, c.nome
LIMIT 10;


-- Exercício 8: EXISTS — categorias que TÊM ao menos um produto
-- Mais limpo que IN quando o predicado pode crescer.
SELECT cat.nome
FROM categorias cat
WHERE EXISTS (
    SELECT 1
    FROM produtos p
    WHERE p.categoria_id = cat.id
)
ORDER BY cat.nome;


-- Exercício 9: ANY — produto mais caro que QUALQUER produto da categoria 1
-- Equivale a: preco > (mínimo da categoria 1).
SELECT nome, preco, categoria_id
FROM produtos
WHERE preco > ANY (
    SELECT preco FROM produtos WHERE categoria_id = 1
)
ORDER BY preco DESC
LIMIT 10;


-- Exercício 10: LATERAL — pra cada cliente, pegar o pedido mais recente
-- LEFT JOIN LATERAL + ON TRUE mantém o cliente mesmo sem pedido.
SELECT c.nome,
       ult.id          AS ultimo_pedido_id,
       ult.data_pedido AS ultima_data,
       ult.status      AS ultimo_status
FROM clientes c
LEFT JOIN LATERAL (
    SELECT id, data_pedido, status
    FROM pedidos p
    WHERE p.cliente_id = c.id
    ORDER BY data_pedido DESC
    LIMIT 1
) AS ult ON TRUE
ORDER BY ult.data_pedido DESC NULLS LAST, c.nome;
