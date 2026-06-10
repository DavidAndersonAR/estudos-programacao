# Variáveis em Go — Resumo simples

Uma **variável** é como uma caixinha com nome onde você guarda um valor. Em Go, toda variável tem um tipo (o que ela pode guardar) e um valor (o que ela está guardando agora). Você pode trocar o valor depois, mas o tipo geralmente continua o mesmo.

## 1. O que é uma variável
Pense numa variável como uma etiqueta que aponta para um espaço da memória do computador. Esse espaço guarda um valor, e você acessa esse valor usando o nome (a etiqueta). Toda vez que você "lê" a variável, ela devolve o último valor que foi guardado nela.

```go
// Criando uma variável chamada "idade" que guarda o número 25
idade := 25

// Lendo o valor (vai imprimir 25)
fmt.Println(idade)

// Trocando o valor guardado
idade = 30
fmt.Println(idade)    // agora imprime 30
```

---

## 2. Declarando com `var`
A forma "longa" de criar uma variável é usando a palavra `var`. Você diz o nome, o tipo e (se quiser) já dá um valor inicial. Se não der valor, Go coloca o **valor zero** automaticamente (mais sobre isso adiante).

```go
// Só declarando (Go coloca o valor zero, que é 0 para int)
var idade int

// Declarando e já atribuindo valor
var nome string = "David"

// Quando você dá o valor, dá para omitir o tipo - Go descobre sozinho
var ativo = true              // Go entende que é bool

// Declarando várias de uma vez com o mesmo tipo
var x, y, z int               // x, y e z começam todos com 0

// Declarando várias com valores diferentes
var a, b = 10, "olá"          // a é int, b é string

// Bloco de declarações (deixa o código mais organizado)
var (
    nomeUsuario string = "ana"
    idadeUsuario int    = 25
    ativoUsuario bool   = true
)
```

---

## 3. Declaração curta com `:=`
Dentro de funções, o jeito mais comum de criar variáveis é com `:=`. É uma versão atalho: Go descobre o tipo sozinho com base no valor que você passou. Mais rápido de escrever e bem fácil de ler.

```go
// Forma curta - Go entende que "nome" é string
nome := "Maria"

// Várias de uma vez
x, y := 10, 20

// Bem útil ao chamar funções que devolvem vários valores
arquivo, erro := os.Open("dados.txt")

// Só funciona DENTRO de funções (não funciona no nível do pacote)
func exemplo() {
    contador := 0
    contador++
}
```

Atenção: pelo menos uma das variáveis do lado esquerdo precisa ser **nova**. Se todas já existirem, Go reclama. Se só algumas forem novas, as antigas são "reaproveitadas" (recebem um novo valor).

```go
nome, idade := "Ana", 25            // ambas novas, ok
nome, profissao := "Bia", "Dev"     // "profissao" é nova, "nome" só é atualizada
```

---

## 4. Tipo estático (o tipo da variável)
Em Go, toda variável tem um **tipo fixo** que é definido na hora da criação. Esse tipo se chama "tipo estático" e ele **não muda** durante a vida da variável. Se você criou um `int`, ela vai continuar sendo `int` até o fim.

```go
// "numero" tem tipo estático int - vai continuar int sempre
var numero int = 10
numero = 20                   // ok, ainda é int
// numero = "texto"           // erro! não dá para atribuir string num int

// Quando você usa := ou var sem tipo, Go "deduz" o tipo pelo valor
var preco = 19.90             // tipo estático: float64
quantidade := 5               // tipo estático: int
nome := "Pedro"               // tipo estático: string
```

Existe um detalhe especial: variáveis do tipo **interface** podem guardar valores de diferentes tipos por dentro (isso se chama "tipo dinâmico"), mas no nível da declaração elas continuam tendo o mesmo tipo estático.

```go
var qualquerCoisa interface{}     // tipo estático: interface vazia
qualquerCoisa = 42                // por dentro guarda um int
qualquerCoisa = "olá"             // agora por dentro guarda uma string
```

---

## 5. Valor zero (o valor padrão)
Se você cria uma variável e não dá um valor inicial, Go **não deixa ela "vazia"** — ele coloca um valor padrão chamado **valor zero**. Cada tipo tem o seu:

- Números (`int`, `float64`...) → `0`
- Booleano (`bool`) → `false`
- Texto (`string`) → `""` (string vazia)
- Ponteiro, slice, map, canal, função e interface → `nil` (nada)
- Array e struct → cada campo com seu próprio zero

Isso é ótimo porque você nunca tem uma variável com "lixo" da memória — sempre começa com algo previsível.

```go
var numero int                // vale 0
var ativo bool                // vale false
var nome string               // vale ""
var lista []int               // vale nil
var pessoa struct {           // todos os campos zerados
    Nome  string              // ""
    Idade int                 // 0
}

fmt.Println(numero, ativo, nome)   // 0 false (string vazia)
```

---

## 6. Identificador em branco `_`
O `_` (underline / sublinhado) é um nome especial chamado **identificador em branco**. Ele funciona como uma "lixeira": você usa quando precisa receber um valor mas não quer guardá-lo. Útil em funções que retornam várias coisas e você só se interessa por algumas.

```go
// os.Open devolve um arquivo e um erro - aqui só queremos o arquivo
arquivo, _ := os.Open("dados.txt")

// Verificar se uma chave existe num map (só queremos o "existe", não o valor)
mapa := map[string]int{"a": 1, "b": 2}
_, existe := mapa["c"]
if !existe {
    fmt.Println("chave não encontrada")
}

// Pegar só o segundo retorno de uma função
_, y, _ := pegarCoordenadas()      // só queremos o y
```

Você não pode **ler** o `_` — ele só serve para descartar valor. É como jogar fora.

---

## 7. Escopo (onde a variável existe)
O **escopo** é a região do código onde uma variável existe e pode ser usada. Em Go, isso depende de **onde** ela foi declarada:

- Declarada **dentro de uma função** → só existe ali dentro (variável local).
- Declarada **dentro de um bloco** (como `if`, `for`, `{ }`) → só existe naquele bloco.
- Declarada **fora de qualquer função**, no nível do arquivo → existe em todo o pacote (variável de pacote).

Quando o bloco termina, a variável "desaparece".

```go
// Variável de pacote - existe em todo o arquivo/pacote
var versao = "1.0"

func exemplo() {
    // Variável local - só existe nesta função
    nome := "Ana"

    if true {
        // Variável de bloco - só existe dentro do if
        mensagem := "oi"
        fmt.Println(mensagem)          // ok
    }
    // fmt.Println(mensagem)           // erro! "mensagem" não existe mais aqui

    for i := 0; i < 3; i++ {
        // "i" só existe dentro deste for
        fmt.Println(i)
    }
    // fmt.Println(i)                  // erro! "i" não existe mais aqui
}
```

Também vale lembrar: Go **não deixa você declarar uma variável local sem usar**. Se criar e não usar, o compilador dá erro. Isso ajuda a evitar código sujo.

---

Em resumo: variáveis em Go são **caixinhas tipadas** com nome. Você cria com `var` (forma longa) ou `:=` (forma curta, só dentro de funções), o tipo é fixo desde o começo, e se você não der um valor inicial, Go usa o **valor zero**. Use `_` quando quiser descartar um valor, e lembre que cada variável vive só dentro do bloco onde foi criada.
