# Módulo 14 — Views e Materialized Views

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar e dropar **VIEWs** (consultas nomeadas que sempre executam ao vivo)
- Decidir quando uma view é **atualizável** (dá pra INSERT/UPDATE/DELETE através dela)
- Criar **MATERIALIZED VIEWs** (cache em disco do resultado da query)
- Atualizar MVs com `REFRESH MATERIALIZED VIEW` — incluindo `CONCURRENTLY`
- Indexar MV pra acelerar consultas em cima dela
- Saber escolher entre VIEW vs MV pro seu caso (dashboard, relatório, cache)

## 🪟 O que é uma VIEW
Uma **VIEW** é uma consulta SQL com nome. Tipo um "atalho": você escreve uma query complexa uma vez e referencia ela como se fosse uma tabela.

**Importante**: view **NÃO armazena dados**. Toda vez que você consulta `SELECT * FROM minha_view`, o Postgres executa a query original. Ela é só uma "máscara" em cima das tabelas reais.

Por que usar?
- **Simplificar consultas**: esconde JOINs e WHEREs complicados atrás de um nome amigável
- **Segurança**: dá pra liberar a view pro usuário sem dar acesso direto às tabelas (e mostrar só algumas colunas)
- **Reuso**: várias queries usam a mesma "visão" sem copiar-colar

### CREATE VIEW
```sql
CREATE VIEW produtos_caros AS
SELECT id, nome, preco
FROM produtos
WHERE preco > 1000;

-- Usa como tabela normal:
SELECT * FROM produtos_caros;
SELECT nome FROM produtos_caros WHERE preco < 5000;
```

### CREATE OR REPLACE VIEW
Quer mudar a definição? Se você só **adiciona colunas no fim** ou troca o cálculo, `CREATE OR REPLACE` resolve sem precisar dropar:

```sql
CREATE OR REPLACE VIEW produtos_caros AS
SELECT id, nome, preco, estoque
FROM produtos
WHERE preco > 1000;
```

Se mudar a ordem ou o tipo das colunas existentes, o Postgres reclama. Aí precisa `DROP VIEW` e criar de novo.

### DROP VIEW
```sql
DROP VIEW produtos_caros;
DROP VIEW IF EXISTS produtos_caros;  -- não erra se não existir
DROP VIEW produtos_caros CASCADE;    -- dropa também o que depende dela
```

## ✍️ Views atualizáveis (updatable)
Uma view é **automaticamente atualizável** (dá pra fazer `INSERT/UPDATE/DELETE` nela) se ela for **simples**:
- Vem de **uma única tabela** (sem JOIN)
- Sem `GROUP BY`, `DISTINCT`, `UNION`, agregados, window functions
- Colunas são referências diretas (não expressões tipo `preco * 1.1`)

```sql
-- Essa É atualizável:
CREATE VIEW estoque_baixo AS
SELECT id, nome, estoque FROM produtos WHERE estoque < 10;

UPDATE estoque_baixo SET estoque = 20 WHERE id = 5;  -- funciona!

-- Essa NÃO é (tem JOIN):
CREATE VIEW pedido_cliente AS
SELECT p.id, c.nome FROM pedidos p JOIN clientes c ON c.id = p.cliente_id;
-- UPDATE aqui dá erro.
```

Pra views complexas atualizáveis, você precisa de `INSTEAD OF` triggers (vamos ver no Módulo 18).

## 💾 MATERIALIZED VIEW
Agora a **diferença grande**. Uma **MATERIALIZED VIEW (MV)** **armazena o resultado** da query em disco — vira tipo uma "tabela cache". Quando você consulta, ela **não re-executa** a query: lê os dados gravados, como se fosse uma tabela normal.

| | VIEW | MATERIALIZED VIEW |
|---|---|---|
| Armazena dados? | Não | Sim, em disco |
| Velocidade de consulta | Igual a query original | Rápido (lê direto) |
| Dados sempre atuais? | Sim | Não, precisa REFRESH |
| Aceita índice? | Não | Sim |
| Espaço em disco | 0 | Tamanho do resultado |

Use MV quando a query é **cara** (agregação pesada, vários JOINs) e os dados **não precisam estar no segundo** — dashboard, relatório diário, ranking, cache de consulta.

