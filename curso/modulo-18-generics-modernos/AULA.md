# Módulo 18 — Generics e Padrões Modernos

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que são **generics** e por que entraram em Go (1.18)
- Escrever funções genéricas com **type parameters** `[T any]`
- Usar **constraints** como `any`, `comparable` e uniões do tipo `~int | ~float64`
- Criar constraints próprias como **interface nomeada**
- Definir **tipos genéricos** (struct, slice) reutilizáveis
- Usar os pacotes modernos `slices` e `maps` da stdlib (Go 1.21+)
- Saber quando usar generics — e, mais importante, **quando NÃO usar**

## 🤔 De onde veio essa história de generics?
Por mais de uma década, Go viveu sem generics. A filosofia era "interfaces resolvem tudo". E até resolviam — mas com tropeços: pra fazer uma função `Min` que servisse pra `int`, `float64` e `string`, você tinha três opções, todas ruins:

1. Escrever **três funções quase iguais** (`MinInt`, `MinFloat`, `MinString`).
2. Usar `interface{}` (hoje `any`) e fazer **type assertions** em tudo — adeus segurança de tipo.
3. Aceitar que Go não era pra esse tipo de problema e usar outra linguagem. 😬

Em **Go 1.18 (2022)** chegaram os generics. A ideia é simples: a função fica parametrizada não só por **valor**, mas também por **tipo**. O compilador faz o resto.

```go
// Antes: três funções
func MinInt(a, b int) int       { if a < b { return a }; return b }
func MinFloat(a, b float64) float64 { if a < b { return a }; return b }

// Com generics: uma só, e funciona pra qualquer tipo "ordenável"
func Min[T cmp.Ordered](a, b T) T {
    if a < b {
        return a
    }
    return b
}
```

## 🧩 Type parameters — a sintaxe `[T any]`
O coração da coisa: antes dos parâmetros normais, você declara os **parâmetros de tipo** entre colchetes.

```go
func Primeiro[T any](lista []T) T {
    return lista[0]
}
```

Quebrando:
- `[T any]` — declaramos um parâmetro de tipo chamado `T`, que pode ser **qualquer tipo** (`any` é a constraint mais permissiva).
- `lista []T` — o parâmetro `lista` é uma slice de `T`.
- `T` no retorno — devolvemos um valor do mesmo tipo dos elementos.

Usando:
```go
n := Primeiro([]int{10, 20, 30})         // T = int, devolve 10
s := Primeiro([]string{"a", "b", "c"})   // T = string, devolve "a"
```

Você quase nunca precisa escrever `Primeiro[int](...)` — o compilador **infere** o tipo a partir do argumento.

> Convenção: usa-se `T`, `U`, `V` para "tipo qualquer". Nada te impede de chamar de `Elemento`, mas o pessoal lê `T` mais rápido.

## 🚧 Constraints — quem pode entrar nessa festa
Sem constraint, `T` é literalmente qualquer coisa. Aí você não pode **fazer nada** com ele (nem comparar com `==`, nem somar, nada). As constraints são **regras** que dizem "T precisa pelo menos ser X".

### `any` — qualquer coisa
```go
func Imprimir[T any](v T) {
    fmt.Println(v) // só dá pra fazer coisas que servem pra tudo
}
```

### `comparable` — tipos que aceitam `==` e `!=`
```go
func Contem[T comparable](lista []T, alvo T) bool {
    for _, v := range lista {
        if v == alvo { // só funciona porque T é comparable
            return true
        }
    }
    return false
}
```
Tipos comparáveis: números, strings, bools, ponteiros, structs sem campos não-comparáveis, arrays. **Não** são comparáveis: slices, maps, funções.

### União com `|` — uma lista fechada
Quando você quer só números, por exemplo:

```go
func Dobrar[T int | float64](n T) T {
    return n * 2
}
```

### `~` — "qualquer tipo cujo underlying é esse"
Imagina que você criou:
```go
type Idade int
```
`Idade` **não é** `int`, é um tipo diferente — mas tem o mesmo "tipo subjacente". Se você escrever `[T int]`, `Idade` é rejeitado. Com `[T ~int]`, é aceito:

```go
func Dobrar[T ~int | ~float64](n T) T {
    return n * 2
}
```

A regra prática: **use `~` quando achar que vão te passar tipos derivados**. Pra constraints utilitárias, é quase sempre a escolha certa.

## 🪪 Constraints como interface nomeada
Repetir `int | float64 | int64 | float32 | ...` várias vezes é chato. Dá pra criar uma interface que **só serve como constraint**:

```go
type Numero interface {
    ~int | ~int64 | ~float32 | ~float64
}

func Soma[T Numero](nums []T) T {
    var total T // zero value de T (0 pra números)
    for _, n := range nums {
        total += n
    }
    return total
}
```

Repare que essa "interface" nunca vai virar variável (não dá pra fazer `var x Numero`). Ela existe **só como restrição** sobre `T`.

## 🧱 Tipos genéricos — struct, slice, etc
Generics não são só pra funções. **Tipos** também podem ser genéricos:

```go
type Pilha[T any] struct {
    itens []T
}

func (p *Pilha[T]) Empilhar(v T) {
    p.itens = append(p.itens, v)
}

func (p *Pilha[T]) Desempilhar() (T, bool) {
    var zero T
    if len(p.itens) == 0 {
        return zero, false
    }
    v := p.itens[len(p.itens)-1]
    p.itens = p.itens[:len(p.itens)-1]
    return v, true
}
```

Uso:
```go
p := Pilha[int]{}        // pilha de int
p.Empilhar(1)
p.Empilhar(2)
v, ok := p.Desempilhar() // v=2, ok=true

ps := Pilha[string]{}    // pilha de string, mesmo código
```

