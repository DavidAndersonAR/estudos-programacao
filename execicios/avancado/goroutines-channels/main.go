package main

import (
	"fmt"
	"sync"
	"time"
)

// Exercícios avançados: Goroutines e Channels

// Exercício 1: Goroutine básica com WaitGroup
// Disparar várias goroutines e esperar todas terminarem.
func exercicio1() {
	var wg sync.WaitGroup

	for i := 1; i <= 3; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			time.Sleep(time.Duration(id) * 100 * time.Millisecond)
			fmt.Println("worker", id, "terminou")
		}(i)
	}

	wg.Wait()
	fmt.Println("Todos terminaram")
}

// Exercício 2: Channel sem buffer (sincronização)
// Goroutine produz, main consome.
func exercicio2() {
	ch := make(chan string)

	go func() {
		time.Sleep(200 * time.Millisecond)
		ch <- "olá da goroutine"
	}()

	msg := <-ch // bloqueia até a goroutine mandar
	fmt.Println("Recebido:", msg)
}

// Exercício 3: Channel com buffer
// Mandar várias mensagens sem ninguém precisar receber na hora.
func exercicio3() {
	ch := make(chan int, 3)
	ch <- 1
	ch <- 2
	ch <- 3
	close(ch)

	for v := range ch {
		fmt.Println("Tirou da fila:", v)
	}
}

// Exercício 4: Worker pool
// 3 workers consumindo tarefas, devolvendo resultados.
func worker(id int, tarefas <-chan int, resultados chan<- int) {
	for t := range tarefas {
		fmt.Printf("worker %d processando %d\n", id, t)
		time.Sleep(100 * time.Millisecond)
		resultados <- t * t
	}
}

func exercicio4() {
	tarefas := make(chan int, 10)
	resultados := make(chan int, 10)

	for w := 1; w <= 3; w++ {
		go worker(w, tarefas, resultados)
	}

	// Mandar 5 tarefas
	for j := 1; j <= 5; j++ {
		tarefas <- j
	}
	close(tarefas)

	// Coletar resultados
	for r := 1; r <= 5; r++ {
		fmt.Println("Resultado:", <-resultados)
	}
}

// Exercício 5: select com timeout
// Esperar uma resposta, mas desistir se demorar demais.
func exercicio5() {
	ch := make(chan string)

	go func() {
		time.Sleep(500 * time.Millisecond)
		ch <- "resposta"
	}()

	select {
	case msg := <-ch:
		fmt.Println("Recebido:", msg)
	case <-time.After(200 * time.Millisecond):
		fmt.Println("Timeout: demorou demais")
	}
}

// Exercício 6: Done channel (sinal de parada)
// Goroutine que trabalha até receber sinal pra parar.
func exercicio6() {
	done := make(chan struct{})

	go func() {
		for {
			select {
			case <-done:
				fmt.Println("Recebi sinal pra parar")
				return
			default:
				fmt.Println("trabalhando...")
				time.Sleep(150 * time.Millisecond)
			}
		}
	}()

	time.Sleep(500 * time.Millisecond)
	close(done) // sinaliza
	time.Sleep(100 * time.Millisecond)
}

// Exercício 7: Fan-out / Fan-in
// Várias goroutines processam em paralelo, resultados juntados num só canal.
func exercicio7() {
	entrada := []int{1, 2, 3, 4, 5}
	resultados := make(chan int, len(entrada))
	var wg sync.WaitGroup

	for _, n := range entrada {
		wg.Add(1)
		go func(v int) {
			defer wg.Done()
			time.Sleep(time.Duration(v) * 50 * time.Millisecond)
			resultados <- v * 10
		}(n)
	}

	// Goroutine que fecha o canal quando todas terminam
	go func() {
		wg.Wait()
		close(resultados)
	}()

	for r := range resultados {
		fmt.Println("Resultado:", r)
	}
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
}
