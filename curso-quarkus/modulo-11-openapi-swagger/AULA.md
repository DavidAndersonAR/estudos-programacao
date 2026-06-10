# Módulo 11 — OpenAPI e Swagger UI

## 🎯 Objetivos

- Entender o que é a especificação **OpenAPI** e por que documentar uma API REST.
- Habilitar a extensão `quarkus-smallrye-openapi` para gerar a documentação automaticamente.
- Acessar o schema em `/q/openapi` e a interface visual em `/q/swagger-ui`.
- Enriquecer endpoints com anotações: `@Tag`, `@Operation`, `@APIResponse`, `@Schema`, `@Parameter`.
- Customizar título, versão e contato da API via `application.properties`.
- Liberar o Swagger UI também em produção.
- Conhecer `@SecurityScheme` para documentar autenticação.
- Gerar um client a partir do schema.

## O que é OpenAPI?

**OpenAPI** (antigo Swagger) é uma especificação aberta que descreve APIs REST num formato padrão (JSON ou YAML). Com esse arquivo você consegue:

- Gerar documentação navegável (Swagger UI, Redoc).
- Gerar clientes em qualquer linguagem (Java, TypeScript, Go) com `openapi-generator`.
- Validar contratos entre times back e front.
- Importar a API em ferramentas como Postman ou Insomnia.

O Quarkus, via SmallRye, **gera o schema automaticamente** lendo seus recursos JAX-RS. Você só precisa adicionar anotações pra dar mais detalhes.

## Habilitando

```bash
./mvnw quarkus:add-extension -Dextensions="quarkus-smallrye-openapi"
```

Subindo a app em dev (`./mvnw quarkus:dev`):

- Schema JSON: `http://localhost:8080/q/openapi`
- Schema YAML: `http://localhost:8080/q/openapi?format=YAML` (ou `/q/openapi.yaml`)
- Swagger UI: `http://localhost:8080/q/swagger-ui`

Por padrão, o **Swagger UI só fica disponível em modo dev e test**. Pra liberar em produção, ative a flag (mais abaixo).

## Anotações principais

| Anotação        | Onde usar          | Pra quê                                                          |
|-----------------|--------------------|------------------------------------------------------------------|
| `@Tag`          | Classe / método    | Agrupa endpoints por área (ex.: "Pedidos", "Clientes")           |
| `@Operation`    | Método             | Define `summary` e `description` do endpoint                     |
| `@APIResponse`  | Método             | Documenta cada status possível (200, 404, 500) com schema/exemplo|
| `@APIResponses` | Método             | Agrupa vários `@APIResponse`                                     |
| `@Parameter`    | Parâmetro          | Descreve query/path/header com exemplo                           |
| `@Schema`       | Classe / campo / parâmetro | Define exemplo, descrição, tipo, valor mínimo/máximo     |
| `@RequestBody`  | Parâmetro do body  | Documenta o corpo da requisição                                  |
| `@SecurityScheme` | Classe `Application` | Declara esquema de autenticação (JWT, OAuth2, Basic)         |

Exemplo curto:

```java
@GET
@Path("/{id}")
@Operation(summary = "Busca pedido por ID", description = "Retorna 404 se não existir")
@APIResponse(responseCode = "200", description = "Pedido encontrado",
    content = @Content(schema = @Schema(implementation = Pedido.class)))
@APIResponse(responseCode = "404", description = "Pedido não existe")
public Pedido buscar(@Parameter(description = "ID do pedido", example = "42") @PathParam("id") Long id) { ... }
```

## Customizando a info da API

Tudo via `application.properties`:

```properties
quarkus.smallrye-openapi.info-title=API de Pedidos
quarkus.smallrye-openapi.info-version=1.0.0
quarkus.smallrye-openapi.info-description=Gerencia pedidos da loja
quarkus.smallrye-openapi.info-contact-email=dev@loja.com
quarkus.smallrye-openapi.info-contact-name=Time Backend
quarkus.smallrye-openapi.info-license-name=Apache 2.0

# Liberar Swagger UI em prod
quarkus.swagger-ui.always-include=true
quarkus.swagger-ui.path=/docs
```

`quarkus.swagger-ui.path` muda o endpoint (default `/q/swagger-ui`).

## Security Scheme

Pra documentar que sua API exige JWT, anote a classe `JAXRSApplication` (ou qualquer classe `@ApplicationPath`):

```java
@SecurityScheme(
    securitySchemeName = "jwt",
    type = SecuritySchemeType.HTTP,
    scheme = "bearer",
    bearerFormat = "JWT"
)
public class MinhaApp extends Application {}
```

Depois, no endpoint protegido: `@SecurityRequirement(name = "jwt")`. O Swagger UI vai mostrar o botão **Authorize**.

## Gerando client a partir do schema

Com o `openapi.yaml` em mãos:

```bash
curl http://localhost:8080/q/openapi.yaml -o api.yaml
npx @openapitools/openapi-generator-cli generate -i api.yaml -g typescript-axios -o ./client
```

Isso gera um SDK TypeScript pronto pro frontend consumir.

## 💡 Detalhes

- O schema é **gerado em build time**, mas atualiza no dev mode a cada save.
- Se você usa Panache, evite expor a Entity direto — prefira DTOs com `@Schema` bem descritos.
- `@Schema(hidden = true)` esconde campos sensíveis (senha, token).
- A ordem dos endpoints no Swagger UI segue a ordem das tags.
- Pra trocar o tema do Swagger UI: `quarkus.swagger-ui.theme=flattop`.
- Existe também o **Redoc** via `quarkus.swagger-ui.theme=original` ou extensão separada.

## 🚦 Próximos passos

- Módulo 12: **Métricas** com Micrometer e Prometheus.
- Considere combinar OpenAPI + contract testing (Pact) pra garantir que mudanças não quebram clientes.

## ✅ Auto-verificação

- [ ] Acessei `/q/openapi` e vi o JSON gerado.
- [ ] Abri `/q/swagger-ui` e testei um endpoint pelo botão **Try it out**.
- [ ] Cada endpoint tem `@Operation`, pelo menos um `@APIResponse` e está agrupado por `@Tag`.
- [ ] Os DTOs têm `@Schema` com `example` nos campos principais.
- [ ] Configurei título, versão e contato em `application.properties`.
- [ ] Liberei o Swagger UI em produção com `quarkus.swagger-ui.always-include=true`.
- [ ] Gerei um client a partir do `openapi.yaml`.
