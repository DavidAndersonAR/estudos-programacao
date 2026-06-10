# Módulo 08 — Herança + Polimorfismo + Overload + Override + Final

> Corresponde às aulas do Java10x: *Herança - O primeiro pilar da OO* (19:39), *Polimorfismo - O segundo pilar da OO* (10:04), *Super classes x Sub Classes* (11:47), *Overload/Sobrecarga de métodos* (11:30), *@Override real funcionamento* (7:12), *Final Methods* (11:58), *Final class* (6:57).

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar uma **subclasse** com `extends` e reaproveitar código da **superclasse**
- Chamar construtor e método da pai com `super(...)` e `super.metodo()`
- Sobrescrever métodos com `@Override` (e entender por que essa anotação é uma **trava de segurança do compilador**)
- Diferenciar **overload** (sobrecarga) de **override** (sobrescrita)
- Usar **polimorfismo** — uma referência da superclasse apontando pra qualquer subclasse
- Fazer **upcasting** e **downcasting** com `instanceof` (pattern matching do Java 16+)
- Saber quando marcar um **método `final`** (não pode ser sobrescrito) e uma **classe `final`** (não pode ser estendida)
- Entender por que `String` é `final`

---

## 🧬 1. Herança com `extends` — o **primeiro pilar** da OO

Herança é a maneira de dizer "essa classe **é um tipo de** outra classe". Você pega uma classe base (pai, ou *superclasse*) e cria uma classe nova (filha, ou *subclasse*) que **herda** todos os campos e métodos da pai, podendo ainda **adicionar** comportamento novo ou **sobrescrever** o existente.

A palavra-chave em Java é `extends`:

```java
public class Ninja {
    String nome;
    int chakra;

    void realizarJutsu() {
        System.out.println(nome + " executa um jutsu básico.");
    }
}

public class Uzumaki extends Ninja {
    // Uzumaki JÁ TEM nome, chakra e realizarJutsu() — tudo herdado.
    void rasengan() {
        System.out.println(nome + " concentra chakra e lança o Rasengan!");
    }
}
```

Agora:
```java
Uzumaki naruto = new Uzumaki();
naruto.nome = "Naruto";          // veio de Ninja (herdado)
naruto.chakra = 9000;            // veio de Ninja
naruto.realizarJutsu();          // herdado → "Naruto executa um jutsu básico."
naruto.rasengan();               // próprio do Uzumaki
```

> **Regra de ouro:** use herança quando faz sentido dizer **"X é um Y"**. Uzumaki **é um** Ninja ✅. Ninja **é uma** Kunai ❌ (Ninja **tem** uma kunai — isso seria composição).

### Superclasse x Subclasse — vocabulário oficial

| Termo | Outros nomes | Quem é no nosso exemplo |
|---|---|---|
| Superclasse | classe pai, classe base, "super" | `Ninja` |
| Subclasse | classe filha, classe derivada, "sub" | `Uzumaki`, `Uchiha` |

A relação é **unidirecional**: a sub conhece tudo da super, mas a super **não conhece** os métodos novos que a sub adicionou.

### Por que herança é considerada um pilar?
Reutilização de código. Em vez de copiar `nome`, `chakra` e `realizarJutsu()` em toda classe de ninja que você criar, você herda uma vez e adiciona só o que é específico de cada clã.

---

## 🔁 2. Sobrescrita com `@Override` — o funcionamento real

Quando a subclasse quer **mudar o comportamento** de um método herdado, ela declara o mesmo método com **a mesma assinatura** (mesmo nome, mesmos parâmetros, mesmo tipo de retorno) e marca com `@Override`:

```java
public class Uzumaki extends Ninja {
    @Override
    void realizarJutsu() {
        System.out.println(nome + " grita: Kage Bunshin no Jutsu! (clones das sombras)");
    }
}

public class Uchiha extends Ninja {
    @Override
    void realizarJutsu() {
        System.out.println(nome + " ativa o Sharingan e lança Katon: Goukakyuu!");
    }
}
```

### `@Override` é opcional. Mas você SEMPRE deve usar. Por quê?

Porque ela é uma **trava de segurança do compilador**. Imagine este cenário:

```java
public class Ninja {
    void realizarJutsu() { ... }
}

public class Uzumaki extends Ninja {
    // Sem @Override, você digita errado e o compilador NÃO reclama:
    void realizarJutso() {    // ← typo! "jutso" no lugar de "jutsu"
        System.out.println("Rasengan!");
    }
}
```

Aqui você **achou** que estava sobrescrevendo `realizarJutsu()`, mas na verdade criou um método **novo** chamado `realizarJutso()`. Quando alguém chamar `realizarJutsu()` num Uzumaki, vai cair na versão genérica da pai. Bug silencioso.

Agora com `@Override`:

```java
@Override
void realizarJutso() { ... }    // 💥 ERRO DE COMPILAÇÃO: não existe esse método na pai.
```

O compilador trava o build. Você descobre o erro na hora.

### O cenário matador: renomeação na pai

Imagine que o time renomeia `realizarJutsu()` pra `executarJutsu()` na classe `Ninja`. Sem `@Override`, todas as subclasses continuam com `realizarJutsu()` — só que agora esses métodos não sobrescrevem mais nada, viraram métodos novos órfãos. Você só descobre rodando. **Com** `@Override`, o compilador acusa erro em todas as subclasses no segundo seguinte: *"método marcado como override não existe na superclasse"*. Bug pego em segundos.

---

## 🔢 3. Overload (sobrecarga) — mesmo nome, assinaturas diferentes

**Overload ≠ Override.** É a confusão clássica do iniciante.

**Sobrecarga (overload)** = mesmo nome de método, mas **assinaturas diferentes** (número, tipo ou ordem de parâmetros). Acontece **na mesma classe** (ou herdada). Resolvida em tempo de **compilação**, baseada nos parâmetros.

```java
public class Ninja {
    String nome;

    // Três versões do método "atacar" — mesmo nome, parâmetros diferentes.
    void atacar() {
        System.out.println(nome + " ataca com kunai.");
    }

    void atacar(String alvo) {
        System.out.println(nome + " ataca " + alvo + " com kunai.");
    }

    void atacar(String alvo, int forca) {
        System.out.println(nome + " ataca " + alvo + " com força " + forca + ".");
    }

    void atacar(int distancia) {
        System.out.println(nome + " lança shuriken a " + distancia + " metros.");
    }
}
```

Uso:
```java
Ninja n = new Ninja();
n.nome = "Sasuke";
n.atacar();                       // chama a 1ª versão
n.atacar("Naruto");               // chama a 2ª
n.atacar("Naruto", 99);           // chama a 3ª
n.atacar(50);                     // chama a 4ª — int, então é "lançar shuriken"
```

### Override x Overload — tabela definitiva

| | **Override (sobrescrita)** | **Overload (sobrecarga)** |
|---|---|---|
| O que muda | nada — assinatura idêntica | parâmetros (número, tipo ou ordem) |
| Onde acontece | subclasse vs superclasse | mesma classe (ou herdada) |
| Resolvido em | tempo de **execução** (dynamic dispatch) | tempo de **compilação** |
| Anotação | `@Override` | (nenhuma) |
| Tipo de retorno | tem que ser igual (ou covariante) | pode ser diferente |
| Relação com herança | precisa de herança | independe de herança |

---

## ⬆️ 4. `super` — chamando a pai

`super` é a referência à classe pai. Tem dois usos principais:

### 4.1 Chamar o construtor da pai
Precisa ser a **primeira linha** do construtor da filha:

```java
public class Ninja {
    String nome;
    int chakra;

    Ninja(String nome, int chakra) {
        this.nome = nome;
        this.chakra = chakra;
    }
}

public class Uchiha extends Ninja {
    boolean sharinganAtivo;

    Uchiha(String nome, int chakra, boolean sharinganAtivo) {
        super(nome, chakra);          // chama Ninja(String, int) — PRIMEIRA linha
        this.sharinganAtivo = sharinganAtivo;
    }
}
```

Se você não escrever `super(...)`, o compilador injeta `super()` (sem argumentos) automaticamente. Se a pai não tiver construtor sem argumentos, **erro de compilação**.

### 4.2 Chamar o método da pai (mesmo tendo sobrescrito)
Útil quando você quer **estender** o comportamento da pai em vez de substituir:

```java
@Override
void realizarJutsu() {
    super.realizarJutsu();                                 // executa o básico da pai
    System.out.println(nome + " complementa com Katon!");  // e adiciona algo novo
}
```

---

## 🎭 5. Polimorfismo — o **segundo pilar** da OO

**Polimorfismo** = "muitas formas". A ideia é simples e poderosa: **uma referência da superclasse pode apontar pra qualquer objeto de subclasse**, e a JVM resolve em tempo de execução qual versão do método chamar.

```java
Ninja n;                       // referência do tipo Ninja
n = new Uzumaki();             // mas aponta pra um Uzumaki
n.realizarJutsu();             // imprime "Kage Bunshin no Jutsu!" — versão do Uzumaki
```

A JVM olha o **objeto real** (Uzumaki), não o tipo da referência (Ninja). Isso se chama **dynamic dispatch** (despacho dinâmico).

### Métodos intercambiáveis: a parte mágica

Você pode tratar várias subclasses de forma uniforme:

```java
Ninja[] esquadrao = {
    new Uzumaki("Naruto", 9000),
    new Uchiha("Sasuke", 7000, true),
    new Uzumaki("Boruto", 5000)
};

for (Ninja n : esquadrao) {
    n.realizarJutsu();      // cada um executa o jutsu dele
}
```

Adicionou um `Hyuuga extends Ninja`? Adiciona ele no array e o loop continua funcionando sem alterar uma linha. **É essa a flexibilidade que polimorfismo te dá: código que aceita a superclasse aceita automaticamente qualquer subclasse futura.**

### Upcasting (subir na hierarquia) — IMPLÍCITO e SEGURO
```java
Uzumaki naruto = new Uzumaki("Naruto", 9000);
Ninja n = naruto;       // Uzumaki → Ninja: automático, sem cast
```
Faz sentido: todo Uzumaki **é um** Ninja.

### Downcasting (descer) — EXPLÍCITO e ARRISCADO
```java
Ninja n = new Uzumaki("Naruto", 9000);
Uzumaki u = (Uzumaki) n;       // funciona — o objeto real É um Uzumaki
```
Mas:
```java
Ninja n = new Uchiha("Sasuke", 7000, true);
Uzumaki u = (Uzumaki) n;       // 💥 ClassCastException em tempo de execução
```

**Regra:** antes de downcastar, **verifique com `instanceof`**.

---

## 🔍 6. `instanceof` e o pattern matching (Java 16+)

`instanceof` testa se um objeto é (ou herda de) um determinado tipo.

### Forma clássica
```java
Ninja n = new Uzumaki("Naruto", 9000);

if (n instanceof Uzumaki) {
    Uzumaki u = (Uzumaki) n;       // downcasting seguro
    u.rasengan();
}
```

### Forma moderna (Java 16+) — *pattern matching for instanceof*
Em uma linha só, sem cast manual:

```java
if (n instanceof Uzumaki u) {      // já declara "u" do tipo Uzumaki, já castado
    u.rasengan();
}
```

Mais limpo, menos repetitivo, mesmo resultado. **Use esta sempre que possível**.

### Encadeando
```java
for (Ninja n : esquadrao) {
    if (n instanceof Uzumaki u) {
        u.rasengan();
    } else if (n instanceof Uchiha uc) {
        uc.sharingan();
    } else {
        n.realizarJutsu();         // fallback genérico
    }
}
```

---

## 🚫 7. `final` em método e em classe

`final` significa "isso aqui está **fechado pra mudanças**". Existem três usos comuns em Java; aqui vamos focar em dois: método e classe (o terceiro é variável imutável, que você já viu).

### 7.1 Método `final` — não pode ser sobrescrito

```java
public class Ninja {
    public final String getNome() {
        return nome;
    }

    public void realizarJutsu() {
        System.out.println("Jutsu básico");
    }
}

public class Uzumaki extends Ninja {
    @Override
    public String getNome() {    // 💥 ERRO: getNome() é final na pai
        return "Hokage " + super.getNome();
    }
}
```

**Por que travar?** Porque alguns métodos definem comportamento **crítico** que não pode ser alterado por subclasses — exemplo clássico: identificadores, hash de senha, regras de segurança. Se você permitisse override, uma subclasse maliciosa (ou mal escrita) poderia quebrar invariantes do sistema.

