package main

import (
	"fmt"
	"sync"
	"time"
)

// Módulo 12 — Goroutines
// Prática: 6 experimentos curtos para sentir como goroutines se comportam.
//
// Dica: rode com -race pelo menos uma vez para ver o detector de corrida em ação:
//   go run -race ./curso/modulo-12-goroutines/pratica

// Exercício 1: goroutine simples + sleep (hack)
// Lança uma goroutine e espera com time.Sleep. Funciona, mas é frágil:
// se a goroutine demorasse mais que 200ms, o main sairia antes dela.
func exercicio1() {
	go func() {
		fmt.Println("  -> oi do paralelo")
	}()

	// hack ruim, mas didático: dá um tempinho pra goroutine rodar
	time.Sleep(200 * time.Millisecond)
	fmt.Println("  main terminou")
}

// Exercício 2: 5 goroutines com WaitGroup
// O jeito certo: contador de "trabalhos pendentes".
// Add antes de lançar, Done ao terminar, Wait segura o main.
func exercicio2() {
	var wg sync.WaitGroup

	for i := 1; i <= 5; i++ {
		wg.Add(1) // avisa: tem mais 1 goroutine pendente
		go func(id int) {
			defer wg.Done() // garante decremento ao sair
			fmt.Printf("  goroutine %d trabalhando\n", id)
		}(i) // passa i como argumento (cópia local)
	}

	wg.Wait() // bloqueia até contador zerar
	fmt.Println("  todas as 5 terminaram")
}

// Exercício 3: armadilha da variável de loop
// Mostra como capturar i corretamente. Se você capturar i diretamente
// (sem cópia local nem argumento), em versões antigas do Go todas as
// goroutines imprimiam o mesmo valor (geralmente 5).
func exercicio3() {
	var wg sync.WaitGroup

	fmt.Println("  -- jeito correto: cópia local com 'i := i' --")
	for i := 0; i < 3; i++ {
		i := i // cria nova variável dentro do escopo do loop
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Printf("  cópia local: i = %d\n", i)
		}()
	}
	wg.Wait()

	fmt.Println("  -- jeito correto: passando como argumento --")
	for i := 0; i < 3; i++ {
		wg.Add(1)
		go func(n int) {
			defer wg.Done()
			fmt.Printf("  argumento: n = %d\n", n)
		}(i)
	}
	wg.Wait()
}

// Exercício 4: medindo sequencial vs paralelo
// Cada "tarefa" dorme 100ms. 5 tarefas em sequência = ~500ms.
// 5 tarefas em paralelo = ~100ms (todas dormem ao mesmo tempo).
// Esse é o ganho real de concorrência para trabalho que espera (I/O).
func exercicio4() {
	trabalho := func() {
		time.Sleep(100 * time.Millisecond)
	}

	// Sequencial
	inicio := time.Now()
	for i := 0; i < 5; i++ {
		trabalho()
	}
	fmt.Printf("  sequencial: %v\n", time.Since(inicio))

	// Paralelo
	inicio = time.Now()
	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			trabalho()
		}()
	}
	wg.Wait()
	fmt.Printf("  paralelo:   %v\n", time.Since(inicio))
}

// Exercício 5: goroutines mostrando seu ID
// Cada goroutine recebe um ID e imprime quem é + faz um trabalhinho.
// Note que a ordem da saída é imprevisível — é assim mesmo.
func exercicio5() {
	var wg sync.WaitGroup

	for id := 1; id <= 4; id++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			fmt.Printf("  [goroutine %d] iniciando\n", id)
			time.Sleep(50 * time.Millisecond)
			fmt.Printf("  [goroutine %d] terminando\n", id)
		}(id)
	}

	wg.Wait()
}

// Exercício 6: race condition (PROBLEMA — não a solução!)
// 1000 goroutines incrementando o mesmo contador. O esperado seria 1000,
// mas o valor final varia a cada execução. Rode com -race para o Go
// gritar exatamente onde está o problema.
//
// veremos correção no próximo módulo (mutex, atomic, canais).
func exercicio6() {
	contador := 0
	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			contador++ // RACE: leitura + soma + escrita não é atômico
		}()
	}

	wg.Wait()
	fmt.Printf("  contador final: %d (esperado 1000, mas pode variar!)\n", contador)
	fmt.Println("  -> rode com 'go run -race' pra ver o detector de corrida.")
}

func main() {
	fmt.Println("=== Exercício 1: goroutine simples (sleep hack) ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: 5 goroutines com WaitGroup ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: capturando variável de loop ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: sequencial vs paralelo (tempo) ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: goroutines com ID ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: race condition (PROBLEMA) ===")
	exercicio6()
}
