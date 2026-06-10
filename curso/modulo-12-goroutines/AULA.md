# Módulo 12 — Goroutines

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é uma goroutine e por que ela é tão barata
- Lançar funções em paralelo com `go func()`
- Esperar goroutines terminarem com `sync.WaitGroup`
- Reconhecer (e evitar) duas armadilhas clássicas: o **main que sai cedo demais** e a **variável de loop compartilhada**
- Identificar uma **race condition** (sem ainda saber resolvê-la — isso vem no Módulo 13)

## 🤔 O que é uma goroutine?
Uma **goroutine** é uma função rodando "ao lado" do programa principal. Pense em vários ajudantes correndo em paralelo enquanto o `main` continua o trabalho dele.

Em outras linguagens, criar uma thread é caro: cada uma consome megabytes de memória, e poucas centenas já travam o sistema. Em Go, uma goroutine custa **uns 2 KB** no início. Dá pra ter **milhares — até milhões** delas no mesmo programa sem suar. É essa a peça que fez o Go virar queridinho de servidores web.

Importante: goroutine **não é** uma thread do sistema operacional. O runtime do Go multiplexa milhares de goroutines em um punhado de threads reais. Você não precisa se preocupar com isso — só saber que é leve.

## 🧱 A sintaxe é... só uma palavra
Para rodar uma função como goroutine, coloque `go` na frente dela:

```go
package main

import "fmt"

func dizerOi() {
    fmt.Println("Oi do paralelo!")
}

func main() {
    go dizerOi()        // lança goroutine
    fmt.Println("main") // continua sem esperar
}
```

Rodando isso várias vezes, você vai ver coisas estranhas: às vezes só aparece `main`, às vezes aparece tudo, às vezes vem fora de ordem. **Por quê?**

## ⚠️ Armadilha #1: o main não espera ninguém
Quando o `main` retorna, **o programa inteiro acaba** — e leva todas as goroutines junto, mesmo as que ainda não tinham terminado.

A solução **errada** que todo iniciante tenta:

```go
func main() {
    go dizerOi()
    time.Sleep(1 * time.Second) // hack: espera 1 segundo
}
```

Funciona? Mais ou menos. Mas é horrível:
- Se a goroutine demora mais de 1 segundo, ainda morre
- Se demora menos, você ficou parado à toa
- Não escala para várias goroutines com tempos diferentes

Use `time.Sleep` só para experimentos descartáveis. Em código sério, use **WaitGroup**.

## 🔄 sync.WaitGroup — esperando em grupo
Um `WaitGroup` é um contador atômico de "trabalhos pendentes". Três métodos:

- **`Add(n)`**: avisa que tem `n` trabalhos novos
- **`Done()`**: avisa que um trabalho terminou (decrementa o contador)
- **`Wait()`**: bloqueia até o contador chegar a zero

```go
var wg sync.WaitGroup

wg.Add(1)             // vai ter 1 goroutine
go func() {
    defer wg.Done()   // marca como terminada ao sair
    fmt.Println("trabalhando")
}()

wg.Wait()             // segura o main até Done() ser chamado
```

O `defer wg.Done()` é padrão de ouro: garante o decremento mesmo se a função entrar em pânico ou sair por outro caminho.

## 🐛 Armadilha #2: a variável do loop
Esse aqui pega quase todo mundo. **Antes do Go 1.22**, o seguinte código era um clássico de pegadinha:

```go
for i := 0; i < 5; i++ {
    go func() {
        fmt.Println(i) // CUIDADO
    }()
}
```

A questão: a goroutine **captura `i` por referência**. Quando ela finalmente roda, o loop já pode ter terminado e `i` virou 5. Resultado: várias goroutines imprimindo `5`.

A solução tradicional é fazer uma **cópia local**:

```go
for i := 0; i < 5; i++ {
    i := i // cria nova variável dentro do loop
    go func() {
        fmt.Println(i)
    }()
}
```

Ou passar como argumento (mais explícito):

```go
for i := 0; i < 5; i++ {
    go func(n int) {
        fmt.Println(n)
    }(i)
}
```

