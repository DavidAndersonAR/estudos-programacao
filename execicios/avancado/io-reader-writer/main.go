package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"strings"
)

// Exercícios avançados: io.Reader e io.Writer

// Exercício 1: strings.Reader — ler de uma string
func exercicio1() {
	r := strings.NewReader("Olá, mundo do Go!")
	buf := make([]byte, 5)

	for {
		n, err := r.Read(buf)
		fmt.Printf("Leu %d bytes: %q\n", n, buf[:n])
		if err == io.EOF {
			break
		}
	}
}

// Exercício 2: bytes.Buffer como Writer
func exercicio2() {
	var buf bytes.Buffer
	buf.WriteString("Linha 1\n")
	buf.WriteString("Linha 2\n")
	buf.Write([]byte("Linha 3 (em bytes)\n"))

	fmt.Println("Conteúdo do buffer:")
	fmt.Println(buf.String())
	fmt.Println("Tamanho:", buf.Len())
}

// Exercício 3: io.Copy — copiar entre Reader e Writer
func exercicio3() {
	origem := strings.NewReader("dados que serão copiados")
	var destino bytes.Buffer

	n, err := io.Copy(&destino, origem)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	fmt.Printf("Copiou %d bytes\n", n)
	fmt.Println("Destino:", destino.String())
}

// Exercício 4: io.ReadAll — ler tudo de uma vez
func exercicio4() {
	r := strings.NewReader("conteúdo inteiro de uma vez")
	dados, err := io.ReadAll(r)
	if err != nil {
		fmt.Println("Erro:", err)
		return
	}
	fmt.Println("Tudo lido:", string(dados))
}

// Exercício 5: bufio.Scanner — ler linha a linha
func exercicio5() {
	texto := "primeira linha\nsegunda linha\nterceira linha"
	scanner := bufio.NewScanner(strings.NewReader(texto))

	linha := 1
	for scanner.Scan() {
		fmt.Printf("Linha %d: %s\n", linha, scanner.Text())
		linha++
	}
}

// Exercício 6: Implementar Writer próprio
// Um writer que conta bytes e linhas.
type EstatisticasWriter struct {
	Bytes  int
	Linhas int
}

func (e *EstatisticasWriter) Write(p []byte) (int, error) {
	e.Bytes += len(p)
	for _, b := range p {
		if b == '\n' {
			e.Linhas++
		}
	}
	return len(p), nil
}

func exercicio6() {
	stats := &EstatisticasWriter{}
	io.Copy(stats, strings.NewReader("linha 1\nlinha 2\nlinha 3\n"))
	fmt.Printf("Bytes: %d, Linhas: %d\n", stats.Bytes, stats.Linhas)
}

// Exercício 7: io.MultiWriter — escrever em vários destinos
func exercicio7() {
	var buf1, buf2 bytes.Buffer
	// Escreve nos dois ao mesmo tempo
	multi := io.MultiWriter(&buf1, &buf2, os.Stdout)
	fmt.Fprintln(multi, "esta linha vai pra 3 lugares")

	fmt.Println("--- buf1 ---")
	fmt.Println(buf1.String())
	fmt.Println("--- buf2 ---")
	fmt.Println(buf2.String())
}

// Exercício 8: io.TeeReader — espelhar leitura
func exercicio8() {
	origem := strings.NewReader("dados originais")
	var espelho bytes.Buffer

	// Tudo que for lido de origem também vai pra espelho
	tee := io.TeeReader(origem, &espelho)

	dados, _ := io.ReadAll(tee)
	fmt.Println("Lido:", string(dados))
	fmt.Println("Espelhado:", espelho.String())
}

// Exercício 9: io.LimitReader — limitar quantos bytes ler
func exercicio9() {
	r := strings.NewReader("texto muito longo aqui")
	limitado := io.LimitReader(r, 10) // lê no máximo 10 bytes

	dados, _ := io.ReadAll(limitado)
	fmt.Println("Lido (limitado a 10):", string(dados))
}

func main() {
	fmt.Println("--- Exercício 1 ---")
	exercicio1()
	fmt.Println("--- Exercício 2 ---")
	exercicio2()
	fmt.Println("--- Exercício 3 ---")
	exercicio3()
	fmt.Println("--- Exercício 4 ---")
	exercicio4()
	fmt.Println("--- Exercício 5 ---")
	exercicio5()
	fmt.Println("--- Exercício 6 ---")
	exercicio6()
	fmt.Println("--- Exercício 7 ---")
	exercicio7()
	fmt.Println("--- Exercício 8 ---")
	exercicio8()
	fmt.Println("--- Exercício 9 ---")
	exercicio9()
}
