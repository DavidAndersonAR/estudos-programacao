package main

import (
	"fmt"
	"sync"
	"time"
)

// Módulo 13 — Channels e Sync
// Prática: vamos brincar com canais, select, mutex e dar uma espiada em worker pool.

// Exercício 1: Canal unbuffered — ping-pong
// Duas goroutines trocam mensagens. Como o canal não tem buffer,
// cada envio espera alguém receber. Isso sincroniza naturalmente.
func exercicio1() {
	ping := make(chan string)
	pong := make(chan string)

	// Goroutine A: manda "ping" e espera o "pong"
	go func() {
		ping <- "ping"
		resp := <-pong
		fmt.Println("A recebeu:", resp)
	}()

	// Goroutine B (a main aqui mesmo): recebe "ping" e devolve "pong"
	msg := <-ping
	fmt.Println("B recebeu:", msg)
	pong <- "pong"

	// Pequena pausa para a goroutine A imprimir antes de seguirmos.
	time.Sleep(50 * time.Millisecond)
}

// Exercício 2: Canal buffered com 3 valores
// O buffer permite enviar 3 valores sem ninguém estar recebendo ainda.
// O 4º envio travaria — comente o close e tente para ver.
func exercicio2() {
	ch := make(chan int, 3)

	ch <- 10
	ch <- 20
	ch <- 30
	// ch <- 40 // descomente para travar: buffer cheio

	fmt.Println("Capacidade:", cap(ch), "Tamanho atual:", len(ch))

	fmt.Println(<-ch) // 10
	fmt.Println(<-ch) // 20
	fmt.Println(<-ch) // 30
}

// Exercício 3: Fechar canal e percorrer com range
// O produtor manda valores e fecha. O consumidor usa range para
// ler até o fim sem precisar saber quantos vão chegar.
func exercicio3() {
	numeros := make(chan int)

	// Produtor em goroutine
	go func() {
		for i := 1; i <= 5; i++ {
			numeros <- i
		}
		close(numeros) // sinaliza "acabou" — sem isso o range trava
	}()

	// Consumidor
	for n := range numeros {
		fmt.Println("recebi", n)
	}
	fmt.Println("canal fechado, fim do range")
}

// Exercício 4: select com 2 canais
// select escolhe o caso que estiver pronto primeiro.
// Aqui um canal "demora" 100ms e o outro "demora" 200ms,
// então o de 100ms ganha quase sempre.
func exercicio4() {
	rapido := make(chan string)
	lento := make(chan string)

	go func() {
		time.Sleep(100 * time.Millisecond)
		rapido <- "veloz"
	}()
	go func() {
		time.Sleep(200 * time.Millisecond)
		lento <- "devagar"
	}()

	// Lemos 2 vezes para imprimir os dois resultados na ordem em que chegam.
	for i := 0; i < 2; i++ {
		select {
		case v := <-rapido:
			fmt.Println("rapido respondeu:", v)
		case v := <-lento:
			fmt.Println("lento respondeu:", v)
		}
	}
}

// Exercício 5: select com timeout
// Se ninguém responder em 200ms, desistimos. Padrão clássico
// para evitar travar para sempre esperando algo que não vem.
func exercicio5() {
	ch := make(chan string)

	go func() {
		time.Sleep(500 * time.Millisecond) // proposital: demora demais
		ch <- "finalmente!"
	}()

	select {
	case msg := <-ch:
		fmt.Println("chegou:", msg)
	case <-time.After(200 * time.Millisecond):
		fmt.Println("timeout — cansei de esperar")
	}
}

// Exercício 6: Contador protegido por Mutex (com e sem)
// Vamos somar 1000 incrementos em 5 goroutines.
// SEM mutex: o valor final costuma ficar errado (race condition).
// COM mutex: bate 1000 sempre.
func exercicio6() {
	// --- SEM Mutex ---
	contadorRuim := 0
	var wgRuim sync.WaitGroup
	for i := 0; i < 5; i++ {
		wgRuim.Add(1)
		go func() {
			defer wgRuim.Done()
			for j := 0; j < 200; j++ {
				contadorRuim++ // RACE: várias goroutines mexendo na mesma var
			}
		}()
	}
	wgRuim.Wait()
	fmt.Println("SEM mutex (esperado 1000):", contadorRuim, "— pode variar a cada execução")

	// --- COM Mutex ---
	var mu sync.Mutex
	contadorBom := 0
	var wgBom sync.WaitGroup
	for i := 0; i < 5; i++ {
		wgBom.Add(1)
		go func() {
			defer wgBom.Done()
			for j := 0; j < 200; j++ {
				mu.Lock()
				contadorBom++
				mu.Unlock()
			}
		}()
	}
	wgBom.Wait()
	fmt.Println("COM mutex (esperado 1000):", contadorBom)
}

// Exercício 7: Worker pool simples (1-2 workers)
// Spoiler do desafio: várias goroutines puxando trabalho do mesmo canal.
// Aqui vamos com 2 workers processando 5 tarefas. Cada um pega
// quando estiver livre. close(tarefas) avisa que não vem mais nada.
func worker(id int, tarefas <-chan int, resultados chan<- int) {
	for t := range tarefas {
		// "processa" a tarefa (aqui só dobra o valor)
		time.Sleep(50 * time.Millisecond)
		fmt.Printf("worker %d processou tarefa %d\n", id, t)
		resultados <- t * 2
	}
}

func exercicio7() {
	tarefas := make(chan int, 5)
	resultados := make(chan int, 5)

	// Sobem 2 workers
	go worker(1, tarefas, resultados)
	go worker(2, tarefas, resultados)

	// Enfileira 5 tarefas
	for i := 1; i <= 5; i++ {
		tarefas <- i
	}
	close(tarefas) // sinaliza que não vem mais tarefa — workers vão sair do for range

	// Lê os 5 resultados
	for i := 0; i < 5; i++ {
		fmt.Println("resultado:", <-resultados)
	}
}

func main() {
	fmt.Println("=== Exercício 1: Ping-pong (canal unbuffered) ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Canal buffered ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: close + range ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: select com 2 canais ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: select com timeout ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Contador com Mutex ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: Worker pool simples ===")
	exercicio7()
}
