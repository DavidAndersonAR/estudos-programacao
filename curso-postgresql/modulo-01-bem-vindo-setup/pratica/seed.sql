-- =============================================
-- Dados de exemplo para a loja e-commerce
-- =============================================

-- Categorias
INSERT INTO categorias (nome, descricao) VALUES
    ('Eletrônicos', 'Smartphones, computadores, acessórios'),
    ('Livros', 'Físicos e e-books'),
    ('Roupas', 'Masculino, feminino, infantil'),
    ('Casa e Cozinha', 'Utensílios e decoração'),
    ('Esportes', 'Equipamentos e roupas esportivas');

-- Produtos (10 por categoria, variando preços)
INSERT INTO produtos (nome, preco, estoque, categoria_id) VALUES
    -- Eletrônicos (id 1)
    ('Smartphone X12', 2499.90, 30, 1),
    ('Notebook Pro 15"', 5499.00, 12, 1),
    ('Fone Bluetooth Sport', 249.50, 100, 1),
    ('Smart TV 55"', 3299.00, 8, 1),
    ('Tablet Lite', 899.00, 25, 1),
    -- Livros (id 2)
    ('Domain-Driven Design', 159.00, 50, 2),
    ('Clean Code', 109.90, 80, 2),
    ('SQL Performance Explained', 189.00, 30, 2),
    ('PostgreSQL Internals', 249.00, 15, 2),
    ('Refactoring 2ª ed', 199.00, 40, 2),
    -- Roupas (id 3)
    ('Camiseta Algodão Básica', 49.90, 200, 3),
    ('Calça Jeans Slim', 159.00, 80, 3),
    ('Tênis Esportivo', 299.00, 60, 3),
    ('Jaqueta Corta-Vento', 219.00, 35, 3),
    ('Meia Esportiva (par)', 19.90, 500, 3),
    -- Casa e Cozinha (id 4)
    ('Jogo Panelas Inox 5 peças', 599.00, 20, 4),
    ('Liquidificador 1200W', 289.00, 40, 4),
    ('Conjunto Faqueiro 24 peças', 129.00, 60, 4),
    ('Cafeteira Italiana', 89.90, 70, 4),
    ('Forma de Bolo Antiaderente', 39.90, 150, 4),
    -- Esportes (id 5)
    ('Bola de Futebol Oficial', 159.00, 80, 5),
    ('Bicicleta Aro 29', 1899.00, 5, 5),
    ('Halter 5kg (par)', 119.00, 40, 5),
    ('Tapete de Yoga', 89.00, 100, 5),
    ('Corda de Pular', 29.90, 200, 5);

-- Clientes (20 espalhados pelo Brasil)
INSERT INTO clientes (nome, email, cidade, estado, data_cadastro) VALUES
    ('Ana Souza',       'ana.souza@email.com',       'São Paulo',       'SP', '2025-01-15'),
    ('Bruno Lima',      'bruno.lima@email.com',      'Rio de Janeiro',  'RJ', '2025-01-22'),
    ('Carla Mendes',    'carla.mendes@email.com',    'Belo Horizonte',  'MG', '2025-02-03'),
    ('Diego Alves',     'diego.alves@email.com',     'Porto Alegre',    'RS', '2025-02-10'),
    ('Elena Costa',     'elena.costa@email.com',     'Curitiba',        'PR', '2025-02-18'),
    ('Felipe Rocha',    'felipe.rocha@email.com',    'Salvador',        'BA', '2025-03-05'),
    ('Gabriela Pinto',  'gabi.pinto@email.com',      'Recife',          'PE', '2025-03-14'),
    ('Henrique Dias',   'henrique.dias@email.com',   'Fortaleza',       'CE', '2025-03-22'),
    ('Isabela Nunes',   'isa.nunes@email.com',       'Brasília',        'DF', '2025-04-01'),
    ('João Silva',      'joao.silva@email.com',      'São Paulo',       'SP', '2025-04-10'),
    ('Karen Oliveira',  'karen.oliveira@email.com',  'Manaus',          'AM', '2025-04-18'),
    ('Lucas Ferreira',  'lucas.ferreira@email.com',  'Belém',           'PA', '2025-04-25'),
    ('Mariana Castro',  'mariana.castro@email.com',  'Florianópolis',   'SC', '2025-05-03'),
    ('Nathan Ramos',    'nathan.ramos@email.com',    'Goiânia',         'GO', '2025-05-12'),
    ('Olivia Barbosa',  'olivia.barbosa@email.com',  'Vitória',         'ES', '2025-05-20'),
    ('Pedro Santos',    'pedro.santos@email.com',    'São Paulo',       'SP', '2025-06-01'),
    ('Quitéria Lopes',  'quiteria.lopes@email.com',  'Natal',           'RN', '2025-06-10'),
    ('Renato Borges',   'renato.borges@email.com',   'João Pessoa',     'PB', '2025-06-18'),
    ('Sabrina Vieira',  'sabrina.vieira@email.com',  'Maceió',          'AL', '2025-06-25'),
    ('Tiago Martins',   'tiago.martins@email.com',   'Rio de Janeiro',  'RJ', '2025-07-02');

