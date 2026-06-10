-- =============================================
-- Módulo 01 — Bem-vindo + Setup
-- Prática: primeiros comandos pra explorar a loja
-- Pré-requisito: rodar schema.sql + seed.sql antes
-- =============================================

-- Exercício 1: ver tudo de uma tabela
-- O caso clássico (cuidado em tabelas grandes — sempre use LIMIT em produção!)
SELECT * FROM categorias;

-- Exercício 2: contar registros
SELECT count(*) AS total_produtos FROM produtos;
SELECT count(*) AS total_clientes FROM clientes;
SELECT count(*) AS total_pedidos FROM pedidos;

-- Exercício 3: ver apenas algumas colunas
SELECT nome, preco FROM produtos;

-- Exercício 4: limitar quantidade de linhas
SELECT nome, preco FROM produtos LIMIT 5;

-- Exercício 5: descobrir estrutura via SQL (em vez de \d)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- Exercício 6: descobrir os bancos e usuário atual
SELECT current_database(), current_user, version();

-- Exercício 7: ver os tipos enum (que é o status_pedido)
SELECT enum_range(NULL::status_pedido);
