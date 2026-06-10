# Módulo 16 — JSON e JSONB

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Saber **quando usar JSONB** (e por que quase nunca usar `json`)
- Inserir, extrair e atualizar dados dentro de colunas JSONB
- Dominar os operadores `->`, `->>`, `#>`, `#>>`, `@>`, `<@`, `?`, `?|`, `?&`
- Usar funções como `jsonb_set`, `jsonb_array_elements`, `jsonb_agg`, `jsonb_path_query`
- Criar **índices GIN** pra que o JSONB voe em vez de rastejar
- Saber quando promover um campo JSONB pra **generated column**

## 🤔 Por que JSON dentro de um banco relacional?
O mundo real tem entidades com **forma fluida**: um produto eletrônico tem RAM e tela, uma camiseta tem tamanho e cor, um móvel tem dimensão e material. Modelar cada atributo como coluna vira pesadelo (centenas de colunas, a maioria NULL). Modelar cada atributo numa tabela EAV (entity-attribute-value) vira outro pesadelo (JOINs intermináveis).

JSONB resolve isso: você guarda um **documento estruturado** num campo, mantém **transação ACID**, e ainda consegue **indexar e consultar** com performance decente.

Não é desculpa pra largar tudo schemaless — JSONB é pra **a parte variável**. O que é estável (id, nome, preço) continua em colunas tipadas.

## 🆚 `json` vs `jsonb`
Postgres tem dois tipos. Quase sempre você quer **jsonb**:

| Aspecto | `json` | `jsonb` |
|---|---|---|
| Armazenamento | texto cru, como você escreveu | binário decodificado |
| Preserva espaços/ordem das chaves | sim | não |
| Velocidade de leitura | mais lenta (parseia toda vez) | rápida (já vem parseado) |
| Operadores avançados (`@>`, `?`) | não | **sim** |
| Indexável com GIN | não | **sim** |
| Insert | mais rápido (não decodifica) | um pouco mais lento |

**Regra**: use `jsonb`. Use `json` só se você precisa preservar o JSON original byte a byte (caso raríssimo, tipo log de auditoria).

## 🏗️ Criando coluna JSONB
```sql
CREATE TABLE eventos (
    id      SERIAL PRIMARY KEY,
    payload JSONB NOT NULL
);

INSERT INTO eventos (payload) VALUES
('{"tipo": "login", "user": "ana", "ip": "10.0.0.1"}'),
('{"tipo": "compra", "user": "joao", "itens": [{"sku": "A1", "qtd": 2}]}');
```

O Postgres valida o JSON na inserção. JSON inválido = erro.

## 🔧 Operadores essenciais

### Extrair campos: `->` e `->>`
- `->` retorna **jsonb** (pode encadear).
- `->>` retorna **text** (pra comparar, mostrar, indexar).

```sql
SELECT payload -> 'user'    FROM eventos;  -- "ana"  (jsonb com aspas)
SELECT payload ->> 'user'   FROM eventos;  -- ana    (texto puro)
SELECT payload -> 'itens' -> 0 ->> 'sku' FROM eventos;  -- A1
```

Para arrays use índice numérico (zero-based): `payload -> 'itens' -> 0`.

### Caminhos profundos: `#>` e `#>>`
Mesmo papel, mas em um único passo via array de chaves:

```sql
SELECT payload #>  '{itens,0,sku}' FROM eventos;  -- "A1"   (jsonb)
SELECT payload #>> '{itens,0,sku}' FROM eventos;  -- A1     (text)
```

### Contém / contido: `@>` e `<@`
O **mais usado** em buscas. Pergunta: "esse documento contém esse pedaço?"

```sql
-- Eventos de login
SELECT * FROM eventos WHERE payload @> '{"tipo": "login"}';

-- Eventos do usuário joao
SELECT * FROM eventos WHERE payload @> '{"user": "joao"}';
```

`@>` testa **subconjunto estrutural**. Funciona em chaves aninhadas. É o operador que melhor casa com **índice GIN**.

`<@` é o inverso (raramente útil).

### Chave existe: `?`, `?|`, `?&`
```sql
-- Tem a chave "ip"?
SELECT * FROM eventos WHERE payload ? 'ip';

-- Tem alguma dessas chaves?
SELECT * FROM eventos WHERE payload ?| ARRAY['ip', 'user_agent'];

-- Tem todas?
SELECT * FROM eventos WHERE payload ?& ARRAY['tipo', 'user'];
```

## ✏️ Atualizando: `jsonb_set`
JSONB é **imutável**: você substitui o valor inteiro. `jsonb_set` faz isso de forma cirúrgica.

```sql
-- Adiciona/atualiza payload.ip = '10.0.0.99' no evento id=1
UPDATE eventos
SET payload = jsonb_set(payload, '{ip}', '"10.0.0.99"')
WHERE id = 1;

-- Cria caminho que não existe? Use o 4º parâmetro = true (default)
UPDATE eventos
SET payload = jsonb_set(payload, '{geo,pais}', '"BR"', true)
WHERE id = 1;
```

