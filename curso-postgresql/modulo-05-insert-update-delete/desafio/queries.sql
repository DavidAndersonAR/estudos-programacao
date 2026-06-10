-- =============================================
-- 🎯 DESAFIO DO MÓDULO 05 — CRUD de Produtos
-- =============================================
--
-- Cenário:
-- Você é o(a) DBA da loja e precisa fazer um pacote de manutenção
-- no catálogo de produtos. Resolva cada tarefa com DML (INSERT/UPDATE/DELETE).
--
-- Tarefa 1: Crie 3 produtos novos numa única instrução INSERT em batch.
--           Coloque eles na categoria 1, com preços e estoques à sua escolha.
--
-- Tarefa 2: Refaça o INSERT da Tarefa 1, mas dessa vez use RETURNING
--           pra trazer o id, nome e preco de cada produto inserido.
--
-- Tarefa 3: Aumente o preço de TODOS os produtos da categoria 2 em 10%.
--           Use RETURNING pra confirmar quantas linhas foram afetadas.
--
-- Tarefa 4: Marque estoque = 0 em todos os produtos que NUNCA foram pedidos
--           (ou seja, não aparecem em itens_pedido).
--           Dica: subquery com NOT IN ou NOT EXISTS.
--
-- Tarefa 5: Faça um UPSERT pra inserir-ou-atualizar um cliente por email.
--           Use 'maria.cliente@email.com'. Se já existir, atualize cidade.
--           (lembre-se: precisa de UNIQUE constraint em email — a loja tem!)
--
-- Tarefa 6: Delete todos os produtos com estoque = 0.
--           ⚠️ ATENÇÃO: faça primeiro um SELECT pra ver o que vai pegar.
--           Pode ser que FKs em itens_pedido bloqueiem — nesse caso, comente
--           a tarefa e explique no comentário por que não rolou.
--
-- Tarefa 7 (bônus): Crie uma categoria nova "Promoção", e mova pra ela
--                   (com UPDATE) todos os produtos com preco < 10.
--                   Use RETURNING pra ver o que mudou.
--
-- 💡 Dicas gerais:
--   - Antes de qualquer UPDATE/DELETE, rode o SELECT com o mesmo WHERE
--   - RETURNING serve nos três comandos: INSERT, UPDATE, DELETE
--   - EXCLUDED.coluna = valor que VOCÊ tentou inserir no UPSERT
--   - Se quiser desfazer tudo no fim, envolve numa transação:
--       BEGIN; ... ROLLBACK;
--
-- ============================
-- SUA SOLUÇÃO ABAIXO
-- ============================

-- Tarefa 1:


-- Tarefa 2:


-- Tarefa 3:


-- Tarefa 4:


-- Tarefa 5:


-- Tarefa 6:


-- Tarefa 7 (bônus):


-- ============================
-- SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
-- ============================

/*
-- 1: Criar 3 produtos numa só instrução
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES
    ('Mouse Gamer RGB',     149.90,  25, 1),
    ('Teclado Mecânico',    349.00,  15, 1),
    ('Mousepad XL',          59.90,  60, 1);

-- 2: O mesmo INSERT com RETURNING
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES
    ('Headset Bluetooth',   199.90,  20, 1),
    ('Webcam HD',           179.00,  18, 1),
    ('Suporte Notebook',     89.90,  40, 1)
RETURNING id, nome, preco;

-- 3: Aumentar 10% nos produtos da categoria 2
UPDATE produtos
SET preco = preco * 1.10
WHERE categoria_id = 2
RETURNING id, nome, preco;

-- 4: Zerar estoque dos produtos que nunca foram pedidos
-- Versão com NOT EXISTS (geralmente mais eficiente)
UPDATE produtos p
SET estoque = 0
WHERE NOT EXISTS (
    SELECT 1 FROM itens_pedido ip WHERE ip.produto_id = p.id
)
RETURNING id, nome, estoque;

-- 5: UPSERT por email único
INSERT INTO clientes (nome, email, cidade, estado)
VALUES ('Maria Cliente', 'maria.cliente@email.com', 'Curitiba', 'PR')
ON CONFLICT (email)
DO UPDATE SET
    cidade = EXCLUDED.cidade,
    estado = EXCLUDED.estado
RETURNING id, nome, email, cidade;

-- 6: Deletar produtos sem estoque
-- Primeiro confere o que tem:
SELECT id, nome, estoque FROM produtos WHERE estoque = 0;

-- Depois deleta (pode falhar com FK constraint se algum produto sem
-- estoque já tiver sido pedido — itens_pedido não tem ON DELETE CASCADE):
DELETE FROM produtos
WHERE estoque = 0
RETURNING id, nome;
-- Caso dê erro de FK: precisa primeiro lidar com os itens_pedido,
-- ou usar outra estratégia (ex.: marcar produto como "inativo" em vez de deletar).

-- 7 (bônus): Categoria Promoção + mover produtos baratos
INSERT INTO categorias (nome, descricao)
VALUES ('Promoção', 'Produtos com preço promocional')
RETURNING id;
-- Suponha que o id retornado foi, digamos, 10:
UPDATE produtos
SET categoria_id = (SELECT id FROM categorias WHERE nome = 'Promoção')
WHERE preco < 10
RETURNING id, nome, preco, categoria_id;
*/
