package main

import "fmt"

// Exercícios práticos: Constantes em Go
// Constante é um valor que NÃO muda depois de declarado.

// Exercício 1: Constante simples com const
// Declare uma constante PI e use ela para calcular a área de um círculo.
const PI = 3.14159

func exercicio1() {
	raio := 5.0
	area := PI * raio * raio
	fmt.Println("Área do círculo:", area)
}

// Exercício 2: Constantes tipadas vs não-tipadas
// Mostre a diferença entre uma constante com tipo declarado e uma "untyped".
func exercicio2() {
	const tipada int = 100      // tipo fixo: int
	const naoTipada = 100       // "untyped" — flexível

	var x int = tipada          // OK
	var y float64 = naoTipada   // OK porque naoTipada se adapta
	// var z float64 = tipada   // ERRO! tipada é int, precisaria conversão

	fmt.Println(x, y)
}

// Exercício 3: Grupo de constantes com const ( ... )
// Declare várias constantes relacionadas num único bloco.
func exercicio3() {
	const (
		StatusAtivo    = "ativo"
		StatusInativo  = "inativo"
		StatusPendente = "pendente"
	)

	fmt.Println("Status disponíveis:", StatusAtivo, StatusInativo, StatusPendente)
}

// Exercício 4: iota — gerador automático de valores
// Crie uma sequência de constantes para os dias da semana usando iota.
func exercicio4() {
	const (
		Domingo  = iota // 0
		Segunda         // 1
		Terca           // 2
		Quarta          // 3
		Quinta          // 4
		Sexta           // 5
		Sabado          // 6
	)

	fmt.Println("Quarta é o dia número:", Quarta)
	fmt.Println("Sábado é o dia número:", Sabado)
}

// Exercício 5: iota com expressões — flags de bits
// Use iota com deslocamento de bits para criar permissões (estilo Linux).
func exercicio5() {
	const (
		Leitura  = 1 << iota // 1 (binário: 001)
		Escrita              // 2 (binário: 010)
		Execucao             // 4 (binário: 100)
	)

	permissao := Leitura | Escrita // combina permissões: 3
	fmt.Printf("Permissão combinada: %d (binário: %03b)\n", permissao, permissao)
	fmt.Println("Pode ler?", permissao&Leitura != 0)
	fmt.Println("Pode executar?", permissao&Execucao != 0)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
}
