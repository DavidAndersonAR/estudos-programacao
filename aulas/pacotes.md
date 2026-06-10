# Pacotes em Go — Resumo simples

Em Go, um **pacote** (em inglês, *package*) é uma forma de organizar e reaproveitar código. Você agrupa arquivos relacionados num mesmo pacote, e quem quiser usar essas funcionalidades só precisa "importar" (trazer para dentro do seu arquivo) o pacote. Pense num pacote como uma "caixa de ferramentas" pronta para usar.

## 1. O que é um pacote
Um pacote é um conjunto de **um ou mais arquivos `.go`** que ficam dentro de uma mesma pasta e compartilham o mesmo nome de pacote. Todos esses arquivos enxergam uns aos outros automaticamente — não precisa importar nada entre eles.

A biblioteca padrão do Go já vem cheia de pacotes prontos, como `fmt` (formatar texto), `strings` (mexer com texto), `math` (matemática) e `os` (sistema operacional).

```go
// Estrutura típica de um projeto em Go:
//
// meuapp/
// ├── main.go          (pacote main)
// ├── calculadora/
// │   ├── soma.go      (pacote calculadora)
// │   └── subtrai.go   (pacote calculadora)
// └── util/
//     └── texto.go     (pacote util)
//
// Cada pasta = um pacote. Os arquivos dentro da
// mesma pasta fazem parte do mesmo pacote.
```

---

## 2. Organização do arquivo fonte
Todo arquivo `.go` segue uma ordem fixa, e isso é obrigatório:

1. **Cláusula `package`** — a primeira linha "de verdade" do arquivo (pode ter comentários antes), dizendo a qual pacote o arquivo pertence.
2. **Imports** — a lista de pacotes externos que esse arquivo vai usar.
3. **Declarações** — variáveis, constantes, tipos e funções.

```go
// Comentário explicando o arquivo (opcional)

// 1. Cláusula package - SEMPRE a primeira instrução
package calculadora

// 2. Imports - vêm logo depois
import "fmt"

// 3. Declarações - o resto do código
func Somar(a, b int) int {
    fmt.Println("Calculando...")
    return a + b
}
```

---

## 3. A cláusula `package` (primeira linha)
A linha `package nome` define a qual pacote o arquivo pertence. Regras simples:

- **Todos os arquivos da mesma pasta** precisam ter o mesmo nome de pacote.
- O nome do pacote costuma ser **curto, em minúsculas e sem underscores** (ex.: `fmt`, `http`, `bufio`).
- O nome `main` é especial: indica que esse pacote é um programa executável (tem uma função `main` que é o ponto de partida do programa).

```go
// Arquivo: calculadora/soma.go
package calculadora

func Somar(a, b int) int {
    return a + b
}
```

```go
// Arquivo: main.go
// Pacote "main" = programa que será executado
package main

import "fmt"

// A função main é o ponto de entrada do programa
func main() {
    fmt.Println("Olá, mundo!")
}
```

---

## 4. Declaração de import
Para usar um pacote, você precisa **importá-lo**. O import pode ser feito de duas formas: uma a uma ou agrupado entre parênteses (mais comum quando são vários).

```go
// Forma 1: um import por linha
import "fmt"
import "strings"

// Forma 2: agrupado (mais usado e recomendado)
import (
    "fmt"
    "strings"
    "math"
)

// Usando depois de importar
func exemplo() {
    fmt.Println(strings.ToUpper("olá"))  // OLÁ
    fmt.Println(math.Pi)                 // 3.141592...
}
```

O texto entre aspas é o **caminho do pacote** (*import path*). Para pacotes da biblioteca padrão é só o nome (`"fmt"`). Para pacotes externos costuma ser um endereço (`"github.com/usuario/projeto"`).

---

## 5. Formas de importar
Existem quatro jeitos de importar um pacote, e cada um tem uma utilidade:

```go
import (
    // 1. Import normal (padrão) - usa o nome do pacote
    "fmt"
    // Uso: fmt.Println("oi")

    // 2. Apelido - você dá outro nome ao pacote
    // Útil quando dois pacotes têm o mesmo nome
    f "fmt"
    // Uso: f.Println("oi")

    // 3. Ponto - traz as funções como se fossem do seu arquivo
    // (NÃO recomendado - deixa o código confuso)
    . "fmt"
    // Uso: Println("oi")   <- sem prefixo!

    // 4. Blank (underscore) - importa só pelos "efeitos colaterais"
    // Não vai usar nada do pacote diretamente, mas precisa que ele
    // seja carregado (ex: registrar um driver de banco)
    _ "github.com/lib/pq"
)
```

