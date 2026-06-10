-- =============================================
-- 🎯 DESAFIO DO MÓDULO 03 — Validador de Dados de Cadastro
-- =============================================
--
-- Objetivo:
-- Você é o backend de um cadastro e recebe esses dados crus.
-- Escreva queries que detectem o que está errado em cada caso.
--
-- Use a CTE abaixo como sua "tabela" de entrada (não precisa criar tabela real):
--
-- WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
--   VALUES
--     (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
--     (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
--     (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
--     (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
--     (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
-- )
--
-- Pra cada pergunta, faça `WITH cadastros(...) AS (VALUES ...) SELECT ...`.
--
-- Pergunta 1: Quais cadastros têm email malformado?
--             (regra simples: precisa ter exatamente um '@' e pelo menos um '.' depois do '@')
-- Pergunta 2: Quais têm data de nascimento no futuro (impossível)?
-- Pergunta 3: Quais têm salário negativo ou zero?
-- Pergunta 4: Quais têm CPF com tamanho diferente de 11 dígitos OU contendo letra?
-- Pergunta 5: Quais têm telefone com tamanho fora de 10 ou 11 dígitos?
-- Pergunta 6: Quais têm data_cadastro no futuro (depois de hoje)?
-- Pergunta 7: Liste TODOS os cadastros com uma coluna `problemas` (text[]) listando
--             todas as falhas detectadas (junte as regras 1 a 6 + nome vazio).
--
-- 💡 Dicas:
--   - length(texto) retorna tamanho da string
--   - texto ~ 'regex' faz match de regex POSIX
--   - texto !~ 'regex' é o inverso
--   - CAST com `::date` e `::numeric` quando precisar
--   - array_append(arr, valor) ou CASE em ARRAY[...] pra montar lista de problemas
--   - current_date pra "hoje"
--
-- ============================
-- SUA SOLUÇÃO ABAIXO
-- ============================

-- Pergunta 1 — email malformado:


-- Pergunta 2 — nascimento no futuro:


-- Pergunta 3 — salário <= 0:


-- Pergunta 4 — CPF inválido:


-- Pergunta 5 — telefone com tamanho errado:


-- Pergunta 6 — data_cadastro no futuro:


-- Pergunta 7 — relatório completo (problemas como array):


-- ============================
-- SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
-- ============================

/*
-- Bloco base reaproveitado em todas as queries
-- (em cada pergunta, copie a CTE antes do SELECT)

-- 1: email malformado
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT id, email
FROM cadastros
WHERE email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$';

-- 2: nascimento no futuro
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT id, nascimento
FROM cadastros
WHERE nascimento > current_date;

-- 3: salário <= 0
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT id, salario
FROM cadastros
WHERE salario <= 0;

-- 4: CPF inválido (tamanho != 11 ou contém não-dígito)
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT id, cpf
FROM cadastros
WHERE length(cpf) <> 11 OR cpf !~ '^[0-9]+$';

-- 5: telefone fora de 10/11 dígitos
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT id, telefone, length(telefone) AS tam
FROM cadastros
WHERE length(telefone) NOT IN (10, 11) OR telefone !~ '^[0-9]+$';

-- 6: data_cadastro no futuro
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT id, data_cadastro
FROM cadastros
WHERE data_cadastro > current_date;

-- 7: relatório completo com array de problemas
WITH cadastros(id, nome, email, cpf, telefone, salario, nascimento, data_cadastro) AS (
  VALUES
    (1, 'Ana Souza',    'ana@empresa.com',    '12345678901', '11987654321', 4500.00::numeric, '1990-05-12'::date, '2026-01-10'::date),
    (2, 'Bruno Lima',   'bruno_at_email',     '12345',       '1198765',     -100.00::numeric, '2030-01-01'::date, '2026-02-15'::date),
    (3, 'Carla Dias',   'carla@dominio.com',  '98765432100', '21999887766', 7200.50::numeric, '1985-11-30'::date, '2026-03-20'::date),
    (4, '',             'invalido@@x.com',    'abc',         '0000',         3200.00::numeric, '1995-08-22'::date, '2099-12-31'::date),
    (5, 'Eduardo Reis', 'edu.reis@x.com.br',  '11122233344', '11912345678', 0::numeric,        '2010-06-15'::date, '2026-04-01'::date)
)
SELECT
  id,
  nome,
  ARRAY_REMOVE(ARRAY[
    CASE WHEN length(trim(nome)) = 0                                  THEN 'nome_vazio'           END,
    CASE WHEN email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'                    THEN 'email_invalido'       END,
    CASE WHEN nascimento > current_date                                THEN 'nascimento_no_futuro' END,
    CASE WHEN salario <= 0                                             THEN 'salario_invalido'     END,
    CASE WHEN length(cpf) <> 11 OR cpf !~ '^[0-9]+$'                   THEN 'cpf_invalido'         END,
    CASE WHEN length(telefone) NOT IN (10, 11) OR telefone !~ '^[0-9]+$' THEN 'telefone_invalido'  END,
    CASE WHEN data_cadastro > current_date                             THEN 'cadastro_no_futuro'   END
  ], NULL) AS problemas
FROM cadastros
ORDER BY id;
*/
