# Módulo 05 — INSERT, UPDATE, DELETE (DML)

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Inserir dados de várias formas (linha única, várias linhas, a partir de `SELECT`)
- Atualizar e deletar com segurança (sempre com `WHERE`!)
- Usar `RETURNING` pra pegar o resultado da operação
- Fazer **UPSERT** (inserir-ou-atualizar) com `ON CONFLICT`
- Saber quando usar `TRUNCATE` e por que ele é perigoso

## 🧭 O que é DML?
**DML** = *Data Manipulation Language*. É a parte do SQL que mexe nos **dados** das tabelas (não na estrutura — isso é DDL, do Módulo 04). Os três comandos centrais são:

| Comando | O que faz |
|---|---|
| `INSERT` | adiciona linhas novas |
| `UPDATE` | altera linhas existentes |
| `DELETE` | remove linhas |

E tem um quarto, meio "à parte": `TRUNCATE`, que apaga **tudo** de uma tabela bem rápido.

## ➕ INSERT — adicionando dados

### Forma básica (com colunas explícitas — SEMPRE preferida)
```sql
INSERT INTO categorias (nome, descricao)
VALUES ('Bebidas', 'Sucos, refrigerantes e afins');
```

Por que listar as colunas? Porque se um dia a tabela ganhar uma coluna nova no meio, o `INSERT INTO categorias VALUES (...)` (sem colunas) quebra. Listar é à prova de futuro.

### Múltiplas linhas numa só query (rápido!)
```sql
INSERT INTO categorias (nome, descricao) VALUES
    ('Limpeza',    'Produtos pra casa'),
    ('Higiene',    'Banho, cabelo, etc'),
    ('Mercearia',  'Itens secos');
```
Um único `INSERT` com várias linhas é **muito** mais rápido que vários `INSERT`s separados — uma viagem de rede só, uma transação só.

### INSERT...SELECT (copiar/transformar dados)
```sql
-- Copia todos os produtos da categoria 1 pra uma tabela de backup
INSERT INTO produtos_backup (nome, preco, estoque)
SELECT nome, preco, estoque
FROM produtos
WHERE categoria_id = 1;
```
Útil pra arquivamento, migração, "duplicar tudo com desconto", etc.

## 🎁 RETURNING — pegando dados de volta
Por padrão `INSERT`/`UPDATE`/`DELETE` só retornam quantidade de linhas afetadas. Mas você quase sempre quer o **`id`** que foi gerado, ou ver o que mudou:

```sql
INSERT INTO produtos (nome, preco, estoque, categoria_id)
VALUES ('Coca-Cola 2L', 9.90, 100, 1)
RETURNING id, nome;
```

Funciona com os três comandos:
```sql
UPDATE produtos SET preco = preco * 1.1 WHERE categoria_id = 1
RETURNING id, nome, preco;

DELETE FROM produtos WHERE estoque = 0
RETURNING id, nome;
```

Isso é **assinatura do Postgres** — outros bancos só ganharam algo parecido depois. Use sempre que precisar saber o que aconteceu.

## ✏️ UPDATE — alterando dados

```sql
UPDATE produtos
SET preco = 12.50
WHERE id = 42;
```

### ⚠️ CUIDADO: UPDATE sem WHERE atualiza TUDO
```sql
-- 🚨 PERIGO: isso muda o preço de TODOS os produtos da loja
UPDATE produtos SET preco = 9.99;
```
Isso é causa #1 de incidente em prod. Antes de rodar um `UPDATE`, faça um `SELECT` com o mesmo `WHERE` e confira quantas linhas vai pegar.

### Expressões no SET
Pode usar coluna como referência pra ela mesma:
```sql
-- Aumenta 10% no preço de produtos da categoria 2
UPDATE produtos
SET preco = preco * 1.10
WHERE categoria_id = 2;

-- Zera o estoque
UPDATE produtos SET estoque = 0 WHERE id = 5;
```

### Atualizar várias colunas
```sql
UPDATE produtos
SET preco = 19.90, estoque = 50
WHERE nome = 'Sabonete';
```

## 🗑️ DELETE — removendo dados

```sql
DELETE FROM produtos WHERE id = 42;
```

Mesma regra do `UPDATE`: **sem `WHERE` apaga tudo**. Postgres não pergunta "tem certeza?".

