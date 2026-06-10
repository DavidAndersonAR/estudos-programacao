-- =============================================
-- 🎯 DESAFIO DO MÓDULO 02 — Top 10 produtos mais caros
-- =============================================
--
-- Cenário:
-- O time de marketing quer destacar os produtos premium da loja
-- e entender melhor o catálogo. Sua missão: responder as perguntas
-- usando SELECT + WHERE + ORDER BY + LIMIT/OFFSET + DISTINCT + AS.
--
-- 💡 Dicas:
--   - Use ORDER BY DESC pra "mais caro / mais recente / maior"
--   - LIMIT N pra "top N"
--   - OFFSET M pra "pular os M primeiros"
--   - DISTINCT pra valores únicos
--   - Apelide colunas com AS pra deixar o relatório legível
--
-- ============================
-- SUA SOLUÇÃO ABAIXO
-- ============================

-- Pergunta 1: Liste os 10 produtos mais caros (nome e preço),
-- do mais caro pro mais barato.


-- Pergunta 2: Liste todos os produtos com preço abaixo de R$ 100,
-- ordenados do mais barato pro mais caro.


-- Pergunta 3: Mostre os produtos SEM estoque (estoque = 0).
-- Apelide o nome da coluna 'nome' como "produto_em_falta".


-- Pergunta 4: Liste os clientes do RJ OU SP, ordenados pela data
-- de cadastro do mais recente pro mais antigo. Mostre nome, estado
-- e data_cadastro.


-- Pergunta 5: Pule os 5 produtos mais caros e me dê os próximos 5
-- (do 6º ao 10º mais caro). Pense em LIMIT + OFFSET.


-- Pergunta 6: Quais cidades únicas a loja atende? Liste em ordem
-- alfabética, sem repetição.


-- Pergunta 7: Use DISTINCT ON pra trazer o produto MAIS CARO
-- de cada categoria (uma linha por categoria_id).
-- Mostre categoria_id, nome e preco.


-- ============================
-- SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
-- ============================

/*
-- 1: Top 10 produtos mais caros
SELECT nome, preco
FROM produtos
ORDER BY preco DESC
LIMIT 10;

-- 2: Produtos abaixo de R$ 100, do mais barato pro mais caro
SELECT nome, preco
FROM produtos
WHERE preco < 100
ORDER BY preco ASC;

-- 3: Produtos sem estoque, com alias
SELECT nome AS produto_em_falta, preco
FROM produtos
WHERE estoque = 0
ORDER BY nome;

-- 4: Clientes do RJ ou SP, ordenados por data de cadastro DESC
SELECT nome, estado, data_cadastro
FROM clientes
WHERE estado = 'RJ' OR estado = 'SP'
ORDER BY data_cadastro DESC;

-- 5: Pular os 5 primeiros (mais caros) e pegar os próximos 5
SELECT nome, preco
FROM produtos
ORDER BY preco DESC
LIMIT 5 OFFSET 5;

-- 6: Cidades únicas que a loja atende
SELECT DISTINCT cidade
FROM clientes
WHERE cidade IS NOT NULL
ORDER BY cidade ASC;

-- 7: Produto mais caro de cada categoria (DISTINCT ON é PG-only)
SELECT DISTINCT ON (categoria_id)
       categoria_id,
       nome,
       preco
FROM produtos
ORDER BY categoria_id, preco DESC;
*/
