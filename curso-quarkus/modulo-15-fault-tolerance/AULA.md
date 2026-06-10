# Módulo 15 — Fault Tolerance com MicroProfile

Sistemas distribuídos falham. Rede cai, serviço externo trava, banco fica lento. Em vez de deixar tudo quebrar em cascata, a gente protege as chamadas com padrões de resiliência. O MicroProfile Fault Tolerance entrega isso via anotações declarativas — sem precisar escrever a lógica de retry/timeout/circuit breaker na mão.

## 🎯 Objetivos

- Entender quando usar cada padrão de resiliência
- Aplicar `@Retry`, `@Timeout`, `@CircuitBreaker`, `@Bulkhead`, `@Fallback`
- Combinar anotações pra proteger uma chamada externa de ponta a ponta
- Saber a diferença entre Bulkhead semáforo e threadpool
- Não cometer o erro clássico de dar retry em erro de cliente (4xx)

## Os 5 padrões

| Padrão | Quando usar | Cuidado |
| --- | --- | --- |
| `@Retry` | Falha temporária (timeout de rede, 503) | Não retry em erro de negócio/4xx |
| `@Timeout` | Chamada pode pendurar e segurar thread | Valor curto demais = falso positivo |
| `@CircuitBreaker` | Serviço externo já tá quebrado, parar de bater | Precisa ter fallback ou erro previsível |
| `@Bulkhead` | Limitar concorrência pra um recurso caro | Threadpool consome mais memória |
| `@Fallback` | Resposta alternativa quando tudo falha | Método de fallback precisa ser rápido e seguro |

## Extensão

```bash
./mvnw quarkus:add-extension -Dextensions="smallrye-fault-tolerance"
```

Pacote das anotações: `org.eclipse.microprofile.faulttolerance.*`

## `@Retry` — tenta de novo

```java
@Retry(maxRetries = 3, delay = 200, delayUnit = ChronoUnit.MILLIS,
       retryOn = IOException.class, abortOn = IllegalArgumentException.class)
public String buscar() { ... }
```

Parâmetros principais:

| Parâmetro | Default | Pra quê |
| --- | --- | --- |
| `maxRetries` | 3 | Quantas tentativas extras |
| `delay` | 0 | Espera entre tentativas |
| `delayUnit` | MILLIS | Unidade do delay |
| `jitter` | 200 | Aleatoriedade pra evitar thundering herd |
| `retryOn` | Exception.class | Em quais exceções tentar |
| `abortOn` | — | Exceções que param o retry na hora |

## `@Timeout` — limite de tempo

```java
@Timeout(value = 2, unit = ChronoUnit.SECONDS)
public String buscar() { ... }
```

Se passar do tempo, lança `TimeoutException`. Use em qualquer chamada que possa pendurar — HTTP, banco lento, fila externa.

## `@CircuitBreaker` — corta quando tá doente

```java
@CircuitBreaker(
    requestVolumeThreshold = 10,
    failureRatio = 0.5,
    delay = 5000,
    successThreshold = 2
)
public String buscar() { ... }
```

| Parâmetro | Significado |
| --- | --- |
| `requestVolumeThreshold` | Janela de chamadas observada |
| `failureRatio` | % de falhas pra abrir o circuito (0.5 = 50%) |
| `delay` | Quanto tempo fica aberto antes de testar de novo |
| `successThreshold` | Quantos sucessos no meio-aberto pra fechar |

Estados: **fechado** (passa tudo) → **aberto** (rejeita rápido com `CircuitBreakerOpenException`) → **meio-aberto** (testa) → fechado de novo.

## `@Bulkhead` — limita concorrência

Isola pra que uma chamada lenta não afogue o resto.

```java
// Modo semáforo (default) — só limita chamadas simultâneas
@Bulkhead(value = 5)

// Modo threadpool — precisa de @Asynchronous
@Asynchronous
@Bulkhead(value = 5, waitingTaskQueue = 10)
public CompletionStage<String> buscar() { ... }
```

| Modo | Quando |
| --- | --- |
| Semáforo | Chamadas síncronas, baixo overhead |
| Threadpool | Precisa rodar em outra thread, tem fila de espera |

## `@Fallback` — plano B

```java
@Fallback(fallbackMethod = "buscarFallback")
public String buscar(String id) { ... }

public String buscarFallback(String id) {
    return "valor-em-cache";
}
```

**Regras**: método de fallback precisa ter **mesma assinatura** (parâmetros e tipo de retorno).

## Combinando tudo

A ordem de aplicação importa: `Fallback` envolve tudo, depois `Retry`, depois `CircuitBreaker`, depois `Timeout`, depois `Bulkhead`.

```java
@Retry(maxRetries = 3, delay = 300)
@CircuitBreaker(requestVolumeThreshold = 4, failureRatio = 0.5, delay = 5000)
@Timeout(value = 2, unit = ChronoUnit.SECONDS)
@Fallback(fallbackMethod = "fallback")
public String chamarServicoExterno(String id) {
    return client.buscar(id);
}

public String fallback(String id) {
    return "{\"id\":\"" + id + "\",\"origem\":\"cache\"}";
}
```

Fluxo: timeout protege cada tentativa → retry tenta de novo → circuit breaker conta falhas e abre se passar do limite → fallback responde quando estoura tudo.

## Métricas (com `quarkus-micrometer` ou `smallrye-metrics`)

Cada anotação expõe métricas automáticas:

- `ft.retry.calls.total`
- `ft.timeout.calls.total`
- `ft.circuitbreaker.state.total{state="open|halfOpen|closed"}`
- `ft.bulkhead.executionsRunning`
- `ft.invocations.total{fallback="applied|notApplied"}`

Acessíveis em `/q/metrics`.

## 💡 Detalhes que pegam

- **Nunca dar retry em 4xx** — se o cliente mandou request errado, vai falhar de novo. Use `abortOn` ou checa o status antes
- **Timeout < intervalo de retry total** — `maxRetries=3` + `delay=1s` + `timeout=10s` = pior caso ~33s. Calcule
- **Circuit breaker conta `TimeoutException` como falha** — ótimo, é o que a gente quer
- **Fallback precisa ser barato** — se ele também chama rede, não adianta nada
- **Bulkhead semáforo não tem fila** — chamada acima do limite leva `BulkheadException` na hora
- **Anotações funcionam em beans CDI** — método precisa ser público e ser chamado por fora (proxy)

## 🚦 Próximos passos

- Faça a prática: simule serviço flaky e veja o circuito abrir
- Resolva o desafio: combine os padrões em 3 chamadas diferentes
- Próximo módulo: testes de integração com Quarkus

## ✅ Auto-verificação

- [ ] Sei quando usar `@Retry` e quando NÃO usar
- [ ] Entendo os 3 estados do `@CircuitBreaker`
- [ ] Sei a diferença entre Bulkhead semáforo e threadpool
- [ ] Consigo combinar 4 anotações em um método e prever o comportamento
- [ ] Sei que método `@Fallback` precisa ter mesma assinatura
- [ ] Encontro as métricas em `/q/metrics`
