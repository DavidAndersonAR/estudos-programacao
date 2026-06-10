# Módulo 06 — Operadores e Funções

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Buscar texto com `LIKE` / `ILIKE` (curingas `%` e `_`)
- Filtrar com `IN`, `BETWEEN`, `IS NULL` / `IS NOT NULL`
- Tratar NULL com `COALESCE` e `NULLIF`
- Criar colunas calculadas com `CASE WHEN`
- Manipular strings, números e datas com funções nativas

## 🔎 LIKE e ILIKE — busca por padrão
Servem pra buscar texto que **bate um padrão**. Dois curingas:

- `%` = zero ou mais caracteres
- `_` = exatamente 1 caractere

```sql
-- LIKE é case-sensitive
SELECT nome FROM produtos WHERE nome LIKE 'Smart%';   -- começa com "Smart"
SELECT nome FROM produtos WHERE nome LIKE '%phone%';  -- contém "phone"
SELECT nome FROM produtos WHERE nome LIKE '_phone';   -- 1 letra + "phone" (iphone? aphone?)

-- ILIKE = LIKE case-insensitive (extensão Postgres, super útil em PT-BR)
SELECT nome FROM produtos WHERE nome ILIKE '%smart%'; -- pega Smart, smart, SMART
```

> 💡 Em produção, `ILIKE '%algo%'` não usa índice por padrão. Pro caso real, vamos ver `pg_trgm` mais pra frente.

## 🎯 IN — lista de valores
Substitui um monte de `OR`:

```sql
-- Em vez disso:
SELECT * FROM produtos WHERE categoria_id = 1 OR categoria_id = 2 OR categoria_id = 5;

-- Faça isso:
SELECT * FROM produtos WHERE categoria_id IN (1, 2, 5);

-- Funciona com string também:
SELECT * FROM pedidos WHERE status IN ('pendente', 'pago');

-- E o oposto:
SELECT * FROM pedidos WHERE status NOT IN ('cancelado', 'entregue');
```

## 📏 BETWEEN — intervalo (inclusivo)
`BETWEEN a AND b` é equivalente a `>= a AND <= b`:

```sql
SELECT nome, preco FROM produtos WHERE preco BETWEEN 100 AND 500;
SELECT * FROM clientes WHERE data_cadastro BETWEEN '2024-01-01' AND '2024-12-31';
```

> ⚠️ `BETWEEN` é **inclusivo nos dois lados**. Pra exclusivo, use `>` e `<` explícitos.

## 🕳️ IS NULL / IS NOT NULL
Lembra do módulo 01? NULL não é igual a nada — nem a outro NULL. **Sempre** use `IS`:

```sql
SELECT * FROM clientes WHERE cidade IS NULL;       -- sem cidade
SELECT * FROM clientes WHERE cidade IS NOT NULL;   -- tem cidade
-- ❌ ERRADO: WHERE cidade = NULL  → nunca retorna nada
```

## 🛡️ COALESCE — primeiro valor não-NULL
Pega o primeiro argumento que **não for NULL**. Ouro pra tratar campo opcional:

```sql
SELECT
    nome,
    COALESCE(cidade, '(sem cidade)') AS cidade_exibida
FROM clientes;

-- Pode aninhar quantos quiser:
SELECT COALESCE(cidade, estado, 'Brasil') FROM clientes;
```

## 🔄 NULLIF — vira NULL se for igual
`NULLIF(a, b)` retorna NULL se `a = b`, senão retorna `a`. Útil pra evitar divisão por zero:

```sql
SELECT 100 / NULLIF(estoque, 0) FROM produtos; -- se estoque=0, vira NULL em vez de erro
```

## 🎚️ CASE WHEN — if/else do SQL
Permite categorizar valores na hora:

```sql
SELECT
    nome,
    preco,
    CASE
        WHEN preco < 50  THEN 'barato'
        WHEN preco < 500 THEN 'médio'
        ELSE                  'caro'
    END AS faixa_preco
FROM produtos;
```

Forma curta (igualdade):
```sql
SELECT CASE status
    WHEN 'pendente' THEN 'Aguardando'
    WHEN 'pago'     THEN 'Pago — preparar'
    ELSE                 'Outro'
END FROM pedidos;
```

