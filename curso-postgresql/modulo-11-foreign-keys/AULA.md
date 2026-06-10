# Módulo 11 — Foreign Keys e Relacionamentos

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar e entender **FOREIGN KEYS** (FKs) e o que é integridade referencial
- Escolher a política correta de `ON DELETE` / `ON UPDATE` pra cada caso
- Modelar relacionamentos **1:1**, **1:N** e **N:N**
- Criar FKs **compostas** e **auto-referentes** (hierarquia)
- Usar `DEFERRABLE` pra adiar verificação até o fim da transação
- Falar sobre **normalização** (1FN, 2FN, 3FN) sem dor de cabeça

## 🔗 O que é uma FOREIGN KEY?
Uma chave estrangeira é uma coluna (ou conjunto) que **aponta** para a chave primária (ou única) de outra tabela. Ela garante uma promessa: *"o valor que está aqui existe lá"*.

Sem FK, nada impede você de inserir um `categoria_id = 9999` na tabela `produtos` — mesmo que essa categoria nunca tenha existido. Com FK, o Postgres **bate o pé** e bloqueia a operação. Isso é **integridade referencial**: a regra de que toda referência aponta pra algo real.

```sql
CREATE TABLE produtos (
    id           SERIAL PRIMARY KEY,
    nome         VARCHAR(200) NOT NULL,
    categoria_id INTEGER REFERENCES categorias(id)
);
```

A palavra mágica é `REFERENCES`. Dá pra escrever também com nome de constraint (recomendado em produção):

```sql
CREATE TABLE produtos (
    id           SERIAL PRIMARY KEY,
    nome         VARCHAR(200) NOT NULL,
    categoria_id INTEGER,
    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
```

Por que dar nome? Pra conseguir **dropar/alterar** depois sem ter que adivinhar o nome auto-gerado feio (`produtos_categoria_id_fkey`).

## ➕ Adicionar FK em tabela já existente
```sql
ALTER TABLE produtos
ADD CONSTRAINT fk_produto_categoria
FOREIGN KEY (categoria_id) REFERENCES categorias(id);
```

E pra remover:
```sql
ALTER TABLE produtos DROP CONSTRAINT fk_produto_categoria;
```

## 💣 ON DELETE — o que fazer quando o pai some?
Quando você deleta uma linha na tabela "pai" (a apontada), o que acontece com os "filhos" que dependem dela? Você decide.

| Política | O que faz |
|---|---|
| `NO ACTION` | **Default**. Erro: não deixa deletar se houver filhos. Checagem no fim do comando. |
| `RESTRICT` | Parecido com `NO ACTION`, mas a checagem é **imediata** (não dá pra adiar nem com `DEFERRABLE`). |
| `CASCADE` | Apaga junto. Deletou o pedido? Some todos os `itens_pedido`. **Cuidado.** |
| `SET NULL` | Coloca `NULL` no filho. Bom pra relações opcionais. Coluna precisa permitir NULL. |
| `SET DEFAULT` | Coloca o `DEFAULT` da coluna. Útil pra ter um "registro órfão" (ex: categoria_id = 1 = "Sem categoria"). |

```sql
-- Pedidos: se cliente sumir, mantém pedido com cliente_id NULL (histórico)
cliente_id INTEGER REFERENCES clientes(id) ON DELETE SET NULL

-- Itens do pedido: se pedido for cancelado/deletado, itens vão junto
pedido_id INTEGER REFERENCES pedidos(id) ON DELETE CASCADE

-- Produto: não deixa apagar se houver pedido referenciando (default)
produto_id INTEGER REFERENCES produtos(id) ON DELETE RESTRICT
```

## 🔄 ON UPDATE
Mesma ideia, mas pra quando a chave primária do pai muda. Como `id SERIAL` quase nunca muda, costuma ser irrelevante — **mas** se a FK aponta pra coluna natural (ex: CPF, código SKU), `ON UPDATE CASCADE` é útil.

```sql
codigo VARCHAR(20) PRIMARY KEY  -- na tabela pai
...
codigo_produto VARCHAR(20) REFERENCES produtos(codigo)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
```

## 🧩 FK composta
Às vezes a chave primária do pai tem **duas colunas**. A FK tem que espelhar isso:

```sql
CREATE TABLE turmas (
    curso_id   INTEGER,
    semestre   INTEGER,
    PRIMARY KEY (curso_id, semestre)
);

CREATE TABLE matriculas (
    aluno_id   INTEGER,
    curso_id   INTEGER,
    semestre   INTEGER,
    FOREIGN KEY (curso_id, semestre) REFERENCES turmas(curso_id, semestre)
);
```

Note: a FK referencia **as duas colunas juntas**, na mesma ordem da PK do pai.

## 🌳 FK auto-referente — hierarquia na mesma tabela
Categorias com subcategorias, comentários com respostas, funcionários com chefe… o filho aponta pra um pai **na própria tabela**:

