package main

import (
	"fmt"
	"math"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"
)

// Módulo 10 — Pacotes
// Prática: usando a biblioteca padrão (stdlib) do Go.
// Cada exercício explora um pacote diferente: strings, strconv, math, time, sort, os.

// Exercício 1: strings — manipulação de texto
// Split divide uma string em slice; Join faz o contrário.
// ToUpper deixa tudo maiúsculo; Contains checa se contém um trecho.
func exercicio1() {
	frase := "Go é simples, rápido e divertido"

	// Split: quebra a frase em pedaços separados por espaço.
	palavras := strings.Split(frase, " ")
	fmt.Println("Split:", palavras) // [Go é simples, rápido e divertido]

	// Join: junta os pedaços com um separador no meio.
	juntado := strings.Join(palavras, "-")
	fmt.Println("Join:", juntado) // Go-é-simples,-rápido-e-divertido

	// ToUpper: tudo em CAIXA ALTA.
	fmt.Println("ToUpper:", strings.ToUpper(frase))

	// Contains: devolve true/false se um trecho aparece dentro da string.
	fmt.Println("Contém 'simples'?", strings.Contains(frase, "simples")) // true
	fmt.Println("Contém 'Python'?", strings.Contains(frase, "Python"))   // false
}

// Exercício 2: strconv — conversão entre string e número
// Atoi (Ascii to Int): string -> int.
// Itoa (Int to Ascii): int -> string.
// ParseFloat: string -> float64.
// Conversões sempre devolvem (valor, erro). Trate o erro!
func exercicio2() {
	// String para int
	n, err := strconv.Atoi("42")
	if err != nil {
		fmt.Println("erro ao converter:", err)
	} else {
		fmt.Println("Atoi('42') =", n, "(int)") // 42
	}

	// String inválida -> erro
	_, err = strconv.Atoi("não sou número")
	fmt.Println("Atoi inválido ->", err) // mostra a mensagem de erro

	// Int para string
	s := strconv.Itoa(2026)
	fmt.Println("Itoa(2026) =", s, "(string)") // "2026"

	// String para float64
	f, err := strconv.ParseFloat("3.14", 64) // 64 = precisão
	if err == nil {
		fmt.Printf("ParseFloat('3.14') = %.2f (float64)\n", f)
	}
}

// Exercício 3: math — operações matemáticas
// Sqrt = raiz quadrada. Pi = constante. Pow(base, expoente) = potência.
// Tudo trabalha com float64 — converta se for usar int.
func exercicio3() {
	// Sqrt
	fmt.Println("Sqrt(16) =", math.Sqrt(16)) // 4
	fmt.Println("Sqrt(2)  =", math.Sqrt(2))  // 1.4142...

	// Pi como constante exportada
	fmt.Printf("math.Pi = %.4f\n", math.Pi) // 3.1416

	// Área do círculo: Pi * r^2
	raio := 5.0
	area := math.Pi * math.Pow(raio, 2)
	fmt.Printf("Área do círculo (r=%.1f): %.2f\n", raio, area)

	// Pow para inteiros — precisa converter na entrada e na saída
	resultado := int(math.Pow(2, 10)) // 2^10 = 1024
	fmt.Println("2^10 =", resultado)
}

// Exercício 4: time — datas e horários
// time.Now() devolve o instante atual.
// Format usa uma data de REFERÊNCIA fixa: 2006-01-02 15:04:05.
// Add soma uma duração (time.Hour, time.Minute, ...).
func exercicio4() {
	agora := time.Now()
	fmt.Println("Now (cru):", agora) // muita informação

	// Format com layout de referência (decore: 2006-01-02 15:04:05)
	fmt.Println("Formatado:", agora.Format("02/01/2006 15:04:05"))
	fmt.Println("Só data: ", agora.Format("2006-01-02"))
	fmt.Println("Só hora: ", agora.Format("15:04"))

	// Add: somar duração
	amanha := agora.Add(24 * time.Hour)
	fmt.Println("Amanhã:", amanha.Format("02/01/2006"))

	daqui3h := agora.Add(3 * time.Hour)
	fmt.Println("Daqui 3h:", daqui3h.Format("15:04"))
}

// Exercício 5: sort — ordenação
// sort.Ints ordena um []int in-place (modifica o slice original).
// sort.Slice ordena qualquer slice com um critério customizado (closure).
func exercicio5() {
	// Ordenando slice de inteiros
	numeros := []int{5, 2, 8, 1, 9, 3}
	sort.Ints(numeros) // modifica o próprio slice
	fmt.Println("Ints ordenados:", numeros)

	// Ordenando slice de strings por TAMANHO (não alfabético)
	palavras := []string{"banana", "uva", "laranja", "kiwi"}
	sort.Slice(palavras, func(i, j int) bool {
		return len(palavras[i]) < len(palavras[j])
	})
	fmt.Println("Por tamanho:", palavras)

	// Ordenando do maior para o menor (decrescente)
	nums := []int{4, 1, 7, 3, 8, 2}
	sort.Slice(nums, func(i, j int) bool {
		return nums[i] > nums[j] // troque > por < para crescente
	})
	fmt.Println("Decrescente:", nums)
}

// Exercício 6: os — acesso ao sistema operacional
// os.Getenv lê variáveis de ambiente.
// os.Args contém os argumentos da linha de comando (Args[0] é o próprio programa).
func exercicio6() {
	// Variável de ambiente (no Windows: PATH, USERNAME, etc.)
	usuario := os.Getenv("USERNAME") // Windows
	if usuario == "" {
		usuario = os.Getenv("USER") // Linux/Mac
	}
	fmt.Println("Usuário do SO:", usuario)

	// Variável que provavelmente não existe -> string vazia
	inexistente := os.Getenv("VARIAVEL_QUE_NAO_EXISTE")
	fmt.Printf("Variável inexistente: [%s] (string vazia)\n", inexistente)

	// Argumentos da linha de comando
	// Args[0] = caminho do executável; Args[1..] = argumentos passados
	fmt.Println("os.Args (qtd):", len(os.Args))
	for i, arg := range os.Args {
		fmt.Printf("  Args[%d] = %s\n", i, arg)
	}
	fmt.Println("Dica: rode com 'go run . um dois três' para ver mais argumentos.")
}

func main() {
	fmt.Println("=== Exercício 1: strings ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: strconv ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: math ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: time ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: sort ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: os ===")
	exercicio6()
}
