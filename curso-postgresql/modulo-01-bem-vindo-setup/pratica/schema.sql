-- =============================================
-- Schema da loja e-commerce — Curso PostgreSQL
-- Roda em Postgres 14+
-- =============================================

-- Remove tudo se já existir (ordem importa por causa das FKs)
DROP TABLE IF EXISTS itens_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS produtos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TYPE IF EXISTS status_pedido CASCADE;

-- Enum para status de pedido
CREATE TYPE status_pedido AS ENUM ('pendente', 'pago', 'enviado', 'entregue', 'cancelado');

-- Categorias de produtos
CREATE TABLE categorias (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL UNIQUE,
    descricao   TEXT
);

-- Produtos
CREATE TABLE produtos (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(200) NOT NULL,
    preco           NUMERIC(10, 2) NOT NULL CHECK (preco >= 0),
    estoque         INTEGER NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    categoria_id    INTEGER REFERENCES categorias(id),
    criado_em       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Clientes
CREATE TABLE clientes (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(200) NOT NULL,
    email           VARCHAR(200) NOT NULL UNIQUE,
    cidade          VARCHAR(100),
    estado          CHAR(2),
    data_cadastro   DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Pedidos
CREATE TABLE pedidos (
    id          SERIAL PRIMARY KEY,
    cliente_id  INTEGER NOT NULL REFERENCES clientes(id),
    data_pedido TIMESTAMP NOT NULL DEFAULT NOW(),
    status      status_pedido NOT NULL DEFAULT 'pendente'
);

-- Itens do pedido (relação N:N entre pedidos e produtos)
CREATE TABLE itens_pedido (
    pedido_id       INTEGER NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id      INTEGER NOT NULL REFERENCES produtos(id),
    quantidade      INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario  NUMERIC(10, 2) NOT NULL CHECK (preco_unitario >= 0),
    PRIMARY KEY (pedido_id, produto_id)
);

-- Mensagem de sucesso
SELECT 'Schema criado com sucesso!' AS resultado;
