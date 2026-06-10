# Módulo 05 — Coleções

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diferenciar **arrays** (tamanho fixo) de **slices** (dinâmicos)
- Criar slices com `make` e crescer com `append`
- Usar `len`, `cap` e fatiar com `a[low:high]`
- Copiar slices com `copy` e iterar com `range`
- Criar e manipular **maps**: ler, escrever, deletar e checar existência
- Escolher entre slice e map de acordo com o problema

## 🤔 Por que precisamos de coleções?
Variáveis sozinhas guardam **um** valor. Mas a vida real é cheia de listas: lista de tarefas, lista de alunos, lista de produtos no carrinho, dicionário de preços. Coleções resolvem isso.

Em Go, as três coleções básicas são:
- **Array** — tamanho fixo, decidido em tempo de compilação. Pouco usado no dia a dia.
- **Slice** — uma "vista" sobre um array, dinâmica. É o que você vai usar 90% do tempo.
- **Map** — dicionário chave-valor. Útil para buscas rápidas.

## 🧱 Arrays — o ponto de partida

```go
var notas [3]int          // array de 3 inteiros, todos zerados
notas[0] = 10
notas[1] = 8
notas[2] = 9
fmt.Println(notas)        // [10 8 9]
fmt.Println(len(notas))   // 3
```

Detalhes importantes:
- O tamanho faz parte do **tipo**: `[3]int` é diferente de `[4]int`.
- Não dá pra crescer. Se precisar de mais espaço, você cria outro array.
- É copiado por valor: passar para uma função copia tudo.

Por causa dessas limitações, na prática usamos **slices**.

## 🧵 Slices — coleções dinâmicas

```go
// Forma 1: literal
nomes := []string{"Ana", "Bia", "Caio"}

// Forma 2: make (slice vazio com capacidade pré-alocada)
numeros := make([]int, 0, 5)  // len=0, cap=5

// Forma 3: a partir de outro slice (fatiar)
parte := nomes[0:2]           // ["Ana", "Bia"]
```

### `append` — o jeito de crescer

```go
nums := []int{1, 2, 3}
nums = append(nums, 4)         // [1 2 3 4]
nums = append(nums, 5, 6, 7)   // [1 2 3 4 5 6 7]

outros := []int{8, 9}
nums = append(nums, outros...) // junta dois slices (o "..." é obrigatório)
```

⚠️ `append` pode devolver um slice novo (se ele precisou crescer o array interno). **Sempre reatribua**: `s = append(s, x)`.

### `len` e `cap`

```go
s := make([]int, 3, 10)
fmt.Println(len(s))  // 3  -> quantos elementos tem
fmt.Println(cap(s))  // 10 -> quanto cabe sem realocar
```

### Fatiar — `a[low:high]`

```go
s := []int{10, 20, 30, 40, 50}
fmt.Println(s[1:4])  // [20 30 40]   -> índice 1, 2, 3 (high é exclusivo)
fmt.Println(s[:3])   // [10 20 30]   -> do começo até o 3
fmt.Println(s[2:])   // [30 40 50]   -> do 2 até o fim
fmt.Println(s[:])    // cópia rasa do slice inteiro
```

⚠️ Slices fatiados **compartilham** o array por baixo. Mexer em um pode afetar o outro.

### `copy` — copiar de verdade

```go
origem := []int{1, 2, 3}
destino := make([]int, len(origem))
n := copy(destino, origem)
fmt.Println(destino, "copiados:", n)  // [1 2 3] copiados: 3
```

### `range` em slice

```go
nomes := []string{"Ana", "Bia", "Caio"}
for i, nome := range nomes {
    fmt.Printf("%d: %s\n", i, nome)
}

// Se você só quer o valor, use _ no índice:
for _, nome := range nomes {
    fmt.Println(nome)
}
```

## 🗺️ Maps — dicionário chave-valor

```go
// Forma 1: literal
idades := map[string]int{
    "Ana":  30,
    "Bia":  25,
    "Caio": 40,
}

// Forma 2: make
precos := make(map[string]float64)
precos["pao"] = 0.75
precos["leite"] = 5.20
```

### Lendo um map

```go
fmt.Println(idades["Ana"])  // 30
fmt.Println(idades["Zé"])   // 0   -> chave inexistente devolve o "zero value"
```

⚠️ `idades["Zé"]` devolveu `0`, mas o Zé não está no map. Cuidado!

### Checagem de existência — `v, ok := m[k]`

```go
v, ok := idades["Ana"]
fmt.Println(v, ok)  // 30 true

v, ok = idades["Zé"]
fmt.Println(v, ok)  // 0 false  -> agora sabemos que não existe
```

Esse padrão `v, ok :=` é **fundamental** em Go. Você vai ver ele em muitos lugares.

### `delete` — remover chave

```go
delete(idades, "Bia")
fmt.Println(idades)  // map[Ana:30 Caio:40]
```

Deletar uma chave que não existe **não dá erro**. Simplesmente não faz nada.

### `range` em map

```go
for chave, valor := range idades {
    fmt.Printf("%s tem %d anos\n", chave, valor)
}
```

⚠️ A ordem dos itens em um map **não é garantida**. A cada execução pode mudar. Se você precisa de ordem, ordene as chaves separadamente.

## 💡 Detalhes que valem ouro
- **Slice nil vs vazio**: `var s []int` cria um slice `nil` (mas pode receber `append` normalmente). `s := []int{}` cria um slice vazio não-nil. Para a maioria dos casos, o nil já serve.
- **Map nil é leitura-apenas**: `var m map[string]int` permite ler (devolve zero value), mas **escrever causa panic**. Sempre crie com `make` ou literal antes de escrever.
- **Slice de slice (matriz)**: `[][]int` é uma "matriz". Cada linha é um slice independente.
- **Comparação**: você não pode comparar slices nem maps com `==` (só com `nil`). Para igualdade real, percorra os dois.

## 👀 Variações para entender melhor

```go
// Removendo elemento do meio de um slice (índice i)
s := []int{10, 20, 30, 40, 50}
i := 2
s = append(s[:i], s[i+1:]...)  // remove o 30 -> [10 20 40 50]

// Contando frequência com map
texto := []string{"go", "py", "go", "go", "py"}
contagem := map[string]int{}
for _, palavra := range texto {
    contagem[palavra]++  // zero value (0) + 1 funciona no primeiro
}
fmt.Println(contagem)  // map[go:3 py:2]

// Map com slice como valor (agrupar)
porInicial := map[string][]string{}
nomes := []string{"Ana", "Alex", "Bia", "Bruno"}
for _, n := range nomes {
    letra := string(n[0])
    porInicial[letra] = append(porInicial[letra], n)
}
fmt.Println(porInicial)  // map[A:[Ana Alex] B:[Bia Bruno]]
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e estude os exercícios resolvidos.
2. Rode: `go run ./curso/modulo-05-colecoes/pratica`
3. Mexa nos slices/maps — adicione, remova, fatie de outras formas.
4. Encare o **desafio**: construir um **Gerenciador de Tarefas em Memória**.

## ✅ Auto-verificação
- [ ] Sei a diferença entre array e slice
- [ ] Uso `append` reatribuindo o resultado
- [ ] Sei fatiar com `a[low:high]` e entendo que `high` é exclusivo
- [ ] Uso o padrão `v, ok := m[k]` para checar existência
- [ ] Sei que map nil não aceita escrita, mas slice nil aceita `append`
- [ ] Consigo iterar slice e map com `range`

Próximo módulo: **Structs e Métodos** — onde você vai criar seus próprios tipos.
