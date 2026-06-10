package main

import (
	"fmt"
	"strings"
)

// Exercícios avançados: Generics

// Exercício 1: Função genérica básica
// Função que devolve o último elemento de qualquer slice.
func Ultimo[T any](s []T) T {
	return s[len(s)-1]
}

func exercicio1() {
	fmt.Println(Ultimo([]int{1, 2, 3, 4}))       // 4
	fmt.Println(Ultimo([]string{"a", "b", "c"})) // c
}

// Exercício 2: Constraint comparable
// Função que verifica se um elemento existe num slice.
func Contem[T comparable](s []T, alvo T) bool {
	for _, v := range s {
		if v == alvo {
			return true
		}
	}
	return false
}

func exercicio2() {
	fmt.Println(Contem([]int{1, 2, 3}, 2))             // true
	fmt.Println(Contem([]string{"a", "b"}, "x"))       // false
	fmt.Println(Contem([]float64{1.1, 2.2, 3.3}, 2.2)) // true
}

// Exercício 3: União de tipos numéricos
// Função que soma todos os elementos de um slice numérico.
type Numero interface {
	~int | ~int64 | ~float64 | ~float32
}

func Soma[T Numero](s []T) T {
	var total T
	for _, v := range s {
		total += v
	}
	return total
}

func exercicio3() {
	fmt.Println(Soma([]int{1, 2, 3, 4, 5}))               // 15
	fmt.Println(Soma([]float64{1.5, 2.5, 3.0}))           // 7.0
	type Idade int
	fmt.Println(Soma([]Idade{25, 30, 35})) // 90 — funciona com tipo derivado
}

// Exercício 4: Tipo genérico (struct)
// Implementar uma fila genérica (FIFO).
type Fila[T any] struct {
	itens []T
}

func (f *Fila[T]) Enfileirar(v T) {
	f.itens = append(f.itens, v)
}

func (f *Fila[T]) Desenfileirar() (T, bool) {
	var zero T
	if len(f.itens) == 0 {
		return zero, false
	}
	primeiro := f.itens[0]
	f.itens = f.itens[1:]
	return primeiro, true
}

func (f *Fila[T]) Tamanho() int {
	return len(f.itens)
}

func exercicio4() {
	f := Fila[string]{}
	f.Enfileirar("primeiro")
	f.Enfileirar("segundo")
	f.Enfileirar("terceiro")

	for f.Tamanho() > 0 {
		v, _ := f.Desenfileirar()
		fmt.Println("Saiu:", v)
	}
}

// Exercício 5: Map e Filter genéricos (estilo funcional)
func Map[T, U any](s []T, fn func(T) U) []U {
	resultado := make([]U, len(s))
	for i, v := range s {
		resultado[i] = fn(v)
	}
	return resultado
}

func Filter[T any](s []T, pred func(T) bool) []T {
	resultado := []T{}
	for _, v := range s {
		if pred(v) {
			resultado = append(resultado, v)
		}
	}
	return resultado
}

func exercicio5() {
	nums := []int{1, 2, 3, 4, 5}

	dobrados := Map(nums, func(n int) int { return n * 2 })
	fmt.Println("Dobrados:", dobrados)

	pares := Filter(nums, func(n int) bool { return n%2 == 0 })
	fmt.Println("Pares:", pares)

	// Combinando: transformar em string
	textos := Map(nums, func(n int) string {
		return strings.Repeat("*", n)
	})
	fmt.Println("Em estrelas:", textos)
}

// Exercício 6: Reduce genérico
func Reduce[T, U any](s []T, inicial U, fn func(U, T) U) U {
	acc := inicial
	for _, v := range s {
		acc = fn(acc, v)
	}
	return acc
}

func exercicio6() {
	nums := []int{1, 2, 3, 4, 5}
	soma := Reduce(nums, 0, func(acc, n int) int { return acc + n })
	produto := Reduce(nums, 1, func(acc, n int) int { return acc * n })
	concat := Reduce(nums, "", func(acc string, n int) string {
		return acc + fmt.Sprint(n)
	})

	fmt.Println("Soma:", soma)
	fmt.Println("Produto:", produto)
	fmt.Println("Concatenado:", concat)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	exercicio6()
}
