package main

import (
	"fmt"
	"strings"
)

// 🎯 DESAFIO DO MÓDULO 10 — Biblioteca de Utilitários
//
// Objetivo:
// Construir sua própria "biblioteca" de funções utilitárias, organizadas em
// três seções:
//   1. Strings:  Capitalize, Reverter, ContarPalavras
//   2. Números:  EhPar, EhPrimo, MDC
//   3. Slice:    RemoverDuplicatas, Interseccao
//
// O ideal seria cada seção em um arquivo (ou pacote!) separado. Como ainda
// não chegamos lá, vamos manter tudo em um único arquivo, MAS organizado
// em seções bem marcadas com comentários — como se fossem "sub-pacotes".
//
// Cada função deve:
//   - Ter nome com letra MAIÚSCULA (convenção de exportada, mesmo em pacote main)
//   - Ter um comentário explicando o que faz
//   - Ser pequena, focada em uma coisa só
//
// A função main() deve DEMONSTRAR todas elas, mostrando entrada e saída.
//
// Saída esperada (exemplo):
//
//   --- STRINGS ---
//   Capitalize('olá mundo')      = Olá Mundo
//   Reverter('abcdef')           = fedcba
//   ContarPalavras('um dois três') = 3
//   --- NÚMEROS ---
//   EhPar(4)                     = true
//   EhPrimo(7)                   = true
//   MDC(12, 18)                  = 6
//   --- SLICES ---
//   RemoverDuplicatas(...)       = [1 2 3 4]
//   Interseccao(...)             = [2 3]
//
// 💡 Dicas:
// - strings.Title está deprecada; faça Capitalize na mão (split, ToUpper na 1ª letra).
// - Para Reverter, converta a string em []rune (para suportar acentos) e inverta.
// - Primo: n > 1 e não divisível por nenhum número de 2 até sqrt(n).
// - MDC: algoritmo de Euclides — mdc(a,b) = mdc(b, a%b), parando quando b==0.
// - RemoverDuplicatas: use um map[T]bool como "visto".
// - Interseccao: passe um slice pra um map, percorra o outro e veja quem está no map.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente as funções nas três seções e chame todas aqui.
	//
	// Roteiro sugerido:
	// 1. Crie a seção "STRINGS" com Capitalize, Reverter, ContarPalavras.
	// 2. Crie a seção "NÚMEROS" com EhPar, EhPrimo, MDC.
	// 3. Crie a seção "SLICES"  com RemoverDuplicatas e Interseccao.
	// 4. Em main(), demonstre cada uma delas com um exemplo.
	fmt.Println("(implemente sua Biblioteca de Utilitários aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// ────────────────────────────────────────────────────────────
// SEÇÃO 1 — STRINGS
// Funções utilitárias para manipulação de texto.
// ────────────────────────────────────────────────────────────

// Capitalize deixa a primeira letra de cada palavra em maiúscula.
// Ex.: "olá mundo go" -> "Olá Mundo Go"
func Capitalize(s string) string {
	palavras := strings.Fields(s) // Fields quebra por qualquer espaço em branco
	for i, p := range palavras {
		if p == "" {
			continue
		}
		runes := []rune(p)                       // []rune lida bem com acentos
		runes[0] = []rune(strings.ToUpper(string(runes[0])))[0]
		palavras[i] = string(runes)
	}
	return strings.Join(palavras, " ")
}

// Reverter inverte a ordem dos caracteres de uma string.
// Usa []rune pra não bagunçar caracteres multi-byte (á, ç, emoji).
// Ex.: "abcdef" -> "fedcba"
func Reverter(s string) string {
	runes := []rune(s)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i] // troca clássica
	}
	return string(runes)
}

// ContarPalavras devolve quantas palavras tem na string.
// strings.Fields ignora espaços extras, tabs e quebras de linha.
// Ex.: "um  dois  três" -> 3
func ContarPalavras(s string) int {
	return len(strings.Fields(s))
}

// ────────────────────────────────────────────────────────────
// SEÇÃO 2 — NÚMEROS
// Funções utilitárias para inteiros.
// ────────────────────────────────────────────────────────────

