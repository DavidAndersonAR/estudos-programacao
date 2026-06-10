# Goroutines e Channels — Resumo simples

A "marca registrada" do Go é a concorrência fácil. As ferramentas principais são **goroutines** (tarefas leves) e **channels** (canais de comunicação entre elas).

## 1. O que é uma goroutine
Uma goroutine é uma função que roda "em paralelo" com o resto do programa. É muito mais leve que uma thread — dá pra ter milhares delas. Basta usar a palavra `go` na frente da chamada.

```go
func saudar(nome string) {
    fmt.Println("Olá,", nome)
}

func main() {
    go saudar("Ana")    // roda em paralelo
    go saudar("Bruno")  // roda em paralelo
    time.Sleep(time.Second) // espera um pouco pra elas terminarem
}
```

Atenção: se `main` terminar antes das goroutines, elas são abandonadas. Por isso usamos sincronização (channels ou WaitGroup).

---

## 2. O que é um channel
Channel é um "cano" para mandar valores entre goroutines, com sincronização automática.

```go
ch := make(chan int)        // canal sem buffer
buf := make(chan string, 3) // canal com buffer (até 3 valores)

// Mandar
ch <- 42

// Receber
v := <-ch
```

---

## 3. Channel sem buffer (sincronizado)
O envio só passa quando ALGUÉM já está esperando para receber. É o "aperto de mão".

```go
ch := make(chan int)
go func() {
    ch <- 10  // só vai passar quando main fizer <-ch
}()
fmt.Println(<-ch) // espera receber, então 10 chega
```

---

## 4. Channel com buffer
O envio passa imediatamente, desde que o buffer não esteja cheio.

```go
ch := make(chan int, 2)
ch <- 1  // ok
ch <- 2  // ok, buffer cheio
// ch <- 3  // bloquearia até alguém receber
fmt.Println(<-ch, <-ch) // 1 2
```

---

## 5. Fechando um channel
Quando você não vai mais mandar mensagens, feche com `close()`. Quem recebe pode detectar isso.

```go
ch := make(chan int, 3)
ch <- 1
ch <- 2
close(ch)

// for-range em channel: roda até o canal ser fechado
for v := range ch {
    fmt.Println(v) // 1, depois 2
}

// Verificar manualmente se fechou
v, ok := <-ch
if !ok {
    fmt.Println("canal fechado")
}
```

---

## 6. Direção do channel (só envio/só recebimento)
Pra ser mais seguro, dá pra dizer que uma função só pode enviar ou só receber.

```go
func produzir(out chan<- int) {  // só envia
    out <- 42
}

func consumir(in <-chan int) {   // só recebe
    v := <-in
    fmt.Println(v)
}
```

---

## 7. `select` — esperar vários channels
Permite esperar em vários channels e agir no primeiro que ficar pronto.

```go
select {
case msg := <-ch1:
    fmt.Println("veio do ch1:", msg)
case msg := <-ch2:
    fmt.Println("veio do ch2:", msg)
case <-time.After(2 * time.Second):
    fmt.Println("timeout!")
default:
    fmt.Println("nenhum canal pronto")
}
```

---

## 8. Padrões comuns

### Worker pool
Vários workers consumindo tarefas de um channel.

```go
func worker(id int, tarefas <-chan int, resultados chan<- int) {
    for t := range tarefas {
        resultados <- t * 2
    }
}

tarefas := make(chan int, 10)
resultados := make(chan int, 10)

for w := 1; w <= 3; w++ {
    go worker(w, tarefas, resultados)
}

for i := 1; i <= 5; i++ { tarefas <- i }
close(tarefas)

for i := 1; i <= 5; i++ { fmt.Println(<-resultados) }
```

### Fan-out / Fan-in
Várias goroutines processam (fan-out), depois resultados são juntados (fan-in).

### Done channel (sinal de parada)
```go
done := make(chan struct{})
go func() {
    defer close(done)
    // ... trabalho ...
}()
<-done // espera terminar
```

---

## 9. Erros comuns a evitar
- **Deadlock**: enviar pra canal sem ninguém recebendo, ou esperar receber sem ninguém mandando.
- **Vazamento de goroutine**: goroutine que fica presa esperando algo que nunca vem.
- **Race condition**: várias goroutines mexem na mesma variável sem sincronização. Use channels ou `sync.Mutex`.
- **Fechar channel duas vezes**: panic. Só feche uma vez, geralmente quem envia fecha.
- **Mandar em channel fechado**: panic.

---

Em resumo: goroutines são tarefas paralelas leves, channels são o jeito seguro de elas se comunicarem. A filosofia do Go é: "não compartilhe memória para se comunicar; comunique-se para compartilhar memória".
