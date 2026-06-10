# Módulo 08 — Tratamento de erros com `ExceptionMapper`

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar **exceções customizadas** com significado de negócio
- Mapear exceção para resposta HTTP com `ExceptionMapper<E>` + `@Provider`
- Padronizar payload de erro seguindo **RFC 7807** (`application/problem+json`)
- Tratar **`ConstraintViolationException`** (validação) e **`PersistenceException`** (banco)
- Logar erro do servidor sem **vazar stack trace** pro cliente
- Entender a **ordem de prioridade** entre mappers

## 🤔 Por que padronizar erro

Quando o backend devolve erro de qualquer jeito ("string aqui, JSON ali, HTML lá no 500"), o cliente vira um pesadelo de parsing. Um payload padrão muda isso:

- Front sabe **sempre** onde ler a mensagem
- Mobile consegue **traduzir** baseado em um `code` estável
- Observabilidade casa o `traceId` da resposta com o log do servidor
- Time de QA escreve teste contra um contrato, não contra texto livre

A IETF resolveu isso com a **RFC 7807 — Problem Details for HTTP APIs**. É só um JSON com campos padronizados e `Content-Type: application/problem+json`.

## 📐 Anatomia do payload (RFC 7807)

Campos canônicos:
```json
{
  "type": "https://api.exemplo.com/erros/produto-nao-encontrado",
  "title": "Produto não encontrado",
  "status": 404,
  "detail": "Não existe produto com id 42",
  "instance": "/produtos/42"
}
```

Você pode (e deve) **estender** com campos do seu domínio: `code`, `traceId`, `errors[]`. A RFC permite. Só não conflite com os 5 padrão.

## 🧩 Anatomia do `ExceptionMapper`

```java
@Provider
public class MeuMapper implements ExceptionMapper<MinhaException> {
    @Override
    public Response toResponse(MinhaException ex) {
        return Response.status(404)
                .type("application/problem+json")
                .entity(new ProblemDetail(...))
                .build();
    }
}
```

- **`@Provider`** — Quarkus descobre no startup e registra
- **`ExceptionMapper<E>`** — `E` é a exceção que você captura
- **`toResponse`** — devolve `Response` (status + body + headers)

Não precisa registrar em lugar nenhum. Basta a classe estar no classpath com `@Provider`.

## 📚 Ordem dos mappers (mais específico ganha)

Se você tem mapper pra `Exception` e outro pra `RecursoNaoEncontradoException` (que herda de `RuntimeException`), o RESTEasy escolhe o **mais próximo na hierarquia**. Regra prática:

- Um mapper **específico** por exceção customizada
- Mappers pras "famosas": `ConstraintViolationException`, `PersistenceException`, `NotFoundException`
- **Um catch-all `Exception`** no fim como rede de segurança → 500 genérico

Não dá pra deixar duas implementações pra mesma classe — Quarkus reclama no startup.

## 🔥 Exceções comuns no Quarkus

| Origem | Exceção | Status sugerido |
|---|---|---|
| `@Valid` falhou no body | `ConstraintViolationException` | **422** Unprocessable Entity |
| `Panache.findById` + você decidiu lançar | sua `RecursoNaoEncontradoException` | **404** |
| `WebApplicationException(404)` | já vem mapeada | 404 |
| `EntityExistsException` (PK duplicada) | sua `ConflitoException` | **409** |
| Banco offline / constraint violada | `PersistenceException` | **500** ou **409** |
| Qualquer outra | `Exception` | **500** "Erro interno" |

Cuidado: **`PanacheEntityBase.findById` retorna `null`** quando não acha. Não lança nada sozinho. Você é quem decide:

```java
Produto p = Produto.findById(id);
if (p == null) throw new RecursoNaoEncontradoException("Produto", id);
```

## 🙈 Não vaze stack trace

Stack trace na resposta é **ouro pra atacante** (versão de framework, caminho de classe, query SQL). Regra:

- **Cliente recebe**: `title`, `detail` curto, `code`, `traceId` opcional
- **Servidor loga**: tudo, com `LOG.error("...", ex)` (stack completo no log)
- Use `Logger.getLogger(Classe.class)` (do `org.jboss.logging`, padrão Quarkus)
- O `traceId` no payload é um UUID que casa com a linha do log → suporte rastreia sem expor nada

```java
String traceId = UUID.randomUUID().toString();
LOG.errorf(ex, "Erro inesperado [traceId=%s]", traceId);
return Response.serverError()
        .entity(new ProblemDetail("Erro interno", 500, "Tente novamente", traceId))
        .build();
```

## 🧪 Validação → 422 com lista de campos

`ConstraintViolationException` traz **várias** violações de uma vez. Devolva todas:

```json
{
  "title": "Validação falhou",
  "status": 422,
  "errors": [
    { "campo": "nome", "mensagem": "não pode ser vazio" },
    { "campo": "preco", "mensagem": "deve ser maior que 0" }
  ]
}
```

Status **422** é o correto pra "JSON bem formado, mas semanticamente inválido". 400 fica pra JSON quebrado.

## 💡 Detalhes
- `@Provider` **não precisa** ser `@ApplicationScoped`. Mas pode ser, se quiser injetar coisa (`@Inject Logger`).
- Mapper roda **fora** do contexto da transação. Se precisar de DB no mapper, abra você mesmo.
- **`WebApplicationException`** já tem mapper default — ele devolve o status que você passou no construtor. Útil pra atalhos.
- Quer **desativar** o mapper default de `Exception`? `quarkus.rest.unhandled-failure-strategy=jboss-log-only` muda comportamento (avançado).
- **Testes**: mocke o `Logger` ou só verifique status + body. Não dependa do conteúdo do log.
- Em **dev mode**, Quarkus pode mostrar página HTML bonita de erro. Em produção (`prod`), ela é desativada. Mas seu mapper sempre ganha do default.
- Content-Type **`application/problem+json`** ajuda libs cliente (ex.: Spring `ProblemDetail`, `problem-spec` Node) a desserializar direto.

## 🚦 Próximos passos
1. Abra `pratica/` e copie todos os arquivos pro seu projeto
2. Rode `quarkus dev`
3. Use o `comandos.sh` pra disparar cada erro:
   - GET de produto que não existe → 404 problem+json
   - POST com body inválido → 422 com lista
   - Forçar erro genérico → 500 com `traceId` (e veja o log)
4. Confira no Dev UI a aba **Endpoints** + olhe os logs do terminal
5. Encare o desafio: mapper pra `ConflitoNegocioException` → 409

## ✅ Auto-verificação
- [ ] Sei o que é RFC 7807 e por que `application/problem+json`
- [ ] Sei criar `ExceptionMapper<E>` com `@Provider`
- [ ] Entendo a ordem dos mappers (específico > genérico)
- [ ] Sei que `Panache.findById` retorna `null` e eu lanço a exceção
- [ ] Não vazo stack trace no body — uso `traceId` + log
- [ ] Sei devolver 422 com lista de violações de validação

Próximo módulo: **Testes** — `@QuarkusTest`, RestAssured, e como garantir que esses status codes não regridem.
