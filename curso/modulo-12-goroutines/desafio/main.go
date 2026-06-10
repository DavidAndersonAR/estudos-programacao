package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 12 — Downloader Paralelo Simulado
//
// Objetivo:
// Você tem uma lista de "URLs" para baixar. Cada download demora um tempo
// aleatório entre 100 e 500 milissegundos (vamos só fingir com time.Sleep).
// Sua missão: baixar TODOS em paralelo usando goroutines + WaitGroup e medir
// quanto tempo a coisa toda levou.
//
// Lista de URLs sugerida:
//   "site1.com", "site2.com", "site3.com",
//   "site4.com", "site5.com", "site6.com",
//   "site7.com", "site8.com"
//
// Requisitos:
// 1. Crie uma função `baixar(url string)` que:
//    - Imprime "iniciando: <url>"
//    - Dorme um tempo aleatório entre 100ms e 500ms (use math/rand + time.Sleep)
//    - Imprime "concluído: <url> (XXXms)" — mostrando quanto demorou
// 2. No main, lance UMA goroutine por URL.
// 3. Use sync.WaitGroup para esperar todas terminarem.
// 4. Meça o tempo total com time.Now()/time.Since().
// 5. No fim, imprima: "Total: X URLs em YYYms"
//
// 💡 Dicas:
// - Lembre da armadilha da variável de loop: passe a URL como argumento da goroutine.
// - rand.Intn(401) + 100 gera um número entre 100 e 500.
// - Não esqueça do defer wg.Done() dentro da goroutine.
// - Comparação justa: se rodasse sequencial, seria ~uns 2,5 segundos (8 × média).
//   Em paralelo deve ficar perto do MAIS LENTO sozinho (~500ms).
//
// 🚀 Bônus (opcional):
// - Compare tempos: rode primeiro sequencial, depois paralelo, e mostre a diferença.
// - Use runtime.NumGoroutine() para imprimir quantas goroutines existem no pico.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente o downloader paralelo aqui.
	// Apague esta linha e construa o seu.
	fmt.Println("(implemente seu downloader paralelo)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// baixar simula o download de uma URL: dorme um tempo aleatório
// entre 100ms e 500ms e imprime o resultado.
func baixar(url string, wg *sync.WaitGroup) {
	defer wg.Done() // garante decremento mesmo se algo der errado

	fmt.Printf("iniciando:  %s\n", url)

	// tempo aleatório entre 100ms e 500ms
	duracao := time.Duration(rand.Intn(401)+100) * time.Millisecond
	time.Sleep(duracao)

	fmt.Printf("concluído:  %s (%dms)\n", url, duracao.Milliseconds())
}

func main() {
	urls := []string{
		"site1.com", "site2.com", "site3.com", "site4.com",
		"site5.com", "site6.com", "site7.com", "site8.com",
	}

	var wg sync.WaitGroup
	inicio := time.Now()

	for _, url := range urls {
		wg.Add(1)
		// passamos url como argumento — evita a armadilha da variável de loop
		go baixar(url, &wg)
	}

	wg.Wait() // espera todas as 8 terminarem

	total := time.Since(inicio)
	fmt.Printf("\nTotal: %d URLs em %dms\n", len(urls), total.Milliseconds())

	// Observação: como tudo roda em paralelo, o tempo total fica perto
	// do download MAIS LENTO (~500ms), não da soma de todos (~2400ms).
	// Esse é o superpoder das goroutines para trabalho de I/O.
}
*/
