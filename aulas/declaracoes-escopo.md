# Declarações e Escopo em Go — Resumo simples

Em Go, **declarar** é dar um nome para alguma coisa (uma variável, uma constante, um tipo, uma função etc) para poder usar esse nome depois. Já o **escopo** é o "pedaço do código" onde aquele nome funciona — fora dali, ele não existe. Pense num escopo como o "alcance" do nome.

## 1. O que é uma declaração

Uma declaração liga um nome (chamado de **identificador**) a alguma coisa: um valor, um tipo, uma função, etc. Toda coisa usada no programa precisa ter sido declarada antes, e dentro do mesmo bloco você não pode declarar dois nomes iguais.

```go
// Declarando uma variável (nome ligado a um valor)
var idade int = 30

// Declarando uma constante (nome ligado a um valor fixo)
const PI = 3.14

// Declarando um tipo novo (nome ligado a uma estrutura)
type Pessoa struct {
    Nome string
}

// Declarando uma função (nome ligado a um comportamento)
func saudar() {
    fmt.Println("Olá!")
}
```

---

## 2. Escopo (onde o nome funciona)

O escopo é a região do código onde aquele nome tem sentido. Go usa **escopo léxico em blocos**, ou seja: cada par de chaves `{ }` cria um novo "compartimento". Um nome declarado dentro de um bloco só vive ali. Se você declarar outro nome igual dentro de um bloco mais interno, ele **esconde** (sobrepõe) o de fora enquanto durar.

Os principais "níveis" de escopo, do mais amplo para o mais restrito:

- **Universo**: nomes embutidos do Go (como `int`, `true`, `nil`) — funcionam em qualquer lugar.
- **Pacote**: nomes declarados fora de qualquer função — funcionam em todo o pacote.
- **Arquivo**: nomes de pacotes importados — só funcionam no arquivo onde foi feito o `import`.
- **Função**: parâmetros e variáveis locais — só funcionam dentro daquela função.
- **Bloco**: qualquer `{ }` mais interno (dentro de `if`, `for`, etc).

```go
package main

import "fmt"

var nome = "global"   // escopo de pacote (visível em todo o arquivo)

func exemplo() {
    nome := "local"   // escopo de função — esconde a "nome" de fora
    fmt.Println(nome) // imprime "local"

    if true {
        nome := "ainda mais dentro" // escopo de bloco — esconde de novo
        fmt.Println(nome)           // imprime "ainda mais dentro"
    }

    fmt.Println(nome) // imprime "local" de novo
}
```

---

## 3. Escopo de rótulo (label)

Um **rótulo** (label) é um nome usado com `break`, `continue` ou `goto` para identificar um lugar específico do código. Eles têm um escopo próprio: valem dentro da função onde foram declarados (mas não dentro de funções aninhadas) e não conflitam com nomes de variáveis. Todo rótulo declarado precisa ser usado, senão dá erro de compilação.

```go
func procurar(matriz [][]int, alvo int) {
externo: // este é um rótulo
    for i := 0; i < len(matriz); i++ {
        for j := 0; j < len(matriz[i]); j++ {
            if matriz[i][j] == alvo {
                fmt.Println("achei!")
                break externo // sai do laço de fora também
            }
        }
    }
}
```

---

## 4. Identificadores pré-declarados (nomes embutidos)

São os nomes que **já vêm prontos** no Go, sem precisar declarar nem importar nada. Eles vivem no escopo do "universo", o mais amplo possível.

- **Tipos**: `bool`, `byte`, `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`...`uint64`, `uintptr`, `float32`, `float64`, `complex64`, `complex128`, `string`, `rune`, `error`, `any`, `comparable`.
- **Constantes**: `true`, `false`, `iota`.
- **Valor zero genérico**: `nil` (representa "nada" para ponteiros, slices, maps, etc).
- **Funções embutidas**: `append`, `cap`, `close`, `complex`, `copy`, `delete`, `imag`, `len`, `make`, `max`, `min`, `new`, `panic`, `print`, `println`, `real`, `recover`, `clear`.

```go
var ativo bool = true        // bool, true: já existem
tamanho := len("texto")      // len: função embutida
lista := make([]int, 3)      // make: função embutida
var p *int = nil             // nil: já existe
```

Você até pode declarar uma variável chamada `int` ou `len`, mas é uma péssima ideia — você "esconde" o original e perde a função embutida.

---

## 5. Identificadores exportados (maiúscula = público)

Em Go não tem `public` nem `private`. A regra é simples: se o nome começa com **letra maiúscula**, ele é **exportado** (visível em outros pacotes). Se começa com **minúscula**, ele é **privado** do pacote.

```go
package contas

// Exportado — outros pacotes podem usar
type Cliente struct {
    Nome  string // exportado (Maiúscula)
    saldo float64 // privado (minúscula)
}

// Exportada — pode ser chamada de outro pacote
func NovoCliente(nome string) Cliente {
    return Cliente{Nome: nome}
}

// privada — só funciona dentro deste pacote
func calcularJuros(valor float64) float64 {
    return valor * 0.01
}
```

Repare: o campo `Nome` é acessível de fora, mas `saldo` não. A função `calcularJuros` só pode ser chamada dentro do pacote `contas`.

---

## 6. Unicidade de identificadores

Dentro do mesmo bloco, dois nomes não podem ser iguais. Dois nomes são considerados **diferentes** se forem escritos de forma diferente ou se estiverem em pacotes diferentes (e não forem ambos exportados). Em pacotes diferentes, dá para ter nomes iguais sem problema.

