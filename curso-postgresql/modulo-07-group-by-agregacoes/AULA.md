# Módulo 07 — GROUP BY e Agregações

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Usar as funções de agregação clássicas: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- Entender a diferença entre `COUNT(*)` e `COUNT(coluna)` (e por que ela existe)
- Agrupar dados com `GROUP BY` — uma e múltiplas colunas
- Filtrar grupos com `HAVING` (e não confundir com `WHERE`)
- Fazer agregação condicional moderna com `FILTER (WHERE ...)`
- Concatenar valores agrupados com `string_agg` e `array_agg`
- Montar relatórios multi-nível com `GROUPING SETS`, `ROLLUP` e `CUBE`
- Não cair nas armadilhas de `NULL` em agregação

E no miniprojeto: gerar **Estatísticas de Vendas** da loja.

## 🧠 Por que agregação existe?
Até agora você selecionou linhas. Agora você vai **resumir** linhas. "Quantos produtos eu tenho?", "Qual o ticket médio?", "Quanto vendi por mês?" — tudo isso é colapsar várias linhas em **uma resposta** (ou em uma resposta por grupo).

A regra mental: agregação **come linhas e cospe número** (ou texto, ou array). É a mesma ideia do `Sum`, `Avg`, `Min`, `Max` que você já viu em planilha.

## 🔢 As cinco funções básicas

| Função | O que faz | Ignora NULL? |
|---|---|---|
| `COUNT(*)` | conta linhas | não — conta tudo |
| `COUNT(coluna)` | conta linhas onde `coluna IS NOT NULL` | sim |
| `COUNT(DISTINCT coluna)` | conta valores distintos não-nulos | sim |
| `SUM(coluna)` | soma | sim (NULL é tratado como "nada") |
| `AVG(coluna)` | média aritmética | sim (NULL não entra nem no numerador nem no denominador) |
| `MIN(coluna)` | menor valor | sim |
| `MAX(coluna)` | maior valor | sim |

```sql
-- Quantos produtos eu cadastrei?
SELECT count(*) FROM produtos;

-- Quantos produtos têm categoria definida?
SELECT count(categoria_id) FROM produtos;

-- Quantas categorias diferentes aparecem nos produtos?
SELECT count(DISTINCT categoria_id) FROM produtos;

-- Estatística rápida da tabela inteira
SELECT
    count(*)   AS total,
    avg(preco) AS preco_medio,
    min(preco) AS mais_barato,
    max(preco) AS mais_caro,
    sum(estoque) AS estoque_total
FROM produtos;
```

### ⚠️ A pegadinha do COUNT
`count(*)` conta **linhas**. `count(coluna)` conta valores **não nulos** daquela coluna. Em uma tabela com 100 linhas onde `categoria_id` está NULL em 10 produtos:
- `count(*)` → 100
- `count(categoria_id)` → 90

Pegadinha de entrevista. Memoriza.

## 🧺 GROUP BY — agrupando antes de agregar
`GROUP BY` separa as linhas em **caixas** segundo o valor de uma (ou mais) colunas. Depois, a função de agregação roda **dentro de cada caixa**.

```sql
-- Quantos produtos em cada categoria?
SELECT categoria_id, count(*) AS qtd
FROM produtos
GROUP BY categoria_id;
```

Resultado: uma linha por `categoria_id`. Se você tem 5 categorias, vêm 5 linhas.

### Múltiplas colunas no GROUP BY
Pode agrupar por mais de uma coluna. A "caixa" passa a ser a **combinação** dos valores.

```sql
-- Quantos clientes por (estado, cidade)?
SELECT estado, cidade, count(*) AS qtd
FROM clientes
GROUP BY estado, cidade
ORDER BY estado, cidade;
```

## ⚖️ A regra do GROUP BY
Esta é **A** regra que pega todo mundo no começo:

> **Toda coluna no SELECT precisa estar agregada OU listada no GROUP BY.**

