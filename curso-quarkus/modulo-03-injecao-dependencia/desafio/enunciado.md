# 🎯 Desafio do Módulo 03 — Refatorar o `PedidoResource` gigante

## 😱 Cenário

Um dev anterior escreveu uma API de Pedidos com **tudo dentro do Resource**: acesso a dados, regras de negócio, cálculo de total, conversão HTTP — tudo misturado. Agora você precisa adicionar testes e trocar o "banco" no futuro. Está impossível.

## 📜 O código atual (a refatorar)

Salve como `src/main/java/com/exemplo/PedidoResource.java` num projeto Quarkus com `rest-jackson`:

```java
package com.exemplo;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;

@Path("/pedidos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PedidoResource {

    // ❌ Dados misturados no Resource
    private static final Map<Long, Pedido> DB = new ConcurrentHashMap<>();
    private static final AtomicLong SEQ = new AtomicLong();

    @GET
    public Collection<Pedido> listar() {
        return DB.values();
    }

    @POST
    public Response criar(Pedido p) {
        // ❌ Regra de negócio misturada
        if (p.itens() == null || p.itens().isEmpty()) {
            return Response.status(400).entity("pedido sem itens").build();
        }
        double total = 0;
        for (Item i : p.itens()) {
            total += i.preco() * i.qtd();
        }
        // ❌ Acesso a dados misturado
        long id = SEQ.incrementAndGet();
        Pedido salvo = new Pedido(id, p.cliente(), p.itens(), total);
        DB.put(id, salvo);
        return Response.status(201).entity(salvo).build();
    }

    @GET @Path("/{id}")
    public Response buscar(@PathParam("id") Long id) {
        Pedido p = DB.get(id);
        return p == null ? Response.status(404).build() : Response.ok(p).build();
    }
}

record Item(String produto, double preco, int qtd) {}
record Pedido(Long id, String cliente, List<Item> itens, Double total) {}
```

## ✅ Sua missão

Refatore em **3 camadas + 1 model**, mantendo o comportamento dos endpoints:

1. **`Pedido.java`** + **`Item.java`** — records (modelos), sem mudança grande.
2. **`PedidoRepository.java`** — `@ApplicationScoped`, com o `Map` e `AtomicLong`. Métodos: `listar()`, `buscar(id)`, `salvar(pedido)`.
3. **`PedidoService.java`** — `@ApplicationScoped`, injeta o repository **por construtor**. Faz validação ("sem itens") e cálculo do total. Métodos: `listarTodos()`, `buscarPorId(id)`, `criar(pedido)`.
4. **`PedidoResource.java`** — só lida com HTTP. Injeta o service por construtor.

### Regras

- Use `@Inject` por **construtor** em todos os beans.
- O Resource **não** pode mais ter `Map`, `AtomicLong`, nem cálculo de total.
- O Service **não** pode importar nada de `jakarta.ws.rs.*` (sem acoplamento HTTP).
- O Repository **não** conhece o Service.
- Para erros de validação no Service, lance `IllegalArgumentException` (no Módulo 08 a gente trata pra virar 400).

### Bônus

- Crie uma **interface** `PedidoRepository` e uma implementação `PedidoRepositoryEmMemoria`. Confirme que tudo continua funcionando.
- Adicione um `@PostConstruct` no Service que cria 1 pedido de exemplo no boot.

## 🧪 Como testar

```bash
quarkus dev
# Em outro terminal:
curl -s http://localhost:8080/pedidos | jq .

curl -s -X POST http://localhost:8080/pedidos \
  -H "Content-Type: application/json" \
  -d '{"cliente":"David","itens":[{"produto":"Café","preco":12.0,"qtd":2}]}' | jq .

curl -s http://localhost:8080/pedidos/1 | jq .
```

Comportamento esperado: idêntico ao código original, mas agora cada camada faz só uma coisa.

## 💡 Dicas
- Quando o Service injeta o Repository por construtor, o ArC resolve sozinho.
- Esqueceu `@ApplicationScoped`? Vai dar `UnsatisfiedResolutionException` no build/dev.
- Live reload (`quarkus dev`) deixa o ciclo de refatoração super rápido — salva e roda o curl.
- Em `/q/dev` → aba **Arc** dá pra ver os 3 beans e as setas de dependência.

A solução de referência está em `solucao/` (arquivos `.java.solucao` — renomeie pra `.java` se quiser rodar direto).
