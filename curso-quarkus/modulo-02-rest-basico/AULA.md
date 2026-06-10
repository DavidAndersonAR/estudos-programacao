# Módulo 02 — REST básico com RESTEasy Reactive

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Mapear endpoints com `@Path`, `@GET`, `@POST`, `@PUT`, `@DELETE`
- Ler **path params** (`/livros/42`) e **query params** (`?autor=Tolkien`)
- Receber e devolver **JSON** automaticamente
- Controlar **status code** e **headers** com `Response`
- Saber a diferença entre `RestPath`/`RestQuery` (Quarkus) e `@PathParam`/`@QueryParam` (JAX-RS)

## 🧱 RESTEasy Reactive (a engine REST do Quarkus)

Quando você criou o projeto com `--extension=rest-jackson`, o Quarkus puxou o **RESTEasy Reactive** — a implementação JAX-RS dele, reescrita pra ser rápida e não-bloqueante.

Detalhe importante: você **não precisa** programar reativo pra usar. Métodos `public String hello()` funcionam normal. O "reactive" é interno — você ganha performance de graça.

## 🛣️ Anatomia de um endpoint

```java
@Path("/livros")
public class LivroResource {

    @GET
    @Path("/{id}")
    public Livro buscar(@RestPath Long id) {
        return repositorio.get(id);
    }
}
```

- `@Path("/livros")` na classe → prefixo de todos os métodos
- `@Path("/{id}")` no método → completa pra `/livros/{id}`
- `@GET` → método HTTP
- `@RestPath Long id` → pega o `{id}` da URL e converte pra `Long`

URL final: `GET /livros/42` → chama `buscar(42L)`.

## 📥 Path params: 2 jeitos

**Jeito Quarkus (recomendado, menos verboso):**
```java
public Livro buscar(@RestPath Long id) { ... }
```
Nome do parâmetro Java tem que casar com `{id}` na URL.

**Jeito JAX-RS padrão (funciona em qualquer servidor Jakarta):**
```java
public Livro buscar(@PathParam("id") Long id) { ... }
```
Aqui o nome do parâmetro Java pode ser qualquer um — o que importa é o `"id"` na anotação.

Use `@RestPath` quando estiver em Quarkus. Conheça `@PathParam` porque você vai ver em código antigo.

## 🔎 Query params

URL: `GET /livros?autor=Tolkien&limite=10`

```java
@GET
public List<Livro> listar(
        @RestQuery String autor,
        @RestQuery Integer limite) {
    // autor pode vir null se omitido
    // limite idem
}
```

Versão JAX-RS: `@QueryParam("autor") String autor`.

Valor default quando o cliente omite:
```java
@RestQuery @DefaultValue("20") Integer limite
```

## 📦 JSON automático (Jackson)

Com a extensão `rest-jackson`, **objetos Java viram JSON sozinhos** na resposta, e **JSON do request vira objeto** nos parâmetros:

```java
@POST
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Livro criar(Livro novo) {
    novo.id = proximoId();
    livros.put(novo.id, novo);
    return novo;
}
```

Na verdade, **`@Consumes`/`@Produces` JSON são o default** no RESTEasy Reactive quando você tem rest-jackson. Você pode omitir — só coloca quando quer ser explícito ou usar outro media type.

## 🔢 Status codes com `Response`

Retornar o objeto direto dá **200 OK**. Pra controlar o status, devolva `Response`:

```java
@POST
public Response criar(Livro novo) {
    novo.id = proximoId();
    livros.put(novo.id, novo);
    return Response.status(201)         // Created
            .entity(novo)
            .header("Location", "/livros/" + novo.id)
            .build();
}

@DELETE
@Path("/{id}")
public Response remover(@RestPath Long id) {
    Livro removido = livros.remove(id);
    if (removido == null) {
        return Response.status(404).build();   // Not Found
    }
    return Response.noContent().build();        // 204
}
```

Atalhos úteis:
- `Response.ok(obj).build()` → 200 com body
- `Response.created(uri).entity(obj).build()` → 201
- `Response.noContent().build()` → 204
- `Response.status(Response.Status.NOT_FOUND).build()` → 404

Você também pode lançar `WebApplicationException(404)` — Quarkus converte em resposta. Tratamento de erros bonito vem no Módulo 08.

## 🧾 Headers

Ler header do request:
```java
public String agente(@RestHeader("User-Agent") String ua) { ... }
```

Devolver header na resposta:
```java
Response.ok(livro).header("X-Total-Count", "42").build()
```

## 💡 Detalhes que valem ouro
- **Não precisa de `@ApplicationScoped`** no Resource — RESTEasy já gerencia o ciclo de vida. Mas pode anotar se quiser injeção CDI dentro dele (Módulo 03).
- **`@Path` aceita regex**: `@Path("/{id: \\d+}")` casa só com números. URL com letra vai dar 404 antes de entrar no método.
- **Tipos suportados em `@RestPath`/`@RestQuery`**: primitivos, wrappers, `String`, `UUID`, `LocalDate`, `enum`, qualquer tipo com construtor `String` ou método `valueOf(String)`.
- **`List<String> tags` em query param**: `?tags=java&tags=rest` vira lista de 2 itens automaticamente.
- **Dev UI** (http://localhost:8080/q/dev) tem uma seção **Endpoints** onde você vê todos os mapeamentos e pode testar direto do browser.
- **Order matters**: rotas mais específicas vêm antes. `/livros/destaques` precisa ser declarado antes de `/livros/{id}`, ou `{id}` engole "destaques".
- **JSON com campos extras**: por padrão Jackson reclama de campos desconhecidos. Configure em `application.properties`: `quarkus.jackson.fail-on-unknown-properties=false`.

## 🚦 Próximos passos
1. Abra `pratica/` e copie o `LivroResource.java` + `Livro.java` pro seu projeto
2. Rode `quarkus dev`
3. Use o `comandos.sh` (curls) pra testar cada endpoint
4. Veja os endpoints na Dev UI
5. Encare o desafio do Filme

## ✅ Auto-verificação
- [ ] Sei a diferença entre `@RestPath` e `@PathParam`
- [ ] Sei devolver 201, 204 e 404 com `Response`
- [ ] Entendo que JSON é automático quando tem rest-jackson
- [ ] Sei ler query params opcionais e com default
- [ ] Consegui rodar o CRUD de livros e testar todos os curls

Próximo módulo: **Injeção de Dependência (CDI)** — separando Resource de "Repository/Service".
