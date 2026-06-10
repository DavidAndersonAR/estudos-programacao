# Expressões em Go — Resumo simples

Em Go, uma **expressão** é qualquer pedaço de código que **produz um valor**. Pode ser algo simples como o número `42`, uma variável como `idade`, uma conta como `2 + 3`, ou uma chamada de função como `somar(1, 2)`. Sempre que você escreve algo que "vira" um valor, está escrevendo uma expressão.

## 1. Operandos
Operandos são as "peças" mais básicas de uma expressão — os valores em si. Podem ser literais (valores escritos direto no código, como `10` ou `"oi"`), nomes de variáveis, constantes, funções, ou uma expressão entre parênteses.

```go
// Literais (valores escritos direto)
42                  // número inteiro
3.14                // número decimal
"olá"               // texto
true                // booleano

// Identificadores (nomes de variáveis, constantes etc)
idade               // variável
math.Pi             // constante de outro pacote

// Expressão entre parênteses (agrupa pedaços)
(2 + 3) * 4         // os parênteses mudam a ordem da conta
```

---

## 2. Identificadores qualificados
Quando você quer usar algo (função, variável, tipo) que está em **outro pacote**, escreve `pacote.Coisa`. O nome do que você está acessando precisa começar com letra maiúscula (exportado), senão não é visível de fora.

```go
import "fmt"
import "math"

fmt.Println("oi")    // Println está no pacote fmt
raiz := math.Sqrt(16)  // Sqrt está no pacote math
valor := math.Pi       // Pi é uma constante exportada
```

---

## 3. Literais compostos
São uma forma de **criar valores "prontos"** de tipos compostos (struct, array, slice, map) já preenchidos, tudo em uma linha. Em vez de criar e ir atribuindo campo por campo, você monta tudo de uma vez.

```go
// Struct: criar já com os campos preenchidos
type Ponto struct {
    X, Y int
}
p := Ponto{X: 10, Y: 20}

// Array: tamanho fixo, valores entre chaves
notas := [3]float64{8.5, 9.0, 7.5}

// Slice: como array, mas sem o tamanho
frutas := []string{"maçã", "banana", "uva"}

// Map: chave e valor entre chaves
idades := map[string]int{
    "Ana":    25,
    "Carlos": 30,
}

// Struct dentro de struct (composição)
type Linha struct {
    Inicio, Fim Ponto
}
l := Linha{
    Inicio: Ponto{X: 0, Y: 0},
    Fim:    Ponto{X: 10, Y: 10},
}
```

---

## 4. Literais de função
Você pode criar uma função **sem nome**, ali mesmo no meio do código, e guardá-la em uma variável ou passar adiante. É bem útil para callbacks (funções que serão chamadas depois).

```go
// Função anônima guardada em variável
dobrar := func(n int) int {
    return n * 2
}
fmt.Println(dobrar(5))   // 10

// Função anônima chamada na hora
resultado := func(a, b int) int {
    return a + b
}(3, 4)                  // resultado = 7

// Passando como argumento
numeros := []int{1, 2, 3}
for _, n := range numeros {
    func(x int) {
        fmt.Println(x * x)
    }(n)
}
```

---

## 5. Seletores
O seletor é o ponto (`.`) usado para **acessar algo dentro de outra coisa** — um campo de struct, um método, ou até algo de um pacote. Se o que você está acessando estiver dentro de um ponteiro, o Go já "desfaz" o ponteiro automaticamente para você.

```go
type Pessoa struct {
    Nome  string
    Idade int
}

p := Pessoa{Nome: "Ana", Idade: 25}

// Acessar campo
nome := p.Nome

// Em ponteiros, o Go entende sozinho (não precisa fazer (*ptr).Nome)
ptr := &p
nome2 := ptr.Nome        // funciona igual a (*ptr).Nome

// Selecionar de pacote
fmt.Println("oi")        // Println é "selecionado" de fmt
```

---

## 6. Expressões de índice
Usadas para **pegar um item específico** de um array, slice, string ou map, usando colchetes `[]`. Para os três primeiros, o índice é um número (começando de 0). Para map, é a chave.

```go
// Array e slice
nums := []int{10, 20, 30, 40}
primeiro := nums[0]      // 10
ultimo := nums[3]        // 40

// String (retorna um byte)
texto := "Go"
letra := texto[0]        // 71 (código do 'G')

// Map (busca pela chave)
idades := map[string]int{"Ana": 25, "Bia": 30}
ana := idades["Ana"]     // 25

// Map: forma com dois retornos (verifica se existe)
valor, ok := idades["Carlos"]
if !ok {
    fmt.Println("não tem")
}
```

---

## 7. Expressões de fatiamento (slice)
Servem para **pegar um pedaço** de um array, slice ou string, usando `[inicio:fim]`. O início é incluído, o fim **não**. Se omitir o início, começa do zero; se omitir o fim, vai até o final.

