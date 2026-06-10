# Módulo 13 — Lambdas e Functional Interfaces

> Corresponde ao Nível Avançado do Java10x.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é uma **expressão lambda** e por que ela existe
- Reconhecer uma **Functional Interface** e usar `@FunctionalInterface`
- Usar as interfaces prontas em `java.util.function`: `Function`, `Predicate`, `Consumer`, `Supplier`, `BiFunction`, `UnaryOperator`
- Trocar lambdas por **method references** (`String::toUpperCase`)
- Decidir quando vale a pena puxar lambda em vez de uma classe inteira

## λ O que é uma lambda?
Lambda é jeito **curto** de escrever uma função anônima — função sem nome, declarada na hora.

Antes do Java 8 você precisava de uma classe inteira pra passar "comportamento" como argumento:

```java
// Java antigo: classe anônima
Comparator<Integer> ordem = new Comparator<Integer>() {
    @Override
    public int compare(Integer a, Integer b) {
        return a - b;
    }
};
```

A partir do Java 8, lambda:

```java
Comparator<Integer> ordem = (a, b) -> a - b;
```

Mesma coisa. Mesma `Comparator`. Muito menos cerimônia.

A sintaxe geral é:

```
(parâmetros) -> { corpo }
```

A "seta" `->` é o coração da lambda — separa o **input** (esquerda) do **comportamento** (direita).

---

## ✍️ Sintaxe completa vs reduzida

### Forma completa
```java
(int a, int b) -> {
    int soma = a + b;
    return soma;
}
```

### Forma reduzida (atalhos que o Java aceita)
- **Sem tipos** (inferidos pelo contexto): `(a, b) -> { return a + b; }`
- **Um parâmetro só**: parênteses opcionais → `n -> n * 2`
- **Corpo de uma expressão só**: chaves e `return` opcionais → `(a, b) -> a + b`
- **Sem parâmetros**: parênteses vazios obrigatórios → `() -> System.out.println("oi")`

Exemplos lado a lado:

```java
// Soma de dois números
BiFunction<Integer, Integer, Integer> soma1 = (Integer a, Integer b) -> { return a + b; };
BiFunction<Integer, Integer, Integer> soma2 = (a, b) -> a + b; // mesma coisa

// Dobrar um número
Function<Integer, Integer> dobrar1 = (Integer n) -> { return n * 2; };
Function<Integer, Integer> dobrar2 = n -> n * 2; // mesma coisa
```

---

## 🧩 Functional Interface — o "molde" da lambda

Uma lambda **sempre** representa uma interface — e essa interface tem que ter **exatamente um método abstrato** (Single Abstract Method, SAM). Essas são as **Functional Interfaces**.

```java
@FunctionalInterface
interface Operacao {
    int aplicar(int a, int b); // único método abstrato
}
```

A anotação `@FunctionalInterface`:
- **Não é obrigatória**, mas é **boa prática**
- Avisa o compilador: "essa interface é pra ser usada com lambda"
- Se você adicionar um segundo método abstrato por engano, o compilador **reclama**

Uso:

```java
Operacao soma = (a, b) -> a + b;
Operacao mult = (a, b) -> a * b;

System.out.println(soma.aplicar(3, 4)); // 7
System.out.println(mult.aplicar(3, 4)); // 12
```

Detalhe: a interface pode ter **vários métodos `default`** e `static` — o limite é só sobre métodos **abstratos**.

---

## 📦 Interfaces prontas: `java.util.function`

O Java já vem com um catálogo de Functional Interfaces pra você não ficar criando uma toda hora. As mais usadas:

| Interface | Assinatura | Pra que serve |
|---|---|---|
| `Function<T, R>` | `R apply(T t)` | Transforma um valor: recebe `T`, devolve `R` |
| `Predicate<T>` | `boolean test(T t)` | Testa uma condição: recebe `T`, devolve `boolean` |
| `Consumer<T>` | `void accept(T t)` | Consome um valor: recebe `T`, devolve nada |
| `Supplier<T>` | `T get()` | Fornece um valor: não recebe nada, devolve `T` |
| `BiFunction<T, U, R>` | `R apply(T t, U u)` | Como `Function`, mas com 2 entradas |
| `UnaryOperator<T>` | `T apply(T t)` | `Function` em que entrada e saída são do mesmo tipo |

### Exemplos rápidos

