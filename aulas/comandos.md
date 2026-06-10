# Comandos (Statements) em Go — Resumo simples

Em Go, um **comando** (statement) é uma instrução que faz alguma coisa acontecer: atribuir um valor, tomar uma decisão, repetir algo, chamar uma função etc. O programa é, no fundo, uma sequência de comandos que o computador executa um atrás do outro.

## 1. Atribuição (`=`, `:=`, `+=` e companhia)
Atribuir significa **guardar um valor em uma variável**. Em Go existem várias formas: a comum (`=`), a curta que já declara a variável (`:=`) e as combinadas (`+=`, `-=`, `*=`, `/=`, `%=`) que fazem uma conta e já salvam o resultado.

```go
// Atribuição simples (variável já existe)
var idade int
idade = 30

// Forma curta (declara e atribui de uma vez)
nome := "David"

// Atribuir vários valores ao mesmo tempo
a, b := 1, 2

// Trocar valores entre duas variáveis (sem precisar de uma terceira)
a, b = b, a

// Ignorar um valor usando "_" (underline)
_, valor := 10, 20

// Atribuições combinadas (fazem conta e já salvam)
contador := 0
contador += 5     // mesmo que contador = contador + 5
contador -= 2     // subtrai
contador *= 3     // multiplica
contador /= 2     // divide
contador %= 4     // resto da divisão
```

---

## 2. Incremento e decremento (`++` e `--`)
São formas curtas de **somar 1** ou **subtrair 1** de uma variável. Diferente de outras linguagens, em Go eles são **comandos** (não expressões), ou seja, ficam sozinhos na linha — não dá para usar dentro de uma conta.

```go
contador := 10

contador++        // agora vale 11
contador--        // voltou para 10

// Isso NÃO funciona em Go (dá erro):
// x := contador++
// fmt.Println(contador++)
```

---

## 3. `if` / `else` (decisões)
Executa um bloco de código **só se** uma condição for verdadeira. Pode ter um `else` para o caso contrário, e `else if` para testar várias condições em sequência. Uma coisa legal do Go: dá para declarar uma variável dentro do próprio `if`.

```go
idade := 18

// if simples
if idade >= 18 {
    fmt.Println("Maior de idade")
}

// if com else
if idade >= 18 {
    fmt.Println("Pode entrar")
} else {
    fmt.Println("Não pode entrar")
}

// if com else if
nota := 7.5
if nota >= 9 {
    fmt.Println("Ótimo")
} else if nota >= 7 {
    fmt.Println("Bom")
} else {
    fmt.Println("Precisa melhorar")
}

// if com declaração de variável (só existe dentro do if/else)
if resultado := calcular(); resultado > 0 {
    fmt.Println("Positivo:", resultado)
} else {
    fmt.Println("Negativo:", resultado)
}
```

---

## 4. `switch` (várias opções)
Quando você tem **muitos casos para testar**, o `switch` é mais limpo que vários `if/else if`. Em Go, ele tem duas vantagens: **não precisa de `break`** no final de cada caso (não "vaza" para o próximo automaticamente) e pode ser usado sem expressão, virando um `if/else` disfarçado.

```go
dia := "terça"

// Switch comum
switch dia {
case "segunda":
    fmt.Println("Começo da semana")
case "terça", "quarta", "quinta":     // vários valores no mesmo caso
    fmt.Println("Meio da semana")
case "sexta":
    fmt.Println("Sextou!")
default:                              // se nenhum bater
    fmt.Println("Fim de semana")
}

// Switch sem expressão (substitui if/else if)
nota := 8.0
switch {
case nota >= 9:
    fmt.Println("A")
case nota >= 7:
    fmt.Println("B")
default:
    fmt.Println("C")
}

// Switch com inicialização
switch x := obterValor(); {
case x > 0:
    fmt.Println("positivo")
case x < 0:
    fmt.Println("negativo")
}
```

---

## 5. `type switch` (descobrir o tipo)
É um `switch` especial que pergunta **qual tipo um valor tem**. Muito usado quando você recebe um valor numa interface vazia (`any`) e precisa saber o que ele realmente é.

```go
func descrever(coisa any) {
    switch v := coisa.(type) {
    case int:
        fmt.Println("É um inteiro:", v)
    case string:
        fmt.Println("É um texto:", v)
    case bool:
        fmt.Println("É booleano:", v)
    case nil:
        fmt.Println("É nada (nil)")
    default:
        fmt.Println("Não sei o que é")
    }
}

descrever(42)         // É um inteiro: 42
descrever("oi")       // É um texto: oi
descrever(true)       // É booleano: true
```

