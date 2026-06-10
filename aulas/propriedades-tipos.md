# Propriedades de Tipos e Valores em Go — Resumo simples

Em Go, cada tipo tem algumas características importantes que decidem como os valores se comportam: qual é o "tipo de base" por trás dele, quando dois tipos são considerados iguais, quando dá pra colocar um valor em outra variável e quais ações (métodos) aquele tipo sabe fazer. Aqui vai um resumo bem direto desses pontos.

## 1. Tipo subjacente (underlying type)

Todo tipo em Go tem um **tipo subjacente** — ou seja, o "tipo de base" que está por trás dele. É como se cada tipo tivesse um "esqueleto" original que define sua estrutura real. Os tipos básicos (`int`, `string`, `bool`...) são o tipo subjacente deles mesmos. Quando você cria um tipo novo a partir de outro, o tipo subjacente é o do "pai".

```go
// Tipos básicos: o tipo subjacente é ele mesmo
// string -> string
// int    -> int

// Criando tipos novos a partir de outros
type Nome string        // tipo subjacente: string
type Apelido Nome       // tipo subjacente: string (continua sendo string)
type Idade int          // tipo subjacente: int

// Quando o tipo é um "literal" (definição direta), ele é seu próprio subjacente
type Lista []int        // tipo subjacente: []int
type OutraLista Lista   // tipo subjacente: []int

// Apelido de tipo (alias) com "=" — é a MESMA coisa que o original
type Texto = string     // Texto e string são literalmente iguais
```

Por que isso importa? Porque várias regras de Go (como atribuição e conversão) olham pro tipo subjacente, não pro nome que você deu.

---

## 2. Identidade de tipos (quando dois tipos são iguais)

Dois tipos podem ser **idênticos** (iguais para o Go) ou **diferentes**. A regra principal é: um **tipo com nome próprio** (criado com `type`) é sempre diferente de qualquer outro tipo, mesmo que por baixo dos panos eles sejam parecidos. Já tipos sem nome (escritos diretamente, tipo `[]int`) são iguais se tiverem a mesma estrutura.

```go
type Reais []string     // tipo com nome
type Falsos []string    // outro tipo com nome

var a Reais
var b Falsos
// a e b NÃO são do mesmo tipo, mesmo sendo "lista de string"
// Reais e Falsos são diferentes porque cada um tem nome próprio

// Tipos sem nome com mesma estrutura são iguais
var x []string
var y []string
// x e y são do mesmo tipo: []string

// Apelido (com "=") cria o MESMO tipo, não um novo
type Texto = string
var t Texto = "oi"
var s string = t        // funciona, são literalmente o mesmo tipo

// Struct: iguais se tiverem os mesmos campos, na mesma ordem, com os mesmos tipos
type P1 struct{ Nome string; Idade int }
type P2 struct{ Nome string; Idade int }
// P1 e P2 são tipos DIFERENTES (cada um tem nome próprio)
// Mas struct{ Nome string; Idade int } sem nome é igual a outro struct igual sem nome
```

---

## 3. Atribuição (quando posso colocar um valor de tipo A numa variável de tipo B)

Atribuir é colocar um valor numa variável. Em Go, isso só funciona em algumas situações claras:

- Quando os dois tipos são **idênticos** (iguais).
- Quando têm o **mesmo tipo subjacente** e pelo menos um dos dois não tem nome próprio.
- Quando o destino é uma **interface** e o valor cumpre essa interface.
- Quando o valor é `nil` e o destino aceita `nil` (ponteiro, slice, map, canal, função, interface).
- Quando o valor é uma **constante sem tipo** que cabe no tipo de destino (por exemplo, o número `5` cabe em `int`, `float64` etc).

