package main

import "fmt"

// Módulo 09 — Ponteiros
// Prática: do básico (& e *) até receiver de ponteiro e structs grandes.

// Exercício 1: Dobrar um valor via ponteiro
// A função recebe *int, vai até o endereço e modifica o valor original.
func dobrar(n *int) {
	*n = *n * 2 // dereferência para LER e ESCREVER no endereço
}

func exercicio1() {
	x := 7
	fmt.Println("Antes :", x)
	dobrar(&x) // passamos o ENDEREÇO de x
	fmt.Println("Depois:", x)
}

// Exercício 2: Swap (trocar) duas variáveis usando ponteiros
// Sem ponteiro, a troca aconteceria só dentro da função — inútil.
func swap(a, b *int) {
	*a, *b = *b, *a // Go aceita atribuição múltipla
}

func exercicio2() {
	x, y := 10, 20
	fmt.Printf("Antes : x=%d, y=%d\n", x, y)
	swap(&x, &y)
	fmt.Printf("Depois: x=%d, y=%d\n", x, y)
}

// Exercício 3: Struct com método incrementar usando receiver de ponteiro
// Se o receiver fosse por valor, o contador NUNCA aumentaria.
type Contador struct {
	valor int
}

// Receiver por PONTEIRO — modifica a struct real
func (c *Contador) Incrementar() {
	c.valor++ // Go entende c.valor como (*c).valor automaticamente
}

// Receiver por VALOR — só lê, recebe uma cópia
func (c Contador) Mostrar() {
	fmt.Println("Valor do contador:", c.valor)
}

func exercicio3() {
	c := Contador{valor: 0}
	c.Mostrar()
	c.Incrementar()
	c.Incrementar()
	c.Incrementar()
	c.Mostrar() // 3
}

// Exercício 4: Slice modificado por valor vs por ponteiro
// CURIOSIDADE: o "header" do slice (ponteiro interno + len + cap) é copiado,
// mas o ARRAY apontado é compartilhado. Mexer nos índices funciona;
// trocar o slice inteiro (s = append(...)) pode não refletir fora.
func zerarPorValor(s []int) {
	for i := range s {
		s[i] = 0 // muda os elementos do array — VISÍVEL FORA
	}
	s = append(s, 99) // reatribuição local — INVISÍVEL FORA (na maioria dos casos)
}

func zerarPorPonteiro(s *[]int) {
	for i := range *s {
		(*s)[i] = 0
	}
	*s = append(*s, 99) // agora SIM aparece fora
}

func exercicio4() {
	s1 := []int{1, 2, 3}
	zerarPorValor(s1)
	fmt.Println("Por valor   :", s1) // [0 0 0] — sem o 99

	s2 := []int{1, 2, 3}
	zerarPorPonteiro(&s2)
	fmt.Println("Por ponteiro:", s2) // [0 0 0 99]
}

// Exercício 5: Demonstrar ponteiro nil (com segurança)
// Mostramos como CHECAR antes de dereferenciar para evitar panic.
func mostrarSeguro(p *int) {
	if p == nil {
		fmt.Println("Ponteiro é nil — nada a mostrar.")
		return
	}
	fmt.Println("Valor apontado:", *p)
}

func exercicio5() {
	var p *int // zero value de ponteiro é nil
	mostrarSeguro(p)

	x := 42
	p = &x
	mostrarSeguro(p)

	// Se descomentar a linha abaixo com p = nil, dá PANIC:
	// var q *int
	// fmt.Println(*q)
}

// Exercício 6: new(int) — criando um inteiro e pegando ponteiro pra ele
// new(T) aloca, zera e devolve *T. Pouco usado, mas existe.
func exercicio6() {
	p := new(int)    // *int apontando para um int zerado
	fmt.Println(*p)  // 0
	*p = 100
	fmt.Println(*p) // 100

	// Equivalente prático mais idiomático:
	x := 0
	q := &x
	*q = 100
	fmt.Println(*q) // 100
}

// Exercício 7: Passar struct grande por ponteiro (economia de cópia)
// Imagine uma struct com 20 campos. Copiar a cada chamada é desperdício.
type Relatorio struct {
	Titulo      string
	Autor       string
	Paginas     int
	Linhas      int
	Palavras    int
	Caracteres  int
	Versao      string
	Aprovado    bool
	// ... imagine mais 12 campos aqui
}

// Recebe ponteiro: rápido (passa só o endereço, ~8 bytes) e permite alterar.
func aprovar(r *Relatorio) {
	r.Aprovado = true
	r.Versao = "1.0"
}

func resumo(r *Relatorio) {
	fmt.Printf("%q por %s — %d pgs, aprovado=%v, v%s\n",
		r.Titulo, r.Autor, r.Paginas, r.Aprovado, r.Versao)
}

func exercicio7() {
	r := Relatorio{
		Titulo:  "Ponteiros em Go",
		Autor:   "David",
		Paginas: 12,
	}
	resumo(&r)
	aprovar(&r)
	resumo(&r)
}

func main() {
	fmt.Println("=== Exercício 1: Dobrar via ponteiro ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Swap com ponteiros ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Método com receiver de ponteiro ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Slice por valor vs por ponteiro ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Ponteiro nil (com segurança) ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: new(int) ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: Struct grande por ponteiro ===")
	exercicio7()
}
