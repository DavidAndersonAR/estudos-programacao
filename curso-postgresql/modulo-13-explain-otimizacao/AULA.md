# Módulo 13 — EXPLAIN e Otimização

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Ler o **plano de execução** que o Postgres montou pra sua query
- Diferenciar `EXPLAIN` (estimado) de `EXPLAIN ANALYZE` (real)
- Identificar **gargalos**: Seq Scan grande, estimativa errada, join ruim
- Saber **quando criar índice**, **quando rodar `ANALYZE`** e quando rodar `VACUUM`
- Achar as queries mais lentas do banco com `pg_stat_statements`

## 🧠 O que é o plano de execução?
Quando você manda um `SELECT`, o Postgres não executa "linha por linha do SQL". Ele:

1. **Parser** — entende o SQL
2. **Planner** — decide *como* buscar os dados (usar índice? fazer hash join? ordenar antes ou depois?)
3. **Executor** — executa o plano escolhido

O **planner** olha estatísticas (`pg_statistic`) e estima qual caminho é o mais barato. `EXPLAIN` te mostra esse plano. Se o plano é ruim → query lenta. Se as estatísticas estão desatualizadas → plano errado.

## 🔎 EXPLAIN — só o plano (sem executar)
```sql
EXPLAIN SELECT * FROM produtos WHERE preco > 100;
```

Saída típica:
```
Seq Scan on produtos  (cost=0.00..18.00 rows=300 width=68)
  Filter: (preco > 100::numeric)
```

Como ler:
- **Seq Scan** = leu a tabela inteira (sequencial)
- **cost=0.00..18.00** = `startup_cost..total_cost` em "unidades arbitrárias" (~ I/O + CPU). Não é ms, é uma métrica relativa pra comparar planos.
- **rows=300** = quantas linhas o planner *acha* que vão sair
- **width=68** = tamanho médio da linha em bytes

`EXPLAIN` **não executa** a query — é rápido e seguro até em produção.

## ⏱️ EXPLAIN ANALYZE — executa de verdade
```sql
EXPLAIN ANALYZE SELECT * FROM produtos WHERE preco > 100;
```

Agora aparece também:
```
Seq Scan on produtos  (cost=0.00..18.00 rows=300 width=68)
                      (actual time=0.012..0.250 rows=287 loops=1)
Planning Time: 0.080 ms
Execution Time: 0.310 ms
```

- **actual time=0.012..0.250** = tempo real em **ms** (startup..total por loop)
- **rows=287** = linhas reais que saíram
- **loops=1** = quantas vezes o nó foi executado (em joins pode ser N)
- **Planning Time** vs **Execution Time** — se planning > execution e a query é simples, o problema é o planner

> ⚠️ `EXPLAIN ANALYZE` **roda a query**. Em `UPDATE`/`DELETE`/`INSERT`, embrulhe em transação:
> ```sql
> BEGIN;
> EXPLAIN ANALYZE UPDATE produtos SET preco = preco * 1.1;
> ROLLBACK;
> ```

## 🧰 EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
A versão "raio-x":

```sql
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM produtos WHERE categoria_id = 3;
```

Opções dentro do parêntese:
| Opção | O que adiciona |
|---|---|
| `ANALYZE` | executa e mede tempo real |
| `BUFFERS` | mostra leituras de cache (`shared hit`) vs disco (`read`) |
| `VERBOSE` | mostra colunas de saída, schema, alias |
| `SETTINGS` | mostra parâmetros não-default que afetaram o plano |
| `WAL` | linhas escritas no WAL (pra UPDATE/INSERT) |
| `FORMAT JSON\|YAML\|XML\|TEXT` | muda o formato de saída |

**BUFFERS** é o pulo do gato pra diagnosticar I/O:
```
Buffers: shared hit=120 read=8
```
- `shared hit` = leu do **cache do Postgres** (rápido)
- `read` = leu do **disco** (lento — culpado quando query "demora do nada")

## 🪜 Lendo o plano — os principais nós

### Scans (como ler a tabela)
| Nó | Quando aparece | Bom ou ruim? |
|---|---|---|
| **Seq Scan** | lê tudo, sem índice | Ruim em tabela grande, OK em tabela pequena ou quando devolve >10% das linhas |
| **Index Scan** | usa índice e busca linhas no heap | Bom quando filtro retorna poucas linhas |
| **Index Only Scan** | resposta saiu só do índice (não tocou no heap) | Ótimo — exige índice cobrindo todas as colunas usadas |
| **Bitmap Heap Scan** | combina vários índices ou faz range grande | Bom pra range / `IN` médio |
| **Tid Scan** | acesso direto por `ctid` | Raro |

### Joins
| Nó | Estratégia | Quando o planner escolhe |
|---|---|---|
| **Nested Loop** | pra cada linha de A, busca em B | Tabelas pequenas, ou B com índice no campo do join |
| **Hash Join** | constrói hash de uma tabela, varre a outra | Tabelas médias/grandes, junta por igualdade |
| **Merge Join** | junta duas listas já ordenadas | Quando ambas vêm ordenadas (ex: dois Index Scans) |