```go
nums := []int{10, 20, 30, 40, 50}

a := nums[1:4]    // [20, 30, 40] - do índice 1 ao 3
b := nums[:3]     // [10, 20, 30] - do começo até o índice 2
c := nums[2:]     // [30, 40, 50] - do índice 2 até o final
d := nums[:]      // [10, 20, 30, 40, 50] - cópia "fatiada" do todo

// Forma com três valores: [inicio:fim:capacidade]
// Define até onde o slice pode crescer
e := nums[1:3:4]  // tamanho 2, capacidade 3

// Funciona com strings também
texto := "Olá, mundo"
ola := texto[0:3]  // "Olá" (cuidado com caracteres multi-byte)
```

---

## 8. Type assertion (afirmação de tipo)
Quando você tem uma variável do tipo interface e quer descobrir/usar o **tipo real** dela por baixo, usa a assertion. É como dizer ao Go: "confia, esse valor aí dentro é um `string`". Tem uma forma segura com dois retornos que evita o programa quebrar.

```go
var qualquer any = "olá"

// Forma 1: direta (se der errado, o programa quebra com panic)
s := qualquer.(string)
fmt.Println(s)           // olá

// Forma 2: com dois retornos (seguro - retorna ok = false se falhar)
n, ok := qualquer.(int)
if ok {
    fmt.Println("é int:", n)
} else {
    fmt.Println("não é int")
}

// Muito usado em switch para tratar vários tipos
switch v := qualquer.(type) {
case string:
    fmt.Println("texto:", v)
case int:
    fmt.Println("número:", v)
default:
    fmt.Println("outro tipo")
}
```

---

## 9. Chamadas de função
Para **executar uma função**, você escreve o nome dela seguido de parênteses com os argumentos. Se a função retorna valor(es), a chamada vira uma expressão que produz aquele(s) valor(es).

```go
func somar(a, b int) int {
    return a + b
}

// Chamada simples
total := somar(2, 3)     // 5

// Função com vários retornos
func dividir(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("não dá pra dividir por zero")
    }
    return a / b, nil
}

resultado, err := dividir(10, 2)
if err != nil {
    fmt.Println("erro:", err)
}

// Chamada de método (com seletor antes)
type Caixa struct{ Volume int }
func (c Caixa) Dobrar() int { return c.Volume * 2 }

c := Caixa{Volume: 5}
v := c.Dobrar()          // 10
```

---

## 10. Passando argumentos para `...` (variádicos)
Quando uma função aceita **número variável de argumentos** (com `...` no parâmetro), você pode chamar passando vários valores soltos, ou passar um slice já pronto usando `...` na chamada.

```go
func somarTudo(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}

// Passar valores soltos
somarTudo(1, 2, 3)              // 6
somarTudo(10, 20, 30, 40)       // 100

// Passar um slice já pronto (com ... no final)
lista := []int{5, 10, 15}
somarTudo(lista...)             // 30

// Sem argumentos também funciona
somarTudo()                     // 0
```

---

## 11. Operadores aritméticos
Fazem **contas** com números. Os mais comuns: soma, subtração, multiplicação, divisão e resto.

```go
a, b := 10, 3

soma := a + b            // 13
sub := a - b             // 7
mult := a * b            // 30
div := a / b             // 3  (divisão inteira, descarta o resto)
resto := a % b           // 1  (o que sobra da divisão)

// Com decimais a divisão é "normal"
x, y := 10.0, 3.0
divDecimal := x / y      // 3.3333...

// Operadores bit a bit (mexem nos bits do número)
c := 12 & 10             // E bit a bit
d := 12 | 10             // OU bit a bit
e := 12 ^ 10             // OU exclusivo (XOR)
f := 1 << 3              // deslocar bits à esquerda = 8
g := 16 >> 2             // deslocar à direita = 4
```

---

## 12. Operadores de comparação
Comparam dois valores e devolvem um **booleano** (`true` ou `false`). Servem para usar em `if`, `for` etc.

```go
a, b := 10, 20

igual := a == b          // false (igual?)
diferente := a != b      // true  (diferente?)
menor := a < b           // true
maior := a > b           // false
menorIgual := a <= 10    // true
maiorIgual := a >= 11    // false

// Funciona com strings também
nome1, nome2 := "Ana", "Bia"
fmt.Println(nome1 == nome2)   // false
fmt.Println(nome1 < nome2)    // true (ordem alfabética)
```

---

## 13. Operadores lógicos
Combinam **valores booleanos**. O `&&` (E) só é verdadeiro se **os dois lados** forem; o `||` (OU) se **pelo menos um** for; o `!` inverte. Go usa "curto-circuito": se já dá pra saber o resultado pelo primeiro lado, nem avalia o segundo.