---

## 6. `for` (repetir)
Go tem **só um comando de repetição**: o `for`. Mas ele assume três formas diferentes, dependendo de como você usa.

```go
// Forma 1: clássica (com início, condição e passo)
for i := 0; i < 5; i++ {
    fmt.Println(i)            // imprime 0, 1, 2, 3, 4
}

// Forma 2: estilo "while" (só com condição)
n := 10
for n > 0 {
    fmt.Println(n)
    n--
}

// Forma 3: infinito (precisa de break para parar)
contador := 0
for {
    if contador >= 3 {
        break
    }
    fmt.Println("rodando...")
    contador++
}
```

---

## 7. `for range` (percorrer coleções)
É a forma de **passar por todos os itens** de um slice, array, map, string ou canal. Devolve dois valores: a posição (ou chave) e o valor.

```go
// Percorrer um slice
frutas := []string{"maçã", "banana", "uva"}
for indice, fruta := range frutas {
    fmt.Println(indice, fruta)
}

// Só os índices (ignorando o valor)
for i := range frutas {
    fmt.Println(i)
}

// Só os valores (ignorando o índice com "_")
for _, fruta := range frutas {
    fmt.Println(fruta)
}

// Percorrer um map (chave e valor)
idades := map[string]int{"Ana": 25, "João": 30}
for nome, idade := range idades {
    fmt.Println(nome, "tem", idade, "anos")
}

// Percorrer uma string (devolve a posição e a "rune", ou seja, o caractere)
for i, letra := range "olá" {
    fmt.Println(i, string(letra))
}

// Percorrer um canal (até ele ser fechado)
canal := make(chan int)
for valor := range canal {
    fmt.Println(valor)
}
```

---

## 8. `defer` (adiar execução)
Marca uma chamada de função para ser executada **só no final** da função atual, não importa como ela termine. Muito usado para fechar arquivos, liberar recursos ou destravar coisas — você "agenda" a limpeza logo depois de abrir.

```go
func lerArquivo() {
    arquivo, _ := os.Open("dados.txt")
    defer arquivo.Close()         // só vai fechar quando a função terminar

    // ... lê o arquivo ...
}

// Vários defers rodam na ordem inversa (último adicionado é o primeiro a rodar)
func exemplo() {
    defer fmt.Println("1")
    defer fmt.Println("2")
    defer fmt.Println("3")
    fmt.Println("início")
}
// Imprime: início, 3, 2, 1

// Os argumentos do defer são avaliados na hora, não no final
func cuidado() {
    x := 10
    defer fmt.Println(x)         // vai imprimir 10
    x = 20
}
```

---

## 9. `go` (iniciar goroutine)
Coloca uma função para **rodar ao lado** (em paralelo) sem esperar ela terminar. A função executada assim se chama **goroutine** (uma tarefa leve gerenciada pelo próprio Go).

```go
func contar(nome string) {
    for i := 1; i <= 3; i++ {
        fmt.Println(nome, i)
    }
}

// Rodando em paralelo
go contar("A")
go contar("B")
contar("C")

// Função anônima como goroutine
go func() {
    fmt.Println("rodando do lado")
}()

// Goroutine com canal para esperar resultado
resultado := make(chan int)
go func() {
    resultado <- 42
}()
fmt.Println(<-resultado)         // 42
```

---

## 10. `select` (escolher canal pronto)
Parecido com `switch`, mas para **canais**. Espera vários canais ao mesmo tempo e executa o caso do **primeiro que ficar pronto**. Se mais de um estiver pronto, escolhe um aleatoriamente. Tem um `default` opcional para quando nenhum estiver pronto.

```go
c1 := make(chan string)
c2 := make(chan string)

go func() { c1 <- "vem do 1" }()
go func() { c2 <- "vem do 2" }()

select {
case msg := <-c1:
    fmt.Println("Recebi de c1:", msg)
case msg := <-c2:
    fmt.Println("Recebi de c2:", msg)
case <-time.After(1 * time.Second):
    fmt.Println("Demorou demais")
default:
    fmt.Println("Nenhum canal pronto agora")
}
```

---

## 11. `return` (devolver valor)
Termina a função atual e (opcionalmente) devolve um ou mais valores para quem chamou.