### CREATE MATERIALIZED VIEW
```sql
CREATE MATERIALIZED VIEW vendas_por_mes AS
SELECT
    date_trunc('month', p.data_pedido) AS mes,
    SUM(i.quantidade * i.preco_unitario) AS total
FROM pedidos p
JOIN itens_pedido i ON i.pedido_id = p.id
WHERE p.status IN ('pago', 'enviado', 'entregue')
GROUP BY 1
ORDER BY 1;

-- Consulta como tabela:
SELECT * FROM vendas_por_mes;
```

A primeira consulta já vem rápida — o resultado está gravado.

### REFRESH MATERIALIZED VIEW
Como a MV é um cache, os dados **ficam velhos** conforme as tabelas-fonte mudam. Pra atualizar:

```sql
REFRESH MATERIALIZED VIEW vendas_por_mes;
```

Isso **bloqueia leituras** na MV durante o refresh (lock exclusivo). Em dashboard 24/7 isso atrapalha.

### REFRESH CONCURRENTLY
A versão "sem bloquear leitores":

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY vendas_por_mes;
```

Funciona, **mas exige um índice UNIQUE** na MV (qualquer coluna ou combinação que identifique cada linha unicamente). Sem o índice unique, o Postgres dá erro.

```sql
CREATE UNIQUE INDEX idx_vendas_mes_pk ON vendas_por_mes(mes);
-- Agora dá pra fazer CONCURRENTLY:
REFRESH MATERIALIZED VIEW CONCURRENTLY vendas_por_mes;
```

CONCURRENTLY é **mais lento** que o normal (faz diff entre versão velha e nova), mas leitores podem consultar enquanto roda. Vale pra produção.

### Índices em MV
MV aceita índices como qualquer tabela. Acelera filtros e ordenações em cima dela:

```sql
CREATE INDEX idx_vendas_total ON vendas_por_mes(total DESC);
```

### DROP MATERIALIZED VIEW
```sql
DROP MATERIALIZED VIEW vendas_por_mes;
DROP MATERIALIZED VIEW IF EXISTS vendas_por_mes;
```

## 🤔 VIEW ou MATERIALIZED VIEW?
| Cenário | Escolha |
|---|---|
| Query simples, simplificar acesso | VIEW |
| Dado precisa estar **sempre atual** | VIEW |
| Esconder colunas sensíveis | VIEW |
| Query cara, consulta muito | MATERIALIZED VIEW |
| Dashboard / relatório | MATERIALIZED VIEW |
| Cache de top-N, ranking | MATERIALIZED VIEW |
| Tabela-fonte muda toda hora e você precisa do dado no segundo | VIEW (ou tabela normal) |

## 💡 Dicas de quem usa view/MV na prática
- Nome de MV com prefixo `mv_` ajuda a identificar (`mv_vendas_mes`, `mv_top_produtos`)
- Pra MV de dashboard, agende o `REFRESH` em **cron / pg_cron** (a cada hora, 15min, etc.)
- **Sempre crie índice UNIQUE** na MV se for usar CONCURRENTLY — vale o esforço
- View encadeada (view em cima de view) funciona, mas dificulta otimização — o planner às vezes não consegue empurrar filtros direito
- MV não tem transação automática com as tabelas-fonte: se a tabela mudou, a MV continua antiga até dar REFRESH
- Pra ver MVs existentes no banco: `\dm` no psql

## 🚦 Próximos passos
1. Rode o setup do Módulo 1 (schema + seed)
2. Abra `pratica/queries.sql` e crie views e MVs
3. Faça o `desafio`: monte o **Dashboard de Vendas** completo
4. Vá pro Módulo 15 — Transações e ACID

## ✅ Auto-verificação
- [ ] Sei a diferença entre VIEW e MATERIALIZED VIEW
- [ ] Sei quando uma view é updatable
- [ ] Sei criar, alterar (REPLACE) e dropar view
- [ ] Sei rodar REFRESH normal e CONCURRENTLY
- [ ] Entendi por que CONCURRENTLY exige índice UNIQUE
- [ ] Consigo decidir qual usar pro meu caso

Próximo módulo: **Transações e ACID** — BEGIN, COMMIT, ROLLBACK, isolamento.
