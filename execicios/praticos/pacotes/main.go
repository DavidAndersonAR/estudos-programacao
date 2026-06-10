package main

import (
	"fmt"
	"math"
	"sort"
	"strconv"
	"strings"
	"time"
)

// Exercícios práticos: Pacotes (stdlib)
// A biblioteca padrão do Go já vem com vários pacotes prontos.

// Exercício 1: strings — manipular texto
// Funções como Split, ToUpper, Contains, Replace.
func exercicio1() {
	frase := "Go é uma linguagem rápida"

	palavras := strings.Split(frase, " ")   // separa por espaços
	maiuscula := strings.ToUpper(frase)
	contem := strings.Contains(frase, "Go") // true
	trocada := strings.Replace(frase, "rápida", "simples", 1)

	fmt.Println("Palavras:", palavras)
	fmt.Println("Maiúscula:", maiuscula)
	fmt.Println("Contém 'Go'?", contem)
	fmt.Println("Trocada:", trocada)
}

// Exercício 2: strconv — converter entre string e número
func exercicio2() {
	// String → int
	n, err := strconv.Atoi("42")
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	fmt.Println("String para int:", n+10)

	// Int → string
	idade := 25
	texto := "Tenho " + strconv.Itoa(idade) + " anos"
	fmt.Println(texto)

	// String → float
	f, _ := strconv.ParseFloat("3.14", 64)
	fmt.Println("Float:", f*2)
}

// Exercício 3: math — funções matemáticas
func exercicio3() {
	fmt.Println("Pi:", math.Pi)
	fmt.Println("Raiz de 16:", math.Sqrt(16))
	fmt.Println("2 elevado a 10:", math.Pow(2, 10))
	fmt.Println("Absoluto de -7:", math.Abs(-7))
	fmt.Println("Arredondado:", math.Round(3.6))
}

// Exercício 4: time — data e hora
func exercicio4() {
	agora := time.Now()
	fmt.Println("Agora:", agora)
	fmt.Println("Formatado:", agora.Format("02/01/2006 15:04"))

	// Daqui a 1 hora
	depois := agora.Add(1 * time.Hour)
	fmt.Println("Daqui 1h:", depois.Format("15:04"))
}

// Exercício 5: sort — ordenar slices
func exercicio5() {
	numeros := []int{5, 2, 8, 1, 9, 3}
	sort.Ints(numeros)
	fmt.Println("Números ordenados:", numeros)

	nomes := []string{"Carlos", "Ana", "Bruno"}
	sort.Strings(nomes)
	fmt.Println("Nomes ordenados:", nomes)

	// Ordenação personalizada (do maior pro menor)
	sort.Slice(numeros, func(i, j int) bool {
		return numeros[i] > numeros[j]
	})
	fmt.Println("Decrescente:", numeros)
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
}
