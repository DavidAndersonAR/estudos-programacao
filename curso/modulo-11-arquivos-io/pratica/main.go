package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"path/filepath"
)

// Módulo 11 — Arquivos e I/O
// Prática: lendo e escrevendo arquivos sem sujar o projeto.
// Tudo aqui usa os.TempDir() ou os.CreateTemp() — nada é gravado na pasta do curso.

// Exercício 1: Criar arquivo e escrever texto (jeito mais simples)
// Usamos os.WriteFile, que cria/sobrescreve com uma chamada só.
func exercicio1() {
	caminho := filepath.Join(os.TempDir(), "modulo11_ex1.txt")
	conteudo := []byte("Olá, arquivo!\nEssa é a segunda linha.\n")

	err := os.WriteFile(caminho, conteudo, 0644)
	if err != nil {
		fmt.Println("erro ao escrever:", err)
		return
	}
	fmt.Println("arquivo escrito em:", caminho)

	// limpa no fim
	defer os.Remove(caminho)

	// confirma lendo de volta
	lido, _ := os.ReadFile(caminho)
	fmt.Printf("conteúdo lido (%d bytes):\n%s", len(lido), lido)
}

// Exercício 2: Ler arquivo inteiro com os.ReadFile
// Primeiro escrevemos algo, depois lemos tudo de uma vez.
func exercicio2() {
	caminho := filepath.Join(os.TempDir(), "modulo11_ex2.txt")
	os.WriteFile(caminho, []byte("linha A\nlinha B\nlinha C\n"), 0644)
	defer os.Remove(caminho)

	dados, err := os.ReadFile(caminho)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}

	fmt.Println("arquivo tem", len(dados), "bytes")
	fmt.Println("conteúdo como string:")
	fmt.Print(string(dados))
}

// Exercício 3: Ler linha a linha com bufio.Scanner
// É o jeito certo pra arquivos grandes ou quando você quer processar linha por linha.
func exercicio3() {
	caminho := filepath.Join(os.TempDir(), "modulo11_ex3.txt")
	os.WriteFile(caminho, []byte("primeira\nsegunda\nterceira\nquarta\n"), 0644)
	defer os.Remove(caminho)

	arq, err := os.Open(caminho)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}
	defer arq.Close() // garante fechar mesmo se der erro depois

	scanner := bufio.NewScanner(arq)
	numero := 0
	for scanner.Scan() {
		numero++
		fmt.Printf("linha %d: %s\n", numero, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("erro durante leitura:", err)
	}
}

// Exercício 4: Copiar de uma string para um "arquivo" em memória
// Usamos bytes.Buffer (implementa io.Writer) pra demonstrar io.Copy
// sem precisar gravar nada no disco.
func exercicio4() {
	origem := bytes.NewBufferString("dado1\ndado2\ndado3\n")
	var destino bytes.Buffer // também é io.Writer

	n, err := io.Copy(&destino, origem)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}

	fmt.Printf("copiou %d bytes\n", n)
	fmt.Println("destino agora contém:")
	fmt.Print(destino.String())
}

// Exercício 5: Escrever em arquivo temporário com os.CreateTemp
// os.CreateTemp gera um nome único pra você. Ótimo pra testes e scripts.
func exercicio5() {
	arq, err := os.CreateTemp("", "modulo11_ex5_*.txt")
	if err != nil {
		fmt.Println("erro:", err)
		return
	}
	defer arq.Close()
	defer os.Remove(arq.Name()) // remove no fim pra não sujar

	fmt.Println("arquivo temporário criado:", arq.Name())

	// usamos bufio.NewWriter pra escrever em "rajadas" (mais eficiente)
	w := bufio.NewWriter(arq)
	for i := 1; i <= 5; i++ {
		fmt.Fprintf(w, "linha número %d\n", i)
	}
	// ⚠️ sem Flush, parte pode não chegar no disco
	if err := w.Flush(); err != nil {
		fmt.Println("erro no flush:", err)
		return
	}

	// confirma lendo de volta
	conteudo, _ := os.ReadFile(arq.Name())
	fmt.Println("conteúdo escrito:")
	fmt.Print(string(conteudo))
}

// Exercício 6: Listar arquivos de um diretório
// os.ReadDir te dá tudo que tem na pasta — arquivos e subpastas.
func exercicio6() {
	dir := os.TempDir()
	fmt.Println("listando até 5 entradas em:", dir)

	entradas, err := os.ReadDir(dir)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}

	limite := 5
	if len(entradas) < limite {
		limite = len(entradas)
	}

	for i := 0; i < limite; i++ {
		e := entradas[i]
		tipo := "arquivo"
		if e.IsDir() {
			tipo = "pasta"
		}
		fmt.Printf("  - %-30s (%s)\n", e.Name(), tipo)
	}
	fmt.Printf("(mostradas %d de %d entradas)\n", limite, len(entradas))
}

// Exercício 7: filepath.Join e amigos
// Caminhos portáveis: o mesmo código funciona no Windows e no Linux/Mac.
func exercicio7() {
	caminho := filepath.Join("dados", "2026", "junho.txt")
	fmt.Println("Join:", caminho)
	fmt.Println("Dir: ", filepath.Dir(caminho))
	fmt.Println("Base:", filepath.Base(caminho))
	fmt.Println("Ext: ", filepath.Ext(caminho))

	abs, _ := filepath.Abs("teste.txt")
	fmt.Println("Abs de 'teste.txt':", abs)
}

func main() {
	fmt.Println("=== Exercício 1: Criar e escrever arquivo ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Ler arquivo inteiro ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Ler linha a linha (bufio.Scanner) ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: io.Copy entre buffers em memória ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Arquivo temporário + bufio.NewWriter + Flush ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Listar diretório (os.ReadDir) ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: filepath.Join e amigos ===")
	exercicio7()
}
