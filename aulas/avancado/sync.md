# Pacote sync — Resumo simples

Quando várias goroutines mexem nos MESMOS dados ao mesmo tempo, dá ruim — é a chamada **race condition**. O pacote `sync` traz ferramentas para evitar isso, complementando os channels.

## 1. Por que precisar de sincronização
Sem proteção, duas goroutines incrementando um contador podem produzir resultados errados:

```go
var contador int
for i := 0; i < 1000; i++ {
    go func() { contador++ }()
}
// contador pode ser MENOR que 1000 — leituras e escritas se misturam
```

---

## 2. Mutex — trava de exclusão mútua
Mutex (Mutual Exclusion) garante que só uma goroutine por vez entre numa "região crítica".

```go
import "sync"

var (
    contador int
    mu       sync.Mutex
)

func incrementar() {
    mu.Lock()         // trava
    defer mu.Unlock() // sempre destrava no final
    contador++
}
```

Use sempre `defer mu.Unlock()` pra garantir o destravamento mesmo se der panic.

---

## 3. RWMutex — várias leituras simultâneas, uma escrita
Quando você lê MUITO mais do que escreve, RWMutex é mais eficiente:
- `RLock()`/`RUnlock()`: várias leituras podem rodar juntas.
- `Lock()`/`Unlock()`: bloqueia tudo para uma escrita exclusiva.

```go
var rw sync.RWMutex
var dados = make(map[string]string)

func ler(chave string) string {
    rw.RLock()
    defer rw.RUnlock()
    return dados[chave]
}

func escrever(chave, valor string) {
    rw.Lock()
    defer rw.Unlock()
    dados[chave] = valor
}
```

---

## 4. WaitGroup — esperar várias goroutines terminarem
Quando você dispara várias goroutines e precisa esperar todas acabarem.

```go
var wg sync.WaitGroup

for i := 0; i < 5; i++ {
    wg.Add(1)  // sinaliza "vai começar mais uma"
    go func(id int) {
        defer wg.Done() // sinaliza "esta acabou"
        fmt.Println("worker", id)
    }(i)
}

wg.Wait() // bloqueia até Add ficar zerado
fmt.Println("Todas terminaram")
```

Regras:
- `Add(n)` antes de disparar a goroutine.
- `Done()` dentro da goroutine (com defer).
- `Wait()` espera tudo voltar a zero.

---

## 5. Once — executar apenas uma vez
Garante que um código rode UMA única vez, mesmo se chamado por várias goroutines. Clássico para inicialização.

```go
var (
    once    sync.Once
    config  map[string]string
)

func carregarConfig() {
    once.Do(func() {
        fmt.Println("carregando config (só uma vez)")
        config = map[string]string{"ambiente": "prod"}
    })
}

// Chamar várias vezes, mas a função interna só roda uma vez
carregarConfig()
carregarConfig()
```

---

## 6. Map — map seguro para concorrência
`sync.Map` é um map já preparado para acesso concorrente. Use quando muitas goroutines leem/escrevem.

```go
var cache sync.Map

cache.Store("chave", 42)
v, ok := cache.Load("chave")
cache.Delete("chave")

cache.Range(func(k, v any) bool {
    fmt.Println(k, v)
    return true // continuar
})
```

Atenção: `sync.Map` só vale a pena em casos específicos (muitas leituras, poucas escritas). Pra uso normal, um `map` com `RWMutex` costuma ser melhor.

---

## 7. Pool — reutilizar objetos
`sync.Pool` é um cache de objetos descartáveis. Reduz pressão no garbage collector.

```go
var bufferPool = sync.Pool{
    New: func() any {
        return new(bytes.Buffer)
    },
}

buf := bufferPool.Get().(*bytes.Buffer)
buf.Reset()
// ... usar buf ...
bufferPool.Put(buf) // devolve pro pool
```

---

## 8. atomic — operações atômicas em primitivos
Para incrementos simples em inteiros, `sync/atomic` é mais rápido que Mutex.

```go
import "sync/atomic"

var contador int64
atomic.AddInt64(&contador, 1)
v := atomic.LoadInt64(&contador)
```

---

## 9. Detectar race conditions
Rode os testes ou o programa com `-race`:

```bash
go run -race main.go
go test -race ./...
```

Ele aponta se duas goroutines acessam a mesma variável sem sincronização.

---

## 10. Channel vs Mutex — qual usar?
Regra de ouro do Go: **prefira channel** quando o problema é comunicação entre goroutines (passar dados, sinalizar). **Use Mutex** quando o problema é proteger um estado compartilhado pequeno (um contador, um cache).

---

Em resumo: `sync` é a caixa de ferramentas para sincronização. Mutex protege regiões críticas, WaitGroup espera goroutines, Once garante execução única, Pool reaproveita objetos. Combinado com channels e o detector `-race`, dá pra escrever código concorrente seguro.
