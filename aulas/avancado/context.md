# Context em Go — Resumo simples

O pacote `context` resolve um problema comum: como **cancelar** ou **dar timeout** numa operação que está rodando (especialmente entre várias goroutines)? E como passar dados de requisição (como ID de usuário) entre funções sem virar bagunça?

## 1. O que é um Context
É um "sinal" que carrega:
- Um **prazo** ou cancelamento
- Valores associados à requisição (opcional)

É sempre passado como **primeiro parâmetro** de funções que demoram (HTTP, banco de dados, etc).

```go
import "context"

ctx := context.Background()  // contexto raiz, vazio
```

---

## 2. Background e TODO
- `context.Background()` — usado no `main`, em testes, no início de uma requisição.
- `context.TODO()` — quando você ainda não sabe qual usar (placeholder).

```go
ctx := context.Background()
```

---

## 3. WithCancel — cancelamento manual
Cria um contexto filho que pode ser cancelado por uma função `cancel`.

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel() // SEMPRE chame cancel, libera recursos

go trabalhar(ctx)

time.Sleep(2 * time.Second)
cancel() // sinaliza pra parar
```

A função recebida usa `<-ctx.Done()` pra saber se foi cancelada:

```go
func trabalhar(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            fmt.Println("cancelado:", ctx.Err())
            return
        default:
            // continua trabalhando
            time.Sleep(500 * time.Millisecond)
        }
    }
}
```

---

## 4. WithTimeout — cancela depois de X tempo
Atalho pra criar contexto que cancela sozinho após um tempo.

```go
ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
defer cancel()

select {
case <-tarefaLonga():
    fmt.Println("tarefa terminou a tempo")
case <-ctx.Done():
    fmt.Println("estourou o tempo:", ctx.Err())
}
```

---

## 5. WithDeadline — cancela em momento específico
Parecido com timeout, mas usa data/hora absoluta.

```go
prazo := time.Now().Add(5 * time.Second)
ctx, cancel := context.WithDeadline(context.Background(), prazo)
defer cancel()
```

---

## 6. WithValue — passar dados na requisição
Permite anexar valores ao contexto. Útil para coisas como ID de usuário, trace ID.

```go
type chave string
const userIDKey chave = "userID"

ctx := context.WithValue(context.Background(), userIDKey, 42)

// Lendo
if id, ok := ctx.Value(userIDKey).(int); ok {
    fmt.Println("user:", id)
}
```

**Cuidado**: WithValue é para dados de requisição (IDs, autenticação), NÃO para passar parâmetros normais. Não abuse.

---

## 7. ctx.Done() e ctx.Err()
- `ctx.Done()` retorna um channel que fecha quando o contexto é cancelado.
- `ctx.Err()` retorna o motivo: `context.Canceled` ou `context.DeadlineExceeded`.

```go
select {
case <-ctx.Done():
    if ctx.Err() == context.DeadlineExceeded {
        fmt.Println("estourou o tempo")
    } else {
        fmt.Println("cancelado manualmente")
    }
}
```

---

## 8. Propagação em camadas
Cada função que recebe um contexto pode criar um filho com timeout próprio. Se o pai for cancelado, os filhos também são.

```go
func handler(ctx context.Context) {
    ctxDB, cancel := context.WithTimeout(ctx, 1*time.Second)
    defer cancel()

    consulta(ctxDB) // se ctx for cancelado, ctxDB também é
}
```

---

## 9. Boas práticas
- **Primeiro parâmetro**: sempre `ctx context.Context`.
- **Nunca guarde context em struct** — passe por argumento.
- **Sempre chame `cancel()`** com defer, mesmo se o contexto já vai expirar sozinho.
- **Não passe `nil`** — use `context.Background()` ou `context.TODO()`.
- **Não use WithValue para tudo** — só para dados de requisição.

---

Em resumo: `context` é o jeito padrão de propagar cancelamento, prazo e valores em operações concorrentes. É essencial em servidores HTTP, RPC, banco de dados, e qualquer coisa que envolva trabalho em background com possibilidade de aborto.
