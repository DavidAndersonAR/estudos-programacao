# Módulo 06 — REST Client Reactive

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Consumir APIs externas com **interface declarativa** (sem `HttpClient` manual)
- Configurar URL base, headers e timeouts via `application.properties`
- Injetar o client com `@RestClient`
- Tratar erros HTTP de um jeito limpo
- Saber quando faz sentido devolver `Uni`/`Multi` (reativo) vs sync

## 🤔 Por que client declarativo?

Antes você ia escrever isso pra chamar a API do ViaCEP:

```java
HttpClient http = HttpClient.newHttpClient();
HttpRequest req = HttpRequest.newBuilder()
    .uri(URI.create("https://viacep.com.br/ws/" + cep + "/json/"))
    .header("Accept", "application/json")
    .timeout(Duration.ofSeconds(5))
    .GET()
    .build();
HttpResponse<String> resp = http.send(req, BodyHandlers.ofString());
Endereco e = mapper.readValue(resp.body(), Endereco.class);
```

Funciona, mas você escreve a mesma coreografia em todo lugar: montar URL, headers, timeout, deserializar, tratar status code...

Com **REST Client** do Quarkus (spec **MicroProfile REST Client**) você declara o contrato como uma interface Java:

```java
@Path("/ws")
@RegisterRestClient(configKey = "viacep")
public interface ViaCepClient {
    @GET
    @Path("/{cep}/json")
    Endereco buscar(@PathParam("cep") String cep);
}
```

E o Quarkus gera a implementação. **Você chama método; ele faz HTTP**. Tipado, testável, com config externa.

## 📦 Extensão

```bash
quarkus ext add rest-client-jackson
```

`quarkus-rest-client-jackson` = REST Client + Jackson pra (de)serializar JSON automaticamente.

## 🧩 Anatomia da interface

```java
package com.exemplo.cep;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

@Path("/ws")
@RegisterRestClient(configKey = "viacep")
@Produces(MediaType.APPLICATION_JSON)
public interface ViaCepClient {

    @GET
    @Path("/{cep}/json")
    Endereco buscar(@PathParam("cep") String cep);
}
```

- `@RegisterRestClient(configKey = "viacep")` → diz pro Quarkus gerar implementação; o `configKey` liga essa interface ao bloco de config `quarkus.rest-client.viacep.*`
- Anotações JAX-RS (`@GET`, `@Path`, `@PathParam`, `@QueryParam`) — **mesmas do servidor**, só que agora viram chamada de saída
- O tipo de retorno (`Endereco`) é deserializado do JSON pelo Jackson

## ⚙️ Configuração

`application.properties`:

```properties
quarkus.rest-client.viacep.url=https://viacep.com.br
quarkus.rest-client.viacep.scope=jakarta.inject.Singleton
quarkus.rest-client.viacep.connect-timeout=2000
quarkus.rest-client.viacep.read-timeout=5000
```

- `url` → base; o `@Path` da interface concatena
- `scope` → ciclo de vida do bean (Singleton é o comum)
- timeouts em ms — **sempre configure**, default é infinito

## 💉 Injetando o client

```java
import org.eclipse.microprofile.rest.client.inject.RestClient;

@ApplicationScoped
public class EnderecoService {

    @RestClient
    ViaCepClient viaCep;

    public Endereco porCep(String cep) {
        return viaCep.buscar(cep);
    }
}
```

**Atenção**: é `@RestClient`, **não** `@Inject`. Marca que o bean vem do REST Client, não do CDI normal.

## 🪪 Headers

Header fixo em todas as chamadas:

```java
@RegisterRestClient(configKey = "github")
@ClientHeaderParam(name = "User-Agent", value = "curso-quarkus/1.0")
public interface GitHubClient { ... }
```

Header por método (ex: token vindo de config):

