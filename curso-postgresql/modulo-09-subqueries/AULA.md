# Módulo 09 — Subqueries

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever **subqueries escalares** (que retornam 1 valor) e usar em SELECT/WHERE
- Usar **subquery no FROM** (derived table) pra pré-agregar dados
- Filtrar com **IN (SELECT)** e entender o **perigo do NOT IN com NULL**
- Trocar IN/NOT IN por **EXISTS / NOT EXISTS** quando faz sentido
- Usar **ANY** e **ALL** pra comparar com listas
- Escrever **correlated subqueries** (subquery que referencia a query externa)
- Usar **LATERAL JOIN** pra "pra cada linha da esquerda, roda essa query"
- Decidir: **JOIN ou subquery?**

## 🧠 O que é uma subquery?
Subquery (ou **subconsulta**) é uma `SELECT` dentro de outra `SELECT`. Vive entre parênteses e o planner do Postgres trata como uma "mini-query" que produz um resultado consumido pela query externa.

Três grupos de subquery, por **forma do resultado**:

| Forma | Retorna | Onde usa |
|---|---|---|
| **Escalar** | 1 linha × 1 coluna | SELECT, WHERE, ORDER BY |
| **Vetor / lista** | N linhas × 1 coluna | IN, NOT IN, ANY, ALL |
| **Tabela** | N linhas × M colunas | FROM (derived table), LATERAL, EXISTS |

## 🔹 Subquery escalar
Retorna **um único valor**. Se vier mais de uma linha, dá erro em runtime.

```sql
-- Preço médio da loja (1 número)
SELECT AVG(preco) FROM produtos;

-- Produtos acima da média geral
SELECT nome, preco
FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos);
```

Dá pra usar no SELECT também (mostra a média em cada linha — útil pra comparar):

```sql
SELECT nome,
       preco,
       (SELECT AVG(preco) FROM produtos) AS media_geral
FROM produtos;
```

## 🔹 Subquery no FROM (derived table)
A subquery vira uma "tabela virtual". **Precisa de alias** — sem alias, Postgres reclama.

```sql
SELECT cat_nome, total
FROM (
    SELECT c.nome AS cat_nome, COUNT(p.id) AS total
    FROM categorias c
    LEFT JOIN produtos p ON p.categoria_id = c.id
    GROUP BY c.nome
) AS resumo            -- ← o alias é obrigatório
WHERE total > 5;
```

Útil quando você precisa **agregar primeiro e filtrar depois** com um critério que o `HAVING` não dá conta.

## 🔹 IN (SELECT ...)
Filtra por uma lista que vem de outra query:

```sql
-- Clientes que já fizeram pelo menos um pedido
SELECT nome, email
FROM clientes
WHERE id IN (SELECT DISTINCT cliente_id FROM pedidos);
```

## ⚠️ NOT IN: a pegadinha do NULL
**Cuidado**: se a subquery retornar um `NULL`, `NOT IN` devolve **vazio** (não o que você esperava). Isso porque `x NOT IN (1, 2, NULL)` é equivalente a `x <> 1 AND x <> 2 AND x <> NULL`, e qualquer comparação com NULL é desconhecida.

```sql
-- ⚠️ Pode dar bug se algum cliente_id for NULL na fonte
SELECT nome FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos);

-- ✅ Versão segura
SELECT nome FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos WHERE cliente_id IS NOT NULL);

-- ✅✅ Versão idiomática (e geralmente mais rápida)
SELECT nome FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

## 🔹 EXISTS e NOT EXISTS
`EXISTS` é **booleano**: retorna `TRUE` se a subquery devolveu pelo menos 1 linha. Por isso o `SELECT 1` clássico — o conteúdo não importa, só a existência.

```sql
-- Clientes COM pedido
SELECT nome FROM clientes c
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);

-- Clientes SEM pedido
SELECT nome FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id);
```

**Por que prefiro EXISTS sobre IN/NOT IN?**
- Não tem problema com NULL.
- Curto-circuita: para na primeira linha que casar.
- Lê melhor quando o join é "complexo" (mais de uma coluna).

## 🔹 ANY e ALL
Comparam com **cada elemento** de uma lista/subquery.

```sql
-- Produto mais caro que QUALQUER um da categoria 2 (= mais caro que o mais barato dela)
SELECT nome, preco FROM produtos
WHERE preco > ANY (SELECT preco FROM produtos WHERE categoria_id = 2);

