-- =============================================
-- Módulo 06 — Desafio: Relatório Formatado de Pedidos
-- Use o schema da loja (Módulo 01).
-- Objetivo: gerar um relatório bonito, pronto pra colar em
-- planilha ou e-mail, usando CASE, COALESCE, funções de data
-- e formatação de string/número.
-- =============================================

-- ---------------------------------------------
-- TODO 1: Listar pedidos com status traduzido em PT-BR via CASE
-- Mostre: id, data_pedido e uma coluna "status_traduzido" onde
-- pendente   -> 'Aguardando pagamento'
-- pago       -> 'Pago — aguardando envio'
-- enviado    -> 'A caminho'
-- entregue   -> 'Entregue ao cliente'
-- cancelado  -> 'Cancelado'
-- ---------------------------------------------

-- (escreva aqui)


-- ---------------------------------------------
-- TODO 2: Idade de cada pedido em dias
-- Mostre id, data_pedido e quantos dias se passaram desde o pedido.
-- Dica: (current_date - data_pedido::date)::int retorna dias inteiros.
-- ---------------------------------------------

-- (escreva aqui)


-- ---------------------------------------------
-- TODO 3: Valor total de cada pedido formatado como "R$ 1.234,56"
-- Some quantidade * preco_unitario por pedido (JOIN com itens_pedido).
-- Use to_char(valor, 'FM999G999G999D00') e concatene com 'R$ '.
-- ---------------------------------------------

-- (escreva aqui)


-- ---------------------------------------------
-- TODO 4: Mês e ano de cada pedido em colunas separadas
-- Use date_trunc('month', data_pedido) e extract(year FROM data_pedido).
-- ---------------------------------------------

-- (escreva aqui)


-- ---------------------------------------------
-- TODO 5: Lista de clientes com cidade ou "(sem cidade)" via COALESCE
-- ---------------------------------------------

-- (escreva aqui)


-- ---------------------------------------------
-- TODO 6: Buscar produtos cujo nome contenha "fone" (case-insensitive)
-- ---------------------------------------------

-- (escreva aqui)


-- ---------------------------------------------
-- TODO 7 (bônus): Relatório completo de pedidos
-- Junte tudo: id, cliente (nome), cidade (com COALESCE),
-- status traduzido, dias desde o pedido e valor formatado em R$.
-- Ordene por data_pedido DESC.
-- ---------------------------------------------

-- (escreva aqui)


-- =============================================
-- ✅ SOLUÇÃO
-- =============================================

-- Solução 1: status traduzido
SELECT
    id,
    data_pedido,
    CASE status
        WHEN 'pendente'  THEN 'Aguardando pagamento'
        WHEN 'pago'      THEN 'Pago — aguardando envio'
        WHEN 'enviado'   THEN 'A caminho'
        WHEN 'entregue'  THEN 'Entregue ao cliente'
        WHEN 'cancelado' THEN 'Cancelado'
    END AS status_traduzido
FROM pedidos
ORDER BY data_pedido DESC;

-- Solução 2: idade do pedido em dias
SELECT
    id,
    data_pedido,
    (current_date - data_pedido::date)::int AS dias_desde_pedido
FROM pedidos
ORDER BY dias_desde_pedido DESC;

-- Solução 3: valor total formatado em R$
SELECT
    p.id,
    'R$ ' || to_char(
        sum(ip.quantidade * ip.preco_unitario),
        'FM999G999G999D00'
    ) AS valor_total
FROM pedidos p
JOIN itens_pedido ip ON ip.pedido_id = p.id
GROUP BY p.id
ORDER BY p.id;

-- Solução 4: mês e ano em colunas separadas
SELECT
    id,
    data_pedido,
    date_trunc('month', data_pedido)::date AS mes,
    extract(year FROM data_pedido)::int    AS ano
FROM pedidos
ORDER BY data_pedido;

-- Solução 5: cidade com COALESCE
SELECT
    id,
    nome,
    COALESCE(cidade, '(sem cidade)') AS cidade
FROM clientes
ORDER BY nome;

-- Solução 6: produtos com "fone" no nome
SELECT id, nome, preco
FROM produtos
WHERE nome ILIKE '%fone%';

-- Solução 7 (bônus): relatório completo
SELECT
    p.id                                                AS pedido_id,
    c.nome                                              AS cliente,
    COALESCE(c.cidade, '(sem cidade)')                  AS cidade,
    CASE p.status
        WHEN 'pendente'  THEN 'Aguardando pagamento'
        WHEN 'pago'      THEN 'Pago — aguardando envio'
        WHEN 'enviado'   THEN 'A caminho'
        WHEN 'entregue'  THEN 'Entregue ao cliente'
        WHEN 'cancelado' THEN 'Cancelado'
    END                                                 AS status,
    (current_date - p.data_pedido::date)::int           AS dias,
    'R$ ' || to_char(
        COALESCE(sum(ip.quantidade * ip.preco_unitario), 0),
        'FM999G999G999D00'
    )                                                   AS valor_total
FROM pedidos p
JOIN clientes c             ON c.id = p.cliente_id
LEFT JOIN itens_pedido ip   ON ip.pedido_id = p.id
GROUP BY p.id, c.nome, c.cidade, p.status, p.data_pedido
ORDER BY p.data_pedido DESC;
