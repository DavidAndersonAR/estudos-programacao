-- =============================================
-- Módulo 19 — Particionamento
-- Prática: RANGE, LIST, pruning, ATTACH/DETACH
-- Roda num banco limpo (sem dependência da loja)
-- =============================================

-- Limpa execuções anteriores (ordem importa — filhas antes do pai)
DROP TABLE IF EXISTS vendas_partitioned CASCADE;
DROP TABLE IF EXISTS clientes_por_estado CASCADE;
DROP TABLE IF EXISTS vendas_2025_04 CASCADE;

-- Exercício 1: criar tabela particionada por RANGE em data
-- Note: PK precisa incluir a coluna de partição (data)
CREATE TABLE vendas_partitioned (
    id      SERIAL,
    data    DATE NOT NULL,
    valor   NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (id, data)
) PARTITION BY RANGE (data);

-- Exercício 2: criar 3 partições mensais (jan, fev, mar de 2025)
CREATE TABLE vendas_2025_01 PARTITION OF vendas_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE vendas_2025_02 PARTITION OF vendas_partitioned
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE vendas_2025_03 PARTITION OF vendas_partitioned
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

-- Exercício 3: inserir dados e descobrir em qual partição caíram
-- tableoid::regclass mostra a tabela física onde a linha vive
INSERT INTO vendas_partitioned (data, valor) VALUES
    ('2025-01-15', 100.00),
    ('2025-01-28', 250.50),
    ('2025-02-03', 80.00),
    ('2025-02-22', 999.99),
    ('2025-03-10', 1200.00),
    ('2025-03-31', 45.00);

SELECT tableoid::regclass AS particao, id, data, valor
FROM vendas_partitioned
ORDER BY data;

-- Exercício 4: demonstrar partition pruning
-- Olhe o EXPLAIN: só a partição de fevereiro deve aparecer
EXPLAIN
SELECT * FROM vendas_partitioned
WHERE data >= '2025-02-01' AND data < '2025-03-01';

-- Compare: filtro fora da coluna de partição -> lê todas as partições
EXPLAIN
SELECT * FROM vendas_partitioned WHERE valor > 500;

-- Exercício 5: criar índice na tabela pai (propaga pra todas as partições)
CREATE INDEX ON vendas_partitioned (valor);
\d+ vendas_partitioned

-- Exercício 6: particionar por LIST em estado (UF)
CREATE TABLE clientes_por_estado (
    id      SERIAL,
    nome    TEXT NOT NULL,
    estado  CHAR(2) NOT NULL,
    PRIMARY KEY (id, estado)
) PARTITION BY LIST (estado);

CREATE TABLE clientes_sp PARTITION OF clientes_por_estado FOR VALUES IN ('SP');
CREATE TABLE clientes_rj PARTITION OF clientes_por_estado FOR VALUES IN ('RJ');
CREATE TABLE clientes_sul PARTITION OF clientes_por_estado FOR VALUES IN ('PR', 'SC', 'RS');

INSERT INTO clientes_por_estado (nome, estado) VALUES
    ('Ana',    'SP'),
    ('Bruno',  'RJ'),
    ('Carla',  'PR'),
    ('Diego',  'RS');

SELECT tableoid::regclass AS particao, * FROM clientes_por_estado ORDER BY id;

-- Exercício 7: DEFAULT partition (catch-all)
-- Sem ela, inserir 'MG' falharia com "no partition found"
CREATE TABLE clientes_outros PARTITION OF clientes_por_estado DEFAULT;

INSERT INTO clientes_por_estado (nome, estado) VALUES ('Elisa', 'MG');

SELECT tableoid::regclass AS particao, nome, estado
FROM clientes_por_estado
WHERE estado = 'MG';

-- Exercício 8: ATTACH e DETACH
-- Criar partição "solta" (com mesma estrutura), carregar dados, anexar depois
CREATE TABLE vendas_2025_04 (
    id      INTEGER NOT NULL,
    data    DATE NOT NULL,
    valor   NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (id, data),
    CHECK (data >= '2025-04-01' AND data < '2025-05-01')
);

INSERT INTO vendas_2025_04 (id, data, valor) VALUES
    (1001, '2025-04-05', 300.00),
    (1002, '2025-04-20', 750.00);

ALTER TABLE vendas_partitioned ATTACH PARTITION vendas_2025_04
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

-- Confirma: a partição de abril agora aparece nos selects da tabela pai
SELECT tableoid::regclass AS particao, id, data, valor
FROM vendas_partitioned
WHERE data >= '2025-04-01'
ORDER BY data;

-- DETACH: desanexar (a tabela vira "solta", não some)
ALTER TABLE vendas_partitioned DETACH PARTITION vendas_2025_01;

-- Após DETACH, vendas_2025_01 existe sozinha — daria pra arquivar ou dropar
SELECT count(*) AS vendas_jan FROM vendas_2025_01;
SELECT count(*) AS vendas_pai_apos_detach FROM vendas_partitioned;
