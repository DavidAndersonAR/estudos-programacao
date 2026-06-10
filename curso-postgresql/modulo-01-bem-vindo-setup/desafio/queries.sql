-- =============================================
-- 🎯 DESAFIO DO MÓDULO 01 — Explorando a Loja
-- =============================================
--
-- Objetivo:
-- Familiarize-se com o banco respondendo as perguntas abaixo.
-- Pra cada pergunta, escreva uma query que dá a resposta.
--
-- Pergunta 1: Quantas categorias existem na loja?
-- Pergunta 2: Quais são as 3 primeiras categorias (mostrando id e nome)?
-- Pergunta 3: Quantos produtos existem ao todo?
-- Pergunta 4: Mostre o nome dos primeiros 10 produtos.
-- Pergunta 5: Quantos clientes a loja tem?
-- Pergunta 6: Quantos pedidos foram feitos?
-- Pergunta 7: Quais são os status possíveis de pedido? (Dica: enum_range)
--
-- 💡 Dicas:
--   - count(*) conta linhas
--   - LIMIT n limita a quantidade
--   - Em SQL você não precisa pensar "como" — só descrever "o que" quer
--
-- ============================
-- SUA SOLUÇÃO ABAIXO
-- ============================

-- Pergunta 1:


-- Pergunta 2:


-- Pergunta 3:


-- Pergunta 4:


-- Pergunta 5:


-- Pergunta 6:


-- Pergunta 7:


-- ============================
-- SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
-- ============================

/*
-- 1: Quantas categorias existem?
SELECT count(*) FROM categorias;

-- 2: 3 primeiras categorias
SELECT id, nome FROM categorias LIMIT 3;

-- 3: Total de produtos
SELECT count(*) FROM produtos;

-- 4: Nome dos primeiros 10 produtos
SELECT nome FROM produtos LIMIT 10;

-- 5: Total de clientes
SELECT count(*) FROM clientes;

-- 6: Total de pedidos
SELECT count(*) FROM pedidos;

-- 7: Status possíveis de pedido
SELECT unnest(enum_range(NULL::status_pedido)) AS status_disponiveis;
*/
