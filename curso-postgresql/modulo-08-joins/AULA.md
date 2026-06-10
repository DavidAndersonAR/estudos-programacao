# Módulo 08 — JOINs

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender por que JOIN existe (e por que normalizar tabelas)
- Escolher entre INNER, LEFT, RIGHT, FULL OUTER, CROSS e SELF JOIN
- Qualificar colunas com alias pra evitar ambiguidade
- Encadear 3+ tabelas num relatório só
- Saber a diferença entre `USING` e `ON`
- Reconhecer (e evitar) a sintaxe antiga com vírgula

## 🤔 Por que JOIN?
Banco relacional **divide informação em tabelas separadas** pra evitar duplicação. Cliente fica em `clientes`, pedido em `pedidos`, produto em `produtos`. Quando você precisa de tudo junto num relatório, **JOIN** é a ferramenta que costura as tabelas de volta — usando uma chave em comum (geralmente a FK).

Sem JOIN você teria que repetir o nome do cliente em todo pedido, o nome da categoria em todo produto, etc. Vira um inferno de manter (mudou o nome do cliente → atualiza em 100 lugares).

## 🧱 A mesa de exemplo
Continuamos com a loja. Lembre dos relacionamentos:

```
categorias 1 ── N produtos
clientes   1 ── N pedidos
pedidos    1 ── N itens_pedido N ── 1 produtos
```

Toda vez que você vê `_id` numa tabela, é um JOIN esperando pra acontecer.

## 🎨 Os tipos de JOIN (com diagrama mental)

### INNER JOIN — só os matches
Pega **só as linhas que têm correspondência nas duas tabelas**. É o JOIN mais usado.

```
   A      B
  ╭─╮   ╭─╮
  │ │╳│ │     ← só o pedaço do meio
  ╰─╯   ╰─╯
```

```sql
SELECT p.nome, c.nome AS categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id;
```

Se um produto tem `categoria_id` NULL (ou apontando pra categoria inexistente), **ele some** do resultado. Cuidado.

### LEFT JOIN (LEFT OUTER JOIN) — todos da esquerda
Mantém **todas as linhas da tabela da esquerda**, e traz as da direita quando casa. Quando não casa, vem NULL.

```
   A      B
  ╭─╮   ╭─╮
  │█│█│ │     ← A inteiro, B só onde encaixa
  ╰─╯   ╰─╯
```

```sql
SELECT c.nome, p.id AS pedido_id
FROM clientes c
LEFT JOIN pedidos p ON p.cliente_id = c.id;
```

Cliente sem pedido nenhum aparece com `pedido_id = NULL`. **Esse é o padrão pra encontrar "quem não tem":** LEFT JOIN + `WHERE direita.id IS NULL`.

### RIGHT JOIN — quase nunca usado
É o LEFT virado de cabeça pra baixo. Por convenção, **sempre invertemos a ordem das tabelas e usamos LEFT** — fica mais fácil de ler. Existe pra completude, mas se você ver RIGHT no seu código provavelmente dá pra reescrever como LEFT.

### FULL OUTER JOIN — tudo dos dois lados
Mantém **todas as linhas das duas tabelas**. Onde não casa, vem NULL no lado faltante.

```
   A      B
  ╭─╮   ╭─╮
  │█│█│█│     ← união completa
  ╰─╯   ╰─╯
```

```sql
SELECT c.nome, p.id
FROM clientes c
FULL OUTER JOIN pedidos p ON p.cliente_id = c.id;
```

Útil pra reconciliação (achar discrepâncias entre dois conjuntos).

### CROSS JOIN — produto cartesiano
**Toda linha da esquerda combinada com toda linha da direita**. Sem condição. Se A tem 10 linhas e B tem 20, sai 200.

```sql
SELECT t.nome AS tamanho, c.nome AS cor
FROM tamanhos t
CROSS JOIN cores c;
```

Útil pra gerar combinações (ex: matriz de variações de produto). Em qualquer outro caso costuma ser **bug** — você esqueceu o `ON`.

### SELF JOIN — a tabela com ela mesma
Tabela que referencia ela própria (hierarquia: funcionário → chefe, categoria → categoria-pai, comentário → comentário-pai). Você usa a mesma tabela duas vezes com aliases diferentes.

```sql
SELECT filho.nome AS subcategoria, pai.nome AS categoria_pai
FROM categorias filho
LEFT JOIN categorias pai ON filho.parent_id = pai.id;
```

