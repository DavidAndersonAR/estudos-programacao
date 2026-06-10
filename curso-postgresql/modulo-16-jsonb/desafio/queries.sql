-- =============================================
-- Módulo 16 — Desafio: Catálogo Flexível com JSONB
-- =============================================
-- Cenário: você tá modelando o catálogo de uma loja que vende DE TUDO
-- (eletrônicos, roupas, móveis, livros). Cada categoria tem atributos
-- diferentes: notebook tem RAM/SSD/tela, camiseta tem tamanho/cor,
-- mesa tem dimensão/material. Em vez de criar 80 colunas (com 70 NULL),
-- vamos jogar o que varia num JSONB chamado `attrs`.
--
-- Resolva cada TODO. As soluções estão lá embaixo — só consulta depois
-- de tentar de verdade.
-- =============================================

-- Setup: tabela do catálogo flexível
DROP TABLE IF EXISTS produtos_v2;
CREATE TABLE produtos_v2 (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(200) NOT NULL,
    attrs JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- ---------------------------------------------
-- Tarefa 1: inserir 6 produtos com attrs distintos.
--   - 2 notebooks com chaves: ram_gb, ssd_gb, tela_polegadas, cor
--   - 2 camisetas com chaves: tamanho, cor, material
--   - 1 mesa com chaves: largura_cm, profundidade_cm, material
--   - 1 livro com chaves: autor, paginas, idioma
-- TODO: escreva os INSERTs aqui
--
-- (resposta na seção SOLUÇÃO lá embaixo)
-- ---------------------------------------------


-- ---------------------------------------------
-- Tarefa 2: listar produtos com RAM >= 16 GB.
-- Dica: precisa fazer cast de (attrs ->> 'ram_gb') pra int.
-- TODO:
-- ---------------------------------------------


-- ---------------------------------------------
-- Tarefa 3: listar TODAS as cores únicas presentes no catálogo.
-- Dica: nem todo produto tem cor — use WHERE attrs ? 'cor'.
-- TODO:
-- ---------------------------------------------


-- ---------------------------------------------
-- Tarefa 4: atualizar a cor do notebook id=1 pra 'grafite'
-- usando jsonb_set (não substituir o objeto inteiro).
-- TODO:
-- ---------------------------------------------


-- ---------------------------------------------
-- Tarefa 5: criar um índice GIN em attrs pra acelerar
-- buscas com @>. Escolha jsonb_path_ops se for só contains.
-- TODO:
-- ---------------------------------------------


-- ---------------------------------------------
-- Tarefa 6: buscar todos os produtos da cor 'preto' usando @>
-- e confirmar com EXPLAIN ANALYZE que o índice foi usado.
-- (em poucos registros o planner pode preferir seq scan — tudo bem)
-- TODO:
-- ---------------------------------------------


-- =============================================
-- 🟢 SOLUÇÃO (espia depois de tentar!)
-- =============================================

-- Tarefa 1
INSERT INTO produtos_v2 (nome, attrs) VALUES
('Notebook Pro 14',  '{"ram_gb": 16, "ssd_gb": 512, "tela_polegadas": 14, "cor": "prata"}'),
('Notebook Lite 13', '{"ram_gb": 8,  "ssd_gb": 256, "tela_polegadas": 13, "cor": "preto"}'),
('Camiseta Básica',  '{"tamanho": "M", "cor": "preto",  "material": "algodao"}'),
('Camiseta Polo',    '{"tamanho": "G", "cor": "branco", "material": "pique"}'),
('Mesa de Jantar',   '{"largura_cm": 160, "profundidade_cm": 90, "material": "madeira"}'),
('Livro Postgres',   '{"autor": "Korry Douglas", "paginas": 1024, "idioma": "en"}');

-- Tarefa 2: RAM >= 16
SELECT id, nome, attrs ->> 'ram_gb' AS ram
FROM produtos_v2
WHERE attrs ? 'ram_gb'
  AND (attrs ->> 'ram_gb')::int >= 16;

-- Tarefa 3: cores únicas
SELECT DISTINCT attrs ->> 'cor' AS cor
FROM produtos_v2
WHERE attrs ? 'cor'
ORDER BY cor;

-- Tarefa 4: trocar cor do notebook id=1 pra grafite
UPDATE produtos_v2
SET attrs = jsonb_set(attrs, '{cor}', '"grafite"')
WHERE id = 1;

-- confere
SELECT id, nome, attrs FROM produtos_v2 WHERE id = 1;

-- Tarefa 5: índice GIN
CREATE INDEX IF NOT EXISTS idx_produtos_v2_attrs
ON produtos_v2 USING GIN (attrs jsonb_path_ops);

-- Tarefa 6: buscar cor 'preto' + ver o plano
EXPLAIN ANALYZE
SELECT id, nome FROM produtos_v2
WHERE attrs @> '{"cor": "preto"}';

-- Bônus: e se eu quisesse filtrar por cor o tempo todo?
-- Promove a coluna pra ser indexável como B-tree comum.
-- ALTER TABLE produtos_v2
--   ADD COLUMN cor TEXT GENERATED ALWAYS AS (attrs ->> 'cor') STORED;
-- CREATE INDEX idx_produtos_v2_cor ON produtos_v2 (cor);