Desde o Go 1.22, o loop já cria uma variável nova por iteração — mas o costume de passar como argumento continua sendo mais claro e funciona em qualquer versão.

## 💀 Goroutine vazada (leak)
Lançar goroutine é fácil. **Matar** goroutine não existe — em Go não tem `goroutine.Kill()`. Se uma goroutine ficar bloqueada para sempre (esperando algo que nunca chega), ela vira **memória vazada** para o resto da vida do programa.

```go
go func() {
    canal := make(chan int)
    <-canal // espera para sempre — ninguém manda nada
}()
```

Cada goroutine custa pouco, mas se você vazar **milhares por minuto**, em pouco tempo o servidor cai. Regra: toda goroutine que você lança precisa ter um caminho **claro de sair**. Veremos isso direito com canais no próximo módulo.

## 🔥 Race condition (rápido aperitivo)
Quando duas goroutines mexem na **mesma variável ao mesmo tempo**, dá merda.

```go
contador := 0

for i := 0; i < 1000; i++ {
    go func() {
        contador++   // RACE: leitura + escrita não atômica
    }()
}
```

O esperado seria contador = 1000. Mas a operação `contador++` na verdade é:
1. ler o valor de `contador`
2. somar 1
3. escrever de volta

Duas goroutines podem ler **6** ao mesmo tempo, ambas somar e escrever **7** — uma incrementação se perdeu. O resultado final é imprevisível: 873, 941, 1000... vai variar a cada execução.

Go tem uma ferramenta linda para detectar isso: rode com `-race`:
```bash
go run -race ./curso/modulo-12-goroutines/pratica
```
e ele aponta exatamente onde existe a corrida.

**A solução** (mutex, atomic, ou canais) vem no **Módulo 13**. Por enquanto: aprenda a **enxergar** o problema.

## 💡 Detalhes que valem ouro
- `go funcao()` lança a função; **não retorna nada** (o valor de retorno da função é descartado).
- Goroutine sem nome (anônima) é o mais comum: `go func() { ... }()` — note os `()` no final.
- `runtime.NumGoroutine()` te diz quantas goroutines estão vivas — útil pra detectar leaks.
- Goroutines compartilham memória com o `main`. Em Go a filosofia é: **"não comunique compartilhando memória; compartilhe memória comunicando"** (via canais). Vamos chegar lá.
- Lançar goroutine é tão barato que muitos programas Go criam **uma por requisição HTTP** sem pensar duas vezes.

## 👀 Variação completa com WaitGroup

```go
package main

import (
    "fmt"
    "sync"
)

func trabalhador(id int, wg *sync.WaitGroup) {
    defer wg.Done()
    fmt.Printf("trabalhador %d começou\n", id)
    fmt.Printf("trabalhador %d terminou\n", id)
}

func main() {
    var wg sync.WaitGroup

    for i := 1; i <= 3; i++ {
        wg.Add(1)
        go trabalhador(i, &wg)
    }

    wg.Wait()
    fmt.Println("todos terminaram")
}
```

Note: o `WaitGroup` é passado **por ponteiro** (`*sync.WaitGroup`). Se passar por valor, cada goroutine teria a própria cópia do contador — e o `Wait()` no main nunca encontraria os `Done()` das cópias. Detalhe pequeno, bug grande.

## 🚦 Próximos passos
1. Leia **`pratica/main.go`** com calma — 6 exercícios resolvidos que mostram cada armadilha.
2. Rode com `-race` pelo menos uma vez: `go run -race ./curso/modulo-12-goroutines/pratica`
3. Encare o **desafio**: **Downloader Paralelo Simulado**.
4. Próximo módulo: canais e mutex — aí sim a gente **resolve** a race condition.

## ✅ Auto-verificação
- [ ] Sei que `go funcao()` lança uma goroutine
- [ ] Entendo por que `time.Sleep` é hack ruim e `WaitGroup` é o jeito certo
- [ ] Sei explicar o problema da variável de loop capturada
- [ ] Consigo descrever em uma frase o que é race condition
- [ ] Reconheço que uma goroutine bloqueada para sempre é um vazamento

Próximo módulo: **Channels e sync** — onde a gente aprende a fazer goroutines **conversarem** sem bagunça.