Se você escreve `SELECT categoria_id, nome, count(*)` mas só agrupa por `categoria_id`, o Postgres não tem como decidir **qual `nome`** mostrar (são vários nomes dentro de cada categoria). Ele dá erro:

```
ERROR: column "produtos.nome" must appear in the GROUP BY clause
or be used in an aggregate function
```

Conserto: ou agrupe por `nome` também, ou agregue o `nome` (`max(nome)`, `string_agg(nome, ', ')`, etc.), ou tire do SELECT.

```sql
-- ❌ ERRADO
SELECT categoria_id, nome, count(*)
FROM produtos
GROUP BY categoria_id;

-- ✅ CERTO (agrega o nome)
SELECT categoria_id, string_agg(nome, ', ') AS nomes, count(*)
FROM produtos
GROUP BY categoria_id;
```

## 🚪 HAVING — filtrando depois de agrupar
`WHERE` filtra **linhas antes** do agrupamento. `HAVING` filtra **grupos depois** do agrupamento. A diferença é o momento:

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

```sql
-- Categorias com mais de 3 produtos
SELECT categoria_id, count(*) AS qtd
FROM produtos
GROUP BY categoria_id
HAVING count(*) > 3;
```

Você **não pode** colocar `count(*) > 3` no `WHERE` — naquele momento o grupo ainda nem existe. E pode usar `WHERE` + `HAVING` juntos, cada um filtrando no seu momento:

```sql
-- Entre produtos com estoque > 0, quais categorias têm mais de 3 SKUs?
SELECT categoria_id, count(*) AS qtd
FROM produtos
WHERE estoque > 0       -- filtra linhas
GROUP BY categoria_id
HAVING count(*) > 3;    -- filtra grupos
```

Regra prática: **agregação** vai no `HAVING`. **Coluna pura** vai no `WHERE`.

## 🎛️ FILTER (WHERE ...) — agregação condicional moderna
Esse é um recurso lindo do SQL padrão (Postgres tem desde a 9.4). Permite **agregar só um subconjunto** dentro da mesma query:

```sql
-- Em uma tacada só: total de pedidos, quantos entregues e quantos cancelados
SELECT
    count(*) AS total,
    count(*) FILTER (WHERE status = 'entregue')  AS entregues,
    count(*) FILTER (WHERE status = 'cancelado') AS cancelados
FROM pedidos;
```

A galera mais antiga fazia isso com `count(CASE WHEN status='entregue' THEN 1 END)`. Ainda funciona, mas `FILTER` é mais limpo e mais rápido de ler.

```sql
-- FILTER funciona com qualquer agregação
SELECT
    categoria_id,
    avg(preco) AS preco_medio_geral,
    avg(preco) FILTER (WHERE estoque > 0) AS preco_medio_em_estoque
FROM produtos
GROUP BY categoria_id;
```

## 🪢 string_agg e array_agg — colando valores agrupados
Quando você quer ver os **valores** de cada grupo, não só a contagem:

```sql
-- Nomes dos produtos de cada categoria, separados por vírgula
SELECT
    categoria_id,
    string_agg(nome, ', ' ORDER BY nome) AS produtos
FROM produtos
GROUP BY categoria_id;

-- Mesma coisa, mas em array
SELECT
    categoria_id,
    array_agg(nome ORDER BY nome) AS produtos
FROM produtos
GROUP BY categoria_id;
```

`ORDER BY` dentro do agregado controla a ordem de concatenação. Útil pra relatório.

## 📊 GROUPING SETS, ROLLUP e CUBE — relatórios multi-nível
Imagine: você quer um relatório que tem **subtotal por categoria** **E** **total geral**, no mesmo resultado. Antes era `UNION ALL`. Hoje:

### GROUPING SETS — escolha os níveis na mão
```sql
SELECT categoria_id, count(*) AS qtd
FROM produtos
GROUP BY GROUPING SETS ((categoria_id), ());
```

