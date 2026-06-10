# Módulo 07 — Interfaces

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é uma **interface** em Go (um contrato de comportamento)
- Declarar uma interface com `type X interface { ... }`
- Entender por que em Go as interfaces são **implementadas implicitamente**
- Usar **polimorfismo**: a mesma função aceita tipos diferentes
- Trabalhar com `any` (a interface vazia)
- Fazer **type assertion** (`x.(T)`) com o famoso "ok pattern"
- Usar **type switch** para tratar vários tipos de uma vez
- Implementar a interface `Stringer` (a forma idiomática de "como esse tipo vira string")
- Entender por que em Go as **interfaces pequenas** são melhores

## 🤔 O que é uma interface?

Uma interface em Go é um **contrato**. Ela diz:

> "Qualquer tipo que tiver estes métodos pode ser usado onde eu apareço."

Repare: a interface **não** descreve dados (não tem campos), ela descreve **comportamento** (métodos).

Pense num controle remoto universal:
- Ele não sabe se a TV é Samsung, LG ou Philco.
- Ele só sabe que ela tem botões `Ligar()`, `Desligar()`, `MudarCanal()`.
- Qualquer TV que tiver esses botões funciona com ele.

A interface é o controle. As TVs são as **implementações**.

## 🧱 Declarando uma interface

```go
type Animal interface {
    Som() string
    Nome() string
}
```

Lê-se: "qualquer coisa chamada `Animal` precisa ter um método `Som()` que devolve string e um método `Nome()` que devolve string".

E como um tipo "vira" um Animal? Implementando os métodos:

```go
type Cachorro struct {
    nome string
}

func (c Cachorro) Som() string  { return "Au au!" }
func (c Cachorro) Nome() string { return c.nome }

// Pronto. Cachorro é um Animal. Sem dizer "implements".
```

## 🪄 Implementação implícita (a mágica do Go)

Em Java, C# e várias outras linguagens, você precisa escrever algo tipo `class Cachorro implements Animal`. Em **Go, não**.

Se o tipo tem os métodos certos, ele **automaticamente** satisfaz a interface. O compilador descobre sozinho.

Por que isso importa?
- Você pode escrever interfaces para tipos que **já existem** (até de pacotes alheios).
- O acoplamento fica fraquinho: o tipo não precisa "saber" da interface.
- Promove o estilo "duck typing" — *"se anda como pato e grasna como pato, é um pato"* — mas com checagem em tempo de compilação.

## 🦆 Polimorfismo: o pulo do gato

Com a interface declarada, podemos escrever **uma função que aceita qualquer Animal**:

```go
func apresentar(a Animal) {
    fmt.Printf("%s faz %s\n", a.Nome(), a.Som())
}

apresentar(Cachorro{nome: "Rex"})   // Rex faz Au au!
apresentar(Gato{nome: "Mia"})       // Mia faz Miau!
```

A função `apresentar` **não sabe** se recebeu um Cachorro ou um Gato. Ela só sabe que tem os métodos do contrato. Isso é polimorfismo.

E você pode juntar em um slice:

```go
animais := []Animal{
    Cachorro{nome: "Rex"},
    Gato{nome: "Mia"},
}
for _, a := range animais {
    apresentar(a)
}
```

## 🌀 A interface vazia: `any`

Uma interface sem métodos nenhum é satisfeita por **todo** tipo (afinal, "não exige nada"). Antigamente se escrevia `interface{}`. A partir do Go 1.18 existe o apelido `any`:

```go
var x any
x = 42
x = "texto"
x = []int{1, 2, 3}
```

É a "variável que aceita qualquer coisa". Útil em situações genéricas, mas perde-se a segurança de tipo. Use com moderação.

## 🎯 Type assertion: tirar o tipo de dentro

Quando você tem um `any` (ou uma interface) e quer "voltar" para o tipo concreto:

```go
var x any = "olá"

s := x.(string)         // funciona, x é mesmo string
fmt.Println(s)

n := x.(int)            // PÂNICO em tempo de execução!
```

Para não estourar o programa, use o **"ok pattern"**:

```go
s, ok := x.(string)
if ok {
    fmt.Println("É string:", s)
} else {
    fmt.Println("Não era string")
}
```

Se a conversão falhar, `ok` é `false` e `s` é o valor zero — sem pânico.

## 🔀 Type switch: tratar vários tipos

