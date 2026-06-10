# Módulo 13 — Channels e Sync

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar canais com `make(chan T)` e entender pra que servem
- Enviar (`ch <- v`) e receber (`v := <-ch`) valores
- Diferenciar canal **unbuffered** de **buffered**
- Fechar um canal com `close()` e iterar com `for v := range ch`
- Restringir direção do canal (`chan<- T` envio, `<-chan T` recepção)
- Usar `select` para multiplexar canais e implementar **timeout**
- Proteger estado compartilhado com `sync.Mutex`

## 🤔 Por que channels existem?
No módulo passado você viu **goroutines**: várias coisas rodando ao mesmo tempo. Mas surge uma pergunta natural: **como uma goroutine fala com a outra?**

Em outras linguagens a resposta costuma ser "memória compartilhada + locks". É rápido, mas é fácil errar (race conditions, deadlocks, código difícil de entender).

A filosofia do Go é diferente, resumida numa frase famosa:

> *"Não se comunique compartilhando memória; compartilhe memória se comunicando."*

Ou seja: em vez de várias goroutines mexerem na mesma variável, elas **enviam mensagens** umas para as outras por um "cano" (channel). É como uma esteira de fábrica: um trabalhador coloca a peça, outro pega na outra ponta.

## 🧱 Criando e usando um channel

```go
ch := make(chan int) // canal que transporta inteiros

go func() {
    ch <- 42          // envia 42 no canal
}()

valor := <-ch         // recebe do canal
fmt.Println(valor)    // 42
```

Quebra-cabeça:
- `make(chan int)` cria o canal.
- `ch <- 42` é o **envio**. A seta aponta pra dentro do canal.
- `<-ch` é a **recepção**. A seta aponta pra fora.
- Como o canal acima é **unbuffered**, o envio **trava** até alguém receber, e a recepção **trava** até alguém enviar. É um encontro marcado.

## 📦 Unbuffered vs Buffered

### Unbuffered — encontro sincronizado
```go
ch := make(chan int)   // capacidade 0
```
Quem envia espera. Quem recebe espera. Eles se "encontram" no canal. Bom para sincronização.

### Buffered — caixa de correio com capacidade
```go
ch := make(chan int, 3) // capacidade 3
ch <- 1                 // não trava
ch <- 2                 // não trava
ch <- 3                 // não trava
ch <- 4                 // TRAVA: buffer cheio
```
O envio só trava quando o buffer está **cheio**. A recepção só trava quando está **vazio**. Útil para desacoplar produtor e consumidor (um pode estar um pouco mais rápido que o outro).

## 🔒 Fechando um canal

Quando o produtor terminou de mandar mensagens, ele **fecha** o canal:

```go
close(ch)
```

Regras de ouro:
- **Só quem envia fecha.** Quem recebe nunca fecha.
- Enviar em canal fechado = **panic**.
- Receber de canal fechado retorna o **valor zero** do tipo (e nunca trava).

Para saber se o canal ainda está aberto:
```go
v, ok := <-ch
if !ok {
    fmt.Println("canal fechou")
}
```

## 🔁 Lendo até o canal fechar com `range`

A forma mais elegante de consumir tudo:

```go
for v := range ch {
    fmt.Println(v)
}
// sai do for quando o canal for fechado
```

Sem o `close`, o `range` ficaria travado para sempre esperando mais valores. Por isso fechar é importante.

## ➡️ Direção do canal (chan<- e <-chan)

Em uma função, você pode dizer se ela só envia, só recebe, ou faz os dois:

```go
func produtor(out chan<- int) {  // só pode enviar
    out <- 1
}

func consumidor(in <-chan int) { // só pode receber
    v := <-in
    fmt.Println(v)
}
```

Isso documenta a intenção e o compilador te protege de erros bobos (tentar receber num canal "de envio" não compila).

## 🎛️ `select` — multiplexando canais

`select` é como um `switch` para canais. Ele escolhe **um caso pronto** entre vários:

