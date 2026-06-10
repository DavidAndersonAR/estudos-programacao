-- =============================================
-- Módulo 14 — Desafio: Dashboard de Vendas com MV
-- =============================================
-- Você vai montar a "camada de dashboard" da loja: 3 materialized views
-- (cache de agregações pesadas) + 1 view comum (join detalhado pra relatório).
--
-- Estrutura esperada:
--   mv_vendas_mes       -> total de vendas por mês
--   mv_top_produtos     -> top 10 produtos mais vendidos (por quantidade)
--   mv_clientes_ativos  -> clientes com pedido nos últimos 30 dias
--   pedidos_detalhados  -> view com join completo (pedido + cliente + item + produto)
--
-- Cada MV precisa de UNIQUE index pra suportar REFRESH CONCURRENTLY.
-- No fim, mostre como atualizar todas de uma vez.
--
-- TODO 1: mv_vendas_mes (mes, qtd_pedidos, total_vendido)
--         só considerar status IN ('pago','enviado','entregue')
-- TODO 2: índice UNIQUE em mv_vendas_mes(mes)
-- TODO 3: mv_top_produtos (produto_id, nome, total_qtd_vendida, total_faturado)
--         ranking top 10 por quantidade vendida
-- TODO 4: índice UNIQUE em mv_top_produtos(produto_id)
-- TODO 5: mv_clientes_ativos (cliente_id, nome, email, ultimo_pedido, qtd_pedidos_30d)
--         clientes com pelo menos 1 pedido nos últimos 30 dias
-- TODO 6: índice UNIQUE em mv_clientes_ativos(cliente_id)
-- TODO 7: view pedidos_detalhados — join pedidos + clientes + itens_pedido + produtos + categorias
-- TODO 8: mostrar como dar REFRESH CONCURRENTLY em todas as MVs (rotina diária)
-- TODO 9: bonus — consultar cada uma pra ver se o dashboard responde
--
-- =============================================
-- SOLUÇÃO
-- =============================================

-- Limpa execução anterior (ordem importa por causa de dependência)
DROP MATERIALIZED VIEW IF EXISTS mv_vendas_mes;
DROP MATERIALIZED VIEW IF EXISTS mv_top_produtos;
DROP MATERIALIZED VIEW IF EXISTS mv_clientes_ativos;
DROP VIEW IF EXISTS pedidos_detalhados;

-- ---------------------------------------------
-- TODO 1: mv_vendas_mes
-- ---------------------------------------------
CREATE MATERIALIZED VIEW mv_vendas_mes AS
SELECT
    date_trunc('month', p.data_pedido)::date     AS mes,
    COUNT(DISTINCT p.id)                          AS qtd_pedidos,
    SUM(i.quantidade * i.preco_unitario)          AS total_vendido
FROM pedidos p
JOIN itens_pedido i ON i.pedido_id = p.id
WHERE p.status IN ('pago', 'enviado', 'entregue')
GROUP BY 1
ORDER BY 1;

-- TODO 2: índice UNIQUE pra CONCURRENTLY
CREATE UNIQUE INDEX idx_mv_vendas_mes_mes ON mv_vendas_mes(mes);

-- ---------------------------------------------
-- TODO 3: mv_top_produtos
-- ---------------------------------------------
CREATE MATERIALIZED VIEW mv_top_produtos AS
SELECT
    pr.id                                         AS produto_id,
    pr.nome,
    SUM(i.quantidade)                             AS total_qtd_vendida,
    SUM(i.quantidade * i.preco_unitario)          AS total_faturado
FROM itens_pedido i
JOIN produtos pr ON pr.id = i.produto_id
JOIN pedidos p   ON p.id = i.pedido_id
WHERE p.status IN ('pago', 'enviado', 'entregue')
GROUP BY pr.id, pr.nome
ORDER BY total_qtd_vendida DESC
LIMIT 10;

-- TODO 4: índice UNIQUE
CREATE UNIQUE INDEX idx_mv_top_produtos_id ON mv_top_produtos(produto_id);
-- Índice extra pra ordenação rápida no dashboard:
CREATE INDEX idx_mv_top_produtos_qtd ON mv_top_produtos(total_qtd_vendida DESC);

-- ---------------------------------------------
-- TODO 5: mv_clientes_ativos
-- ---------------------------------------------
CREATE MATERIALIZED VIEW mv_clientes_ativos AS
SELECT
    c.id                          AS cliente_id,
    c.nome,
    c.email,
    MAX(p.data_pedido)            AS ultimo_pedido,
    COUNT(p.id)                   AS qtd_pedidos_30d
FROM clientes c
JOIN pedidos p ON p.cliente_id = c.id
WHERE p.data_pedido >= NOW() - INTERVAL '30 days'
GROUP BY c.id, c.nome, c.email;

-- TODO 6: índice UNIQUE
CREATE UNIQUE INDEX idx_mv_clientes_ativos_id ON mv_clientes_ativos(cliente_id);

-- ---------------------------------------------
-- TODO 7: view pedidos_detalhados (join completo, sempre fresca)
-- ---------------------------------------------
CREATE OR REPLACE VIEW pedidos_detalhados AS
SELECT
    p.id                              AS pedido_id,
    p.data_pedido,
    p.status,
    c.id                              AS cliente_id,
    c.nome                            AS cliente_nome,
    c.email                           AS cliente_email,
    c.cidade,
    pr.id                             AS produto_id,
    pr.nome                           AS produto_nome,
    cat.nome                          AS categoria,
    i.quantidade,
    i.preco_unitario,
    (i.quantidade * i.preco_unitario) AS subtotal
FROM pedidos p
JOIN clientes c       ON c.id = p.cliente_id
JOIN itens_pedido i   ON i.pedido_id = p.id
JOIN produtos pr      ON pr.id = i.produto_id
LEFT JOIN categorias cat ON cat.id = pr.categoria_id;

-- ---------------------------------------------
-- TODO 8: rotina de atualização (rodar via cron / pg_cron / job)
-- ---------------------------------------------
-- CONCURRENTLY = não bloqueia o dashboard durante o refresh.
-- Todas as 3 MVs têm índice UNIQUE, então pode rodar em paralelo:
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vendas_mes;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_produtos;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_clientes_ativos;
-- A view pedidos_detalhados não precisa de refresh — é "ao vivo".

-- ---------------------------------------------
-- TODO 9: consultas do dashboard
-- ---------------------------------------------
-- Faturamento por mês:
SELECT mes, qtd_pedidos, total_vendido
FROM mv_vendas_mes
ORDER BY mes DESC
LIMIT 12;

-- Top 10 produtos:
SELECT nome, total_qtd_vendida, total_faturado
FROM mv_top_produtos
ORDER BY total_qtd_vendida DESC;

-- Clientes ativos (últimos 30 dias):
SELECT nome, email, ultimo_pedido, qtd_pedidos_30d
FROM mv_clientes_ativos
ORDER BY qtd_pedidos_30d DESC, ultimo_pedido DESC
LIMIT 20;

-- Relatório detalhado de 1 pedido (usando a view ao vivo):
SELECT pedido_id, cliente_nome, produto_nome, quantidade, subtotal
FROM pedidos_detalhados
WHERE pedido_id = 1;