```sql
CREATE TABLE categorias (
    id        SERIAL PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categorias(id) ON DELETE SET NULL
);

-- "Eletrônicos" sem pai
INSERT INTO categorias (nome, parent_id) VALUES ('Eletrônicos', NULL);
-- "Celulares" filha de Eletrônicos (id=1)
INSERT INTO categorias (nome, parent_id) VALUES ('Celulares', 1);
```

Pra consultar a árvore inteira você usa **CTE recursiva** (vamos ver no módulo de queries avançadas).

## ⏳ DEFERRABLE — adiar verificação
Às vezes você precisa inserir pai e filho na **mesma transação** e a ordem é chata (ex: importação em lote, dependência circular). `DEFERRABLE INITIALLY DEFERRED` deixa a checagem rolar só no `COMMIT`:

```sql
CREATE TABLE pedidos (
    id         SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id)
        DEFERRABLE INITIALLY DEFERRED
);

BEGIN;
INSERT INTO pedidos (cliente_id) VALUES (999);  -- ainda não existe, mas não erra agora
INSERT INTO clientes (id, nome, email) VALUES (999, 'X', 'x@x');
COMMIT;  -- agora a FK é checada. Tudo válido, passa.
```

Sem `DEFERRABLE`, o primeiro `INSERT` já daria erro. Use com moderação — geralmente é cheiro de modelagem ruim, mas tem casos legítimos.

## 👯 Relacionamentos: 1:1, 1:N, N:N

### 1:N (um-para-muitos) — o mais comum
Um cliente tem vários pedidos. A FK fica do **lado N** (na tabela de pedidos):
```sql
cliente_id INTEGER REFERENCES clientes(id)
```

### 1:1 (um-para-um) — raro mas existe
Cliente tem um único endereço de cobrança. A FK fica em qualquer um dos lados, com `UNIQUE`:
```sql
CREATE TABLE enderecos_cobranca (
    cliente_id INTEGER PRIMARY KEY REFERENCES clientes(id),
    rua        TEXT,
    cep        TEXT
);
```
A PK sendo a própria FK garante o 1:1 (não pode repetir).

### N:N (muitos-para-muitos) — precisa de tabela de junção
Produtos têm várias tags, tags estão em vários produtos. Não dá pra resolver com FK direta — precisa de **tabela do meio**:

```sql
CREATE TABLE tags (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE produto_tags (
    produto_id INTEGER REFERENCES produtos(id) ON DELETE CASCADE,
    tag_id     INTEGER REFERENCES tags(id)     ON DELETE CASCADE,
    PRIMARY KEY (produto_id, tag_id)
);
```

A PK composta `(produto_id, tag_id)` impede duplicatas (a mesma tag colada duas vezes no mesmo produto).

## 📐 Normalização — em 90 segundos
Normalizar = organizar pra evitar **redundância** e **anomalias**.

- **1FN (Primeira Forma Normal)**: cada célula tem **um único valor** atômico. Nada de "1, 2, 3" numa coluna só. Cada repetição vira linha.
- **2FN (Segunda)**: já tá em 1FN **e** toda coluna não-chave depende da chave **inteira** (relevante quando a PK é composta). Coluna que depende só de parte da PK → vai pra outra tabela.
- **3FN (Terceira)**: já tá em 2FN **e** não tem dependência transitiva. Ex: se `pedido` guarda `cliente_id, cliente_nome, cliente_email`, isso é redundante — `cliente_nome` depende de `cliente_id`, não de `pedido_id`. Manda nome/email pra tabela `clientes` e referencia.

Na prática 99% dos casos: chegou na 3FN, tá bom. Existem 4FN, 5FN, BCNF, mas raramente são o problema.

## 💡 Dicas de quem programa Postgres há tempo
- **Sempre indexe a coluna FK do lado filho.** O Postgres **não** cria índice automático em FK (só na PK). Sem índice, deletar o pai vira table scan no filho.
- **CASCADE é faca de dois gumes.** Em produção, prefira `RESTRICT` ou `SET NULL` e force a aplicação a lidar com isso. CASCADE silencioso já apagou banco inteiro.
- **Nomeie suas constraints.** `fk_<filho>_<pai>` é uma convenção limpa.
- **FK só funciona dentro do mesmo banco.** Pra "FK entre microservices", esquece — ou usa um banco só, ou implementa na aplicação.
- **Dê nome às tabelas de junção pelo conceito**, não só "ab" — ex: `inscricoes` é melhor que `aluno_curso`.

## 🚦 Próximos passos
1. Leia `pratica/queries.sql` e rode cada exercício
2. Faça o `desafio`: refatorar o schema da loja com integridade
3. Vá pro Módulo 12 — Constraints avançadas (CHECK, EXCLUSION)

## ✅ Auto-verificação
- [ ] Sei criar FK com `REFERENCES` e com `ALTER TABLE ADD CONSTRAINT`
- [ ] Sei explicar a diferença entre CASCADE, SET NULL, RESTRICT, NO ACTION
- [ ] Sei modelar uma N:N com tabela de junção
- [ ] Sei criar FK auto-referente pra hierarquia
- [ ] Sei o que é 1FN, 2FN e 3FN

Próximo módulo: **Constraints avançadas** — CHECK complexo, EXCLUDE, DOMAIN.
