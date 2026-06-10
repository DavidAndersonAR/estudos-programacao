package main

import "fmt"

// Exercícios práticos: Declarações e Escopo

// Exercício 1: Declaração com var vs :=
// Use as duas formas no mesmo contexto.
func exercicio1() {
	// Forma longa (var)
	var nome string = "Ana"
	var idade int = 25

	// Forma curta (:=) — só funciona dentro de função
	cidade := "São Paulo"
	estado := "SP"

	fmt.Println(nome, idade, cidade, estado)
}

// Exercício 2: Identificador em branco _
// Use _ para descartar valores que não te interessam.
func dadosUsuario() (string, int, bool) {
	return "João", 30, true
}

func exercicio2() {
	// Só queremos o nome, descartamos os outros
	nome, _, _ := dadosUsuario()
	fmt.Println("Nome:", nome)

	// Em loops, _ é comum quando não usamos o índice
	frutas := []string{"maçã", "banana", "uva"}
	for _, f := range frutas {
		fmt.Println(f)
	}
}

// Exercício 3: Identificadores exportados (maiúscula) vs privados (minúscula)
// Os com inicial maiúscula podem ser usados por outros pacotes; minúscula, só interno.

// Exportado (público): outro pacote consegue usar
type Produto struct {
	Nome  string  // exportado
	preco float64 // não exportado (privado do pacote)
}

// Método exportado
func (p Produto) Preco() float64 {
	return p.preco
}

func exercicio3() {
	p := Produto{Nome: "Café", preco: 5.50}
	fmt.Println(p.Nome)    // OK — exportado
	fmt.Println(p.Preco()) // acessamos via método
}

// Exercício 4: Declaração de tipo (type)
// Crie um tipo próprio e um alias.
type Temperatura float64       // tipo novo (definição)
type Fahrenheit = Temperatura  // alias (mesmo tipo, outro nome)

func exercicio4() {
	var t Temperatura = 25.5
	var f Fahrenheit = 77.0

	// Alias = mesmo tipo, então isto compila normalmente
	t = f
	fmt.Println("Temperatura:", t)
}

// Exercício 5: Função e método com receiver
type Retangulo struct {
	Largura, Altura float64
}

// Método: função com receiver. Pertence ao tipo Retangulo.
func (r Retangulo) Area() float64 {
	return r.Largura * r.Altura
}

// Função normal (sem receiver)
func criarRetangulo(l, a float64) Retangulo {
	return Retangulo{Largura: l, Altura: a}
}

func exercicio5() {
	r := criarRetangulo(4, 5)
	fmt.Println("Área:", r.Area())
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
}