## 🔤 Funções de string
| Função | O que faz | Exemplo |
|---|---|---|
| `upper(s)` | maiúscula | `upper('go')` → `GO` |
| `lower(s)` | minúscula | `lower('GO')` → `go` |
| `length(s)` | tamanho | `length('abc')` → `3` |
| `trim(s)` | tira espaço das pontas | `trim('  oi  ')` → `oi` |
| `substring(s FROM a FOR n)` | recorta | `substring('postgres' FROM 1 FOR 4)` → `post` |
| `replace(s, de, para)` | troca | `replace('a-b', '-', '_')` → `a_b` |
| `position(sub IN s)` | acha índice (1-based) | `position('gr' IN 'postgres')` → `5` |
| `concat(a, b, ...)` | junta (ignora NULL) | `concat('oi ', nome)` |
| `a \|\| b` | concatena (NULL contamina) | `'oi ' \|\| nome` |

```sql
SELECT upper(nome), length(nome), 'Olá, ' || nome FROM clientes;
```

## 🔢 Funções de número
| Função | O que faz |
|---|---|
| `round(x, n)` | arredonda pra n casas (default 0) |
| `ceil(x)` | arredonda pra cima |
| `floor(x)` | arredonda pra baixo |
| `abs(x)` | valor absoluto |
| `mod(a, b)` | resto da divisão |
| `power(a, b)` | a elevado a b |

```sql
SELECT round(preco, 1), ceil(preco), floor(preco) FROM produtos;
SELECT mod(10, 3);    -- 1
SELECT power(2, 10);  -- 1024
```

## 📅 Funções de data/hora
São as que mais quebram cabeça de quem vem de Java/Python. Vale decorar:

| Função | O que retorna |
|---|---|
| `now()` | timestamp atual (com timezone) |
| `current_date` | só a data de hoje |
| `current_time` | só a hora |
| `date_trunc('mes', data)` | "trunca" no início do período (mes, dia, ano...) |
| `extract(year FROM data)` | extrai parte (year, month, day, dow, hour) |
| `age(t1, t2)` | diferença entre datas como `interval` |
| `interval '7 days'` | literal de intervalo |

```sql
-- Pedidos do mês atual
SELECT * FROM pedidos
WHERE date_trunc('month', data_pedido) = date_trunc('month', current_date);

-- Ano de cada pedido
SELECT id, extract(year FROM data_pedido) AS ano FROM pedidos;

-- Idade do cliente em relação ao cadastro
SELECT nome, age(current_date, data_cadastro) AS tempo_de_casa FROM clientes;

-- Aritmética com interval
SELECT now() + interval '7 days';        -- daqui 1 semana
SELECT now() - interval '1 month 3 days'; -- 1 mês e 3 dias atrás
```

> 💡 `date_trunc` é seu melhor amigo pra agrupar por período em relatório.

## 💡 Dicas de quem programa Postgres há tempo
- **`ILIKE` é o padrão em busca de usuário** — ninguém quer "Smart" diferente de "smart".
- **`COALESCE` no SELECT** deixa o relatório muito mais apresentável.
- **`CASE` substitui muito CRUD no app** — categorizar no banco economiza código.
- **Sempre `date_trunc` antes de agrupar por mês/ano** — não tente fazer com `to_char`, perde a ordem natural.
- **`age()` retorna `interval`** — pra ter "em dias" use `(data1 - data2)::int` ou `extract(day FROM age(...))`.

## 🚦 Próximos passos
1. Rode as queries de `pratica/queries.sql`
2. Faça o desafio `desafio/queries.sql` — Relatório Formatado de Pedidos
3. Próximo módulo: Joins (INNER, LEFT, RIGHT, FULL)

## ✅ Auto-verificação
- [ ] Sei diferenciar `LIKE` de `ILIKE` e usar `%` / `_`
- [ ] Uso `IN` em vez de cadeia de `OR`
- [ ] Trato NULL com `COALESCE` e `IS NULL`
- [ ] Construo categorias com `CASE WHEN`
- [ ] Uso `date_trunc` e `extract` em relatórios por período

Próximo módulo: **Joins** — combinando tabelas pra valer.
