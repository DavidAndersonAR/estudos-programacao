# Módulo 20 — Validações + Exceções + Swagger

> Corresponde ao **Desafio Técnico Itaú** (Swagger + JUnit) do Java10x + *Specifications* (Exception handling) — agora você fecha a API com a qualidade que o mercado espera: dados validados, erros padronizados e documentação automática.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Validar payloads de entrada com **Bean Validation** (Jakarta Validation)
- Centralizar tratamento de erros com **@ControllerAdvice**
- Criar **exceções de negócio** próprias e mapeá-las pra HTTP
- Documentar a API automaticamente com **Springdoc / Swagger UI**

## 🧠 Por que esses três temas juntos?
Validações, exceções e documentação são o "polimento final" de qualquer API REST. Sem eles a API roda — mas:
- Sem validação: o usuário manda `idade = -7` e seu banco aceita
- Sem handler global: qualquer erro vira **stack trace de 50 linhas** no JSON
- Sem Swagger: ninguém sabe como chamar a sua API

É exatamente o que cai em entrevistas de pleito Java pra fintech (Itaú, Bradesco, Nubank).

---

## 1) Bean Validation (Jakarta Validation API)

A especificação Jakarta Validation define anotações declarativas que rodam **antes** do método controller ser chamado.

### Dependência (Spring Boot 3)
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### Anotações mais usadas

| Anotação | Onde aplica | O que faz |
|---|---|---|
| `@NotNull` | qualquer campo | proíbe `null` |
| `@NotBlank` | `String` | proíbe `null`, vazio ou só espaços |
| `@NotEmpty` | `String`, `Collection` | proíbe `null` ou vazio (mas aceita espaços) |
| `@Size(min, max)` | `String`, `Collection` | tamanho mínimo/máximo |
| `@Min(n)` / `@Max(n)` | numéricos | valor mínimo / máximo |
| `@Email` | `String` | formato de e-mail |
| `@Pattern(regexp=...)` | `String` | bate com regex |
| `@Positive` / `@Negative` | numéricos | sinal |
| `@Past` / `@Future` | datas | passado / futuro |

### Aplicando no DTO
```java
public record CriarUsuarioRequest(
    @NotBlank(message = "nome é obrigatório")
    @Size(min = 2, max = 100)
    String nome,

    @NotBlank @Email
    String email,

    @Min(value = 18, message = "precisa ter 18+")
    int idade
) {}
```

### Disparando a validação no controller
A anotação que **liga a engine** é `@Valid`:

```java
@PostMapping
public ResponseEntity<Usuario> criar(@Valid @RequestBody CriarUsuarioRequest req) {
    // só chega aqui se passou em todas as validações
    return ResponseEntity.status(201).body(service.criar(req));
}
```

Sem `@Valid` o Spring **ignora** as anotações do DTO. É o erro mais comum de quem está começando.

### O que acontece quando falha?
Spring lança `MethodArgumentNotValidException`. Sem handler global, vira HTTP 400 com JSON gigante e feio. Vamos resolver isso já já.

---

## 2) Exception Handling Global

### O problema
Por padrão, exceção não tratada vira stack trace no JSON. Cliente vê detalhe de implementação, e cada endpoint pode responder diferente para o mesmo erro. Inaceitável.