-- Produto mais caro que TODOS da categoria 2 (= mais caro que o mais caro dela)
SELECT nome, preco FROM produtos
WHERE preco > ALL (SELECT preco FROM produtos WHERE categoria_id = 2);
```

Equivalências boas de saber:
- `x IN (...)` ≡ `x = ANY (...)`
- `x NOT IN (...)` ≡ `x <> ALL (...)`

## 🔹 Correlated subquery
A subquery **referencia colunas da query externa**. Roda uma vez por linha da query externa (pelo menos logicamente — o planner pode otimizar).

```sql
-- Pra cada cliente, contar seus pedidos
SELECT c.nome,
       (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id) AS qtd_pedidos
FROM clientes c;

-- Produtos mais caros que a média da SUA categoria
SELECT p.nome, p.preco, p.categoria_id
FROM produtos p
WHERE p.preco > (
    SELECT AVG(preco)
    FROM produtos p2
    WHERE p2.categoria_id = p.categoria_id   -- ← amarra com a externa
);
```

A correlated subquery é a forma natural de fazer "**pra cada X, calcula Y baseado em X**".

## 🔹 LATERAL JOIN
A irmã moderna e mais flexível da correlated subquery. Permite que a subquery do FROM **enxergue colunas das tabelas anteriores** — coisa que uma derived table normal **não** consegue.

```sql
-- Pra cada cliente, pegar o pedido mais recente
SELECT c.nome, ult.id AS pedido_id, ult.data_pedido
FROM clientes c
LEFT JOIN LATERAL (
    SELECT id, data_pedido
    FROM pedidos p
    WHERE p.cliente_id = c.id        -- ← só funciona por causa do LATERAL
    ORDER BY data_pedido DESC
    LIMIT 1
) AS ult ON TRUE;
```

Use `LEFT JOIN LATERAL` + `ON TRUE` quando quer manter a linha externa mesmo que a subquery não devolva nada (caso do cliente sem pedido). Use `CROSS JOIN LATERAL` quando linhas sem match podem sumir.

**Quando LATERAL brilha**:
- "Top N por grupo" (top 3 produtos por categoria).
- "Última linha por chave" (último pedido por cliente).
- Chamar uma função set-returning (ex.: `jsonb_array_elements`) por linha.

## 🤔 JOIN ou subquery?
Não é guerra santa — Postgres muitas vezes reescreve uma na outra. Mas tem heurísticas:

| Situação | Prefira |
|---|---|
| "Existe pelo menos um?" / "Não existe nenhum?" | EXISTS / NOT EXISTS |
| Precisa de colunas das duas tabelas no SELECT | JOIN |
| Precisa pré-agregar antes de juntar | subquery no FROM ou CTE |
| "Pra cada linha da esquerda, top N da direita" | LATERAL |
| Comparar valor com um agregado da mesma tabela | escalar / correlated |

CTE (`WITH ...`) é o próximo nível — vamos ver no **Módulo 10**.

## 💡 Dicas de produção
- Subquery escalar dentro de SELECT é elegante mas pode rodar muitas vezes. Em tabela grande, **prefira JOIN com derived table**.
- `EXISTS` quase sempre ganha de `IN` em subqueries grandes — e nunca te bate com bug de NULL.
- Sempre **nomeie o alias** das subqueries no FROM (`AS resumo`). Não dá pra omitir no Postgres.
- LATERAL é caro quando a subquery interna não tem índice no critério de correlação. Garanta índice em `pedidos(cliente_id, data_pedido DESC)` no exemplo acima.
- Use `EXPLAIN ANALYZE` pra ver se sua subquery está sendo materializada ou inline (vamos no Módulo 17).

## 🚦 Próximos passos
1. Rode `pratica/queries.sql` e leia cada bloco.
2. Tente o `desafio/queries.sql` **antes** de olhar a solução comentada.
3. Vá pro Módulo 10 — CTEs e Window Functions.

## ✅ Auto-verificação
- [ ] Sei diferenciar escalar / vetor / tabela
- [ ] Sei por que NOT IN com NULL é furada
- [ ] Sei quando usar EXISTS no lugar de IN
- [ ] Escrevi pelo menos uma correlated subquery do zero
- [ ] Entendi por que LATERAL precisa do `ON TRUE`

Próximo módulo: **CTEs e Window Functions** — `WITH`, `ROW_NUMBER()`, `RANK()`, frames.