```java
import java.util.function.*;

// Function: String -> Integer
Function<String, Integer> tamanho = s -> s.length();
System.out.println(tamanho.apply("Java")); // 4

// Predicate: testar se número é par
Predicate<Integer> ehPar = n -> n % 2 == 0;
System.out.println(ehPar.test(10)); // true

// Consumer: imprimir
Consumer<String> imprime = s -> System.out.println("> " + s);
imprime.accept("oi"); // > oi

// Supplier: gerar valor sob demanda
Supplier<Double> aleatorio = () -> Math.random();
System.out.println(aleatorio.get());

// BiFunction: somar
BiFunction<Integer, Integer, Integer> soma = (a, b) -> a + b;
System.out.println(soma.apply(2, 3)); // 5

// UnaryOperator: dobrar (entrada e saída Integer)
UnaryOperator<Integer> dobro = n -> n * 2;
System.out.println(dobro.apply(5)); // 10
```

### Combinando Predicates
`Predicate` tem métodos `default` muito úteis:

```java
Predicate<Integer> positivo = n -> n > 0;
Predicate<Integer> par = n -> n % 2 == 0;

Predicate<Integer> positivoEPar = positivo.and(par);
Predicate<Integer> positivoOuPar = positivo.or(par);
Predicate<Integer> negativo = positivo.negate();

System.out.println(positivoEPar.test(4));  // true
System.out.println(positivoEPar.test(-2)); // false
```

Esse `.and(...)` é o que vai brilhar no desafio.

---

## 🎯 Method reference — lambda ainda mais curta

Quando a lambda só **chama um método já pronto**, o Java tem um atalho: `Classe::metodo`.

```java
// Lambda tradicional
Function<String, String> upper1 = s -> s.toUpperCase();

// Method reference
Function<String, String> upper2 = String::toUpperCase;
```

Quatro tipos comuns:

```java
// 1. Método estático: Classe::metodo
Function<String, Integer> parse = Integer::parseInt;
// equivale a: s -> Integer.parseInt(s)

// 2. Método de instância de um objeto específico: objeto::metodo
Consumer<String> imprime = System.out::println;
// equivale a: s -> System.out.println(s)

// 3. Método de instância de um tipo: Classe::metodo
Function<String, Integer> tamanho = String::length;
// equivale a: s -> s.length()

// 4. Construtor: Classe::new
Supplier<ArrayList<String>> nova = ArrayList::new;
// equivale a: () -> new ArrayList<>()
```

Regra prática: **se sua lambda só repassa o argumento pra um método existente, troque por method reference**. Fica mais limpo.

---

## 🤔 Quando usar lambda?

Lambda **não substitui** classe — substitui **comportamento curto e descartável**. Bom para:

1. **Callbacks**: "rode esse código quando X acontecer"
   ```java
   botao.aoClicar(() -> System.out.println("clicou!"));
   ```

2. **Estratégias intercambiáveis**: passar **como** fazer algo
   ```java
   lista.sort((a, b) -> a.getIdade() - b.getIdade());
   ```

3. **Filtros e transformações** em coleções (vai ver no Módulo 14 com Streams)
   ```java
   lista.stream().filter(n -> n > 10).forEach(System.out::println);
   ```

4. **Configuração**: parametrizar comportamento de um método genérico — exatamente o que o desafio pede.

Quando **não** usar:
- Lambda muito grande (mais de 3-4 linhas): extraia pra método nomeado
- Lógica que se repete em vários lugares: vira método de verdade
- Precisa de estado próprio, vários métodos: usa classe normal

---

## ⚠️ Pegadinhas

- **`@FunctionalInterface` não é obrigatório**, mas usar previne dor de cabeça (Java avisa se quebrar a regra do método único).
- **Variáveis capturadas precisam ser `final` ou "effectively final"**: se você usa uma variável de fora da lambda, não pode reatribuir ela depois.
  ```java
  int x = 10;
  Function<Integer, Integer> f = n -> n + x; // OK
  // x = 20; // ❌ erro de compilação — x deixa de ser effectively final
  ```
- **Lambda não é "função"** isolada — é sempre instância de uma interface. Por isso o tipo precisa estar claro no contexto.

---

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode os 7 exercícios.
2. Encare o **desafio**: Sistema de Filtros Configuráveis.
3. No Módulo 14 vem **Streams**, que é onde lambdas brilham de verdade.

## ✅ Auto-verificação
- [ ] Sei escrever lambda na forma completa e na reduzida
- [ ] Sei o que é Functional Interface e pra que serve `@FunctionalInterface`
- [ ] Conheço `Function`, `Predicate`, `Consumer`, `Supplier`, `BiFunction`, `UnaryOperator`
- [ ] Sei usar method reference (`String::toUpperCase`, `System.out::println`)
- [ ] Sei combinar `Predicate` com `.and()`, `.or()`, `.negate()`
- [ ] Sei quando vale lambda e quando vale classe normal

Próximo módulo: **Streams** — processamento funcional de coleções, onde lambdas mostram pra que vieram.
