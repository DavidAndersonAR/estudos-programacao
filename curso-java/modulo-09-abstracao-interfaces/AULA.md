# Módulo 09 — Abstração e Interfaces

> Corresponde às aulas do Java10x: *Interfaces - Uma explicação simples* (16:47), *Classes Abstratas - O que caralhos é isso?* (8:19), *Classes abstratas x interfaces* (10:54), *Polimorfismo + Abstração* (14:14), *Herança Múltipla com interfaces* (18:36).

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é **abstração** (esconder o "como", expor o "o quê")
- Criar **classes abstratas** com métodos abstratos e concretos
- Criar **interfaces** e fazer classes que `implements` várias delas
- Usar `default`, `static` e `private` methods em interfaces (Java 8/9+)
- Decidir **quando usar classe abstrata vs interface** (com base em estado, contrato e herança múltipla)
- Combinar **polimorfismo + abstração** pra trocar implementações sem mexer no código que usa
- Reconhecer interfaces clássicas da stdlib: `Comparable`, `Runnable`, `Iterable`

---

## 🧠 O que é abstração?
Abstração é **esconder detalhes** e mostrar só o essencial.

Pensa no mundo Naruto: você diz "esse cara é um **Ninja**". Pronto, todo mundo já sabe que ele tem chakra, treina, luta. Você **não precisa explicar** se ele faz Kage Bunshin (clones), Sharingan (olho) ou Rasengan (esfera de chakra) — esses são detalhes da implementação. O "conceito Ninja" é a abstração; cada clã (Uzumaki, Uchiha, Hyuuga) é uma implementação específica.

No código, abstração é fazer o mesmo: oferecer um "contrato" de uso e esconder a implementação interna.

Java oferece duas ferramentas pra isso:
1. **Classe abstrata** (`abstract class`)
2. **Interface** (`interface`)

---

## 🏛️ Classes abstratas (`abstract class`)

> *"O que caralhos é isso?"* — uma classe que **não pode ser instanciada** e serve **só como superclasse**.

Uma classe abstrata é um **molde** parcial. Ela pode ter atributos, construtor, métodos concretos (com corpo) E métodos abstratos (sem corpo, que filhas são obrigadas a implementar).

```java
public abstract class Ninja {
    protected String nome;
    protected String vila;

    public Ninja(String nome, String vila) {
        this.nome = nome;
        this.vila = vila;
    }

    // Método CONCRETO (tem corpo): toda filha herda igualzinho.
    public void apresentar() {
        System.out.println("Eu sou " + nome + " da vila " + vila + ".");
    }

    // Método ABSTRATO (sem corpo): cada filha É OBRIGADA a implementar.
    public abstract void habilidade();
}
```

E uma classe filha:

```java
public class Uzumaki extends Ninja {
    public Uzumaki(String nome) {
        super(nome, "Konoha");
    }

    @Override
    public void habilidade() {            // obrigatório implementar
        System.out.println(nome + " usa Rasengan!");
    }
}
```

Tente fazer `new Ninja("X", "Y")` → o compilador **recusa**: *"Ninja is abstract; cannot be instantiated"*. Só dá pra instanciar pelas filhas concretas.

### Regras das classes abstratas
- Declaradas com `abstract class`.
- Podem ter **construtor**, **atributos**, **métodos concretos** e **métodos abstratos**.
- Métodos abstratos: `abstract void metodo();` (sem corpo, terminam em `;`).
- Filhas **DEVEM** implementar todos os abstratos (ou também serem declaradas `abstract`).
- Você **não pode** fazer `new Ninja(...)` — só `new Uzumaki(...)`.
- Classe filha herda **somente UMA** classe abstrata (Java tem herança simples de classes).
- Uma classe abstrata **pode existir sem nenhum método abstrato** — basta ela ser declarada `abstract`. É útil quando você quer impedir a instanciação direta.

---

## 🔌 Interfaces (`interface`, `implements`)

> *"Uma explicação simples"*: interface é um **contrato**. Quem assinar, **tem que implementar todos os métodos**.

```java
public interface Atacavel {
    void atacar(String alvo);
}
```

E quem assina:

```java
public class Uchiha implements Atacavel {
    private String nome;

    public Uchiha(String nome) { this.nome = nome; }

    @Override
    public void atacar(String alvo) {
        System.out.println(nome + " ataca " + alvo + " com Amaterasu!");
    }
}
```