// EhPar devolve true se n for par.
// Truque: par é todo número cujo resto da divisão por 2 é zero.
func EhPar(n int) bool {
	return n%2 == 0
}

// EhPrimo devolve true se n for primo.
// Primo: n > 1 e só divisível por 1 e por ele mesmo.
// Otimização: só precisamos testar divisores até sqrt(n).
func EhPrimo(n int) bool {
	if n < 2 {
		return false
	}
	// i*i <= n é o mesmo que i <= sqrt(n), sem usar float.
	for i := 2; i*i <= n; i++ {
		if n%i == 0 {
			return false // achou divisor -> não é primo
		}
	}
	return true
}

// MDC devolve o Máximo Divisor Comum entre a e b.
// Algoritmo de Euclides — bem antigo e bem elegante.
// Ex.: MDC(12, 18) = 6
func MDC(a, b int) int {
	// Garantimos que trabalhamos com valores positivos.
	if a < 0 {
		a = -a
	}
	if b < 0 {
		b = -b
	}
	for b != 0 {
		a, b = b, a%b // o segredo: troca simultânea
	}
	return a
}

// ────────────────────────────────────────────────────────────
// SEÇÃO 3 — SLICES
// Funções utilitárias para []int.
// ────────────────────────────────────────────────────────────

// RemoverDuplicatas devolve um novo slice sem valores repetidos.
// A ordem dos elementos é preservada (primeiro aparecimento ganha).
// Ex.: [1 2 2 3 1 4] -> [1 2 3 4]
func RemoverDuplicatas(s []int) []int {
	visto := map[int]bool{}    // map serve como "set"
	resultado := []int{}
	for _, v := range s {
		if !visto[v] { // se ainda não vimos esse valor
			visto[v] = true
			resultado = append(resultado, v)
		}
	}
	return resultado
}

// Interseccao devolve os elementos que aparecem em A E em B (sem repetições).
// Estratégia: jogamos A em um map, depois percorremos B vendo quem está lá.
// Ex.: ([1 2 3], [2 3 4]) -> [2 3]
func Interseccao(a, b []int) []int {
	emA := map[int]bool{}
	for _, v := range a {
		emA[v] = true
	}
	jaAdicionado := map[int]bool{}
	resultado := []int{}
	for _, v := range b {
		if emA[v] && !jaAdicionado[v] { // está em A e ainda não foi incluído
			resultado = append(resultado, v)
			jaAdicionado[v] = true
		}
	}
	return resultado
}

// ────────────────────────────────────────────────────────────
// MAIN — demonstração de todas as funções
// ────────────────────────────────────────────────────────────

func main() {
	fmt.Println("--- STRINGS ---")
	fmt.Printf("Capitalize(%q)      = %s\n", "olá mundo go", Capitalize("olá mundo go"))
	fmt.Printf("Reverter(%q)        = %s\n", "abcdef", Reverter("abcdef"))
	fmt.Printf("ContarPalavras(%q)  = %d\n", "um dois três quatro", ContarPalavras("um dois três quatro"))

	fmt.Println("\n--- NÚMEROS ---")
	fmt.Printf("EhPar(4)   = %v\n", EhPar(4))
	fmt.Printf("EhPar(7)   = %v\n", EhPar(7))
	fmt.Printf("EhPrimo(7) = %v\n", EhPrimo(7))
	fmt.Printf("EhPrimo(9) = %v\n", EhPrimo(9))
	fmt.Printf("MDC(12,18) = %d\n", MDC(12, 18))
	fmt.Printf("MDC(48,36) = %d\n", MDC(48, 36))

	fmt.Println("\n--- SLICES ---")
	original := []int{1, 2, 2, 3, 1, 4, 3, 5}
	fmt.Printf("RemoverDuplicatas(%v) = %v\n", original, RemoverDuplicatas(original))

	a := []int{1, 2, 3, 4}
	b := []int{3, 4, 5, 6}
	fmt.Printf("Interseccao(%v, %v) = %v\n", a, b, Interseccao(a, b))
}
*/

// Linha de import abaixo só pra evitar erro "imported and not used"
// enquanto o aluno ainda não implementou nada. Você pode remover
// quando começar a usar 'strings' de verdade.
var _ = strings.ToUpper
