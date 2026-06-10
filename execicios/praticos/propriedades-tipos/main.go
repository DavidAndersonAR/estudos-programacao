package main

import "fmt"

// Exercícios práticos: Propriedades de Tipos e Valores

// Exercício 1: Tipo subjacente (underlying type)
// Criar um tipo próprio baseado em int. O underlying continua sendo int,
// mas é um tipo diferente para o compilador.
type Idade int

func exercicio1() {
	var i Idade = 25
	var n int = 30

	// i + n // ERRO! Idade e int são tipos diferentes
	// Precisa converter:
	soma := int(i) + n
	fmt.Println("Soma após conversão:", soma)
}

// Exercício 2: Identidade de tipos
// Dois tipos só são "iguais" se forem o mesmo nome ou tiverem estrutura idêntica.
type Celsius float64
type Fahrenheit float64

func exercicio2() {
	var c Celsius = 100
	var f Fahrenheit = 212

	// Mesmo underlying (float64), mas tipos diferentes — não dá pra somar direto
	resultado := float64(c) + float64(f)
	fmt.Println("Soma (com conversão):", resultado)
}

// Exercício 3: Atribuição entre tipos
// Quando um valor pode ser atribuído a outro tipo automaticamente.
func exercicio3() {
	// Constantes "untyped" se adaptam ao tipo de destino
	const x = 10
	var a int = x
	var b float64 = x
	var c byte = x

	fmt.Println(a, b, c)

	// Mas variáveis tipadas exigem conversão explícita
	var pequeno int8 = 5
	var grande int32 = int32(pequeno) // conversão explícita necessária
	fmt.Println(grande)
}

// Exercício 4: Method set por valor vs por ponteiro
// O método declarado com receiver de valor pertence a T E *T.
// O método declarado com receiver de ponteiro pertence só a *T.
type Contador struct {
	valor int
}

// Método com receiver de valor — só lê
func (c Contador) Valor() int {
	return c.valor
}

// Método com receiver de ponteiro — pode modificar
func (c *Contador) Incrementar() {
	c.valor++
}

func exercicio4() {
	c := Contador{valor: 0}
	c.Incrementar() // Go automaticamente usa &c
	c.Incrementar()
	c.Incrementar()
	fmt.Println("Valor após 3 incrementos:", c.Valor())
}

// Exercício 5: Method set e interface
// Para satisfazer uma interface com métodos de ponteiro, é preciso usar ponteiro.
type Falante interface {
	Falar() string
}

type Cachorro struct {
	Nome string
}

// Método com receiver de ponteiro
func (c *Cachorro) Falar() string {
	return c.Nome + " diz: Au au!"
}

func exercicio5() {
	// var f Falante = Cachorro{Nome: "Rex"}  // ERRO! Cachorro não satisfaz, só *Cachorro
	var f Falante = &Cachorro{Nome: "Rex"} // OK
	fmt.Println(f.Falar())
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
}
