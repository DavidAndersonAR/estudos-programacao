# Desafio — Catalogo de Produtos por Categoria

## Cenario
Voce vai modelar um pequeno catalogo: **Categoria** tem varios **Produto**s.

Use **PostgreSQL via Dev Services** (sem configurar URL).

## Requisitos

### Modelo
- `Categoria` (estilo **PanacheEntity** — active record)
  - `nome` (String)
  - `livros` ❌ digo, `produtos` (`List<Produto>`, `@OneToMany(mappedBy = "categoria", cascade = ALL)`)
- `Produto` (estilo **PanacheRepository** — pra praticar o outro estilo)
  - `nome` (String)
  - `preco` (BigDecimal)
  - `estoque` (Integer)
  - `categoria` (`@ManyToOne`)

### Endpoints
1. `GET /categorias` — lista categorias (sem trazer produtos no JSON; cuidado com LazyInit)
2. `GET /categorias/{id}/produtos` — produtos da categoria
3. `POST /categorias` — cria categoria
4. `POST /produtos` — cria produto (recebe `categoria.id` no body)
5. `GET /produtos?precoMin=X&precoMax=Y&pagina=0&tamanho=10` — filtro paginado
6. `PATCH /produtos/{id}/estoque?delta=N` — soma `delta` no estoque (pode ser negativo). Recuse se ficar negativo (HTTP 409).
7. `DELETE /categorias/{id}` — apaga categoria e seus produtos (`cascade`)

### Extras
- `import.sql` com pelo menos 3 categorias e 6 produtos
- `comandos.sh` com curl pra cada endpoint
- Toda escrita anotada com `@Transactional`

## Dicas
- Pra evitar LazyInit no `GET /categorias`, **nao serialize** a lista `produtos`. Opcoes:
  - Anotar o campo com `@JsonIgnore`
  - Criar um DTO/record `CategoriaResumo(Long id, String nome)`
- Pra `PATCH` de estoque: leia, valide, escreva. Dirty checking faz o UPDATE no commit.

## Auto-verificacao
- [ ] `quarkus dev` sobe e o Dev Services loga "Postgres started"
- [ ] Listo categorias sem estourar LazyInit
- [ ] Filtro de produtos paginado funciona com 0, 1 ou 2 parametros
- [ ] PATCH de estoque rejeita valor negativo
- [ ] DELETE de categoria leva os produtos junto

## Solucao
Os arquivos `.solucao` na mesma pasta tem uma proposta de implementacao. Tente sozinho primeiro!
