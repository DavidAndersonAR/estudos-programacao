package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 18 — Biblioteca Utilitária Genérica
//
// Objetivo:
// Construir uma pequena "stdlib pessoal" de utilitários sobre slices, usando
// generics. Esse é o tipo de pacote que, depois de pronto, você reusa pelo
// resto da vida. Pense nele como o seu "lodash" / "Enumerable" do Go.
//
// Você precisa implementar SEIS funções genéricas, todas no `package main`
// deste arquivo, e demonstrar cada uma com pelo menos um exemplo no `main`.
//
// 1) Map[T, U](s []T, f func(T) U) []U
//    Aplica `f` em cada elemento de `s`, devolvendo uma nova slice com os
//    resultados. Comprimento de saída = comprimento de entrada.
//
// 2) Filter[T](s []T, manter func(T) bool) []T
//    Mantém apenas os elementos para os quais `manter` retorna true.
//
// 3) Reduce[T, U](s []T, inicial U, f func(acc U, v T) U) U
//    Acumula um único valor a partir da slice. Começa em `inicial` e vai
//    aplicando `f`. Útil pra somas, concatenações, montar mapas, etc.
//
// 4) Distintos[T comparable](s []T) []T
//    Devolve uma nova slice sem duplicatas, PRESERVANDO a ordem da primeira
//    aparição. (Constraint comparable, porque precisamos comparar com ==.)
//
// 5) MinMax[T cmp.Ordered](s []T) (T, T, bool)
//    Retorna (mínimo, máximo, true). Se a slice estiver vazia, retorna o
//    zero-value de T pra ambos e bool=false. `cmp.Ordered` vem do pacote
//    `cmp` (Go 1.21+) e cobre números, strings e tipos derivados.
//
// 6) Agrupar[T any, K comparable](s []T, chave func(T) K) map[K][]T
//    Agrupa elementos por uma chave produzida pela função `chave`. Útil pra
//    classificar coisas (alunos por turma, vendas por mês, etc).
//
// Requisitos do main:
// - Demonstrar TODAS as funções com pelo menos um exemplo diferente.
// - Pelo menos UM exemplo deve combinar duas ou mais delas (ex: Filter +
//   Distintos, ou Map + Reduce).
//
// 💡 Dicas:
// - Para `MinMax`, importe `"cmp"` e use `cmp.Ordered`. Vale também declarar
//   uma constraint própria com union se você não quiser depender de `cmp`.
// - Em `Agrupar`, o map já agrupa naturalmente: `m[k] = append(m[k], v)`.
// - `Distintos` precisa de um `map[T]struct{}` interno como "set" pra marcar
//   o que já apareceu. `struct{}` ocupa zero bytes.
// - Não importe `"slices"` neste desafio — a graça é IMPLEMENTAR utilitários,
//   não usar os prontos. (Você já viu o pacote `slices` na prática.)

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente as funções e seus exemplos aqui.
	//
	// Esqueleto sugerido (descomente conforme for implementando):
	//
	//   nums := []int{1, 2, 3, 4, 5}
	//   dobrados := Map(nums, func(n int) int { return n * 2 })
	//   fmt.Println(dobrados) // [2 4 6 8 10]
	//
	//   pares := Filter(nums, func(n int) bool { return n%2 == 0 })
	//   fmt.Println(pares)
	//
	//   total := Reduce(nums, 0, func(acc, v int) int { return acc + v })
	//   fmt.Println(total)
	//
	//   sem := Distintos([]string{"a", "b", "a", "c", "b"})
	//   fmt.Println(sem)
	//
	//   minimo, maximo, ok := MinMax([]int{3, 1, 4, 1, 5, 9, 2, 6})
	//   fmt.Println(minimo, maximo, ok)
	//
	//   palavras := []string{"go", "rust", "vim", "git", "zig"}
	//   porTamanho := Agrupar(palavras, func(s string) int { return len(s) })
	//   fmt.Println(porTamanho)
	fmt.Println("(implemente sua biblioteca utilitária genérica aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
import (
	"cmp"
	"fmt"
	"sort"
)

// ----- 1) Map -----
// Aplica `f` em cada elemento. Dois type parameters: T (entrada) e U (saída).
// O comprimento do resultado é exatamente o mesmo da entrada, então
// usamos `make` com tamanho fixo (mais eficiente que `append`).
func Map[T any, U any](s []T, f func(T) U) []U {
	resultado := make([]U, len(s))
	for i, v := range s {
		resultado[i] = f(v)
	}
	return resultado
}

// ----- 2) Filter -----
// Capacidade inicial = len(s) é um chute razoável (no pior caso, nada é
// filtrado e não precisamos realocar).
func Filter[T any](s []T, manter func(T) bool) []T {
	resultado := make([]T, 0, len(s))
	for _, v := range s {
		if manter(v) {
			resultado = append(resultado, v)
		}
	}
	return resultado
}

// ----- 3) Reduce -----
// `inicial` define o zero do acumulador E o tipo de saída U. É por isso que
// dá pra reduzir []int em string, por exemplo — basta passar "" como inicial.
func Reduce[T any, U any](s []T, inicial U, f func(acc U, v T) U) U {
	acc := inicial
	for _, v := range s {
		acc = f(acc, v)
	}
	return acc
}

// ----- 4) Distintos -----
// Constraint `comparable` porque precisamos do `==` (implícito no uso como
// chave de map). Usamos um set (map para struct{} vazio) pra detectar quem
// já vimos. struct{} não ocupa memória; é o jeito idiomático de "set" em Go.
func Distintos[T comparable](s []T) []T {
	visto := make(map[T]struct{}, len(s))
	resultado := make([]T, 0, len(s))
	for _, v := range s {
		if _, ja := visto[v]; ja {
			continue
		}
		visto[v] = struct{}{} // marcador "presente"
		resultado = append(resultado, v)
	}
	return resultado
}

// ----- 5) MinMax -----
// `cmp.Ordered` (Go 1.21+) é a constraint pronta pra tipos que aceitam <, <=,
// >, >=. Cobre todos os números e strings. Inicializamos min e max com o
// PRIMEIRO elemento — não com `var zero T`, porque o zero pode não ser o
// menor (ex: slice [-5, -3, -10] o zero `0` daria errado).
func MinMax[T cmp.Ordered](s []T) (T, T, bool) {
	var zero T
	if len(s) == 0 {
		return zero, zero, false
	}
	minV, maxV := s[0], s[0]
	for _, v := range s[1:] {
		if v < minV {
			minV = v
		}
		if v > maxV {
			maxV = v
		}
	}
	return minV, maxV, true
}

// ----- 6) Agrupar -----
// `T any` porque podemos agrupar qualquer coisa. `K comparable` porque K vai
// ser CHAVE de map (toda chave de map em Go precisa ser comparable).
func Agrupar[T any, K comparable](s []T, chave func(T) K) map[K][]T {
	resultado := make(map[K][]T)
	for _, v := range s {
		k := chave(v)
		resultado[k] = append(resultado[k], v) // append em map[K][]T funciona mesmo se a chave não existir ainda (nil slice + append = ok)
	}
	return resultado
}

// ============================
// Demonstração
// ============================

type Pessoa struct {
	Nome  string
	Idade int
	Cidade string
}

func main() {
	// ---------- 1) Map ----------
	fmt.Println("=== Map ===")
	nums := []int{1, 2, 3, 4, 5}
	dobrados := Map(nums, func(n int) int { return n * 2 })
	fmt.Println("Dobrados:", dobrados) // [2 4 6 8 10]

	// Map com mudança de tipo: int -> string
	rotulados := Map(nums, func(n int) string {
		return fmt.Sprintf("item-%d", n)
	})
	fmt.Println("Rótulos:", rotulados)

	// ---------- 2) Filter ----------
	fmt.Println("\n=== Filter ===")
	pares := Filter(nums, func(n int) bool { return n%2 == 0 })
	fmt.Println("Pares:", pares) // [2 4]

	palavras := []string{"go", "rust", "vim", "git", "zig", "javascript"}
	curtas := Filter(palavras, func(s string) bool { return len(s) <= 3 })
	fmt.Println("Palavras curtas:", curtas) // [go vim git zig]

	// ---------- 3) Reduce ----------
	fmt.Println("\n=== Reduce ===")
	soma := Reduce(nums, 0, func(acc, v int) int { return acc + v })
	fmt.Println("Soma:", soma) // 15

	// Reduce trocando tipo: []int -> string concatenada
	concat := Reduce(nums, "", func(acc string, v int) string {
		return acc + fmt.Sprintf("[%d]", v)
	})
	fmt.Println("Concat:", concat) // [1][2][3][4][5]

	// ---------- 4) Distintos ----------
	fmt.Println("\n=== Distintos ===")
	comDup := []string{"a", "b", "a", "c", "b", "d", "a"}
	fmt.Println("Sem duplicatas:", Distintos(comDup)) // [a b c d]

	idsRepetidos := []int{10, 20, 10, 30, 20, 40, 10}
	fmt.Println("IDs únicos:", Distintos(idsRepetidos)) // [10 20 30 40]

	// ---------- 5) MinMax ----------
	fmt.Println("\n=== MinMax ===")
	mn, mx, ok := MinMax([]int{3, 1, 4, 1, 5, 9, 2, 6})
	fmt.Printf("min=%d, max=%d, ok=%t\n", mn, mx, ok)

	mnS, mxS, _ := MinMax([]string{"banana", "ame", "caju", "damasco"})
	fmt.Printf("min=%q, max=%q\n", mnS, mxS) // "ame", "damasco"

	_, _, ok = MinMax([]float64{}) // slice vazia
	fmt.Println("Slice vazia ok?", ok) // false

	// ---------- 6) Agrupar ----------
	fmt.Println("\n=== Agrupar ===")
	pessoas := []Pessoa{
		{"Ana", 30, "São Paulo"},
		{"Bia", 25, "Rio"},
		{"Caio", 30, "São Paulo"},
		{"Dani", 25, "Curitiba"},
		{"Eva", 40, "Rio"},
	}

	porCidade := Agrupar(pessoas, func(p Pessoa) string { return p.Cidade })
	// Ordena as chaves só para a saída ficar determinística (map é aleatório).
	cidades := make([]string, 0, len(porCidade))
	for c := range porCidade {
		cidades = append(cidades, c)
	}
	sort.Strings(cidades)
	for _, c := range cidades {
		fmt.Printf("%-12s -> %d pessoas\n", c, len(porCidade[c]))
	}

	// Agrupar por idade — agora a chave é int.
	porIdade := Agrupar(pessoas, func(p Pessoa) int { return p.Idade })
	fmt.Println("Grupos por idade:", len(porIdade), "grupos distintos")

	// ---------- Combinação: Filter + Map + Reduce ----------
	// "Soma dos quadrados dos pares" — clássico encadeamento funcional.
	fmt.Println("\n=== Combinação (Filter + Map + Reduce) ===")
	dados := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	resultado := Reduce(
		Map(
			Filter(dados, func(n int) bool { return n%2 == 0 }), // pares
			func(n int) int { return n * n },                    // ao quadrado
		),
		0,
		func(acc, v int) int { return acc + v }, // soma
	)
	fmt.Println("Soma dos quadrados dos pares:", resultado) // 4+16+36+64+100 = 220

	// ---------- Combinação: Distintos + MinMax ----------
	fmt.Println("\n=== Combinação (Distintos + MinMax) ===")
	bagunca := []int{5, 3, 8, 3, 1, 5, 9, 1, 8, 2}
	unicos := Distintos(bagunca)
	mn2, mx2, _ := MinMax(unicos)
	fmt.Printf("Únicos=%v, min=%d, max=%d\n", unicos, mn2, mx2)
}
*/
