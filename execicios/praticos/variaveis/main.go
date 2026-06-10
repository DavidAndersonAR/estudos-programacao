package main

import "fmt"

// Exercícios práticos: Variáveis em Go

// Variável de pacote (declarada fora de qualquer função)
var versao = "1.0"

// Exercício 1: Declaração com var
// Use var para criar variáveis com tipo explícito.
func exercicio1() {
	var nome string = "Maria"
	var idade int = 30
	var ativo bool = true

	fmt.Println(nome, idade, ativo)
}

// Exercício 2: Declaração curta com :=
// Use a forma curta (mais comum em Go) — o tipo é inferido pelo valor.
func exercicio2() {
	nome := "Carlos" // string
	idade := 25      // int
	altura := 1.75   // float64

	fmt.Println(nome, idade, altura)
}

// Exercício 3: Declaração múltipla
// Declare várias variáveis numa só linha e num bloco.
func exercicio3() {
	// Várias na mesma linha (forma curta)
	x, y, z := 1, "dois", 3.0

	// Várias no estilo var ( ... )
	var (
		titulo   = "Aula de Go"
		duracao  = 60
		gravacao = true
	)

	fmt.Println(x, y, z)
	fmt.Println(titulo, duracao, gravacao)
}

// Exercício 4: Valor zero
// Declare variáveis sem atribuir e mostre o valor padrão de cada tipo.
func exercicio4() {
	var n int
	var f float64
	var s string
	var b bool
	var p *int
	var lista []int

	fmt.Printf("int    = %v\n", n)       // 0
	fmt.Printf("float  = %v\n", f)       // 0
	fmt.Printf("string = %q\n", s)       // ""
	fmt.Printf("bool   = %v\n", b)       // false
	fmt.Printf("ponteiro = %v\n", p)     // <nil>
	fmt.Printf("slice    = %v\n", lista) // []
}

// Exercício 5: Identificador em branco _ e escopo
// Use _ para descartar um valor de retorno e mostre escopo.
func divisao(a, b int) (int, int) {
	return a / b, a % b
}

func exercicio5() {
	// _ descarta o resto, só usamos o quociente
	quociente, _ := divisao(10, 3)
	fmt.Println("Quociente:", quociente)

	// Variável local: só vive aqui dentro
	local := "só existe nesta função"
	fmt.Println(local)

	// Variável de pacote: dá pra usar de qualquer função do arquivo
	fmt.Println("Versão (variável de pacote):", versao)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
}
