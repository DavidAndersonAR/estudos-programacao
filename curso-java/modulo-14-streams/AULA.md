# Módulo 14 — Streams API

> Corresponde ao Nível Avançado — Streams e filtragem.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é uma **Stream** e como ela difere de uma `Collection`
- Distinguir **operações intermediárias** (preguiçosas) de **operações terminais** (disparam execução)
- Usar `filter`, `map`, `sorted`, `distinct`, `limit`, `skip` pra transformar dados
- Coletar resultados com `Collectors` (`toList`, `groupingBy`, `joining`, etc)
- Reduzir, contar, somar e fazer médias em uma linha
- Saber quando usar `IntStream` / `DoubleStream` (streams primitivas)

## 🌊 O que é uma Stream

Uma **Stream** é uma **sequência de elementos** sobre a qual você aplica operações **funcionais** (filtrar, transformar, agrupar). Ela apareceu no **Java 8 (2014)** junto com as expressões lambda.

Pensa numa esteira de fábrica: os dados passam, cada estação faz uma operação, e no fim sai o produto.

```java
List<Integer> numeros = List.of(1, 2, 3, 4, 5);

int soma = numeros.stream()       // cria a stream
                  .filter(n -> n % 2 == 0)  // só pares: [2, 4]
                  .mapToInt(n -> n * n)     // ao quadrado: [4, 16]
                  .sum();                   // 20

System.out.println(soma); // 20
```

### Três coisas importantes
1. **Stream NÃO é uma estrutura de dados** — ela não guarda nada. Só processa.
2. **Stream NÃO modifica a fonte original** — a `List` continua intacta.
3. **Stream é "uso único"** — depois de uma operação terminal, ela acaba. Pra rodar de novo, crie outra com `.stream()`.

## 🔄 Pipeline: Source → Intermediárias → Terminal

```
fonte.stream()         <-- source (uma List, Set, array, etc)
     .filter(...)      <-- intermediária
     .map(...)         <-- intermediária
     .sorted()         <-- intermediária
     .collect(...);    <-- TERMINAL (dispara tudo)
```

Nada acontece até a operação terminal. Isso se chama **lazy evaluation** (avaliação preguiçosa) — é o que permite encadear várias operações sem custo extra.

## 🔁 Operações Intermediárias

Todas retornam **uma nova Stream**, então dá pra encadear.

| Operação | O que faz | Exemplo |
|---|---|---|
| `filter(Predicate)` | Mantém só os que passam no teste | `.filter(n -> n > 0)` |
| `map(Function)` | Transforma cada elemento | `.map(s -> s.toUpperCase())` |
| `mapToInt` / `mapToDouble` | Transforma em stream primitiva | `.mapToInt(String::length)` |
| `distinct()` | Remove duplicados | `.distinct()` |
| `sorted()` | Ordena (natural ou com Comparator) | `.sorted()` |
| `limit(n)` | Pega só os N primeiros | `.limit(3)` |
| `skip(n)` | Pula os N primeiros | `.skip(2)` |
| `peek(Consumer)` | Espia cada elemento (debug) | `.peek(System.out::println)` |

## 🏁 Operações Terminais

Disparam a execução do pipeline e produzem um resultado (ou efeito).

| Operação | O que retorna | Quando usar |
|---|---|---|
| `collect(Collector)` | List, Set, Map, etc | Materializar resultado |
| `count()` | `long` | Contar elementos |
| `forEach(Consumer)` | nada | Executar ação em cada um |
| `reduce(...)` | valor agregado | Soma, produto, concatenação custom |
| `anyMatch(Predicate)` | `boolean` | Pelo menos um passa? |
| `allMatch(Predicate)` | `boolean` | Todos passam? |
| `noneMatch(Predicate)` | `boolean` | Nenhum passa? |
| `findFirst()` | `Optional<T>` | Primeiro elemento (se houver) |
| `findAny()` | `Optional<T>` | Qualquer um (útil em paralelo) |
| `min` / `max` | `Optional<T>` | Menor/maior por Comparator |
| `sum` / `average` (em IntStream) | número | Em streams primitivas |

