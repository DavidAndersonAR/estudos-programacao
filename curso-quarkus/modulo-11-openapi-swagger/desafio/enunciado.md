# Desafio — Módulo 11: Documentando uma API de Clientes

## 🎯 Objetivo

Criar uma API REST `/clientes` com **4 endpoints** totalmente documentados com OpenAPI, agrupados por `@Tag`, com `@Operation`, `@APIResponse` (cobrindo status de sucesso e erro), `@Schema` com exemplos e `@Parameter` nos parâmetros.

## 📋 Requisitos

### 1. Modelo `Cliente`
- Campos: `id` (Long), `nome` (String), `email` (String), `cpf` (String), `ativo` (boolean).
- Use `@Schema` em todos os campos com **descrição e exemplo**.
- `id` deve ser `readOnly`.
- `email` deve ter `pattern` ou `format = "email"`.

### 2. Resource `ClienteResource`
Anote a classe com `@Tag(name = "Clientes", description = "...")`.

Crie os endpoints:

| Método | Caminho             | Operation summary           | Responses obrigatórios |
|--------|---------------------|-----------------------------|------------------------|
| GET    | `/clientes`         | Lista todos                 | 200 |
| GET    | `/clientes/{id}`    | Busca por ID                | 200, 404 |
| POST   | `/clientes`         | Cria novo cliente           | 201, 400 |
| PATCH  | `/clientes/{id}/ativar` | Reativa um cliente inativo | 200, 404, 409 (se já ativo) |

Cada endpoint precisa de:
- `@Operation` com `summary` E `description`.
- `@APIResponse` pra cada status listado, com `description`.
- `@Parameter` com `description` e `example` em todos os path params.
- `@RequestBody` documentado no POST.

### 3. `application.properties`
Configure pelo menos:
- `info-title`, `info-version`, `info-description`.
- `info-contact-email`.
- Ative `quarkus.swagger-ui.always-include=true`.
- Mude o `path` do swagger-ui pra `/docs`.

### 4. Validação manual
- Abra `/docs` (path customizado) e confira que cada endpoint mostra os responses certos.
- Baixe `/q/openapi.yaml` e procure pelas tags, exemplos e descrições.

## 🌟 Bônus

- Adicione `@SecurityScheme` na classe `Application` declarando JWT Bearer.
- Marque `POST` e `PATCH` com `@SecurityRequirement(name = "jwt")`.
- Gere um client TS com `openapi-generator-cli` e cole o comando usado em `comandos.solucao.sh`.

## ✅ Critérios de aceite

- [ ] Os 4 endpoints aparecem agrupados sob a tag **Clientes** no Swagger UI.
- [ ] Cada response (200/201/400/404/409) tem descrição clara.
- [ ] Os campos de `Cliente` mostram exemplos no schema do Swagger UI.
- [ ] O título e contato configurados aparecem no topo do Swagger UI.
- [ ] O Swagger UI fica disponível em `http://localhost:8080/docs` mesmo após `./mvnw package` e `java -jar`.

## 💡 Dicas

- Pra status 409, use `Response.status(409)` ou `Response.Status.CONFLICT`.
- `@Schema(format = "email")` é suficiente pra validação visual no Swagger.
- Use `@APIResponses({ ... })` pra agrupar vários `@APIResponse`.
