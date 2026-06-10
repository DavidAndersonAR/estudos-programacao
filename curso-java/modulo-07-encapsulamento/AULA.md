# Módulo 07 — Encapsulamento + Construtores + ENUMs

> Corresponde às aulas do Java10x: *Construtores - Organizando e padronizando objetos* (16:54), *Overload/Sobrecarga de construtores* (22:48), *Encapsulamento - Uma explicação teórica* (9:12), *Getters e Setters - Uma explicação mais técnica* (15:55), *ENUMS - Uma classe especial, mas nem tanto* (11:01).

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender por que esconder o estado interno de um objeto (encapsulamento)
- Usar os modificadores de acesso: `private`, `public`, `protected`, package-private
- Escrever construtores **No-Args** e **All-Args**
- Sobrecarregar construtores e encadear com `this()`
- Criar getters e setters com (e sem) validação
- Modelar um conjunto fixo de constantes usando **`enum`**

## 🔒 O que é encapsulamento
Imagine uma classe `Ninja` com tudo público:

```java
class Ninja {
    public String nome;
    public int chakra;
}

Ninja naruto = new Ninja();
naruto.chakra = -9_999; // ninguém te impede de quebrar a regra
```

Qualquer pedaço do programa pode violar a regra de negócio (chakra nunca pode ser negativo, por exemplo). **Encapsulamento** é exatamente isso: o objeto é responsável por **proteger seu próprio estado**.

A regra de ouro:
- **Campos** sempre que possível `private`
- **Acesso** controlado por métodos públicos (getters/setters)
- **Validação** mora dentro do setter / construtor, num lugar só

Benefícios:
- Você muda a implementação sem quebrar quem usa a classe
- A invariante (regra que sempre vale) é garantida em um único ponto
- Fica óbvio o que é "API pública" e o que é "implementação interna"

## 🚪 Modificadores de acesso
Java tem 4 níveis, do mais aberto pro mais restrito:

| Modificador | Mesma classe | Mesmo pacote | Subclasse | Qualquer lugar |
|---|---|---|---|---|
| `public` | ✅ | ✅ | ✅ | ✅ |
| `protected` | ✅ | ✅ | ✅ | ❌ |
| *(nenhum)* package-private | ✅ | ✅ | ❌ | ❌ |
| `private` | ✅ | ❌ | ❌ | ❌ |

Regra prática:
- Comece tudo `private`
- Abra só o que precisa abrir
- Use `protected` quando for desenhar pra herança (próximo módulo)
- Package-private (sem palavra) é útil dentro do mesmo módulo lógico

## 🏗️ Construtores — organizando a criação
Construtor é um "método especial" que roda na criação do objeto. Mesmo nome da classe, **sem tipo de retorno**.

### Construtor default (implícito)
Se você **não** escrever nenhum construtor, o Java cria um sem argumentos:

```java
class Ninja { /* nenhum construtor escrito */ }
Ninja n = new Ninja(); // funciona — default invisível
```

⚠️ No momento que você escreve **qualquer** construtor, o default some. Se quiser os dois, declare os dois.

### No-Args constructor (sem argumentos)
Útil quando você ainda não tem os dados:

```java
public Ninja() {
    // pode ter defaults: this.chakra = 100;
}
```

### All-Args constructor (com todos os campos)
Inicializa o objeto já com valores válidos:

```java
public Ninja(String nome, int idade, int chakra) {
    setNome(nome);
    setIdade(idade);   // reaproveita validação
    setChakra(chakra);
}
```

Chamar o setter dentro do construtor é um truque comum pra não duplicar a validação.

## 🔁 Sobrecarga de construtores e `this()`
Você pode ter **vários** construtores na mesma classe — basta que as **assinaturas** (tipos/quantidade de parâmetros) sejam diferentes. Isso é **overload**. Pra não repetir lógica, um construtor chama outro com `this(...)`:

```java
public class Ninja {
    private String nome;
    private int idade;
    private int chakra;

    // Construtor "completo" — All-Args
    public Ninja(String nome, int idade, int chakra) {
        this.nome = nome;
        this.idade = idade;
        this.chakra = chakra;
    }

    // Atalho: só nome — assume idade 12 e chakra 100 (genin recém-formado)
    public Ninja(String nome) {
        this(nome, 12, 100); // delega ao All-Args
    }

    // No-Args: genin anônimo
    public Ninja() {
        this("Desconhecido"); // delega ao de 1 arg, que delega ao All-Args
    }
}
```

Regras importantes:
- `this(...)` precisa ser **a primeira instrução** do construtor
- Você só pode chamar **um** outro construtor por essa via
- A "cadeia" sempre termina no construtor mais completo — validação fica num lugar só

## 🧱 Getters e Setters
Com campo `private`, o acesso é por métodos públicos:

```java
public class Ninja {
    private String nome;
    private int chakra;

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public int getChakra() {
        return chakra;
    }

    public void setChakra(int chakra) {
        this.chakra = chakra;
    }
}
```

`this.nome = nome` distingue o campo (`this.nome`) do parâmetro (`nome`).

> 💡 No IntelliJ, `Alt+Insert` → **Getter and Setter** gera tudo pra você.

### Validação dentro do setter
O setter é o lugar certo pra dizer "esse valor não pode entrar":

```java
public void setIdade(int idade) {
    if (idade < 0) {
        throw new IllegalArgumentException("Idade não pode ser negativa: " + idade);
    }
    this.idade = idade;
}
```

`IllegalArgumentException` é a exceção padrão pra **argumento inválido**. Quem chamar `ninja.setIdade(-5)` vai levar um estouro — exatamente o que queremos: bug aparece cedo, perto da causa. E o estado do objeto **não fica corrompido**: a atribuição só acontece depois da validação.

## 🎴 ENUMs — conjunto fixo de constantes
Quando um campo só pode ter **um valor de uma lista pequena e bem definida**, usar `String` ou `int` é fonte de bug. Pense no nível de um ninja: só pode ser GENIN, CHUNIN, JONIN ou HOKAGE. Em vez disso:

```java
public enum NivelNinja {
    GENIN, CHUNIN, JONIN, HOKAGE
}
```

`enum` é uma classe especial. Cada valor (`GENIN`, `CHUNIN`...) é uma constante única — tipo "instância singleton" daquele tipo.

### Usando o enum
```java
NivelNinja nivel = NivelNinja.CHUNIN;

if (nivel == NivelNinja.HOKAGE) {
    System.out.println("Reverência!");
}
```

Compara com `==` direto — não precisa de `equals`. E o compilador não deixa você usar valor "inventado": `NivelNinja.PRESIDENTE` nem compila.

### Enum com métodos e campos
Enum pode ter construtor, campos e métodos como qualquer classe:

```java
public enum NivelNinja {
    GENIN(100),
    CHUNIN(300),
    JONIN(800),
    HOKAGE(2000);

    private final int xpMinimo;

    NivelNinja(int xpMinimo) {     // construtor é sempre package-private/private
        this.xpMinimo = xpMinimo;
    }

    public int getXpMinimo() {
        return xpMinimo;
    }
}
```

Uso: `NivelNinja.JONIN.getXpMinimo()` devolve `800`.

### Enum em `switch`
Combinação clássica — o compilador avisa se você esquecer um caso:

```java
String missaoTipica(NivelNinja n) {
    switch (n) {
        case GENIN:  return "Capinar quintal da vovó";
        case CHUNIN: return "Escoltar mercador";
        case JONIN:  return "Infiltração em país inimigo";
        case HOKAGE: return "Governar a vila";
        default:     return "?";
    }
}
```

(Em Java 14+ existe `switch expression` mais enxuto — fica pra depois.)

## 🪤 Pegadinhas
- **`private` é por classe, não por instância**: dois objetos da mesma classe enxergam os campos `private` um do outro. Útil em `equals` e em métodos como `transferir(outraConta)`.
- **Getter pode mentir / calcular**: `getNomeCompleto()` pode juntar nome + sobrenome na hora. Quem chama nem percebe.
- **Validação só no setter não basta** se o construtor setar o campo direto. Centralize: ou ambos validam, ou o construtor chama o setter.
- **Não chame setter "validador" dentro do construtor encadeado errado**: lembre que `this(...)` precisa ser a primeira linha.
- **Enum não é `String`**: `nivel.name()` devolve `"GENIN"` (String), `NivelNinja.valueOf("GENIN")` faz o caminho contrário — útil ao ler de banco/arquivo.
- **Construtor escrito apaga o default**: declarar `Ninja(String nome)` faz `new Ninja()` parar de compilar — se quiser, escreva também o No-Args.

## 🚦 Próximos passos
1. Faça **`pratica/Main.java`**: brinque com `Ninja`, setters validando, sobrecarga de construtores e o enum `NivelNinja`.
2. Encare o **desafio**: **Banco em Konoha** (`ContaBancaria`).
3. No próximo módulo: **Herança e Polimorfismo** — reaproveitar comportamento entre classes.

## ✅ Auto-verificação
- [ ] Sei explicar por que campos públicos são ruins
- [ ] Sei a diferença entre `private`, `public`, `protected` e package-private
- [ ] Sei escrever construtor No-Args e All-Args
- [ ] Sei sobrecarregar construtores usando `this()` pra delegar
- [ ] Sei escrever setter que valida e lança `IllegalArgumentException`
- [ ] Sei criar um `enum` com campos, construtor e métodos
- [ ] Sei usar enum em `switch`

Próximo módulo: **Herança e Polimorfismo**.