### `reduce` em detalhe
Combina elementos dois a dois até sobrar um só:

```java
int soma = List.of(1, 2, 3, 4).stream()
               .reduce(0, (acc, n) -> acc + n); // 10
```
- `0` é o valor inicial (identidade).
- `(acc, n) -> acc + n` é como combinar.

## 🧺 Collectors — montando estruturas no fim

`Collectors` (do pacote `java.util.stream`) é uma caixa de ferramentas pra `collect(...)`.

```java
import static java.util.stream.Collectors.*;

// Pra List
List<String> nomes = pessoas.stream()
    .map(Pessoa::getNome)
    .collect(toList()); // ou Collectors.toList()

// Pra Set (sem duplicados)
Set<String> unicos = palavras.stream().collect(toSet());

// Pra Map (chave -> valor)
Map<String, Integer> mapa = pessoas.stream()
    .collect(toMap(Pessoa::getNome, Pessoa::getIdade));

// Agrupar por critério
Map<String, List<Pessoa>> porCidade = pessoas.stream()
    .collect(groupingBy(Pessoa::getCidade));

// Particionar (boolean)
Map<Boolean, List<Integer>> paresEImpares = numeros.stream()
    .collect(partitioningBy(n -> n % 2 == 0));

// Contar por grupo
Map<String, Long> qtdPorCidade = pessoas.stream()
    .collect(groupingBy(Pessoa::getCidade, counting()));

// Média de um campo
Double mediaIdade = pessoas.stream()
    .collect(averagingDouble(Pessoa::getIdade));

// Juntar strings com separador
String csv = nomes.stream().collect(joining(", "));
String linha = nomes.stream().collect(joining(", ", "[", "]")); // [a, b, c]
```

## 🔢 Streams primitivas — IntStream, DoubleStream, LongStream

`Stream<Integer>` faz boxing (embrulha cada `int` num objeto), o que é mais lento. Pra trabalhar com primitivos, use as streams primitivas:

```java
// Faixa de números
IntStream.range(0, 5).forEach(System.out::println);     // 0,1,2,3,4
IntStream.rangeClosed(1, 5).forEach(System.out::println); // 1,2,3,4,5

// Estatísticas direto
int soma = IntStream.rangeClosed(1, 100).sum();   // 5050
double media = IntStream.of(1, 2, 3).average().orElse(0); // 2.0

// Sair de e voltar pra Stream<Integer>
IntStream.range(0, 10).boxed().collect(Collectors.toList());
```

## 💡 Pegadinhas que valem ouro

- **Stream é uso único.** Tentar reusar dá `IllegalStateException`. Crie outra com `.stream()`.
- **Stream NÃO modifica o original.** Se quiser a fonte alterada, atribua o resultado: `lista = lista.stream()...collect(toList());`
- **Sem operação terminal, nada acontece.** É comum esquecer o `collect` e ficar olhando pro nada.
- **`forEach` com efeito colateral em variáveis externas é ruim** — prefira `collect` ou `reduce`.
- **Em streams primitivas use `sum`/`average`, NÃO `reduce` toscamente.**
- **`Optional` aparece muito** (`findFirst`, `min`, `max`) — trate com `orElse`, `ifPresent`, etc.

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode os 8 exercícios.
2. Encare o **desafio**: Análise de Vendas — vários relatórios em cima da mesma lista.
3. Quando estiver confortável, vá pro próximo módulo.

## ✅ Auto-verificação
- [ ] Sei explicar a diferença entre intermediária e terminal
- [ ] Sei que Stream não muda a coleção original
- [ ] Consigo usar `filter` + `map` + `collect(toList())` de memória
- [ ] Sei agrupar com `groupingBy`
- [ ] Sei usar `IntStream.range` e somar uma faixa
- [ ] Conheço `reduce` e sei pra que serve

Próximo passo: praticar muito — Streams se aprende escrevendo, não lendo.
