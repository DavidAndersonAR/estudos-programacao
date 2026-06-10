-- =============================================
-- Módulo 08 — JOINs
-- Prática: costurando tabelas da loja
-- Pré-requisito: schema.sql + seed.sql carregados
-- =============================================

-- Exercício 1: INNER JOIN — produtos com o nome da categoria
-- Só aparecem produtos que TÊM categoria associada.
SELECT
    p.id,
    p.nome    AS produto,
    p.preco,
    c.nome    AS categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.nome, p.nome;

-- Exercício 2: LEFT JOIN + COUNT — categorias e quantos produtos cada uma tem
-- Categoria SEM produto também aparece (com count = 0).
-- Dica: COUNT(p.id) ignora NULL; COUNT(*) contaria a linha do LEFT mesmo vazia.
SELECT
    c.id,
    c.nome              AS categoria,
    COUNT(p.id)         AS qtd_produtos
FROM categorias c
LEFT JOIN produtos p ON p.categoria_id = c.id
GROUP BY c.id, c.nome
ORDER BY qtd_produtos DESC, c.nome;

-- Exercício 3: INNER JOIN — pedidos + dados do cliente
SELECT
    pe.id           AS pedido_id,
    pe.data_pedido,
    pe.status,
    cli.nome        AS cliente,
    cli.cidade
FROM pedidos pe
INNER JOIN clientes cli ON pe.cliente_id = cli.id
ORDER BY pe.data_pedido DESC;

-- Exercício 4: LEFT JOIN + IS NULL — clientes que NUNCA pediram nada
-- Padrão clássico de "anti-join": tudo da esquerda que NÃO tem match.
SELECT
    cli.id,
    cli.nome,
    cli.email,
    cli.data_cadastro
FROM clientes cli
LEFT JOIN pedidos pe ON pe.cliente_id = cli.id
WHERE pe.id IS NULL
ORDER BY cli.data_cadastro;

-- Exercício 5: 3+ tabelas — para cada produto vendido, qual cliente comprou
-- Caminho: produtos -> itens_pedido -> pedidos -> clientes
SELECT
    pr.nome        AS produto,
    ip.quantidade,
    pe.id          AS pedido_id,
    pe.data_pedido,
    cli.nome       AS cliente
FROM produtos pr
INNER JOIN itens_pedido ip  ON ip.produto_id = pr.id
INNER JOIN pedidos      pe  ON ip.pedido_id  = pe.id
INNER JOIN clientes     cli ON pe.cliente_id = cli.id
ORDER BY pe.data_pedido DESC, pr.nome;

-- Exercício 6a: ON explícito — versão verbosa
SELECT pr.nome, c.nome AS categoria
FROM produtos pr
INNER JOIN categorias c ON pr.categoria_id = c.id;

-- Exercício 6b: USING — só funcionaria se as colunas tivessem o MESMO nome.
-- Como na nossa loja o produto tem "categoria_id" e a categoria tem "id",
-- USING não se aplica direto aqui. Exemplo abaixo é hipotético:
-- SELECT pr.nome, c.nome FROM produtos pr JOIN categorias c USING (categoria_id);
-- USING já junta as colunas no resultado (não duplica). Útil em PKs/FKs com nome igual.

-- Exercício 7: CROSS JOIN — gerar combinações (matriz)
-- Útil pra catálogos: combinar todas categorias com todos os status possíveis,
-- para depois LEFT JOIN com vendas e ver buracos no relatório.
SELECT
    c.nome                                  AS categoria,
    unnest(enum_range(NULL::status_pedido)) AS status
FROM categorias c
ORDER BY c.nome, status;

-- Versão pura de CROSS JOIN (sem unnest):
SELECT c.nome AS categoria, s.status
FROM categorias c
CROSS JOIN (SELECT unnest(enum_range(NULL::status_pedido)) AS status) s
ORDER BY c.nome, s.status;

-- Exercício 8: SELF JOIN — hierarquia hipotética de categorias
-- Imagine que categorias tem uma coluna parent_id apontando pra própria tabela.
-- Mesmo sem a coluna existir no nosso schema, o padrão é esse:
--
-- ALTER TABLE categorias ADD COLUMN parent_id INTEGER REFERENCES categorias(id);
-- UPDATE categorias SET parent_id = 1 WHERE id IN (2,3);
--
-- SELECT
--     filho.nome  AS subcategoria,
--     pai.nome    AS categoria_pai
-- FROM categorias filho
-- LEFT JOIN categorias pai ON filho.parent_id = pai.id
-- ORDER BY pai.nome NULLS FIRST, filho.nome;

-- Exercício 9: comparando contagens — INNER vs LEFT
-- Útil pra "sentir" a diferença visualmente.
SELECT 'INNER (produtos com categoria)' AS tipo, COUNT(*) AS linhas
FROM produtos p INNER JOIN categorias c ON p.categoria_id = c.id
UNION ALL
SELECT 'LEFT  (todos os produtos)', COUNT(*)
FROM produtos p LEFT JOIN categorias c ON p.categoria_id = c.id;

-- Exercício 10: pegadinha do filtro em LEFT JOIN
-- ERRADO: vira INNER por causa do WHERE
SELECT cli.nome, pe.id
FROM clientes cli
LEFT JOIN pedidos pe ON pe.cliente_id = cli.id
WHERE pe.status = 'pago';

-- CERTO: filtro DENTRO do ON preserva o LEFT
SELECT cli.nome, pe.id
FROM clientes cli
LEFT JOIN pedidos pe
    ON pe.cliente_id = cli.id
   AND pe.status = 'pago';
