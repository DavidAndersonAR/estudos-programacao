package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 05 — Gerenciador de Tarefas em Memória
//
// Objetivo:
// Construir um pequeno gerenciador de tarefas que funcione apenas na memória
// (sem arquivo, sem banco). O programa deve oferecer as operações abaixo,
// cada uma implementada como uma função separada:
//
//   1. adicionar(titulo)              -> cria uma nova tarefa
//   2. listar()                       -> mostra todas as tarefas
//   3. concluir(id)                   -> marca a tarefa como concluída
//   4. remover(id)                    -> apaga a tarefa
//
// Estrutura sugerida:
//   - Use um map[int]string para o título da tarefa
//   - Use um map[int]bool para saber se está concluída
//   - Mantenha um "proximoID" global que vai crescendo (1, 2, 3, ...)
//
// Saída esperada (exemplo):
//   --- Após adicionar 'estudar Go' ---
//   [ ] 1 - estudar Go
//   --- Após adicionar 'fazer café' ---
//   [ ] 1 - estudar Go
//   [ ] 2 - fazer café
//   --- Após concluir 1 ---
//   [x] 1 - estudar Go
//   [ ] 2 - fazer café
//   --- Após remover 1 ---
//   [ ] 2 - fazer café
//
// Requisitos:
// 1. Crie uma função para cada operação (adicionar, listar, concluir, remover).
// 2. Depois de cada operação no main, chame listar() para mostrar o estado.
// 3. Trate o caso de id inexistente em concluir() e remover() — só avise.
// 4. Use range, append, delete e o padrão v, ok := m[k] em pelo menos um lugar.
//
// 💡 Dicas:
// - Variáveis globais (fora de funções) em Go ficam acessíveis a todo o pacote.
// - Para imprimir [x] ou [ ], use uma função auxiliar que devolva a string.
// - delete(m, chave) remove a chave do map (sem erro se não existir).

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente o gerenciador aqui.
	// Apague esta linha e construa o seu.
	fmt.Println("(implemente seu gerenciador de tarefas)")

	// Roteiro sugerido para o main:
	// adicionar("estudar Go")
	// listar()
	// adicionar("fazer café")
	// listar()
	// concluir(1)
	// listar()
	// remover(1)
	// listar()
	// remover(99) // id inexistente, deve só avisar
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// Estado em memória (variáveis de pacote)
var (
	titulos    = map[int]string{}
	concluidas = map[int]bool{}
	proximoID  = 1
)

// adicionar cria uma nova tarefa e devolve o id gerado.
func adicionar(titulo string) int {
	id := proximoID
	titulos[id] = titulo
	concluidas[id] = false
	proximoID++
	fmt.Printf("--- Após adicionar %q ---\n", titulo)
	listar()
	return id
}

// listar mostra todas as tarefas, com [x] para concluída e [ ] para pendente.
// Itera de 1 até proximoID-1 para garantir uma ordem previsível
// (lembre-se: range em map não tem ordem garantida).
func listar() {
	if len(titulos) == 0 {
		fmt.Println("(sem tarefas)")
		return
	}
	for id := 1; id < proximoID; id++ {
		titulo, existe := titulos[id]
		if !existe {
			continue // foi removida
		}
		fmt.Printf("%s %d - %s\n", marcador(concluidas[id]), id, titulo)
	}
}

// concluir marca uma tarefa como concluída.
func concluir(id int) {
	if _, ok := titulos[id]; !ok {
		fmt.Printf("--- Não foi possível concluir: id %d não existe ---\n", id)
		return
	}
	concluidas[id] = true
	fmt.Printf("--- Após concluir %d ---\n", id)
	listar()
}

// remover apaga uma tarefa pelo id.
func remover(id int) {
	if _, ok := titulos[id]; !ok {
		fmt.Printf("--- Não foi possível remover: id %d não existe ---\n", id)
		return
	}
	delete(titulos, id)
	delete(concluidas, id)
	fmt.Printf("--- Após remover %d ---\n", id)
	listar()
}

// marcador devolve "[x]" se concluída, "[ ]" se pendente.
func marcador(feita bool) string {
	if feita {
		return "[x]"
	}
	return "[ ]"
}

func main() {
	adicionar("estudar Go")
	adicionar("fazer café")
	adicionar("ler um livro")
	concluir(1)
	remover(2)
	concluir(99) // id inexistente
	remover(50)  // id inexistente
}
*/
