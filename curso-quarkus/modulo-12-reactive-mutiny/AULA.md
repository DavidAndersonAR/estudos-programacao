# Módulo 12 — Programação Reativa com Mutiny

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender por que **programação reativa** existe e o problema do **thread-blocking**
- Diferenciar `Uni<T>` (0-1 item) e `Multi<T>` (0-N itens) — os dois tipos centrais do **Mutiny**
- Usar os operadores mais comuns: `.onItem().transform`, `.onItem().transformToUni`, `.onFailure().recoverWithItem`, `.combine`
- Escrever **endpoints reativos** que retornam `Uni` ou `Multi`
- Servir um stream contínuo via **Server-Sent Events** (`text/event-stream`)
- Decidir **quando usar reativo** e **quando não usar**

## 🧠 O problema do thread-blocking

No modelo tradicional (servlet, "imperativo"), cada requisição prende uma **thread** do pool até a resposta sair. Se o endpoint chama um banco lento ou uma API externa, a thread fica **bloqueada esperando I/O**. Com 200 threads no pool e 200 requests lentos simultâneos, o servidor para.

A solução reativa: a thread **dispara** a operação de I/O, libera, e volta a trabalhar quando a resposta chega. Poucas threads atendem milhares de requests — desde que ninguém **bloqueie**.

Quarkus 3+ usa **RESTEasy Reactive** por padrão (extensão `quarkus-rest-jackson`). Você pode retornar valor síncrono (`Cotacao`) **ou** reativo (`Uni<Cotacao>`) — o framework lida com os dois.

## 🔀 Uni vs Multi

| Tipo | Quantos itens | Analogia | Exemplo |
|---|---|---|---|
| `Uni<T>` | 0 ou 1 | `Future<T>` / `CompletableFuture<T>` | Buscar um usuário por id |
| `Multi<T>` | 0 a N (stream) | `Stream<T>` assíncrono / `Flux<T>` (Reactor) | Eventos em tempo real, lista paginada infinita |

Ambos são **lazy**: nada acontece até alguém **subscrever**. No endpoint, quem subscreve é o próprio Quarkus.

```java
// Cria um Uni a partir de um valor pronto
Uni<String> ola = Uni.createFrom().item("oi");

// Cria um Multi a partir de vários valores
Multi<Integer> nums = Multi.createFrom().items(1, 2, 3);
```

## 🛠️ Operadores que você vai usar 90% do tempo

```java
// 1. Transformar o valor (map)
Uni<Integer> tamanho = Uni.createFrom().item("hello")
    .onItem().transform(String::length);

// 2. Encadear outra chamada reativa (flatMap)
Uni<Usuario> usuario = buscarId(1L)
    .onItem().transformToUni(id -> buscarUsuario(id));

// 3. Tratar erro recuperando
Uni<Cotacao> segura = chamarApi()
    .onFailure().recoverWithItem(new Cotacao("USD", 0.0));

// 4. Transformar cada item de um Multi
Multi<String> nomes = Multi.createFrom().items("ana", "bob")
    .onItem().transform(String::toUpperCase);

// 5. Combinar dois Uni em paralelo
Uni<Resultado> agregado = Uni.combine().all()
    .unis(buscarUsuario(1L), buscarPedidos(1L))
    .asTuple()
    .onItem().transform(t -> new Resultado(t.getItem1(), t.getItem2()));
```

> Atalho: `Uni#map(fn)` existe e é equivalente a `.onItem().transform(fn)`. Use o que ler melhor — a forma `.onItem()` deixa explícito que você está num pipeline reativo.

## 🚪 Endpoint reativo

Retornar `Uni<T>` no método é tudo. Quarkus subscreve, espera o resultado **sem bloquear thread**, e serializa pra JSON.

```java
@GET
@Path("/cotacao")
public Uni<Cotacao> cotacao() {
    return cotacaoService.buscar("USD");
}
```

Pra cliente, é uma resposta HTTP normal. A diferença está no servidor: a thread que recebeu o request foi liberada enquanto `buscar()` esperava o I/O.

