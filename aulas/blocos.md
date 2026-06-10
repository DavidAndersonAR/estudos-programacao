# Blocos em Go — Resumo simples

Em Go, um **bloco** é basicamente um pedaço de código entre chaves `{` e `}`. Dentro de um bloco a gente pode declarar variáveis, escrever comandos e organizar a lógica do programa. Os blocos servem para agrupar coisas que andam juntas e também para definir o **escopo** (até onde uma variável "existe" e pode ser usada).

Além dos blocos que a gente escreve com chaves, o Go tem alguns blocos **invisíveis** (chamados de implícitos) que existem mesmo sem aparecer no código. Eles ajudam o compilador a saber o que está visível em cada parte do programa.

## 1. O que é um bloco
Um bloco é uma sequência (possivelmente vazia) de declarações e comandos delimitada por chaves. Toda variável declarada dentro de um bloco só vive ali dentro — quando o bloco termina, ela some.

```go
// Um bloco simples entre chaves
{
    mensagem := "Olá"
    fmt.Println(mensagem)
} // aqui o bloco acaba e "mensagem" deixa de existir

// Tentar usar "mensagem" aqui fora daria erro de compilação
```

---

## 2. Blocos explícitos (com chaves)
São os blocos que a gente vê no código: tudo que está dentro de `{ ... }`. Aparecem no corpo de funções, dentro de `if`, `for`, `switch` e até soltos no meio do código.

```go
func exemplo() {
    // Este é o bloco da função

    if true {
        // Este é outro bloco, dentro do if
        x := 10
        fmt.Println(x)
    }

    // Dá pra criar um bloco "solto" só para organizar
    {
        temporario := "só vivo aqui"
        fmt.Println(temporario)
    }
    // "temporario" não existe mais aqui
}
```

---

## 3. Bloco universo (universe block)
É o "bloco mais externo" do Go, que envolve **todo o código de qualquer programa**. Nele moram os nomes pré-definidos pela linguagem, como `int`, `string`, `true`, `false`, `nil`, `len`, `make`, `append` etc. Por isso a gente pode usar esses nomes em qualquer lugar sem importar nada.

```go
// Tudo isso vem do bloco universo - já existe pronto
var n int = 10           // "int" vem do universo
ok := true               // "true" vem do universo
tamanho := len("texto")  // "len" vem do universo
lista := make([]int, 3)  // "make" vem do universo
```

---

## 4. Bloco de pacote (package block)
Cada pacote (package) tem o seu próprio bloco, que envolve **todos os arquivos** daquele pacote. Variáveis, funções e tipos declarados aqui (fora de qualquer função) ficam visíveis para todos os arquivos do mesmo pacote.

```go
// arquivo: usuario.go
package app

// Esta variável está no bloco do pacote "app"
var versao = "1.0"

func MostrarVersao() {
    fmt.Println(versao)
}
```

```go
// arquivo: main.go (mesmo pacote "app")
package app

func iniciar() {
    // Dá pra usar "versao" aqui sem problema,
    // porque está no mesmo bloco de pacote
    fmt.Println(versao)
}
```

---

## 5. Bloco de arquivo (file block)
Cada arquivo `.go` tem o seu próprio bloco também. Ele serve principalmente para os **imports**: o que você importa em um arquivo só vale para aquele arquivo, não para o pacote inteiro.

```go
// arquivo: a.go
package app

import "fmt"  // este "fmt" só vale neste arquivo

func ola() {
    fmt.Println("oi")  // funciona
}
```

```go
// arquivo: b.go
package app

// Se eu não importar "fmt" aqui, não consigo usar fmt neste arquivo,
// mesmo que o arquivo a.go (do mesmo pacote) já tenha importado.
import "fmt"

func tchau() {
    fmt.Println("até logo")
}
```

---

## 6. Bloco de função
Toda função tem o seu próprio bloco, que começa em `{` e termina em `}`. Os parâmetros da função também fazem parte desse bloco, então eles existem do começo ao fim da função.

```go
func saudar(nome string) {
    // Aqui dentro estamos no bloco da função "saudar"
    // O parâmetro "nome" vive neste bloco

    mensagem := "Olá, " + nome
    fmt.Println(mensagem)
} // bloco da função termina aqui; "nome" e "mensagem" somem
```

---

## 7. Blocos implícitos de `if`, `for` e `switch`
Cada `if`, `for` e `switch` cria um bloco **invisível** que envolve a condição/inicialização. Isso é importante porque variáveis declaradas ali na "abertura" do comando só existem dentro daquele `if`/`for`/`switch`.

```go
// No "if" dá pra declarar uma variável antes da condição.
// Essa variável só vive dentro do if/else.
if idade := 18; idade >= 18 {
    fmt.Println("maior de idade")
} else {
    fmt.Println("menor de idade", idade) // ainda dá pra usar aqui
}
// Aqui fora "idade" não existe mais

// No "for" também tem um bloco implícito que segura o "i"
for i := 0; i < 3; i++ {
    fmt.Println(i)
}
// "i" não existe mais aqui

// No "switch" a variável declarada no início só vale dentro dele
switch dia := "segunda"; dia {
case "sabado", "domingo":
    fmt.Println("fim de semana")
default:
    fmt.Println("dia útil:", dia)
}
```

---

## 8. Blocos implícitos nos `case` e `select`
Cada `case` (de um `switch`) e cada `case` de um `select` também é um bloco invisível. Ou seja: o que você declara dentro de um `case` só vale naquele `case`.

```go
switch nota := 8; {
case nota >= 7:
    status := "aprovado"        // só existe neste case
    fmt.Println(status)
case nota >= 5:
    status := "recuperação"     // outro "status", outro bloco
    fmt.Println(status)
default:
    fmt.Println("reprovado")
}

// Exemplo com select (usado em canais)
select {
case msg := <-canal1:
    // "msg" só existe neste case
    fmt.Println("veio do canal1:", msg)
case msg := <-canal2:
    // este "msg" é diferente do de cima
    fmt.Println("veio do canal2:", msg)
}
```

---

## 9. Como os blocos influenciam o escopo
Os blocos formam uma espécie de "caixa dentro de caixa". Uma variável declarada em um bloco mais interno pode ter o mesmo nome que outra de um bloco mais externo — e nesse caso ela **esconde** (shadowing) a de fora enquanto o bloco interno estiver ativo.

```go
var nome = "Global" // bloco do pacote

func exemplo() {
    fmt.Println(nome) // Global

    nome := "Local"   // novo "nome" no bloco da função (esconde o global)
    fmt.Println(nome) // Local

    if true {
        nome := "Mais Local Ainda" // novo "nome" no bloco do if
        fmt.Println(nome)          // Mais Local Ainda
    }

    fmt.Println(nome) // Local (o do if já sumiu)
}
```

---

Em resumo: blocos em Go são **regiões de código** que organizam declarações e definem até onde cada coisa existe. Existem os **blocos explícitos** (entre chaves, que a gente escreve) e os **blocos implícitos** (invisíveis, criados automaticamente): o **universo** (toda a linguagem), o **pacote**, o **arquivo**, a **função** e os blocos dos comandos `if`, `for`, `switch`, `select` e seus `case`. Entender essa "hierarquia de blocos" é o que ajuda a saber onde uma variável é visível e onde ela some.
