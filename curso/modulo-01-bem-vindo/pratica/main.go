package main

import "fmt"

// Módulo 01 — Bem-vindo ao Go
// Prática: experimentando as formas básicas de imprimir e estruturar um programa.

// Exercício 1: Hello World tradicional
// O programa mais simples possível em Go.
func exercicio1() {
	fmt.Println("Olá, mundo!")
}

// Exercício 2: Várias linhas com Println
// Cada Println pula uma linha no final.
func exercicio2() {
	fmt.Println("Linha 1")
	fmt.Println("Linha 2")
	fmt.Println("Linha 3")
}

// Exercício 3: Print (sem quebra automática) vs Println
// Note como o resultado fica grudado.
func exercicio3() {
	fmt.Print("sem ")
	fmt.Print("quebra ")
	fmt.Print("automática\n") // a quebra de linha é manual com \n
	fmt.Println("agora sim, com quebra")
}

// Exercício 4: Printf — formatação com placeholders
// %s = string, %d = inteiro, %f = decimal, %v = qualquer coisa
func exercicio4() {
	nome := "David"
	idade := 30
	altura := 1.75

	fmt.Printf("Nome: %s\n", nome)
	fmt.Printf("Idade: %d anos\n", idade)
	fmt.Printf("Altura: %.2f m\n", altura) // %.2f = 2 casas decimais
	fmt.Printf("Resumo: %s, %d, %v m\n", nome, idade, altura)
}

// Exercício 5: Múltiplos valores no Println
// Println coloca espaço entre os argumentos automaticamente.
func exercicio5() {
	fmt.Println("Olá,", "tudo", "bem?")
	fmt.Println("Soma:", 2+3)
	fmt.Println("Mistura:", "número", 42, "e booleano", true)
}

func main() {
	fmt.Println("=== Exercício 1: Hello World ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Várias linhas ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Print vs Println ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Printf ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Múltiplos valores ===")
	exercicio5()
}
