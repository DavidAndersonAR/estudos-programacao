# Funções Built-in em Go — Resumo simples

Em Go existem algumas funções que já vêm prontas na linguagem, sem precisar **importar** (trazer de outro pacote) nada. Elas são chamadas de **built-in** (embutidas) e estão sempre disponíveis em qualquer arquivo. Servem para tarefas do dia a dia, como medir o tamanho de uma lista, criar um slice, deletar uma chave de um map e por aí vai.

## 1. `len` e `cap`
- `len` retorna o **tamanho** (quantos elementos existem agora) de uma string, array, slice, map ou canal.
- `cap` retorna a **capacidade** (quanto cabe no total antes de precisar crescer) de um array, slice ou canal. Em map não funciona.

```go
texto := "Olá"
nums := []int{10, 20, 30}
buffer := make([]int, 3, 10)        // tamanho 3, capacidade 10
idades := map[string]int{"Ana": 25}

fmt.Println(len(texto))   // 3 (bytes, não caracteres)
fmt.Println(len(nums))    // 3
fmt.Println(len(idades))  // 1

fmt.Println(cap(nums))    // 3
fmt.Println(cap(buffer))  // 10
```

---

## 2. `append`
Adiciona um ou mais elementos ao final de um slice. Como o slice pode precisar crescer, o `append` sempre **retorna um novo slice** — por isso é comum escrever `lista = append(lista, ...)` para guardar o resultado.

```go
// Adicionando um valor por vez
frutas := []string{"maçã", "banana"}
frutas = append(frutas, "uva")            // [maçã banana uva]

// Adicionando vários de uma vez
nums := []int{1, 2}
nums = append(nums, 3, 4, 5)              // [1 2 3 4 5]

// Juntando dois slices (note o "..." no final)
a := []int{1, 2, 3}
b := []int{4, 5, 6}
c := append(a, b...)                      // [1 2 3 4 5 6]

// Caso especial: append em um slice de bytes pode receber uma string
bytes := []byte("Olá ")
bytes = append(bytes, "mundo"...)         // []byte("Olá mundo")
```

---

## 3. `copy`
Copia elementos de um slice para outro. Retorna a **quantidade** de elementos copiados, que é sempre o menor tamanho entre os dois slices (origem e destino).

```go
origem := []int{1, 2, 3, 4, 5}
destino := make([]int, 3)

n := copy(destino, origem)
fmt.Println(destino)   // [1 2 3]
fmt.Println(n)         // 3 (copiou 3 elementos)

// Também funciona com strings copiando para []byte
bytes := make([]byte, 5)
copy(bytes, "Hello")
fmt.Println(string(bytes))   // Hello

// Útil para duplicar um slice (sem compartilhar memória)
original := []int{10, 20, 30}
copia := make([]int, len(original))
copy(copia, original)
```

---

## 4. `make`
Cria e prepara para uso valores de três tipos: **slice**, **map** e **channel** (canal). Diferente do `new`, o `make` já deixa a estrutura pronta para receber dados, não devolve um ponteiro — devolve o próprio valor.

```go
// Slice: tamanho 5 (todos os valores começam como 0)
nums := make([]int, 5)

// Slice: tamanho 3, capacidade 10 (pode crescer até 10 sem realocar)
buffer := make([]int, 3, 10)

// Map: dicionário vazio pronto para uso
idades := make(map[string]int)
idades["Ana"] = 25

// Channel sem buffer (sincronizado)
canal := make(chan string)

// Channel com buffer (guarda até 5 mensagens)
fila := make(chan int, 5)
```

---

## 5. `new`
Cria um espaço na memória para um valor de qualquer tipo, devolvendo um **ponteiro** (endereço) para esse espaço. O valor começa zerado. Na prática, é menos usado que `make` ou que criar um struct direto com `&`.

```go
// Criar um ponteiro para int (valor inicial 0)
p := new(int)
fmt.Println(*p)   // 0
*p = 42
fmt.Println(*p)   // 42

// Equivalente a new para structs
type Pessoa struct {
    Nome  string
    Idade int
}

p1 := new(Pessoa)        // ponteiro para Pessoa zerada
p1.Nome = "Ana"

// Forma mais comum (faz a mesma coisa)
p2 := &Pessoa{Nome: "Ana"}
```

---

## 6. `delete`
Remove uma chave de um map. Se a chave não existir, não acontece nada (não dá erro). Só funciona com map.

```go
precos := map[string]float64{
    "café":  5.50,
    "pão":   1.20,
    "leite": 4.90,
}

delete(precos, "leite")
fmt.Println(precos)   // map[café:5.5 pão:1.2]

// Apagar uma chave que não existe não causa erro
delete(precos, "chocolate")   // nada acontece
```

