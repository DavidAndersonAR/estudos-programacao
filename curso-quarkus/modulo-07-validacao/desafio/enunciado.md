# Desafio — Cadastro de Empresa com validações

## 🎯 Objetivo
Construir o endpoint `POST /empresas` que recebe um `EmpresaDTO` e responde:
- **201 Created** quando o payload é válido
- **400 Bad Request** (estruturado pelo Quarkus) quando algo falha

Você deve criar uma **constraint customizada `@CNPJ`** (só valida formato) e usá-la no DTO.

## 📋 Regras do `EmpresaDTO`

Mínimo de **6 validações** no DTO, contemplando:

1. `razaoSocial` — `String`, obrigatório, entre 3 e 120 caracteres
2. `nomeFantasia` — `String`, opcional, no máximo 80 caracteres
3. `cnpj` — `String`, obrigatório, **validado pela anotação customizada `@CNPJ`** (formato `00.000.000/0000-00`)
4. `emailContato` — `String`, obrigatório, formato e-mail
5. `quantidadeFuncionarios` — `Integer`, obrigatório, **maior ou igual a 1**, no máximo 1.000.000
6. `dataFundacao` — `LocalDate`, obrigatório, deve estar **no passado**
7. `site` — `String`, opcional, deve casar com regex `^https?://.+`
8. (Bônus) `endereco` — objeto aninhado validado em cascade com `@Valid`

## 🛠️ Constraint customizada `@CNPJ`

- Anotação em `jakarta.validation.Constraint`
- Validador implementando `ConstraintValidator<CNPJ, String>`
- Só precisa validar **formato** (regex): `XX.XXX.XXX/XXXX-XX`
- Mensagem default em português: `"CNPJ inválido (use 00.000.000/0000-00)"`
- `null` deve passar — quem trata `null` é `@NotBlank`/`@NotNull`

## 🚪 Endpoint

```java
@POST
@Path("/empresas")
public Response criar(@Valid EmpresaDTO dto) { ... }
```

Use `@Valid` — não precisa montar resposta de erro à mão, o Quarkus faz.

## ✅ Critério de aceitação

| Caso | Body | Esperado |
|---|---|---|
| Tudo válido | Todos os campos OK | 201 |
| CNPJ formato errado | `"cnpj": "12345678000100"` | 400 com violação de `@CNPJ` |
| E-mail ruim | `"emailContato": "naoeemail"` | 400 |
| `quantidadeFuncionarios: 0` | | 400 (viola `@Min(1)`) |
| `dataFundacao` no futuro | `"2099-01-01"` | 400 (`@Past`) |
| `razaoSocial: "AB"` | | 400 (`@Size min`) |

Rode os curls e observe o array `violations` no JSON de resposta.

## 💡 Dicas
- Olhe a `pratica/` — o `@CPF` é praticamente o template do `@CNPJ`
- Regex do CNPJ: `\\d{2}\\.\\d{3}\\.\\d{3}/\\d{4}-\\d{2}`
- Lembre que `@Email`, `@Pattern`, `@Past` só validam **valores não-null** — combine com `@NotBlank`/`@NotNull` quando o campo for obrigatório

## 🏁 Quando terminar
Compare seus arquivos com os `.solucao` desta pasta.
