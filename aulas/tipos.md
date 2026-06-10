# Tipos em Go — Resumo simples

Em Go, todo valor tem um **tipo**, que define o que aquele valor pode fazer e que operações são permitidas com ele.

## 1. Booleano (`bool`)
Guarda só duas coisas: **verdadeiro** ou **falso**. Útil para condições e checagens.

```go
// Forma 1: declarar e depois atribuir
var ativo bool
ativo = true

// Forma 2: declarar e já atribuir
var logado bool = false

// Forma 3: forma curta (a mais usada)
aprovado := true

// Usando em uma condição
if aprovado {
    fmt.Println("Passou!")
}
```

---

## 2. Números
São divididos em três famílias:

- **Inteiros**: números sem vírgula (1, 2, -5...). Existem versões "com sinal" (aceitam negativos: `int8`, `int16`, `int32`, `int64`) e "sem sinal" (só positivos: `uint8`, `uint16`...). O mais comum é só usar `int`.
- **Decimais**: números com vírgula (`float32`, `float64`).
- **Complexos**: números com parte "imaginária" (`complex64`, `complex128`) — raramente usados.

Detalhes úteis: `byte` é o mesmo que `uint8`, e `rune` representa um caractere Unicode (uma letra, emoji etc).

```go
// Inteiros
var idade int = 30
quantidade := 100         // Go entende sozinho que é int
var pequeno int8 = 127    // ocupa menos memória
var positivo uint = 50    // só aceita números >= 0

// Decimais
var preco float64 = 19.90
desconto := 0.15          // Go entende como float64

// Byte e rune
var letra byte = 'A'      // guarda o código 65
var emoji rune = '😀'     // guarda o código Unicode

// Conversão entre tipos numéricos (precisa ser explícita)
var a int = 10
var b float64 = float64(a)
```

---

## 3. Texto (`string`)
Sequência de caracteres, tipo "Olá, mundo". Uma vez criada, **não pode ser alterada** — se precisar mudar, cria-se outra.

```go
// Criando strings
var nome string = "David"
saudacao := "Olá, mundo!"

// Juntar (concatenar) textos
mensagem := saudacao + " " + nome

// Pegar tamanho
tamanho := len(nome)      // 5

// Acessar um caractere pela posição (retorna um byte)
primeira := nome[0]       // 'D'

// String de várias linhas (com crases)
texto := `Linha 1
Linha 2
Linha 3`
```

---

## 4. Array
Uma "caixa" com tamanho fixo que guarda vários valores do mesmo tipo. Exemplo: `[5]int` é uma caixa com exatamente 5 números inteiros. O tamanho faz parte do tipo e não muda nunca.

```go
// Declarar array vazio (cada posição começa com zero)
var numeros [5]int        // [0, 0, 0, 0, 0]

// Atribuir valores
numeros[0] = 10
numeros[1] = 20

// Criar já com valores
notas := [3]float64{8.5, 9.0, 7.5}

// Deixar o Go contar o tamanho com "..."
dias := [...]string{"Seg", "Ter", "Qua", "Qui", "Sex"}

// Acessar valores e tamanho
primeira := notas[0]      // 8.5
total := len(notas)       // 3
```

---

## 5. Slice
É como um array, mas **flexível** — pode crescer e diminuir. É o jeito mais usado de guardar listas em Go. Por baixo dos panos, ele aponta para um array, mas você não precisa se preocupar com isso no dia a dia.

```go
// Forma 1: criar vazio
var lista []int

// Forma 2: já com valores
frutas := []string{"maçã", "banana", "uva"}

// Forma 3: usando make (define tamanho inicial)
zeros := make([]int, 5)              // [0, 0, 0, 0, 0]
buffer := make([]int, 3, 10)         // tamanho 3, capacidade 10

// Adicionar elementos (append retorna um novo slice)
frutas = append(frutas, "laranja")
lista = append(lista, 1, 2, 3)

// Fatiar (pegar um pedaço)
parte := frutas[1:3]                 // pega do índice 1 ao 2

// Remover um item (juntando dois pedaços)
frutas = append(frutas[:1], frutas[2:]...)
```

---

## 6. Struct
Um "agrupador" de campos com nomes diferentes. Serve para representar uma "coisa" do mundo real. Exemplo: uma `Pessoa` com `nome` e `idade`. É parecido com o que outras linguagens chamam de objeto ou registro.

```go
// Definindo o tipo
type Pessoa struct {
    Nome  string
    Idade int
    Email string
}

// Criando uma pessoa
var p1 Pessoa
p1.Nome = "Ana"
p1.Idade = 25

// Criando já com valores (por nome dos campos - recomendado)
p2 := Pessoa{
    Nome:  "Carlos",
    Idade: 30,
    Email: "carlos@email.com",
}

// Criando pela ordem dos campos
p3 := Pessoa{"Maria", 28, "maria@email.com"}

// Acessando campos
fmt.Println(p2.Nome)

// Struct dentro de struct
type Empresa struct {
    Nome string
    Dono Pessoa
}
```

---

## 7. Ponteiro
Em vez de guardar um valor, guarda o **endereço** onde o valor está na memória. Útil quando você quer que uma função altere um valor original, em vez de mexer só numa cópia.

