# Módulo 04 — Funções

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Declarar funções com parâmetros e retornos em Go
- Usar **retornos múltiplos** (jeito clássico do Go pra erro)
- Trabalhar com **retornos nomeados** e quando eles ajudam
- Escrever funções **variádicas** (`...int`) que recebem N argumentos
- Tratar funções como **valores** (passar como parâmetro, guardar em variável)
- Criar **closures** — funções que "lembram" variáveis do contexto
- Usar `defer` pra garantir que algo aconteça no fim

## 🤔 Por que funções importam tanto?
Função é o **tijolo** de um programa. Você quebra um problema grande em pedacinhos pequenos, cada um com um nome e uma responsabilidade. Em Go a sintaxe é enxuta e tem alguns superpoderes que linguagens populares não têm (ou tem de forma esquisita): retornos múltiplos, variádicas e funções de primeira classe.

Pensa assim: se o seu `main` tem 200 linhas, ele é um monstro. Se tem 20 linhas chamando 10 funções, ele é um maestro.

## 🧱 Declarando uma função

```go
func soma(a int, b int) int {
    return a + b
}
```

Anatomia:
- `func` — palavra-chave que inicia a função.
- `soma` — nome (camelCase pra "privado", PascalCase pra "exportado").
- `(a int, b int)` — **parâmetros** com seus tipos.
- `int` (depois do parêntese) — **tipo do retorno**.
- `return a + b` — devolve o valor.

### Atalho: parâmetros do mesmo tipo
Se vários parâmetros têm o mesmo tipo, dá pra agrupar:
```go
func soma(a, b int) int {
    return a + b
}
```
Funciona igualzinho, é só mais limpo.

## 🔁 Retorno múltiplo (o clássico do Go)
Diferente de Python (tupla) ou Java (criar uma classe), Go aceita **retornar várias coisas direto**:

```go
func dividir(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("divisão por zero")
    }
    return a / b, nil
}

resultado, err := dividir(10, 2)
if err != nil {
    fmt.Println("Erro:", err)
    return
}
fmt.Println("Resultado:", resultado)
```

Esse padrão `(valor, erro)` é **a marca registrada do Go**. Você vai ver em toda biblioteca padrão. Não tem `try/catch`: você sempre olha o `err` na linha de baixo.

### Ignorando retorno com `_`
Não precisa de todos os valores? Usa o underscore:
```go
resultado, _ := dividir(10, 2) // ignora o erro (cuidado!)
```

## 🏷️ Retornos nomeados
Você pode dar nome pros valores de retorno. Eles viram variáveis já declaradas dentro da função:

```go
func dividir(a, b float64) (resultado float64, err error) {
    if b == 0 {
        err = fmt.Errorf("divisão por zero")
        return // "naked return" — devolve resultado e err automaticamente
    }
    resultado = a / b
    return
}
```

**Quando usar?** Funções curtas com lógica clara. Em funções longas, naked return vira pesadelo de leitura — evite.

## 📦 Funções variádicas (`...tipo`)
E se você quer somar 3 números? E 5? E 100? Variádica resolve:

```go
func somar(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}

somar(1, 2, 3)           // 6
somar(1, 2, 3, 4, 5)     // 15
somar()                  // 0 (vazio também vale)
```

Dentro da função, `nums` é um **slice** (`[]int`). Pra passar um slice já pronto, usa `...`:
```go
valores := []int{10, 20, 30}
somar(valores...) // 60
```

> 🧠 `fmt.Println` é variádica! Por isso aceita 1, 2 ou 50 argumentos.

## 🎁 Funções como valores
Em Go, função é **um tipo como qualquer outro**. Você pode:

### 1) Guardar em variável
```go
operacao := func(a, b int) int { return a + b }
fmt.Println(operacao(2, 3)) // 5
```

### 2) Passar como parâmetro
```go
func aplicar(a, b int, op func(int, int) int) int {
    return op(a, b)
}

soma := func(x, y int) int { return x + y }
fmt.Println(aplicar(4, 6, soma)) // 10
```

Isso é a base de **callbacks**, **middlewares** e várias outras coisas legais.

### 3) Funções anônimas
Sem nome, criada e usada na hora:
```go
resultado := func(x int) int { return x * x }(5) // 25
```

## 🧠 Closures — funções que "lembram"
Closure é uma função que captura variáveis do escopo onde foi criada:

```go
func contador() func() int {
    contagem := 0
    return func() int {
        contagem++
        return contagem
    }
}

c := contador()
fmt.Println(c()) // 1
fmt.Println(c()) // 2
fmt.Println(c()) // 3
```

A variável `contagem` vive **dentro** da função retornada. Cada chamada de `contador()` cria um contador novo e independente. Mágica útil pra:
- Geradores de IDs
- Estado encapsulado sem usar struct
- Funções "configuráveis" (currying)

## ⏳ `defer` — execute depois, no fim
`defer` adia a execução de uma chamada pro **momento em que a função terminar**:

```go
func exemplo() {
    defer fmt.Println("3. fim")
    fmt.Println("1. começo")
    fmt.Println("2. meio")
}
// Saída:
// 1. começo
// 2. meio
// 3. fim
```

Usos clássicos:
- Fechar arquivo (`defer arquivo.Close()`)
- Fechar conexão de banco
- Liberar trava (`mutex.Unlock`)

### Ordem reversa (LIFO)
Vários `defer` empilham e saem ao contrário:
```go
defer fmt.Println("A")
defer fmt.Println("B")
defer fmt.Println("C")
// Imprime: C, B, A
```

## 💡 Detalhes que valem ouro
- **Função sem retorno** simplesmente omite o tipo: `func saudar(nome string) { ... }`.
- **Maiúscula = exportada**: `Somar` é pública (vista de fora do pacote), `somar` é privada.
- **Sem sobrecarga**: Go não deixa duas funções com o mesmo nome e tipos diferentes. Use nomes claros.
- **Argumentos são passados por valor**: Go copia. Pra modificar o original, usa ponteiros (módulo 09).
- **Não existe parâmetro opcional ou default**: se precisa, use variádica ou uma struct de config.

## 👀 Variações pra você entender melhor

```go
// retorno simples
func dobro(n int) int { return n * 2 }

// sem retorno
func saudar(nome string) { fmt.Println("Oi,", nome) }

// múltiplo retorno
func minMax(a, b int) (int, int) {
    if a < b { return a, b }
    return b, a
}

// variádica
func maior(nums ...int) int {
    m := nums[0]
    for _, n := range nums { if n > m { m = n } }
    return m
}

// closure
multiplicador := func(fator int) func(int) int {
    return func(x int) int { return x * fator }
}
dobrar := multiplicador(2)
triplicar := multiplicador(3)
fmt.Println(dobrar(10), triplicar(10)) // 20 30
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia cada exercício — eles vão do simples ao closure.
2. Rode: `go run ./curso/modulo-04-funcoes/pratica`
3. Mexa nos exercícios. Quebrar é parte do treino.
4. Encare o **desafio**: uma calculadora modular usando funções como valores.

## ✅ Auto-verificação
- [ ] Sei declarar uma função com vários parâmetros e múltiplos retornos
- [ ] Entendo por que Go usa `(valor, error)` no lugar de exceções
- [ ] Sei usar `...int` pra aceitar N argumentos
- [ ] Consigo passar uma função como parâmetro de outra
- [ ] Entendi o que uma closure "lembra"
- [ ] Sei pra que serve `defer` e em qual ordem ele executa

Próximo módulo: **Coleções (arrays, slices e maps)** — onde a gente guarda muitos dados juntos.
