package main

import "fmt"

// Exercícios práticos: Elementos Léxicos em Go
// Os "elementos léxicos" são as peças básicas que formam o código:
// comentários, identificadores, palavras-chave, operadores e literais.

// Exercício 1: Comentários
// Escreva uma função que tenha um comentário de linha (//) e um comentário
// de bloco (/* ... */). Os comentários devem explicar o que o código faz.
func exercicio1() {
	// Comentário de linha: explica algo curto
	x := 10

	/* Comentário de bloco:
	   serve para explicações maiores
	   que ocupam várias linhas */
	fmt.Println("Exercício 1, valor:", x)
}

// Exercício 2: Identificadores válidos
// Crie variáveis com identificadores válidos. Lembre que identificador deve
// começar com letra ou _, e pode ter letras, números e _ depois.
func exercicio2() {
	nome := "David"
	idade2 := 30      // pode ter número, mas não no começo
	_interno := true  // _ no começo é permitido (mas geralmente evitado)
	saldoTotal := 100 // camelCase é o padrão Go

	fmt.Println(nome, idade2, _interno, saldoTotal)
}

// Exercício 3: Literais inteiros em várias bases
// Mostre o mesmo número (255) escrito em decimal, hexadecimal, octal e binário.
func exercicio3() {
	decimal := 255
	hexa := 0xFF      // base 16
	octal := 0o377    // base 8 (também aceita 0377)
	binario := 0b1111_1111 // base 2 (o _ é apenas para legibilidade)

	fmt.Println("Mesmo valor em bases diferentes:")
	fmt.Println(decimal, hexa, octal, binario) // todos imprimem 255
}

// Exercício 4: Runes e literais de caractere
// Mostre como guardar um caractere ASCII e um Unicode usando rune.
// Lembre: rune é apelido para int32, e guarda o "número" do caractere.
func exercicio4() {
	letraA := 'A'      // rune: guarda o código 65
	cifrao := '$'      // 36
	acento := 'ç'      // Unicode
	escape := '\n'     // caractere de escape (quebra de linha)

	fmt.Printf("Letra '%c' = %d\n", letraA, letraA)
	fmt.Printf("Símbolo '%c' = %d\n", cifrao, cifrao)
	fmt.Printf("Acento '%c' = %d\n", acento, acento)
	fmt.Printf("Escape (código): %d\n", escape)
}

// Exercício 5: Strings interpretadas vs cruas
// Crie uma string normal (com aspas duplas) que interpreta caracteres de escape,
// e uma string "crua" (com crases) que mostra tudo literalmente.
func exercicio5() {
	// Interpretada: \n vira quebra de linha, \t vira tab
	interpretada := "Linha 1\nLinha 2\tcom tab"

	// Crua: mostra os caracteres como estão
	crua := `Linha 1\nLinha 2\tsem efeito
mas a quebra de linha real funciona`

	fmt.Println("--- Interpretada ---")
	fmt.Println(interpretada)
	fmt.Println("--- Crua ---")
	fmt.Println(crua)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
}
