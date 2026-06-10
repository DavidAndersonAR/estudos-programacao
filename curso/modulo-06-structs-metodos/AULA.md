# Módulo 06 — Structs e Métodos

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Definir um tipo próprio usando `type Nome struct { ... }`
- Criar valores de struct com literal nomeado e posicional
- Acessar e modificar campos com `.`
- Aninhar uma struct dentro de outra (composição)
- Escrever métodos com receiver de **valor** e de **ponteiro** — e saber qual escolher
- Entender quando uma struct pode ser `nil` e como evitar pânico
- Diferenciar campos **exportados** (maiúscula) de **não exportados** (minúscula)

## 🤔 Pra quê servem structs?
Até aqui você guardou dados em variáveis soltas: `nome`, `idade`, `email`. Mas e quando esses três pertencem à **mesma pessoa**? Andar com eles separados é convite a bug.

Uma **struct** é um molde: você diz "uma Pessoa tem nome, idade e email", e a partir daí o Go entende que esses campos andam juntos. É o equivalente, em outras linguagens, a uma "classe simples" (sem herança, sem `new`, sem nada complicado).

Em Go, structs + funções (métodos) substituem boa parte do que outras linguagens chamam de "orientação a objetos". Mais simples, mais previsível.

## 🧱 Definindo uma struct

```go
type Pessoa struct {
    Nome  string
    Idade int
    Email string
}
```

Isso **declara o tipo** — ainda não criou ninguém. É como uma planta de casa: o desenho existe, mas a casa ainda precisa ser construída.

### Criando valores

**Literal nomeado** (recomendado — fica claro qual campo é qual):
```go
p := Pessoa{
    Nome:  "Ana",
    Idade: 28,
    Email: "ana@email.com",
}
```

**Literal posicional** (na ordem da declaração — frágil, quebra se você reordenar campos):
```go
p := Pessoa{"Ana", 28, "ana@email.com"}
```

**Zero value** (todos os campos com o valor zero do tipo):
```go
var p Pessoa
// p.Nome  == ""
// p.Idade == 0
// p.Email == ""
```

Em Go, **nada fica "indefinido"**. Todo tipo tem um valor zero seguro.

### Acessando campos
```go
fmt.Println(p.Nome)   // "Ana"
p.Idade = 29          // pode modificar
```

## 🏠 Struct dentro de struct (composição)

Em vez de herança, Go faz **composição**: uma struct contém outra.

```go
type Endereco struct {
    Rua    string
    Cidade string
    UF     string
}

type Pessoa struct {
    Nome     string
    Endereco Endereco // campo do tipo Endereco
}

p := Pessoa{
    Nome: "Ana",
    Endereco: Endereco{
        Rua:    "Rua A, 100",
        Cidade: "São Paulo",
        UF:     "SP",
    },
}

fmt.Println(p.Endereco.Cidade) // "São Paulo"
```

Cada nível usa um `.` — leitura natural.

## ⚙️ Métodos: funções com receiver

Um **método** é uma função "amarrada" a um tipo. A sintaxe quase igual à de função, com um pedaço extra antes do nome: o **receiver**.

```go
type Retangulo struct {
    Largura float64
    Altura  float64
}

// (r Retangulo) é o receiver — diz "este método pertence a Retangulo"
func (r Retangulo) Area() float64 {
    return r.Largura * r.Altura
}

ret := Retangulo{Largura: 3, Altura: 4}
fmt.Println(ret.Area()) // 12
```

Pense no receiver como o `self`/`this` de outras linguagens — só que **explícito** (você escolhe o nome) e **com tipo** (você escolhe valor ou ponteiro).

## 🎯 O grande dilema: receiver de valor vs receiver de ponteiro

Essa é **a** decisão importante do módulo. Preste atenção.

### Receiver de valor — `func (r Retangulo)`
- O método recebe uma **cópia** da struct
- Modificações feitas dentro do método **não afetam** o original
- Bom para métodos que só **leem** dados (Area, Perimetro, String...)

```go
func (r Retangulo) Escalar(fator float64) {
    r.Largura *= fator // muda só a cópia!
}

ret := Retangulo{Largura: 3, Altura: 4}
ret.Escalar(2)
fmt.Println(ret.Largura) // 3 — não mudou!
```

