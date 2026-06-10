-- =============================================
-- Módulo 16 — JSON e JSONB
-- Prática: operadores, funções e índice GIN
-- Rode no banco `loja` (ou crie um separado, tanto faz)
-- =============================================

-- Exercício 1: criar tabela com coluna JSONB
DROP TABLE IF EXISTS eventos;
CREATE TABLE eventos (
    id      SERIAL PRIMARY KEY,
    payload JSONB NOT NULL
);

-- Exercício 2: inserir eventos com formatos diferentes (schemaless, lembra?)
INSERT INTO eventos (payload) VALUES
('{"tipo": "login",  "user": "ana",   "ip": "10.0.0.1"}'),
('{"tipo": "login",  "user": "joao",  "ip": "10.0.0.2"}'),
('{"tipo": "compra", "user": "ana",   "itens": [{"sku": "A1", "qtd": 2}, {"sku": "B7", "qtd": 1}]}'),
('{"tipo": "compra", "user": "joao",  "itens": [{"sku": "A1", "qtd": 1}]}'),
('{"tipo": "logout", "user": "ana"}');

-- Exercício 3: extrair campo com ->> (texto) e -> (jsonb)
SELECT
    id,
    payload -> 'user'   AS user_jsonb,   -- "ana" (com aspas)
    payload ->> 'user'  AS user_text,    -- ana   (texto puro)
    payload ->> 'tipo'  AS tipo
FROM eventos;

-- Exercício 4: filtro com @> (contains) — o operador mais útil do JSONB
-- Todos os eventos do tipo 'login'
SELECT id, payload ->> 'user' AS quem
FROM eventos
WHERE payload @> '{"tipo": "login"}';

-- Todos os eventos da usuária ana
SELECT id, payload ->> 'tipo' AS tipo
FROM eventos
WHERE payload @> '{"user": "ana"}';

-- Exercício 5: busca por path com #> e #>>
-- Pega o SKU do primeiro item de cada compra
SELECT
    id,
    payload #>  '{itens,0,sku}' AS sku_jsonb,
    payload #>> '{itens,0,sku}' AS sku_text
FROM eventos
WHERE payload ->> 'tipo' = 'compra';

-- Exercício 6: jsonb_set pra atualizar valor aninhado
-- Corrige o IP do evento id=1
UPDATE eventos
SET payload = jsonb_set(payload, '{ip}', '"192.168.0.10"')
WHERE id = 1;

-- Adiciona um campo geo que ainda não existe (4º param = true cria o caminho)
UPDATE eventos
SET payload = jsonb_set(payload, '{geo,pais}', '"BR"', true)
WHERE id = 1;

-- Confere
SELECT id, payload FROM eventos WHERE id = 1;

-- Exercício 7: jsonb_array_elements pra explodir array em linhas
-- Cada item de compra vira uma linha (one-row-per-item)
SELECT
    e.id                              AS evento_id,
    e.payload ->> 'user'              AS usuario,
    item ->> 'sku'                    AS sku,
    (item ->> 'qtd')::int             AS quantidade
FROM eventos e,
     jsonb_array_elements(e.payload -> 'itens') AS item
WHERE e.payload ->> 'tipo' = 'compra';

-- Exercício 8: jsonb_agg pra construir JSONB agregando linhas
-- Resumo: pra cada usuário, um array com os tipos de evento dele
SELECT
    payload ->> 'user' AS usuario,
    jsonb_agg(payload ->> 'tipo') AS tipos_de_evento
FROM eventos
GROUP BY payload ->> 'user';

-- Exercício 9: índice GIN pra acelerar buscas com @>
-- jsonb_path_ops é menor e mais rápido pra contains
CREATE INDEX IF NOT EXISTS idx_eventos_payload
ON eventos USING GIN (payload jsonb_path_ops);

-- Exercício 10: query que usa o índice GIN
-- Em uma tabela grande, EXPLAIN mostraria "Bitmap Index Scan on idx_eventos_payload"
EXPLAIN ANALYZE
SELECT * FROM eventos WHERE payload @> '{"tipo": "compra"}';
