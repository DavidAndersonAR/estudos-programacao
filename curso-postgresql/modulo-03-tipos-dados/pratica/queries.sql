-- =============================================
-- Módulo 03 — Tipos de Dados
-- Prática: conversões, datas, arrays, UUID
-- Pré-requisito: ter um Postgres rodando (não precisa do schema da loja aqui)
-- =============================================

-- Exercício 1: cast básico com `::`
-- Texto pra número, número pra texto e date pra texto.
SELECT
  '42'::integer        AS texto_pra_int,
  42::text             AS int_pra_texto,
  '3.14'::numeric      AS texto_pra_numeric,
  current_date::text   AS date_pra_texto;

-- Exercício 2: por que numeric e não float pra dinheiro
-- Compare o resultado das duas somas. A do float não fecha.
SELECT
  0.1::real      + 0.2::real      AS soma_float,
  0.1::numeric   + 0.2::numeric   AS soma_numeric;

-- Exercício 3: funções de data e hora
-- now() inclui timezone; current_date é só data.
SELECT
  current_date                       AS hoje,
  now()                              AS agora_com_tz,
  now() AT TIME ZONE 'UTC'           AS agora_em_utc,
  now() + interval '7 days'          AS daqui_7_dias,
  now() - interval '1 month'         AS um_mes_atras,
  age(timestamp '2000-01-01')        AS idade_do_milenio;

-- Exercício 4: diferença entre timestamps com timezone
-- O Postgres entende e converte os fusos antes de comparar.
SELECT
  '2026-06-09 10:00-03'::timestamptz AS sao_paulo,
  '2026-06-09 10:00+00'::timestamptz AS londres,
  '2026-06-09 10:00+00'::timestamptz - '2026-06-09 10:00-03'::timestamptz AS diferenca;

-- Exercício 5: gerando UUIDs
-- gen_random_uuid() vem nativa no Postgres 13+.
SELECT
  gen_random_uuid() AS id_1,
  gen_random_uuid() AS id_2,
  gen_random_uuid() AS id_3;

-- Exercício 6: array literal e operações básicas
-- Criando um array, pegando elemento, somando, vendo tamanho.
SELECT
  ARRAY[10, 20, 30, 40]              AS lista,
  ARRAY[10, 20, 30, 40][2]           AS segundo_elemento,
  array_length(ARRAY[10, 20, 30], 1) AS tamanho,
  ARRAY['go', 'sql', 'docker']       AS skills;

-- Exercício 7: unnest — explodindo array em linhas
-- Útil pra transformar array em algo que dá pra filtrar/agregar.
SELECT unnest(ARRAY['postgres', 'mysql', 'sqlite', 'oracle']) AS banco;

-- Exercício 8: testando pertencimento em array
SELECT
  'sql' = ANY(ARRAY['go', 'sql', 'docker'])  AS tem_sql,
  'java' = ANY(ARRAY['go', 'sql', 'docker']) AS tem_java;

-- Exercício 9: cast entre numeric e text (formatação)
-- to_char dá controle fino na formatação de número.
SELECT
  1234567.89::numeric(12,2)                  AS valor_numerico,
  1234567.89::numeric(12,2)::text            AS cast_direto,
  to_char(1234567.89, 'FM999G999G990D00')    AS formatado_br;

-- Exercício 10: cast com tratamento — interval pra texto e vice-versa
SELECT
  interval '1 year 2 months 3 days'         AS um_interval,
  (interval '1 year 2 months 3 days')::text AS interval_em_texto,
  '90 minutes'::interval                    AS texto_em_interval;