## 🎯 `ON` vs `USING`
Duas formas de dizer "junta por essa coluna":

```sql
-- ON: explícito, funciona pra qualquer condição
SELECT * FROM produtos p
JOIN categorias c ON p.categoria_id = c.id;

-- USING: só quando o nome da coluna é IGUAL nas duas tabelas
SELECT * FROM produtos
JOIN categorias USING (categoria_id);  -- precisa do mesmo nome
```

`USING` é mais curto e **deduplica a coluna no resultado** (só aparece uma vez). Mas exige nome igual. Como na nossa loja o padrão é `categoria_id` em `produtos` e `id` em `categorias` (nomes diferentes), usamos quase sempre `ON`.

## 🏷️ Alias de tabela (essencial!)
Quando duas tabelas têm coluna com mesmo nome (`id`, `nome`...), o Postgres reclama de **ambiguidade**. Solução: dar apelido pras tabelas e qualificar.

```sql
SELECT p.nome AS produto, c.nome AS categoria
FROM produtos AS p
JOIN categorias AS c ON p.categoria_id = c.id;
```

`AS` é opcional (`produtos p` funciona). Padrão da comunidade: **alias curto e mnemônico** (`p` pra produtos, `c` pra clientes, `ip` pra itens_pedido).

## 🔗 JOINs encadeados (3+ tabelas)
Você simplesmente vai adicionando JOIN atrás de JOIN. A ordem de leitura é: começa da tabela base, vai costurando.

```sql
SELECT
    cli.nome     AS cliente,
    pr.nome      AS produto,
    cat.nome     AS categoria,
    ip.quantidade
FROM pedidos pe
INNER JOIN clientes     cli ON pe.cliente_id = cli.id
INNER JOIN itens_pedido ip  ON ip.pedido_id  = pe.id
INNER JOIN produtos     pr  ON ip.produto_id = pr.id
INNER JOIN categorias   cat ON pr.categoria_id = cat.id;
```

Dica: indente os JOINs alinhados. Fica visualmente óbvio o "caminho" do relatório.

## ⚠️ Sintaxe antiga (vírgula) — **EVITE**
Antes de 1992 (SQL-92), JOIN era escrito com vírgula no FROM e condição no WHERE:

```sql
-- ⛔ NÃO faça isso (legado)
SELECT p.nome, c.nome
FROM produtos p, categorias c
WHERE p.categoria_id = c.id;
```

Por que evitar:
- Esquecer o `WHERE` vira **CROSS JOIN silencioso** (e devastador).
- Misturar filtros (`WHERE`) com junção fica ilegível em 5+ tabelas.
- Não dá pra fazer LEFT/RIGHT/FULL com vírgula.

**Sempre use `JOIN ... ON ...` explícito.**

## 💡 Dicas de quem programa Postgres há tempo
- **JOIN sem `ON` é CROSS JOIN**. Postgres avisa, mas só se você usar a sintaxe nova. Com vírgula, ele faz silenciosamente.
- **Filtro em LEFT JOIN tem pegadinha**: `WHERE direita.coluna = X` **anula o LEFT** (vira INNER). Pra preservar, coloque a condição no `ON`: `LEFT JOIN ... ON ... AND direita.coluna = X`.
- **`COUNT(*)` num LEFT JOIN conta NULL também**. Use `COUNT(direita.id)` se quiser contar só os matches.
- **Ordem dos JOINs não muda resultado** (em INNER), mas pode mudar performance. O planner reordena, mas dê uma mão pra ele em queries grandes.
- **Aliase tudo**: mesmo com 2 tabelas. Custo zero, leitura ganha muito.

## 🚦 Próximos passos
1. Rode `pratica/queries.sql` e observe quantas linhas cada JOIN devolve.
2. Faça o `desafio`: o **Relatório de Vendas Detalhado**.
3. Vá pro Módulo 09 — Subqueries.

## ✅ Auto-verificação
- [ ] Sei quando usar INNER vs LEFT
- [ ] Sei achar "quem não tem" com LEFT + IS NULL
- [ ] Sei encadear 3+ tabelas num relatório
- [ ] Sei a diferença ON × USING
- [ ] Não uso mais vírgula no FROM

Próximo módulo: **Subqueries** — consultas dentro de consultas.
