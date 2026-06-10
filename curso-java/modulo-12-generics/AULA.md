# Módulo 12 — Generics

> Corresponde às aulas do Java10x: *Generics Parte 1* (16:58) e *Generics Parte 2* (13:57).
> Na Parte 1 ele introduz a ideia com a **bolsa de ferramentas do ninja** (uma classe que pode guardar qualquer tipo de item). Na Parte 2 ele formaliza com `InfoNinja<T>` e métodos genéricos.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender **por que** generics existem (evitar cast e `ClassCastException`)
- Criar classes com **type parameter** (`<T>`) — tipo `Bolsa<T>` e `InfoNinja<T>`
- Criar métodos genéricos (`<T> T metodo(...)`)
- Usar **bounded types** (`<T extends Number>`)
- Usar **wildcards**: `?`, `? extends T`, `? super T` (regra PECS)
- Entender o que é **type erasure** e suas limitações
- Usar múltiplos parâmetros de tipo (`<K, V>`)

## 🤔 Por que generics existem?

Imagina o **Naruto** com uma bolsa de ferramentas ninja. Antes dele entender que cada bolsa serve pra um tipo de item, ele jogava tudo dentro do mesmo saco: kunai, shuriken, pergaminho, ramen frio... e na hora de pegar, era loteria.

No Java pré-2004 (antes da versão 5) era a mesma coisa — listas sem tipo:

```java
List bolsa = new ArrayList();   // sem tipo!
bolsa.add("Kunai");
bolsa.add(42);                  // aceita qualquer coisa

String item = (String) bolsa.get(0);   // precisa fazer cast (forçar o tipo)
String x    = (String) bolsa.get(1);   // BOOM! ClassCastException em runtime
```

Dois problemas grandes:
1. **Cast manual** toda vez que tirava algo da bolsa (poluído e chato).
2. **Erro só estoura em runtime** — o compilador não avisava nada.

Generics resolvem isso:

```java
List<String> bolsa = new ArrayList<>();
bolsa.add("Kunai");
// bolsa.add(42);   // ❌ erro de COMPILAÇÃO — pega antes de rodar

String item = bolsa.get(0);   // sem cast, o compilador já sabe que é String
```

Em uma frase: **generics dão segurança de tipo em tempo de compilação e eliminam casts**.

## 🧱 Type parameter `<T>` em classes — a Bolsa do Ninja

O `<T>` é um "espaço em branco" pro tipo. Você escreve a classe **uma vez** e quem usa decide qual ferramenta entra na bolsa.

```java
public class Bolsa<T> {
    private T item;

    public void guardar(T item) {
        this.item = item;
    }

    public T pegar() {
        return item;
    }
}
```

Usando:

```java
Bolsa<Kunai> bolsaKunai = new Bolsa<>();
bolsaKunai.guardar(new Kunai());
Kunai k = bolsaKunai.pegar();        // sem cast — compilador sabe que é Kunai

Bolsa<Shuriken> bolsaShuriken = new Bolsa<>();
bolsaShuriken.guardar(new Shuriken());

Bolsa<Pergaminho> bolsaPergaminho = new Bolsa<>();
bolsaPergaminho.guardar(new Pergaminho("Rasengan"));
```

Mesma classe, três usos seguros e diferentes — sem duplicar código.

> 💡 O `T` é convenção (Type). Outras letras comuns: `E` (Element), `K`/`V` (Key/Value), `R` (Return), `N` (Number).

### O exemplo do Java10x: `InfoNinja<T>`

Na Parte 2 ele monta uma classe que guarda **qualquer informação** de um ninja — pode ser nível (int), apelido (String), aldeia (objeto), o que for:

```java
public class InfoNinja<T> {
    private T info;

    public InfoNinja(T info) {
        this.info = info;
    }

    public T getInfo() {
        return info;
    }
}
```

```java
InfoNinja<String>  apelido = new InfoNinja<>("Raposa de Nove Caudas");
InfoNinja<Integer> nivel   = new InfoNinja<>(99);
InfoNinja<Boolean> vivo    = new InfoNinja<>(true);
```

