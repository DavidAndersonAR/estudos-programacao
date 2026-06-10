-- =============================================
-- 🎯 DESAFIO DO MÓDULO 04 — Tabelas Auxiliares da Loja
-- =============================================
--
-- Objetivo:
-- A loja precisa de 3 tabelas novas pra dar conta de funcionalidades extras.
-- Sua missão: modelar essas tabelas usando o que aprendeu de DDL —
-- chaves primárias, NOT NULL, UNIQUE, CHECK, DEFAULT, FKs e nomes de constraint.
--
-- Pré-requisito: schema do Módulo 01 carregado (produtos, clientes existem).
--
-- ─────────────────────────────────────────────
-- TAREFA 1 — Tabela `cupons`
-- ─────────────────────────────────────────────
-- Crie a tabela `cupons` com:
--   - id: chave primária auto-incremento (use IDENTITY moderno)
--   - codigo: VARCHAR(30), obrigatório, ÚNICO (ex.: "BEMVINDO10")
--   - percentual_desconto: NUMERIC(5,2), obrigatório, entre 0 (exclusivo) e 100 (inclusivo)
--   - validade: DATE, obrigatório
--   - ativo: BOOLEAN, obrigatório, padrão true
--   - criado_em: TIMESTAMPTZ, obrigatório, padrão now()
-- Nomeie pelo menos 1 constraint (ex.: cupons_percentual_check).
--
-- ─────────────────────────────────────────────
-- TAREFA 2 — Tabela `avaliacoes`
-- ─────────────────────────────────────────────
-- Crie a tabela `avaliacoes` com:
--   - id: PK auto-incremento (IDENTITY)
--   - produto_id: FK pra produtos(id), obrigatório
--   - cliente_id: FK pra clientes(id), obrigatório
--   - nota: INTEGER obrigatório, só aceita valores de 1 a 5
--   - comentario: TEXT (opcional — pode ser NULL)
--   - data: TIMESTAMPTZ obrigatório, padrão now()
--   - Restrição extra: o mesmo cliente não pode avaliar o mesmo produto 2 vezes
--     (use UNIQUE composto em produto_id + cliente_id)
--
-- ─────────────────────────────────────────────
-- TAREFA 3 — Tabela `historico_precos`
-- ─────────────────────────────────────────────
-- Crie a tabela `historico_precos` com:
--   - id: PK auto-incremento (IDENTITY)
--   - produto_id: FK pra produtos(id), obrigatório
--   - preco_antigo: NUMERIC(10,2), obrigatório, >= 0
--   - preco_novo: NUMERIC(10,2), obrigatório, >= 0
--   - data: TIMESTAMPTZ obrigatório, padrão now()
--   - CHECK extra: preco_novo deve ser diferente de preco_antigo
--     (não faz sentido registrar mudança sem mudança)
--
-- 💡 Dicas:
--   - Use CONSTRAINT nome_da_constraint pra nomear constraints importantes
--   - CHECK aceita expressão composta com AND
--   - Pra UNIQUE composto, declare no nível da tabela: UNIQUE (col1, col2)
--   - FK: REFERENCES tabela(id)
--   - Em desenvolvimento, prefixe com DROP TABLE IF EXISTS pra poder rodar de novo
--
-- ============================
-- SUA SOLUÇÃO ABAIXO
-- ============================

-- TAREFA 1: cupons


-- TAREFA 2: avaliacoes


-- TAREFA 3: historico_precos


-- ============================
-- SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
-- ============================

/*
-- Pra rodar sem dor em ambiente de estudo: limpa antes
DROP TABLE IF EXISTS historico_precos;
DROP TABLE IF EXISTS avaliacoes;
DROP TABLE IF EXISTS cupons;

-- TAREFA 1: cupons
CREATE TABLE cupons (
    id                   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo               VARCHAR(30)   NOT NULL UNIQUE,
    percentual_desconto  NUMERIC(5, 2) NOT NULL,
    validade             DATE          NOT NULL,
    ativo                BOOLEAN       NOT NULL DEFAULT true,
    criado_em            TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT cupons_percentual_check
        CHECK (percentual_desconto > 0 AND percentual_desconto <= 100)
);

-- TAREFA 2: avaliacoes
CREATE TABLE avaliacoes (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    produto_id   INTEGER     NOT NULL REFERENCES produtos(id),
    cliente_id   INTEGER     NOT NULL REFERENCES clientes(id),
    nota         INTEGER     NOT NULL,
    comentario   TEXT,
    data         TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT avaliacoes_nota_check       CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT avaliacoes_produto_cliente_unique UNIQUE (produto_id, cliente_id)
);

-- TAREFA 3: historico_precos
CREATE TABLE historico_precos (
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    produto_id    INTEGER        NOT NULL REFERENCES produtos(id),
    preco_antigo  NUMERIC(10, 2) NOT NULL,
    preco_novo    NUMERIC(10, 2) NOT NULL,
    data          TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT historico_preco_antigo_nao_neg CHECK (preco_antigo >= 0),
    CONSTRAINT historico_preco_novo_nao_neg   CHECK (preco_novo   >= 0),
    CONSTRAINT historico_precos_diferentes    CHECK (preco_novo  <> preco_antigo)
);

-- Teste rápido (deve aceitar):
INSERT INTO cupons (codigo, percentual_desconto, validade)
VALUES ('BEMVINDO10', 10, CURRENT_DATE + INTERVAL '30 days');

-- Teste rápido (deve FALHAR — percentual inválido):
-- INSERT INTO cupons (codigo, percentual_desconto, validade)
-- VALUES ('BUG', 150, CURRENT_DATE);

-- Teste rápido (deve FALHAR — nota fora do range):
-- INSERT INTO avaliacoes (produto_id, cliente_id, nota) VALUES (1, 1, 7);
*/
