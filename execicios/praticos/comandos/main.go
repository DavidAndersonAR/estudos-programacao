package main

import "fmt"

// Exercícios práticos: Comandos (Statements)

// Exercício 1: if/else — verificar se número é par ou ímpar
func exercicio1() {
	n := 7
	if n%2 == 0 {
		fmt.Println(n, "é par")
	} else {
		fmt.Println(n, "é ímpar")
	}
}

// Exercício 2: switch — categorizar uma nota
func categorizarNota(nota float64) string {
	switch {
	case nota >= 9:
		return "Excelente"
	case nota >= 7:
		return "Bom"
	case nota >= 5:
		return "Regular"
	default:
		return "Reprovado"
	}
}

func exercicio2() {
	fmt.Println("Nota 9.5:", categorizarNota(9.5))
	fmt.Println("Nota 7.2:", categorizarNota(7.2))
	fmt.Println("Nota 4.0:", categorizarNota(4.0))
}

// Exercício 3: switch com fallthrough
// fallthrough faz cair no próximo case sem checar condição.
func exercicio3() {
	dia := 3
	switch dia {
	case 1:
		fmt.Println("Domingo")
	case 2, 3, 4, 5, 6:
		fmt.Println("Dia útil")
		fallthrough
	case 7:
		fmt.Println("(continuou no próximo case)")
	}
}

// Exercício 4: for clássico — somar de 1 até N
func somar(n int) int {
	total := 0
	for i := 1; i <= n; i++ {
		total += i
	}
	return total
}

func exercicio4() {
	fmt.Println("Soma de 1 a 10:", somar(10))
}

// Exercício 5: for-range em slice
func exercicio5() {
	frutas := []string{"maçã", "banana", "uva", "laranja"}
	for indice, fruta := range frutas {
		fmt.Printf("%d: %s\n", indice, fruta)
	}
}

// Exercício 6: for-range em map
func exercicio6() {
	precos := map[string]float64{
		"café":  5.50,
		"pão":   1.20,
		"leite": 4.90,
	}
	for produto, preco := range precos {
		fmt.Printf("%s custa R$ %.2f\n", produto, preco)
	}
}

// Exercício 7: defer — ordem reversa (último a entrar é o primeiro a sair)
func exercicio7() {
	fmt.Println("Início")
	defer fmt.Println("Adiado 1") // será executado por último
	defer fmt.Println("Adiado 2") // será executado segundo
	defer fmt.Println("Adiado 3") // será executado primeiro
	fmt.Println("Fim do corpo")
	// Saída: Início, Fim do corpo, Adiado 3, Adiado 2, Adiado 1
}

// Exercício 8: break e continue — filtrar pares e parar no 10
func exercicio8() {
	for i := 1; i <= 20; i++ {
		if i%2 != 0 {
			continue // pula ímpares
		}
		if i > 10 {
			break // para depois do 10
		}
		fmt.Println(i)
	}
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	exercicio6()
	exercicio7()
	exercicio8()
}
