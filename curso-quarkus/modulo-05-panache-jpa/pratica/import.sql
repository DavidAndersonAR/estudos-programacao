-- Seed de dev: roda automaticamente apos drop-and-create.
-- ATENCAO: cada linha precisa terminar em ;

INSERT INTO autor(id, nome, nascimento) VALUES (1, 'Machado de Assis', '1839-06-21');
INSERT INTO autor(id, nome, nascimento) VALUES (2, 'Clarice Lispector', '1920-12-10');
INSERT INTO autor(id, nome, nascimento) VALUES (3, 'Jorge Amado', '1912-08-10');

INSERT INTO livro(id, titulo, ano, preco, autor_id) VALUES (1, 'Memorias Postumas de Bras Cubas', 1881, 49.90, 1);
INSERT INTO livro(id, titulo, ano, preco, autor_id) VALUES (2, 'Dom Casmurro', 1899, 39.90, 1);
INSERT INTO livro(id, titulo, ano, preco, autor_id) VALUES (3, 'A Hora da Estrela', 1977, 35.00, 2);
INSERT INTO livro(id, titulo, ano, preco, autor_id) VALUES (4, 'Agua Viva', 1973, 42.00, 2);
INSERT INTO livro(id, titulo, ano, preco, autor_id) VALUES (5, 'Capitaes da Areia', 1937, 45.00, 3);
INSERT INTO livro(id, titulo, ano, preco, autor_id) VALUES (6, 'Gabriela Cravo e Canela', 1958, 55.00, 3);

-- Ajusta as sequences (PanacheEntity usa SEQUENCE por default).
ALTER SEQUENCE autor_seq RESTART WITH 50;
ALTER SEQUENCE livro_seq RESTART WITH 50;
