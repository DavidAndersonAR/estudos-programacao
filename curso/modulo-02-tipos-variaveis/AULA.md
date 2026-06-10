# Módulo 02 — Tipos e Variáveis

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Identificar os tipos básicos do Go: `int`, `float64`, `string`, `bool`
- Declarar variáveis usando `var` (forma longa) e `:=` (forma curta)
- Declarar várias variáveis de uma vez só
- Entender o que é o **valor zero** e por que ele existe
- Converter valores entre tipos numéricos sem dor de cabeça

## 🧠 Por que isso importa?
Programar é, em grande parte, **guardar dados** e **mexer com eles**. Uma calculadora precisa guardar números; um cadastro precisa guardar nomes; uma porta automática precisa saber se está aberta (verdadeiro/falso). Tudo isso vira **variáveis** com **tipos**.

Go é uma linguagem **tipada estaticamente**, o que significa que cada variável tem um tipo fixo definido desde o nascimento. Isso assusta no começo, mas vira amigo: o compilador pega seus erros antes do programa rodar.

## 🧱 Os 4 tipos básicos que você vai usar 90% do tempo

### `int` — números inteiros
Para coisas que não têm vírgula: idade, quantidade, posição em uma lista.

```go
var idade int = 30
quantidade := 7      // Go entende sozinho que é int
```

### `float64` — números com vírgula (decimais)
Para preços, alturas, temperaturas, taxas... qualquer coisa que tenha "ponto" no número.

```go
var altura float64 = 1.75
preco := 19.90       // Go entende que é float64
```

> Em Go, o padrão para decimal é `float64` (64 bits de precisão). Existe `float32`, mas use-o só quando precisar de fato.

### `string` — texto
Sequência de caracteres entre aspas duplas `"..."`.

```go
var nome string = "Maria"
saudacao := "Olá, tudo bem?"
```

> Aspas simples `'a'` em Go **não** são string — são um caractere (`rune`). Sempre use aspas duplas para texto.

### `bool` — verdadeiro ou falso
Só dois valores possíveis: `true` ou `false`. Útil para "está logado?", "passou na prova?", "é maior de idade?".

```go
var ativo bool = true
maiorDeIdade := false
```

## ✍️ Declarando variáveis

### Forma longa: `var`
Útil quando você quer ser explícito sobre o tipo, ou declarar variável sem valor inicial.

```go
var idade int          // sem valor: começa em 0 (valor zero)
var nome string = "Ana"
var preco = 19.90      // tipo pode ser omitido se há valor
```

### Forma curta: `:=`
A mais usada **dentro de funções**. Go deduz o tipo pelo valor.

```go
idade := 30          // int
preco := 9.99        // float64
nome  := "João"      // string
ativo := true        // bool
```

> `:=` só funciona **dentro de funções**. Fora delas, use `var`.

### Declaração múltipla
Você pode criar várias variáveis em uma linha só:

```go
// Mesma linha, com :=
nome, idade := "Pedro", 25

// Várias do mesmo tipo com var
var x, y, z int           // todas começam em 0

// Em bloco (organiza bem quando são muitas)
var (
    largura  float64 = 10.5
    altura   float64 = 3.2
    titulo   string  = "Sala"
    ocupada  bool    = false
)
```

## 🧊 Valor zero — Go nunca deixa variável "vazia"
Se você declara uma variável e **não dá um valor inicial**, Go coloca automaticamente o **valor zero** do tipo dela. Isso evita o problema clássico do "lixo de memória" que existe em outras linguagens.

| Tipo      | Valor zero |
|-----------|------------|
| `int`     | `0`        |
| `float64` | `0`        |
| `string`  | `""` (vazia) |
| `bool`    | `false`    |

```go
var contador int      // vale 0
var preco float64     // vale 0
var nome string       // vale ""
var ligado bool       // vale false

fmt.Println(contador, preco, nome, ligado)
// imprime: 0 0  false
```

Isso é ótimo porque você sempre sabe com o que está começando.

## 🔄 Conversão entre tipos numéricos
Em Go, **não existe conversão automática** entre tipos numéricos. Se você tem um `int` e quer somar com um `float64`, **você** precisa converter um deles. O compilador não faz isso por você.

```go
var inteiro int = 10
var decimal float64 = 3.14

// soma := inteiro + decimal     // ERRO! tipos diferentes

// Solução: converter um deles
soma := float64(inteiro) + decimal   // ok, agora os dois são float64
fmt.Println(soma)                     // 13.14
```

A sintaxe é `tipo(valor)`. Funciona para todos os tipos numéricos:

```go
var a int     = 7
var b float64 = float64(a)     // converte int para float64
var c int     = int(b)         // converte float64 para int (corta a parte decimal!)

fmt.Println(a, b, c)           // 7 7 7
```

> **Cuidado**: converter `float64` para `int` **corta a parte decimal** (não arredonda). `int(3.99)` vira `3`, não `4`.

### Por que Go é assim?
Para evitar bugs silenciosos. Em outras linguagens, somar `int + float` pode dar resultado errado sem você perceber. Em Go, o compilador para você e força a pensar.

## 💡 Detalhes que valem ouro
- **Variável declarada não usada = erro**. Se você criou e nunca usou, Go reclama na hora de compilar. Mantém o código limpo.
- **Constantes existem também**: use `const` quando o valor nunca vai mudar (`const pi = 3.14`). Veremos com mais calma depois.
- **`fmt.Printf` te ajuda a inspecionar**: `%d` para int, `%f` para float, `%s` para string, `%t` para bool, `%v` para qualquer um, `%T` mostra o **tipo** da variável.
- **Nomes**: em Go, usa-se `camelCase` para variáveis (`precoTotal`, não `preco_total`).

```go
preco := 19.90
fmt.Printf("Valor: %.2f — Tipo: %T\n", preco, preco)
// Valor: 19.90 — Tipo: float64
```

## 👀 Variações para você fixar

```go
package main

import "fmt"

func main() {
    // Forma longa
    var nome string = "Ana"
    var idade int = 28

    // Forma curta
    cidade := "Curitiba"
    altura := 1.62

    // Múltipla
    a, b, c := 1, 2, 3

    // Valor zero
    var contador int
    var ligado bool

    fmt.Println(nome, idade, cidade, altura)
    fmt.Println(a, b, c)
    fmt.Println("contador:", contador, "ligado:", ligado)

    // Conversão
    var ano int = 2026
    anoFloat := float64(ano)
    fmt.Printf("Ano como float: %.2f\n", anoFloat)
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e rode os exercícios resolvidos.
2. Rode: `go run ./curso/modulo-02-tipos-variaveis/pratica`
3. Mexa nos valores das variáveis e veja o que muda.
4. Encare o **desafio**: a **Calculadora de IMC**.

## ✅ Auto-verificação
- [ ] Sei dizer qual a diferença entre `int` e `float64`
- [ ] Sei usar `var` e `:=` e entendo quando usar cada um
- [ ] Sei o valor zero de `int`, `float64`, `string` e `bool`
- [ ] Sei converter um `int` para `float64` e vice-versa
- [ ] Entendi por que Go não converte tipos numéricos automaticamente

Próximo módulo: **Operadores e Expressões** — onde você vai fazer as variáveis trabalharem juntas.