### 7.2 Classe `final` — não pode ser estendida

```java
public final class Hokage extends Ninja {
    // Hokage é o cargo máximo. Ninguém estende Hokage.
}

public class HokageReserva extends Hokage {    // 💥 ERRO: Hokage é final
    ...
}
```

**Exemplo real famoso:** `String` em Java é `final`. Tenta:

```java
public class MinhaString extends String { ... }   // 💥 erro de compilação
```

Por que `String` é `final`? Porque ela é **imutável** e essa imutabilidade é assumida por todo o ecossistema Java (HashMap, cache de strings, segurança). Se você pudesse estender String e mudar comportamento, quebraria meio mundo. `Integer`, `LocalDate`, `LocalDateTime` — todos `final` pelo mesmo motivo.

### Quando marcar como `final`?
- **Classes de valor imutáveis** (tipo `String`, `LocalDate`) — `final` para garantir que ninguém quebre a imutabilidade.
- **Classes utilitárias** com só métodos estáticos — não faz sentido estender.
- **Métodos críticos** que definem contratos invioláveis (autenticação, identidade).
- Se em dúvida, **deixe sem `final`** — herança é uma ferramenta valiosa pra quem usa sua API. `final` é uma decisão deliberada de fechar a porta.

---

## 👑 Object — a raiz de todas as classes

**Toda classe em Java herda implicitamente de `java.lang.Object`** — mesmo que você não escreva `extends Object`.

Isso significa que **todo objeto** tem alguns métodos por padrão:

| Método | O que faz |
|---|---|
| `toString()` | Representação em texto do objeto |
| `equals(Object o)` | Compara se dois objetos são "iguais" |
| `hashCode()` | Inteiro usado por `HashMap`, `HashSet`, etc |
| `getClass()` | Retorna a classe do objeto em tempo de execução |

E é por isso que você pode fazer:

```java
Object x = new Uzumaki("Naruto", 9000);   // qualquer coisa cabe em Object
Object y = 42;                            // até primitivos (autoboxing pra Integer)
Object z = "Vila da Folha";
```

---

## ⚠️ Pegadinhas que valem ouro

- **`extends` só aceita UMA classe**. Java não tem herança múltipla de classes (mas tem de **interfaces** — próximo módulo).
- **Construtor não é herdado**. A filha precisa declarar os seus, e a primeira linha será `super(...)` (explícito ou implícito).
- **Campos `private` NÃO são acessíveis na filha**. Use `protected` se quiser acesso direto da subclasse.
- **`@Override` em método que não existe na pai** = erro de compilação. Esse é exatamente o ponto — pegar erros de digitação e renomeações.
- **Não confunda override com overload.** Override = mesmo nome **e mesma assinatura**, na filha. Overload = mesmo nome, **assinatura diferente**, mesma classe.
- **Método `static` não é sobrescrito**, é **escondido** (hiding). Não tem dynamic dispatch em método estático.
- **Construtor não pode ser `final`** (não faz sentido — construtor não é herdado).

---

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** — 8 exercícios com Naruto, Sasuke e cia.
2. Encare o **desafio**: hierarquia de ninjas de Konoha (folha de pagamento da vila).
3. Próximo módulo: **Classes Abstratas e Interfaces** — quando herdar não é o suficiente.

## ✅ Auto-verificação
- [ ] Sei criar uma subclasse com `extends` e dizer quem é super x sub
- [ ] Uso `@Override` em toda sobrescrita e sei explicar **por quê**
- [ ] Sei a diferença entre **overload** (mesma classe, parâmetros diferentes) e **override** (subclasse, mesma assinatura)
- [ ] Sei a diferença entre `super(...)` (construtor) e `super.metodo()` (chamada de método)
- [ ] Entendo por que `Ninja n = new Uzumaki()` é válido e útil — dynamic dispatch
- [ ] Uso `instanceof` com pattern matching antes de fazer downcasting
- [ ] Sei o que `final` faz num método (não sobrescreve) e numa classe (não estende)
- [ ] Sei por que `String` é `final`

Próximo módulo: **Classes Abstratas e Interfaces** — contratos sem implementação.
