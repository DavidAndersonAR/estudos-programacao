package main

import "fmt"

// Exercícios práticos: Inicialização e Execução

// Variáveis de pacote — inicializadas ANTES do main rodar
var contadorGlobal int
var nomeApp = "Meu App"
var configs map[string]string // começa nil até init() rodar

// Função init — roda automaticamente antes do main.
// Pode ter várias, são chamadas na ordem que aparecem no arquivo.
func init() {
	fmt.Println("[init 1] preparando configs...")
	configs = map[string]string{
		"versao": "1.0",
		"ambiente": "desenvolvimento",
	}
}

func init() {
	fmt.Println("[init 2] ajustando contador...")
	contadorGlobal = 100
}

// Exercício 1: Valor zero — toda variável tem um valor padrão
func exercicio1() {
	var n int
	var s string
	var b bool
	var p *int
	var lista []int
	var m map[string]int

	fmt.Printf("int: %v | string: %q | bool: %v\n", n, s, b)
	fmt.Printf("ponteiro: %v | slice: %v | map: %v\n", p, lista, m)
}

// Exercício 2: Variáveis de pacote acessíveis em qualquer função
func exercicio2() {
	fmt.Println("App:", nomeApp)
	fmt.Println("Contador (vindo do init):", contadorGlobal)
}

// Exercício 3: Estrutura inicializada pelo init
func exercicio3() {
	fmt.Println("Configs:")
	for chave, valor := range configs {
		fmt.Printf("  %s = %s\n", chave, valor)
	}
}

// Exercício 4: Demonstrar ordem de execução
func exercicio4() {
	fmt.Println("--- main rodando ---")
	fmt.Println("Aqui já passou pelo init, pelas declarações de variáveis de pacote")
}

// Exercício 5: O ponto de entrada do programa é sempre main()
// Se main() retornar, o programa termina.
func exercicio5() {
	fmt.Println("Quando main() acaba, o programa termina.")
	fmt.Println("Goroutines não terminadas são abandonadas.")
}

func main() {
	fmt.Println("=== main() iniciou ===")
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	fmt.Println("=== main() vai terminar ===")
}
