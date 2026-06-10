-- =============================================
-- Módulo 11 — Desafio: Refatorar schema com integridade
-- =============================================
-- Cenário: o schema da loja foi montado meio "no susto". Algumas colunas
-- que deveriam ser FKs ficaram soltas. Outras precisam de política de
-- ON DELETE adequada. E precisamos de novas features: categorias
-- hierárquicas, tags em produtos (N:N) e carrinho de compras.
--
-- Pré-requisito: schema da loja carregado.
-- Sua missão: 6 tarefas. Tente sozinho antes de olhar a solução abaixo.
-- =============================================


-- ---------------------------------------------
-- TAREFA 1: Adicionar FK faltante
-- A tabela `produtos` tem `categoria_id INTEGER REFERENCES categorias(id)`
-- — mas sem nome, sem política de ON DELETE, e sem proteção contra "deletar
-- categoria que tem produto". Faça:
--   (a) Dropar a FK auto-gerada.
--   (b) Recriar com nome `fk_produto_categoria` e `ON DELETE SET NULL`
--       (porque produto pode ficar "sem categoria", não queremos perder produto).
--   (c) Idem para `itens_pedido.produto_id`: defina como `ON DELETE RESTRICT`
--       (proibido apagar produto que já apareceu em pedido — preserva histórico).
-- ---------------------------------------------
-- TODO: seu código aqui


-- ---------------------------------------------
-- TAREFA 2: Categorias hierárquicas
-- A tabela `categorias` atual é "flat". Precisamos suportar subcategorias
-- (ex: Eletrônicos > Celulares > Smartphones).
-- Faça:
--   (a) Adicione coluna `parent_id INTEGER` em `categorias`.
--   (b) Crie a FK auto-referente `fk_categoria_parent` com `ON DELETE SET NULL`
--       (se apagar o pai, filhos viram raiz).
--   (c) Insira: "Eletrônicos" (raiz), "Celulares" (filha), "Notebooks" (filha).
-- ---------------------------------------------
-- TODO: seu código aqui


-- ---------------------------------------------
-- TAREFA 3: Tabela `tags` + N:N `produto_tags`
-- Cada produto pode ter várias tags ("promocao", "lancamento", etc) e cada
-- tag está em vários produtos. Modele a N:N com tabela de junção.
-- Requisitos:
--   - `tags(id, nome UNIQUE NOT NULL)`.
--   - `produto_tags(produto_id, tag_id)` com PK composta.
--   - Política: ON DELETE CASCADE nos dois lados (apagou produto/tag,
--     limpa o vínculo).
-- ---------------------------------------------
-- TODO: seu código aqui


-- ---------------------------------------------
-- TAREFA 4: Política CASCADE adequada em cada lugar
-- Revise as FKs do schema e aplique (via ALTER) a política coerente:
--   - `pedidos.cliente_id`         → ON DELETE RESTRICT (não some cliente com pedido!)
--   - `itens_pedido.pedido_id`     → ON DELETE CASCADE  (apagou pedido, vão os itens)
--   - `itens_pedido.produto_id`    → já feito na Tarefa 1 (RESTRICT)
-- ---------------------------------------------
-- TODO: seu código aqui


-- ---------------------------------------------
-- TAREFA 5: Tabela `carrinhos` com FK
-- Cada cliente tem **no máximo um** carrinho aberto (1:1). O carrinho
-- contém vários itens (1:N).
-- Requisitos:
--   - `carrinhos(id, cliente_id UNIQUE, criado_em)`. FK pra clientes
--     com ON DELETE CASCADE (cliente foi, carrinho vai).
--   - `itens_carrinho(carrinho_id, produto_id, quantidade)`. PK composta.
--     FKs com ON DELETE CASCADE no carrinho e RESTRICT no produto.
-- ---------------------------------------------
-- TODO: seu código aqui


-- ---------------------------------------------
-- TAREFA 6: Testar a integridade
-- Rode pra provar que as políticas funcionam:
--   (a) Tente apagar um cliente que tem pedido → deve dar erro (RESTRICT).
--   (b) Apague um pedido → seus itens_pedido devem sumir (CASCADE).
--   (c) Apague uma categoria que tem produto → produto fica com NULL.
-- ---------------------------------------------
-- TODO: seu código aqui


-- =============================================
-- SOLUÇÃO
-- (Não espie antes de tentar!)
-- =============================================

-- ===== TAREFA 1: Adicionar FK faltante / ajustar políticas =====
-- (a) Dropar a FK auto-gerada de produtos.categoria_id
ALTER TABLE produtos DROP CONSTRAINT IF EXISTS produtos_categoria_id_fkey;

-- (b) Recriar com nome e política
ALTER TABLE produtos
ADD CONSTRAINT fk_produto_categoria
FOREIGN KEY (categoria_id) REFERENCES categorias(id)
ON DELETE SET NULL;

-- (c) itens_pedido.produto_id → RESTRICT
ALTER TABLE itens_pedido DROP CONSTRAINT IF EXISTS itens_pedido_produto_id_fkey;
ALTER TABLE itens_pedido
ADD CONSTRAINT fk_item_produto
FOREIGN KEY (produto_id) REFERENCES produtos(id)
ON DELETE RESTRICT;


