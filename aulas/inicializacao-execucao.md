# Inicialização e Execução em Go — Resumo simples

Todo programa em Go segue um "passo a passo" antes de começar a rodar de fato: primeiro as variáveis ganham um valor inicial, depois os pacotes se preparam (rodando suas funções `init`), e só no final a função `main` é chamada. Entender essa ordem ajuda a evitar surpresas quando uma variável depende de outra ou quando algo precisa ser configurado antes do programa começar.

## 1. Valor zero
Em Go, **toda variável já nasce com um valor padrão**, mesmo que você não atribua nada. Esse valor inicial se chama "valor zero" (zero value). Isso evita o problema de "variável sem valor" que existe em outras linguagens.

Cada tipo tem o seu valor zero:
- Números → `0`
- Booleano → `false`
- Texto (string) → `""` (vazio)
- Ponteiro, slice, map, canal, função e interface → `nil` (que significa "nada")
- Array e struct → cada campo com o seu próprio valor zero

```go
// Declarar sem atribuir nada — Go preenche com o valor zero
var idade int              // 0
var ativo bool             // false
var nome string            // ""
var ponteiro *int          // nil
var lista []int            // nil
var dicionario map[string]int  // nil

// Em struct, cada campo recebe o seu zero
type Pessoa struct {
    Nome  string
    Idade int
}
var p Pessoa               // {Nome: "", Idade: 0}

// Em array, todas as posições começam zeradas
var numeros [3]int         // [0, 0, 0]
```

---

## 2. Inicialização de variáveis do pacote
Antes do programa começar a rodar, Go olha para todas as **variáveis declaradas no nível do pacote** (fora de qualquer função) e dá um valor a cada uma. A regra é simples:

- Se você atribuiu um valor na declaração, esse valor é usado.
- Se não atribuiu, a variável recebe o valor zero do seu tipo.

A ordem importa quando uma variável depende de outra. Go é esperto: ele analisa as dependências e inicializa primeiro as que não dependem de ninguém, depois as que dependem dessas, e por aí vai. Se não houver dependência, a ordem é a de declaração no arquivo.

```go
package main

// Variáveis do pacote (fora de qualquer função)
var (
    a = 10              // inicializa com 10
    b = a * 2           // depende de "a", então roda depois — vira 20
    c int               // sem valor atribuído — fica com o zero (0)
    nome = "David"      // string com valor
)

// Quando o programa começa, a, b, c e nome já estão prontos
func main() {
    fmt.Println(a, b, c, nome)  // 10 20 0 David
}
```

---

## 3. A função `init`
A `init` é uma função **especial** que Go chama sozinho, sem você precisar invocar. Ela serve para preparar coisas antes de o programa começar (carregar configuração, validar valores, registrar algo etc).

Regras importantes:
- Não recebe parâmetros e não retorna nada: `func init() { ... }`
- Você **não pode chamar** `init` manualmente — só o Go chama.
- Pode existir **mais de uma** `init` no mesmo arquivo ou pacote. Todas rodam, na ordem em que aparecem.
- Roda **depois** que todas as variáveis do pacote já foram inicializadas.

```go
package main

import "fmt"

var contador = 0

// Primeira init — roda automaticamente antes do main
func init() {
    fmt.Println("Preparando o programa...")
    contador = 10
}

// Segunda init — também roda, logo depois da primeira
func init() {
    fmt.Println("Carregando configurações...")
    contador = contador + 5
}

func main() {
    fmt.Println("Contador =", contador)  // Contador = 15
}

// Saída na tela:
// Preparando o programa...
// Carregando configurações...
// Contador = 15
```

---

## 4. Inicialização do programa (a ordem completa)
Quando você roda um programa Go, ele segue **sempre** essa ordem:

1. **Importa os pacotes** que o seu código usa. Se esses pacotes importam outros, Go vai descendo até o fundo da árvore.
2. **Inicializa cada pacote** começando pelos mais "no fundo" (os que não dependem de mais ninguém). Para cada um:
   - Primeiro, as variáveis do pacote ganham seus valores.
   - Depois, todas as funções `init` daquele pacote são chamadas.
3. **Inicializa o pacote `main`** seguindo as mesmas regras.
4. **Chama a função `main`** — aqui o seu programa começa de verdade.

Cada pacote é inicializado **apenas uma vez**, mesmo que vários outros pacotes o importem.

```go
// Imagine este cenário com 3 pacotes:
// main importa "config" e "config" importa "log"

// Ordem em que tudo acontece:
// 1. Variáveis do pacote "log" ganham valores
// 2. init() do pacote "log" roda
// 3. Variáveis do pacote "config" ganham valores
// 4. init() do pacote "config" roda
// 5. Variáveis do pacote "main" ganham valores
// 6. init() do pacote "main" roda
// 7. main() é chamada — programa começa
```

---

## 5. Execução do programa (a função `main`)
A `main` é o **ponto de partida** do programa. Ela só existe no pacote chamado `main` e tem uma assinatura fixa: não recebe parâmetros e não retorna nada.

Quando a `main` termina, o programa termina junto — mesmo que existam outras tarefas (goroutines) ainda rodando em paralelo. Por isso, em programas com concorrência, é comum esperar essas tarefas antes de deixar a `main` acabar.

```go
package main

import "fmt"

func main() {
    // Aqui começa o programa de verdade
    fmt.Println("Olá, mundo!")

    // Quando esta função termina, o programa termina
}
```

```go
// Exemplo com goroutine (tarefa em paralelo)
package main

import (
    "fmt"
    "time"
)

func tarefa() {
    fmt.Println("Tarefa rodando...")
}

func main() {
    go tarefa()                  // dispara em paralelo
    time.Sleep(time.Second)      // espera um pouco antes de terminar
    fmt.Println("Fim do main")
    // Se a main acabasse antes do Sleep, a tarefa nem rodaria
}
```

---

## 6. Resumo visual da ordem
Para fixar a sequência completa:

```
1. Go importa todos os pacotes (e os pacotes deles, recursivamente)
2. Para cada pacote, em ordem de dependência:
   2a. Variáveis do pacote ganham seus valores (ou o valor zero)
   2b. Todas as funções init() rodam, na ordem em que aparecem
3. O pacote main passa pelo mesmo processo
4. A função main() é chamada
5. Quando main() termina, o programa acaba
```

---

Em resumo: Go cuida da preparação do programa para você. Toda variável já nasce com um valor (o **valor zero**), as variáveis do pacote são inicializadas respeitando dependências, as funções **`init`** rodam automaticamente para deixar tudo pronto, e só então a **`main`** é chamada para começar de fato a execução. Essa ordem é sempre a mesma e ajuda a manter os programas previsíveis.
