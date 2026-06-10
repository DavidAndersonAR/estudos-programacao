# Módulo 04 — Criando Tabelas (DDL)

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar tabelas com `CREATE TABLE` e escolher tipos certos
- Aplicar **constraints** (NOT NULL, UNIQUE, CHECK, DEFAULT, PRIMARY KEY) com nome explícito
- Saber a diferença entre **SERIAL** e **GENERATED ALWAYS AS IDENTITY** (e por que usar IDENTITY hoje)
- Modificar tabelas existentes com `ALTER TABLE` (ADD/DROP COLUMN, ADD CONSTRAINT, RENAME)
- Remover tabelas com `DROP TABLE ... CASCADE` sem deixar lixo
- Entender **TEMPORARY tables** e organizar com **schemas**

## 🧱 DDL é o quê?
**DDL = Data Definition Language**. É a parte do SQL que **define a estrutura** do banco: tabelas, colunas, tipos, restrições, índices, schemas. Mexe na "forma" — não nos dados.

- **DDL**: `CREATE`, `ALTER`, `DROP`, `TRUNCATE` (define o esqueleto)
- **DML**: `INSERT`, `UPDATE`, `DELETE` (mexe nos dados — Módulo 05)
- **DQL**: `SELECT` (consulta — Módulos 02 e 03)

Pense em DDL como a planta da casa; DML é mobiliar; DQL é dar uma volta vendo o que tem.

## 🏗️ CREATE TABLE — anatomia básica
```sql
CREATE TABLE livros (
    id           INTEGER PRIMARY KEY,
    titulo       VARCHAR(200) NOT NULL,
    paginas      INTEGER CHECK (paginas > 0),
    publicado_em DATE DEFAULT CURRENT_DATE
);
```

Quebra:
- `id INTEGER PRIMARY KEY` — chave primária (única + NOT NULL automaticamente)
- `titulo VARCHAR(200) NOT NULL` — string até 200 chars, obrigatório
- `paginas INTEGER CHECK (paginas > 0)` — só aceita inteiro positivo
- `publicado_em DATE DEFAULT CURRENT_DATE` — se não informar, vira hoje

## 🚧 Constraints — as regras do jogo

| Constraint | O que faz |
|---|---|
| `NOT NULL` | proíbe NULL na coluna |
| `UNIQUE` | nenhum valor repetido (NULLs são considerados distintos) |
| `CHECK (expr)` | só aceita linhas onde `expr` é verdade |
| `DEFAULT valor` | se não informar, usa esse valor |
| `PRIMARY KEY` | identificador único da linha (NOT NULL + UNIQUE) |
| `FOREIGN KEY` | referencia outra tabela (vamos detalhar no Módulo 06) |

### Constraint a nível de coluna vs tabela
Pode declarar **junto da coluna** (mais limpo pra constraint simples) ou **na tabela** (necessário pra constraints compostas):

```sql
-- Constraint composta: UNIQUE em duas colunas juntas
CREATE TABLE matriculas (
    aluno_id   INTEGER NOT NULL,
    curso_id   INTEGER NOT NULL,
    UNIQUE (aluno_id, curso_id)
);
```

### Nomeando constraints (boa prática!)
Constraint sem nome ganha um nome automático tipo `produtos_preco_check`. Funciona, mas se um dia precisar **alterar ou remover** vai ficar caçando. Dê nome:

```sql
CREATE TABLE produtos2 (
    id      INTEGER PRIMARY KEY,
    preco   NUMERIC(10, 2),
    CONSTRAINT preco_positivo CHECK (preco >= 0)
);
```

Convenção comum: `tabela_coluna_tipo` (ex.: `produtos_preco_check`, `clientes_email_unique`).

## 🔢 SERIAL vs IDENTITY — chave auto-incremento
Você vai ver os dois em código alheio. Vale entender:

### SERIAL (jeito antigo, mas ainda muito usado)
```sql
CREATE TABLE x (
    id SERIAL PRIMARY KEY
);
```
`SERIAL` não é tipo de verdade — é açúcar que cria uma `SEQUENCE` por baixo e seta `DEFAULT nextval(...)`. Funciona, mas tem pegadinhas: a sequence fica "solta" e dá pra inserir id manualmente passando por cima.

### GENERATED ALWAYS AS IDENTITY (jeito moderno, padrão SQL)
```sql
CREATE TABLE x (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);
```
- É padrão SQL (Oracle, DB2 também usam) → mais portável
- `ALWAYS` impede insert manual de id (mais seguro)
- Existe variante `BY DEFAULT` se quiser permitir override
- Recomendação: **use IDENTITY em código novo**. SERIAL você lê em código legado.

Para identificadores enormes (sistema distribuído, ID público), considere `UUID` ou `BIGINT IDENTITY`.