```go
idade := 25
temCNH := true

// E: precisa dos dois
podeDirigir := idade >= 18 && temCNH       // true

// OU: basta um
desconto := idade < 12 || idade > 60        // false

// Não: inverte
naoTem := !temCNH                          // false

// Combinando
if idade >= 18 && (temCNH || idade > 21) {
    fmt.Println("ok")
}
```

---

## 14. Precedência de operadores
É a **ordem em que as contas são feitas** quando você mistura vários operadores. Da maior para menor: `*` `/` `%` vêm antes de `+` `-`; depois as comparações; depois `&&`; e por último `||`. Quando estiver na dúvida, **use parênteses** — fica mais claro e evita erro.

```go
// Multiplicação antes da soma
x := 2 + 3 * 4           // 14, não 20

// Parênteses mudam a ordem
y := (2 + 3) * 4         // 20

// Comparação antes de &&
z := 5 > 3 && 2 < 10     // true

// Quando misturar muito, use parênteses
ok := (a > 0 && b > 0) || (c == 10)
```

---

## 15. Operadores de endereço
Servem para trabalhar com **ponteiros** (lembre: ponteiro guarda o endereço de uma variável na memória). O `&` pega o endereço; o `*` faz o "contrário" — pega o valor que está naquele endereço.

```go
x := 42

// & = "endereço de"
ptr := &x                // ptr aponta para x

// * = "valor no endereço"
valor := *ptr            // 42

// Mudar pelo ponteiro afeta o original
*ptr = 100
fmt.Println(x)           // 100
```

---

## 16. Operador de recebimento (`<-`)
Usado com **canais** (channels) para enviar ou receber mensagens. A flechinha aponta para onde a mensagem vai.

```go
canal := make(chan int)

// Enviar (a flecha aponta pro canal)
go func() {
    canal <- 42
}()

// Receber (a flecha aponta pra variável)
n := <-canal             // 42

// Forma com dois retornos (sabe se o canal foi fechado)
valor, aberto := <-canal
if !aberto {
    fmt.Println("canal fechado")
}
```

---

## 17. Conversões de tipo
Em Go, você **não pode** misturar tipos diferentes de qualquer jeito — precisa converter explicitamente. A sintaxe parece com chamada de função: `Tipo(valor)`.

```go
// Entre números
var a int = 10
var b float64 = float64(a)      // de int para float
var c int = int(b)              // de float para int (descarta a vírgula)

// Número para string (não converte o número em texto, e sim em char Unicode!)
s := string(65)                 // "A" (porque 65 é o código de A)

// Para virar texto "65", use o pacote strconv
import "strconv"
texto := strconv.Itoa(65)       // "65"

// String <-> slice de bytes/runes
bytes := []byte("oi")           // [111 105]
str := string(bytes)            // "oi"
runes := []rune("éàü")          // slice de runes (cada char Unicode)
```

---

## 18. Expressões constantes
Quando uma expressão usa só **constantes**, o Go calcula o valor na hora da compilação, não na hora de rodar. Constantes não têm endereço de memória e podem ser "não tipadas" — o tipo é decidido só quando você usa.

```go
const Pi = 3.14159              // não tipada (vira o tipo certo no uso)
const Max int = 100             // tipada explicitamente

// Operações entre constantes são feitas na compilação
const Area = Pi * 10 * 10       // calculado já

// iota: contador automático em blocos const
const (
    Domingo = iota    // 0
    Segunda           // 1
    Terca             // 2
    Quarta            // 3
)
```

---

## 19. Ordem de avaliação
Quando você tem várias coisas acontecendo em uma linha, o Go avalia da **esquerda para a direita**, na ordem em que aparecem. Em uma atribuição, o lado direito é calculado antes do esquerdo. Isso ajuda a saber em que ordem chamadas de função são executadas.

```go
func f() int { fmt.Println("f"); return 1 }
func g() int { fmt.Println("g"); return 2 }

// f() é chamado antes de g()
x := f() + g()

// Em atribuição múltipla, o lado direito é avaliado primeiro
a, b := 1, 2
a, b = b, a              // troca: a=2, b=1

// Argumentos são avaliados da esquerda pra direita
fmt.Println(f(), g())    // imprime f, depois g, depois "1 2"
```

---

Em resumo: uma **expressão** em Go é qualquer coisa que produz um valor. Elas vão desde literais simples (`42`, `"oi"`) e variáveis, até montagens mais ricas com **operadores** (aritméticos, comparação, lógicos), **seletores** (`.`), **índices** (`[]`), **fatiamentos** (`[a:b]`), **chamadas de função**, **conversões** e **type assertions**. Entender expressões é entender como os valores fluem e se combinam no seu programa.
