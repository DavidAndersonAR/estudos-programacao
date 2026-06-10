# Módulo 02 — SELECT básico

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Filtrar linhas com `WHERE` usando os operadores certos
- Combinar condições com `AND`, `OR`, `NOT` sem se enrolar
- Ordenar resultados com `ORDER BY` (e tratar `NULL` direito)
- Paginar com `LIMIT` e `OFFSET`
- Eliminar duplicatas com `DISTINCT` (e `DISTINCT ON`)
- Renomear colunas e tabelas com `AS`

E no miniprojeto: descobrir os **Top 10 produtos mais caros** da loja.

## 🧠 A anatomia de um SELECT
A ordem em que VOCÊ escreve:

```sql
SELECT   coluna1, coluna2
FROM     tabela
WHERE    condição
ORDER BY coluna
LIMIT    n
OFFSET   m;
```

A ordem em que o Postgres EXECUTA (importante saber, vamos voltar nisso muitas vezes no curso):

```
FROM → WHERE → SELECT → ORDER BY → LIMIT/OFFSET
```

Por isso um alias criado no `SELECT` (ex: `preco * 1.1 AS preco_com_imposto`) pode ser usado no `ORDER BY` mas **não** no `WHERE`. Detalhe que pega muita gente.

## 🔍 WHERE — filtrando linhas
`WHERE` é o filtro. Tudo que **bate** na condição passa. O resto fica fora.

### Operadores de comparação

| Operador | Significado | Exemplo |
|---|---|---|
| `=` | igual | `preco = 100` |
| `!=` ou `<>` | diferente | `estado != 'SP'` |
| `<` | menor que | `preco < 50` |
| `>` | maior que | `estoque > 0` |
| `<=` | menor ou igual | `preco <= 99.99` |
| `>=` | maior ou igual | `data_cadastro >= '2024-01-01'` |

```sql
-- Produtos que custam exatamente R$ 100
SELECT nome, preco FROM produtos WHERE preco = 100;

-- Produtos acima de R$ 500
SELECT nome, preco FROM produtos WHERE preco > 500;

-- Clientes que NÃO são de São Paulo
SELECT nome FROM clientes WHERE estado != 'SP';
```

### Operadores lógicos: AND, OR, NOT

- `AND` = as duas condições precisam ser verdadeiras
- `OR` = pelo menos uma precisa ser verdadeira
- `NOT` = inverte a condição

```sql
-- Produtos caros E com estoque
SELECT nome FROM produtos
WHERE preco > 1000 AND estoque > 0;

-- Clientes do Rio OU de SP
SELECT nome, estado FROM clientes
WHERE estado = 'RJ' OR estado = 'SP';

-- Pedidos que NÃO foram cancelados
SELECT id, status FROM pedidos
WHERE NOT status = 'cancelado';
```

### ⚠️ Precedência: AND antes de OR
Isso é uma pegadinha clássica. `AND` é avaliado antes de `OR`, igual em matemática (`*` antes de `+`). Quando misturar, **use parênteses** sempre — fica explícito e te livra de bugs sutis:

```sql
-- ERRADO (provavelmente não é o que você quer)
SELECT * FROM produtos
WHERE categoria_id = 1 OR categoria_id = 2 AND preco > 100;
-- Lê-se: categoria 1 OU (categoria 2 E preco > 100)

-- CERTO (com parênteses, intenção clara)
SELECT * FROM produtos
WHERE (categoria_id = 1 OR categoria_id = 2) AND preco > 100;
```

### NULL nunca é igual a nada
`WHERE estoque = NULL` **nunca** retorna linha — nem mesmo as que têm NULL. Use `IS NULL` / `IS NOT NULL`:

```sql
SELECT nome FROM clientes WHERE estado IS NULL;
SELECT nome FROM clientes WHERE estado IS NOT NULL;
```

## 📊 ORDER BY — ordenando o resultado
Por padrão, o Postgres **não garante ordem** se você não pedir. `ORDER BY` resolve.

```sql
-- Crescente (ASC é o default, pode omitir)
SELECT nome, preco FROM produtos ORDER BY preco;
SELECT nome, preco FROM produtos ORDER BY preco ASC;

-- Decrescente
SELECT nome, preco FROM produtos ORDER BY preco DESC;

-- Por várias colunas (desempata pela segunda)
SELECT nome, preco, estoque FROM produtos
ORDER BY preco DESC, estoque DESC;
```

### NULLS FIRST / NULLS LAST
Por padrão no Postgres:
- `ASC` → NULLs vão pro **fim** (`NULLS LAST`)
- `DESC` → NULLs vão pro **começo** (`NULLS FIRST`)

