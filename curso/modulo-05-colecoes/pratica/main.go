package main

import (
	"fmt"
	"strings"
)

// Módulo 05 — Coleções
// Prática: exercícios resolvidos com slices e maps.

// Exercício 1: Somar todos os elementos de um slice de inteiros
// Use range para percorrer e ir somando.
func exercicio1() {
	numeros := []int{10, 20, 30, 40, 50}
	soma := 0
	for _, n := range numeros {
		soma += n
	}
	fmt.Printf("Slice: %v | Soma: %d\n", numeros, soma)
}

// Exercício 2: Encontrar o maior elemento de um slice
// Começamos assumindo que o primeiro é o maior e comparamos com os demais.
func exercicio2() {
	numeros := []int{3, 17, 8, 42, 11, 25}
	maior := numeros[0]
	for _, n := range numeros {
		if n > maior {
			maior = n
		}
	}
	fmt.Printf("Slice: %v | Maior: %d\n", numeros, maior)
}

// Exercício 3: Filtrar apenas os números pares
// Criamos um novo slice e usamos append para colocar os que passarem no filtro.
func exercicio3() {
	numeros := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	pares := []int{}
	for _, n := range numeros {
		if n%2 == 0 {
			pares = append(pares, n)
		}
	}
	fmt.Printf("Original: %v\nPares:    %v\n", numeros, pares)
}

// Exercício 4: Inverter um slice
// Trocamos o primeiro com o último, o segundo com o penúltimo, etc.
func exercicio4() {
	letras := []string{"a", "b", "c", "d", "e"}
	fmt.Println("Antes: ", letras)

	// Cópia para não mexer no original (slices compartilham array por baixo)
	invertido := make([]string, len(letras))
	copy(invertido, letras)

	for i, j := 0, len(invertido)-1; i < j; i, j = i+1, j-1 {
		invertido[i], invertido[j] = invertido[j], invertido[i]
	}

	fmt.Println("Depois:", invertido)
}

// Exercício 5: Contar a frequência de palavras com um map
// Para cada palavra, incrementamos o contador no map.
// O zero value de int é 0, então não precisa inicializar.
func exercicio5() {
	frase := "go é simples go é rápido e go é divertido"
	palavras := strings.Fields(frase) // separa por espaços
	contagem := map[string]int{}

	for _, palavra := range palavras {
		contagem[palavra]++
	}

	fmt.Printf("Frase: %q\n", frase)
	fmt.Println("Contagem:")
	for palavra, qtd := range contagem {
		fmt.Printf("  %-10s -> %d\n", palavra, qtd)
	}
}

// Exercício 6: Agrupar nomes pela letra inicial (map de slice)
// A chave é a letra inicial, o valor é um slice com os nomes daquela letra.
func exercicio6() {
	nomes := []string{"Ana", "Alex", "Bia", "Bruno", "Carla", "Caio", "Diego"}
	grupos := map[string][]string{}

	for _, nome := range nomes {
		inicial := strings.ToUpper(string(nome[0]))
		grupos[inicial] = append(grupos[inicial], nome)
	}

	fmt.Printf("Nomes: %v\n", nomes)
	fmt.Println("Agrupados por inicial:")
	for letra, lista := range grupos {
		fmt.Printf("  %s: %v\n", letra, lista)
	}
}

// Exercício 7: Remover duplicatas de um slice
// Usamos um map como "conjunto" (set) para lembrar o que já vimos.
func exercicio7() {
	original := []string{"go", "py", "go", "js", "py", "rust", "go"}
	visto := map[string]bool{}
	unicos := []string{}

	for _, item := range original {
		if !visto[item] { // map devolve false se a chave não existe
			visto[item] = true
			unicos = append(unicos, item)
		}
	}

	fmt.Printf("Original: %v\n", original)
	fmt.Printf("Sem duplicatas: %v\n", unicos)
}

// Exercício 8: Checagem de existência em map (v, ok := m[k])
// Mostra a diferença entre "chave existe com valor zero" e "chave não existe".
func exercicio8() {
	estoque := map[string]int{
		"caneta":  10,
		"caderno": 5,
		"borracha": 0, // existe mas zerado
	}

	itens := []string{"caneta", "borracha", "regua"}
	for _, item := range itens {
		qtd, ok := estoque[item]
		if !ok {
			fmt.Printf("  %-10s -> não cadastrado\n", item)
			continue
		}
		if qtd == 0 {
			fmt.Printf("  %-10s -> cadastrado, mas sem estoque\n", item)
			continue
		}
		fmt.Printf("  %-10s -> %d unidades\n", item, qtd)
	}
}

func main() {
	fmt.Println("=== Exercício 1: Somar slice ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Maior elemento ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Filtrar pares ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Inverter slice ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Frequência de palavras ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Agrupar por inicial ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: Remover duplicatas ===")
	exercicio7()

	fmt.Println("\n=== Exercício 8: Existência em map ===")
	exercicio8()
}