```go
select {
case v := <-ch1:
    fmt.Println("veio de ch1:", v)
case v := <-ch2:
    fmt.Println("veio de ch2:", v)
}
```

Se mais de um estiver pronto, escolhe **aleatoriamente** (isso é proposital, evita "fome" de um canal).

### Timeout com `time.After`
`time.After(d)` devolve um canal que dispara depois de `d`. Combinado com `select`, dá timeout natural:

```go
select {
case v := <-ch:
    fmt.Println("recebi:", v)
case <-time.After(2 * time.Second):
    fmt.Println("desisti de esperar")
}
```

Sem nenhum `case` pronto, o `select` trava (a menos que você ponha um `default`, que aí ele desiste na hora).

## 🛡️ `sync.Mutex` — quando o channel não cabe

Channels resolvem **muita** coisa, mas às vezes você só quer um contador compartilhado, um cache, um mapa. Para isso existe o **Mutex** (mutual exclusion = exclusão mútua):

```go
import "sync"

var (
    mu      sync.Mutex
    contador int
)

func incrementa() {
    mu.Lock()
    contador++
    mu.Unlock()
}
```

Quem chama `Lock()` primeiro entra; os outros esperam na fila. `Unlock()` libera. Esqueceu o `Unlock`? Trava o programa para sempre. Por isso é comum usar `defer mu.Unlock()` na linha de baixo do `Lock`:

```go
mu.Lock()
defer mu.Unlock()
contador++
```

Sem o Mutex, duas goroutines podem ler `contador`, somar 1, e escrever — perdendo um incremento. Isso é uma **race condition**.

> 💡 Detecte race conditions rodando com a flag `-race`: `go run -race ./seu/programa`. Em produção evita, mas em desenvolvimento é seu melhor amigo.

## 💡 Detalhes que valem ouro
- **Canal nil trava para sempre.** `var ch chan int` (sem `make`) bloqueia envios e recepções. Às vezes isso é usado de propósito em `select` para "desligar" um caso.
- **Fechar canal não é obrigatório** — só faça quando algum consumidor depende disso (typicamente para `range` parar).
- **Channels não são filas universais.** São mecanismo de comunicação. Não use channel onde um `slice` resolve.
- **Mutex protege estado; channel comunica fluxo.** Quando ficar em dúvida, prefira channel — tende a dar código mais simples.

## 👀 Exemplo completo: dois trabalhadores via channel

```go
package main

import (
    "fmt"
    "time"
)

func trabalhador(id int, tarefas <-chan int, resultados chan<- int) {
    for t := range tarefas {
        time.Sleep(100 * time.Millisecond)
        resultados <- t * 2
        fmt.Printf("worker %d processou %d\n", id, t)
    }
}

func main() {
    tarefas := make(chan int, 5)
    resultados := make(chan int, 5)

    go trabalhador(1, tarefas, resultados)
    go trabalhador(2, tarefas, resultados)

    for i := 1; i <= 5; i++ {
        tarefas <- i
    }
    close(tarefas) // sinaliza fim para os trabalhadores

    for i := 0; i < 5; i++ {
        fmt.Println("resultado:", <-resultados)
    }
}
```

Esse padrão se chama **worker pool** — e é praticamente o que você vai construir no desafio.

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia cada exercício com calma.
2. Rode: `go run ./curso/modulo-13-channels-sync/pratica`
3. Modifique buffers, comente `close`, veja o que dá errado. Erro aqui ensina muito.
4. Encare o **desafio**: montar um **Pipeline de Processamento** com 3 estágios.

## ✅ Auto-verificação
- [ ] Sei a diferença entre canal buffered e unbuffered
- [ ] Sei quando devo fechar um canal e quem deve fechar
- [ ] Consigo escrever um `select` com timeout
- [ ] Entendo quando usar `sync.Mutex` em vez de channel
- [ ] Sei restringir a direção de um canal em parâmetros

Próximo módulo: **HTTP Cliente** — fazendo seu programa Go conversar com a internet.
