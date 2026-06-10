# Módulo 09 — Ponteiros

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é um ponteiro e por que ele existe
- Pegar o endereço de uma variável com `&` e ler o valor com `*` (dereferência)
- Diferenciar **passagem por valor** (cópia) de **passagem por ponteiro** (referência)
- Escrever métodos com **receiver de ponteiro** e saber quando preferi-los
- Criar valores com `new()` e entender o que é um ponteiro `nil`
- Decidir, com critério, quando usar ponteiro e quando não usar

## 🤔 O que é um ponteiro?
Toda variável que você cria mora em algum lugar da memória do computador. Esse "lugar" tem um **endereço** — tipo o número de uma casa numa rua.

Um **ponteiro** é simplesmente uma variável que, em vez de guardar um valor (tipo `42` ou `"David"`), guarda o **endereço de memória** onde outro valor está.

Imagine assim:
- Variável normal: "tem o número 42 dentro dela".
- Ponteiro: "tem um papelzinho com a anotação: o 42 está no endereço 0xC0000140A0".

Por que isso é útil?
- Permite que uma função **modifique** uma variável que está em outro lugar (sem precisar devolver uma cópia).
- Evita copiar estruturas grandes toda hora (mais rápido, menos memória).
- Permite construir estruturas que apontam umas para as outras (listas, árvores, grafos).

## 🧱 Pegando o endereço (`&`) e dereferenciando (`*`)

```go
x := 10
p := &x       // p é um ponteiro para x (guarda o endereço de x)

fmt.Println(x)    // 10  — valor de x
fmt.Println(&x)   // 0xc0000... — endereço de x
fmt.Println(p)    // mesmo endereço acima
fmt.Println(*p)   // 10  — "dereferenciar" p, ou seja, ir até o endereço e ler o valor

*p = 20           // muda o valor que está NAQUELE endereço
fmt.Println(x)    // 20  — x mudou porque p apontava pra ele!
```

Resumo dos dois operadores:
- `&variavel` → **pega o endereço** da variável (cria um ponteiro).
- `*ponteiro` → **acessa o valor** que está naquele endereço (dereferência).

E o **tipo** de um ponteiro se escreve com `*` antes do tipo apontado:
```go
var p *int    // p é "ponteiro para int"
var s *string // ponteiro para string
```

## 📦 Passar por valor vs por ponteiro

Por padrão, em Go, **tudo que você passa para uma função é uma cópia**. A função mexe na cópia, e a variável original não muda.

```go
func dobraValor(n int) {
    n = n * 2 // muda só a CÓPIA
}

func dobraPonteiro(n *int) {
    *n = *n * 2 // vai até o endereço e muda o valor REAL
}

func main() {
    x := 5
    dobraValor(x)
    fmt.Println(x) // 5 — não mudou!

    dobraPonteiro(&x)
    fmt.Println(x) // 10 — mudou de verdade!
}
```

A regra é simples: **se você quer que a função modifique a variável original, passe um ponteiro**.

## 🛠️ Métodos com receiver de ponteiro

Quando você cria métodos em uma struct, o `receiver` pode ser por valor ou por ponteiro:

```go
type Contador struct {
    valor int
}

// receiver por VALOR — recebe uma cópia, NÃO altera o original
func (c Contador) IncrementarValor() {
    c.valor++ // só mexe na cópia
}

// receiver por PONTEIRO — altera o original
func (c *Contador) IncrementarPonteiro() {
    c.valor++ // mexe na struct de verdade
}

func main() {
    c := Contador{valor: 0}
    c.IncrementarValor()
    fmt.Println(c.valor) // 0 — não mudou

    c.IncrementarPonteiro()
    fmt.Println(c.valor) // 1 — mudou!
}
```

**Detalhe legal**: você pode chamar `c.IncrementarPonteiro()` mesmo `c` não sendo ponteiro — Go automaticamente faz `(&c).IncrementarPonteiro()` por baixo dos panos.

