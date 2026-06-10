package main

import (
	"fmt"
	"sync"
	"sync/atomic"
	"time"
)

// Exercícios avançados: pacote sync

// Exercício 1: Mutex protegendo um contador
type Contador struct {
	mu    sync.Mutex
	valor int
}

func (c *Contador) Incrementar() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.valor++
}

func (c *Contador) Valor() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.valor
}

func exercicio1() {
	c := &Contador{}
	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			c.Incrementar()
		}()
	}

	wg.Wait()
	fmt.Println("Valor final (esperado 1000):", c.Valor())
}

// Exercício 2: RWMutex — várias leituras, escrita exclusiva
type Cache struct {
	mu    sync.RWMutex
	dados map[string]string
}

func NewCache() *Cache {
	return &Cache{dados: make(map[string]string)}
}

func (c *Cache) Get(chave string) string {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.dados[chave]
}

func (c *Cache) Set(chave, valor string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.dados[chave] = valor
}

func exercicio2() {
	cache := NewCache()
	cache.Set("nome", "David")
	cache.Set("idade", "30")

	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			fmt.Printf("leitor %d: nome=%s\n", id, cache.Get("nome"))
		}(i)
	}
	wg.Wait()
}

// Exercício 3: WaitGroup para esperar várias tarefas
func exercicio3() {
	var wg sync.WaitGroup
	tarefas := []string{"baixar", "processar", "enviar"}

	for _, t := range tarefas {
		wg.Add(1)
		go func(tarefa string) {
			defer wg.Done()
			time.Sleep(100 * time.Millisecond)
			fmt.Println("Terminou:", tarefa)
		}(t)
	}

	wg.Wait()
	fmt.Println("Todas as tarefas terminaram")
}

// Exercício 4: sync.Once para inicialização única
var (
	config     map[string]string
	configOnce sync.Once
)

func carregarConfig() {
	configOnce.Do(func() {
		fmt.Println("carregando config (só uma vez!)")
		time.Sleep(100 * time.Millisecond)
		config = map[string]string{"versao": "1.0"}
	})
}

func exercicio4() {
	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			carregarConfig() // chamado 5 vezes, mas roda 1 só
		}()
	}
	wg.Wait()
	fmt.Println("Config:", config)
}

// Exercício 5: sync.Map (map seguro)
func exercicio5() {
	var m sync.Map

	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			m.Store(fmt.Sprintf("chave%d", id), id*10)
		}(i)
	}
	wg.Wait()

	m.Range(func(k, v any) bool {
		fmt.Printf("%v = %v\n", k, v)
		return true
	})
}

// Exercício 6: atomic — operações atômicas
func exercicio6() {
	var contador int64
	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			atomic.AddInt64(&contador, 1) // muito mais rápido que mutex
		}()
	}
	wg.Wait()
	fmt.Println("Contador atômico:", atomic.LoadInt64(&contador))
}

// Exercício 7: comparar com e sem mutex (demonstração)
// Sem mutex você teria race condition; com mutex está protegido.
func exercicio7() {
	var (
		semProtecao int
		comProtecao int
		mu          sync.Mutex
		wg          sync.WaitGroup
	)

	for i := 0; i < 100; i++ {
		wg.Add(2)
		go func() {
			defer wg.Done()
			semProtecao++ // RACE CONDITION (não use isso!)
		}()
		go func() {
			defer wg.Done()
			mu.Lock()
			comProtecao++
			mu.Unlock()
		}()
	}
	wg.Wait()
	fmt.Println("Sem proteção (pode ser <100):", semProtecao)
	fmt.Println("Com proteção (sempre 100):", comProtecao)
	fmt.Println("Dica: rode com 'go run -race main.go' para ver o aviso")
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
