# 🎯 Desafio do Módulo 14 — Serviço Calculadora via gRPC

## Contexto
Você vai criar um serviço gRPC `Calculadora` com **4 operações** (soma, subtração, multiplicação, divisão) e expor um endpoint REST que chama esse serviço internamente. A ideia é fixar `.proto`, codegen, `@GrpcService` e `@GrpcClient` sem olhar a solução.

## O que construir

### 1. `calculadora.proto`
Vai em `src/main/proto/calculadora.proto`.

- `package` = `calculadora`
- `java_package` = `com.exemplo.calculadora`
- Serviço `Calculadora` com 4 RPCs **unary**:
  - `Somar(OperacaoRequest) returns (OperacaoReply)`
  - `Subtrair(OperacaoRequest) returns (OperacaoReply)`
  - `Multiplicar(OperacaoRequest) returns (OperacaoReply)`
  - `Dividir(OperacaoRequest) returns (OperacaoReply)`
- `OperacaoRequest`: campos `a` (double) e `b` (double)
- `OperacaoReply`: campos `resultado` (double) e `expressao` (string, ex.: `"2.0 + 3.0 = 5.0"`)

### 2. `CalculadoraGrpcService.java`
- Anote com `@GrpcService`
- Implementa a interface Mutiny gerada (`Calculadora`)
- Cada método retorna `Uni<OperacaoReply>`
- Em `Dividir`, se `b == 0`, devolve um `Uni.createFrom().failure(...)` com mensagem clara

### 3. `CalculadoraResource.java`
Expor REST chamando o gRPC:

| Método | URL                              | Resposta                |
|--------|----------------------------------|-------------------------|
| GET    | `/calc/somar?a=2&b=3`            | `2.0 + 3.0 = 5.0`       |
| GET    | `/calc/subtrair?a=10&b=4`        | `10.0 - 4.0 = 6.0`      |
| GET    | `/calc/multiplicar?a=3&b=7`      | `3.0 * 7.0 = 21.0`      |
| GET    | `/calc/dividir?a=10&b=2`         | `10.0 / 2.0 = 5.0`      |
| GET    | `/calc/dividir?a=10&b=0`         | 500 com mensagem de erro |

Injete com `@GrpcClient("calculadora")`. Retorne `Uni<String>` em cada método.

### 4. `application.properties`
- Porta gRPC: `9000`
- `plain-text=true`
- Cliente `calculadora` apontando pra `localhost:9000`

## TODOs

1. **`quarkus ext add grpc`** no seu projeto (ou aproveite o da prática)
2. Crie o `.proto` com **as 4 operações**. Não esqueça os números de tag (`= 1`, `= 2`)
3. Rode `mvn compile` (ou `quarkus dev`) e confirme que `target/generated-sources/grpc/com/exemplo/calculadora/` apareceu
4. Implemente `CalculadoraGrpcService` com `@GrpcService`
5. Trate divisão por zero retornando `Uni.failure(...)` — quem chama vai receber `StatusRuntimeException` com `INTERNAL` ou `UNKNOWN`
6. Implemente `CalculadoraResource` com `@GrpcClient("calculadora")`
7. Configure `application.properties` com porta gRPC e host/port do cliente
8. Teste:
   ```bash
   # via REST
   curl "http://localhost:8080/calc/somar?a=2&b=3"
   curl "http://localhost:8080/calc/dividir?a=10&b=0"

   # via grpcurl
   grpcurl -plaintext localhost:9000 list
   grpcurl -plaintext -d '{"a":2,"b":3}' localhost:9000 calculadora.Calculadora/Somar
   grpcurl -plaintext -d '{"a":10,"b":0}' localhost:9000 calculadora.Calculadora/Dividir
   ```

## Critério de "tá pronto"
- [ ] `.proto` compila e gera as classes em `target/generated-sources/grpc/`
- [ ] As 4 operações funcionam via REST **e** via `grpcurl`
- [ ] `Dividir` por zero não derruba a JVM — vira erro gRPC tratável
- [ ] A `expressao` no `OperacaoReply` mostra a conta certa
- [ ] Você não precisou olhar a solução enquanto fazia

## Quando travar
Releia `pratica/saudacao.proto` e `pratica/SaudacaoGrpcService.java` — a estrutura é praticamente idêntica, só muda o número de operações. Só depois disso, se ainda travado, abra os arquivos `.solucao`.

> A solução tem extensão `.solucao` de propósito: o `quarkus dev` não compila arquivos com essa extensão. Pra rodar, renomeie pra `.java` (ou `.proto`).