### Sintaxe
- Declara com `interface`.
- Classe usa `implements` (não `extends`).
- Uma classe pode `implements` **VÁRIAS** interfaces (vírgula): `class X implements A, B, C { ... }`
- Uma interface pode `extends` **várias outras interfaces** (interfaces se herdam livremente entre si).

### O que pode ter dentro de uma interface
| Recurso | Desde | O quê |
|---|---|---|
| Método abstrato | sempre | `void atacar(String alvo);` — sem corpo, quem implementa preenche |
| Constante | sempre | `int CHAKRA_MAX = 100;` — implicitamente `public static final` |
| `default` method | Java 8 | Método com corpo padrão. Classes podem usar ou sobrescrever |
| `static` method | Java 8 | Função utilitária ligada à interface, chamada por `Nome.metodo()` |
| `private` method | Java 9 | Helper interno, usado por `default`/`static` da própria interface |

---

## 🆕 Default, static e private methods em interfaces (Java 8+)

Antes do Java 8, interface era **só contrato**: zero implementação. Daí veio um problema: se uma interface da biblioteca padrão adicionasse um método novo, TODAS as classes que implementavam quebrariam.

A solução foi `default`: um método com corpo **padrão** dentro da interface. Quem implementa ganha de graça e pode sobrescrever se quiser.

```java
public interface Atacavel {
    void atacar(String alvo);                          // abstrato (contrato)

    // default — todo Atacavel ganha esse método "de brinde"
    default void atacarMultiplos(String... alvos) {
        for (String alvo : alvos) {
            atacar(alvo);                               // reusa o atacar() de quem implementa
        }
    }

    // static — utilitário ligado à interface
    static Atacavel pacifista() {
        return alvo -> System.out.println("Eu não luto.");
    }

    // private (Java 9+) — só visível dentro da própria interface,
    // serve pra fatorar código entre defaults.
    private void log(String alvo) {
        System.out.println("[log] alvo: " + alvo);
    }
}
```

**Conflito de defaults**: se duas interfaces têm um `default` com a MESMA assinatura, a classe que implementar as duas **DEVE** sobrescrever pra resolver a ambiguidade.

---

## 🆚 Abstract class vs Interface — tabela comparativa

| Característica | `abstract class` | `interface` |
|---|---|---|
| Pode ter **atributos de instância** (estado) | ✅ sim | ❌ não (só `public static final`) |
| Pode ter **construtor** | ✅ sim (chamado por `super(...)`) | ❌ não |
| Pode ter **métodos concretos** | ✅ sempre | ⚠️ só via `default`/`static` (Java 8+) |
| Pode ter **métodos abstratos** | ✅ sim | ✅ sim (são o padrão) |
| Modificadores nos métodos | qualquer (`public`, `protected`, `private`...) | `public` (implícito); `private` só desde Java 9 |
| Herança | classe filha **herda UMA** (`extends`) | classe **implementa N** (`implements A, B, C`) |
| Conceito que modela | **"é um"** — base comum de família | **"é capaz de"** — habilidade plugável |
| Quando o contrato muda | filhas podem quebrar | `default` evita quebrar |
| Pode ser instanciada com `new`? | ❌ não | ❌ não |

### Regra de bolso
- **Classe abstrata** quando há **base comum com estado** e relação "é um". Ex: `Uzumaki` **é um** `Ninja`.
- **Interface** quando o foco é **habilidade plugável**, sem família. Ex: `Pato`, `Aviao` e `Drone` — todos `Voador`, mas sem relação de família.
- Na dúvida e sem estado compartilhado → **interface**. É mais flexível.

---

## 🧬 Implementação múltipla — a "herança múltipla" de Java

Java **proíbe** herdar de duas classes (`class A extends B, C` não compila), porque herança múltipla de classes traz o famoso *diamond problem*: se B e C têm o mesmo método, qual A herda?

Mas Java **permite** implementar várias interfaces ao mesmo tempo:

