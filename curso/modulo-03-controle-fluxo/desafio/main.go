package main

import (
	"fmt"
	// "math/rand"  // descomente quando for usar a solução abaixo
)

// 🎯 DESAFIO DO MÓDULO 03 — Jogo de Adivinhação
//
// Objetivo:
// O computador sorteia um número secreto entre 1 e 100.
// O jogador faz tentativas. Para cada tentativa, o programa responde:
//   - "maior!"   se o palpite for MENOR que o segredo
//   - "menor!"   se o palpite for MAIOR que o segredo
//   - "acertou!" se o palpite for igual ao segredo
//
// Como não vamos ler input do teclado neste módulo (isso é mais à frente),
// vamos SIMULAR uma rodada com uma lista de tentativas pré-definida.
//
// Saída esperada (exemplo, varia conforme o sorteio):
//
//   Número secreto sorteado entre 1 e 100.
//   Tentativa 1: 50 -> maior!
//   Tentativa 2: 75 -> menor!
//   Tentativa 3: 62 -> maior!
//   Tentativa 4: 68 -> acertou! Em 4 tentativas.
//
// Requisitos:
// 1. Use `math/rand` para sortear o número secreto entre 1 e 100.
// 2. Tenha uma slice de tentativas (palpites do "jogador") já pronta.
// 3. Use um `for range` (ou for clássico) para percorrer as tentativas.
// 4. Use `if/else if/else` OU `switch` sem expressão para comparar palpite vs segredo.
// 5. Quando acertar, use `break` para parar o laço.
// 6. No final, imprima quantas tentativas foram necessárias.
//    Se acabarem as tentativas sem acerto, avise e mostre qual era o número.
//
// 💡 Dicas:
// - rand.Intn(100) devolve 0..99. Para ter 1..100, use rand.Intn(100) + 1.
// - Você pode usar um `switch` sem expressão para ficar mais limpo:
//     switch {
//     case palpite < segredo: ...
//     case palpite > segredo: ...
//     default: ... // acertou
//     }
// - Lembre de declarar uma variável tipo `acertou := false` para saber se houve acerto.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente seu Jogo de Adivinhação aqui.
	//
	// Roteiro sugerido:
	// 1. segredo := rand.Intn(100) + 1
	// 2. tentativas := []int{50, 75, 62, 68}   // ou qualquer lista
	// 3. for i, palpite := range tentativas { ... }
	// 4. Use if/switch para comparar e print as dicas.
	// 5. Use break quando acertar.
	// 6. Depois do for, mostre o resultado final.
	fmt.Println("(implemente o Jogo de Adivinhação aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
func main() {
	// 1. Sorteia o número secreto entre 1 e 100.
	segredo := rand.Intn(100) + 1
	fmt.Println("Número secreto sorteado entre 1 e 100.")

	// 2. Lista de palpites simulando as tentativas do jogador.
	//    Em um programa real, viriam do teclado.
	tentativas := []int{50, 25, 75, 62, 68, 70, 80, 90}

	// 3. Variável de controle para saber se houve acerto.
	acertou := false
	totalTentativas := 0

	// 4. Percorre as tentativas usando for-range.
	for i, palpite := range tentativas {
		totalTentativas = i + 1

		// 5. switch sem expressão para comparar — bem mais limpo que if/else if.
		switch {
		case palpite < segredo:
			fmt.Printf("Tentativa %d: %d -> maior!\n", totalTentativas, palpite)
		case palpite > segredo:
			fmt.Printf("Tentativa %d: %d -> menor!\n", totalTentativas, palpite)
		default:
			fmt.Printf("Tentativa %d: %d -> acertou! Em %d tentativas.\n",
				totalTentativas, palpite, totalTentativas)
			acertou = true
		}

		// 6. Quando acertar, sai do laço.
		if acertou {
			break
		}
	}

	// 7. Mensagem final se acabaram as tentativas sem acerto.
	if !acertou {
		fmt.Printf("Acabaram as tentativas! O número era %d.\n", segredo)
	}
}
*/
