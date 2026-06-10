-- =============================================
-- Módulo 02 — SELECT básico
-- Prática: WHERE, ORDER BY, LIMIT/OFFSET, DISTINCT, AS
-- Pré-requisito: schema.sql + seed.sql do Módulo 01 carregados
-- =============================================

-- Exercício 1: WHERE simples com igualdade
-- Pega todos os pedidos que ainda estão pendentes.
-- Lembre: string fica entre aspas simples ('pendente'), nunca duplas.
SELECT id, cliente_id, data_pedido
FROM pedidos
WHERE status = 'pendente';

-- Exercício 2: WHERE com comparação numérica
-- Produtos que custam mais que R$ 500. Útil pra encontrar itens "premium".
SELECT nome, preco
FROM produtos
WHERE preco > 500;

-- Exercício 3: WHERE com AND (duas condições precisam bater)
-- Produtos caros (> 500) E que ainda têm estoque (> 0).
-- Sem estoque não adianta ser caro, ninguém compra.
SELECT nome, preco, estoque
FROM produtos
WHERE preco > 500 AND estoque > 0;

-- Exercício 4: WHERE com OR + parênteses defensivos
-- Clientes do Rio OU de São Paulo. Os parênteses não são obrigatórios aqui,
-- mas é um bom hábito quando OR vai conviver com AND no futuro.
SELECT nome, cidade, estado
FROM clientes
WHERE (estado = 'RJ' OR estado = 'SP');

-- Exercício 5: ORDER BY decrescente — o coração do miniprojeto
-- Lista produtos do mais caro pro mais barato. DESC = descendente.
SELECT nome, preco
FROM produtos
ORDER BY preco DESC;

-- Exercício 6: ORDER BY + LIMIT = "top N"
-- Os 10 produtos mais caros da loja. Esse é o padrão clássico de "top".
-- Sem ORDER BY, LIMIT pegaria 10 linhas QUAISQUER — não confie nisso.
SELECT nome, preco
FROM produtos
ORDER BY preco DESC
LIMIT 10;

-- Exercício 7: ORDER BY por duas colunas (desempate)
-- Ordena por preço decrescente; quando o preço empata, desempata pelo nome A→Z.
-- Tudo que está no ORDER BY tem precedência da esquerda pra direita.
SELECT nome, preco
FROM produtos
ORDER BY preco DESC, nome ASC;

-- Exercício 8: LIMIT + OFFSET (paginação)
-- Pula os 10 primeiros e mostra os próximos 10. Equivale à "página 2"
-- numa listagem de 10 por página: OFFSET = (pagina - 1) * 10.
SELECT id, nome, preco
FROM produtos
ORDER BY id
LIMIT 10 OFFSET 10;

-- Exercício 9: DISTINCT — valores únicos
-- Quais estados a loja tem clientes? Sem DISTINCT, viria um por linha de cliente.
SELECT DISTINCT estado
FROM clientes
ORDER BY estado;

-- Exercício 10: aliases (AS) + expressão calculada
-- Renomeia colunas no resultado e cria uma coluna nova com preço + 10% imposto.
-- Alias deixa o resultado mais legível pra quem lê o relatório.
SELECT
    nome         AS produto,
    preco        AS valor_atual,
    preco * 1.10 AS valor_com_imposto
FROM produtos AS p
WHERE p.preco > 0
ORDER BY valor_com_imposto DESC
LIMIT 5;