A mesma classe serve pra qualquer tipo, sem precisar criar `InfoNinjaString`, `InfoNinjaInteger`, etc.

## 🛠️ Métodos genéricos

Você também pode declarar `<T>` em **um método específico**, sem a classe inteira ser genérica:

```java
public static <T> T primeiro(List<T> lista) {
    return lista.get(0);
}
```

O `<T>` antes do tipo de retorno **declara** que esse método tem um parâmetro de tipo. O compilador deduz o `T` pelo argumento:

```java
List<String> ninjas = List.of("Naruto", "Sasuke", "Sakura");
String primeiroNinja = primeiro(ninjas);   // T vira String

List<Integer> niveis = List.of(99, 80, 70);
int n = primeiro(niveis);                  // T vira Integer
```

## 📚 Exemplos da stdlib

A biblioteca padrão é cheia de generics — você já usa há módulos:

```java
List<Ninja> equipe          = new ArrayList<>();
Map<String, Integer> niveis = new HashMap<>();
Set<Long> ids               = new HashSet<>();
Optional<Ninja> hokage      = Optional.empty();
```

Sem generics, tudo isso ia exigir cast.

## 🚧 Bounded types: `<T extends Number>`

Às vezes você quer aceitar **qualquer tipo, mas com alguma restrição**. Exemplo: somar o chakra de vários ninjas — só faz sentido com números.

```java
public static <T extends Number> double somarChakra(List<T> chakras) {
    double total = 0;
    for (T n : chakras) {
        total += n.doubleValue();   // posso chamar isso porque T É um Number
    }
    return total;
}
```

Sem o `extends Number`, o compilador não deixaria chamar `doubleValue()` (porque `T` poderia ser qualquer coisa, até `String`).

> 💡 `extends` aqui significa "É um Number ou subclasse dele" — vale tanto pra classe quanto pra interface (sim, mesmo pra interface usa `extends`, não `implements`).

Também dá pra restringir a uma classe do domínio:

```java
public static <T extends Ninja> void treinar(T ninja) {
    ninja.meditar();   // só compila porque sabemos que T é Ninja
}
```

## 🃏 Wildcards (`?`)

Wildcard (`?`) é o "qualquer tipo, não importa qual". Aparece muito em **parâmetros de método**.

### `?` puro: qualquer tipo

```java
public static void inspecionar(List<?> bolsa) {
    for (Object item : bolsa) {
        System.out.println(item);
    }
}
```

Aceita `List<Kunai>`, `List<Shuriken>`, `List<String>`... qualquer um. Mas você **só pode ler como Object** — não dá pra adicionar (exceto `null`), porque o compilador não sabe o tipo certo.

### `? extends T`: T ou subclasse (covariância — só leitura)

```java
public static void apresentarTime(List<? extends Ninja> time) {
    for (Ninja n : time) {
        System.out.println(n.getNome());
    }
}
```

Aceita `List<Ninja>`, `List<Genin>`, `List<Jounin>`. Bom pra **consumir** (ler) elementos.

### `? super T`: T ou superclasse (contravariância — só escrita)

```java
public static void recrutarGenin(List<? super Genin> registro) {
    registro.add(new Genin("Konohamaru"));
    registro.add(new Genin("Moegi"));
}
```

Aceita `List<Genin>`, `List<Ninja>`, `List<Object>`. Bom pra **produzir** (escrever) elementos.

> 💡 Regra mnemônica **PECS** (do livro Effective Java):
> **P**roducer **E**xtends, **C**onsumer **S**uper.
> Se a estrutura te dá coisas (você LÊ) → `extends`.
> Se você joga coisas dentro (você ESCREVE) → `super`.

## 👻 Type erasure (a pegadinha do Java)

Esse é o ponto que mais confunde quem vem de outras linguagens.

**No código-fonte**, você vê `List<Kunai>`, `Bolsa<Pergaminho>`, etc.
**Em runtime**, o Java **apaga** os parâmetros de tipo. Tudo vira só `List` e `Bolsa`.

