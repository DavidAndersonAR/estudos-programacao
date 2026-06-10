# Elementos Léxicos em Go — Resumo simples

Quando você escreve um programa em Go, o compilador olha pro seu código e quebra ele em pedacinhos. Esses pedacinhos são os **elementos léxicos** — as "peças de Lego" que formam o código. Aqui a gente vê quais são essas peças: comentários, espaços, nomes, palavras reservadas, símbolos e os valores que aparecem direto no código (chamados de "literais").

## 1. Comentários
Comentários são textos que o Go **ignora** — eles servem só pra você (ou outras pessoas) entenderem o código. Existem duas formas:

- **Comentário de linha**: começa com `//` e vai até o fim da linha.
- **Comentário de bloco**: começa com `/*` e termina com `*/`, podendo ocupar várias linhas.

Importante: um comentário não pode começar dentro de um texto (string) nem dentro de outro comentário.

```go
// Isto é um comentário de uma linha só

/* Isto é um comentário
   que pode ocupar
   várias linhas */

var idade int = 30 // explicação no fim da linha

/* comentário curto em uma linha */ var nome string = "Ana"
```

---

## 2. Tokens (as peças do código)
Quando o Go lê seu código, ele divide tudo em **tokens** (pedaços com significado). Existem quatro tipos:

- **Identificadores**: nomes que você cria (variáveis, funções...).
- **Palavras-chave**: palavras reservadas da linguagem (como `if`, `for`).
- **Operadores e pontuação**: símbolos como `+`, `=`, `{`, `,`.
- **Literais**: valores escritos direto no código, como `42` ou `"oi"`.

Espaços em branco (espaço, tab, quebra de linha) são ignorados — servem só pra separar as peças. O Go sempre pega o **maior pedaço possível** que forme um token válido.

```go
// Aqui o Go enxerga: "var", "idade", "int", "=", "30"
var idade int = 30

// Espaços extras não importam — o resultado é o mesmo
var    nome   string   =   "Ana"
```

---

## 3. Ponto e vírgula (semicolons)
Em outras linguagens, você precisa colocar `;` no fim de cada comando. Em Go, **o compilador coloca pra você** automaticamente no fim de cada linha (em quase todos os casos). Por isso quase nunca a gente escreve `;` no código.

O Go insere um `;` automático depois de coisas como: um nome, um número, um texto, um `)`, um `]`, um `}`, ou palavras como `return`, `break`, `continue`.

```go
// Você escreve assim (sem ponto e vírgula):
idade := 30
nome := "Ana"

// O Go entende como se fosse:
// idade := 30;
// nome := "Ana";

// Quando colocar dois comandos na mesma linha, aí sim precisa do ;
a := 1; b := 2
```

---

## 4. Identificadores (nomes)
São os **nomes** que você dá pras coisas: variáveis, funções, tipos etc. Regras:

- Começa com uma **letra** (ou `_`).
- Depois pode ter letras, números ou `_`.
- Letras acentuadas e de outros alfabetos também valem (Unicode).
- Não pode ser uma palavra reservada da linguagem.

Detalhe importante: se o nome começar com **letra maiúscula**, ele fica visível para outros pacotes (público); se começar com minúscula, fica só dentro do pacote (privado).

```go
// Nomes válidos
var idade int
var _x9 int
var nomeCompleto string
var αβ int             // letras gregas funcionam
var Total int          // começa com maiúscula = público

// Nomes inválidos (vão dar erro)
// var 9vidas int      // não pode começar com número
// var if int          // "if" é palavra reservada
```

---

## 5. Palavras-chave (keywords)
São 25 palavras que o Go reservou pra si mesmo. Você **não pode** usá-las como nome de variável, função ou qualquer outra coisa.

```go
// As 25 palavras reservadas do Go:
// break       default      func        interface   select
// case        defer        go          map         struct
// chan        else         goto        package     switch
// const       fallthrough  if          range       type
// continue    for          import      return      var

// Exemplos de uso correto dessas palavras:
package main

import "fmt"

func main() {
    for i := 0; i < 3; i++ {
        if i == 1 {
            continue
        }
        fmt.Println(i)
    }
}
```

---

## 6. Operadores e pontuação
São os **símbolos** que o Go usa pra fazer contas, comparar, atribuir valores e organizar o código. Alguns exemplos:

- **Aritméticos**: `+`, `-`, `*`, `/`, `%`
- **Comparação**: `==`, `!=`, `<`, `>`, `<=`, `>=`
- **Lógicos**: `&&` (e), `||` (ou), `!` (não)
- **Atribuição**: `=`, `:=`, `+=`, `-=`, etc.
- **Pontuação**: `(`, `)`, `{`, `}`, `[`, `]`, `,`, `;`, `.`, `...`, `:`
- **Outros**: `<-` (canal), `++`, `--`, `&` (endereço), `*` (ponteiro)

```go
// Aritmética
soma := 10 + 5         // 15
resto := 10 % 3        // 1 (resto da divisão)

// Comparação e lógicos
maior := 10 > 5                    // true
ambos := (10 > 5) && (3 < 7)       // true

// Atribuição
x := 10                // forma curta
x += 5                 // mesmo que x = x + 5
x++                    // mesmo que x = x + 1

// Pontuação
nums := []int{1, 2, 3}             // {} e , agrupam valores
primeiro := nums[0]                 // [] acessa posição
```

---

## 7. Números inteiros (integer literals)
São os números **sem vírgula** escritos direto no código. Podem ser em diferentes bases:

- **Decimal** (base 10, o normal): `42`
- **Binário** (base 2): começa com `0b` ou `0B`
- **Octal** (base 8): começa com `0`, `0o` ou `0O`
- **Hexadecimal** (base 16): começa com `0x` ou `0X`

