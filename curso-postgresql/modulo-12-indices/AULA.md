# Módulo 12 — Índices

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é um índice e por que ele acelera leitura
- Criar e remover índices com `CREATE INDEX` / `DROP INDEX`
- Escolher o **tipo certo** de índice (B-tree, Hash, GIN, GiST, BRIN)
- Usar **partial**, **expression**, **multi-column** e **covering** indexes
- Pesar o trade-off: índice acelera leitura, mas custa em escrita e espaço

## 🧠 O que é um índice?
Imagina um livro de 800 páginas sem sumário. Pra achar o capítulo "Cap. 7 — Postgres", você vai folha por folha. É o **sequential scan**: ler tudo até achar.

O índice é o sumário. Ele guarda, **separado da tabela**, uma estrutura ordenada com o valor da coluna apontando pra "página" (na verdade, pro `ctid` = endereço físico da linha). Aí o Postgres pula direto.

A estrutura padrão é uma **B-tree** (árvore balanceada): boa pra `=`, `<`, `>`, `BETWEEN`, `ORDER BY`. Funciona em quase tudo.

```
Sem índice:  SELECT * FROM produtos WHERE id = 9999;
             → varre os 100.000 produtos

Com índice:  mesma query
             → desce a árvore B-tree em ~3 saltos, acha o ctid, lê 1 página
```

## 🔧 CREATE INDEX e DROP INDEX
```sql
-- Criar
CREATE INDEX idx_produtos_categoria ON produtos (categoria_id);

-- Remover
DROP INDEX idx_produtos_categoria;

-- Em produção: cria sem travar a tabela (lento, mas não bloqueia escrita)
CREATE INDEX CONCURRENTLY idx_produtos_categoria ON produtos (categoria_id);
```

**Convenção** de nome: `idx_<tabela>_<coluna(s)>`. Não é obrigatório, mas ajuda a vida.

## 🆓 Índices que o Postgres cria sozinho
Você **não precisa** criar índice em:
- **Primary key** — vem com um índice B-tree único automático
- **UNIQUE** — também vem com índice automático (é assim que ele garante unicidade)

Foreign keys, **não**. Postgres não cria índice automático em FK — e isso é uma pegadinha clássica. Se você faz JOIN frequente por `cliente_id`, precisa criar o índice na mão.

## 🌳 Tipos de índice

### B-tree (padrão)
Serve pra 95% dos casos. Suporta `=`, `<`, `<=`, `>`, `>=`, `BETWEEN`, `IN`, `IS NULL`, `ORDER BY`, `LIKE 'prefixo%'`.
```sql
CREATE INDEX idx_produtos_preco ON produtos (preco);
```

### Hash
Só `=`. Antes não era crash-safe, agora é (PG 10+). Na prática, B-tree é quase sempre tão bom quanto, então **raramente** vale usar Hash.
```sql
CREATE INDEX idx_clientes_email_hash ON clientes USING HASH (email);
```

### GIN (Generalized Inverted Index)
Pra dados onde uma linha tem **vários valores**: arrays, `jsonb`, full-text search (`tsvector`), `pg_trgm` (busca por substring).
```sql
CREATE INDEX idx_produtos_tags ON produtos USING GIN (tags);
-- agora "WHERE tags @> ARRAY['promo']" voa
```

### GiST (Generalized Search Tree)
Pra **geometria** (PostGIS), **ranges** (`tsrange`, `int4range`), e busca por proximidade. Mais flexível que B-tree, paga em performance.
```sql
CREATE INDEX idx_evento_periodo ON eventos USING GIST (periodo);
```

### BRIN (Block Range INdex)
Para tabelas **gigantes** (>10M linhas) onde os dados estão **fisicamente ordenados** (ex.: `criado_em` de log que só faz INSERT). Guarda min/max por bloco de páginas — índice **minúsculo**, scan mais lento que B-tree, mas em tabela enorme ainda compensa.
```sql
CREATE INDEX idx_logs_data_brin ON logs USING BRIN (criado_em);
```