## 🛠️ ALTER TABLE — mudando depois de pronto
Você quase nunca acerta o schema na primeira. `ALTER TABLE` resolve:

```sql
-- Adicionar coluna
ALTER TABLE produtos ADD COLUMN sku VARCHAR(50);

-- Adicionar coluna com NOT NULL + DEFAULT (necessário se tabela tem dados)
ALTER TABLE produtos ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT true;

-- Remover coluna
ALTER TABLE produtos DROP COLUMN sku;

-- Renomear
ALTER TABLE produtos RENAME COLUMN preco TO preco_venda;
ALTER TABLE produtos RENAME TO catalogo;

-- Adicionar constraint
ALTER TABLE produtos
  ADD CONSTRAINT produtos_estoque_check CHECK (estoque >= 0);

-- Remover constraint (precisa saber o nome — viu por que nomear?)
ALTER TABLE produtos DROP CONSTRAINT produtos_estoque_check;

-- Mudar tipo de coluna
ALTER TABLE produtos ALTER COLUMN preco TYPE NUMERIC(12, 2);
```

⚠️ **Cuidado em produção**: alguns ALTERs reescrevem a tabela inteira e travam ela. Em bancos grandes existem técnicas (NOT VALID, expand/contract). Veremos no Módulo de Operação.

## 💣 DROP TABLE — apagando
```sql
DROP TABLE produtos;                -- erro se algo referencia
DROP TABLE produtos CASCADE;        -- arrasta dependências (cuidado!)
DROP TABLE IF EXISTS produtos;      -- não dá erro se não existe
```

`CASCADE` é prático em dev pra recriar tudo (vide o `schema.sql` do Módulo 01). Em produção, **pense duas vezes** — vai derrubar views, FKs, etc.

## ⚡ TEMPORARY tables (visão geral)
Tabela que **só existe na sessão atual** e some quando a conexão fecha:

```sql
CREATE TEMP TABLE relatorio_tmp AS
SELECT cliente_id, count(*) AS qtd
FROM pedidos
GROUP BY cliente_id;
```

Útil pra:
- **Cálculos intermediários** em scripts/relatórios
- **Stage** de dados antes de inserir na tabela final
- Não polui o schema principal

Detalhe: cada sessão tem a sua, não compartilha com outras conexões.

## 🗂️ Schemas — organizando tabelas
Schema é um **namespace** dentro do banco. Por padrão tudo vai pro schema `public`. Em projetos maiores você separa por área:

```sql
CREATE SCHEMA financeiro;
CREATE SCHEMA logistica;

CREATE TABLE financeiro.faturas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    valor NUMERIC(12, 2) NOT NULL
);

-- Pra consultar:
SELECT * FROM financeiro.faturas;

-- Ou setar search_path pra não precisar prefixar:
SET search_path TO financeiro, public;
```

Benefícios: organização, permissões granulares, evita conflito de nomes.

## 💡 Dicas de quem cria schema há tempo
- **Nomes em snake_case e plural**: `clientes`, `itens_pedido`. Convenção quase universal em Postgres.
- **NUMERIC pra dinheiro, nunca FLOAT/REAL**: `NUMERIC(10,2)`. Float perde centavo.
- **TIMESTAMPTZ > TIMESTAMP** pra datas de evento — guarda timezone, evita dor de cabeça.
- **Sempre `NOT NULL` por padrão**; só relaxe quando a coluna *realmente* pode ser desconhecida.
- **CHECK é seu amigo**: prefira "preço >= 0" no banco a confiar só na app.
- **Constraint nomeada** salva sua vida no `ALTER TABLE` lá na frente.
- **Não use `VARCHAR(n)` por reflexo** se não tem limite real — `TEXT` é igual em performance no Postgres.

## 🚦 Próximos passos
1. Leia o `pratica/queries.sql` e rode passo a passo no psql
2. Faça o `desafio/queries.sql` modelando as 3 tabelas auxiliares
3. Confira sua solução no bloco comentado do final
4. Vá pro Módulo 05 — INSERT, UPDATE, DELETE pra mexer nos dados

## ✅ Auto-verificação
- [ ] Sei criar tabela com `CREATE TABLE` e pelo menos 3 tipos de constraint
- [ ] Sei a diferença entre SERIAL e GENERATED ALWAYS AS IDENTITY
- [ ] Sei adicionar e remover coluna e constraint com `ALTER TABLE`
- [ ] Sei o que faz `DROP TABLE ... CASCADE` e quando evitar
- [ ] Sei criar um `SCHEMA` e qualificar tabela com `schema.tabela`

Próximo módulo: **DML — INSERT, UPDATE, DELETE** — agora que temos a forma, vamos por dado dentro.
