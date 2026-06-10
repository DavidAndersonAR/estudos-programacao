# Módulo 10 — CTEs + Window Functions

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever **CTEs** (`WITH ... AS (...)`) pra deixar queries longas legíveis
- Encadear múltiplas CTEs (uma usando a outra)
- Usar **WITH RECURSIVE** pra hierarquias (categoria → subcategoria) e sequências
- Entender **window functions**: agregar **sem perder linhas**
- Dominar `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`
- Calcular **somas/médias acumuladas** com `SUM() OVER (...)` e **frame clauses**

## 🧠 CTE — o que é e por que usar
**CTE** = *Common Table Expression*. É uma subquery nomeada que vive só dentro da query. Sintaxe:

```sql
WITH nome_da_cte AS (
    SELECT ...
)
SELECT * FROM nome_da_cte;
```

Por que usar em vez de subquery aninhada?
- **Legibilidade**: cada CTE é uma "etapa" nomeada. Lê de cima pra baixo, como receita.
- **Reuso**: você referencia a CTE várias vezes na mesma query.
- **Debug**: comenta a query principal e roda só a CTE pra ver o que ela entrega.

Compare. Aninhada (confuso):
```sql
SELECT c.nome, t.total
FROM categorias c
JOIN (
    SELECT categoria_id, SUM(preco * estoque) AS total
    FROM produtos
    GROUP BY categoria_id
) t ON t.categoria_id = c.id;
```

Com CTE (limpo):
```sql
WITH valor_estoque AS (
    SELECT categoria_id, SUM(preco * estoque) AS total
    FROM produtos
    GROUP BY categoria_id
)
SELECT c.nome, v.total
FROM categorias c
JOIN valor_estoque v ON v.categoria_id = c.id;
```

## 🔗 Múltiplas CTEs
Separa por vírgula. Cada CTE seguinte enxerga as anteriores:

```sql
WITH
pedidos_pagos AS (
    SELECT * FROM pedidos WHERE status IN ('pago','enviado','entregue')
),
valor_por_pedido AS (
    SELECT p.id, p.cliente_id, SUM(i.quantidade * i.preco_unitario) AS total
    FROM pedidos_pagos p
    JOIN itens_pedido i ON i.pedido_id = p.id
    GROUP BY p.id, p.cliente_id
)
SELECT cliente_id, SUM(total) AS faturado
FROM valor_por_pedido
GROUP BY cliente_id
ORDER BY faturado DESC;
```

Três etapas claras: filtra pedidos → calcula valor → soma por cliente.

## 🔁 WITH RECURSIVE — hierarquias e sequências
Quando você não sabe quantos níveis tem (categoria → subcategoria → sub-sub...), `WITH RECURSIVE` resolve. Estrutura sempre igual:

```sql
WITH RECURSIVE nome AS (
    -- 1) caso base (âncora)
    SELECT ... FROM ... WHERE condição_inicial

    UNION ALL

    -- 2) parte recursiva (referencia "nome" — a CTE em si)
    SELECT ... FROM ... JOIN nome ON ...
)
SELECT * FROM nome;
```

### Exemplo 1: gerar sequência 1..10
```sql
WITH RECURSIVE numeros AS (
    SELECT 1 AS n            -- âncora
    UNION ALL
    SELECT n + 1 FROM numeros WHERE n < 10  -- recursão
)
SELECT * FROM numeros;
```

### Exemplo 2: hierarquia de categorias
Imagine `categorias(id, nome, pai_id)`:
```sql
WITH RECURSIVE arvore AS (
    SELECT id, nome, pai_id, 0 AS nivel
    FROM categorias
    WHERE pai_id IS NULL

    UNION ALL

    SELECT c.id, c.nome, c.pai_id, a.nivel + 1
    FROM categorias c
    JOIN arvore a ON c.pai_id = a.id
)
SELECT * FROM arvore ORDER BY nivel, nome;
```

⚠️ **Sempre** tenha condição de parada na recursão (`WHERE n < 10`, ou o JOIN naturalmente termina), senão loop infinito.

## 🪟 Window Functions — o pulo do gato
Agregação tradicional com `GROUP BY` **colapsa** linhas:

```sql
SELECT categoria_id, AVG(preco) FROM produtos GROUP BY categoria_id;
-- volta 1 linha por categoria. Perdeu os produtos individuais.
```

Window function **mantém todas as linhas** e adiciona a agregação ao lado:

```sql
SELECT
    nome,
    preco,
    categoria_id,
    AVG(preco) OVER (PARTITION BY categoria_id) AS media_da_categoria
FROM produtos;
-- volta TODOS os produtos, com a média da categoria deles em cada linha.
```

A mágica é o `OVER (...)`. Sem ele, é agregação normal. Com ele, é janela.

### Anatomia do `OVER`
```sql
funcao() OVER (
    PARTITION BY coluna1   -- divide em grupos (opcional)
    ORDER BY     coluna2   -- ordena dentro do grupo (opcional)
    ROWS BETWEEN ...       -- recorta um "frame" da janela (opcional)
)
```

