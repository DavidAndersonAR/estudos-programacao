# Módulo 13 — Mensageria com Kafka (SmallRye Reactive Messaging)

## 🎯 Objetivos

- Entender **por que mensageria** existe e quando vale a pena usar.
- Conhecer os conceitos básicos do **Kafka**: tópico, partição, offset, consumer group.
- Usar `@Outgoing` e `@Incoming` do **SmallRye Reactive Messaging** pra produzir e consumir.
- Enviar mensagens de forma imperativa com `Emitter<T>`.
- Mapear **channels** pra tópicos Kafka em `application.properties`.
- Deixar o **Dev Services** subir um Kafka local automaticamente (sem instalar nada).
- Fazer um pipeline simples: receber → transformar → re-emitir em outro tópico.
- Saber o que é uma **Dead Letter Topic (DLT)** e quando configurar uma.

## Por que mensageria?

Num sistema síncrono (REST puro), o cliente fica **esperando** a resposta. Se o serviço de baixo cai, a chamada falha. Se demora, o cliente trava.

Mensageria desacopla isso: o produtor **joga uma mensagem** num tópico e segue a vida. Um (ou vários) consumidores processam quando dá. Ganhos:

- **Resiliência**: se o consumer cai, as mensagens ficam guardadas no broker.
- **Escala horizontal**: vários consumers do mesmo grupo dividem a carga.
- **Picos de tráfego**: o broker funciona como buffer.
- **Eventos**: vários serviços podem reagir ao mesmo evento (ex.: "PedidoCriado" → notifica, fatura, atualiza estoque).

## Conceitos rápidos do Kafka

| Termo            | O que é                                                                 |
|------------------|-------------------------------------------------------------------------|
| **Broker**       | Servidor Kafka que armazena mensagens.                                  |
| **Tópico**       | Fila nomeada onde mensagens são publicadas (ex.: `pedidos`).            |
| **Partição**     | Subdivisão do tópico pra paralelizar consumo.                           |
| **Offset**       | Posição da mensagem dentro da partição (cada consumer guarda o seu).    |
| **Consumer Group**| Conjunto de consumers que dividem partições — cada mensagem vai pra um. |
| **Produtor**     | Quem publica mensagens.                                                 |
| **Consumidor**   | Quem lê mensagens.                                                      |

A garantia básica do Kafka: **ordem dentro da partição**. Mesma chave (`key`) → mesma partição → ordem preservada.

## Habilitando

```bash
./mvnw quarkus:add-extension -Dextensions="quarkus-messaging-kafka"
```

Em modo dev (`./mvnw quarkus:dev`), o **Dev Services** detecta a extensão e sobe um container Kafka automaticamente. Você não precisa configurar `kafka.bootstrap.servers` em dev.

## Anatomia: `@Outgoing` e `@Incoming`

O SmallRye trabalha com **channels** (canais lógicos). Você produz num channel e consome de outro — o `application.properties` decide se esse channel é um tópico Kafka, um log, memória etc.

### Producer reativo (`@Outgoing`)

```java
@Outgoing("pedidos-out")
public Multi<Pedido> gerar() {
    return Multi.createFrom().items(new Pedido(1L, "Café"), new Pedido(2L, "Pão"));
}
```

Tudo que sai do método vai pro channel `pedidos-out`.

### Consumer (`@Incoming`)

```java
@Incoming("pedidos-in")
public void consumir(Pedido p) {
    Log.infof("Recebi pedido %s", p.id());
}
```

### Transformer (`@Incoming` + `@Outgoing`)

```java
@Incoming("pedidos-in")
@Outgoing("pedidos-processados-out")
public Pedido processar(Pedido p) {
    return p.marcarProcessado();
}
```

Recebe de um channel, retorna pro outro — pipeline em uma linha.

## `Emitter<T>` — envio imperativo

`@Outgoing` é declarativo (um stream). Mas e quando um endpoint REST recebe um POST e quer **publicar uma mensagem ali na hora**? Usa `Emitter`:

```java
@Channel("pedidos-out")
Emitter<Pedido> emitter;

@POST
public void criar(Pedido p) {
    emitter.send(p);
}
```

`@Channel` injeta o emitter ligado ao mesmo channel configurado no properties.

## Configurando channels no `application.properties`

A receita é sempre: `mp.messaging.<direção>.<channel>.<propriedade>`.