```go
// Return simples
func dobrar(n int) int {
    return n * 2
}

// Return de vários valores
func dividir(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("divisão por zero")
    }
    return a / b, nil
}

// Return "nu" (com nomes nos retornos)
func soma(a, b int) (total int) {
    total = a + b
    return                       // já devolve "total" sem precisar repetir
}

// Return sem valor (em função void)
func avisar(msg string) {
    if msg == "" {
        return                   // sai mais cedo
    }
    fmt.Println(msg)
}
```

---

## 12. `break` (parar laço)
Sai **de dentro** de um `for`, `switch` ou `select` antes da hora. Por padrão, sai só do laço mais próximo, mas dá para usar com um **rótulo** (label) para sair de laços aninhados.

```go
// Break simples
for i := 0; i < 10; i++ {
    if i == 5 {
        break                    // para o for quando i for 5
    }
    fmt.Println(i)
}

// Break com label (sai de dois fors de uma vez)
fora:
for i := 0; i < 5; i++ {
    for j := 0; j < 5; j++ {
        if i*j > 6 {
            break fora           // sai dos dois fors
        }
    }
}
```

---

## 13. `continue` (pular para próxima volta)
Pula o resto do código **da volta atual** do `for` e vai direto para a próxima iteração. Também aceita um rótulo, igual ao `break`.

```go
// Imprimir só os números pares
for i := 0; i < 10; i++ {
    if i%2 != 0 {
        continue                 // pula os ímpares
    }
    fmt.Println(i)               // 0, 2, 4, 6, 8
}

// Continue com label
externo:
for i := 0; i < 3; i++ {
    for j := 0; j < 3; j++ {
        if j == 1 {
            continue externo     // pula direto para a próxima volta do for de fora
        }
        fmt.Println(i, j)
    }
}
```

---

## 14. `goto` (pular para um rótulo)
Faz o programa **saltar** direto para um ponto marcado com um rótulo (`label:`). Existe em Go, mas é pouco usado — quase sempre dá para resolver melhor com `for`, `if` ou `break`/`continue`. Use só em casos bem específicos.

```go
i := 0

inicio:
if i < 3 {
    fmt.Println(i)
    i++
    goto inicio                  // volta para o rótulo "inicio"
}

// Uso mais útil: tratar erros em sequência
func processar() error {
    if err := passo1(); err != nil {
        goto falha
    }
    if err := passo2(); err != nil {
        goto falha
    }
    return nil

falha:
    fmt.Println("Algo deu errado")
    return fmt.Errorf("erro no processamento")
}
```

---

## 15. `fallthrough` (cair para o próximo case)
Por padrão, o `switch` em Go **não vaza** para o próximo `case`. Se você quiser esse comportamento de propósito, usa `fallthrough` no final do caso. Ele força a execução a continuar no caso seguinte, sem testar a condição.

```go
nivel := 1

switch nivel {
case 1:
    fmt.Println("Nível 1 desbloqueado")
    fallthrough                  // continua no case 2
case 2:
    fmt.Println("Nível 2 desbloqueado")
    fallthrough
case 3:
    fmt.Println("Nível 3 desbloqueado")
case 4:
    fmt.Println("Nível 4 — não vai chegar aqui")
}
// Imprime os três primeiros, mas não o quarto
```

---

## 16. Comandos menos comuns

- **Comando vazio**: uma instrução que não faz nada. Aparece sozinha às vezes em construções como `for` infinito vazio.
- **Comando rotulado** (`label:`): só dá um nome para o próximo comando, usado com `break`, `continue` ou `goto`.
- **Comando de expressão**: chamar uma função e ignorar o retorno (`fmt.Println("oi")` por si só já é um comando).
- **Comando de envio para canal**: `canal <- valor` envia algo para um canal.

```go
// Comando rotulado + break com label
inicio:
for {
    for i := 0; i < 5; i++ {
        if i == 3 {
            break inicio         // sai dos dois fors
        }
    }
}

// Comando de expressão (só chamar a função)
fmt.Println("isso é um comando")

// Comando de envio
canal := make(chan int, 1)
canal <- 10                      // envia 10 para o canal
```

---

Em resumo: Go tem comandos para **guardar valores** (atribuição, `++`/`--`), **decidir caminhos** (`if`, `switch`), **repetir coisas** (`for`, `for range`), **controlar o fluxo** (`break`, `continue`, `return`, `goto`, `fallthrough`), **organizar limpeza** (`defer`) e **trabalhar com concorrência** (`go`, `select`, envio em canal). Dominando esses 16 tipos de comando, você consegue escrever praticamente qualquer programa em Go.
