package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 09 — Lista Encadeada
//
// Objetivo:
// Implementar uma LISTA ENCADEADA simples. Cada elemento (chamado "nó") guarda
// um valor inteiro e um PONTEIRO para o próximo nó. O último nó aponta para nil.
//
// Esquema:
//
//   [10] -> [20] -> [30] -> nil
//
// Operações que você precisa implementar:
//
//   1) Inserir no fim
//        - Adiciona um novo nó com o valor recebido no FINAL da lista.
//        - Se a lista estiver vazia, esse novo nó vira o primeiro.
//
//   2) Percorrer e imprimir
//        - Imprime os valores na ordem: 10 -> 20 -> 30 -> nil
//
//   3) Contar nós
//        - Retorna quantos nós existem na lista.
//
//   4) Remover por valor
//        - Remove o PRIMEIRO nó que tem aquele valor.
//        - Se não encontrar, não faz nada (ou retorna false).
//
// Estrutura sugerida:
//
//   type No struct {
//       valor    int
//       proximo  *No
//   }
//
//   type Lista struct {
//       inicio *No
//   }
//
// 💡 Dicas:
// - O "inicio" da Lista guarda o primeiro nó. Se for nil, a lista está vazia.
// - Para andar na lista: comece em `atual := l.inicio` e vá fazendo `atual = atual.proximo`
//   até `atual == nil`.
// - Para inserir no fim: ande até achar um nó cujo `proximo == nil` e ligue o novo lá.
// - Para remover: precisa lembrar do nó ANTERIOR para "pular" o nó removido.
//   (Caso especial: remover o primeiro — basta atualizar `l.inicio`.)
// - Todos os métodos que MODIFICAM a lista devem ter receiver `*Lista`.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente sua Lista Encadeada.
	// Exemplo de teste que você pode usar:
	//
	//   l := &Lista{}
	//   l.InserirFim(10)
	//   l.InserirFim(20)
	//   l.InserirFim(30)
	//   l.Imprimir()           // 10 -> 20 -> 30 -> nil
	//   fmt.Println(l.Contar()) // 3
	//   l.Remover(20)
	//   l.Imprimir()           // 10 -> 30 -> nil
	//
	fmt.Println("(implemente sua lista encadeada aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// No é cada elemento da lista: guarda um valor e aponta pro próximo.
type No struct {
	valor   int
	proximo *No // nil = não tem próximo (é o último)
}

// Lista guarda só o ponteiro pro primeiro nó.
// Se inicio == nil, a lista está vazia.
type Lista struct {
	inicio *No
}

// InserirFim adiciona um novo nó com o valor dado no FINAL da lista.
// Receiver de ponteiro porque vamos modificar a lista (l.inicio, etc).
func (l *Lista) InserirFim(valor int) {
	novo := &No{valor: valor} // proximo já vem nil (zero value)

	// Caso 1: lista vazia — o novo nó vira o primeiro.
	if l.inicio == nil {
		l.inicio = novo
		return
	}

	// Caso 2: anda até achar o último (aquele cujo proximo é nil) e liga lá.
	atual := l.inicio
	for atual.proximo != nil {
		atual = atual.proximo
	}
	atual.proximo = novo
}

// Imprimir percorre a lista e imprime: 10 -> 20 -> 30 -> nil
func (l *Lista) Imprimir() {
	atual := l.inicio
	for atual != nil {
		fmt.Printf("%d -> ", atual.valor)
		atual = atual.proximo
	}
	fmt.Println("nil")
}

// Contar devolve quantos nós existem.
// Não modifica nada, mas usamos *Lista por consistência com os outros métodos.
func (l *Lista) Contar() int {
	total := 0
	atual := l.inicio
	for atual != nil {
		total++
		atual = atual.proximo
	}
	return total
}

// Remover apaga o PRIMEIRO nó que tem `valor`. Retorna true se removeu, false se não achou.
func (l *Lista) Remover(valor int) bool {
	// Lista vazia: nada a fazer.
	if l.inicio == nil {
		return false
	}

	// Caso especial: o nó a remover é o PRIMEIRO.
	if l.inicio.valor == valor {
		l.inicio = l.inicio.proximo // pula o primeiro
		return true
	}

	// Caso geral: precisamos do nó ANTERIOR pra "pular" o que será removido.
	anterior := l.inicio
	atual := l.inicio.proximo
	for atual != nil {
		if atual.valor == valor {
			anterior.proximo = atual.proximo // liga anterior direto no próximo do removido
			return true
		}
		anterior = atual
		atual = atual.proximo
	}

	// Não achou.
	return false
}

func main() {
	l := &Lista{}

	fmt.Println("--- Lista recém-criada ---")
	l.Imprimir()                  // nil
	fmt.Println("Tamanho:", l.Contar()) // 0

	fmt.Println("\n--- Inserindo 10, 20, 30, 40 ---")
	l.InserirFim(10)
	l.InserirFim(20)
	l.InserirFim(30)
	l.InserirFim(40)
	l.Imprimir()                  // 10 -> 20 -> 30 -> 40 -> nil
	fmt.Println("Tamanho:", l.Contar()) // 4

	fmt.Println("\n--- Removendo 20 (do meio) ---")
	ok := l.Remover(20)
	fmt.Println("Removeu?", ok)
	l.Imprimir() // 10 -> 30 -> 40 -> nil

	fmt.Println("\n--- Removendo 10 (do início) ---")
	l.Remover(10)
	l.Imprimir() // 30 -> 40 -> nil

	fmt.Println("\n--- Tentando remover 999 (não existe) ---")
	ok = l.Remover(999)
	fmt.Println("Removeu?", ok)
	l.Imprimir() // 30 -> 40 -> nil

	fmt.Println("\n--- Removendo o restante ---")
	l.Remover(30)
	l.Remover(40)
	l.Imprimir()                  // nil
	fmt.Println("Tamanho:", l.Contar()) // 0
}
*/