Outras úteis:
- `jsonb_set_lax` — versão tolerante a NULL.
- `payload - 'chave'` — **remove** uma chave.
- `payload || '{"extra": true}'::jsonb` — **mescla** (último vence).

## 🧰 Funções de exploração e construção

### Explodir arrays e objetos
```sql
-- Cada item do array vira uma linha
SELECT id, item
FROM eventos, jsonb_array_elements(payload -> 'itens') AS item;

-- Iterar chave-valor de um objeto
SELECT key, value FROM jsonb_each('{"a":1, "b":2}'::jsonb);

-- Só as chaves
SELECT jsonb_object_keys('{"a":1, "b":2}'::jsonb);
```

### Construir JSONB
```sql
SELECT jsonb_build_object('nome', 'ana', 'idade', 30);
-- {"nome": "ana", "idade": 30}

-- Agregar várias linhas num array JSONB (combo poderoso com GROUP BY)
SELECT cliente_id, jsonb_agg(jsonb_build_object('pedido', id, 'status', status))
FROM pedidos
GROUP BY cliente_id;
```

### SQL/JSON Path (Postgres 12+): `jsonb_path_query`
Linguagem própria pra navegar/filtrar JSON, parecida com JSONPath/XPath.

```sql
-- Pegar todos os SKUs comprados
SELECT jsonb_path_query(payload, '$.itens[*].sku') FROM eventos;

-- Itens com quantidade > 1
SELECT jsonb_path_query(payload, '$.itens[*] ? (@.qtd > 1)') FROM eventos;
```

Pra quem vem de NoSQL é familiar. Pra quem só usou SQL, leva um tempinho — mas é a forma mais expressiva de varrer estruturas profundas.

## 🚀 Indexação com GIN
Sem índice, qualquer `@>` faz **sequential scan** — o JSONB foi parseado, mas pra cada linha o Postgres percorre o documento. Em 10 milhões de eventos, isso é morte.

```sql
-- Índice GIN clássico: indexa todas as chaves e valores
CREATE INDEX idx_eventos_payload ON eventos USING GIN (payload);

-- Variante mais leve e rápida pra buscas com @>:
CREATE INDEX idx_eventos_payload ON eventos USING GIN (payload jsonb_path_ops);
```

Diferença prática:
- **`jsonb_ops`** (default): suporta `@>`, `?`, `?|`, `?&`.
- **`jsonb_path_ops`**: só suporta `@>`, mas é **menor e mais rápido**. Se você só usa contains, escolha esse.

Depois disso:
```sql
EXPLAIN ANALYZE
SELECT * FROM eventos WHERE payload @> '{"tipo": "login"}';
-- Bitmap Index Scan on idx_eventos_payload
```

## 🎯 Generated columns — promovendo o JSONB
Quando um campo JSONB é consultado **toda hora** (filtros, joins, ordenação), promova-o pra coluna calculada — fica indexável como qualquer coluna comum:

```sql
ALTER TABLE eventos
ADD COLUMN tipo TEXT GENERATED ALWAYS AS (payload ->> 'tipo') STORED;

CREATE INDEX idx_eventos_tipo ON eventos (tipo);

SELECT * FROM eventos WHERE tipo = 'login';  -- usa B-tree, rapidíssimo
```

Você ganha o melhor dos dois mundos: documento flexível **e** colunas tipadas pra hot paths.

## 💡 Dicas de quem programa Postgres há tempo
- **Default é jsonb**. Se você criou uma coluna `json` sem motivo, troque pra `jsonb`.
- **Sempre indexe com GIN** assim que a tabela passa de uns 10k registros e você filtra por JSONB.
- **`@>` é seu melhor amigo** pra busca — projete suas queries em volta dele.
- **Não guarde tudo em JSONB**. Se um campo é **sempre** preenchido e **sempre** filtrado, ele merece coluna própria.
- **JSONB não tem schema** — você é responsável pela consistência. Considere `CHECK (payload ? 'tipo')` pra forçar campos obrigatórios.
- **Documentos enormes (>1MB) ficam em TOAST** e prejudicam performance. Quebre se passar disso.
- Pra **ordenar por número** dentro do JSONB, faça cast: `ORDER BY (payload ->> 'preco')::numeric`.

## 🚦 Próximos passos
1. Rode `pratica/queries.sql` (cria tabela `eventos`, brinca com operadores, cria índice GIN)
2. Faça o `desafio/queries.sql` — **Catálogo Flexível** com `produtos_v2`
3. Compare `EXPLAIN ANALYZE` antes e depois do índice GIN
4. Próximo módulo: **arrays nativos do Postgres**

## ✅ Auto-verificação
- [ ] Sei a diferença entre `->` e `->>`
- [ ] Sei usar `@>` pra buscar dentro do JSONB
- [ ] Crio índice GIN e entendo `jsonb_ops` vs `jsonb_path_ops`
- [ ] Atualizo campo aninhado com `jsonb_set`
- [ ] Sei quando vale promover um campo pra generated column

Próximo módulo: **arrays** — outro tipo flexível e poderoso do Postgres.
