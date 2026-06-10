package main

import "fmt"

// Exercícios práticos: Blocos em Go
// Bloco = código entre { e }. Variáveis declaradas dentro de um bloco
// só vivem ali.

// Variável de pacote — vive no bloco do pacote
var mensagemPacote = "Disponível em todas as funções"

// Exercício 1: Bloco explícito solto
// Crie um bloco { ... } solto dentro de uma função. A variável dentro
// dele só existe nesse bloco.
func exercicio1() {
	{
		secreto := "só vive neste bloco"
		fmt.Println(secreto)
	}
	// fmt.Println(secreto) // ERRO! secreto não existe mais aqui
	fmt.Println("Fora do bloco interno")
}

// Exercício 2: Escopo em if/else
// Variável declarada no if só vale dentro do if e else.
func exercicio2() {
	if x := 10; x > 5 {
		fmt.Println("x é maior que 5:", x)
	} else {
		fmt.Println("x é menor ou igual a 5:", x)
	}
	// fmt.Println(x) // ERRO! x não existe mais aqui
}

// Exercício 3: Escopo em for
// O contador do for só vive dentro do laço.
func exercicio3() {
	for i := 0; i < 3; i++ {
		fmt.Println("Iteração", i)
	}
	// fmt.Println(i) // ERRO! i não existe mais aqui
}

// Exercício 4: Shadowing (variável "sombra")
// Variável com mesmo nome em bloco interno "esconde" a externa.
func exercicio4() {
	valor := "externo"
	fmt.Println("Antes do bloco:", valor)

	{
		valor := "interno" // NOVA variável, esconde a externa
		fmt.Println("Dentro do bloco:", valor)
	}

	fmt.Println("Depois do bloco:", valor) // volta a ser "externo"
}

// Exercício 5: Bloco de função vs bloco de pacote
// Variável local da função existe só ali; variável de pacote, em qualquer função.
func exercicio5() {
	mensagemLocal := "Só nesta função"

	fmt.Println("Variável de pacote:", mensagemPacote)
	fmt.Println("Variável local:", mensagemLocal)
}

// Outra função demonstrando que mensagemLocal NÃO está acessível aqui
func outraFuncao() {
	// fmt.Println(mensagemLocal) // ERRO! só existe em exercicio5
	fmt.Println("Outra função vê:", mensagemPacote)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	outraFuncao()
}