```go
func exemplo() {
    var x int = 1
    var x int = 2  // ERRO: x já existe neste bloco

    // Mas isso funciona (são blocos diferentes):
    if true {
        var x int = 2  // OK: bloco novo, escopo novo
        fmt.Println(x)
    }
}
```

---

## 7. O identificador em branco `_`

O `_` é um **descartador**. Serve para dizer "tem um valor aqui mas eu não me importo com ele". Não cria nome nenhum, não guarda nada — é só um lugar pra jogar fora o que não interessa.

```go
// Map: só quero saber se a chave existe, não o valor
_, existe := precos["café"]

// Função retorna 3 coisas, só quero a do meio
_, y, _ := coordenadas(p)

// Quero rodar o for sem precisar do índice
for _, valor := range lista {
    fmt.Println(valor)
}

// Importar pacote só pelos efeitos colaterais (rodar o init dele)
import _ "image/png"
```

---

## 8. Declaração de constantes

Constantes são valores que **nunca mudam**. Usa-se a palavra `const`. Se você não falar o tipo, Go deixa a constante "sem tipo definido" e ela se adapta ao contexto.

```go
// Forma simples
const Pi = 3.14159
const Nome = "Go"

// Com tipo explícito
const Tamanho int = 1024

// Várias de uma vez, dentro de parênteses
const (
    Domingo  = 0
    Segunda  = 1
    Terca    = 2
)

// Usando iota (gera 0, 1, 2, 3... automaticamente)
const (
    Vermelho = iota // 0
    Verde           // 1
    Azul            // 2
)

// iota com deslocamento de bits — útil para flags
const (
    Leitura  = 1 << iota // 1
    Escrita              // 2
    Execucao             // 4
)
```

---

## 9. Declaração de tipos

Cria um nome novo para um tipo. Existem dois jeitos: **definição** (cria um tipo realmente novo, diferente do original) e **apelido** (alias — só dá outro nome para o mesmo tipo).

```go
// Definição: Idade é um tipo NOVO, diferente de int
type Idade int

// Apelido (alias): MeuInt é OUTRO NOME para int (são iguais)
type MeuInt = int

// Definição com struct
type Pessoa struct {
    Nome  string
    Idade Idade
}

// Tipo definido pode ter métodos próprios
func (i Idade) EhAdulto() bool {
    return i >= 18
}

// Tipo genérico (com parâmetro de tipo)
type Lista[T any] struct {
    valores []T
}
```

A diferença prática: com `type Idade int` você não pode misturar `Idade` e `int` sem conversão. Com o alias `type MeuInt = int`, são a mesma coisa.

---

## 10. Declaração de variáveis

Cria um nome ligado a um valor (que pode mudar depois). Tem várias formas.

```go
// Forma 1: declarar com tipo, sem valor (recebe o "valor zero")
var idade int          // idade vale 0

// Forma 2: declarar com tipo e valor
var nome string = "Ana"

// Forma 3: deixar o Go descobrir o tipo
var ativo = true

// Forma 4: forma curta (só dentro de função)
quantidade := 10

// Várias de uma vez
var x, y, z int = 1, 2, 3
a, b := "olá", 42

// Em bloco (parênteses)
var (
    titulo  string = "Go"
    versao  int    = 1
    pronto  bool
)
```

A forma curta `:=` só funciona **dentro de funções**. Para variáveis no nível do pacote, é obrigatório usar `var`.

### Redeclaração com `:=`

Você pode reusar o `:=` desde que **pelo menos uma** das variáveis à esquerda seja nova:

```go
campo1, posicao := proximoCampo(texto, 0)
campo2, posicao := proximoCampo(texto, posicao) // OK: campo2 é novo
```

---

## 11. Declaração de funções

Cria uma função: dá um nome, lista os parâmetros (entradas) e os tipos de retorno (saídas).

```go
// Função simples
func somar(a int, b int) int {
    return a + b
}

// Parâmetros do mesmo tipo podem ser agrupados
func multiplicar(a, b int) int {
    return a * b
}

// Função com múltiplos retornos
func dividir(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("divisão por zero")
    }
    return a / b, nil
}

// Função genérica (com parâmetro de tipo)
func menor[T int | float64](x, y T) T {
    if x < y {
        return x
    }
    return y
}
```

---

## 12. Declaração de métodos

Método é uma função **associada a um tipo**. A diferença é que ele tem um **receptor** (receiver) — aquele parâmetro extra entre `func` e o nome do método, que diz "este método é desse tipo aqui".

```go
type Retangulo struct {
    Largura, Altura float64
}

// Método com receptor por VALOR (recebe uma cópia)
func (r Retangulo) Area() float64 {
    return r.Largura * r.Altura
}

// Método com receptor por PONTEIRO (pode alterar o original)
func (r *Retangulo) Dobrar() {
    r.Largura *= 2
    r.Altura *= 2
}

// Usando
ret := Retangulo{Largura: 3, Altura: 4}
fmt.Println(ret.Area())  // 12
ret.Dobrar()
fmt.Println(ret.Area())  // 48
```

Regras importantes do receptor:
- Só pode ser de um tipo **definido no mesmo pacote** do método.
- Não pode ser ponteiro nem interface diretamente.
- Use ponteiro (`*Tipo`) quando o método precisa **modificar** o valor; use valor (`Tipo`) quando só precisa **ler**.

---

Em resumo: em Go, **declarar** é dar nome às coisas, e **escopo** é o "raio de alcance" desse nome. Quanto mais interno o bloco, menor o escopo. Identificadores começando com maiúscula são públicos, com minúscula são privados. O `_` serve para descartar valores, e os nomes pré-declarados (como `int`, `len`, `nil`) já vêm prontos para usar em qualquer lugar.
