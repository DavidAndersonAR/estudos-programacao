# Curso de PostgreSQL — do Básico ao Avançado

> Mesmo padrão dos outros cursos. 20 módulos progressivos, do primeiro `SELECT` até administração e tuning. Tema do banco de exemplo: **e-commerce** (clientes, produtos, pedidos, categorias).

## Como rodar PostgreSQL

Você já tem **Docker** instalado, então é só rodar:

```bash
# Subir Postgres num container (porta 5432, senha postgres):
docker run -d --name pg-curso \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=loja \
  -p 5432:5432 \
  postgres:16

# Entrar no psql interativo:
docker exec -it pg-curso psql -U postgres -d loja
```

Sair do psql: `\q`. Parar o container: `docker stop pg-curso`. Reiniciar: `docker start pg-curso`. Remover (perde dados): `docker rm pg-curso`.

### Carregar o schema e dados iniciais
Cada módulo assume que existe um banco `loja` com o schema do **Módulo 01**:

```bash
# Copiar o schema pra dentro do container
docker cp curso-postgresql/modulo-01-bem-vindo-setup/pratica/schema.sql pg-curso:/tmp/
docker cp curso-postgresql/modulo-01-bem-vindo-setup/pratica/seed.sql pg-curso:/tmp/

# Rodar
docker exec -it pg-curso psql -U postgres -d loja -f /tmp/schema.sql
docker exec -it pg-curso psql -U postgres -d loja -f /tmp/seed.sql
```

Pronto. Daí em diante é só conectar e rodar os exercícios.

### Cliente gráfico (opcional, mas recomendado)
- **DBeaver** — gratuito, multi-DB, ótimo para visualizar resultados
- **pgAdmin 4** — oficial do Postgres
- **TablePlus** — bonito, grátis pra uso básico

Conexão: host `localhost`, porta `5432`, usuário `postgres`, senha `postgres`, banco `loja`.

## Estrutura

Cada módulo tem:
1. **AULA.md** — teoria com exemplos comentados
2. **pratica/queries.sql** — consultas resolvidas para você estudar e executar
3. **desafio/queries.sql** — miniprojeto: tarefas a resolver + solução comentada no fim

## Ementa

### Fase 1 — Fundamentos
- **01 — Bem-vindo + Setup** — Docker, psql, schema da loja, primeiro SELECT. 🎯 *Subir banco e contar registros*
- **02 — SELECT básico** — FROM, WHERE, ORDER BY, LIMIT, OFFSET, DISTINCT, AS. 🎯 *Top 10 produtos mais caros*
- **03 — Tipos de Dados** — numeric, text, varchar, date/time, boolean, UUID, ENUM, arrays. 🎯 *Validador de dados de cadastro*
- **04 — Criando Tabelas** — CREATE, NOT NULL, UNIQUE, CHECK, DEFAULT, SERIAL/IDENTITY, PRIMARY KEY. 🎯 *Modelar tabelas auxiliares*
- **05 — INSERT, UPDATE, DELETE** — DML, RETURNING, UPSERT (ON CONFLICT), TRUNCATE. 🎯 *CRUD de produtos*

### Fase 2 — Consultas
- **06 — Operadores e Funções** — LIKE, ILIKE, IN, BETWEEN, COALESCE, NULLIF, funções de string/data/número. 🎯 *Relatório formatado de pedidos*
- **07 — GROUP BY e Agregações** — COUNT, SUM, AVG, MIN, MAX, HAVING, FILTER, GROUP BY ROLLUP/CUBE. 🎯 *Estatísticas de vendas*
- **08 — JOINs** — INNER, LEFT, RIGHT, FULL, CROSS, SELF, USING. 🎯 *Relatório com produtos + categorias + clientes*
- **09 — Subqueries** — escalares, IN, EXISTS, ANY/ALL, LATERAL. 🎯 *Clientes acima da média*
- **10 — CTEs + Window Functions** — WITH, WITH RECURSIVE, ROW_NUMBER, RANK, LAG, LEAD, partições. 🎯 *Ranking de produtos por categoria*

### Fase 3 — Estrutura e Performance
- **11 — Foreign Keys e Relacionamentos** — FK, ON DELETE CASCADE/SET NULL, integridade referencial. 🎯 *Refatorar schema com integridade*
- **12 — Índices** — B-tree, hash, GIN, GiST, BRIN, parciais, expressão, multi-coluna. 🎯 *Indexar uma query lenta*
- **13 — EXPLAIN e Otimização** — EXPLAIN, EXPLAIN ANALYZE, leitura do plano, custo, BUFFERS. 🎯 *Diagnosticar queries lentas*
- **14 — Views e Materialized Views** — VIEW, MATERIALIZED VIEW, REFRESH. 🎯 *Dashboard de vendas com MV*
- **15 — Transações e ACID** — BEGIN/COMMIT/ROLLBACK, savepoints, níveis de isolamento, MVCC, deadlock. 🎯 *Transferência entre saldos com transação*

### Fase 4 — Avançado
- **16 — JSON e JSONB** — operadores `->`, `->>`, `@>`, jsonb_path_query, indexação GIN. 🎯 *Catálogo flexível com JSONB*
- **17 — PL/pgSQL: Funções e Procedures** — CREATE FUNCTION, PROCEDURE, parâmetros, RETURN, controle de fluxo. 🎯 *Função de cálculo de frete*
- **18 — Triggers** — BEFORE/AFTER, INSERT/UPDATE/DELETE, FOR EACH ROW, NEW/OLD. 🎯 *Auditoria automática de pedidos*
- **19 — Particionamento** — RANGE, LIST, HASH partition; tabelas grandes; performance. 🎯 *Particionar tabela de pedidos por mês*
- **20 — Administração: Backup, Roles, Replicação** — pg_dump, pg_restore, roles/grants, REPLICATION (visão geral). 🎯 *Backup e restore de produção*

## Pré-requisitos
- **Docker** (você já tem 29.4 ✅) — ou Postgres 14+ instalado localmente
- Editor de sua preferência (VS Code com extensão SQLTools facilita)
- Vontade de digitar `SELECT` várias vezes

## Material de apoio
- Documentação oficial: https://www.postgresql.org/docs/current/
- PostgreSQL Tutorial: https://www.postgresqltutorial.com
- Use the Index, Luke (sobre índices): https://use-the-index-luke.com
- Explain.depesz.com (visualizador de EXPLAIN)

Bom estudo!