```java
@GET
@ClientHeaderParam(name = "Authorization", value = "{authHeader}")
List<Repo> repos(@PathParam("user") String user);

default String authHeader() {
    return "Bearer " + ConfigProvider.getConfig()
        .getValue("github.token", String.class);
}
```

Header dinâmico por chamada — só usar `@HeaderParam` no argumento:

```java
@GET
Endereco buscar(@PathParam("cep") String cep, @HeaderParam("X-Trace-Id") String trace);
```

## 🚨 Tratando erros

Por padrão, status 4xx/5xx vira `WebApplicationException` (ou `ClientWebApplicationException`). Pra mapear pro **seu** tipo de exceção:

```java
public class ViaCepExceptionMapper implements ResponseExceptionMapper<CepInvalidoException> {
    @Override
    public CepInvalidoException toThrowable(Response response) {
        return new CepInvalidoException("CEP não encontrado: " + response.getStatus());
    }
    @Override
    public boolean handles(int status, MultivaluedMap<String, Object> headers) {
        return status == 400 || status == 404;
    }
}
```

Registra na interface:

```java
@RegisterRestClient(configKey = "viacep")
@RegisterProvider(ViaCepExceptionMapper.class)
public interface ViaCepClient { ... }
```

Ou anota direto o método:

```java
@GET
@ClientExceptionMapper
static RuntimeException toException(Response r) {
    return r.getStatus() == 404 ? new CepInvalidoException("404") : null;
}
```

## ⏱️ Sync vs Reativo (Uni/Multi)

Mesma interface, dois "sabores":

```java
// Bloqueante — simples, ok pra worker thread
Endereco buscar(@PathParam("cep") String cep);

// Reativo — não bloqueia I/O thread, integra com Mutiny
Uni<Endereco> buscarAsync(@PathParam("cep") String cep);
```

Regras práticas:
- Endpoint anotado com `@Blocking` ou em service tradicional → use a versão **sync**
- Endpoint que devolve `Uni`/`Multi` → use a versão **reativa** (sem `Uni.createFrom().item(...)` em volta)
- Misturar bloqueante em I/O thread reativa → freeze. Vamos cobrir Mutiny a fundo no Módulo 10.

## 💡 Detalhes que valem ouro
- **`configKey` é melhor que classe fully qualified**: muda o pacote da interface e a config continua válida
- Liste todos os clients no Dev UI em `/q/dev` → seção "REST Client"
- `@Path` na interface é **opcional** — pode pôr o caminho todo em cada método se preferir
- Pra mockar em teste: `@InjectMock @RestClient ViaCepClient viaCep;` (com `quarkus-junit5-mockito`)
- Em modo nativo (GraalVM), os DTOs precisam ser registrados pra reflexão; com `quarkus-rest-client-jackson` isso já é automático pros tipos referenciados na interface
- `quarkus.rest-client.logging.scope=request-response` loga toda chamada — ouro pra debug, ruído pra prod

## 🚦 Próximos passos
1. `quarkus ext add rest-client-jackson` no seu projeto
2. Crie a `Endereco` (record)
3. Crie a interface `ViaCepClient`
4. Configure `quarkus.rest-client.viacep.url` em `application.properties`
5. Injete com `@RestClient` no service
6. Suba (`quarkus dev`) e teste: `curl http://localhost:8080/cep/01001000`
7. Veja `pratica/` pro passo a passo completo
8. Encare o desafio (JSONPlaceholder)

## ✅ Auto-verificação
- [ ] Sei a diferença entre client declarativo e `HttpClient` manual
- [ ] Sei o que `configKey` faz
- [ ] Sei injetar com `@RestClient` (e não com `@Inject`)
- [ ] Sei configurar URL base e timeouts
- [ ] Sei adicionar header fixo com `@ClientHeaderParam`
- [ ] Entendi quando devolver `Uni` em vez de tipo direto

Próximo módulo: **Persistência com Panache** — Hibernate sem o boilerplate.
