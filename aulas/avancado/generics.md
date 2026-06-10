# Generics em Go — Resumo simples

Generics permitem escrever uma função ou tipo que funcione com **qualquer tipo**, sem precisar duplicar código. Foram adicionados no Go 1.18.

## 1. Por que existem
Antes do generics, se você quisesse uma função que somasse números, precisava criar uma para `int`, outra para `float64`, outra para `int64`... Com generics, escreve uma só que funciona com todos.

```go
// Antes (código duplicado):
func somarInts(a, b int) int { return a + b }
func somarFloats(a, b float64) float64 { return a + b }

// Com generics (uma só):
func Somar[T int | float64](a, b T) T {
    return a + b
}
```

---

## 2. Type parameters (parâmetros de tipo)
São declarados entre colchetes `[ ]` antes dos parâmetros normais. `T` é só um nome — pode ser qualquer letra ou palavra.

```go
// T é o "parâmetro de tipo"
func Primeiro[T any](lista []T) T {
    return lista[0]
}

// Usando:
n := Primeiro([]int{1, 2, 3})       // T vira int
s := Primeiro([]string{"a", "b"})   // T vira string
```

---

## 3. Constraints (restrições)
É a "regra" que diz quais tipos `T` pode ser. As principais:

- `any` — aceita qualquer tipo (alias para `interface{}`)
- `comparable` — tipos que aceitam `==` e `!=` (não pode ser slice, map ou função)
- União com `|` — lista os tipos permitidos

```go
// Aceita qualquer tipo
func Imprimir[T any](v T) {
    fmt.Println(v)
}

// Só tipos comparáveis (porque usa ==)
func Igual[T comparable](a, b T) bool {
    return a == b
}

// Só números (união explícita)
func Maior[T int | float64](a, b T) T {
    if a > b { return a }
    return b
}
```

---

## 4. Constraints com underlying type (~)
O `~T` significa "qualquer tipo cujo tipo subjacente seja T". Útil quando você tem tipos próprios.

```go
type Idade int        // underlying é int
type Salario int      // underlying é int

// Aceita int e qualquer tipo com underlying int
func Dobrar[T ~int](n T) T {
    return n * 2
}

var i Idade = 10
Dobrar(i)   // funciona graças ao ~int
```

---

## 5. Constraints como interface nomeada
Para reusar uma constraint, dá pra criar uma interface só para isso.

```go
type Numero interface {
    int | int64 | float32 | float64
}

func Somar[T Numero](nums []T) T {
    var total T
    for _, n := range nums {
        total += n
    }
    return total
}
```

---

## 6. Tipos genéricos (struct/slice/map com generics)
Não é só função — você pode criar **tipos** genéricos.

```go
type Pilha[T any] struct {
    itens []T
}

func (p *Pilha[T]) Empilhar(v T) {
    p.itens = append(p.itens, v)
}

func (p *Pilha[T]) Desempilhar() T {
    if len(p.itens) == 0 {
        var zero T
        return zero
    }
    v := p.itens[len(p.itens)-1]
    p.itens = p.itens[:len(p.itens)-1]
    return v
}

// Uso:
p := Pilha[int]{}
p.Empilhar(1)
p.Empilhar(2)
fmt.Println(p.Desempilhar()) // 2
```

---

## 7. Pacote `constraints` (golang.org/x/exp/constraints)
Tem constraints pré-prontas como `Ordered`, `Integer`, `Float`, `Signed`, `Unsigned`. Útil para evitar listar todos os tipos manualmente.

```go
import "golang.org/x/exp/constraints"

func Min[T constraints.Ordered](a, b T) T {
    if a < b { return a }
    return b
}
```

---

## Quando usar (e quando NÃO usar)
- **Use** quando o mesmo algoritmo serve para vários tipos (ex: estrutura de dados, função utilitária como `Filter`/`Map`).
- **Não use** se uma interface resolve. Generics são para algoritmos sobre TIPOS; interfaces são para comportamentos.
- **Não use** se só tem um tipo concreto — gera complexidade desnecessária.

Em resumo: generics tornam Go mais expressivo, mas o código idiomático ainda prefere interfaces para polimorfismo de comportamento. Use generics quando estiver duplicando código que só difere no tipo.
