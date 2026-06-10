# Módulo 07 — Validação com Hibernate Validator

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Validar payloads de entrada com **Bean Validation** (Jakarta Validation)
- Usar `@Valid` em parâmetros de endpoint pra disparar validação automática
- Entender a resposta **400 estruturada** que o Quarkus devolve de graça
- Validar **programaticamente** com `Validator` quando precisar
- Criar uma **constraint customizada** (ex.: `@CPF`)
- Separar regras por **grupos de validação** (criação vs atualização)

## 🧰 A extensão

```bash
quarkus extension add hibernate-validator
```

Ou no `pom.xml` já vem se você marcou no `create`. Ela traz o **Hibernate Validator**, a implementação de referência da spec **Jakarta Validation**. As anotações vivem em `jakarta.validation.constraints.*`.

Quando RESTEasy Reactive (Módulo 02) detecta um parâmetro com `@Valid`, ele aciona o validador antes do método rodar. Se algo falha, **o endpoint nem é chamado** — Quarkus já devolve 400.

## 📋 Anotações mais comuns

| Anotação | Aplica em | O que faz |
|---|---|---|
| `@NotNull` | qualquer | Não pode ser `null` |
| `@NotBlank` | `String` | Não null, não vazio, não só espaços |
| `@NotEmpty` | `String`, `Collection`, array, `Map` | Não null e tamanho > 0 |
| `@Size(min=, max=)` | `String`, `Collection`... | Tamanho dentro do range |
| `@Min(n)` / `@Max(n)` | numéricos | Valor mínimo/máximo |
| `@Positive` / `@Negative` | numéricos | Sinal (variantes `*OrZero`) |
| `@Email` | `String` | Formato de e-mail |
| `@Pattern(regexp=)` | `String` | Bate com regex |
| `@Past` / `@Future` | `LocalDate`, `LocalDateTime`... | Data no passado/futuro |
| `@Digits(integer=, fraction=)` | numéricos | Quantidade de dígitos |
| `@AssertTrue` / `@AssertFalse` | `boolean` | Valor booleano esperado |

Todas aceitam `message = "..."` pra customizar a mensagem retornada.

## 🧱 DTO validado

```java
public class UsuarioDTO {

    @NotBlank
    @Size(min = 3, max = 60)
    public String nome;

    @NotBlank
    @Email
    public String email;

    @NotNull
    @Min(18)
    @Max(120)
    public Integer idade;

    @Past
    public LocalDate nascimento;
}
```

## 🚪 Validando no endpoint com `@Valid`

```java
@POST
@Path("/usuarios")
public Response criar(@Valid UsuarioDTO dto) {
    // se chegou aqui, todos os campos passaram
    return Response.status(201).entity(dto).build();
}
```

`@Valid` faz **cascade**: se `UsuarioDTO` tiver um campo `@Valid EnderecoDTO endereco`, o endereço também é validado.

Pra params simples (query, path) você anota direto:

```java
@GET
public List<UsuarioDTO> listar(@RestQuery @NotNull @Min(1) Integer pagina) { ... }
```

> Pra `@NotNull` em parâmetros funcionar, a classe Resource precisa ter `@ApplicationScoped` (ou outro escopo CDI). Sem CDI, anotações em parâmetros não disparam.

## 📤 Resposta 400 default do Quarkus

Mande um `POST /usuarios` com body inválido:

```json
{ "nome": "Jo", "email": "naoeemail", "idade": 15 }
```

Quarkus responde **400** com algo assim:

```json
{
  "title": "Constraint Violation",
  "status": 400,
  "violations": [
    { "field": "criar.dto.nome",  "message": "tamanho deve ser entre 3 e 60" },
    { "field": "criar.dto.email", "message": "deve ser um endereço de e-mail bem formado" },
    { "field": "criar.dto.idade", "message": "deve ser maior ou igual a 18" }
  ]
}
```

Pronto, sem escrever uma linha de tratamento de erro. Pra customizar essa resposta, você cria um `ExceptionMapper<ConstraintViolationException>` — assunto do Módulo 08.

## 🔧 Validação programática

Quando a regra não cabe num endpoint (ex.: validar dentro de um service), injete o `Validator`:

```java
@ApplicationScoped
public class UsuarioService {

    @Inject
    Validator validator;

    public void cadastrar(UsuarioDTO dto) {
        Set<ConstraintViolation<UsuarioDTO>> erros = validator.validate(dto);
        if (!erros.isEmpty()) {
            throw new ConstraintViolationException(erros);
        }
        // ...
    }
}
```

## 🛠️ Constraint customizada (`@CPF`)

Duas peças: a **anotação** e o **validador**.

```java
@Target({ FIELD, PARAMETER })
@Retention(RUNTIME)
@Constraint(validatedBy = CPFValidator.class)
public @interface CPF {
    String message() default "CPF inválido (use 000.000.000-00)";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
```

```java
public class CPFValidator implements ConstraintValidator<CPF, String> {
    private static final Pattern P = Pattern.compile("\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}");

    @Override
    public boolean isValid(String valor, ConstraintValidatorContext ctx) {
        if (valor == null) return true;   // delegue null pra @NotNull
        return P.matcher(valor).matches();
    }
}
```

Uso: `@CPF public String cpf;` no DTO. Pronto, vira mais uma `@NotBlank` da vida.

> Aqui só validamos **formato**. Cálculo dos dígitos verificadores você adiciona depois — princípio é o mesmo.

## 🏷️ Grupos de validação

Útil quando o mesmo DTO serve pra **criar** (id null) e **atualizar** (id obrigatório):

```java
public interface Grupos {
    interface Criar {}
    interface Atualizar {}
}
```

```java
public class UsuarioDTO {
    @Null(groups = Grupos.Criar.class)
    @NotNull(groups = Grupos.Atualizar.class)
    public Long id;
    // ...
}
```

No endpoint, em vez de `@Valid`, use `@ConvertGroup` ou a anotação `@org.hibernate.validator.constraints.ConvertGroup` — porém o jeito mais simples no Quarkus é o `@ConvertGroup` da Jakarta:

```java
@POST
public Response criar(@Valid @ConvertGroup(to = Grupos.Criar.class) UsuarioDTO dto) { ... }

@PUT @Path("/{id}")
public Response atualizar(@Valid @ConvertGroup(to = Grupos.Atualizar.class) UsuarioDTO dto) { ... }
```

Sem grupo, validações sem `groups` declarados rodam por padrão (grupo `Default.class`).

## 🌍 Mensagens i18n

Hibernate Validator já vem com pacote `ValidationMessages_pt_BR.properties` em algumas distros. Pra forçar português ou customizar, crie em `src/main/resources/ValidationMessages.properties`:

```
jakarta.validation.constraints.NotBlank.message=campo obrigatório
jakarta.validation.constraints.Email.message=e-mail inválido
```

Quarkus carrega esse arquivo automaticamente.

## 💡 Detalhes
- **`null` é responsabilidade do `@NotNull`** — `@Email`, `@Size`, `@Pattern` etc. consideram `null` como válido. Combine: `@NotBlank @Email`.
- **`@NotBlank` é só pra `String`**. Pra coleção use `@NotEmpty`.
- **`@Valid` não é recursivo automaticamente**: dentro do DTO, anote o campo aninhado com `@Valid` também.
- **Records funcionam**: anote os componentes — `record UsuarioDTO(@NotBlank String nome, @Email String email) {}`.
- **Não valide entidade JPA direto no endpoint** — receba DTO, valide, depois mapeie. Misturar persistência com payload é fonte de bug.
- Dev UI tem a aba **Bean Validation** mostrando todas as constraints carregadas.

## 🚦 Próximos passos
1. Copie os arquivos de `pratica/` (DTO, Resource, `@CPF` + validator, grupos)
2. Rode `quarkus dev`
3. Execute `comandos.sh` — observe o 400 estruturado nos casos inválidos
4. Encare o desafio: cadastro de **Empresa** com `@CNPJ` customizado

## ✅ Auto-verificação
- [ ] Sei usar as anotações básicas (`@NotBlank`, `@Email`, `@Size`, `@Min`...)
- [ ] Entendo o que `@Valid` faz e por que precisa dele no parâmetro
- [ ] Sei que Quarkus retorna 400 estruturado sem eu escrever nada
- [ ] Consigo validar programaticamente com `Validator`
- [ ] Sei criar uma constraint customizada (anotação + `ConstraintValidator`)
- [ ] Sei usar grupos pra mudar regras entre `POST` e `PUT`

Próximo módulo: **Tratamento de erros** — `ExceptionMapper`, formato padronizado, problem+json.
