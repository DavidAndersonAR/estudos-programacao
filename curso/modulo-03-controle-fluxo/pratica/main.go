package main

import "fmt"

// Módulo 03 — Controle de Fluxo
// Prática: exercícios resolvidos com if/switch/for/break/continue.

// Exercício 1: Par ou ímpar
// Usa o operador % (resto da divisão) com um if/else simples.
func exercicio1() {
	numeros := []int{1, 2, 3, 7, 10, 15, 22}
	for _, n := range numeros {
		if n%2 == 0 {
			fmt.Printf("%d é par\n", n)
		} else {
			fmt.Printf("%d é ímpar\n", n)
		}
	}
}

// Exercício 2: FizzBuzz (clássico de entrevista)
// Para cada número de 1 a 20:
// - Múltiplo de 3 e 5 => "FizzBuzz"
// - Múltiplo de 3     => "Fizz"
// - Múltiplo de 5     => "Buzz"
// - Caso contrário    => o próprio número
// Note como o switch sem expressão deixa o código muito mais legível.
func exercicio2() {
	for i := 1; i <= 20; i++ {
		switch {
		case i%15 == 0:
			fmt.Println("FizzBuzz")
		case i%3 == 0:
			fmt.Println("Fizz")
		case i%5 == 0:
			fmt.Println("Buzz")
		default:
			fmt.Println(i)
		}
	}
}

// Exercício 3: Classificar nota (A, B, C, D, F)
// Demonstra if/else if encadeado.
func exercicio3() {
	notas := []float64{9.5, 7.8, 6.2, 4.0, 10.0}
	for _, nota := range notas {
		var conceito string
		if nota >= 9 {
			conceito = "A"
		} else if nota >= 7 {
			conceito = "B"
		} else if nota >= 5 {
			conceito = "C"
		} else if nota >= 3 {
			conceito = "D"
		} else {
			conceito = "F"
		}
		fmt.Printf("Nota %.1f => conceito %s\n", nota, conceito)
	}
}

// Exercício 4: Soma de 1 a N
// For clássico acumulando em uma variável.
func exercicio4() {
	N := 100
	soma := 0
	for i := 1; i <= N; i++ {
		soma += i
	}
	fmt.Printf("Soma de 1 a %d = %d\n", N, soma)
}

// Exercício 5: Encontrar o máximo num slice
// Percorremos com for-range, comparando cada item com o maior visto até agora.
func exercicio5() {
	valores := []int{12, 47, 8, 91, 23, 56, 4, 88}
	maior := valores[0]
	for _, v := range valores {
		if v > maior {
			maior = v
		}
	}
	fmt.Printf("Slice: %v\n", valores)
	fmt.Printf("Maior valor: %d\n", maior)
}

// Exercício 6: Contar quantos dígitos tem um número
// Usa for no estilo "while": enquanto n > 0, dividimos por 10.
func exercicio6() {
	numeros := []int{7, 42, 100, 9999, 12345}
	for _, n := range numeros {
		original := n
		contagem := 0
		if n == 0 {
			contagem = 1
		}
		for n > 0 {
			n /= 10
			contagem++
		}
		fmt.Printf("%d tem %d dígito(s)\n", original, contagem)
	}
}

// Exercício 7: Tabuada de um número
// For clássico de 1 a 10.
func exercicio7() {
	numero := 7
	fmt.Printf("Tabuada do %d:\n", numero)
	for i := 1; i <= 10; i++ {
		fmt.Printf("%d x %d = %d\n", numero, i, numero*i)
	}
}

// Exercício 8: Soma apenas dos pares de 1 a 50 (usando continue)
// Mostra como continue pula a iteração sem sair do laço.
func exercicio8() {
	soma := 0
	for i := 1; i <= 50; i++ {
		if i%2 != 0 {
			continue // pula ímpares
		}
		soma += i
	}
	fmt.Printf("Soma dos pares de 1 a 50 = %d\n", soma)
}

// Exercício 9 (bônus): Primeira potência de 2 maior que 1000 (usando break)
// For infinito com saída por break — padrão útil quando não sabemos quantas voltas vamos precisar.
func exercicio9() {
	valor := 1
	expoente := 0
	for {
		if valor > 1000 {
			break
		}
		valor *= 2
		expoente++
	}
	fmt.Printf("2^%d = %d (primeira potência de 2 maior que 1000)\n", expoente, valor)
}

func main() {
	fmt.Println("=== Exercício 1: Par ou Ímpar ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: FizzBuzz (1 a 20) ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Classificar Nota ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Soma de 1 a N ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Encontrar Máximo ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Contar Dígitos ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: Tabuada ===")
	exercicio7()

	fmt.Println("\n=== Exercício 8: Soma dos Pares (continue) ===")
	exercicio8()

	fmt.Println("\n=== Exercício 9: Potência de 2 > 1000 (break) ===")
	exercicio9()
}