### Outros nós úteis
- **Sort** — ordenou (custa caro se não couber em memória → "external merge Disk")
- **Hash** — construiu uma hash table
- **Gather / Gather Merge** — paralelizou em vários workers
- **Materialize** — gravou resultado intermediário em memória
- **Limit** — corta cedo (e às vezes muda completamente o plano)

## 🚨 Identificando gargalos
Como caçar problema no plano:

### 1. Estimativa muito errada
```
rows=10 ... actual rows=10000
```
Se `actual` é **muito maior** que `rows` estimado → estatística velha. Rode:
```sql
ANALYZE produtos;
```

### 2. Seq Scan em tabela grande com filtro seletivo
```
Seq Scan on pedidos  (rows=1)  actual rows=1
Filter: cliente_id = 42
Rows Removed by Filter: 999999
```
"Removed 999999" = leu tudo pra achar 1 linha → falta índice em `cliente_id`.

### 3. Nested Loop com `loops` enorme
```
->  Nested Loop  (actual time=0.05..15000 rows=100)
    ->  Seq Scan on a (rows=10000)
    ->  Index Scan on b (loops=10000)
```
10k loops vezes algo é caro. Talvez `Hash Join` fosse melhor — verifique se há índice ou se `work_mem` está apertado.

### 4. Sort gigante "external merge Disk"
```
Sort Method: external merge  Disk: 200000kB
```
Não coube em RAM → ordenou em disco. Aumente `work_mem` na sessão:
```sql
SET work_mem = '64MB';
```

### 5. `Buffers: read` alto
Cache frio. Roda a query 2 vezes e compara: se a 2ª vez é muito mais rápida, é só cache. Se continua lento, é plano.

## 🛠️ Comandos auxiliares

### `ANALYZE` — atualiza estatísticas
```sql
ANALYZE;                 -- todas as tabelas
ANALYZE produtos;        -- só uma
ANALYZE produtos (preco); -- só uma coluna
```
Rode após carregar muitos dados, `COPY`, migrations, ou quando o plano "do nada" piorar.

### `VACUUM` — limpa linhas mortas (MVCC)
```sql
VACUUM produtos;          -- limpeza normal (não trava)
VACUUM ANALYZE produtos;  -- limpa + atualiza estatísticas
VACUUM FULL produtos;     -- reescreve a tabela (TRAVA — só em manutenção!)
```
O **autovacuum** já roda automático em produção. Você só chama na mão em casos especiais.

### `pg_stat_statements` — quais queries são as mais lentas
Extensão que registra todas as queries (normalizadas) com tempo total, médio, número de chamadas. Instala uma vez:
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- E em postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
```
Top 10 mais lentas:
```sql
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

### `pg_stat_user_tables` — saúde da tabela
```sql
SELECT relname, seq_scan, idx_scan, n_live_tup, n_dead_tup,
       last_vacuum, last_analyze
FROM pg_stat_user_tables;
```
- `seq_scan` alto vs `idx_scan` baixo → falta índice?
- `n_dead_tup` alto → vacuum atrasado
- `last_analyze` muito velho → estatísticas defasadas

## 📐 Formato JSON
Pra parsing programático ou pra colar em ferramenta visual:
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM pedidos WHERE cliente_id = 1;
```

## 🌐 Sites que salvam a vida
- **[explain.depesz.com](https://explain.depesz.com)** — cola o output do EXPLAIN e ele pinta de vermelho onde dói. Bom pra começar.
- **[explain.dalibo.com](https://explain.dalibo.com)** — visualização em árvore, ótima pra planos complexos. Aceita JSON.
- **[pgmustard.com](https://www.pgmustard.com)** — análise automática com recomendações (pago, mas tem free trial).

## 💡 Receitas do dia a dia
- **Sempre meça antes de otimizar.** Sem `EXPLAIN ANALYZE`, você está chutando.
- **Não crie índice "por garantia"**. Cada índice deixa `INSERT`/`UPDATE` mais lento e ocupa disco.
- **Rode `ANALYZE` depois de carga de dados grande** ou após mudar muita coisa.
- **Cuidado com `EXPLAIN ANALYZE` em produção** — ele executa de verdade.
- **Compare 2x ou 3x** — a primeira execução pode ser só cache frio.
- **Olhe `actual rows` vs `rows`** primeiro — é a pista mais valiosa.

## 🚦 Próximos passos
1. Leia a aula
2. Abra `pratica/queries.sql` — 8 queries pra praticar leitura de planos
3. Faça o `desafio/queries.sql` — 5 queries lentas pra diagnosticar e otimizar
4. Vá pro Módulo 14 — Triggers e Procedures

## ✅ Auto-verificação
- [ ] Sei diferença entre `EXPLAIN` e `EXPLAIN ANALYZE`
- [ ] Consigo identificar Seq Scan, Index Scan, Hash Join no output
- [ ] Sei o que `cost`, `rows` e `actual time` significam
- [ ] Sei quando rodar `ANALYZE` e quando rodar `VACUUM`
- [ ] Já criei um índice e vi o plano mudar de Seq Scan pra Index Scan

Próximo módulo: **Triggers e Procedures** — automatizando regras no banco.
