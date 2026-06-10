package main

import "fmt"

// Exercícios práticos: Expressões em Go

// Exercício 1: Operadores aritméticos
// Calcule a média de 3 notas usando +, /
func exercicio1() {
	n1, n2, n3 := 7.5, 8.0, 6.5
	media := (n1 + n2 + n3) / 3
	fmt.Printf("Média: %.2f\n", media)
}

// Exercício 2: Operadores de comparação e lógicos
// Verifique se uma pessoa pode dirigir (idade >= 18 E tem habilitação).
func podeDirigir(idade int, temHabilitacao bool) bool {
	return idade >= 18 && temHabilitacao
}

func exercicio2() {
	fmt.Println("18 com habilitação?", podeDirigir(18, true))
	fmt.Println("16 com habilitação?", podeDirigir(16, true))
	fmt.Println("25 sem habilitação?", podeDirigir(25, false))
}

// Exercício 3: Expressão de índice e slice
// Pegue partes de um slice usando a[low:high].
func exercicio3() {
	letras := []string{"a", "b", "c", "d", "e", "f"}

	primeira := letras[0]   // índice simples
	tresPrimeiras := letras[:3] // do início até o índice 3 (exclusivo)
	doMeio := letras[2:5]   // do índice 2 ao 4
	semPrimeira := letras[1:] // do índice 1 até o fim

	fmt.Println("Primeira:", primeira)
	fmt.Println("Três primeiras:", tresPrimeiras)
	fmt.Println("Do meio:", doMeio)
	fmt.Println("Sem a primeira:", semPrimeira)
}

// Exercício 4: Type assertion
// Receba algo de tipo `any` e descubra o tipo verdadeiro.
func exercicio4() {
	var qualquer any = "texto"

	// "Se for string, me dá como string"
	if s, ok := qualquer.(string); ok {
		fmt.Println("É string com tamanho:", len(s))
	}

	qualquer = 42
	if n, ok := qualquer.(int); ok {
		fmt.Println("É int dobrado:", n*2)
	}
}

// Exercício 5: Conversão de tipo numérico
// Misture int e float64 (precisa converter explicitamente).
func exercicio5() {
	var inteiro int = 7
	var decimal float64 = 3.5

	// inteiro + decimal // ERRO! tipos diferentes
	resultado := float64(inteiro) + decimal
	fmt.Println("Resultado:", resultado)

	// Voltar pra int (perde a parte decimal)
	truncado := int(resultado)
	fmt.Println("Truncado:", truncado)
}

// Exercício 6: Literais compostos
// Crie struct, slice e map "inline" usando literais.
type Livro struct {
	Titulo string
	Ano    int
}

func exercicio6() {
	// Literal de struct
	livro := Livro{Titulo: "Go em Ação", Ano: 2016}

	// Literal de slice
	notas := []int{8, 9, 7, 10}

	// Literal de map
	idades := map[string]int{
		"Ana":    25,
		"Bruno":  30,
		"Carlos": 28,
	}

	fmt.Println(livro)
	fmt.Println(notas)
	fmt.Println(idades)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	exercicio6()
}