Quando você precisa fazer coisas diferentes para tipos diferentes, o `switch v := x.(type)` é o caminho:

```go
func descrever(x any) {
    switch v := x.(type) {
    case int:
        fmt.Println("É um int:", v*2)
    case string:
        fmt.Println("É string com tamanho", len(v))
    case bool:
        fmt.Println("É booleano:", v)
    default:
        fmt.Println("Não sei o que é isso")
    }
}
```

Dentro de cada `case`, a variável `v` **já tem o tipo certo**. Sem `cast`, sem nada.

## ✍️ Stringer: a interface mais usada do Go

O pacote `fmt` define:

```go
type Stringer interface {
    String() string
}
```

Se o seu tipo implementar `String() string`, o `fmt.Println` e cia. vão **automaticamente** chamar esse método em vez de imprimir os campos crus.

```go
type Pessoa struct {
    Nome  string
    Idade int
}

func (p Pessoa) String() string {
    return fmt.Sprintf("%s (%d anos)", p.Nome, p.Idade)
}

fmt.Println(Pessoa{"David", 30}) // imprime: David (30 anos)
```

Isso é elegantíssimo. Você não precisa criar `imprimir(p)` — o `fmt` já sabe.

## 🐜 Interfaces pequenas: a filosofia Go

Existe um ditado na comunidade Go:

> **"The bigger the interface, the weaker the abstraction."**
> *(Quanto maior a interface, mais fraca a abstração.)* — Rob Pike

Por isso, interfaces idiomáticas em Go têm **1 ou 2 métodos**. Olhe os exemplos da biblioteca padrão:

- `io.Reader` → só tem `Read(p []byte) (n int, err error)`
- `io.Writer` → só tem `Write(p []byte) (n int, err error)`
- `fmt.Stringer` → só tem `String() string`
- `error` → só tem `Error() string`

Quanto menor, mais tipos a satisfazem, mais reuso. Resista à tentação de criar uma interface "Animal" com 20 métodos.

## 💡 Detalhes que valem ouro
- **Interfaces vazias aceitam tudo**: `any` é açúcar para `interface{}`.
- **`nil` em interface é traiçoeiro**: uma interface só é `nil` se o tipo **E** o valor forem `nil`. Cuidado com isso em retornos de erro.
- **Ponteiro vs valor**: se você define o método com receiver `*Tipo`, só o ponteiro implementa a interface, não o valor. Detalhe que pega muito iniciante.
- **`error` é uma interface!**: `error` é só `interface { Error() string }`. Você pode criar seus próprios erros customizados implementando isso.
- **Embedding de interfaces**: você pode compor interfaces. `io.ReadWriter` é literalmente `interface { Reader; Writer }`.

## 👀 Exemplo completo: error customizado

Como `error` é uma interface, dá pra criar erros próprios:

```go
type ErroValidacao struct {
    Campo string
    Motivo string
}

func (e ErroValidacao) Error() string {
    return fmt.Sprintf("campo %s inválido: %s", e.Campo, e.Motivo)
}

func validarIdade(i int) error {
    if i < 0 {
        return ErroValidacao{Campo: "idade", Motivo: "negativa"}
    }
    return nil
}
```

Agora `validarIdade(-3)` devolve um `error` que, quando impresso, mostra a mensagem bonita. E quem chama pode até fazer `type assertion` pra pegar o `Campo` se quiser.

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia os exercícios resolvidos. Entenda **por que** cada tipo satisfaz a interface.
2. Rode: `go run ./curso/modulo-07-interfaces/pratica`
3. Brinque: tente adicionar um novo tipo (ex.: `Vaca`) e veja como ele "vira Animal" automaticamente.
4. Encare o **desafio**: o **Sistema de Notificações Multi-canal**.

## ✅ Auto-verificação
- [ ] Entendi que interface em Go é um **contrato** (só de métodos)
- [ ] Sei que a implementação é **implícita** (não escrevo `implements`)
- [ ] Consigo escrever uma função que recebe a interface e roda com vários tipos
- [ ] Sei usar type assertion com o "ok pattern" para não dar pânico
- [ ] Sei usar `switch v := x.(type)` para tratar tipos diferentes
- [ ] Entendi por que interfaces pequenas são melhores
- [ ] Sei implementar `String() string` para um tipo (Stringer)

Próximo módulo: **Erros e tratamento idiomático** — onde a interface `error` vai brilhar de verdade.
