# Módulo 06 — Classes e Objetos

> Corresponde às aulas do Java10x: *Classes e objetos - Tudo é um objeto no Java!*, *Orientação a objeto - Java, Kotlin, Swift, Dart*, *Métodos e parâmetros*, *Referência de memória x Valor em memória = toString*.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender a diferença entre **classe** (molde) e **objeto** (instância criada com `new`)
- Reconhecer os **três pilares da OO** (Encapsulamento, Herança, Polimorfismo) — só uma vista do alto
- Escrever **métodos** com e sem **parâmetros**
- Distinguir **referência de memória** (objetos) de **valor em memória** (primitivos)
- Sobrescrever `toString()` pra imprimir objetos de forma legível (e não o endereço de memória)

## 🍥 Tudo é um objeto no Java

Uma aplicação Java é feita **em camadas de objetos** conversando entre si. A aula do Java10x deixa claro: classes e objetos são a **base** de tudo que você vai construir daqui pra frente. Spring, Android, microsserviço — no fundo é objeto chamando método de outro objeto.

Antes de cair no código, fixa essa ideia:

- **Classe** = o molde. Diz **como** é a estrutura (campos) e o que ela **sabe fazer** (métodos). É um projeto, não ocupa lugar no mundo real.
- **Objeto** = a coisa concreta. É uma **instância** da classe, com valores próprios, vivendo na memória.

Analogia ninja:
- Classe: `Ninja` (todo ninja tem nome, clã, chakra, e sabe atacar)
- Objeto: o ninja **Naruto Uzumaki**, com nome="Naruto", clã="Uzumaki", chakra=9000 — específico, real

Uma classe pode gerar **infinitos objetos** (uma vila inteira de ninjas).

---

## 🏯 Os três pilares da Orientação a Objeto

A aula *Orientação a objeto - Java, Kotlin, Swift, Dart* lembra que OO não é coisa só do Java — Kotlin, Swift, Dart, C# usam os mesmos três pilares. Aqui só pra você ouvir o nome; **cada um vai ter seu módulo dedicado**:

1. **Encapsulamento** — esconder o que é interno (`private`) e expor o que é seguro. Próximo módulo.
2. **Herança** — uma classe filha aproveita o que a classe mãe já tem (`Uzumaki extends Ninja`). Mais à frente.
3. **Polimorfismo** — o mesmo método se comportar diferente dependendo do objeto. Vem junto com herança.

Neste módulo a gente só constrói a **base**: classes, objetos, métodos. Sem isso, os pilares não param em pé.

---

## 🧩 Anatomia de uma classe

```java
public class Ninja {
    // 1. Campos (atributos) — o que o Ninja TEM
    String nome;
    String cla;
    int chakra;

    // 2. Métodos — o que o Ninja FAZ
    void apresentar() {
        System.out.println("Eu sou " + nome + " do clã " + cla + "!");
    }
}
```

Três partes essenciais:
1. **Declaração da classe**: `public class Ninja { ... }`
2. **Campos**: variáveis que pertencem a cada objeto.
3. **Métodos**: funções que pertencem à classe.

---

## 🏗️ Criando objetos com `new`

A palavra `new` é a "fábrica de objetos". Ela aloca memória e devolve uma **referência** pro objeto criado:

```java
Ninja n1 = new Ninja();      // cria um objeto Ninja
n1.nome = "Naruto";
n1.cla = "Uzumaki";
n1.chakra = 9000;
n1.apresentar();             // Eu sou Naruto do clã Uzumaki!

Ninja n2 = new Ninja();      // outro objeto, totalmente independente
n2.nome = "Sasuke";
n2.cla = "Uchiha";
n2.chakra = 7000;
n2.apresentar();             // Eu sou Sasuke do clã Uchiha!
```

Cada `new Ninja()` cria um **objeto novo**, com seu próprio espaço na memória.

---

## ⚙️ Métodos e parâmetros

A aula *Métodos e parâmetros* do Java10x define: método é **um bloco de código reutilizável** que recebe **parâmetros** (entradas) e (opcionalmente) devolve um valor. Em vez de copiar a mesma lógica em vários lugares, você dá um nome e chama.

```java
class Ninja {
    String nome;
    int chakra;

    // Método SEM parâmetro, sem retorno
    void meditar() {
        this.chakra = this.chakra + 100;
    }

    // Método COM parâmetro (recebe outro Ninja como alvo)
    void atacar(Ninja alvo) {
        System.out.println(this.nome + " atacou " + alvo.nome + "!");
        alvo.chakra = alvo.chakra - 50;
    }

    // Método COM parâmetro e RETORNO
    int chakraRestante() {
        return this.chakra;
    }
}
```

Coisas pra notar:
- `void` = não retorna nada. Senão você declara o tipo do retorno (`int`, `String`, `Ninja`, etc) e usa `return`.
- **Parâmetros** vão entre parênteses: `(Ninja alvo)` significa "este método espera receber um Ninja, e dentro dele chamamos esse Ninja de `alvo`".
- `this` é o "eu mesmo" — o objeto que está executando o método agora. Útil quando o parâmetro tem o mesmo nome do campo.

