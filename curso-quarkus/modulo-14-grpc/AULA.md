# Módulo 14 — gRPC com Quarkus

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é **gRPC** e por que ele existe ao lado do REST
- Escrever um arquivo **`.proto`** descrevendo serviço e mensagens
- Deixar o Quarkus **gerar o código Java** no build a partir do `.proto`
- Implementar um servidor com `@GrpcService` e um cliente com `@GrpcClient`
- Saber os **4 tipos de chamada** (unary, server streaming, client streaming, bidirectional)
- Decidir quando usar gRPC vs REST

## 🤔 O que é gRPC?

gRPC é um framework de **RPC** (Remote Procedure Call) criado pelo Google. Você não pensa em "URL + verbo HTTP + corpo JSON" — você pensa em **chamar um método** que por trás vai para outro processo.

Três peças formam a base:
- **Protobuf** (`.proto`) — linguagem para descrever serviços e mensagens, agnóstica de linguagem
- **HTTP/2** como transporte (multiplexing, header compression, streams bidirecionais)
- **Codegen** — a partir do `.proto`, ferramentas geram stubs no servidor **e** no cliente

O payload vai em **binário** (não JSON), então fica menor e mais rápido de (de)serializar.

## ⚖️ REST vs gRPC

| Aspecto             | REST/JSON                           | gRPC                                  |
|---------------------|-------------------------------------|---------------------------------------|
| Contrato            | OpenAPI (opcional, fica desatualiza) | `.proto` (obrigatório, fonte da verdade) |
| Formato             | Texto (JSON)                        | Binário (Protobuf)                    |
| Transporte          | HTTP/1.1 (geralmente)               | HTTP/2 sempre                         |
| Streaming           | Trabalhoso (SSE, WebSocket)         | Nativo, 4 modos                       |
| Browser direto      | Sim                                 | Não (precisa grpc-web ou proxy)       |
| Debug via curl      | Fácil                               | Precisa `grpcurl`/Postman             |
| Geração de cliente  | Manual ou OpenAPI Generator         | Built-in, pra **qualquer** linguagem  |
| Caso típico         | API pública, browser, parceiros     | Microsserviço interno, alta performance |

Resumo prático: REST pra **fora**, gRPC pra **dentro**.

## 📦 Extensão

```bash
quarkus ext add grpc
```

`quarkus-grpc` traz: runtime gRPC + plugin Maven/Gradle que roda o `protoc` no build.

## 🧩 Anatomia de um `.proto`

O arquivo vai em `src/main/proto/`:

```proto
syntax = "proto3";

option java_multiple_files = true;
option java_package = "com.exemplo.saudacao";

package saudacao;

service Saudacao {
  rpc DizerOla (OlaRequest) returns (OlaReply);
  rpc DizerOlaStream (OlaRequest) returns (stream OlaReply);
}

message OlaRequest {
  string nome = 1;
}

message OlaReply {
  string mensagem = 1;
}
```

- `syntax = "proto3"` — versão da linguagem
- `option java_*` — controla o pacote e se cada classe vai em arquivo próprio
- `service` — o "contrato" de métodos remotos
- `message` — DTO (Protobuf), com **número de tag** (`= 1`, `= 2`) — esse número é o que vai no wire, **nunca mude depois de publicado**
- `stream` na frente do tipo → vira streaming

## 🔧 Geração de código no build

No `mvn compile` (ou `quarkus dev`), o plugin lê `src/main/proto/*.proto` e gera Java em `target/generated-sources/grpc/`. Você ganha:
- Uma **classe por mensagem** (`OlaRequest`, `OlaReply`)
- Uma **interface base** para o serviço (`SaudacaoGrpc.SaudacaoImplBase` no estilo Stub clássico, **mais** uma interface Mutiny `Saudacao` no estilo Quarkus)
- Stubs de **cliente** prontos

Você nunca edita esse código gerado. Mexeu no `.proto` → roda o build de novo.

## 🛰️ Os 4 tipos de chamada

| Tipo                  | Cliente envia    | Servidor responde | Pra quê                    |
|-----------------------|------------------|-------------------|----------------------------|
| Unary                 | 1 mensagem       | 1 mensagem        | RPC clássico, igual REST   |
| Server streaming      | 1 mensagem       | **N mensagens**   | Feed, paginação contínua   |
| Client streaming      | **N mensagens**  | 1 mensagem        | Upload, agregação          |
| Bidirectional         | **N mensagens**  | **N mensagens**   | Chat, jogo, telemetria     |

No Quarkus os streams aparecem como **`Multi`** (Mutiny); unary aparece como **`Uni`**.

## 🖥️ Servidor com `@GrpcService`

