package main

import (
	"fmt"
	"sort"
	"strings"
)

// Exercícios práticos: Tipos em Go

// Exercício 1: bool — função que retorna se um número é par
func ePar(n int) bool {
	return n%2 == 0
}

func exercicio1() {
	fmt.Println("4 é par?", ePar(4))
	fmt.Println("7 é par?", ePar(7))
}

// Exercício 2: Números — calcular a média de uma lista
func exercicio2() {
	notas := []float64{8.5, 7.0, 9.2, 6.5, 10.0}
	soma := 0.0
	for _, n := range notas {
		soma += n
	}
	media := soma / float64(len(notas))
	fmt.Printf("Média: %.2f\n", media)
}

// Exercício 3: String — contar palavras numa frase
func exercicio3() {
	frase := "Go é uma linguagem rápida e simples"
	palavras := strings.Fields(frase) // separa por espaços
	fmt.Println("Palavras:", palavras)
	fmt.Println("Total:", len(palavras))
}

// Exercício 4: Array — somar todos os números de um array fixo
func exercicio4() {
	var numeros [5]int = [5]int{10, 20, 30, 40, 50}
	total := 0
	for _, n := range numeros {
		total += n
	}
	fmt.Println("Soma do array:", total)
}

// Exercício 5: Slice — encontrar o maior número de uma lista dinâmica
func exercicio5() {
	valores := []int{3, 7, 2, 9, 5, 1, 8}
	maior := valores[0]
	for _, v := range valores {
		if v > maior {
			maior = v
		}
	}
	fmt.Println("Maior valor:", maior)
}

// Exercício 6: Struct — ordenar pessoas por idade
type Pessoa struct {
	Nome  string
	Idade int
}

func exercicio6() {
	pessoas := []Pessoa{
		{"Ana", 30},
		{"Bruno", 22},
		{"Clara", 28},
	}
	sort.Slice(pessoas, func(i, j int) bool {
		return pessoas[i].Idade < pessoas[j].Idade
	})
	for _, p := range pessoas {
		fmt.Println(p.Nome, "-", p.Idade)
	}
}

// Exercício 7: Ponteiro — função que modifica o valor original
func dobrar(n *int) {
	*n = *n * 2
}

func exercicio7() {
	valor := 10
	dobrar(&valor)
	fmt.Println("Valor após dobrar:", valor) // 20
}

// Exercício 8: Map — contar frequência de letras
func exercicio8() {
	palavra := "programacao"
	frequencia := make(map[rune]int)
	for _, letra := range palavra {
		frequencia[letra]++
	}
	for letra, qtd := range frequencia {
		fmt.Printf("'%c' aparece %d vez(es)\n", letra, qtd)
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
