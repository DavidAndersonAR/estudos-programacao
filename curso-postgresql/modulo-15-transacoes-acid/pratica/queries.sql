-- =============================================
-- Módulo 15 — Transações e ACID
-- Prática: BEGIN/COMMIT/ROLLBACK, SAVEPOINT, isolamento, locks
-- Pré-requisito: schema/seed do Módulo 01 carregados
-- =============================================

-- =============================================
-- Exercício 1: ROLLBACK explícito — desfazer alterações
-- A transação inteira é descartada. Útil pra "testar" o efeito de
-- um UPDATE sem comprometer os dados.
-- =============================================
BEGIN;
UPDATE produtos SET preco = preco * 10 WHERE id = 1;
SELECT id, nome, preco FROM produtos WHERE id = 1;   -- mostra o preço inflado
ROLLBACK;                                            -- desfaz!
SELECT id, nome, preco FROM produtos WHERE id = 1;   -- preço original de volta


-- =============================================
-- Exercício 2: COMMIT — agrupando várias operações como "tudo ou nada"
-- Cenário: criar pedido + inserir itens + dar baixa no estoque.
-- Se qualquer um falhar, ninguém fica meio feito.
-- =============================================
BEGIN;
INSERT INTO pedidos (cliente_id, status)
VALUES (1, 'pendente')
RETURNING id;                            -- guarda o id, ex.: 100

-- (substitua 100 pelo id retornado acima)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
VALUES (100, 1, 2, (SELECT preco FROM produtos WHERE id = 1));

UPDATE produtos SET estoque = estoque - 2 WHERE id = 1;

COMMIT;                                  -- materializa tudo de uma vez


-- =============================================
-- Exercício 3: SAVEPOINT — rollback parcial
-- Permite desfazer só um pedaço sem perder o resto da transação.
-- =============================================
BEGIN;

INSERT INTO clientes (nome, email, cidade, estado)
VALUES ('Teste Savepoint', 'savepoint@ex.com', 'Curitiba', 'PR');

SAVEPOINT antes_do_pedido;

INSERT INTO pedidos (cliente_id, status)
VALUES (currval('clientes_id_seq'), 'pendente');

-- "Ops, mudei de ideia sobre o pedido, mas o cliente eu quero manter"
ROLLBACK TO SAVEPOINT antes_do_pedido;

-- O cliente foi preservado; só o pedido foi desfeito.
SELECT id, nome FROM clientes WHERE email = 'savepoint@ex.com';

COMMIT;


-- =============================================
-- Exercício 4: SET TRANSACTION ISOLATION LEVEL
-- Sobe o isolamento pra REPEATABLE READ. Dois SELECTs do mesmo dado
-- enxergam o mesmo valor mesmo se outra sessão comitar no meio.
-- =============================================
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT id, preco FROM produtos WHERE id = 1;   -- snapshot tirado aqui

-- (Em outra sessão, alguém poderia fazer: UPDATE produtos SET preco = 999 WHERE id = 1; COMMIT;)
-- A nossa transação NÃO vai enxergar isso:

SELECT pg_sleep(2);                            -- dá tempo de mexer noutra sessão
SELECT id, preco FROM produtos WHERE id = 1;   -- mesmo valor de antes!

COMMIT;


-- =============================================
-- Exercício 5: SELECT ... FOR UPDATE — trava a linha pra alterar depois
-- Padrão pra "leio, decido, escrevo" sem race condition.
-- Outras transações que tentarem FOR UPDATE / UPDATE nessa linha esperam.
-- =============================================
BEGIN;

SELECT id, estoque
FROM produtos
WHERE id = 1
FOR UPDATE;                              -- trava aqui

-- (qualquer outra sessão fazendo FOR UPDATE/UPDATE nesta linha vai aguardar)

UPDATE produtos SET estoque = estoque - 1 WHERE id = 1;

COMMIT;                                  -- libera o lock


-- =============================================
-- Exercício 6: SERIALIZABLE — detectando conflito de serialização
-- ⚠️ Este exercício PRECISA DE 2 SESSÕES psql abertas lado a lado.
-- Demonstra "write skew": as duas decidem baseado no mesmo snapshot e
-- ambas atualizam — uma vai falhar com 40001 (could not serialize access).
--
-- Cenário: regra de negócio "pelo menos um produto com estoque > 0
-- precisa existir na categoria 1". Duas sessões zeram produtos diferentes.
-- Sob SERIALIZABLE, o Postgres detecta e aborta uma.
-- =============================================

-- SESSÃO A:
-- BEGIN;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- SELECT count(*) FROM produtos WHERE categoria_id = 1 AND estoque > 0;
-- UPDATE produtos SET estoque = 0 WHERE id = 1;
-- -- (NÃO comita ainda)

-- SESSÃO B (em paralelo):
-- BEGIN;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- SELECT count(*) FROM produtos WHERE categoria_id = 1 AND estoque > 0;
-- UPDATE produtos SET estoque = 0 WHERE id = 2;
-- COMMIT;

-- SESSÃO A:
-- COMMIT;
-- ↑ aqui o Postgres deve dar:
--   ERROR: could not serialize access due to read/write dependencies among transactions
--   (sua aplicação deve fazer RETRY).


-- =============================================
-- Exercício 7: Inspecionar locks atuais via pg_locks
-- Para usar: abra OUTRA sessão e dispare a transação do exercício 5
-- (sem comitar). Depois rode este SELECT na sessão atual.
-- =============================================
SELECT
    l.pid,
    l.locktype,
    l.relation::regclass  AS tabela,
    l.mode,
    l.granted,
    a.state,
    a.wait_event_type,
    a.query
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON a.pid = l.pid
WHERE l.relation = 'produtos'::regclass
   OR l.locktype = 'transactionid'
ORDER BY l.granted DESC, l.pid;


-- =============================================
-- Exercício 8 (bônus): NOWAIT e SKIP LOCKED
-- Comportamentos alternativos quando a linha já está travada.
-- =============================================

-- Falha imediatamente se a linha estiver travada:
BEGIN;
SELECT id FROM produtos WHERE id = 1 FOR UPDATE NOWAIT;
ROLLBACK;

-- Ignora linhas travadas (ótimo pra fila de jobs / worker pool):
BEGIN;
SELECT id FROM produtos WHERE estoque > 0 FOR UPDATE SKIP LOCKED LIMIT 5;
ROLLBACK;


-- =============================================
-- Limpeza opcional do exercício 3
-- =============================================
-- DELETE FROM clientes WHERE email = 'savepoint@ex.com';