Resumindo:
- **Normal**: o caso do dia a dia.
- **Apelido**: para evitar conflito de nomes ou encurtar.
- **Ponto (`.`)**: bagunça o código, evite.
- **Blank (`_`)**: quando o pacote faz algo automático ao ser carregado e você não chama nada dele.

---

## 6. Identificadores exportados (públicos e privados)
Em Go não existe `public` ou `private` como em outras linguagens. A regra é simples e visual:

- **Começa com letra MAIÚSCULA** → exportado (público): pode ser usado de fora do pacote.
- **Começa com letra minúscula** → não exportado (privado): só é visível dentro do próprio pacote.

Isso vale para **tudo**: funções, variáveis, constantes, tipos e campos de struct.

```go
package calculadora

// Função PÚBLICA - pode ser chamada de outros pacotes
func Somar(a, b int) int {
    return a + b
}

// Função PRIVADA - só funciona dentro do pacote calculadora
func validar(n int) bool {
    return n >= 0
}

// Variável pública
var Versao = "1.0"

// Variável privada
var contador = 0

// Tipo público com campos mistos
type Conta struct {
    Titular string  // campo público
    saldo   float64 // campo privado (só o próprio pacote mexe)
}
```

```go
// Em outro pacote (ex: main.go)
package main

import (
    "fmt"
    "meuapp/calculadora"
)

func main() {
    fmt.Println(calculadora.Somar(2, 3))   // OK - função pública
    fmt.Println(calculadora.Versao)        // OK - variável pública

    // calculadora.validar(5)   // ERRO - função privada
    // calculadora.contador     // ERRO - variável privada
}
```

---

## 7. Unicidade dos identificadores
Dentro de um mesmo pacote, **não pode existir dois identificadores (nomes) iguais no mesmo nível**. Ou seja: não dá para declarar duas funções `Somar` ou duas variáveis `total` no mesmo escopo, mesmo que estejam em arquivos diferentes do pacote.

Já em **pacotes diferentes**, os nomes podem se repetir sem problema, porque você acessa cada um com o prefixo do pacote.

```go
// Arquivo: calculadora/soma.go
package calculadora

func Somar(a, b int) int { return a + b }
```

```go
// Arquivo: calculadora/outro.go
package calculadora

// ERRO! Já existe "Somar" no pacote calculadora
// func Somar(a, b int) int { return a - b }

// OK - nome diferente
func SomarTres(a, b, c int) int { return a + b + c }
```

```go
// Em pacotes diferentes não tem conflito:
package main

import (
    "meuapp/calculadora"
    "meuapp/matematica"
)

func main() {
    calculadora.Somar(1, 2)   // função do pacote calculadora
    matematica.Somar(3, 4)    // função do pacote matematica
}
```

---

## 8. O pacote `main`
O pacote `main` é diferente de todos os outros. Ele indica que aquele código vira um **programa executável**, não uma biblioteca. Toda aplicação Go que você quer rodar precisa de:

- Um pacote chamado `main`.
- Uma função `main()` sem parâmetros e sem retorno — é por onde o programa começa.

```go
// Arquivo: main.go
package main

import "fmt"

// Função main: ponto de entrada do programa
// É chamada automaticamente ao executar "go run" ou rodar o binário
func main() {
    fmt.Println("O programa começa aqui!")
}
```

Já um pacote **comum** (que não é `main`) serve para ser importado por outros — é uma biblioteca, não um programa.

---

## 9. Exemplo completo
Juntando tudo num exemplo prático:

```go
// Arquivo: saudacao/saudacao.go
package saudacao

import "fmt"

// Função pública (M maiúsculo)
func Ola(nome string) string {
    return fmt.Sprintf("Olá, %s!", formatar(nome))
}

// Função privada (f minúsculo) - só o pacote usa
func formatar(nome string) string {
    if nome == "" {
        return "amigo(a)"
    }
    return nome
}
```

```go
// Arquivo: main.go
package main

import (
    "fmt"

    // Apelido para encurtar
    s "meuapp/saudacao"
)

func main() {
    fmt.Println(s.Ola("David"))   // Olá, David!
    fmt.Println(s.Ola(""))        // Olá, amigo(a)!

    // s.formatar("teste")   // ERRO - função privada
}
```

---

Em resumo: pacotes são a maneira de **organizar o código em pastas reutilizáveis**. Todo arquivo Go começa com `package nome`, declara seus `import`s logo em seguida, e usa **letra maiúscula no início** para deixar algo público ou minúscula para privado. O pacote `main` é o programa que roda; os outros são bibliotecas que você importa.