```go
// 1. Mesmo tipo: sempre funciona
var a int = 10
var b int = a           // ok

// 2. Mesmo tipo subjacente, e um deles é sem nome
type Idade int
var i Idade = 20
var n int = i           // NÃO funciona direto: dois tipos com nome diferentes
// var n int = int(i)   // aqui sim, com conversão explícita

var lista1 []int
var lista2 []int = lista1   // ok, []int não tem "nome próprio"

// 3. Destino é interface e o valor cumpre o contrato
type Falante interface {
    Falar() string
}
type Cao struct{}
func (c Cao) Falar() string { return "Au!" }

var f Falante = Cao{}   // ok: Cao tem o método Falar

// 4. nil em tipos que aceitam nil
var p *int = nil        // ok
var s []int = nil       // ok
var m map[string]int = nil  // ok

// 5. Constante sem tipo cabe no destino
var x float64 = 5       // ok: 5 é constante sem tipo, cabe em float64
var y int = 100         // ok
// var z int = 1.5      // erro: 1.5 não cabe em int
```

Resumindo de forma bem prática: se os tipos têm nomes diferentes (mesmo parecidos), normalmente você precisa **converter** com `tipo(valor)`. Se um lado não tem nome próprio, costuma rolar direto.

---

## 4. Representabilidade (quando um número "cabe" em um tipo)

Uma constante é **representável** por um tipo quando o valor dela cabe nas regras daquele tipo. Por exemplo, `255` cabe em `byte` (que vai de 0 a 255), mas `300` não cabe. Isso vale também para decimais: o número precisa caber sem estourar.

```go
var b byte = 200        // ok: cabe em byte (0 a 255)
// var b byte = 300     // erro: 300 não cabe em byte
// var b byte = -1      // erro: byte não aceita negativo

var i int16 = 1000      // ok: cabe em int16 (-32768 a 32767)

var f float32 = 2.71828         // ok: arredonda pra precisão do float32
// var n int = 1.5              // erro: 1.5 não é inteiro
// var c byte = 'a'             // ok: 'a' = 97, cabe em byte
// var s string = 'a'           // erro: caractere não é string
```

---

## 5. Conjunto de métodos (method set)

O **conjunto de métodos** de um tipo é a lista de métodos que você pode chamar em valores daquele tipo. Isso define se um tipo cumpre uma interface ou não.

Regras importantes:

- Se um método foi declarado com receptor `T` (valor), ele faz parte do conjunto de `T` **e** de `*T` (ponteiro).
- Se um método foi declarado com receptor `*T` (ponteiro), ele só faz parte do conjunto de `*T`. Você não consegue chamá-lo a partir de um `T` "puro" em algumas situações (como passar para uma interface).
- Quando uma struct tem um campo "embutido" (embedded), os métodos do tipo embutido viram métodos da struct também (são "promovidos").

```go
type Carro struct {
    Modelo string
}

// Método com receptor de VALOR (Carro)
func (c Carro) Buzinar() string {
    return "Bi bi!"
}

// Método com receptor de PONTEIRO (*Carro)
func (c *Carro) Pintar(cor string) {
    c.Modelo = c.Modelo + " " + cor
}

// Conjunto de métodos:
// Carro    -> tem Buzinar
// *Carro   -> tem Buzinar E Pintar

var c1 Carro
c1.Buzinar()        // ok
c1.Pintar("azul")   // funciona porque Go pega o endereço automaticamente
                    // MAS em interfaces, Carro não tem Pintar — só *Carro

// Exemplo com interface
type Pintor interface {
    Pintar(cor string)
}

var p Pintor = &c1  // ok: *Carro tem Pintar
// var p Pintor = c1  // erro: Carro não tem Pintar no conjunto de métodos

// Métodos "herdados" por embutimento
type Veiculo struct {
    Carro       // campo embutido (sem nome)
}

var v Veiculo
v.Buzinar()         // ok: método promovido de Carro
```

Em interfaces, o conjunto de métodos é a própria lista que a interface exige. Qualquer tipo que tenha todos esses métodos no seu conjunto automaticamente "cumpre" a interface.

---

Em resumo: o **tipo subjacente** é o esqueleto por trás de cada tipo; a **identidade** decide quando dois tipos são iguais (e nomes diferentes contam!); a **atribuição** segue regras claras baseadas em identidade e em tipos subjacentes; a **representabilidade** checa se um número cabe num tipo; e o **conjunto de métodos** define o que aquele tipo sabe fazer — e, por consequência, quais interfaces ele cumpre.