---

## 7. `clear`
Função mais nova (a partir do Go 1.21). Serve para **esvaziar** um map ou zerar todos os valores de um slice (ou seja, deixa cada posição com o valor zero do tipo, mas o tamanho continua o mesmo).

```go
// Em map: apaga todas as chaves
notas := map[string]int{"Ana": 9, "Bia": 8}
clear(notas)
fmt.Println(len(notas))   // 0

// Em slice: zera todos os valores (mas mantém o tamanho)
nums := []int{1, 2, 3, 4, 5}
clear(nums)
fmt.Println(nums)         // [0 0 0 0 0]
fmt.Println(len(nums))    // 5
```

---

## 8. `close`
Fecha um canal, avisando que **nenhuma mensagem nova será enviada**. Quem está recebendo consegue saber que o canal foi fechado. Cuidado: tentar enviar em um canal fechado causa um `panic` (erro grave que para o programa).

```go
canal := make(chan int, 3)
canal <- 1
canal <- 2
canal <- 3
close(canal)   // não vou enviar mais nada

// Receber do canal fechado funciona até esvaziar
for valor := range canal {
    fmt.Println(valor)   // 1, 2, 3
}

// Dá para checar se o canal foi fechado
valor, aberto := <-canal
if !aberto {
    fmt.Println("canal fechado")
}
```

---

## 9. `panic` e `recover`
- `panic` interrompe o programa com um erro grave (tipo um "alarme" que sobe pela pilha de chamadas das funções).
- `recover` "captura" um panic dentro de uma função `defer` (que roda no fim), permitindo que o programa continue rodando em vez de morrer.

Use com cuidado — em Go, o jeito comum de lidar com problemas é retornar um `error`, não dar panic.

```go
// Causando um panic
func dividir(a, b int) int {
    if b == 0 {
        panic("não posso dividir por zero")
    }
    return a / b
}

// Capturando o panic com recover
func seguro() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Erro capturado:", r)
        }
    }()

    dividir(10, 0)   // dispara o panic
    fmt.Println("essa linha não roda")
}

seguro()
fmt.Println("programa continua normalmente")
```

---

## 10. `min` e `max`
Funções novas (a partir do Go 1.21). Retornam o **menor** (`min`) ou o **maior** (`max`) entre dois ou mais valores. Funcionam com números e strings (comparados em ordem alfabética).

```go
// Com números
menor := min(3, 7, 1, 9)     // 1
maior := max(3, 7, 1, 9)     // 9

// Com floats
m := min(2.5, 1.7, 3.8)      // 1.7

// Com strings (ordem alfabética)
primeiro := min("banana", "maçã", "abacaxi")   // "abacaxi"

// Útil para limitar valores
nota := 12
notaFinal := min(nota, 10)   // garante no máximo 10
```

---

## 11. `print` e `println` (não use em produção)
Funções bem básicas que escrevem na saída de erro. **Existem só para ajudar nos primeiros testes** durante o desenvolvimento da própria linguagem Go. A documentação avisa que elas podem sumir em versões futuras.

Na vida real, use sempre o pacote `fmt` (com `fmt.Println`, `fmt.Printf` etc).

```go
// Funcionam, mas evite usar
print("oi\n")
println("Olá", "mundo")

// O jeito certo em programas reais
import "fmt"

fmt.Println("Olá, mundo!")
fmt.Printf("Idade: %d\n", 25)
```

---

## 12. `complex`, `real` e `imag`
Funções para mexer com **números complexos** (aqueles com uma parte "real" e uma "imaginária", usados em matemática avançada). Raramente aparecem no dia a dia, mas é bom saber que existem.

- `complex` monta um número complexo a partir de duas partes.
- `real` pega só a parte real.
- `imag` pega só a parte imaginária.

```go
// Criar um número complexo: 3 + 4i
c := complex(3, 4)
fmt.Println(c)            // (3+4i)

// Pegar as partes
fmt.Println(real(c))      // 3
fmt.Println(imag(c))      // 4

// Também dá para escrever direto
c2 := 2 + 5i
fmt.Println(real(c2))     // 2
fmt.Println(imag(c2))     // 5
```

---

Em resumo: as funções built-in de Go são ferramentas básicas que você usa o tempo todo — `len`, `append`, `make`, `delete` aparecem em quase todo programa, enquanto outras como `panic`/`recover` e `close` ficam para situações mais específicas. Como vêm de fábrica, não precisam de `import` e estão sempre prontas para uso.