---

## 🧠 Referência de memória x Valor em memória

**Esta é a parte mais importante do módulo.** A aula homônima do Java10x bate nisso com força porque é a fonte da maior parte das confusões em Java.

### Primitivos guardam VALOR
Tipos primitivos (`int`, `double`, `char`, `boolean`, `long`, `float`, `byte`, `short`) guardam **o valor diretamente** na variável.

```java
int chakraA = 100;
int chakraB = chakraA;     // COPIA o valor
chakraB = 999;

System.out.println(chakraA);   // 100 (não mudou)
System.out.println(chakraB);   // 999
```

Cada variável tem sua própria "caixinha" com o valor dentro. Mexer em uma não afeta a outra.

### Objetos guardam REFERÊNCIA
Quando você cria um objeto, a variável **não guarda o objeto** — guarda **uma seta** apontando pro objeto na memória.

```java
Ninja a = new Ninja();
a.nome = "Naruto";

Ninja b = a;          // NÃO copia o objeto — copia a SETA
b.nome = "Boruto";    // mexe pelo b...

System.out.println(a.nome);   // imprime "Boruto", não "Naruto"!
System.out.println(b.nome);   // "Boruto"
System.out.println(a == b);   // true — mesma referência
```

`a` e `b` apontam **pro mesmo objeto na memória**. Mexer por uma "seta" reflete na outra. Esse é o famoso efeito de **aliasing**.

### Em parâmetros de método também
```java
static void enfraquecer(Ninja n) {
    n.chakra = 0;     // mexe no objeto original!
}

Ninja naruto = new Ninja();
naruto.chakra = 9000;
enfraquecer(naruto);
System.out.println(naruto.chakra);   // 0
```

| Tipo | Como vai pra outra variável / método |
|---|---|
| `int`, `double`, `char`, `boolean`... | **Cópia do valor** (primitivos) |
| `String`, arrays, objetos | **Cópia da referência** (a seta) |

> Mnemônico: **primitivo é caixa, objeto é controle remoto**. Você pode ter dois controles remotos pra mesma TV (objeto). Tem dois ninjas — tem dois objetos. Tem duas variáveis — pode ser uma TV só com dois controles.

---

## 🖨️ Sobrescrevendo `toString()`

Se você imprime um objeto direto:

```java
Ninja naruto = new Ninja();
naruto.nome = "Naruto";
System.out.println(naruto);   // Ninja@1b6d3586  ← endereço de memória, ilegível
```

Esse `Ninja@1b6d3586` é exatamente a **referência de memória** que falamos acima. Pra imprimir algo útil, **sobrescreva** o método `toString()`:

```java
class Ninja {
    String nome;
    String cla;
    int chakra;

    @Override
    public String toString() {
        return "Ninja{nome='" + nome + "', cla='" + cla + "', chakra=" + chakra + "}";
    }
}

Ninja naruto = new Ninja();
naruto.nome = "Naruto"; naruto.cla = "Uzumaki"; naruto.chakra = 9000;
System.out.println(naruto);
// Ninja{nome='Naruto', cla='Uzumaki', chakra=9000}
```

Detalhes:
- `@Override` avisa o compilador que você está **sobrescrevendo** um método da classe-mãe `Object` (toda classe em Java herda de `Object`, que já tem `toString` — só que feio).
- `println` chama `toString()` **automaticamente** quando recebe um objeto.
- Concatenação com `+` também: `"Olá " + naruto` chama `naruto.toString()` por baixo dos panos.
- Convenção: `NomeDaClasse{campo1=valor, campo2=valor}`.

---

## 💡 Pegadinhas que valem ouro
- **Esqueceu o `new`?** A variável fica `null` e qualquer acesso a campo dá `NullPointerException` (NPE). É o erro mais famoso do Java.
- **Comparar objetos com `==`?** Compara as **referências** (as setas), não o conteúdo. Pra comparar conteúdo, use `equals()` (vem em módulos futuros).
- **Campo sem valor inicial?** Java atribui *default*: `0` pra números, `false` pra boolean, `null` pra objetos/strings.
- **Passou objeto pro método e modificou?** Modificou o original. Isso é feature, não bug — mas precisa ter na cabeça.

---

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** — exercícios resolvidos com `Ninja`, referência vs valor, e `toString()`.
2. Encare o **desafio**: Sistema de Personagens (batalha ninja).
3. Próximo módulo: **construtores e encapsulamento** (`private`, getters/setters) — o pilar do Encapsulamento que mencionamos aqui.

## ✅ Auto-verificação
- [ ] Sei explicar a diferença entre classe e objeto
- [ ] Sei criar um objeto com `new` e preencher campos
- [ ] Sei o nome dos três pilares da OO
- [ ] Sei declarar um método com parâmetros e retorno
- [ ] Entendo que objeto é referência e primitivo é valor
- [ ] Sei sobrescrever `toString()` com `@Override`

Próximo módulo: **Construtores e Encapsulamento** — inicializar objetos do jeito certo e proteger seus campos.
