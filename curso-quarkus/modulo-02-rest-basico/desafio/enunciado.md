# 🎯 Desafio do Módulo 02 — API de Filmes

## Contexto
Você vai construir um CRUD bem parecido com o de Livros da prática, mas pra **Filme**. A ideia é fixar `@Path`, params, JSON e status codes sem olhar a solução.

## O recurso `Filme`
Campos:
- `id` (Long) — gerado pelo servidor
- `nome` (String)
- `ano` (Integer)
- `diretor` (String)
- `nota` (Double) — 0.0 a 10.0

## Endpoints esperados

| Método | URL                              | O que faz                                                    | Status esperado |
|--------|----------------------------------|---------------------------------------------------------------|-----------------|
| GET    | `/filmes`                        | Lista todos                                                   | 200             |
| GET    | `/filmes?diretor=Nolan`          | Filtra por diretor (case-insensitive)                         | 200             |
| GET    | `/filmes?notaMinima=8.0`         | Só filmes com `nota >= 8.0`                                   | 200             |
| GET    | `/filmes/{id}`                   | Busca um                                                      | 200 ou 404      |
| POST   | `/filmes`                        | Cria. Header `Location: /filmes/{id}` na resposta             | 201             |
| PUT    | `/filmes/{id}`                   | Atualiza inteiro                                              | 200 ou 404      |
| DELETE | `/filmes/{id}`                   | Remove                                                        | 204 ou 404      |

Dica extra: os 2 filtros de GET (`diretor` e `notaMinima`) podem vir juntos na mesma requisição — combine.

## TODOs

1. **Crie `Filme.java`** no mesmo pacote do seu Resource. Campos públicos (igual `Livro.java`) ou getters/setters — Jackson aceita os dois.
2. **Crie `FilmeResource.java`** com `@Path("/filmes")`.
3. **Armazenamento em memória**: use `ConcurrentHashMap<Long, Filme>` + `AtomicLong` pra gerar ids. Não precisa de banco.
4. **No construtor**, popule 3-4 filmes pra ter dado de teste.
5. **Implemente cada endpoint** da tabela acima.
6. **Use `Response`** pra controlar status code e header `Location` no POST.
7. **Use `@RestQuery`** pros filtros opcionais. Lembre: `null` quando o cliente omite.
8. **Teste com curl**:
   ```bash
   curl http://localhost:8080/filmes
   curl "http://localhost:8080/filmes?notaMinima=8.5"
   curl "http://localhost:8080/filmes?diretor=Nolan&notaMinima=8.0"
   curl -i -X POST http://localhost:8080/filmes \
     -H "Content-Type: application/json" \
     -d '{"nome":"Interestelar","ano":2014,"diretor":"Nolan","nota":8.7}'
   curl -i -X DELETE http://localhost:8080/filmes/1
   ```

## Critério de "tá pronto"
- [ ] Os 7 endpoints respondem corretamente
- [ ] POST devolve **201** + header `Location`
- [ ] DELETE devolve **204** quando dá certo, **404** quando id não existe
- [ ] Filtros combinados funcionam (`?diretor=X&notaMinima=Y`)
- [ ] Você não precisou olhar a solução enquanto fazia

## Quando travar
Releia `pratica/LivroResource.java` — a estrutura é quase idêntica. Só depois disso, se ainda travado, abra `FilmeResource.java.solucao`.

> A solução tem extensão `.solucao` de propósito: o `quarkus dev` não compila arquivos com essa extensão. Pra rodar, renomeie pra `.java`.
