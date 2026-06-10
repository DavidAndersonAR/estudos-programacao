package main

import (
	"errors"
	"fmt"
)

// Módulo 04 — Funções
// Prática: do básico (somar dois números) ao avançado (closures e defer).
// Cada exercício é uma função separada. O main no fim chama todas.

// Exercício 1: Função simples com dois parâmetros e um retorno
// Note como tipos iguais foram agrupados: (a, b int).
func somar(a, b int) int {
	return a + b
}

// Exercício 2: Retorno múltiplo (resultado, erro)
// Padrão clássico do Go: nunca lance exceção, devolva o erro.
func dividir(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("divisão por zero não é permitida")
	}
	return a / b, nil
}

// Exercício 3: Função variádica
// Aceita qualquer quantidade de inteiros e devolve a soma.
// Dentro da função, "nums" é tratado como []int.
func somarLista(nums ...int) int {
	total := 0
	for _, n := range nums {
		total += n
	}
	return total
}

// Exercício 4: Função que recebe outra função como parâmetro
// "op" é uma função que recebe dois ints e devolve um int.
// Isso é a base de callbacks, ordenação customizada, middlewares, etc.
func aplicar(a, b int, op func(int, int) int) int {
	return op(a, b)
}

// Exercício 5: Closure — função que "lembra" variáveis externas
// criarContador devolve uma função que mantém estado próprio.
// Cada chamada de criarContador() gera um contador novo e independente.
func criarContador() func() int {
	contagem := 0
	return func() int {
		contagem++ // o valor sobrevive entre chamadas porque foi capturado
		return contagem
	}
}

// Exercício 6: defer — executa no fim, em ordem reversa (LIFO)
// Útil pra garantir limpeza (fechar arquivo, soltar trava, etc.).
func ordemDoDefer() {
	defer fmt.Println("4. saiu da função (defer A — empilhado primeiro)")
	defer fmt.Println("3. ainda saindo (defer B — empilhado depois)")
	fmt.Println("1. começo da função")
	fmt.Println("2. meio da função")
	// Quando a função termina, os defers saem ao contrário: B antes de A.
}

// Exercício 7: Recursão — fatorial
// Função que chama a si mesma. Cuidado: precisa de um caso-base pra parar.
func fatorial(n int) int {
	if n <= 1 { // caso-base: 0! e 1! valem 1
		return 1
	}
	return n * fatorial(n-1) // caso recursivo: n * (n-1)!
}

// Exercício 8: Retorno nomeado + função anônima
// "resultado" e "metade" já vêm "pré-declarados". O return sem nada (naked)
// devolve os dois automaticamente.
func dobroEMetade(n float64) (resultado float64, metade float64) {
	resultado = n * 2
	metade = n / 2
	return // naked return — funciona porque os nomes estão na assinatura
}

func main() {
	fmt.Println("=== Exercício 1: somar dois números ===")
	fmt.Println("2 + 3 =", somar(2, 3))

	fmt.Println("\n=== Exercício 2: dividir com tratamento de erro ===")
	if r, err := dividir(10, 2); err != nil {
		fmt.Println("Erro:", err)
	} else {
		fmt.Println("10 / 2 =", r)
	}
	if _, err := dividir(10, 0); err != nil {
		fmt.Println("10 / 0 ->", err) // mostra a mensagem de erro
	}

	fmt.Println("\n=== Exercício 3: variádica somando lista ===")
	fmt.Println("somarLista(1,2,3,4,5) =", somarLista(1, 2, 3, 4, 5))
	fmt.Println("somarLista() (vazio) =", somarLista())
	valores := []int{10, 20, 30}
	fmt.Println("somarLista(valores...) =", somarLista(valores...)) // expande slice

	fmt.Println("\n=== Exercício 4: função como parâmetro ===")
	// Funções anônimas passadas diretamente
	soma := func(x, y int) int { return x + y }
	multi := func(x, y int) int { return x * y }
	fmt.Println("aplicar(4, 6, soma)  =", aplicar(4, 6, soma))
	fmt.Println("aplicar(4, 6, multi) =", aplicar(4, 6, multi))

	fmt.Println("\n=== Exercício 5: closure (contador) ===")
	c1 := criarContador()
	c2 := criarContador() // contador novo, separado do c1
	fmt.Println("c1:", c1(), c1(), c1()) // 1 2 3
	fmt.Println("c2:", c2(), c2())       // 1 2 (independente)
	fmt.Println("c1:", c1())             // 4 (continua de onde parou)

	fmt.Println("\n=== Exercício 6: defer em ordem reversa ===")
	ordemDoDefer()

	fmt.Println("\n=== Exercício 7: recursão (fatorial) ===")
	for i := 0; i <= 6; i++ {
		fmt.Printf("%d! = %d\n", i, fatorial(i))
	}

	fmt.Println("\n=== Exercício 8: retorno nomeado (dobro e metade) ===")
	dobro, meta := dobroEMetade(10)
	fmt.Printf("Para 10: dobro=%.1f, metade=%.1f\n", dobro, meta)
}
