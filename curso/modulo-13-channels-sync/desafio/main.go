package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 13 — Pipeline de Processamento
//
// Objetivo:
// Monte um pipeline de 3 estágios conectados por channels,
// onde cada estágio roda em sua própria goroutine.
//
//   [gerador] --out--> [processador] --out--> [impressor]
//
// Os estágios:
//
//   1) gerador(out chan<- int)
//      Produz os números de 1 a 10 no canal `out` e
//      fecha o canal quando terminar.
//
//   2) processador(in <-chan int, out chan<- int)
//      Lê números de `in`, calcula n*n e envia em `out`.
//      Quando `in` fechar, fecha `out` também.
//
//   3) impressor(in <-chan int, done chan<- bool)
//      Lê de `in` e imprime cada valor.
//      Quando `in` fechar, sinaliza no canal `done` (ou
//      usa sync.WaitGroup — escolha sua).
//
// Saída esperada (a ordem dos números é determinística aqui):
//   1
//   4
//   9
//   16
//   25
//   36
//   49
//   64
//   81
//   100
//
// Requisitos:
// 1. Cada estágio em sua própria goroutine.
// 2. Use direção explícita nos canais (`chan<-` e `<-chan`).
// 3. Sincronize o fim com WaitGroup OU com um canal `done`.
// 4. Nenhum `time.Sleep` para "esperar" goroutine terminar — use
//    os mecanismos certos (close + range, WaitGroup ou done).
//
// 💡 Dicas:
// - Quem envia fecha o canal. O gerador fecha `out` ao final.
// - O processador escuta com `for n := range in` e fecha seu próprio
//   `out` quando o `range` acabar.
// - O impressor sinaliza terminei pelo `done`.
// - Lembre: receber de canal fechado dá valor zero — por isso o
//   `range` é a forma mais limpa de consumir até o fim.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente seu pipeline aqui.
	// Apague esta linha e construa o seu.
	fmt.Println("(monte o pipeline gerador -> processador -> impressor)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
package main

import "fmt"

// Estágio 1: produz 1..10 em `out` e fecha quando termina.
func gerador(out chan<- int) {
	for i := 1; i <= 10; i++ {
		out <- i
	}
	close(out) // sinaliza fim — o range do processador vai parar
}

// Estágio 2: pega de `in`, eleva ao quadrado, manda em `out`.
// Quando `in` fechar, o range encerra e fechamos `out` em sequência.
func processador(in <-chan int, out chan<- int) {
	for n := range in {
		out <- n * n
	}
	close(out)
}

// Estágio 3: imprime tudo que chega em `in` e avisa pelo `done`.
func impressor(in <-chan int, done chan<- bool) {
	for v := range in {
		fmt.Println(v)
	}
	done <- true // sinaliza "terminei"
}

func main() {
	// Canais que conectam os estágios.
	// Buffered pequeno pra dar uma folga — funciona com unbuffered também.
	c1 := make(chan int, 2) // gerador -> processador
	c2 := make(chan int, 2) // processador -> impressor
	done := make(chan bool) // impressor -> main

	// Cada estágio em sua própria goroutine.
	go gerador(c1)
	go processador(c1, c2)
	go impressor(c2, done)

	// main espera o impressor sinalizar que acabou.
	<-done
	fmt.Println("pipeline finalizado")
}

// ----------------------------------------------------------------
// Alternativa usando sync.WaitGroup em vez de canal `done`:
//
// import "sync"
//
// var wg sync.WaitGroup
// wg.Add(1)
// go func() {
//     defer wg.Done()
//     for v := range c2 {
//         fmt.Println(v)
//     }
// }()
// go gerador(c1)
// go processador(c1, c2)
// wg.Wait()
// ----------------------------------------------------------------
*/
