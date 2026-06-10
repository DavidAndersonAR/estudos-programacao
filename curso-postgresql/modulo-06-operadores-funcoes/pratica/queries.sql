-- =============================================
-- Módulo 06 — Operadores e Funções
-- Prática: operadores de filtro + funções nativas
-- Pré-requisito: schema + seed do Módulo 01 carregados
-- =============================================

-- Exercício 1: ILIKE — buscar produtos que mencionam "smart"
-- (case-insensitive: pega Smart, SMART, smart...)
SELECT id, nome, preco
FROM produtos
WHERE nome ILIKE '%smart%';

-- Exercício 2: IN — produtos de várias categorias de uma vez
-- (substitui categoria_id = 1 OR categoria_id = 2 OR ...)
SELECT id, nome, categoria_id
FROM produtos
WHERE categoria_id IN (1, 2, 3);

-- Exercício 3: BETWEEN — produtos numa faixa de preço (inclusivo)
SELECT nome, preco
FROM produtos
WHERE preco BETWEEN 100 AND 1000
ORDER BY preco;

-- Exercício 4: COALESCE — exibir "(sem cidade)" pra quem tem cidade NULL
SELECT
    nome,
    COALESCE(cidade, '(sem cidade)') AS cidade
FROM clientes;

-- Exercício 5: CASE WHEN — classificando preços em faixas
SELECT
    nome,
    preco,
    CASE
        WHEN preco < 100  THEN 'barato'
        WHEN preco < 1000 THEN 'médio'
        ELSE                   'caro'
    END AS faixa_preco
FROM produtos
ORDER BY preco;

-- Exercício 6: date_trunc — agrupar pedidos por mês
SELECT
    date_trunc('month', data_pedido) AS mes,
    count(*) AS total_pedidos
FROM pedidos
GROUP BY mes
ORDER BY mes;

-- Exercício 7: extract — pegar o ano do pedido como número
SELECT
    id,
    data_pedido,
    extract(year FROM data_pedido)::int AS ano
FROM pedidos
ORDER BY data_pedido;

-- Exercício 8: age() — tempo desde o cadastro do cliente
SELECT
    nome,
    data_cadastro,
    age(current_date, data_cadastro) AS tempo_de_casa
FROM clientes
ORDER BY data_cadastro;

-- Exercício 9: format() — gerar texto com placeholders (%s, %I, %L)
SELECT format(
    'Produto: %s — R$ %s',
    nome,
    to_char(preco, 'FM999G999D00')
) AS linha
FROM produtos
LIMIT 10;

-- Exercício 10: regex ~ — validando formato de email
-- (operador ~ é regex case-sensitive, ~* seria case-insensitive)
SELECT
    nome,
    email,
    CASE
        WHEN email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            THEN 'válido'
        ELSE     'inválido'
    END AS status_email
FROM clientes;