Note duas coisas:
- Em **métodos**, o `T` da pilha aparece como `Pilha[T]` no receiver. Não precisa redeclarar `[T any]` no método.
- Pra **criar** a pilha, você precisa dizer o tipo (`Pilha[int]{}`). Aqui o compilador não infere — quem ia chutar?

## 📦 Pacote `slices` (Go 1.21+)
Antes de 1.21, escrever `Sort`, `Contains`, `Index` em slice era exercício de aula. Hoje a stdlib já entrega — usando generics por baixo.

```go
import "slices"

nums := []int{3, 1, 4, 1, 5, 9, 2, 6}

slices.Sort(nums)                  // ordena in-place
fmt.Println(nums)                  // [1 1 2 3 4 5 6 9]

fmt.Println(slices.Contains(nums, 5)) // true
fmt.Println(slices.Index(nums, 4))    // posição do 4 (ou -1)

palavras := []string{"go", "rust", "zig"}
slices.Sort(palavras)              // funciona com string também
```

Outros muito úteis:
- `slices.Reverse(s)` — inverte
- `slices.Min(s)` / `slices.Max(s)` — mínimo/máximo
- `slices.Equal(a, b)` — compara duas slices

## 🗺️ Pacote `maps` (Go 1.21+)
Mesma ideia, pra maps:

```go
import "maps"

m := map[string]int{"a": 1, "b": 2, "c": 3}

for k := range maps.Keys(m) {      // itera só pelas chaves
    fmt.Println(k)
}

for v := range maps.Values(m) {    // itera só pelos valores
    fmt.Println(v)
}
```

> Atenção: a ordem das chaves num map é **aleatória**. Se quiser ordem, colete num slice e ordene com `slices.Sort`.

## 🆕 `min` e `max` como built-in
Desde Go 1.21, `min` e `max` são **funções embutidas** (não precisam de import) e aceitam tipos ordenáveis (números, strings):

```go
fmt.Println(min(3, 7))          // 3
fmt.Println(max(1.5, 2.5, 0.9)) // 2.5 (aceita N argumentos)
fmt.Println(min("ana", "bia"))  // ana
```

Por baixo dos panos, é generics. Por cima, é só usar.

## 🧠 Quando usar generics
**Bons casos:**
- Estruturas de dados (pilha, fila, árvore, cache) que precisam guardar qualquer tipo.
- Funções utilitárias sobre coleções: `Map`, `Filter`, `Reduce`, `Distintos`, `Agrupar`.
- Algoritmos numéricos que devem servir pra `int`, `float64`, etc.
- Tipos que envolvem **pares** ou **resultado + erro genérico** (ex: `Result[T]`).

## 🚫 Quando NÃO usar
- **Quando uma interface resolve.** Se você quer "qualquer coisa que sabe se imprimir", isso é `fmt.Stringer`, não generics.
- **Quando só existe um tipo concreto.** Generics aí é pura complexidade sem ganho.
- **Quando o código fica menos legível.** Generics é uma ferramenta — não um troféu pra colecionar.
- **Em assinaturas de API pública sem necessidade.** O usuário vai pagar em legibilidade.

A regra do bolso: **se você está duplicando código que só difere no tipo, generics é a resposta. Caso contrário, provavelmente não.**

## 💡 Detalhes que valem ouro
- O **zero value** de `T` se obtém com `var zero T`. Útil pra `Desempilhar` de pilha vazia, "não encontrado", etc.
- Generics **não suportam métodos** com type parameters extras (você não pode declarar `func (p *Pilha[T]) Para[U any](...)`). Use uma função-livre.
- Comparar genericamente com `<` exige `cmp.Ordered` (do pacote `cmp`, Go 1.21+) ou listar os tipos manualmente.
- A inferência de tipo é boa, mas **às vezes falha**. Quando falhar, escreva o tipo: `Map[int, string](nums, paraTexto)`.
- Generics são compilados (não usam reflection). O custo em tempo de execução é **zero** comparado a versões específicas.

## 👀 Comparando: antes × depois

```go
// ===== Sem generics (Go pré-1.18) =====
func ContemInt(lista []int, alvo int) bool {
    for _, v := range lista {
        if v == alvo { return true }
    }
    return false
}
func ContemString(lista []string, alvo string) bool {
    for _, v := range lista {
        if v == alvo { return true }
    }
    return false
}

// ===== Com generics =====
func Contem[T comparable](lista []T, alvo T) bool {
    for _, v := range lista {
        if v == alvo { return true }
    }
    return false
}
```

Uma função onde antes existiam N. E sem `interface{}`, sem assertion, com checagem completa em tempo de compilação.

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia os exercícios resolvidos com calma. Cada um introduz uma peça nova.
2. Rode: `go run ./curso/modulo-18-generics-modernos/pratica`
3. Mexa nos exemplos: troque o tipo, adicione mais um caso, quebre e conserte.
4. Encare o **desafio**: a **Biblioteca Utilitária Genérica** — sua "stdlib" pessoal.

## ✅ Auto-verificação
- [ ] Sei o que `[T any]` significa e por que é necessário
- [ ] Diferencio `any`, `comparable` e união com `|`
- [ ] Entendo pra que serve o `~` em `~int`
- [ ] Sei criar uma constraint como interface nomeada
- [ ] Sei criar um tipo genérico (struct) e seus métodos
- [ ] Já usei `slices.Sort`, `slices.Contains` ou `maps.Keys` pelo menos uma vez
- [ ] Sei explicar **um caso onde não vale a pena usar generics**

Próximo módulo: **Testes em Go** — onde tudo que você escreveu até agora vai ganhar uma rede de segurança chamada `go test`.