### A solução: `@ControllerAdvice`
Uma classe que **intercepta exceções de todos os controllers** e devolve um JSON padronizado.

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RecursoNaoEncontradoException.class)
    public ResponseEntity<ErroResponse> tratarNaoEncontrado(RecursoNaoEncontradoException ex) {
        return ResponseEntity.status(404).body(new ErroResponse(404, ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> tratarValidacao(MethodArgumentNotValidException ex) {
        Map<String, String> erros = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(e ->
            erros.put(e.getField(), e.getDefaultMessage())
        );
        return ResponseEntity.badRequest().body(erros);
    }
}
```

### Exceções de negócio próprias
Crie classes que estendem `RuntimeException` pra cada caso de erro do domínio:

```java
public class RecursoNaoEncontradoException extends RuntimeException {
    public RecursoNaoEncontradoException(String mensagem) { super(mensagem); }
}
```

Lança no service:
```java
return repo.findById(id)
    .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário " + id + " não existe"));
```

### `ProblemDetail` (Spring 6 / Boot 3)
Spring 6 trouxe `ProblemDetail` — implementação oficial da RFC 7807 (Problem Details for HTTP APIs). É o padrão moderno:

```java
@ExceptionHandler(RecursoNaoEncontradoException.class)
public ProblemDetail tratar(RecursoNaoEncontradoException ex) {
    ProblemDetail pd = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
    pd.setTitle("Recurso não encontrado");
    return pd;
}
```

Resposta JSON automática:
```json
{
  "type": "about:blank",
  "title": "Recurso não encontrado",
  "status": 404,
  "detail": "Usuário 99 não existe"
}
```

---

## 3) Swagger / OpenAPI com Springdoc

OpenAPI é a especificação (sucessor do Swagger 2.0). **Springdoc** é a biblioteca que gera a documentação OpenAPI automaticamente a partir dos seus controllers Spring.

### Dependência
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.5.0</version>
</dependency>
```

Pronto. Subiu a aplicação, abra no browser:
- `http://localhost:8080/swagger-ui.html` — UI interativa
- `http://localhost:8080/v3/api-docs` — JSON do OpenAPI

### Anotações para enriquecer a doc

```java
@RestController
@RequestMapping("/usuarios")
@Tag(name = "Usuários", description = "CRUD de usuários")
public class UsuarioController {

    @Operation(summary = "Cria um usuário", description = "Recebe DTO validado e persiste")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Criado"),
        @ApiResponse(responseCode = "400", description = "Dados inválidos")
    })
    @PostMapping
    public ResponseEntity<Usuario> criar(@Valid @RequestBody CriarUsuarioRequest req) {
        ...
    }
}
```

| Anotação | Para que serve |
|---|---|
| `@Tag` | agrupa endpoints (vira a "seção" no Swagger UI) |
| `@Operation` | descreve um endpoint específico |
| `@ApiResponses` / `@ApiResponse` | documenta cada possível status HTTP |
| `@Parameter` | descreve query/path params |
| `@Schema` | descreve campos de DTOs |

### Customizando o caminho
No `application.properties`:
```properties
springdoc.swagger-ui.path=/docs
springdoc.api-docs.path=/api-docs
```

---

## 🧱 Stack final do nosso curso

| Camada | Tecnologia |
|---|---|
| Linguagem | Java 21 |
| Framework | Spring Boot 3 |
| Persistência | JPA + Hibernate + H2/PostgreSQL |
| Validação | Jakarta Validation (Bean Validation) |
| Documentação | Springdoc OpenAPI |
| Testes | JUnit 5 + Mockito |

Isso é o **stack padrão de mercado** pra back-end Java em 2026.

---

## 💡 Pegadinhas que valem ouro
- **Esqueceu o `@Valid`?** Spring ignora silenciosamente as anotações. Sempre confira.
- **`@NotNull` vs `@NotBlank`**: `@NotNull` aceita string vazia `""`. Pra String, quase sempre você quer `@NotBlank`.
- **`@ControllerAdvice` precisa estar no pacote escaneado** pelo Spring — coloque junto com os controllers.
- **Ordem de handlers**: mais específico primeiro. `Exception.class` por último (catch-all).
- **Não exponha `Throwable.getMessage()` cru** em produção sem revisar — pode vazar info sensível.
- **Springdoc 2.x** = Spring Boot 3 (Jakarta). Versões 1.x são pra Boot 2 (javax). Não misture.

## 🚦 Próximos passos
1. Leia **`pratica/Main.java`** — DTO validado, handler global, controller documentado.
2. Encare o **desafio**: API Completa Documentada (CRUD + validações + handler + swagger).
3. Suba a aplicação e abra `http://localhost:8080/swagger-ui.html` no browser — interaja com os endpoints direto da UI.

## ✅ Auto-verificação
- [ ] Sei quando usar `@NotNull`, `@NotBlank` e `@NotEmpty`
- [ ] Lembro que `@Valid` no controller é o que **liga** a validação
- [ ] Sei criar um `@ControllerAdvice` com `@ExceptionHandler`
- [ ] Conheço `ProblemDetail` (RFC 7807)
- [ ] Sei adicionar Springdoc e acessar `/swagger-ui.html`
- [ ] Uso `@Tag` e `@Operation` pra enriquecer a doc

Próximo módulo: **Testes Unitários com JUnit 5 + Mockito** — o último passo do desafio Itaú.