Você também pode usar `_` (underline) **entre os números** pra deixar mais legível — o `_` não muda o valor, é só pra leitura.

```go
// Decimal (o jeito comum)
idade := 30
populacao := 1_000_000      // mesma coisa que 1000000

// Binário
mascara := 0b1010           // 10 em decimal

// Octal
permissao := 0o755          // usado em permissões de arquivo
antigo := 0600              // octal "à moda antiga" (também vale)

// Hexadecimal
cor := 0xFF00AA             // usado em cores, endereços

// Exemplos inválidos (vão dar erro)
// 42_         // _ no fim não pode
// 4__2        // dois _ seguidos não pode
// _42         // começa com _ vira um nome de variável, não um número
```

---

## 8. Números decimais (floating-point literals)
São números **com vírgula** (na verdade, com ponto, porque em Go o separador é o `.`). Podem ser escritos de várias formas, inclusive em notação científica usando `e` ou `E`.

Também existe a forma hexadecimal, que usa `p` ou `P` pro expoente — mas isso é bem raro no dia a dia.

```go
// Formas comuns
preco := 19.90
pi := 3.14159
meio := 0.5
tambemMeio := .5            // o 0 antes do ponto pode ser omitido
inteiroComPonto := 5.       // mesma coisa que 5.0

// Notação científica
grande := 1.5e6             // 1,5 × 10⁶ = 1500000
pequeno := 6.67e-11         // 6,67 × 10⁻¹¹

// Com underline pra legibilidade
massaTerra := 5_972e21      // 5972 × 10²¹

// Formato hexadecimal (avançado, raramente usado)
hexFloat := 0x1p-2          // 0,25

// Exemplos inválidos
// 1_.5         // _ não pode grudar no ponto
// 1.5_e1       // _ não pode grudar no e
```

---

## 9. Números imaginários (imaginary literals)
São números usados na parte **complexa** da matemática (aquela com a unidade imaginária `i`). Basta colocar um `i` no fim de qualquer número. Quase nunca aparece no dia a dia, só em código matemático/científico.

```go
// Imaginário puro
a := 2i                     // 2i
b := 3.5i                   // 3,5i

// Combinando com número real pra formar um complexo
c := 2 + 3i                 // número complexo: parte real 2, parte imaginária 3
d := 1.5 + 0.5i

// Pegando as partes
fmt.Println(real(c))        // 2
fmt.Println(imag(c))        // 3
```

---

## 10. Rune literals (caracteres)
Uma **rune** é um caractere Unicode (uma letra, símbolo, emoji...). No código, ela é escrita entre **aspas simples** (`'`). Por baixo dos panos, é um número inteiro que representa aquele caractere na tabela Unicode.

Existem **sequências de escape** pra representar caracteres especiais usando `\`:

- `\n` → nova linha
- `\t` → tab
- `\\` → barra invertida
- `\'` → aspas simples
- `\xNN` → caractere por código hexadecimal (2 dígitos)
- `\uNNNN` → caractere Unicode (4 dígitos hexa)
- `\UNNNNNNNN` → caractere Unicode (8 dígitos hexa)

```go
// Caractere normal
letra := 'A'                // representa o número 65
acento := 'ä'
japones := '本'

// Sequências de escape
quebra := '\n'              // nova linha
tab := '\t'                 // tab
aspas := '\''               // aspas simples

// Por código (várias formas de escrever o mesmo caractere)
porHex := '\x41'            // 'A'
porUnicode := 'á'      // 'á'
porUnicodeLongo := '\U0001F600'  // 😀 (emoji)

// Exemplos inválidos
// 'aa'         // só pode UM caractere entre as aspas simples
// '\k'         // \k não é uma sequência de escape válida
// '\xa'        // precisa de 2 dígitos hexa, não 1
```

---

## 11. String literals (textos)
São os **textos** escritos direto no código. Existem duas formas:

- **String interpretada** (entre aspas duplas `"..."`): as sequências de escape como `\n` funcionam aqui. **Não pode ter quebra de linha real** no meio.
- **String crua** (entre crases `` `...` ``): o que estiver entre as crases é literal — `\n` não vira quebra de linha, fica como dois caracteres `\` e `n`. **Pode ter quebra de linha real** no meio. Útil pra textos longos ou expressões regulares.

```go
// String interpretada (aspas duplas)
saudacao := "Olá, mundo!\n"          // \n vira quebra de linha
comAspas := "Ela disse \"oi\""       // \" para colocar aspas no meio
caminho := "C:\\Users\\David"        // \\ para uma barra

// String crua (crases) — tudo literal
regex := `\d+\.\d+`                   // \d e \. ficam como estão
varias := `Primeira linha
Segunda linha
Terceira linha`

// Mesmo texto, escrito de formas diferentes
a := "日本語"                          // direto no código
b := `日本語`                          // forma crua
c := "日本語"             // por código Unicode
d := "\xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e"  // pelos bytes UTF-8
// a, b, c e d representam o mesmo texto

// Exemplos inválidos
// "linha 1
//  linha 2"     // string com aspas duplas não pode quebrar linha
// "\uD800"     // código Unicode inválido (surrogate half)
```

---

Em resumo: os **elementos léxicos** são as peças mínimas do código Go. Você tem **comentários** (que o compilador ignora), **tokens** (nomes, palavras-chave, símbolos e valores), regras de **ponto e vírgula automático** (que deixam o código mais limpo), e várias formas de escrever **valores direto no código** — números inteiros, decimais, imaginários, caracteres (runes) e textos (strings). Entender essas peças ajuda você a ler e escrever Go com mais confiança, porque você passa a enxergar o código do mesmo jeito que o compilador.