```properties
# Producer
mp.messaging.outgoing.pedidos-out.connector=smallrye-kafka
mp.messaging.outgoing.pedidos-out.topic=pedidos

# Consumer
mp.messaging.incoming.pedidos-in.connector=smallrye-kafka
mp.messaging.incoming.pedidos-in.topic=pedidos
mp.messaging.incoming.pedidos-in.group.id=grupo-pedidos
```

Nome do channel (`pedidos-out`) é **interno do app**. O `topic` é o nome real no Kafka. Vários channels podem apontar pro mesmo tópico.

### Serialização JSON

Por padrão o Kafka trabalha com bytes. Pra mandar/receber objetos Java como JSON, configura os serializers:

```properties
mp.messaging.outgoing.pedidos-out.value.serializer=io.quarkus.kafka.client.serialization.ObjectMapperSerializer
mp.messaging.incoming.pedidos-in.value.deserializer=io.quarkus.kafka.client.serialization.ObjectMapperDeserializer
mp.messaging.incoming.pedidos-in.value.deserializer.type=com.exemplo.Pedido
```

O Quarkus já traz esses serializers — usam Jackson por baixo.

## Processamento: transformar e re-emitir

Padrão muito comum: um serviço lê do tópico `pedidos`, valida/enriquece, e publica em `pedidos-processados`. Outro serviço (talvez em outro app) consome esse segundo tópico.

```java
@Incoming("entrada")
@Outgoing("saida")
public PedidoProcessado processar(Pedido p) {
    return new PedidoProcessado(p.id(), p.item().toUpperCase(), Instant.now());
}
```

O SmallRye cuida do ack/nack automaticamente: se o método retorna sem exceção, a mensagem é confirmada.

## Dead Letter Topic (DLT)

Quando uma mensagem **falha pra sempre** (JSON inválido, dado corrompido), você não quer reprocessar em loop. A solução é mandar pro **dead letter topic** — um tópico de quarentena pra investigar depois.

Configuração:

```properties
mp.messaging.incoming.pedidos-in.failure-strategy=dead-letter-queue
mp.messaging.incoming.pedidos-in.dead-letter-queue.topic=pedidos-dlq
```

Outras estratégias: `fail` (para o consumer), `ignore` (descarta silenciosamente).

## Processamento "exactly-once" básico

Kafka entrega **at-least-once** por padrão (uma mensagem pode chegar 2x se o consumer cair antes de comitar). Pra evitar processar duas vezes:

- Torne o processamento **idempotente** (usar o ID do evento como chave de deduplicação no banco).
- Use `enable.idempotence=true` no producer (já é default no Quarkus recente).
- Pra cenários sérios, transações Kafka — mas isso é tópico de módulo avançado.

## 💡 Detalhes

- Em dev, o Kafka do Dev Services é **destruído ao parar a app** — mensagens não persistem entre reinícios.
- `Log.info(...)` dentro de um `@Incoming` só aparece se o consumer estiver realmente conectado — confira `group.id`.
- Channel sem `connector` configurado vira **in-memory** (útil pra testes).
- Pra ver mensagens no terminal: `./mvnw quarkus:dev` tem o **Dev UI** em `/q/dev-ui` com aba "Kafka" que lista tópicos e mensagens.
- Evite blocking I/O dentro de `@Incoming` reativo — use `@Blocking` se precisar gravar no banco.
- `Emitter.send()` retorna `CompletionStage<Void>` — dá pra encadear `.thenAccept(...)` se quiser confirmar envio.

## 🚦 Próximos passos

- Módulo 14: **gRPC** — outra forma de comunicação entre serviços (síncrona e tipada).
- Estude **Kafka Streams** se precisar de agregações/janelas temporais.
- Combine com módulo 15 (**Fault Tolerance**) pra retries automáticos no consumer.

## ✅ Auto-verificação

- [ ] Subi o app em dev e o Dev Services criou o container Kafka sozinho.
- [ ] Vi o tópico aparecer na Dev UI (`/q/dev-ui`, aba Kafka).
- [ ] Mandei um POST e a mensagem foi consumida (vi o log).
- [ ] Tenho um channel `outgoing` com `connector=smallrye-kafka` e `topic=...`.
- [ ] Tenho um `@Incoming` com `group.id` configurado.
- [ ] Sei a diferença entre `@Outgoing` (declarativo) e `Emitter` (imperativo).
- [ ] Testei um pipeline `@Incoming` + `@Outgoing` no mesmo método.
- [ ] Sei o que é DLT e como configurar uma.
