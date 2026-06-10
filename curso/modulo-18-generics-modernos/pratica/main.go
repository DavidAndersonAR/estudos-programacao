package main

import (
	"fmt"
	"maps"
	"slices"
	"strings"
)

// Módulo 18 — Generics e Padrões Modernos
// Prática: do básico (T any) até constraints próprias, tipos genéricos e os
// pacotes modernos `slices` e `maps`. Requer Go 1.21+ (para slices/maps/min/max).

// =============================================================================
// Exercício 1: Primeiro[T any] — pegar o primeiro elemento de uma slice qualquer
// =============================================================================
// `any` é a constraint mais permissiva: aceita literalmente qualquer tipo.
// Devolvemos também um bool indicando se havia alguém ali — assim não explode
// se a slice estiver vazia.
func Primeiro[T any](lista []T) (T, bool) {
	var zero T // zero value do tipo T (0 para int, "" para string, etc)
	if len(lista) == 0 {
		return zero, false
	}
	return lista[0], true
}

func exercicio1() {
	// O compilador INFERE T = int só de olhar o argumento.
	n, ok := Primeiro([]int{10, 20, 30})
	fmt.Printf("Primeiro int: %d (ok=%t)\n", n, ok)

	// Agora T = string. Mesmo código, tipos diferentes.
	s, ok := Primeiro([]string{"go", "rust", "zig"})
	fmt.Printf("Primeiro string: %q (ok=%t)\n", s, ok)

	// Caso vazio: devolve zero value e false.
	z, ok := Primeiro([]float64{})
	fmt.Printf("Slice vazia: %v (ok=%t)\n", z, ok)
}

// =============================================================================
// Exercício 2: Contem[T comparable] — busca linear genérica
// =============================================================================
// Usamos `comparable` porque precisamos do operador `==` lá dentro. Sem essa
// constraint o compilador não nos deixaria comparar — e está certo, porque
// slice/map/função não são comparáveis com ==.
func Contem[T comparable](lista []T, alvo T) bool {
	for _, v := range lista {
		if v == alvo {
			return true
		}
	}
	return false
}

func exercicio2() {
	nums := []int{1, 2, 3, 4, 5}
	fmt.Println("Contém 3?", Contem(nums, 3))   // true
	fmt.Println("Contém 99?", Contem(nums, 99)) // false

	palavras := []string{"go", "vai", "longe"}
	fmt.Println("Contém 'go'?", Contem(palavras, "go")) // true
}

// =============================================================================
// Exercício 3: Soma[T Numero] — constraint própria com interface nomeada
// =============================================================================
// Criamos uma "interface só pra constraint". Note o `~`: ele aceita também
// tipos derivados (ex: `type Idade int`). Sem `~`, só os tipos exatos passam.
type Numero interface {
	~int | ~int64 | ~float32 | ~float64
}

func Soma[T Numero](nums []T) T {
	var total T // zero value (0) — funciona pra qualquer tipo numérico
	for _, n := range nums {
		total += n
	}
	return total
}

// Tipo derivado pra mostrar o `~` em ação.
type Idade int

func exercicio3() {
	fmt.Println("Soma de ints:", Soma([]int{1, 2, 3, 4, 5}))             // 15
	fmt.Println("Soma de floats:", Soma([]float64{1.5, 2.5, 3.0}))       // 7
	fmt.Println("Soma de idades:", Soma([]Idade{18, 25, 30, 40}))        // 113 — só funciona por causa do ~int
}

// =============================================================================
// Exercício 4: Map / Filter / Reduce genéricos — o trio clássico funcional
// =============================================================================
// Esses três aparecem em quase toda linguagem moderna. Em Go a gente só ganhou
// versões genéricas reais depois do 1.18.

// Map transforma cada elemento de []T em []U, aplicando f.
// Repare: SÃO DOIS type parameters — T (entrada) e U (saída).
func Map[T any, U any](lista []T, f func(T) U) []U {
	resultado := make([]U, len(lista))
	for i, v := range lista {
		resultado[i] = f(v)
	}
	return resultado
}

// Filter mantém só os elementos onde o predicado retorna true.
func Filter[T any](lista []T, manter func(T) bool) []T {
	resultado := make([]T, 0, len(lista)) // capacidade inicial = tamanho de entrada
	for _, v := range lista {
		if manter(v) {
			resultado = append(resultado, v)
		}
	}
	return resultado
}

// Reduce "dobra" a slice num único valor, acumulando.
// Começa em `inicial` (que define o zero) e vai aplicando f.
func Reduce[T any, U any](lista []T, inicial U, f func(acc U, v T) U) U {
	acc := inicial
	for _, v := range lista {
		acc = f(acc, v)
	}
	return acc
}

func exercicio4() {
	nums := []int{1, 2, 3, 4, 5}

	// Map: int -> string ("nº 1", "nº 2", ...)
	rotulos := Map(nums, func(n int) string {
		return fmt.Sprintf("nº %d", n)
	})
	fmt.Println("Map:", rotulos)

	// Filter: só pares.
	pares := Filter(nums, func(n int) bool { return n%2 == 0 })
	fmt.Println("Filter pares:", pares) // [2 4]

	// Reduce: soma manual com Reduce (acabamos de reimplementar Soma).
	total := Reduce(nums, 0, func(acc, v int) int { return acc + v })
	fmt.Println("Reduce soma:", total) // 15

	// Reduce também serve pra construir string (T=int, U=string):
	concat := Reduce(nums, "", func(acc string, v int) string {
		return acc + fmt.Sprintf("[%d]", v)
	})
	fmt.Println("Reduce concat:", concat) // [1][2][3][4][5]
}