Se você quer mudar:

```sql
-- Produtos sem categoria primeiro
SELECT nome, categoria_id FROM produtos
ORDER BY categoria_id ASC NULLS FIRST;

-- Mais caros primeiro, mas NULLs pro fim
SELECT nome, preco FROM produtos
ORDER BY preco DESC NULLS LAST;
```

## ✂️ LIMIT e OFFSET — paginação
`LIMIT n` corta o resultado nas primeiras `n` linhas. `OFFSET m` pula as primeiras `m`.

```sql
-- Top 10 mais caros (o miniprojeto deste módulo!)
SELECT nome, preco FROM produtos
ORDER BY preco DESC
LIMIT 10;

-- Página 2 de uma lista de 10 em 10
SELECT nome FROM produtos
ORDER BY id
LIMIT 10 OFFSET 10;

-- Página 3
SELECT nome FROM produtos
ORDER BY id
LIMIT 10 OFFSET 20;
```

**Fórmula da paginação**: `OFFSET = (pagina - 1) * tamanho_da_pagina`.

⚠️ Dica de produção: `OFFSET` grande (tipo `OFFSET 1000000`) é **lento** — o banco precisa varrer e descartar tudo. Pra paginação séria, usaremos **keyset pagination** num módulo mais à frente. Por enquanto, OFFSET resolve.

## 🎯 DISTINCT — sem duplicatas
`DISTINCT` elimina linhas duplicadas no resultado.

```sql
-- Quais estados temos clientes?
SELECT DISTINCT estado FROM clientes;

-- Combinações únicas de cidade + estado
SELECT DISTINCT cidade, estado FROM clientes;
```

### DISTINCT ON (exclusivo do Postgres)
`DISTINCT ON (col)` mantém **a primeira linha** de cada valor único de `col`. "Primeira" segundo a ordenação do `ORDER BY`. É ótimo pra "pegue o mais recente / mais caro / mais X de cada grupo":

```sql
-- O produto mais caro de cada categoria
SELECT DISTINCT ON (categoria_id) categoria_id, nome, preco
FROM produtos
ORDER BY categoria_id, preco DESC;
```

A regra é: a coluna do `DISTINCT ON` precisa ser a **primeira** do `ORDER BY`.

## 🏷️ AS — apelidos (aliases)
`AS` dá um apelido. Funciona em coluna e em tabela. A palavra `AS` é opcional, mas ajuda a leitura.

### Em coluna
```sql
SELECT nome AS produto, preco AS valor
FROM produtos;

-- Útil pra expressões calculadas
SELECT nome, preco * 1.10 AS preco_com_imposto
FROM produtos;
```

### Em tabela
```sql
SELECT p.nome, p.preco
FROM produtos AS p
WHERE p.preco > 100;

-- Idiomático: omitir o AS
SELECT p.nome FROM produtos p WHERE p.preco > 100;
```

Aliases de tabela ficam essenciais quando entrarmos em JOIN (módulo 4).

## 💡 Dicas de quem programa Postgres há tempo
- **Sempre use `ORDER BY` antes de `LIMIT`**. Sem `ORDER BY`, "qual é a primeira linha?" é indefinido.
- **Aspas simples** pra string, **aspas duplas** pra identificador. `'SP'` é texto. `"SP"` seria um nome de coluna.
- **`!=` e `<>` são equivalentes**. Use o que preferir; `<>` é mais SQL-standard, `!=` é mais comum no dia a dia.
- **Aliases não funcionam no WHERE**, lembra da ordem de execução? Mas funcionam em `ORDER BY` e `GROUP BY`.
- Se misturou AND/OR, **bote parênteses**. Não confie na memória da precedência na hora do bug em produção.

## 🚦 Próximos passos
1. Abra `pratica/queries.sql` e rode cada uma no psql
2. Resolva o `desafio` — **Top 10 produtos mais caros** e variações
3. Vá pro Módulo 03: `LIKE`, `IN`, `BETWEEN` e funções de string

## ✅ Auto-verificação
- [ ] Sei filtrar com `WHERE` usando =, !=, <, >, <=, >=
- [ ] Sei combinar AND/OR/NOT e quando usar parênteses
- [ ] Sei ordenar ASC/DESC e controlar NULLS FIRST/LAST
- [ ] Sei paginar com LIMIT + OFFSET
- [ ] Entendi DISTINCT e quando faz sentido usar DISTINCT ON
- [ ] Uso AS pra deixar colunas e tabelas com nomes legíveis

Próximo módulo: **Filtros avançados** — LIKE, ILIKE, IN, BETWEEN, NULL.