O `(categoria_id)` agrupa por categoria. O `()` (conjunto vazio) é o "grupo de tudo" — vira a linha de total geral (com `categoria_id` NULL).

### ROLLUP — hierarquia da esquerda pra direita
```sql
-- Total por (estado, cidade), depois por estado, depois geral
SELECT estado, cidade, count(*) AS qtd
FROM clientes
GROUP BY ROLLUP (estado, cidade)
ORDER BY estado NULLS LAST, cidade NULLS LAST;
```

Gera: cada (estado, cidade), depois subtotal por estado, depois total geral. Perfeito pra dashboard hierárquico.

### CUBE — todas as combinações
```sql
-- Todas as combinações possíveis dos níveis
SELECT estado, cidade, count(*) AS qtd
FROM clientes
GROUP BY CUBE (estado, cidade);
```

`CUBE(a, b)` = `GROUPING SETS ((a,b), (a), (b), ())`. Usa quando quer todas as facetas.

Pra distinguir um subtotal de um valor real NULL, usa `GROUPING(col)` — retorna 1 quando aquela coluna foi "agrupada pra cima" (subtotal) e 0 quando é valor de verdade.

## 🌫️ NULL em agregação — o resumo
- `SUM`, `AVG`, `MIN`, `MAX`, `COUNT(coluna)` **ignoram NULL**.
- `COUNT(*)` **conta tudo**, NULL inclusive.
- Se **todos** os valores forem NULL (ou nenhum valor existir), `SUM` retorna NULL (não zero!) e `AVG/MIN/MAX` também. Cuidado em relatório financeiro — use `COALESCE(sum(x), 0)`.
- `GROUP BY coluna` coloca todos os NULL em um grupo só (NULL = NULL pro `GROUP BY`, ao contrário do que acontece no `WHERE`).

```sql
-- Evite somar e mostrar NULL como célula vazia
SELECT
    categoria_id,
    COALESCE(sum(estoque), 0) AS estoque_total
FROM produtos
GROUP BY categoria_id;
```

## 💡 Dicas de quem programa Postgres há tempo
- **`GROUP BY` aceita posição** (`GROUP BY 1, 2`) e **alias do SELECT** no Postgres. Padrão SQL nem todo banco aceita; é confortável, mas em código de equipe prefira o nome da coluna.
- **`HAVING` sem `GROUP BY`** é válido — trata a tabela inteira como um grupo só. Útil pra `HAVING count(*) > 0` em subqueries.
- **`FILTER` é mais rápido que `CASE WHEN`** em casos com índice parcial, e sempre mais legível. Use por padrão.
- **`string_agg` precisa do separador** como segundo argumento (`string_agg(nome, ', ')`). Erro comum: esquecer a vírgula entre os args.
- Pra relatório que você roda **muito**, pense em **materialized view** (módulo mais à frente) — agregação cara não precisa rodar toda vez.

## 🚦 Próximos passos
1. Abra `pratica/queries.sql` e rode cada agregação no psql
2. Faça o `desafio` — **Estatísticas de Vendas** completas
3. Vá pro Módulo 08: subqueries e CTEs

## ✅ Auto-verificação
- [ ] Sei a diferença entre `COUNT(*)` e `COUNT(coluna)`
- [ ] Entendi a regra do GROUP BY (tudo do SELECT agregado ou agrupado)
- [ ] Sei quando usar `WHERE` e quando usar `HAVING`
- [ ] Consigo escrever uma agregação condicional com `FILTER`
- [ ] Sei usar `string_agg` / `array_agg` pra concatenar
- [ ] Entendi `GROUPING SETS` / `ROLLUP` / `CUBE` pra relatório multi-nível
- [ ] Lembro que `SUM` de tudo NULL retorna NULL (use `COALESCE`)

Próximo módulo: **Subqueries e CTEs** — quebrando query complexa em pedaços que cabem na cabeça.
