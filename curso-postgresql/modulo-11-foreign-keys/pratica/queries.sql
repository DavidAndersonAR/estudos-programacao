-- =============================================
-- Módulo 11 — Foreign Keys e Relacionamentos
-- Prática: criar FKs, ver integridade na pele
-- Pré-requisito: schema da loja já carregado
-- =============================================

-- Exercício 1: criar tabela nova com FK simples
-- Avaliações de produtos. Cada avaliação pertence a um cliente e a um produto.
DROP TABLE IF EXISTS avaliacoes CASCADE;
CREATE TABLE avaliacoes (
    id          SERIAL PRIMARY KEY,
    produto_id  INTEGER NOT NULL REFERENCES produtos(id),
    cliente_id  INTEGER NOT NULL REFERENCES clientes(id),
    nota        INTEGER NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario  TEXT,
    criado_em   TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Confere a estrutura: deve aparecer "Foreign-key constraints"
-- \d avaliacoes


-- Exercício 2: ALTER TABLE ADD CONSTRAINT (FK em tabela existente)
-- Imagine que a coluna existia sem FK. Vamos criar e depois prender.
DROP TABLE IF EXISTS pedidos_legados CASCADE;
CREATE TABLE pedidos_legados (
    id          SERIAL PRIMARY KEY,
    cliente_id  INTEGER NOT NULL,
    valor       NUMERIC(10,2)
);

-- Agora "trancamos" com a FK nomeada
ALTER TABLE pedidos_legados
ADD CONSTRAINT fk_pedidoslegados_cliente
FOREIGN KEY (cliente_id) REFERENCES clientes(id);

-- Pra remover (não rode agora, é só pra você ver a sintaxe):
-- ALTER TABLE pedidos_legados DROP CONSTRAINT fk_pedidoslegados_cliente;


-- Exercício 3: ON DELETE CASCADE — pai some, filho vai junto
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS comentarios CASCADE;

CREATE TABLE posts (
    id     SERIAL PRIMARY KEY,
    titulo VARCHAR(200)
);

CREATE TABLE comentarios (
    id      SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
    texto   TEXT
);

INSERT INTO posts (titulo) VALUES ('Post 1'), ('Post 2');
INSERT INTO comentarios (post_id, texto) VALUES
    (1, 'Ótimo post!'),
    (1, 'Concordo'),
    (2, 'Boa');

-- Antes: 3 comentários
SELECT count(*) AS antes FROM comentarios;

-- Deleta o post 1 — os 2 comentários dele vão junto, sem precisar fazer nada
DELETE FROM posts WHERE id = 1;

-- Depois: 1 comentário (só o do post 2)
SELECT count(*) AS depois FROM comentarios;


-- Exercício 4: ON DELETE SET NULL — pai some, filho fica órfão
DROP TABLE IF EXISTS funcionarios CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;

CREATE TABLE departamentos (
    id   SERIAL PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE funcionarios (
    id             SERIAL PRIMARY KEY,
    nome           VARCHAR(100),
    departamento_id INTEGER REFERENCES departamentos(id) ON DELETE SET NULL
);

INSERT INTO departamentos (nome) VALUES ('TI'), ('RH');
INSERT INTO funcionarios (nome, departamento_id) VALUES
    ('Ana', 1), ('Bruno', 1), ('Carla', 2);

-- Deleta o departamento TI — os funcionários ficam com departamento_id NULL
DELETE FROM departamentos WHERE id = 1;
SELECT nome, departamento_id FROM funcionarios ORDER BY id;
-- Ana e Bruno: NULL. Carla: 2.


-- Exercício 5: tentar inserir FK inválida (vai dar erro)
-- Tira o comentário e rode pra ver o erro 23503 (foreign_key_violation)
-- INSERT INTO avaliacoes (produto_id, cliente_id, nota)
-- VALUES (99999, 1, 5);
--
-- ERROR: insert or update on table "avaliacoes" violates foreign key constraint
-- DETAIL: Key (produto_id)=(99999) is not present in table "produtos".

-- Pra rodar de forma controlada e ver a mensagem sem abortar tudo:
DO $$
BEGIN
    INSERT INTO avaliacoes (produto_id, cliente_id, nota) VALUES (99999, 1, 5);
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Erro esperado capturado: produto_id=99999 não existe.';
END $$;


-- Exercício 6: FK composta
-- Turmas têm PK composta (curso_id, semestre). Matrículas referenciam as duas.
DROP TABLE IF EXISTS matriculas CASCADE;
DROP TABLE IF EXISTS turmas CASCADE;

CREATE TABLE turmas (
    curso_id   INTEGER NOT NULL,
    semestre   INTEGER NOT NULL,
    professor  VARCHAR(100),
    PRIMARY KEY (curso_id, semestre)
);

CREATE TABLE matriculas (
    id         SERIAL PRIMARY KEY,
    aluno_id   INTEGER NOT NULL,
    curso_id   INTEGER NOT NULL,
    semestre   INTEGER NOT NULL,
    CONSTRAINT fk_matricula_turma
        FOREIGN KEY (curso_id, semestre) REFERENCES turmas(curso_id, semestre)
);

INSERT INTO turmas (curso_id, semestre, professor) VALUES
    (101, 1, 'Prof. X'),
    (101, 2, 'Prof. Y');

INSERT INTO matriculas (aluno_id, curso_id, semestre) VALUES (1, 101, 1);
-- Esta abaixo daria erro (curso 101 semestre 99 não existe):
-- INSERT INTO matriculas (aluno_id, curso_id, semestre) VALUES (1, 101, 99);


-- Exercício 7: FK auto-referente — hierarquia de categorias
DROP TABLE IF EXISTS categorias_hier CASCADE;
CREATE TABLE categorias_hier (
    id        SERIAL PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categorias_hier(id) ON DELETE SET NULL
);

INSERT INTO categorias_hier (nome, parent_id) VALUES
    ('Eletrônicos', NULL),     -- id 1, raiz
    ('Celulares', 1),          -- id 2, filha de Eletrônicos
    ('Notebooks', 1),          -- id 3, filha de Eletrônicos
    ('Smartphones', 2),        -- id 4, neta (filha de Celulares)
    ('Acessórios', 2);         -- id 5, neta

-- Mostra a hierarquia simples (pai + filho)
SELECT
    filho.nome   AS categoria,
    pai.nome     AS pai
FROM categorias_hier filho
LEFT JOIN categorias_hier pai ON pai.id = filho.parent_id
ORDER BY filho.id;


-- Exercício 8: N:N com tabela de junção (produtos <-> tags)
DROP TABLE IF EXISTS produto_tags CASCADE;
DROP TABLE IF EXISTS tags CASCADE;

CREATE TABLE tags (
    id   SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE produto_tags (
    produto_id INTEGER NOT NULL REFERENCES produtos(id) ON DELETE CASCADE,
    tag_id     INTEGER NOT NULL REFERENCES tags(id)     ON DELETE CASCADE,
    PRIMARY KEY (produto_id, tag_id)
);

INSERT INTO tags (nome) VALUES ('promocao'), ('lancamento'), ('frete-gratis');

-- Coloca tags em alguns produtos (assumindo que existem ids 1, 2 em produtos)
INSERT INTO produto_tags (produto_id, tag_id) VALUES
    (1, 1),  -- produto 1 está em promoção
    (1, 3),  -- e tem frete grátis
    (2, 2);  -- produto 2 é lançamento

-- Lista produtos com suas tags
SELECT
    p.nome     AS produto,
    t.nome     AS tag
FROM produto_tags pt
JOIN produtos p ON p.id = pt.produto_id
JOIN tags t     ON t.id = pt.tag_id
ORDER BY p.nome, t.nome;
