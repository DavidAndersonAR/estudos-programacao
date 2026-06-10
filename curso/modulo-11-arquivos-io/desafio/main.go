package main

import (
	"fmt"
)

// 🎯 DESAFIO DO MÓDULO 11 — Contador de Palavras
//
// Objetivo:
// Escreva um programa que:
//   1. Cria um ARQUIVO TEMPORÁRIO (use os.CreateTemp ou os.TempDir + os.WriteFile)
//      com um texto fixo de pelo menos 5 linhas.
//   2. Lê esse arquivo (do disco, não da string original — finja que ele veio "de fora").
//   3. Conta e imprime as estatísticas:
//      - Total de LINHAS
//      - Total de PALAVRAS
//      - Total de CARACTERES (você decide: bytes ou runas)
//   4. Remove o arquivo temporário no final (defer os.Remove).
//
// 🎁 Bônus (faz se quiser ir além):
//   - Imprima as TOP 5 PALAVRAS MAIS FREQUENTES.
//   - Trate maiúsculas/minúsculas como a mesma palavra ("Go" == "go").
//   - Tire a pontuação básica (",", ".", "!", "?", ";", ":") antes de contar.
//
// Saída esperada (mais ou menos assim):
//
//   arquivo: C:\Users\...\Temp\contador_123.txt
//   linhas:     5
//   palavras:   42
//   caracteres: 235
//   top 5 palavras:
//     1. go         (5x)
//     2. arquivo    (3x)
//     3. ...
//
// 💡 Dicas:
// - Use bufio.Scanner pra ler linha a linha (mais "Go-idiomático" que ReadFile aqui).
// - Pra separar palavras numa linha, strings.Fields(linha) é o ideal: ele já
//   trata espaços múltiplos, tabs, etc.
// - Caracteres como bytes: len(linha). Como runas (Unicode): utf8.RuneCountInString(linha).
// - Pra contar frequência: map[string]int.
// - Pra ordenar o top 5: jogue (palavra, contagem) num slice e use sort.Slice.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente o contador de palavras aqui.
	// Apague esta linha e construa o seu.
	fmt.Println("(escreva seu contador de palavras aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strings"
	"unicode/utf8"
)

func main() {
	// ----- 1) cria arquivo temporário com texto fixo -----
	texto := `Go é uma linguagem simples e direta.
Aprender Go é divertido e produtivo.
Em Go, arquivos são fáceis de ler.
Arquivos, arquivos e mais arquivos!
Go, Go, Go: vamos contar palavras.`

	arq, err := os.CreateTemp("", "contador_*.txt")
	if err != nil {
		fmt.Println("erro ao criar arquivo:", err)
		return
	}
	caminho := arq.Name()
	defer os.Remove(caminho) // garante limpeza no fim

	if _, err := arq.WriteString(texto); err != nil {
		fmt.Println("erro ao escrever:", err)
		arq.Close()
		return
	}
	arq.Close() // fecha pra poder reabrir pra leitura

	fmt.Println("arquivo:", caminho)

	// ----- 2) lê o arquivo de volta, linha a linha -----
	f, err := os.Open(caminho)
	if err != nil {
		fmt.Println("erro ao abrir:", err)
		return
	}
	defer f.Close()

	var (
		linhas, palavras, caracteres int
		frequencia                   = make(map[string]int)
	)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		linha := scanner.Text()
		linhas++
		caracteres += utf8.RuneCountInString(linha) // conta runas (Unicode-safe)

		// 3) conta palavras e atualiza frequência
		for _, p := range strings.Fields(linha) {
			palavras++
			// normaliza: minúscula + tira pontuação básica
			limpa := strings.ToLower(strings.Trim(p, ".,!?;:"))
			if limpa == "" {
				continue
			}
			frequencia[limpa]++
		}
	}
	if err := scanner.Err(); err != nil {
		fmt.Println("erro durante leitura:", err)
		return
	}

	// ----- 4) imprime estatísticas -----
	fmt.Printf("linhas:     %d\n", linhas)
	fmt.Printf("palavras:   %d\n", palavras)
	fmt.Printf("caracteres: %d (sem contar quebras de linha)\n", caracteres)

	// ----- bônus: top 5 palavras mais frequentes -----
	type par struct {
		palavra string
		qtd     int
	}
	lista := make([]par, 0, len(frequencia))
	for p, q := range frequencia {
		lista = append(lista, par{p, q})
	}
	sort.Slice(lista, func(i, j int) bool {
		if lista[i].qtd != lista[j].qtd {
			return lista[i].qtd > lista[j].qtd // mais frequente primeiro
		}
		return lista[i].palavra < lista[j].palavra // desempata por ordem alfabética
	})

	limite := 5
	if len(lista) < limite {
		limite = len(lista)
	}
	fmt.Println("top 5 palavras:")
	for i := 0; i < limite; i++ {
		fmt.Printf("  %d. %-12s (%dx)\n", i+1, lista[i].palavra, lista[i].qtd)
	}
}
*/
