# Módulo 19 — Particionamento

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender quando (e quando NÃO) particionar uma tabela
- Criar tabelas particionadas por **RANGE**, **LIST** e **HASH**
- Visualizar o **partition pruning** no `EXPLAIN`
- Criar índices que funcionam em todas as partições
- Anexar (`ATTACH`) e desanexar (`DETACH`) partições sem dor

## 🤔 Por que particionar?
Imagine uma tabela `pedidos` que cresceu 5 anos sem parar. Hoje tem 800 milhões de linhas, ocupa 600 GB. Tudo fica lento:

- Um `SELECT` por data varre o índice gigante.
- `VACUUM` demora horas.
- Backup do "ano passado" exige dump da tabela inteira.
- Reindexar é um evento.

Particionar é **quebrar uma tabela em pedaços** que o Postgres trata como uma só do lado da aplicação, mas internamente são tabelas separadas.

Ganhos principais:
1. **Performance**: query com filtro na coluna de partição lê só a partição certa (**partition pruning**).
2. **Manutenção**: `VACUUM`/`REINDEX` por partição, não pela tabela toda.
3. **Arquivo morto**: dropar dados antigos = `DROP TABLE pedidos_2020` em milissegundos, sem `DELETE` que gera bloat.
4. **Bulk load**: carregar uma partição nova e fazer `ATTACH` é mais rápido do que inserir linha a linha.

Quando **não** particionar: tabela com 1 milhão de linhas. Particionamento tem overhead (planner mais complicado, FKs trabalhosas). Regra de bolso: pense em particionar a partir de **dezenas de milhões de linhas** ou quando uma dimensão de tempo/categoria domina as queries.

## 🧩 Declarative Partitioning (Postgres 10+)
Antes do Postgres 10 você fazia particionamento por herança (`INHERITS`) + triggers — chato e propenso a erro. Desde a versão 10 existe sintaxe declarativa nativa, que é o padrão moderno.

A ideia:
1. Cria-se uma **tabela pai** com `PARTITION BY <estratégia> (<coluna>)`. Ela não armazena nada.
2. Criam-se **partições filhas** com `PARTITION OF pai FOR VALUES ...`.
3. INSERT/SELECT/UPDATE/DELETE são feitos na tabela pai — o Postgres roteia.

## 📐 Tipos de particionamento

### RANGE — intervalos
Para datas e números contínuos. Cada partição é um intervalo `[início, fim)` (inclui início, exclui fim).

```sql
CREATE TABLE vendas (
    id SERIAL,
    data DATE NOT NULL,
    valor NUMERIC
) PARTITION BY RANGE (data);

CREATE TABLE vendas_2025_01 PARTITION OF vendas
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

Caso clássico: pedidos por mês, logs por dia, métricas por ano.

### LIST — valores discretos
Para conjuntos finitos: estado (UF), país, tipo, status.

```sql
CREATE TABLE clientes (
    id SERIAL,
    nome TEXT,
    estado CHAR(2) NOT NULL
) PARTITION BY LIST (estado);

CREATE TABLE clientes_sp PARTITION OF clientes FOR VALUES IN ('SP');
CREATE TABLE clientes_rj PARTITION OF clientes FOR VALUES IN ('RJ');
CREATE TABLE clientes_sul PARTITION OF clientes FOR VALUES IN ('PR', 'SC', 'RS');
```

### HASH — distribuição uniforme
Quando você só quer dividir o volume igualmente, sem padrão lógico (datas, regiões). Útil pra paralelismo, sharding lógico.

```sql
CREATE TABLE eventos (
    id BIGINT NOT NULL,
    payload JSONB
) PARTITION BY HASH (id);

CREATE TABLE eventos_p0 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE eventos_p1 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE eventos_p2 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE eventos_p3 PARTITION OF eventos FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

Não dá pra fazer pruning por intervalo aqui — só por igualdade no campo do hash.

## ✂️ Partition Pruning
É o ouro do particionamento. Quando você filtra pela coluna de partição, o planner descarta partições inteiras antes de executar:

```sql
EXPLAIN SELECT * FROM vendas WHERE data >= '2025-02-01' AND data < '2025-03-01';
```

O `EXPLAIN` mostra **só** a partição `vendas_2025_02`. As outras nem são abertas. Isso é o que faz a tabela de 800M linhas se comportar como uma de 20M.

