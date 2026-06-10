package main

import (
	"errors"
	"fmt"
)

// Módulo 17 — Testes
// Prática: funções simples que serão testadas no arquivo main_test.go.
//
// IMPORTANTE: para os testes funcionarem, este arquivo e o main_test.go
// precisam estar no MESMO pacote (package main).

// Somar retorna a soma de dois inteiros.
func Somar(a, b int) int {
	return a + b
}

// Subtrair retorna a - b.
func Subtrair(a, b int) int {
	return a - b
}

// Multiplicar retorna a * b.
func Multiplicar(a, b int) int {
	return a * b
}

// Dividir retorna a/b ou um erro se b for zero.
// Note como devolver erro em vez de fazer panic é o jeito idiomático em Go.
func Dividir(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("divisão por zero")
	}
	return a / b, nil
}

// EhPar retorna true se n for par.
func EhPar(n int) bool {
	return n%2 == 0
}

// Reverter inverte os caracteres de uma string.
// Usa []rune para suportar caracteres acentuados/UTF-8 sem cortar bytes no meio.
func Reverter(s string) string {
	runas := []rune(s)
	for i, j := 0, len(runas)-1; i < j; i, j = i+1, j-1 {
		runas[i], runas[j] = runas[j], runas[i]
	}
	return string(runas)
}

func main() {
	// main() só serve para mostrar que as funções funcionam.
	// A graça mesmo está nos testes — veja main_test.go.
	fmt.Println("=== Demonstração rápida das funções ===")
	fmt.Println("Somar(2, 3)         =", Somar(2, 3))
	fmt.Println("Subtrair(10, 4)     =", Subtrair(10, 4))
	fmt.Println("Multiplicar(6, 7)   =", Multiplicar(6, 7))

	resultado, err := Dividir(10, 2)
	if err != nil {
		fmt.Println("Erro:", err)
	} else {
		fmt.Println("Dividir(10, 2)      =", resultado)
	}

	fmt.Println("EhPar(4)            =", EhPar(4))
	fmt.Println("Reverter(\"Olá!\")   =", Reverter("Olá!"))

	fmt.Println("\nAgora rode os testes:")
	fmt.Println("  go test ./curso/modulo-17-testes/pratica -v")
	fmt.Println("  go test ./curso/modulo-17-testes/pratica -cover")
	fmt.Println("  go test ./curso/modulo-17-testes/pratica -bench=.")
}
