# Módulo 15 — Java Moderno (Optional, Records, Sealed, Pattern Matching)

> Recursos modernos — Java 14-21

> O Java mudou MUITO entre 2014 e 2024. Quem aprendeu Java 8 e parou tem uma surpresa boa pela frente: o código moderno é muito mais enxuto, expressivo e seguro.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Usar `Optional<T>` para evitar `NullPointerException`
- Criar `record` no lugar de POJOs (Plain Old Java Objects) cheios de boilerplate
- Restringir herança com `sealed classes`/`sealed interfaces`
- Usar **pattern matching** em `instanceof` e em `switch`
- Escrever strings multi-linha com **text blocks** (`"""..."""`)

---

## 1. Linha do tempo (pra saber em qual versão entrou cada coisa)

| Recurso | Versão estável | Ano |
|---|---|---|
| `Optional<T>` | Java 8 | 2014 |
| Text blocks `"""..."""` | Java 15 | 2020 |
| Records | Java 16 | 2021 |
| Pattern matching para `instanceof` | Java 16 | 2021 |
| Sealed classes / interfaces | Java 17 (LTS) | 2021 |
| Pattern matching para `switch` | Java 21 (LTS) | 2023 |

Você está no **JDK 21** — tem tudo isso disponível.

---

## 2. `Optional<T>` — o fim do `null` traiçoeiro

### O problema
```java
String nome = buscarNome(123);
System.out.println(nome.toUpperCase()); // 💥 NullPointerException se buscarNome retornou null
```

Em Java clássico, qualquer referência pode ser `null`. Você só descobre na hora do crash.

### A solução: `Optional<T>`
Uma "caixinha" que ou tem valor, ou está vazia — e o compilador te obriga a pensar nos dois casos.

```java
import java.util.Optional;

Optional<String> nome = buscarNome(123);

if (nome.isPresent()) {
    System.out.println(nome.get().toUpperCase());
} else {
    System.out.println("não achei");
}
```

### Criando um Optional
```java
Optional<String> cheio = Optional.of("texto");        // valor obrigatório (NPE se null)
Optional<String> talvez = Optional.ofNullable(maybe); // aceita null sem reclamar
Optional<String> vazio = Optional.empty();             // explicitamente vazio
```

### Métodos úteis (use esses, esqueça o `.get()`)
```java
Optional<String> nome = buscarNome(123);

// orElse: valor padrão se vazio
String resultado = nome.orElse("desconhecido");

// orElseThrow: lança exceção se vazio
String obrigatorio = nome.orElseThrow(() -> new RuntimeException("vazio!"));

// ifPresent: roda só se tiver valor
nome.ifPresent(n -> System.out.println("achei: " + n));

// map: transforma se tiver valor (continua Optional)
Optional<Integer> tamanho = nome.map(String::length);

// filter: mantém só se passar no teste
Optional<String> nomeLongo = nome.filter(n -> n.length() > 5);
```

### Encadeando (estilo "pipeline")
```java
String saida = buscarUsuario(id)
        .map(Usuario::getNome)
        .map(String::toUpperCase)
        .filter(n -> !n.isBlank())
        .orElse("ANÔNIMO");
```

> 💡 **Regra de ouro**: use `Optional` em **retornos de método**. Não use em campos de classe nem em parâmetros — a comunidade Java considera anti-padrão.

---

## 3. `record` — adeus boilerplate

### O drama do POJO clássico
Pra ter uma classe imutável simples com nome e idade você escrevia:

```java
public class Pessoa {
    private final String nome;
    private final int idade;

    public Pessoa(String nome, int idade) {
        this.nome = nome;
        this.idade = idade;
    }

    public String getNome() { return nome; }
    public int getIdade() { return idade; }

    @Override
    public boolean equals(Object o) { /* 10 linhas */ }
    @Override
    public int hashCode() { /* 3 linhas */ }
    @Override
    public String toString() { /* mais linhas */ }
}
```

30 linhas pra carregar **dois campos**.

### Com `record` (Java 16+)
```java
public record Pessoa(String nome, int idade) {}
```

**Uma linha.** E você ganha de graça:
- Construtor `Pessoa(String, int)`
- Getters: `pessoa.nome()`, `pessoa.idade()` (sem o prefixo `get`!)
- `equals` e `hashCode` (compara campo a campo)
- `toString` legível: `Pessoa[nome=David, idade=30]`
- Campos `final` automáticos (imutáveis)

### Usando
```java
Pessoa p1 = new Pessoa("David", 30);
Pessoa p2 = new Pessoa("David", 30);

System.out.println(p1.nome());      // David
System.out.println(p1);             // Pessoa[nome=David, idade=30]
System.out.println(p1.equals(p2));  // true (compara conteúdo, não referência)
```

### Records aceitam métodos, validação e constantes
```java
public record Produto(String nome, double preco) {
    // construtor compacto — valida antes de atribuir
    public Produto {
        if (preco < 0) throw new IllegalArgumentException("preço negativo");
    }

    // método extra
    public double precoComImposto() {
        return preco * 1.1;
    }

    // constante estática
    public static final Produto VAZIO = new Produto("", 0);
}
```

> 💡 Records **não podem herdar** de outra classe (já estendem `Record` internamente), mas podem **implementar interfaces**.

---

## 4. `sealed` — controlar quem pode herdar