// =============================================================================
// Exercício 5: Pilha[T any] — tipo genérico (struct) com métodos
// =============================================================================
// Última in, primeiro out (LIFO). O tipo do conteúdo é parametrizado.
type Pilha[T any] struct {
	itens []T
}

// Receiver de ponteiro porque vamos modificar o slice interno.
// Note: NÃO redeclaramos `[T any]` aqui — usamos `Pilha[T]` direto.
func (p *Pilha[T]) Empilhar(v T) {
	p.itens = append(p.itens, v)
}

// Devolvemos (valor, ok) — o `ok=false` cobre pilha vazia.
func (p *Pilha[T]) Desempilhar() (T, bool) {
	var zero T
	if len(p.itens) == 0 {
		return zero, false
	}
	topo := p.itens[len(p.itens)-1]
	p.itens = p.itens[:len(p.itens)-1]
	return topo, true
}

func (p *Pilha[T]) Tamanho() int {
	return len(p.itens)
}

func exercicio5() {
	// Pilha de strings — precisa especificar o tipo na criação.
	pp := Pilha[string]{}
	pp.Empilhar("a")
	pp.Empilhar("b")
	pp.Empilhar("c")
	fmt.Println("Tamanho:", pp.Tamanho()) // 3

	for pp.Tamanho() > 0 {
		v, _ := pp.Desempilhar()
		fmt.Println("Desempilhou:", v) // c, b, a (ordem reversa)
	}

	// Caso pilha vazia.
	_, ok := pp.Desempilhar()
	fmt.Println("Desempilhar vazia ok?", ok) // false

	// O MESMO código serve pra int — só trocar o tipo na declaração.
	pi := Pilha[int]{}
	pi.Empilhar(10)
	pi.Empilhar(20)
	v, _ := pi.Desempilhar()
	fmt.Println("Pilha de int — topo:", v) // 20
}

// =============================================================================
// Exercício 6: Pacote `slices` — Sort, Contains, Index (Go 1.21+)
// =============================================================================
// Antes a gente fazia isso na mão. Hoje a stdlib entrega. Por baixo é generics
// — por cima, é só importar `slices` e chamar.
func exercicio6() {
	nums := []int{3, 1, 4, 1, 5, 9, 2, 6, 5}
	fmt.Println("Antes do Sort:", nums)

	slices.Sort(nums) // ordena IN PLACE (modifica o slice original)
	fmt.Println("Depois do Sort:", nums)

	fmt.Println("Contains(5)?", slices.Contains(nums, 5))
	fmt.Println("Contains(99)?", slices.Contains(nums, 99))
	fmt.Println("Index(4):", slices.Index(nums, 4))   // posição (ou -1)
	fmt.Println("Index(99):", slices.Index(nums, 99)) // -1

	// Funciona com qualquer tipo ordenável.
	palavras := []string{"banana", "ame", "caju", "ame"}
	slices.Sort(palavras)
	fmt.Println("Strings ordenadas:", palavras)

	// Built-ins min/max também são genéricos (Go 1.21+) e aceitam N argumentos.
	fmt.Println("min/max:", min(3, 7, 1), max(3, 7, 1))
}

// =============================================================================
// Exercício 7: Pacote `maps` — Keys, Values
// =============================================================================
// `maps.Keys` e `maps.Values` retornam ITERATORS (Go 1.23). Pra coletar num
// slice, a gente usa `slices.Collect`. Também dá pra iterar direto com `range`.
func exercicio7() {
	estoque := map[string]int{
		"banana": 30,
		"ame":    50,
		"caju":   12,
	}

	// Coleta as chaves num slice e ordena (lembre: ordem de map é aleatória).
	chaves := slices.Collect(maps.Keys(estoque))
	slices.Sort(chaves)
	fmt.Println("Chaves ordenadas:", chaves)

	// Soma todos os valores usando Reduce (do exercício 4) + maps.Values.
	valores := slices.Collect(maps.Values(estoque))
	totalEstoque := Reduce(valores, 0, func(acc, v int) int { return acc + v })
	fmt.Println("Total em estoque:", totalEstoque)

	// Iterar direto na ordem das chaves ordenadas — receita comum:
	var b strings.Builder
	for _, k := range chaves {
		fmt.Fprintf(&b, "%s=%d  ", k, estoque[k])
	}
	fmt.Println("Resumo:", strings.TrimSpace(b.String()))
}

func main() {
	fmt.Println("=== Exercício 1: Primeiro[T any] ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Contem[T comparable] ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Soma[T Numero] (constraint própria) ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Map / Filter / Reduce ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Pilha[T any] (tipo genérico) ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: pacote slices (Sort, Contains, Index) ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: pacote maps (Keys, Values) ===")
	exercicio7()
}
