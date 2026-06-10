# Erros e Panics em Go — Resumo simples

Em Go, problemas no programa são tratados de **duas formas bem diferentes**: os **erros comuns** (coisas que a gente espera que possam dar errado, como um arquivo não existir) são tratados como **valores normais** que a função devolve; já os **panics** são situações **graves e inesperadas** (como acessar uma posição que não existe num slice) que param o programa na hora. A ideia é simples: erros você verifica, panics você evita — e, em último caso, recupera.

## 1. Interface `error`
O Go já vem com uma interface pronta chamada `error`. Qualquer tipo que tenha um método `Error() string` automaticamente vira um `error`. Isso significa que um erro em Go é só um **valor** comum, igual a qualquer outro — não é nada mágico.

```go
// Esta é a interface que já vem pronta no Go:
type error interface {
    Error() string
}

// Ou seja: se um tipo souber dizer "qual é o problema?" em forma de texto,
// ele já pode ser usado como erro.
```

---

## 2. Convenção de retornar erro
Em Go, funções que podem falhar costumam devolver o erro como **último valor retornado**. Se deu tudo certo, o erro vem como `nil` (nada). Se deu errado, vem um valor de erro descrevendo o problema.

```go
// Função que pode falhar: devolve o resultado E o erro
func dividir(a, b float64) (float64, error) {
    if b == 0 {
        // Algo deu errado: devolvemos um erro
        return 0, fmt.Errorf("não dá para dividir por zero")
    }
    // Tudo certo: erro é nil
    return a / b, nil
}

// Chamando a função
resultado, err := dividir(10, 2)
```

---

## 3. Verificando erros
O padrão mais comum em Go é o famoso `if err != nil`. Você chama a função, pega o erro, e checa logo em seguida se ele veio diferente de `nil`. Se veio, é porque deu problema.

```go
resultado, err := dividir(10, 0)
if err != nil {
    // Deu ruim: tratar o erro aqui
    fmt.Println("Erro:", err)
    return
}

// Daqui pra baixo, sabemos que deu tudo certo
fmt.Println("Resultado:", resultado)

// Exemplo com leitura de arquivo
dados, err := os.ReadFile("config.txt")
if err != nil {
    fmt.Println("Não consegui ler o arquivo:", err)
    return
}
fmt.Println(string(dados))
```

---

## 4. Criar erros
Existem várias formas de criar um erro. As três mais comuns são:

- **`errors.New`**: para um erro simples com texto fixo.
- **`fmt.Errorf`**: quando você quer montar a mensagem com variáveis dentro.
- **Tipo próprio**: quando você quer guardar mais informações dentro do erro (código, status etc).

```go
import (
    "errors"
    "fmt"
)

// Forma 1: errors.New (texto simples)
var ErroUsuarioNaoEncontrado = errors.New("usuário não encontrado")

func buscar(id int) error {
    return ErroUsuarioNaoEncontrado
}

// Forma 2: fmt.Errorf (texto com variáveis)
func validarIdade(idade int) error {
    if idade < 0 {
        return fmt.Errorf("idade inválida: %d", idade)
    }
    return nil
}

// Forma 3: tipo próprio de erro (mais informações)
type ErroHTTP struct {
    Codigo  int
    Mensagem string
}

// Para virar um "error", precisa do método Error() string
func (e *ErroHTTP) Error() string {
    return fmt.Sprintf("HTTP %d: %s", e.Codigo, e.Mensagem)
}

func buscarPagina() error {
    return &ErroHTTP{Codigo: 404, Mensagem: "página não existe"}
}
```

---

## 5. O que é panic
Um **panic** acontece quando o programa encontra um problema tão sério que não dá para continuar. Diferente do erro comum, o panic **para a execução** e vai subindo até fechar o programa (a não ser que você recupere).

Algumas situações que geram panic automaticamente em tempo de execução:

- Acessar uma posição de array ou slice que **não existe** (índice fora dos limites).
- Tentar usar um **ponteiro `nil`** como se tivesse valor.
- Fazer **divisão de inteiro por zero**.
- Mandar mensagem para um **canal já fechado**.
- Fazer "type assertion" errada sem usar a forma com `ok`.

```go
// 1. Índice fora dos limites
numeros := []int{1, 2, 3}
fmt.Println(numeros[10])    // PANIC: index out of range

// 2. Dereferenciar ponteiro nil
var p *int                  // p é nil
fmt.Println(*p)             // PANIC: nil pointer dereference

// 3. Divisão de inteiro por zero
a := 10
b := 0
fmt.Println(a / b)          // PANIC: integer divide by zero

// 4. Mandar para canal fechado
c := make(chan int)
close(c)
c <- 1                      // PANIC: send on closed channel

// 5. Type assertion errada
var i any = "texto"
n := i.(int)                // PANIC: interface conversion
```

---

## 6. Disparar panic manualmente
Você também pode **causar um panic de propósito** usando a função `panic()`. Isso só deve ser feito em situações realmente sem saída, em que continuar não faz sentido. Para erros normais do dia a dia, prefira retornar `error`.

```go
// Disparando panic manualmente
func carregarConfig(caminho string) {
    if caminho == "" {
        // Situação impossível de continuar
        panic("caminho da config não pode ser vazio")
    }
}

// Outro exemplo: erro que nunca deveria acontecer
func pegarPrimeiro(lista []int) int {
    if len(lista) == 0 {
        panic("lista vazia: programador esqueceu de checar antes")
    }
    return lista[0]
}

// Você pode passar qualquer valor pro panic, não só texto
panic(fmt.Errorf("erro grave: %s", "deu ruim"))
```

---

## 7. Recuperar de um panic
Quando rola um panic, dá para "pegar" ele e evitar que o programa morra usando a função `recover()`. Mas tem um detalhe importante: o `recover()` **só funciona dentro de uma função `defer`**. Fora disso, ele não faz nada.

```go
func dividirComSeguranca(a, b int) (resultado int, err error) {
    // O defer roda no final, mesmo se der panic
    defer func() {
        // recover() pega o panic, se houve um
        if r := recover(); r != nil {
            // Convertemos o panic em um erro normal
            err = fmt.Errorf("rolou um panic: %v", r)
        }
    }()

    // Se b for 0, isso vai gerar panic
    resultado = a / b
    return resultado, nil
}

// Usando
res, err := dividirComSeguranca(10, 0)
if err != nil {
    fmt.Println("Tratado:", err)   // não quebra o programa
} else {
    fmt.Println("Deu:", res)
}

// Outro exemplo: recover num servidor que não pode cair
func processar(tarefa func()) {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Tarefa falhou, mas o servidor continua:", r)
        }
    }()
    tarefa()    // mesmo se essa função der panic, o servidor segue
}
```

---

Em resumo: para **problemas esperados** (arquivo não existe, dado inválido, falha de rede) use o padrão de **retornar `error`** e verificar com `if err != nil`. Para **situações realmente impossíveis** de continuar, use `panic`. E, se precisar evitar que um panic derrube tudo (por exemplo num servidor), use `recover` dentro de um `defer`. A regra geral é: **erros são valores comuns, panics são exceções de verdade** — e Go te dá ferramentas para os dois casos.