```sql
-- 🚨 Apaga TODAS as linhas (mas mantém estrutura, sequência, etc)
DELETE FROM produtos;
```

Cuidado também com FKs: se outra tabela referencia a linha que você quer deletar, o Postgres reclama (a menos que tenha `ON DELETE CASCADE`).

## 🔁 UPSERT — `ON CONFLICT`
"Insira; se já existir, atualize" — esse padrão chama **UPSERT** (insert + update). No Postgres é com `ON CONFLICT`:

### DO NOTHING — ignora se já existe
```sql
INSERT INTO clientes (nome, email)
VALUES ('Maria Silva', 'maria@email.com')
ON CONFLICT (email) DO NOTHING;
```
Útil pra importações em lote — não quebra se a linha já estiver lá.

### DO UPDATE — atualiza se já existe
```sql
INSERT INTO clientes (nome, email, cidade)
VALUES ('Maria Silva', 'maria@email.com', 'São Paulo')
ON CONFLICT (email)
DO UPDATE SET
    nome = EXCLUDED.nome,
    cidade = EXCLUDED.cidade;
```

O `EXCLUDED` é uma "tabela virtual" com os valores que você **tentou** inserir. Bem prático.

Detalhe importante: o `ON CONFLICT (coluna)` precisa de uma `UNIQUE` ou `PRIMARY KEY` naquela coluna. Sem isso, dá erro.

## 💣 TRUNCATE — esvaziar tabela na velocidade da luz

```sql
TRUNCATE TABLE produtos;
```

Diferente do `DELETE`:
- Não aceita `WHERE` — apaga **tudo**, sempre
- Muito mais rápido em tabelas grandes (não escaneia linha a linha)
- Pode resetar a sequência do `SERIAL`:
  ```sql
  TRUNCATE TABLE produtos RESTART IDENTITY;
  ```
- Pode cascatear pra tabelas dependentes:
  ```sql
  TRUNCATE TABLE produtos CASCADE;
  ```

Use **só** em ambientes de dev/teste, ou quando você de fato quer zerar a tabela.

## 🔐 Transações implícitas — uma palavrinha
Lembra do Módulo 01? Toda comando solto roda na própria transação implícita. Isso significa que:

```sql
DELETE FROM produtos WHERE id = 1;  -- ✅ já foi commitado, não tem como voltar
```

Se for uma operação delicada, **envelope numa transação explícita** (Módulo 15):
```sql
BEGIN;
UPDATE produtos SET preco = preco * 1.5;
-- Olha o resultado, confere...
SELECT * FROM produtos LIMIT 10;
ROLLBACK;  -- desfaz! ou COMMIT pra confirmar
```

## 💡 Dicas de quem programa Postgres há tempo
- **Antes de qualquer `UPDATE`/`DELETE` em prod, rode o `SELECT` com o mesmo `WHERE`** pra ver o que vai pegar.
- **`RETURNING` é seu amigo**: pega o `id` gerado sem precisar de `SELECT` extra.
- **Use `INSERT ... ON CONFLICT DO NOTHING` em importação de CSV**: evita erro de chave duplicada.
- **`TRUNCATE` não dispara triggers `ON DELETE`** — diferença sutil mas que pega gente desprevenida.
- **Sempre liste as colunas no `INSERT`** — schema muda, código quebra menos.
- **`UPDATE` é mais caro do que parece**: o Postgres não atualiza in-place por causa do MVCC; ele cria uma versão nova da linha. Por isso `UPDATE` em milhões de linhas exige planejamento.

## 🚦 Próximos passos
1. Rode o `pratica/queries.sql` pra praticar cada operação
2. Faça o `desafio/queries.sql` — CRUD completo de produtos
3. Vá pro Módulo 06 — Constraints (CHECK, UNIQUE, FK e amigos)

## ✅ Auto-verificação
- [ ] Sei inserir uma e várias linhas com `INSERT`
- [ ] Uso `RETURNING` pra pegar o `id` recém-criado
- [ ] Nunca rodo `UPDATE` ou `DELETE` sem `WHERE` (ou confirmei que era isso mesmo)
- [ ] Sei usar `ON CONFLICT DO UPDATE` (UPSERT)
- [ ] Sei a diferença entre `DELETE` e `TRUNCATE`

Próximo módulo: **Constraints** — como o banco protege seus dados de você mesmo.