-- Pedidos (30 pedidos espalhados ao longo do ano)
INSERT INTO pedidos (cliente_id, data_pedido, status) VALUES
    (1,  '2025-02-01 10:30:00', 'entregue'),
    (2,  '2025-02-15 14:22:00', 'entregue'),
    (3,  '2025-02-20 09:15:00', 'entregue'),
    (4,  '2025-03-01 16:40:00', 'entregue'),
    (5,  '2025-03-10 11:20:00', 'entregue'),
    (1,  '2025-03-15 13:50:00', 'entregue'),
    (6,  '2025-03-22 08:30:00', 'cancelado'),
    (7,  '2025-04-01 17:00:00', 'entregue'),
    (8,  '2025-04-05 10:45:00', 'entregue'),
    (9,  '2025-04-12 14:10:00', 'entregue'),
    (10, '2025-04-18 09:00:00', 'entregue'),
    (2,  '2025-04-25 11:30:00', 'entregue'),
    (11, '2025-05-02 15:20:00', 'entregue'),
    (12, '2025-05-08 12:00:00', 'entregue'),
    (13, '2025-05-15 16:45:00', 'enviado'),
    (3,  '2025-05-22 10:10:00', 'enviado'),
    (14, '2025-06-01 13:30:00', 'enviado'),
    (15, '2025-06-08 09:50:00', 'enviado'),
    (16, '2025-06-12 14:15:00', 'pago'),
    (1,  '2025-06-18 11:00:00', 'pago'),
    (17, '2025-06-22 16:30:00', 'pago'),
    (18, '2025-06-28 10:20:00', 'pago'),
    (19, '2025-07-01 13:45:00', 'pago'),
    (20, '2025-07-05 09:15:00', 'pendente'),
    (4,  '2025-07-08 14:00:00', 'pendente'),
    (5,  '2025-07-12 11:30:00', 'pendente'),
    (6,  '2025-07-15 15:50:00', 'cancelado'),
    (7,  '2025-07-18 10:00:00', 'pendente'),
    (8,  '2025-07-22 13:25:00', 'pendente'),
    (9,  '2025-07-25 16:10:00', 'pendente');

-- Itens dos pedidos (variados)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
    -- Pedido 1: Ana — 1 notebook + 1 fone
    (1, 2, 1, 5499.00),
    (1, 3, 1, 249.50),
    -- Pedido 2: Bruno — 2 livros
    (2, 6, 1, 159.00),
    (2, 7, 1, 109.90),
    -- Pedido 3: Carla — roupas
    (3, 11, 3, 49.90),
    (3, 12, 1, 159.00),
    (3, 13, 1, 299.00),
    -- Pedido 4: Diego — TV
    (4, 4, 1, 3299.00),
    -- Pedido 5: Elena — kit cozinha
    (5, 16, 1, 599.00),
    (5, 18, 1, 129.00),
    -- Pedido 6: Ana de novo — tablet
    (6, 5, 1, 899.00),
    -- Pedido 7: Felipe (cancelado) — esportes
    (7, 22, 1, 1899.00),
    -- Pedido 8: Gabriela — vários livros
    (8, 8, 1, 189.00),
    (8, 9, 1, 249.00),
    (8, 10, 1, 199.00),
    -- Pedido 9: Henrique — tênis e meias
    (9, 13, 1, 299.00),
    (9, 15, 5, 19.90),
    -- Pedido 10: Isabela — fone
    (10, 3, 2, 249.50),
    -- Pedido 11: João — smartphone
    (11, 1, 1, 2499.90),
    -- Pedido 12: Bruno de novo — bola e corda
    (12, 21, 1, 159.00),
    (12, 25, 2, 29.90),
    -- Pedido 13: Karen — cozinha
    (13, 17, 1, 289.00),
    (13, 19, 1, 89.90),
    -- Pedido 14: Lucas — yoga
    (14, 24, 1, 89.00),
    (14, 23, 2, 119.00),
    -- Pedido 15: Mariana — jaqueta + livro
    (15, 14, 1, 219.00),
    (15, 7, 1, 109.90),
    -- Pedido 16: Carla de novo — fone esportivo
    (16, 3, 1, 249.50),
    -- Pedido 17: Nathan — bicicleta
    (17, 22, 1, 1899.00),
    -- Pedido 18: Olivia — vários
    (18, 11, 2, 49.90),
    (18, 12, 1, 159.00),
    (18, 20, 1, 39.90),
    -- Pedido 19: Pedro — smart TV
    (19, 4, 1, 3299.00),
    -- Pedido 20: Ana 3ª vez — clean code
    (20, 7, 1, 109.90),
    -- Pedido 21: Quitéria
    (21, 16, 1, 599.00),
    -- Pedido 22: Renato
    (22, 1, 1, 2499.90),
    (22, 3, 1, 249.50),
    -- Pedido 23: Sabrina
    (23, 11, 4, 49.90),
    -- Pedido 24: Tiago
    (24, 21, 2, 159.00),
    -- Pedido 25: Diego 2ª vez
    (25, 9, 1, 249.00),
    -- Pedido 26: Elena 2ª vez
    (26, 17, 1, 289.00),
    -- Pedido 27: Felipe (cancelado)
    (27, 2, 1, 5499.00),
    -- Pedido 28: Gabriela 2ª vez
    (28, 24, 1, 89.00),
    -- Pedido 29: Henrique 2ª vez
    (29, 14, 1, 219.00),
    -- Pedido 30: Isabela 2ª vez
    (30, 18, 2, 129.00);

SELECT 'Seed carregado: ' || (SELECT count(*) FROM produtos) || ' produtos, ' ||
       (SELECT count(*) FROM clientes) || ' clientes, ' ||
       (SELECT count(*) FROM pedidos) || ' pedidos' AS resultado;
