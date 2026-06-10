# Módulo 03 — Controle de Fluxo

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Tomar decisões no código usando `if`, `else if` e `else`
- Usar `if` com inicialização (`if x := f(); x > 0`) — um padrão muito comum em Go
- Escolher entre vários caminhos com `switch` (com e sem expressão)
- Repetir blocos de código com `for` nas suas três formas (clássica, while-like, infinita)
- Interromper laços com `break` e pular voltas com `continue`

## 🤔 Por que controle de fluxo?
Até agora seus programas executam de cima para baixo, linha por linha. Mas a vida real não é assim: às vezes você precisa decidir ("se for maior de idade, libera"), repetir ("imprima de 1 a 100") ou escolher entre várias opções ("se for segunda, terça ou quarta..."). É aí que entram os comandos de controle de fluxo.

Go é minimalista: tem **apenas três construções** principais — `if`, `switch` e `for`. Não existe `while`, `do-while`, nem `foreach` separado. O `for` faz tudo.

## 🪧 `if` / `else` — decisões

```go
idade := 18

if idade >= 18 {
    fmt.Println("Maior de idade")
} else {
    fmt.Println("Menor de idade")
}
```

Detalhes importantes:
- **Sem parênteses** em volta da condição (diferente de C/Java/JavaScript).
- **As chaves `{}` são obrigatórias**, mesmo para uma linha só. Sem atalho.
- A chave de abertura `{` **fica na mesma linha** do `if`. Se você colocar em outra linha, o compilador reclama.

### `else if` para várias condições
```go
nota := 7.5

if nota >= 9 {
    fmt.Println("Ótimo")
} else if nota >= 7 {
    fmt.Println("Bom")
} else if nota >= 5 {
    fmt.Println("Regular")
} else {
    fmt.Println("Precisa melhorar")
}
```

### `if` com inicialização (o pulo do gato)
Você pode **declarar uma variável dentro do próprio `if`**. Essa variável só existe dentro do `if/else`.

```go
if resto := 10 % 3; resto == 0 {
    fmt.Println("Divide certinho")
} else {
    fmt.Println("Sobra:", resto)
}
// "resto" não existe mais aqui fora
```

Esse padrão é **idiomático em Go**: muito usado quando você chama uma função que devolve valor + erro:
```go
if n, err := strconv.Atoi("42"); err == nil {
    fmt.Println("Número:", n)
}
```

## 🔀 `switch` — várias opções de forma limpa

Quando você tem muitos `else if` em sequência, o `switch` fica mais legível.

```go
dia := "terça"

switch dia {
case "segunda":
    fmt.Println("Começo da semana")
case "terça", "quarta", "quinta":   // vários valores no mesmo case
    fmt.Println("Meio da semana")
case "sexta":
    fmt.Println("Sextou!")
default:
    fmt.Println("Fim de semana")
}
```

### Detalhes que diferem de outras linguagens
- **Não precisa de `break`**: em Go, cada `case` para sozinho. Não "vaza" para o próximo.
- Um único `case` pode ter **vários valores**, separados por vírgula.
- O `default` é opcional e roda quando nenhum `case` bater.

### `switch` sem expressão (substitui `else if`)
Esse formato é uma das coisas mais úteis do Go. É como um `if/else if/else` mais bonito.

```go
nota := 8.0

switch {
case nota >= 9:
    fmt.Println("A")
case nota >= 7:
    fmt.Println("B")
case nota >= 5:
    fmt.Println("C")
default:
    fmt.Println("D")
}
```

### `switch` com inicialização
Igual ao `if`: você pode declarar uma variável que só vive dentro do `switch`.
```go
switch hora := time.Now().Hour(); {
case hora < 12:
    fmt.Println("Bom dia")
case hora < 18:
    fmt.Println("Boa tarde")
default:
    fmt.Println("Boa noite")
}
```

## 🔁 `for` — o único laço de Go

Go tem **só um comando de repetição**, mas ele assume três formas.

### Forma 1: clássica (init; condição; passo)
```go
for i := 0; i < 5; i++ {
    fmt.Println(i)   // 0, 1, 2, 3, 4
}
```
Lendo: "comece com `i = 0`, enquanto `i < 5`, no fim de cada volta faça `i++`".

### Forma 2: estilo "while" (só condição)
Em Go não existe `while`. Quando você só quer uma condição, escreve `for` com ela.
```go
n := 10
for n > 0 {
    fmt.Println(n)
    n--
}
```

### Forma 3: infinito (sem condição)
Roda para sempre até você usar `break`. Útil para servidores, loops de jogo, ou quando você não sabe quantas iterações vai precisar.
```go
contador := 0
for {
    if contador >= 3 {
        break
    }
    fmt.Println("rodando...")
    contador++
}
```

## ⛔ `break` e `continue`

### `break` — sai do laço na hora
```go
for i := 0; i < 10; i++ {
    if i == 5 {
        break   // para o for quando i = 5
    }
    fmt.Println(i)   // imprime 0, 1, 2, 3, 4
}
```

### `continue` — pula para a próxima volta
```go
for i := 0; i < 10; i++ {
    if i%2 != 0 {
        continue   // pula os ímpares
    }
    fmt.Println(i)   // imprime 0, 2, 4, 6, 8
}
```

## 💡 Detalhes que valem ouro
- **Sem `while`, sem `do-while`**: o `for` faz tudo. Acostume-se.
- **Parênteses na condição**: não use. `if (x > 0)` compila mas é antiidiomático.
- **Chaves obrigatórias**: até para um `if` de uma linha. Sem atalho como em C.
- **`switch` é seguro**: sem `break` esquecido, sem "fall-through" por acidente.
- **`if`/`switch` com inicialização**: limita o escopo da variável, deixa o código mais limpo. Use bastante.
- **Cuidado com `==` em strings**: funciona normalmente em Go (`s == "ola"`), diferente de Java.
- **Vírgula em `case`**: `case 1, 2, 3:` é OR — qualquer um dos valores entra.

## 👀 Variação útil: contagem regressiva
```go
package main

import "fmt"

func main() {
    for i := 10; i > 0; i-- {
        if i == 5 {
            fmt.Println("metade!")
            continue
        }
        if i == 1 {
            fmt.Println("explode!")
            break
        }
        fmt.Println(i)
    }
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e rode os exemplos:
   `go run ./curso/modulo-03-controle-fluxo/pratica`
2. Modifique os limites dos `for` e veja o que acontece. Erre de propósito.
3. Encare o **desafio**: implementar um Jogo de Adivinhação simulado.

## ✅ Auto-verificação
- [ ] Sei a sintaxe de `if`, `else if`, `else` (sem parênteses, com chaves)
- [ ] Consigo usar `if` com inicialização (`if x := f(); cond`)
- [ ] Sei diferenciar `switch` com expressão e sem expressão
- [ ] Conheço as três formas do `for` e sei quando usar cada uma
- [ ] Sei a diferença entre `break` (sai do laço) e `continue` (pula a volta)

Próximo módulo: **Funções** — onde você vai aprender a empacotar lógica em pedaços reutilizáveis.