### O problema
Quando você cria `interface Forma`, qualquer classe no mundo pode implementar. Isso te impede de fazer um `switch` "completo" porque sempre pode aparecer uma forma nova.

### A solução: `sealed` (Java 17+)
Você lista **exatamente** quem pode estender/implementar:

```java
public sealed interface Forma permits Circulo, Quadrado, Triangulo {}

public record Circulo(double raio) implements Forma {}
public record Quadrado(double lado) implements Forma {}
public record Triangulo(double base, double altura) implements Forma {}
```

Agora `Forma` é um conjunto **fechado** de 3 possibilidades. O compilador sabe disso e te ajuda no `switch` (próxima seção).

### Modificadores dos filhos
Toda classe que aparece em `permits` precisa declarar UM destes:
- `final` — não pode ter mais filhos
- `sealed` — também sela quem herda dela
- `non-sealed` — abre de novo (qualquer um pode herdar)

`record` é implicitamente `final`, então records combinam perfeitamente com `sealed`.

---

## 5. Pattern matching para `instanceof` (Java 16+)

### Antes (chato)
```java
if (obj instanceof String) {
    String s = (String) obj; // cast manual
    System.out.println(s.toUpperCase());
}
```

### Depois (limpo)
```java
if (obj instanceof String s) { // já cria a variável s do tipo certo
    System.out.println(s.toUpperCase());
}
```

A variável `s` só existe dentro do `if` — fora dela o compilador "esquece".

### Com `&&`
```java
if (obj instanceof String s && s.length() > 5) {
    System.out.println(s);
}
```

---

## 6. `switch` expression com pattern matching (Java 21+)

### O combo perfeito: `sealed` + `record` + `switch`
```java
sealed interface Forma permits Circulo, Quadrado, Triangulo {}
record Circulo(double raio) implements Forma {}
record Quadrado(double lado) implements Forma {}
record Triangulo(double base, double altura) implements Forma {}

static double area(Forma f) {
    return switch (f) {
        case Circulo c -> Math.PI * c.raio() * c.raio();
        case Quadrado q -> q.lado() * q.lado();
        case Triangulo t -> t.base() * t.altura() / 2;
    };
}
```

Repare:
- `switch` aqui é **expressão** (retorna valor), não comando.
- Cada `case` casa um **tipo** e já cria a variável (`c`, `q`, `t`).
- Não precisa de `default` porque `sealed` garante que cobrimos tudo.
- Setinha `->` no lugar de `:` + `break`.

### Com guarda `when`
```java
String classificar(Forma f) {
    return switch (f) {
        case Circulo c when c.raio() > 10 -> "círculo grande";
        case Circulo c                    -> "círculo pequeno";
        case Quadrado q                   -> "quadrado";
        case Triangulo t                  -> "triângulo";
    };
}
```

### Casando com `null`
```java
String descrever(Object o) {
    return switch (o) {
        case null         -> "nada";
        case String s     -> "texto: " + s;
        case Integer i    -> "número: " + i;
        default           -> "outro tipo";
    };
}
```

Antes do Java 21, `switch (null)` jogava `NullPointerException`. Agora você pode tratar.

---

## 7. Text blocks `"""..."""` (Java 15+)

Pra strings multi-linha (JSON, SQL, HTML) sem o festival de `\n` e `+`:

### Antes
```java
String json = "{\n" +
              "  \"nome\": \"David\",\n" +
              "  \"idade\": 30\n" +
              "}";
```

### Depois
```java
String json = """
        {
          "nome": "David",
          "idade": 30
        }
        """;
```

Regras rápidas:
- Abre e fecha com `"""` em linhas próprias.
- A indentação comum é **removida automaticamente** (alinha pela linha de fechamento).
- Aspas internas **não precisam de escape**.
- Você pode interpolar com `.formatted(...)`:

```java
String nome = "David";
String json = """
        { "nome": "%s" }
        """.formatted(nome);
```

---

## 8. Por que isso importa

| Sem moderno | Com moderno |
|---|---|
| `null` virando bomba | `Optional<T>` força você a tratar |
| POJO de 40 linhas | `record` de 1 linha |
| Herança "selvagem" | `sealed` lista quem entra |
| `instanceof` + cast feio | `instanceof String s` |
| `switch` com `break` e bug | `switch` expression com `->` |
| JSON com `\n` e `+` | text block `"""..."""` |

Resultado: **menos código, menos bug, mais legibilidade**. Java em 2024 não parece o mesmo de 2014 — e é por aí que projetos modernos (Spring Boot 3, Quarkus, etc) já estão indo.

---

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode os 7 exercícios.
2. Encare o **desafio**: refatorar um modelo "antigo" pro moderno.
3. Tente reescrever código que você fez em módulos passados usando esses recursos — é o melhor jeito de fixar.

## ✅ Auto-verificação
- [ ] Sei diferenciar `Optional.of`, `Optional.ofNullable` e `Optional.empty`
- [ ] Sei encadear `.map().filter().orElse()` num Optional
- [ ] Consigo declarar um `record` e usar seus getters
- [ ] Entendo o papel de `sealed` + `permits`
- [ ] Uso `instanceof String s` em vez de cast manual
- [ ] Escrevo `switch` expression com `case Tipo var ->`
- [ ] Sei abrir um text block `"""..."""`

Próximo módulo: encerramento do curso ou aprofundamento em frameworks (Spring/JUnit) — você terminou a parte de linguagem.
