# Módulo 08 — Tratamento de Erros

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender que erro em Go é um **valor**, não uma exceção
- Retornar erros como **último valor** da função (convenção)
- Usar o padrão `if err != nil { ... }` sem se assustar com ele
- Criar erros simples com `errors.New` e formatados com `fmt.Errorf`
- Embrulhar erros com `%w` e desembrulhar com `errors.Is` e `errors.As`
- Criar **tipos próprios de erro** (struct com método `Error()`)
- Saber o que são `panic` e `recover` — e por que você quase nunca deve usá-los

## 🤔 Por que erros em Go são diferentes?
Em Python, Java, C#, JavaScript... quando algo dá errado, o código "joga uma exceção" e o programa salta para um `try/catch` mais acima. É invisível: olhando a função, você nem sabe que ela pode falhar.

Go faz o oposto: **erro é um valor de retorno comum**. A função te devolve o resultado **e** um erro junto. Se deu certo, o erro é `nil`. Se deu errado, o erro tem conteúdo.

```go
resultado, err := dividir(10, 0)
if err != nil {
    fmt.Println("Deu ruim:", err)
    return
}
fmt.Println(resultado)
```

Parece verboso (porque é), mas tem três vantagens:
- **Explícito**: olhando a assinatura `func dividir(a, b int) (int, error)`, você sabe que pode falhar.
- **Sem surpresa**: nada pula 5 funções pra cima sem aviso.
- **Composição**: erro é só um valor, dá pra comparar, embrulhar, transportar.

## 🧱 A interface `error`
No coração de tudo está uma interface minúscula:

```go
type error interface {
    Error() string
}
```

Qualquer coisa que tenha um método `Error() string` **é** um erro. Só isso. Toda a maquinaria de erros do Go gira em torno disso.

O valor `nil` significa "nenhum erro". Por isso o `if err != nil` é o pão com manteiga de Go.

## ✍️ Criando erros simples

### `errors.New` — mensagem fixa
Quando a mensagem nunca muda:

```go
import "errors"

var ErrSaldoInsuficiente = errors.New("saldo insuficiente")

func sacar(saldo, valor float64) (float64, error) {
    if valor > saldo {
        return saldo, ErrSaldoInsuficiente
    }
    return saldo - valor, nil
}
```

Repare no nome: a convenção em Go é começar com `Err...` para erros "sentinela" (constantes públicas que você compara depois).

### `fmt.Errorf` — mensagem com formatação
Quando você quer incluir dados na mensagem:

```go
import "fmt"

func buscarUsuario(id int) error {
    return fmt.Errorf("usuário %d não encontrado", id)
}
```

`fmt.Errorf` funciona como `fmt.Printf`, só que devolve um `error` em vez de imprimir.

## 🧅 Embrulhando erros com `%w`
Muitas vezes você pega um erro de uma função e quer **adicionar contexto** sem perder o erro original. Para isso existe o verbo especial `%w` (de *wrap*, embrulhar):

```go
func lerConfig(caminho string) error {
    dados, err := os.ReadFile(caminho)
    if err != nil {
        return fmt.Errorf("ler config %q: %w", caminho, err)
    }
    // ... usa dados ...
    _ = dados
    return nil
}
```

A mensagem fica algo como `ler config "app.toml": open app.toml: no such file or directory`. E o erro **interno** continua acessível.

### `errors.Is` — comparar com um erro conhecido
Para perguntar "esse erro **é** (ou contém) o `ErrNaoEncontrado`?":

```go
err := lerConfig("app.toml")
if errors.Is(err, os.ErrNotExist) {
    fmt.Println("arquivo não existe, criando padrão...")
}
```

`errors.Is` segue a cadeia de `%w` automaticamente. Comparar com `==` direto **não funciona** em erro embrulhado — sempre use `errors.Is`.

### `errors.As` — extrair um tipo específico
Para perguntar "tem algum erro do tipo X aí dentro?" e pegá-lo:

```go
var erroPath *os.PathError
if errors.As(err, &erroPath) {
    fmt.Println("problema com o caminho:", erroPath.Path)
}
```

`errors.As` desempacota o erro embrulhado e, se encontrar um do tipo pedido, preenche a variável.

## 🏗️ Tipos próprios de erro
Para erros que **carregam informação estruturada** (não só uma mensagem), crie um `struct` e dê a ele um método `Error()`:

```go
type ErroValidacao struct {
    Campo    string
    Mensagem string
}

func (e *ErroValidacao) Error() string {
    return fmt.Sprintf("validação falhou em %q: %s", e.Campo, e.Mensagem)
}

// Uso:
func validarIdade(idade int) error {
    if idade < 0 {
        return &ErroValidacao{Campo: "idade", Mensagem: "não pode ser negativa"}
    }
    return nil
}
```