```java
interface Voador   { void voar(); }
interface Nadador  { void nadar(); }
interface Atacavel { void atacar(String alvo); }

// Itachi é Ninja (extends), e tb é Voador + Atacavel (implements vários)
class Itachi extends Ninja implements Voador, Atacavel {
    public Itachi() { super("Itachi", "Konoha"); }

    @Override public void habilidade() { System.out.println("Tsukuyomi!"); }
    @Override public void voar()       { System.out.println("Itachi voa com técnica do corvo."); }
    @Override public void atacar(String alvo) { System.out.println("Amaterasu em " + alvo); }
}
```

Repare: o Itachi **herda 1 classe** (`Ninja`) e **implementa N interfaces** (`Voador`, `Atacavel`). Se amanhã ele aprender a nadar, basta acrescentar `, Nadador` e implementar o método.

Isso é o que substitui a herança múltipla em Java — e na prática é até melhor, porque cada interface descreve **uma capacidade isolada** ("voa", "ataca", "salva em disco"), o que é mais reutilizável que árvores genealógicas profundas.

---

## 🎭 Polimorfismo + Abstração juntos

Os dois conceitos formam o coração do design OO:

- **Abstração**: esconde o "como" — você só sabe o **contrato**.
- **Polimorfismo**: usa esse contrato pra **trocar implementações** sem mexer no código que usa.

```java
Ninja[] esquadrao = {
    new Uzumaki("Naruto"),
    new Uchiha("Sasuke"),
    new Hyuuga("Hinata")
};

for (Ninja n : esquadrao) {
    n.apresentar();    // concreto (igual pra todos)
    n.habilidade();    // abstrato — comportamento diferente por filha
}
```

O `for` **não sabe** qual clã é cada um. Ele trabalha com a **abstração** `Ninja` e o **polimorfismo** decide em runtime qual `habilidade()` chamar. Resultado: se amanhã aparecer `Aburame`, basta colocar no array — o loop **não muda uma linha**.

**Princípio**: dependa de abstrações (classes abstratas e interfaces), não de implementações concretas.

---

## 📚 Interfaces clássicas da stdlib

### `Comparable<T>` — ordenação natural
```java
public class Ninja implements Comparable<Ninja> {
    int nivel;
    @Override
    public int compareTo(Ninja outro) {
        return Integer.compare(this.nivel, outro.nivel);
    }
}
```
Permite `Collections.sort(lista)` funcionar sozinho.

### `Runnable` — código que pode rodar em uma thread
```java
Runnable tarefa = () -> System.out.println("Kage Bunshin no Jutsu!");
new Thread(tarefa).start();
```

### `Iterable<T>` — coisas que podem ser percorridas com `for-each`
Qualquer classe que implementa `Iterable` pode ser usada com `for (X x : coisa) { ... }`. Listas, Sets e arrays já vêm prontos.

---

## 💡 Pegadinhas

- **Classe abstrata sem método abstrato existe.** É só uma classe que não dá pra instanciar direto.
- **Interface sem `default`/`static` não tem método "implementado"** — todo método é abstrato implicitamente (`public abstract`).
- **`default` resolve evolução:** você adiciona um método numa interface antiga sem quebrar quem já implementava.
- **Conflito de defaults**: se duas interfaces têm um `default` com a mesma assinatura, a classe **DEVE** sobrescrever pra escolher.
- **Constantes em interface** são sempre `public static final`, mesmo que você não escreva.
- **Você pode ter `Ninja n = new Uzumaki(...)`** — variável tipada na abstração, valor concreto na implementação. Isso É polimorfismo.

---

## 🚦 Próximos passos
1. Veja `pratica/Main.java` (Ninja, Uzumaki, Uchiha + interfaces Voador/Nadador/Atacavel).
2. Encare o **desafio**: Notificações Multi-canal com abstração reforçada.
3. Quando estiver confortável, vá pro Módulo 10 (Exceções).

## ✅ Auto-verificação
- [ ] Sei a diferença entre `abstract class` e `interface` (tabela comparativa)
- [ ] Sei o que é método abstrato e por que filhas devem implementar
- [ ] Sei usar `default`, `static` e `private` em interfaces
- [ ] Sei fazer uma classe `extends` 1 classe e `implements` várias interfaces
- [ ] Entendi como **abstração + polimorfismo** permite trocar implementações sem mexer no código que usa
- [ ] Conheço `Comparable`, `Runnable`, `Iterable` da stdlib

Próximo módulo: **Exceções** — lidar com erros sem deixar o programa cair.
