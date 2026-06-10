# Módulo 03 — Condicionais

> Corresponde às aulas do Java10x: *Condicionais criando lógica para o Narutinho*, *Switch cases*, *Ternários*.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Tomar decisões no código com `if`, `else if` e `else`
- Combinar condições usando operadores lógicos (`&&`, `||`, `!`)
- Comparar valores com `==`, `!=`, `<`, `>`, `<=`, `>=`
- Escolher entre múltiplos caminhos com `switch` clássico
- Usar `switch expression` (Java 14+) com `->` e múltiplos labels
- Resolver decisões curtas com o operador ternário `cond ? a : b`

## 🧠 Por que condicionais existem
Programa sem condicional é uma receita de bolo que sempre faz a mesma coisa. O `if` é o que faz seu código **reagir** aos dados. Login funcionou? Saldo suficiente? Nota passou? Tudo isso é condicional.

## 🔀 `if` / `else` — a decisão básica

```java
int idade = 18;

if (idade >= 18) {
    System.out.println("Maior de idade");
} else {
    System.out.println("Menor de idade");
}
```

Regras:
- A condição vai entre **parênteses** e precisa ser `boolean` (`true` ou `false`).
- Os blocos vão entre **chaves** `{ }`. Se for uma linha só dá pra omitir, mas **não faça isso** — sempre use chaves. Bug clássico.
- O `else` é opcional.

## 🪜 `else if` — cadeia de decisões

```java
int nota = 7;

if (nota >= 9) {
    System.out.println("A");
} else if (nota >= 7) {
    System.out.println("B");
} else if (nota >= 5) {
    System.out.println("C");
} else {
    System.out.println("Reprovado");
}
```

Java **avalia de cima pra baixo** e para no primeiro `true`. Ordem importa: se você inverter, sai resposta errada.

## ⚖️ Operadores de comparação
Sempre retornam `boolean`.

| Operador | Significado          | Exemplo (`a=5`, `b=3`) |
|----------|----------------------|-------------------------|
| `==`     | igual a              | `a == b` → `false`      |
| `!=`     | diferente de         | `a != b` → `true`       |
| `<`      | menor que            | `a < b`  → `false`      |
| `>`      | maior que            | `a > b`  → `true`       |
| `<=`     | menor ou igual       | `a <= 5` → `true`       |
| `>=`     | maior ou igual       | `a >= 5` → `true`       |

> ⚠️ **Pegadinha com Strings**: `"abc" == "abc"` pode dar `true` ou `false` dependendo do caso. **Compare String com `.equals()`**, sempre: `nome.equals("David")`.

## 🔗 Operadores lógicos
Combinam várias condições.

| Operador | Nome | Resultado                                       |
|----------|------|--------------------------------------------------|
| `&&`     | E    | `true` só se **ambas** forem `true`              |
| `\|\|`   | OU   | `true` se **pelo menos uma** for `true`          |
| `!`      | NÃO  | inverte o valor (`!true` → `false`)              |

```java
int idade = 25;
boolean temCNH = true;

if (idade >= 18 && temCNH) {
    System.out.println("Pode dirigir");
}

if (idade < 18 || !temCNH) {
    System.out.println("Não pode dirigir");
}
```

**Curto-circuito**: o Java é esperto. Em `a && b`, se `a` já é `false`, ele **nem avalia** `b`. Em `a || b`, se `a` já é `true`, ignora o `b`. Isso evita erros como dividir por zero numa segunda condição.

## 🎚️ Operador ternário — `if` em uma linha

Quando o `if`/`else` só serve pra escolher um valor, dá pra encolher:

```java
int idade = 20;
String status = (idade >= 18) ? "adulto" : "menor";
System.out.println(status); // adulto
```

Forma: `condicao ? valorSeTrue : valorSeFalse`.

Use pra **atribuições simples**. Pra lógica grande, volta pro `if` — fica mais legível.

## 🎛️ `switch` clássico

Quando você compara **uma variável** contra **vários valores fixos**, o `switch` deixa o código mais limpo que uma cadeia gigante de `else if`.

```java
int dia = 3;

switch (dia) {
    case 1:
        System.out.println("Segunda");
        break;
    case 2:
        System.out.println("Terça");
        break;
    case 3:
        System.out.println("Quarta");
        break;
    default:
        System.out.println("Outro dia");
}
```

Pontos importantes:
- O `break` **é obrigatório** se você não quiser cair no próximo `case` (comportamento de "fall-through").
- O `default` é opcional, mas é boa prática.
- Funciona com `int`, `String`, `char`, `enum`, etc.

### O perigo do fall-through

```java
switch (dia) {
    case 1:
        System.out.println("Segunda");
        // sem break! cai no próximo
    case 2:
        System.out.println("Terça");
        break;
}
// dia=1 imprime "Segunda" E "Terça" 🐛
```

Esquecer um `break` é um dos bugs mais clássicos do Java pré-14.

## 🚀 `switch expression` (Java 14+) — versão moderna

A partir do Java 14, o `switch` ganhou uma sintaxe nova com `->` que:
- **Não tem fall-through** (não precisa de `break`).
- Pode **retornar valor** (vira uma expressão).
- Permite **múltiplos labels** num case só.

```java
int dia = 3;

String nome = switch (dia) {
    case 1 -> "Segunda";
    case 2 -> "Terça";
    case 3 -> "Quarta";
    case 4 -> "Quinta";
    case 5 -> "Sexta";
    case 6, 7 -> "Fim de semana"; // múltiplos labels
    default -> "Inválido";
};

System.out.println(nome);
```

Bloco com várias linhas usa `yield` pra "retornar":

```java
String tipo = switch (dia) {
    case 1, 2, 3, 4, 5 -> "Dia útil";
    case 6, 7 -> {
        System.out.println("Bora descansar");
        yield "Fim de semana";
    }
    default -> "Inválido";
};
```

> 💡 Use `switch expression` sempre que puder — é mais seguro e mais curto.

## 🧮 Tabela rápida: qual usar?

| Situação                                       | Ferramenta            |
|------------------------------------------------|-----------------------|
| Uma condição simples (true/false)              | `if` / `else`         |
| Várias faixas (`>= 9`, `>= 7`, …)              | `if` / `else if`      |
| Comparar 1 variável contra valores fixos       | `switch expression`   |
| Atribuir valor curto baseado em condição       | ternário `? :`        |

## 💡 Pegadinhas que valem ouro
- **`=` ≠ `==`**: `=` atribui, `==` compara. `if (x = 5)` nem compila pra `int` (bom!).
- **String com `.equals()`**: nunca compare String com `==`.
- **Sempre use chaves no `if`**, mesmo de uma linha. Evita bugs em edição futura.
- **`break` no switch clássico**: esqueceu, caiu no próximo case.
- **Curto-circuito é seu amigo**: `if (obj != null && obj.algo())` evita `NullPointerException`.

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode cada método.
2. Encare o **desafio**: Classificador de Notas.
3. Quando estiver confortável, vá pro Módulo 04.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `==` e `.equals()` pra String
- [ ] Sei quando usar `&&` vs `||`
- [ ] Sei o que é fall-through no `switch` clássico
- [ ] Sei usar `switch expression` com `->` e múltiplos labels
- [ ] Sei quando o ternário melhora o código (e quando piora)

Próximo módulo: **Laços de repetição** — `for`, `while`, `do-while`.