-- ===== TAREFA 2: Categorias hierárquicas =====
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS parent_id INTEGER;

ALTER TABLE categorias
ADD CONSTRAINT fk_categoria_parent
FOREIGN KEY (parent_id) REFERENCES categorias(id)
ON DELETE SET NULL;

-- Inserir hierarquia de exemplo (idempotente com ON CONFLICT DO NOTHING)
INSERT INTO categorias (nome, parent_id) VALUES ('Eletrônicos', NULL)
    ON CONFLICT (nome) DO NOTHING;

INSERT INTO categorias (nome, parent_id)
SELECT 'Celulares', id FROM categorias WHERE nome = 'Eletrônicos'
    ON CONFLICT (nome) DO NOTHING;

INSERT INTO categorias (nome, parent_id)
SELECT 'Notebooks', id FROM categorias WHERE nome = 'Eletrônicos'
    ON CONFLICT (nome) DO NOTHING;


-- ===== TAREFA 3: tags + produto_tags (N:N) =====
DROP TABLE IF EXISTS produto_tags CASCADE;
DROP TABLE IF EXISTS tags CASCADE;

CREATE TABLE tags (
    id   SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE produto_tags (
    produto_id INTEGER NOT NULL,
    tag_id     INTEGER NOT NULL,
    PRIMARY KEY (produto_id, tag_id),
    CONSTRAINT fk_pt_produto FOREIGN KEY (produto_id)
        REFERENCES produtos(id) ON DELETE CASCADE,
    CONSTRAINT fk_pt_tag     FOREIGN KEY (tag_id)
        REFERENCES tags(id)     ON DELETE CASCADE
);

-- Bônus: índices nas FKs (Postgres NÃO cria sozinho)
CREATE INDEX IF NOT EXISTS idx_pt_tag_id     ON produto_tags(tag_id);
-- produto_id já indexado por ser primeira coluna da PK


-- ===== TAREFA 4: políticas CASCADE coerentes =====
ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS pedidos_cliente_id_fkey;
ALTER TABLE pedidos
ADD CONSTRAINT fk_pedido_cliente
FOREIGN KEY (cliente_id) REFERENCES clientes(id)
ON DELETE RESTRICT;

ALTER TABLE itens_pedido DROP CONSTRAINT IF EXISTS itens_pedido_pedido_id_fkey;
ALTER TABLE itens_pedido
ADD CONSTRAINT fk_item_pedido
FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
ON DELETE CASCADE;


-- ===== TAREFA 5: carrinhos + itens_carrinho =====
DROP TABLE IF EXISTS itens_carrinho CASCADE;
DROP TABLE IF EXISTS carrinhos CASCADE;

CREATE TABLE carrinhos (
    id          SERIAL PRIMARY KEY,
    cliente_id  INTEGER NOT NULL UNIQUE,  -- UNIQUE garante 1:1
    criado_em   TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_carrinho_cliente FOREIGN KEY (cliente_id)
        REFERENCES clientes(id) ON DELETE CASCADE
);

CREATE TABLE itens_carrinho (
    carrinho_id INTEGER NOT NULL,
    produto_id  INTEGER NOT NULL,
    quantidade  INTEGER NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (carrinho_id, produto_id),
    CONSTRAINT fk_ic_carrinho FOREIGN KEY (carrinho_id)
        REFERENCES carrinhos(id) ON DELETE CASCADE,
    CONSTRAINT fk_ic_produto  FOREIGN KEY (produto_id)
        REFERENCES produtos(id)  ON DELETE RESTRICT
);


-- ===== TAREFA 6: testar a integridade =====
-- (a) Tentar deletar cliente com pedido — deve dar erro 23503
DO $$
BEGIN
    DELETE FROM clientes
    WHERE id IN (SELECT cliente_id FROM pedidos LIMIT 1);
    RAISE NOTICE 'Inesperado: deletou cliente com pedido.';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE '(a) OK: RESTRICT bloqueou apagar cliente com pedido.';
END $$;

-- (b) Apagar um pedido — itens devem sumir (CASCADE)
-- (rode dentro de transação pra não bagunçar dados)
BEGIN;
    SELECT count(*) AS itens_antes FROM itens_pedido
    WHERE pedido_id = (SELECT id FROM pedidos LIMIT 1);

    DELETE FROM pedidos WHERE id = (SELECT id FROM pedidos LIMIT 1);

    SELECT count(*) AS itens_desse_pedido_depois FROM itens_pedido
    WHERE pedido_id NOT IN (SELECT id FROM pedidos);  -- deve ser 0
ROLLBACK;  -- desfaz pra não estragar o seed

-- (c) Apagar categoria com produto — produto fica com categoria_id NULL
BEGIN;
    SELECT id, nome, categoria_id FROM produtos
    WHERE categoria_id = (SELECT id FROM categorias LIMIT 1);

    DELETE FROM categorias WHERE id = (SELECT id FROM categorias LIMIT 1);

    SELECT id, nome, categoria_id FROM produtos
    WHERE categoria_id IS NULL;  -- aqueles que perderam o pai
ROLLBACK;