Isso se chama **type erasure** (apagamento de tipo). Foi feito assim por compatibilidade com código antigo (pré-Java 5).

Consequências práticas — o que **NÃO** dá pra fazer:

```java
// ❌ NÃO COMPILA — não dá pra fazer instanceof em T
public <T> boolean ehDoTipo(Object o) {
    return o instanceof T;
}

// ❌ NÃO COMPILA — não dá pra criar array de tipo genérico
T[] array = new T[10];

// ❌ NÃO COMPILA — não dá pra usar T.class
Class<T> c = T.class;

// ❌ NÃO COMPILA — não dá pra instanciar T direto
T novo = new T();
```

```java
// ✅ Em runtime, esses dois são o MESMO tipo
Bolsa<Kunai>      a = new Bolsa<>();
Bolsa<Pergaminho> b = new Bolsa<>();
System.out.println(a.getClass() == b.getClass());   // true!
```

> 💡 Se você precisa do tipo em runtime, o truque é passar um `Class<T>` no construtor: `new Bolsa<>(Kunai.class)`.

## 🗝️ Múltiplos parâmetros `<K, V>`

Você pode ter quantos parâmetros de tipo quiser. Exemplo: um par chave/valor pra catalogar jutsus por nome:

```java
public class Par<K, V> {
    private final K chave;
    private final V valor;

    public Par(K chave, V valor) {
        this.chave = chave;
        this.valor = valor;
    }

    public K getChave() { return chave; }
    public V getValor() { return valor; }
}
```

Uso:

```java
Par<String, Integer> nivelDoNaruto = new Par<>("Naruto", 99);
Par<String, String>  aldeiaDoNinja = new Par<>("Sasuke", "Konoha");
```

A própria `Map<K, V>` da stdlib usa isso (cada `Map.Entry` é um par genérico).

## ⚠️ Pegadinhas que valem ouro
- **Tipos primitivos não entram**: `List<int>` ❌ — tem que ser `List<Integer>` (usa o wrapper). Generics só aceitam objetos.
- **`new T()` não funciona**: por causa do type erasure, não dá pra instanciar `T` direto.
- **Cuidado com arrays**: `new T[]` não compila. Use `List<T>` em vez de array genérico.
- **`List<Ninja>` ≠ `List<Genin>`**: mesmo que `Genin extends Ninja`, as listas **não** são compatíveis (use wildcard `? extends Ninja` quando precisar).
- **Diamond `<>` (Java 7+)**: do lado direito dá pra omitir o tipo: `new Bolsa<>()` em vez de `new Bolsa<Kunai>()`.
- **`remove(int)` vs `remove(Object)`** em `List<Integer>`: chamar `lista.remove(3)` apaga o **índice** 3, não o valor 3. Use `lista.remove(Integer.valueOf(3))`.

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e veja exemplos de cada conceito (Bolsa, InfoNinja, bounded, wildcards, erasure).
2. Encare o **desafio**: Caixa Genérica do Ninja, com filtro próprio.
3. Pro próximo módulo: **Functional Interfaces e Lambdas** — onde os generics ficam ainda mais úteis.

## ✅ Auto-verificação
- [ ] Sei explicar por que generics existem (cast + ClassCastException)
- [ ] Consigo criar uma classe `Bolsa<T>` ou `InfoNinja<T>` do zero
- [ ] Sei escrever um método genérico `<T> T metodo(...)`
- [ ] Entendo o que é um bounded type (`<T extends Number>`, `<T extends Ninja>`)
- [ ] Sei a diferença entre `?`, `? extends T` e `? super T` (e o que é PECS)
- [ ] Sei o que é type erasure e por que não dá pra `instanceof T`
- [ ] Consigo usar múltiplos parâmetros `<K, V>`

Próximo módulo: **Functional Interfaces e Lambdas** — código mais expressivo com `Predicate`, `Function`, `Consumer` e `Supplier`.
