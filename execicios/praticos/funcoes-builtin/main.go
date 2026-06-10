package main

import "fmt"

// Exercícios práticos: Funções Built-in
// Funções que já vêm prontas no Go, sem precisar importar.

// Exercício 1: len e cap
// len = tamanho atual; cap = capacidade total do slice.
func exercicio1() {
	s := make([]int, 3, 10) // tamanho 3, capacidade 10
	s[0], s[1], s[2] = 1, 2, 3

	fmt.Println("Tamanho:", len(s))     // 3
	fmt.Println("Capacidade:", cap(s))  // 10

	texto := "Olá"
	fmt.Println("Tamanho da string:", len(texto)) // bytes (3 no caso)
}

// Exercício 2: append — adicionar elementos a um slice
func exercicio2() {
	numeros := []int{1, 2, 3}
	numeros = append(numeros, 4)            // 1 elemento
	numeros = append(numeros, 5, 6, 7)      // vários elementos
	outros := []int{8, 9, 10}
	numeros = append(numeros, outros...)    // spread de outro slice
	fmt.Println(numeros)
}

// Exercício 3: copy — clonar um slice (para evitar referência compartilhada)
func exercicio3() {
	original := []int{10, 20, 30}
	copia := make([]int, len(original))
	copy(copia, original)

	copia[0] = 999 // altera só a cópia
	fmt.Println("Original:", original) // [10 20 30]
	fmt.Println("Cópia:", copia)       // [999 20 30]
}

// Exercício 4: make — criar slice, map e canal
func exercicio4() {
	slice := make([]int, 5)            // slice de tamanho 5
	mapa := make(map[string]int)        // map vazio
	canal := make(chan int, 3)          // canal com buffer 3

	slice[0] = 100
	mapa["chave"] = 42
	canal <- 7

	fmt.Println(slice, mapa, <-canal)
}

// Exercício 5: delete — remover chave de um map
func exercicio5() {
	produtos := map[string]float64{
		"café":  5.50,
		"pão":   1.20,
		"leite": 4.90,
	}
	delete(produtos, "leite")
	fmt.Println(produtos)
}

// Exercício 6: new — criar ponteiro com valor zero
func exercicio6() {
	p := new(int) // ponteiro para um int com valor 0
	fmt.Println("Valor inicial:", *p) // 0
	*p = 42
	fmt.Println("Após atribuir:", *p) // 42
}

// Exercício 7: min e max (Go 1.21+)
func exercicio7() {
	menor := min(3, 7, 1, 9, 4)
	maior := max(3, 7, 1, 9, 4)
	fmt.Println("Menor:", menor) // 1
	fmt.Println("Maior:", maior) // 9
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	exercicio6()
	exercicio7()
}
