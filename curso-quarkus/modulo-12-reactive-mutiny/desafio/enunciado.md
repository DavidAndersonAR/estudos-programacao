# Desafio — Painel agregado (duas chamadas reativas em paralelo)

## 🎯 Objetivo
Criar um endpoint **GET /painel/{moeda}** que retorna um JSON com:
- A **cotação atual** da moeda
- A **temperatura** atual de São Paulo

As duas informações vêm de "fontes externas" diferentes (simuladas). Cada chamada demora ~400ms. Se você fizesse sequencial, o request total daria ~800ms. Usando `Uni.combine().all()`, as duas rodam **em paralelo** e o tempo total fica ~400ms.

## 📋 Requisitos

1. Crie dois services reativos:
   - `CotacaoExterna#buscar(String moeda)` → `Uni<Double>` (valor da cotação, ~400ms de delay)
   - `ClimaExterno#temperatura()` → `Uni<Double>` (graus Celsius, ~400ms de delay)
2. Crie `PainelResource` com `GET /painel/{moeda}` retornando `Uni<Painel>`, onde `Painel` é um record:
   ```java
   public record Painel(String moeda, double cotacao, double temperaturaSP) {}
   ```
3. Use `Uni.combine().all().unis(a, b).asTuple()` (ou `.with(...)` que já constrói o objeto) pra disparar as duas em paralelo.
4. Se **uma** das chamadas falhar, devolva `0.0` no campo afetado — não derrube o request inteiro. Dica: aplique `.onFailure().recoverWithItem(0.0)` em cada `Uni` **antes** do `combine`.

## ✅ Critério de aceite

- `curl http://localhost:8080/painel/USD` retorna 200 com os 3 campos preenchidos.
- `time curl ...` mostra tempo total ~400ms (não ~800ms). Se deu 800ms, você fez sequencial — revise.
- Se uma das fontes lançar exceção, o JSON ainda volta, com `0.0` no campo correspondente.

## 🧪 Teste o paralelismo

```bash
time curl -s http://localhost:8080/painel/USD | jq
```

Compare com uma versão sequencial (encadeando com `.transformToUni`) e veja a diferença na medição.

## 💡 Dicas
- `Uni.combine().all().unis(u1, u2).asTuple()` devolve `Uni<Tuple2<A, B>>`. Aí você faz `.onItem().transform(t -> new Painel(moeda, t.getItem1(), t.getItem2()))`.
- Pra simular falha aleatória num service, use `ThreadLocalRandom` e `Uni.createFrom().failure(...)`.
- Quer mais sabor? Adicione um terceiro `Uni` (ex: status do sistema) e use `.combine().all().unis(a, b, c).asTuple()` — funciona até 9 unis sem virar lista.

## 📁 Entrega
Crie em `desafio/`:
- `PainelResource.java`
- `CotacaoExterna.java`
- `ClimaExterno.java`
- `Painel.java` (ou record dentro do Resource)

Quando terminar, compare com os arquivos `.solucao` desta pasta.