## 🎯 Partial index
Indexa **só uma parte** da tabela. Menor, mais rápido, e o planner usa quando a query bate com a condição.
```sql
-- Maioria dos pedidos é histórico fechado. Só nos interessa indexar ativos.
CREATE INDEX idx_pedidos_ativos ON pedidos (cliente_id)
WHERE status IN ('pendente', 'pago');
```
Pra usar: a query precisa ter a **mesma condição** ou uma mais restritiva.

## 🧮 Expression index
Indexa o **resultado de uma expressão**. Clássico: busca case-insensitive.
```sql
-- Se você sempre busca: WHERE lower(email) = 'foo@bar.com'
CREATE INDEX idx_clientes_email_lower ON clientes (lower(email));
```
Sem isso, o B-tree comum em `email` **não serve**, porque `lower(email)` é outra função.

## 🪜 Multi-column — ordem importa
```sql
CREATE INDEX idx_pedidos_cliente_data ON pedidos (cliente_id, data_pedido);
```
Esse índice serve pra:
- `WHERE cliente_id = 7` ✅
- `WHERE cliente_id = 7 AND data_pedido > '2026-01-01'` ✅
- `WHERE data_pedido > '2026-01-01'` ❌ (pula o primeiro campo, não usa)

**Regra**: o índice serve da esquerda pra direita. Coloque primeiro o campo de **maior seletividade** (que filtra mais).

## 📦 Covering index (INCLUDE — PG 11+)
Inclui colunas extras no índice **só pra leitura**, evitando ir na tabela (index-only scan).
```sql
CREATE INDEX idx_produtos_categoria_inc
ON produtos (categoria_id)
INCLUDE (nome, preco);

-- Agora isso é resolvido só com o índice:
SELECT nome, preco FROM produtos WHERE categoria_id = 3;
```

## ⚖️ O trade-off
Cada índice:
- ✅ **Acelera SELECT** (e UPDATE/DELETE com WHERE que bate no índice)
- ❌ **Desacelera INSERT, UPDATE e DELETE** (precisa atualizar o índice também)
- ❌ **Ocupa disco** (às vezes mais que a tabela original)
- ❌ **Precisa de manutenção** (VACUUM, REINDEX, autoanalyze)

Regra de ouro: **não indexe tudo**. Indexe o que aparece no `WHERE`, `JOIN` ou `ORDER BY` de queries lentas e frequentes. Meça com `EXPLAIN ANALYZE` antes e depois (próximo módulo).

## 🔍 Inspecionando índices
```sql
-- Listar índices de uma tabela
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'produtos';

-- Tamanho do índice
SELECT pg_size_pretty(pg_relation_size('idx_produtos_categoria'));

-- Índices nunca usados (candidatos a DROP)
SELECT schemaname, relname, indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

## 💡 Dicas de quem programa Postgres há tempo
- **FK sem índice = dor de cabeça**. Sempre indexe a coluna FK se você faz JOIN ou DELETE no pai.
- **`LIKE '%foo%'`** (com `%` no início) **não usa B-tree**. Use GIN + `pg_trgm`.
- **Multi-column > vários single-column** quando você sempre filtra pelos dois juntos.
- **Partial index** é arma secreta pra reduzir tamanho e bater rápido em hot path.
- **Não esqueça do `VACUUM`/`ANALYZE`**: o planner usa estatísticas pra decidir se usa o índice. Sem stats atualizada, ele chuta errado.
- **`EXPLAIN (ANALYZE, BUFFERS)`** é o seu termômetro. Veremos no Módulo 13.

## 🚦 Próximos passos
1. Rode `pratica/queries.sql` e veja índices nascerem
2. Encare o `desafio`: uma query lenta, sua missão é indexar certo
3. Vá pro Módulo 13 — **EXPLAIN** e leitura de plano de execução

## ✅ Auto-verificação
- [ ] Sei criar e remover índice B-tree
- [ ] Conheço quando usar GIN, GiST e BRIN
- [ ] Sei o que é partial e expression index
- [ ] Entendo por que ordem importa em multi-column
- [ ] Sei consultar `pg_indexes` e `pg_stat_user_indexes`

Próximo módulo: **EXPLAIN** — lendo o plano de execução pra entender o que o Postgres faz.
