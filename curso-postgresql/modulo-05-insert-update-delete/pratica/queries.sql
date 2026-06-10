-- =============================================
-- Módulo 05 — INSERT, UPDATE, DELETE (DML)
-- Prática: manipulando dados na loja
-- Pré-requisito: schema.sql + seed.sql carregados
-- =============================================

-- Exercício 1: inserir 1 produto (colunas explícitas, SEMPRE)
INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Caderno Universitário 200 fls', 24.90, 30, 1);

-- Exercício 2: inserir vários produtos numa só query (mais rápido!)
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES
    ('Caneta Esferográfica Azul', 2.50, 200, 1),
    ('Lápis HB',                  1.20, 500, 1),
    ('Borracha Branca',           0.80, 300, 1);

-- Exercício 3: INSERT com RETURNING — pega o id gerado de volta
INSERT INTO categorias (nome, descricao)
VALUES ('Papelaria', 'Material escolar e escritório')
RETURNING id, nome;

-- Exercício 4: UPDATE de preço com WHERE (NUNCA sem WHERE!)
-- Antes de rodar, confira com SELECT:
SELECT id, nome, preco FROM produtos WHERE nome = 'Lápis HB';

UPDATE produtos
SET preco = 1.50
WHERE nome = 'Lápis HB'
RETURNING id, nome, preco;

-- Exercício 5: UPDATE em massa com expressão (10% de aumento)
UPDATE produtos
SET preco = preco * 1.10
WHERE categoria_id = 1
RETURNING id, nome, preco;

-- Exercício 6: DELETE com WHERE (sempre confira antes!)
SELECT id, nome FROM produtos WHERE nome = 'Borracha Branca';

DELETE FROM produtos
WHERE nome = 'Borracha Branca'
RETURNING id, nome;

-- Exercício 7: UPSERT com ON CONFLICT no email único de clientes
INSERT INTO clientes (nome, email, cidade, estado)
VALUES ('João Pereira', 'joao@email.com', 'Rio de Janeiro', 'RJ')
ON CONFLICT (email)
DO UPDATE SET
    nome   = EXCLUDED.nome,
    cidade = EXCLUDED.cidade,
    estado = EXCLUDED.estado
RETURNING id, nome, email;

-- Exercício 8: INSERT...SELECT — duplicar produtos da categoria 1
-- (com sufixo "(cópia)" no nome só pra diferenciar)
INSERT INTO produtos (nome, preco, estoque, categoria_id)
SELECT nome || ' (cópia)', preco, estoque, categoria_id
FROM produtos
WHERE categoria_id = 1;

-- Exercício 9: TRUNCATE numa tabela temporária criada na hora
-- Tabelas temporárias só existem na sessão atual — bom pra testar TRUNCATE sem risco
CREATE TEMP TABLE rascunho_produtos (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(100)
);

INSERT INTO rascunho_produtos (nome) VALUES
    ('teste 1'), ('teste 2'), ('teste 3');

SELECT count(*) AS antes FROM rascunho_produtos;

TRUNCATE TABLE rascunho_produtos RESTART IDENTITY;

SELECT count(*) AS depois FROM rascunho_produtos;

-- Exercício 10: limpando o que a gente bagunçou (opcional)
-- Pra deixar o banco do jeito que estava antes desta prática:
DELETE FROM produtos WHERE nome LIKE '%(cópia)';
DELETE FROM produtos WHERE nome IN
    ('Caderno Universitário 200 fls', 'Caneta Esferográfica Azul', 'Lápis HB');
DELETE FROM categorias WHERE nome = 'Papelaria';