### Convenção do mundo Go
- Se o método **modifica** o receiver → use `*T`.
- Se a struct é **grande** (várias dezenas de bytes) → use `*T` para evitar cópia.
- **Seja consistente**: se um método usa ponteiro, geralmente todos usam.

## 🕳️ Ponteiro `nil`

Um ponteiro que não aponta para nada vale `nil`. Tentar dereferenciar (`*p`) um ponteiro `nil` **quebra o programa** (panic).

```go
var p *int          // p é nil (zero value de ponteiro)
fmt.Println(p)      // <nil>

// fmt.Println(*p)  // 💥 PANIC: nil pointer dereference

if p != nil {
    fmt.Println(*p) // só dereferencia se for seguro
}
```

Sempre **cheque `!= nil`** antes de dereferenciar um ponteiro que pode estar vazio.

## 🆕 `new()` — criando valores pelo ponteiro

`new(T)` aloca um espaço na memória para um valor do tipo `T`, zera ele e devolve **um ponteiro** para esse espaço.

```go
p := new(int)    // p é *int apontando para um int zerado
fmt.Println(*p)  // 0
*p = 42
fmt.Println(*p)  // 42
```

Na prática, `new()` é pouco usado. A maioria das pessoas escreve assim, que é equivalente:
```go
x := 0
p := &x
```
Ou, para structs, usa o literal direto:
```go
p := &Pessoa{Nome: "David"}  // mais comum que new(Pessoa)
```

## 🤷 Quando usar ponteiro? (e quando NÃO usar)

**USE ponteiro quando:**
- A função precisa **modificar** a variável recebida.
- A struct é **grande** e copiá-la custa caro.
- Você quer expressar "isso pode ser nil" (ausência de valor).
- Está construindo estruturas ligadas (lista, árvore, grafo).

**NÃO use ponteiro quando:**
- O valor é pequeno (int, bool, float, string curta) e a função só lê.
- A simplicidade do código importa mais que micro-otimização.
- Você ainda não tem motivo concreto — comece simples.

Slices, maps e channels já são **referências internamente**. Quase nunca você passa `*[]int` ou `*map[string]int` — passa o próprio slice/map.

## 💡 Detalhes que valem ouro
- Go **não tem aritmética de ponteiros** (diferente de C). Você não pode fazer `p++` para "andar" na memória. Isso evita um monte de bug.
- O garbage collector cuida da memória: não existe `free()` ou `delete` manual.
- Não dá pra ter ponteiro pra "pedaço de variável" — só pra variáveis inteiras.
- `*` em **tipo** (`var p *int`) e `*` em **expressão** (`*p = 5`) são coisas diferentes, mesmo usando o mesmo símbolo. Vai do contexto.

## 👀 Exemplo completo

```go
package main

import "fmt"

type Pessoa struct {
    Nome  string
    Idade int
}

func envelhecer(p *Pessoa) {
    p.Idade++ // mexe na pessoa de verdade
}

func main() {
    david := Pessoa{Nome: "David", Idade: 30}
    envelhecer(&david)
    fmt.Println(david) // {David 31}
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e percorra os exercícios com calma — preste atenção em quando o valor muda e quando não.
2. Rode: `go run ./curso/modulo-09-ponteiros/pratica`
3. Encare o **desafio**: implementar uma **Lista Encadeada** — o exemplo clássico onde ponteiros brilham.

## ✅ Auto-verificação
- [ ] Sei explicar a diferença entre `&` e `*`
- [ ] Consigo escrever uma função que modifica a variável do chamador via ponteiro
- [ ] Sei quando usar receiver de ponteiro em métodos
- [ ] Sei o que é um ponteiro `nil` e como evitar o panic
- [ ] Entendo por que slices e maps não precisam de ponteiro normalmente

Próximo módulo: **Estruturas de Dados Encadeadas** — onde ponteiros saem do papel.
