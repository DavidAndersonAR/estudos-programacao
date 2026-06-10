package main

import "fmt"

// Módulo 02 — Tipos e Variáveis
// Prática: experimentando declaração, tipos básicos, valor zero e conversão.

// Exercício 1: Declaração longa com var
// Aqui usamos a forma "explícita", dizendo o tipo de cada variável.
// Bom para deixar claro o que cada coisa é.
func exercicio1() {
	var nome string = "David"
	var idade int = 30
	var altura float64 = 1.75
	var ativo bool = true

	fmt.Println("Nome:", nome)
	fmt.Println("Idade:", idade)
	fmt.Println("Altura:", altura)
	fmt.Println("Ativo:", ativo)
}

// Exercício 2: Declaração curta com :=
// A forma mais usada dentro de funções. Go descobre o tipo pelo valor.
// Mais rápido de escrever e mais comum no dia a dia.
func exercicio2() {
	nome := "Maria"  // string
	idade := 25      // int
	altura := 1.62   // float64
	ativo := false   // bool

	fmt.Println(nome, idade, altura, ativo)
}

// Exercício 3: Declaração múltipla
// Várias variáveis em uma linha só, ou em um bloco organizado.
func exercicio3() {
	// Múltipla na mesma linha
	x, y, z := 10, 20, 30
	fmt.Println("x, y, z =", x, y, z)

	// Tipos diferentes na mesma linha (Go deduz cada um)
	nome, idade, altura := "Pedro", 40, 1.80
	fmt.Println(nome, idade, altura)

	// Bloco var — útil quando são várias e você quer organizar
	var (
		titulo  string  = "Sala 101"
		largura float64 = 4.5
		ocupada bool    = true
	)
	fmt.Println(titulo, largura, ocupada)
}

// Exercício 4: Valor zero
// Se você declara sem dar valor, Go coloca o valor padrão do tipo.
// Nunca tem "lixo de memória" como em outras linguagens.
func exercicio4() {
	var contador int     // vale 0
	var preco float64    // vale 0
	var texto string     // vale "" (string vazia)
	var ligado bool      // vale false

	fmt.Printf("contador: %d\n", contador)
	fmt.Printf("preco:    %.2f\n", preco)
	fmt.Printf("texto:    [%s]\n", texto) // colchetes para você "ver" o vazio
	fmt.Printf("ligado:   %t\n", ligado)
}

// Exercício 5: Conversão entre tipos numéricos
// Go NÃO converte automaticamente. Você precisa pedir, com tipo(valor).
func exercicio5() {
	var inteiro int = 7
	var decimal float64 = 2.5

	// soma := inteiro + decimal   // ERRO: tipos diferentes
	soma := float64(inteiro) + decimal
	fmt.Println("soma:", soma) // 9.5

	// Convertendo float64 para int — atenção: corta a parte decimal!
	var pi float64 = 3.99
	piInt := int(pi)
	fmt.Println("pi como int:", piInt) // 3, não 4 (Go não arredonda)
}

// Exercício 6: Inspecionando tipo e valor com Printf
// %T mostra o tipo da variável. Ótimo para entender o que Go deduziu.
func exercicio6() {
	a := 42
	b := 3.14
	c := "Go"
	d := true

	fmt.Printf("a = %v   tipo: %T\n", a, a)
	fmt.Printf("b = %v   tipo: %T\n", b, b)
	fmt.Printf("c = %v   tipo: %T\n", c, c)
	fmt.Printf("d = %v   tipo: %T\n", d, d)
}

// Exercício 7: Reatribuição (mudar o valor depois)
// A variável continua com o mesmo TIPO, mas o valor pode mudar.
// Note que usamos = (e não :=) ao reatribuir.
func exercicio7() {
	saldo := 100.0
	fmt.Println("saldo inicial:", saldo)

	saldo = saldo + 50.0 // depósito
	fmt.Println("após depósito:", saldo)

	saldo = saldo - 30.0 // saque
	fmt.Println("após saque:   ", saldo)

	// saldo = "oi"   // ERRO: saldo é float64, não pode receber string
}

func main() {
	fmt.Println("=== Exercício 1: Declaração com var ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Declaração curta com := ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Declaração múltipla ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Valor zero ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Conversão entre tipos ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Inspecionando tipos (com Printf) ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: Reatribuição ===")
	exercicio7()
}