### Receiver de ponteiro — `func (r *Retangulo)`
- O método recebe um **endereço** para a struct
- Modificações **persistem** no original
- Bom para métodos que **modificam** estado (Depositar, Sacar, Set*, ...)

```go
func (r *Retangulo) Escalar(fator float64) {
    r.Largura *= fator // muda o original
    r.Altura  *= fator
}

ret := Retangulo{Largura: 3, Altura: 4}
ret.Escalar(2)
fmt.Println(ret.Largura) // 6 — mudou!
```

### Regra prática
> **Vai modificar?** Use `*T`.
> **Struct grande (muitos campos)?** Use `*T` (evita copiar tudo).
> **Mistura num mesmo tipo?** Mantenha **consistência** — ou todos com `*T`, ou todos com `T`.

Você **chama do mesmo jeito** nos dois casos: `ret.Escalar(2)`. O Go faz o `&` automático quando precisa.

## 🛡️ Cuidado com `nil`

Quando você trabalha com **ponteiros para struct**, eles podem ser `nil`:

```go
var p *Pessoa            // p é nil!
fmt.Println(p.Nome)      // PÂNICO: nil pointer dereference
```

Antes de usar um ponteiro, **verifique**:
```go
if p != nil {
    fmt.Println(p.Nome)
}
```

Métodos com receiver de ponteiro podem ser chamados em `nil` sem panicar — **mas só se o método não acessar campos**:
```go
func (p *Pessoa) Existe() bool {
    return p != nil
}

var p *Pessoa
fmt.Println(p.Existe()) // false — funciona!
```

## 🔒 Exported vs unexported

A regra das maiúsculas vale para campos também:
- `Nome` (maiúscula) → **exportado** — outros pacotes enxergam
- `senha` (minúscula) → **não exportado** — só este pacote enxerga

```go
type Usuario struct {
    Nome  string // público
    senha string // privado deste pacote
}
```

Isso é o "private/public" do Go — sem palavra-chave, só capitalização. Use **maiúscula** quando o campo faz parte da "interface" da struct; **minúscula** quando é detalhe interno.

## 💡 Detalhes que valem ouro
- Structs em Go são **valores**, não referências. `b := a` faz uma cópia (a menos que você use ponteiro).
- Comparação com `==` funciona se **todos** os campos forem comparáveis. Útil para testar igualdade.
- `fmt.Printf("%+v\n", p)` imprime a struct com os nomes dos campos — ótimo pra debugar.
- Construtores em Go são **funções normais**, geralmente chamadas `NovaPessoa`, `NewPessoa`, etc. Não existe `new` mágico como em Java.
- Você pode declarar métodos em **qualquer tipo do seu pacote**, não só structs (`type Idade int` + `func (i Idade) Maior() bool`).

## 👀 Tudo junto, exemplo curto

```go
package main

import "fmt"

type Conta struct {
    Titular string
    Saldo   float64
}

// Receiver de ponteiro: vai modificar o Saldo
func (c *Conta) Depositar(v float64) {
    c.Saldo += v
}

// Receiver de valor: só lê
func (c Conta) Resumo() string {
    return fmt.Sprintf("%s tem R$ %.2f", c.Titular, c.Saldo)
}

func main() {
    c := Conta{Titular: "Ana", Saldo: 100}
    c.Depositar(50)
    fmt.Println(c.Resumo()) // "Ana tem R$ 150.00"
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e estude cada exercício.
2. Rode: `go run ./curso/modulo-06-structs-metodos/pratica`
3. Mexa no código: troque um receiver de valor por ponteiro e veja o que muda.
4. Encare o **desafio**: um Sistema Bancário Simples.

## ✅ Auto-verificação
- [ ] Sei declarar uma struct e criar valores com literal nomeado
- [ ] Sei a diferença entre receiver de valor e de ponteiro — e sei quando usar cada um
- [ ] Sei aninhar uma struct dentro de outra e acessar campos com `.`
- [ ] Entendi por que `nil` em ponteiro pode quebrar o programa
- [ ] Sei o que muda quando troco `Nome` por `nome` num campo

Próximo módulo: **Interfaces** — onde você vai aprender a falar "este tipo se comporta como X" sem precisar herdar nada.