Se o filtro **não** usa a coluna de partição (`WHERE valor > 1000`), o planner lê todas as partições — sem pruning. Por isso a escolha da coluna importa: tem que casar com o padrão de consulta.

## 🔑 Índices em tabela particionada
Você define o índice na tabela pai e o Postgres cria automaticamente em cada partição:

```sql
CREATE INDEX ON vendas (data);
CREATE INDEX ON vendas (valor);
```

Cada partição ganha seu próprio índice — menor, mais rápido de manter.

**Pegadinha da PRIMARY KEY**: o Postgres exige que toda chave única (PK ou `UNIQUE`) inclua a coluna de partição. Não dá pra ter `PRIMARY KEY (id)` numa tabela particionada por `data` — tem que ser `PRIMARY KEY (id, data)`. Faz sentido: o Postgres não consegue garantir unicidade global entre partições sem isso.

## 🪣 DEFAULT partition
E se chegar um valor que não cabe em nenhuma partição definida? Sem `DEFAULT`, o INSERT falha:

```
ERROR: no partition of relation "vendas" found for row
```

A partição `DEFAULT` é a "lixeira" que pega qualquer coisa fora do range/list:

```sql
CREATE TABLE vendas_default PARTITION OF vendas DEFAULT;
```

Útil pra não derrubar o INSERT, mas **não confie nela em produção**: dados ficam misturados, sem pruning útil. Trate como sinal de que falta criar a partição certa.

## 🔧 Manutenção: ATTACH / DETACH
Adicionar uma partição nova:

```sql
CREATE TABLE vendas_2025_04 PARTITION OF vendas
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
```

Ou criar separada e anexar depois (útil pra bulk load):

```sql
CREATE TABLE vendas_2025_04 (LIKE vendas INCLUDING ALL);
-- carrega dados...
ALTER TABLE vendas ATTACH PARTITION vendas_2025_04
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
```

Arquivar dados antigos:

```sql
ALTER TABLE vendas DETACH PARTITION vendas_2024_01;
-- agora vendas_2024_01 é uma tabela "solta", pode mover, arquivar, dropar
DROP TABLE vendas_2024_01;
```

Isso é **instantâneo**, sem `DELETE` nem bloat. É o motivo principal de gente particionar por data.

## 🤖 pg_partman (visão geral)
Criar partição todo mês na mão é trabalho repetitivo. A extensão **pg_partman** automatiza:

- Cria partições futuras automaticamente (configurado via cron/scheduler).
- Faz `DETACH` ou `DROP` de partições antigas conforme política de retenção.
- Suporta sub-particionamento.

```sql
CREATE EXTENSION pg_partman;
SELECT partman.create_parent('public.vendas', 'data', 'native', 'monthly');
```

Não vamos instalar agora — só saber que existe. Em produção séria com particionamento por tempo, **use pg_partman**, não scripts caseiros.

## 💡 Dicas de quem já apanhou
- **Particione cedo**: migrar tabela de 500 GB pra particionada é um projeto. Se você já sabe que vai crescer, comece particionado.
- **Coluna de partição é estratégica**: tem que casar com 80%+ das queries. Errou aqui, perdeu o pruning.
- **PK precisa incluir a coluna de partição**. Acostume.
- **FKs apontando pra tabela particionada**: funciona desde a 12, mas teste.
- **Cuidado com `UPDATE` na coluna de partição**: o Postgres move a linha de partição (lento). Evite mudar a coluna.
- **Tem que criar partições futuras com antecedência**: chegou janeiro e não criou `vendas_2025_01`? INSERT quebra (ou cai no DEFAULT, que é pior). Automatize.

## 🚦 Próximos passos
1. Rode os exercícios em `pratica/queries.sql`
2. Faça o `desafio`: particionar a tabela `pedidos` por mês
3. Vá pro Módulo 20 — fechamento do curso

## ✅ Auto-verificação
- [ ] Sei diferenciar RANGE, LIST e HASH
- [ ] Sei o que é partition pruning e como vê-lo no EXPLAIN
- [ ] Lembro que a PK precisa incluir a coluna de partição
- [ ] Sei usar ATTACH / DETACH e pra que serve cada um
- [ ] Sei o que é a DEFAULT partition (e por que não confiar nela)

Próximo módulo: **Encerramento e próximos passos** — pra onde ir depois do curso.
