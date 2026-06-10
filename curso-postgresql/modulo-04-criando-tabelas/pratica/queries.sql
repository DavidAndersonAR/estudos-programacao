-- =============================================
-- Módulo 04 — Criando Tabelas (DDL)
-- Prática: CREATE TABLE, constraints, ALTER, DROP, schemas
-- Pré-requisito: schema.sql + seed.sql do Módulo 01 carregados
-- Dica: rode comando por comando no psql pra ver o efeito
-- =============================================

-- Exercício 1: criar tabela enderecos_entrega com NOT NULL e CHECK no CEP
-- Observação: CEP no Brasil tem 8 dígitos numéricos. CHAR(8) + CHECK garante.
CREATE TABLE enderecos_entrega (
    id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_id    INTEGER NOT NULL REFERENCES clientes(id),
    logradouro    VARCHAR(200) NOT NULL,
    numero        VARCHAR(20)  NOT NULL,
    complemento   VARCHAR(100),
    bairro        VARCHAR(100) NOT NULL,
    cidade        VARCHAR(100) NOT NULL,
    estado        CHAR(2)      NOT NULL,
    cep           CHAR(8)      NOT NULL,
    criado_em     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT enderecos_cep_check CHECK (cep ~ '^[0-9]{8}$')
);

-- Exercício 2: adicionar coluna "sku" em produtos (código interno)
-- Cuidado: sem DEFAULT em tabela com dados, daria erro se fosse NOT NULL
ALTER TABLE produtos ADD COLUMN sku VARCHAR(50);

-- Exercício 3: criar UNIQUE composto (mesmo cliente não pode ter o mesmo
-- endereço cadastrado duas vezes em logradouro+numero)
ALTER TABLE enderecos_entrega
  ADD CONSTRAINT enderecos_cliente_endereco_unique
  UNIQUE (cliente_id, logradouro, numero);

-- Exercício 4: modificar constraint — trocando o CHECK do estoque por um mais
-- rígido (não basta ser >= 0; também limitamos teto pra evitar erro de digitação)
ALTER TABLE produtos
  ADD CONSTRAINT produtos_estoque_range CHECK (estoque BETWEEN 0 AND 1000000);

-- (Se quisesse trocar o original gerado pelo schema:
--   ALTER TABLE produtos DROP CONSTRAINT produtos_estoque_check;
--  e recriar — mas como aqui ele tem nome automático, deixamos coexistirem)

-- Exercício 5: criar tabela com IDENTITY moderno (em vez de SERIAL antigo)
-- Note o GENERATED ALWAYS — não dá pra inserir id manualmente nessa tabela
CREATE TABLE fornecedores (
    id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         VARCHAR(200) NOT NULL,
    cnpj         CHAR(14)     NOT NULL UNIQUE,
    ativo        BOOLEAN      NOT NULL DEFAULT true,
    criado_em    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Exercício 6: DEFAULT now() — coluna que registra última atualização
-- (vai virar útil quando combinarmos com trigger lá no Módulo 14)
ALTER TABLE produtos
  ADD COLUMN atualizado_em TIMESTAMPTZ NOT NULL DEFAULT now();

-- Exercício 7: CHECK com expressão composta — desconto entre 0 e 100%
-- e validade futura no momento de cadastro
CREATE TABLE promocoes (
    id                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome               VARCHAR(100) NOT NULL,
    percentual         NUMERIC(5, 2) NOT NULL,
    inicio             DATE NOT NULL DEFAULT CURRENT_DATE,
    fim                DATE NOT NULL,
    CONSTRAINT promocoes_percentual_check CHECK (percentual > 0 AND percentual <= 100),
    CONSTRAINT promocoes_periodo_check    CHECK (fim >= inicio)
);

-- Exercício 8: criar schema separado pra área de relatórios
-- (evita misturar tabelas operacionais com tabelas de análise)
CREATE SCHEMA IF NOT EXISTS relatorios;

CREATE TABLE relatorios.resumo_diario (
    dia                 DATE PRIMARY KEY,
    total_pedidos       INTEGER NOT NULL DEFAULT 0,
    total_faturado      NUMERIC(14, 2) NOT NULL DEFAULT 0,
    gerado_em           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Exercício 9: renomear coluna e tabela (caso tenha errado o nome)
-- Vamos só demonstrar — depois voltamos ao nome original
ALTER TABLE fornecedores RENAME COLUMN ativo TO em_atividade;
ALTER TABLE fornecedores RENAME COLUMN em_atividade TO ativo;

-- Exercício 10: limpar tudo que criamos nessa prática (CASCADE arrasta deps)
-- Ordem não importa muito com CASCADE, mas é bom hábito apagar filhas antes
DROP TABLE IF EXISTS relatorios.resumo_diario;
DROP SCHEMA IF EXISTS relatorios;
DROP TABLE IF EXISTS promocoes;
DROP TABLE IF EXISTS fornecedores;
DROP TABLE IF EXISTS enderecos_entrega;
ALTER TABLE produtos DROP COLUMN IF EXISTS sku;
ALTER TABLE produtos DROP COLUMN IF EXISTS atualizado_em;
ALTER TABLE produtos DROP CONSTRAINT IF EXISTS produtos_estoque_range;