## 📡 Server-Sent Events com Multi

`Multi<T>` brilha quando você quer **empurrar eventos** pro cliente continuamente. Anota com `@Produces(MediaType.SERVER_SENT_EVENTS)` (alias `text/event-stream`):

```java
@GET
@Path("/stream")
@Produces(MediaType.SERVER_SENT_EVENTS)
public Multi<Cotacao> stream() {
    return Multi.createFrom().ticks().every(Duration.ofSeconds(1))
        .onItem().transformToUniAndConcatenate(tick -> cotacaoService.buscar("USD"));
}
```

O cliente recebe um evento por segundo, sem precisar fazer polling. Teste com `curl -N` (o `-N` desliga buffering).

## 🧯 Error handling reativo

Não use `try/catch` — o erro **flui pelo pipeline**. Você intercepta com `.onFailure()`:

```java
chamarApi()
    .onFailure().retry().atMost(3)                          // 3 tentativas
    .onFailure().recoverWithItem(new Cotacao("USD", 0.0))   // fallback
    .onFailure().invoke(e -> Log.error("deu ruim", e));     // só logar
```

Se nada tratar o erro, ele chega até o Quarkus, que devolve 500.

## 🛑 Quando NÃO usar reativo

- **CPU-bound** (cálculo pesado, processamento de imagem, hashing): não há I/O pra esperar. Você só atrapalha o event loop.
- **Código simples sem gargalo**: um CRUD que faz 1 query rápida não ganha nada virando reativo — só fica mais difícil de ler.
- **Equipe sem familiaridade**: stack traces reativas são longas, debug exige prática. Avalie o custo.

Regra prática: use reativo quando a maior parte do tempo do request é **esperando I/O** (banco, API externa, fila, arquivo) e você precisa de **alta concorrência**.

## 💡 Detalhes
- **RESTEasy Reactive aceita os dois mundos** — `Uni<X>`, `Multi<X>` ou `X` síncrono no mesmo Resource. Não precisa converter o projeto inteiro.
- **Nunca bloqueie no thread reativo**: nada de `Thread.sleep`, `.get()` em `Future`, JDBC síncrono no meio do pipeline. Use `Uni.createFrom().item(() -> ...)` rodando num worker se for inevitável.
- **`Panache reactive`** existe (`quarkus-hibernate-reactive-panache`) e devolve `Uni<List<T>>`, `Uni<T>`. É um stack separado do Panache "clássico" — escolha um e mantenha.
- **`Multi` é lazy e single-subscriber por padrão**. Pra broadcast use `.broadcast().toAllSubscribers()`.
- **SSE diferente de WebSocket**: SSE é unidirecional (servidor → cliente) e roda em HTTP normal. Pra comunicação bidirecional, use WebSocket (módulo futuro).
- **Dev UI** mostra os endpoints reativos como qualquer outro, mas no Vert.x panel você vê o **event loop** trabalhando.

## 🚦 Próximos passos
1. Copie os arquivos de `pratica/` (`CotacaoResource`, `CotacaoService`)
2. Rode `quarkus dev`
3. Execute `comandos.sh` — observe o `/stream` empurrando eventos em tempo real
4. Encare o desafio: endpoint que **combina** duas chamadas externas reativas em paralelo

## ✅ Auto-verificação
- [ ] Sei explicar por que reativo escala melhor pra I/O
- [ ] Sei diferenciar `Uni<T>` e `Multi<T>` e dou um exemplo de cada
- [ ] Conheço `.onItem().transform`, `.transformToUni`, `.onFailure().recoverWithItem`, `.combine`
- [ ] Sei retornar `Uni`/`Multi` de um endpoint e que Quarkus aceita os dois junto com síncrono
- [ ] Sei expor um endpoint SSE com `Multi` + `MediaType.SERVER_SENT_EVENTS`
- [ ] Sei reconhecer quando reativo **não** ajuda (CPU-bound, código simples)

Próximo módulo: **Testes** — `@QuarkusTest`, REST Assured, testando endpoints reativos.
