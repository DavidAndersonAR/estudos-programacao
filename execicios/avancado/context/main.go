package main

import (
	"context"
	"errors"
	"fmt"
	"time"
)

// Exercícios avançados: Context

// Exercício 1: WithCancel — cancelamento manual
func trabalharComCancel(ctx context.Context, id int) {
	for {
		select {
		case <-ctx.Done():
			fmt.Printf("worker %d: parando, motivo: %v\n", id, ctx.Err())
			return
		default:
			fmt.Printf("worker %d trabalhando...\n", id)
			time.Sleep(200 * time.Millisecond)
		}
	}
}

func exercicio1() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go trabalharComCancel(ctx, 1)

	time.Sleep(700 * time.Millisecond)
	cancel() // pede pra parar
	time.Sleep(300 * time.Millisecond)
}

// Exercício 2: WithTimeout — desistir depois de X tempo
func operacaoLenta() <-chan string {
	resultado := make(chan string)
	go func() {
		time.Sleep(2 * time.Second)
		resultado <- "pronto!"
	}()
	return resultado
}

func exercicio2() {
	ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
	defer cancel()

	select {
	case r := <-operacaoLenta():
		fmt.Println("Recebeu:", r)
	case <-ctx.Done():
		fmt.Println("Timeout:", ctx.Err()) // context deadline exceeded
	}
}

// Exercício 3: WithDeadline — limite em tempo absoluto
func exercicio3() {
	prazo := time.Now().Add(300 * time.Millisecond)
	ctx, cancel := context.WithDeadline(context.Background(), prazo)
	defer cancel()

	select {
	case <-time.After(100 * time.Millisecond):
		fmt.Println("Tarefa rápida terminou dentro do prazo")
	case <-ctx.Done():
		fmt.Println("Estourou o prazo:", ctx.Err())
	}
}

// Exercício 4: WithValue — passar dados pela cadeia
type chave string

const userIDKey chave = "userID"
const traceIDKey chave = "traceID"

func processar(ctx context.Context) {
	userID := ctx.Value(userIDKey)
	traceID := ctx.Value(traceIDKey)
	fmt.Printf("processando para user=%v trace=%v\n", userID, traceID)
}

func exercicio4() {
	ctx := context.Background()
	ctx = context.WithValue(ctx, userIDKey, 42)
	ctx = context.WithValue(ctx, traceIDKey, "abc-123")

	processar(ctx)
}

// Exercício 5: Cancelar várias goroutines de uma vez
func exercicio5() {
	ctx, cancel := context.WithCancel(context.Background())

	for i := 1; i <= 3; i++ {
		go trabalharComCancel(ctx, i)
	}

	time.Sleep(500 * time.Millisecond)
	cancel() // cancela TODAS de uma vez
	time.Sleep(300 * time.Millisecond)
}

// Exercício 6: Propagação de timeout em camadas
func consultaDB(ctx context.Context) (string, error) {
	select {
	case <-time.After(200 * time.Millisecond):
		return "dado do banco", nil
	case <-ctx.Done():
		return "", ctx.Err()
	}
}

func handler(ctx context.Context) {
	// Esta camada cria um filho com seu próprio timeout (menor)
	ctxDB, cancel := context.WithTimeout(ctx, 100*time.Millisecond)
	defer cancel()

	resultado, err := consultaDB(ctxDB)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			fmt.Println("Banco demorou demais")
		} else {
			fmt.Println("Outro erro:", err)
		}
		return
	}
	fmt.Println("Sucesso:", resultado)
}

func exercicio6() {
	ctx := context.Background()
	handler(ctx) // DB vai estourar timeout (100ms < 200ms)
}

func main() {
	fmt.Println("--- Exercício 1: WithCancel ---")
	exercicio1()
	fmt.Println("--- Exercício 2: WithTimeout ---")
	exercicio2()
	fmt.Println("--- Exercício 3: WithDeadline ---")
	exercicio3()
	fmt.Println("--- Exercício 4: WithValue ---")
	exercicio4()
	fmt.Println("--- Exercício 5: Cancelar várias ---")
	exercicio5()
	fmt.Println("--- Exercício 6: Camadas ---")
	exercicio6()
}