```java
import io.quarkus.grpc.GrpcService;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;

@GrpcService
public class SaudacaoGrpcService implements Saudacao {

    @Override
    public Uni<OlaReply> dizerOla(OlaRequest req) {
        return Uni.createFrom().item(
            OlaReply.newBuilder()
                .setMensagem("Olá, " + req.getNome())
                .build()
        );
    }

    @Override
    public Multi<OlaReply> dizerOlaStream(OlaRequest req) {
        return Multi.createFrom().items("Olá", "Tudo bem", "Tchau")
            .map(s -> OlaReply.newBuilder().setMensagem(s + ", " + req.getNome()).build());
    }
}
```

Pontos importantes:
- `@GrpcService` registra a classe como bean **e** como serviço gRPC exposto
- Implementa a interface **Mutiny** gerada (`Saudacao`), não a `SaudacaoImplBase`
- Mensagens são imutáveis — montam com **builder** (`newBuilder()...build()`)

## 📞 Cliente com `@GrpcClient`

```java
import io.quarkus.grpc.GrpcClient;

@Path("/saudacao")
public class SaudacaoResource {

    @GrpcClient("saudacao")
    Saudacao client;

    @GET
    @Path("/{nome}")
    public Uni<String> ola(String nome) {
        return client.dizerOla(OlaRequest.newBuilder().setNome(nome).build())
            .map(OlaReply::getMensagem);
    }
}
```

O `"saudacao"` é a chave de configuração: o Quarkus procura `quarkus.grpc.clients.saudacao.host/port` no `application.properties`.

```properties
quarkus.grpc.clients.saudacao.host=localhost
quarkus.grpc.clients.saudacao.port=9000
```

## 🚪 Porta padrão

Por padrão o servidor gRPC do Quarkus escuta na porta **9000** (separada da 8080 do HTTP). Configurável:

```properties
quarkus.grpc.server.port=9000
quarkus.grpc.server.plain-text=true
```

`plain-text=true` desliga TLS — bom pra dev, **nunca** pra produção entre data centers públicos.

## 🎯 Quando usar gRPC

Usa quando:
- Comunicação **service-to-service** dentro do seu cluster
- Performance importa (latência baixa, payload pequeno)
- Precisa de **streaming** de verdade (telemetria, eventos, IA)
- Tem clientes em várias linguagens e quer **um único contrato**

Evita quando:
- Quem consome é **browser** direto (sem proxy)
- API pública para terceiros que esperam REST/JSON
- Time não tem familiaridade e o caso de uso não justifica

## 💡 Detalhes que valem ouro
- **Não é amigável de testar via browser** — use `grpcurl`, `Postman` (suporta gRPC), `BloomRPC` ou `Insomnia`
- `grpcurl -plaintext localhost:9000 list` → lista os serviços expostos
- **Reflection** vem ligado em `dev` por padrão (por isso `list` funciona); em prod você liga explicitamente com `quarkus.grpc.server.enable-reflection-service=true`
- **Versionamento**: só **adicione** campos novos; **nunca** reutilize um número de tag
- O Quarkus também gera as classes no estilo **stub clássico** (`SaudacaoGrpc.newBlockingStub(...)`) caso você precise interoperar com código não-Mutiny
- Em modo nativo, o codegen funciona sem mexer em nada — uma das integrações mais polidas do Quarkus
- `quarkus dev` recompila o `.proto` no hot reload, mas mudanças em `service` exigem reiniciar o cliente

## 🚦 Próximos passos
1. `quarkus ext add grpc` no seu projeto
2. Cria `src/main/proto/saudacao.proto`
3. Roda `mvn compile` (ou `quarkus dev`) — confere que `target/generated-sources/grpc/` apareceu
4. Implementa `SaudacaoGrpcService` com `@GrpcService`
5. Cria um `SaudacaoResource` REST que chama o gRPC internamente (`@GrpcClient`)
6. Sobe e testa com `grpcurl -plaintext localhost:9000 list`
7. Veja `pratica/` pra ter o código completo
8. Faz o desafio: serviço `Calculadora` com 4 operações

## ✅ Auto-verificação
- [ ] Sei o que Protobuf resolve que JSON não resolve
- [ ] Sei escrever um `service` e uma `message` no `.proto`
- [ ] Sei onde colocar o `.proto` e como o código é gerado
- [ ] Sei a diferença entre os 4 tipos de chamada
- [ ] Sei usar `@GrpcService` no servidor e `@GrpcClient` no cliente
- [ ] Sei que streaming vira `Multi` e unary vira `Uni`
- [ ] Sei testar com `grpcurl` (não com browser)

Próximo módulo: **Fault Tolerance** — retry, timeout, circuit breaker e bulkhead.