- `OVER ()` vazio: janela = a tabela toda.
- `PARTITION BY`: como o `GROUP BY`, mas sem colapsar.
- `ORDER BY` dentro do OVER: ordem das linhas pra funções que dependem de posição (LAG, RANK, SUM acumulado...).

## 📊 Funções de ranking
Todas exigem `ORDER BY` no OVER (precisam de ordem pra ranquear).

| Função | O que faz |
|---|---|
| `ROW_NUMBER()` | numera 1, 2, 3... sem empate (mesmo se valores iguais) |
| `RANK()` | empate vira mesmo número, mas pula posições: 1, 2, 2, 4 |
| `DENSE_RANK()` | empate vira mesmo número, sem pular: 1, 2, 2, 3 |
| `NTILE(n)` | divide em N grupos iguais (quartis, decis, percentis) |

Exemplo: ranking de produtos por preço dentro de cada categoria.
```sql
SELECT
    nome,
    categoria_id,
    preco,
    ROW_NUMBER() OVER (PARTITION BY categoria_id ORDER BY preco DESC) AS posicao
FROM produtos;
```

Pra pegar **top 3 por categoria**: encapsula em CTE e filtra `WHERE posicao <= 3`.

## 🔄 LAG / LEAD — linha anterior / próxima
- `LAG(coluna, n)`: valor da linha **n posições antes**.
- `LEAD(coluna, n)`: valor da linha **n posições depois**.

Útil pra calcular **diferença com período anterior**:
```sql
SELECT
    data_pedido::date AS dia,
    COUNT(*) AS pedidos_dia,
    LAG(COUNT(*)) OVER (ORDER BY data_pedido::date) AS pedidos_dia_anterior
FROM pedidos
GROUP BY dia;
```

## 🥇 FIRST_VALUE / LAST_VALUE
Pega o primeiro/último valor da janela. Combina bem com `PARTITION BY`:

```sql
SELECT
    nome, categoria_id, preco,
    FIRST_VALUE(nome) OVER (PARTITION BY categoria_id ORDER BY preco DESC) AS mais_caro_da_cat
FROM produtos;
```

⚠️ `LAST_VALUE` tem armadilha: o frame default é "do início até a linha atual", então `LAST_VALUE` sem frame explícito vira igual ao valor atual. Pra funcionar, especifique o frame:
```sql
LAST_VALUE(nome) OVER (
    PARTITION BY categoria_id
    ORDER BY preco DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
)
```

## ➕ SUM / AVG OVER — acumulado e rolling
Com `ORDER BY` no OVER, vira **acumulado**:

```sql
SELECT
    data_pedido::date AS dia,
    SUM(total) AS vendas_do_dia,
    SUM(SUM(total)) OVER (ORDER BY data_pedido::date) AS acumulado
FROM vendas
GROUP BY dia;
```

(Sim, dois `SUM` aninhados: o de dentro agrega por dia, o de fora acumula entre dias.)

### Frame clauses — recortando a janela
Dentro do OVER, você pode dizer **quantas linhas vizinhas** entram no cálculo:

| Frame | Significado |
|---|---|
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | do início até a linha atual (acumulado — default quando tem ORDER BY) |
| `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` | últimas 7 linhas (rolling de 7 períodos) |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | a partição toda |
| `ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING` | linha anterior + atual + próxima (média móvel 3) |

Exemplo: média móvel de vendas dos últimos 7 dias.
```sql
SELECT
    dia,
    vendas,
    AVG(vendas) OVER (
        ORDER BY dia
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS media_7dias
FROM vendas_diarias;
```

## 💡 Dicas de quem usa há tempo
- **CTE não é índice mágico**: no Postgres 12+, CTE é "inlined" (otimizada como subquery). Antes do 12, era barreira de otimização. Hoje, use à vontade pela legibilidade.
- **Window function é processada DEPOIS do WHERE**: pra filtrar pelo resultado da janela (`WHERE rank <= 3`), você precisa **envelopar em CTE/subquery** e filtrar fora.
- **PARTITION BY ≠ GROUP BY**: PARTITION mantém linhas, GROUP colapsa. Não dá pra usar os dois pro mesmo agrupamento na mesma SELECT.
- **`OVER w`** com `WINDOW w AS (...)` no fim da query economiza repetição quando você usa a mesma janela 3+ vezes.
- **Recursão tem limite**: Postgres aborta em loop infinito por estouro de memória, mas demora. Coloca `WHERE` de parada sempre.

## 🚦 Próximos passos
1. Leia o `pratica/queries.sql` e rode cada query
2. Faça o `desafio/queries.sql`: **Ranking de Produtos por Categoria**
3. Vá pro Módulo 11 — Índices

## ✅ Auto-verificação
- [ ] Sei diferenciar CTE de subquery aninhada e quando cada uma cabe
- [ ] Escrevi um `WITH RECURSIVE` que para corretamente
- [ ] Sei diferença entre `ROW_NUMBER`, `RANK` e `DENSE_RANK`
- [ ] Sei calcular um acumulado com `SUM() OVER (ORDER BY ...)`
- [ ] Lembro que filtro de window function precisa de CTE/subquery por fora

Próximo módulo: **Índices** — por que sua query lenta vai voar.