```go
// Criar uma variável normal
idade := 25

// Criar um ponteiro para essa variável (& = "endereço de")
var ponteiro *int = &idade

// Ler o valor que o ponteiro aponta (* = "valor em")
fmt.Println(*ponteiro)    // 25

// Mudar o valor original usando o ponteiro
*ponteiro = 30
fmt.Println(idade)        // 30

// Criar um ponteiro do zero com "new"
p := new(int)             // aponta para um int com valor 0
*p = 100

// Usando em função para modificar o original
func incrementar(num *int) {
    *num++
}

x := 5
incrementar(&x)
fmt.Println(x)            // 6
```

---

## 8. Função
Em Go, função também é um tipo de valor — dá para guardar uma função numa variável, passar como parâmetro e devolver outra função. Útil para criar comportamentos flexíveis.

```go
// Função simples
func somar(a int, b int) int {
    return a + b
}

// Função com vários retornos
func dividir(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("divisão por zero")
    }
    return a / b, nil
}

// Guardar função em uma variável
operacao := func(x, y int) int {
    return x * y
}
resultado := operacao(3, 4)   // 12

// Função que recebe outra função
func aplicar(valores []int, fn func(int) int) []int {
    resultado := []int{}
    for _, v := range valores {
        resultado = append(resultado, fn(v))
    }
    return resultado
}

dobrar := func(n int) int { return n * 2 }
dobrados := aplicar([]int{1, 2, 3}, dobrar)   // [2, 4, 6]

// Função com número variável de argumentos
func somarTudo(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}
somarTudo(1, 2, 3, 4)   // 10
```

---

## 9. Interface
Define um "contrato": uma lista de coisas que um tipo precisa saber fazer. Qualquer tipo que cumpra essas regras **automaticamente** vira aquela interface (não precisa declarar nada). Por exemplo: se algo tem um método `Read`, ele é um `Reader`. A interface vazia (`any`) aceita qualquer coisa.

```go
// Definindo uma interface
type Animal interface {
    Falar() string
}

// Criando tipos que cumprem o contrato
type Cachorro struct {
    Nome string
}

func (c Cachorro) Falar() string {
    return "Au au!"
}

type Gato struct {
    Nome string
}

func (g Gato) Falar() string {
    return "Miau!"
}

// Usando a interface - aceita qualquer um que tenha o método Falar
func apresentar(a Animal) {
    fmt.Println(a.Falar())
}

apresentar(Cachorro{Nome: "Rex"})    // Au au!
apresentar(Gato{Nome: "Mia"})        // Miau!

// Interface vazia (any) aceita qualquer tipo
var qualquer any
qualquer = 42
qualquer = "texto"
qualquer = true
```

---

## 10. Map
Uma estrutura de "chave e valor", como um dicionário. Você guarda valores associados a uma chave única e busca pela chave depois. Exemplo: `map[string]int` guarda números associados a textos (como uma agenda de idades por nome).

```go
// Forma 1: criar com make
idades := make(map[string]int)
idades["Ana"] = 25
idades["Carlos"] = 30

// Forma 2: criar já com valores
precos := map[string]float64{
    "café":  5.50,
    "pão":   1.20,
    "leite": 4.90,
}

// Ler um valor
preco := precos["café"]   // 5.50

// Verificar se a chave existe
valor, existe := precos["chocolate"]
if existe {
    fmt.Println("Preço:", valor)
} else {
    fmt.Println("Não encontrado")
}

// Remover uma chave
delete(precos, "leite")

// Percorrer todos os itens
for chave, valor := range precos {
    fmt.Println(chave, "=", valor)
}

// Tamanho
total := len(precos)
```

---

## 11. Channel (canal)
Um "cano" usado para passar mensagens entre tarefas que rodam ao mesmo tempo (as goroutines). Garante que a comunicação seja segura, sem bagunça. Pode ser de mão dupla, só enviar ou só receber.

```go
// Criar um canal sem buffer (sincronizado)
canal := make(chan string)

// Criar um canal com buffer (guarda até 3 mensagens)
buffered := make(chan int, 3)

// Enviar e receber em goroutines diferentes
go func() {
    canal <- "olá"            // enviar para o canal
}()

mensagem := <-canal           // receber do canal
fmt.Println(mensagem)         // olá

// Exemplo completo: somar números em paralelo
func somar(nums []int, resultado chan int) {
    total := 0
    for _, n := range nums {
        total += n
    }
    resultado <- total
}

resultado := make(chan int)
go somar([]int{1, 2, 3, 4, 5}, resultado)
fmt.Println(<-resultado)      // 15

// Fechar um canal quando não vai mais enviar
close(canal)

// Canal só de envio ou só de recebimento (em funções)
func enviar(c chan<- int)  { c <- 10 }    // só envia
func receber(c <-chan int) { <-c }        // só recebe
```

---

## Conceito importante: valor zero
Toda variável em Go já nasce com um valor padrão se você não inicializar:
- Números → `0`
- Booleano → `false`
- Texto → `""` (vazio)
- Ponteiro, slice, map, canal, função e interface → `nil` (nada)
- Array e struct → cada campo com seu próprio zero

```go
var n int             // 0
var b bool            // false
var s string          // ""
var lista []int       // nil
var m map[string]int  // nil
```

---

Em resumo: Go tem **tipos básicos** (números, texto, booleano), **tipos compostos** (array, slice, struct, map) e **tipos especiais para concorrência e abstração** (ponteiro, função, interface, canal).
