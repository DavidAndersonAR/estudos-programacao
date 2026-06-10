# Constantes em Go — Resumo simples

Em Go, uma **constante** é um valor que nunca muda depois de ser criado. Diferente de uma variável (que pode ser alterada a qualquer momento), uma constante é fixa: você define uma vez e ela fica assim para sempre durante a execução do programa. Útil para guardar coisas como o valor de Pi, nomes de configurações ou códigos de status.

## 1. Declarando com `const`
Para criar uma constante, usa-se a palavra `const` no lugar de `var`. Pode ser declarada sozinha ou em grupo (dentro de parênteses), o que costuma deixar o código mais organizado.

```go
// Forma simples — uma constante por linha
const Pi = 3.14159
const NomeApp = "MeuSistema"

// Forma em grupo — várias de uma vez
const (
    VersaoMaior = 1
    VersaoMenor = 0
    Autor       = "David"
)

// Várias na mesma linha
const a, b, c = 10, 20, "texto"
```

---

## 2. Tipos de constantes
Go aceita seis "famílias" (categorias) de constantes:

- **Booleana**: `true` ou `false`.
- **Rune**: representa um caractere Unicode (uma letra, símbolo, emoji etc).
- **Inteira**: números sem vírgula (1, 42, -7...).
- **Decimal** (ponto flutuante): números com vírgula (3.14, 0.5...).
- **Complexa**: números com parte "imaginária" (raramente usado).
- **String**: textos entre aspas.

As quatro do meio (rune, inteira, decimal e complexa) são chamadas em conjunto de **constantes numéricas**.

```go
// Booleana
const ativo = true
const desligado = false

// Rune (caractere Unicode)
const letraA = 'A'         // valor 65
const coracao = '♥'

// Inteira
const idadeMinima = 18
const limite = -100

// Decimal
const taxaJuros = 0.075
const gravidade = 9.81

// String
const saudacao = "Olá, mundo!"
const multilinha = `texto
em várias
linhas`
```

---

## 3. Constantes não-tipadas (untyped)
Quando você cria uma constante **sem dizer o tipo dela**, ela fica "não-tipada" (untyped). Isso é uma coisa muito útil em Go: ela se adapta ao contexto onde for usada. Por exemplo, uma constante `100` pode virar `int`, `float64`, `int64` etc, dependendo do que o código precisar naquele momento.

Cada categoria tem um **tipo padrão**, que é usado quando o contexto não decide outro:

- Booleana → `bool`
- Rune → `rune`
- Inteira → `int`
- Decimal → `float64`
- Complexa → `complex128`
- String → `string`

```go
// Todas estas são não-tipadas
const x = 42              // inteira não-tipada
const y = 3.14            // decimal não-tipada
const nome = "Ana"        // string não-tipada

// Como são flexíveis, dá para usar em vários contextos
var a int = x             // x vira int
var b float64 = x         // o mesmo x vira float64
var c int64 = x           // e aqui vira int64

// Sem contexto, usa o tipo padrão
valor := x                // valor é int (tipo padrão da inteira)
```

---

## 4. Constantes tipadas
Você também pode **dizer o tipo** da constante na hora de criar. Aí ela fica "presa" àquele tipo e não se adapta mais. Útil quando você quer ter certeza absoluta de que aquele valor é, por exemplo, sempre um `float32`.

```go
// Constantes com tipo explícito
const Pi float64 = 3.14159
const TamanhoMax int64 = 1024
const Versao string = "1.0.0"

// Várias do mesmo tipo
const u, v float32 = 0, 3

// Como têm tipo fixo, misturar dá erro
var n int = TamanhoMax    // ERRO: TamanhoMax é int64, não int

// Para misturar, precisa converter na mão
var n int = int(TamanhoMax)
```

**Resumo rápido:** se você não tem certeza, deixe sem tipo (untyped). Só coloque o tipo quando realmente precisar travar aquele valor a um tipo específico.

---

## 5. Precisão alta dos números
As constantes numéricas em Go têm uma característica especial: elas guardam o valor **com precisão muito alta** (pelo menos 256 bits). Isso significa que você pode fazer contas com valores enormes sem perder informação, desde que o resultado final caiba no tipo onde for usado.

```go
// Constantes podem ser absurdamente grandes
const Enorme = 1 << 100   // 2 elevado a 100 — não cabe num int!

// Mas dá para usar em contas, desde que o resultado caiba
const Menor = Enorme >> 99  // resultado é 2, cabe num int

var resultado int = Menor   // OK!
```

---

## 6. `iota` — gerador automático de valores
O `iota` é um ajudante que numera as constantes automaticamente dentro de um bloco `const (...)`. Ele começa em **0** e aumenta de 1 em 1 a cada nova linha. Muito útil para criar listas de constantes relacionadas, tipo dias da semana ou códigos de erro, sem precisar escrever os números na mão.

```go
// Uso básico — numeração automática
const (
    Domingo  = iota   // 0
    Segunda            // 1 (repete a expressão "iota" da linha de cima)
    Terça              // 2
    Quarta             // 3
    Quinta             // 4
    Sexta              // 5
    Sábado             // 6
)

// iota reinicia em cada novo bloco const
const (
    Pequeno = iota    // 0
    Médio             // 1
    Grande            // 2
)

// Dá para usar em expressões — útil para "flags" (bits)
const (
    Leitura  = 1 << iota   // 1  (1 deslocado 0 vezes)
    Escrita                // 2  (1 deslocado 1 vez)
    Executar               // 4  (1 deslocado 2 vezes)
)

// Pular um valor com underscore
const (
    _  = iota             // ignora o 0
    KB = 1 << (10 * iota) // 1024
    MB                    // 1048576
    GB                    // 1073741824
)

// Misturando com tipos
const (
    u         = iota * 10   // 0  — não-tipada
    v float64 = iota * 10   // 10 — float64
    w                       // 20 — float64 (herda da linha de cima)
)
```

---

## 7. Onde uma constante pode aparecer
Uma constante pode ser definida a partir de:
- Um valor escrito direto no código (literal): `42`, `"oi"`, `true`.
- Outra constante já existente.
- Uma expressão que combina constantes: `2 * Pi`, `"olá" + " mundo"`.
- Uma conversão entre tipos que dê resultado constante: `float64(10)`.
- Algumas funções nativas usadas com argumentos constantes: `len`, `cap`, `min`, `max`, `real`, `imag`, `unsafe.Sizeof`.

```go
const base = 10
const dobro = base * 2              // expressão entre constantes
const mensagem = "Oi, " + "tudo bem?"  // junção de strings
const tamanho = len("abcde")        // len com string constante = 5
const maximo = max(10, 20, 30)      // max com números constantes = 30
```

---

## Em resumo
Constantes em Go são valores fixos criados com `const`. Podem ser **não-tipadas** (flexíveis e se adaptam ao contexto) ou **tipadas** (presas a um tipo específico). Existem seis categorias: booleana, rune, inteira, decimal, complexa e string. O `iota` é um truque útil para gerar listas de números automaticamente dentro de um bloco `const`. Use constantes sempre que tiver um valor que não deve mudar — deixa o código mais seguro e mais claro.