Quem chama pode tanto **ler a mensagem** quanto **extrair o campo** com `errors.As`:

```go
err := validarIdade(-1)
var ev *ErroValidacao
if errors.As(err, &ev) {
    fmt.Println("campo problemático:", ev.Campo)
}
```

> **Por convenção**, o método `Error()` é definido sobre o ponteiro (`*ErroValidacao`), e você retorna `&ErroValidacao{...}`. Isso evita comparações estranhas e funciona bem com `errors.As`.

## 💥 `panic` e `recover` — o último recurso

### `panic` — "parar tudo agora"
`panic` interrompe o fluxo normal. A função para, as funções acima também param (executando `defer`s pelo caminho), e o programa morre com uma mensagem feia.

```go
func dividir(a, b int) int {
    if b == 0 {
        panic("divisão por zero")
    }
    return a / b
}
```

### `recover` — pegar um panic em pleno voo
Dentro de um `defer`, `recover()` consegue capturar um panic e impedir que o programa morra:

```go
func executarSemMorrer() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("recuperado de:", r)
        }
    }()
    dividir(10, 0) // panic!
    fmt.Println("essa linha não vai rodar")
}
```

### Quando usar (e quando NÃO usar)
- **NÃO use** para fluxo normal de erro (entrada inválida, arquivo faltando, validação...). Para isso, **retorne `error`**.
- **Use `panic`** só em situações verdadeiramente excepcionais: estado interno corrompido, bug do programador, falha de inicialização que torna o programa inutilizável.
- **Use `recover`** em borda de servidor/biblioteca: ex.: servidor HTTP que não pode morrer por causa de um handler bugado.

A regra prática: se você ficar tentado a usar `panic` para "controle de fluxo", pare e devolva um `error`.

## 💡 Detalhes que valem ouro
- Erro é **sempre o último** valor retornado. `(int, error)`, `(string, error)`, etc.
- Não ignore erros com `_ = err` por preguiça. Trate, faça log, ou retorne.
- `if err != nil { return ..., err }` repete bastante — relaxa, isso é Go.
- Erros sentinela: `var ErrAlgo = errors.New("...")` no topo do pacote. Compare com `errors.Is`.
- Para tipos próprios, exponha os campos que quem usa o erro vai querer ler.
- `%w` só funciona em `fmt.Errorf` (não em `errors.New`).
- Um erro embrulhado com `%w` continua sendo `error`, dá pra retornar normalmente.

## 👀 Variações para você fixar

```go
package main

import (
    "errors"
    "fmt"
)

var ErrNegativo = errors.New("valor negativo")

type ErroIntervalo struct {
    Valor, Min, Max int
}

func (e *ErroIntervalo) Error() string {
    return fmt.Sprintf("%d fora do intervalo [%d, %d]", e.Valor, e.Min, e.Max)
}

func validar(n int) error {
    if n < 0 {
        return ErrNegativo
    }
    if n > 100 {
        return &ErroIntervalo{Valor: n, Min: 0, Max: 100}
    }
    return nil
}

func processar(n int) error {
    if err := validar(n); err != nil {
        return fmt.Errorf("processar(%d): %w", n, err)
    }
    return nil
}

func main() {
    for _, n := range []int{50, -1, 200} {
        err := processar(n)
        if err == nil {
            fmt.Printf("%d ok\n", n)
            continue
        }
        fmt.Println("erro:", err)

        if errors.Is(err, ErrNegativo) {
            fmt.Println("  → era negativo!")
        }

        var ei *ErroIntervalo
        if errors.As(err, &ei) {
            fmt.Printf("  → fora do intervalo: %d\n", ei.Valor)
        }
    }
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e rode os 6 exercícios resolvidos.
2. Rode: `go run ./curso/modulo-08-erros/pratica`
3. Mexa nos valores, force os erros, veja o que acontece.
4. Encare o **desafio**: o **Validador de Cadastro**.

## ✅ Auto-verificação
- [ ] Sei dizer o que é a interface `error` em uma frase
- [ ] Sei criar erro com `errors.New` e com `fmt.Errorf`
- [ ] Sei embrulhar erro com `%w` e desembrulhar com `errors.Is` / `errors.As`
- [ ] Sei criar meu próprio tipo de erro com um `struct`
- [ ] Sei explicar por que `panic` **não** é para fluxo normal

Próximo módulo: **Coleções avançadas e iteração** — onde vamos aplicar erro de verdade em código que processa dados.
