package main

import (
	"fmt"
	"sort"
)

// Módulo 06 — Structs e Métodos
// Prática: definindo tipos próprios, métodos com receiver de valor/ponteiro,
// composição e slice de structs.

// ============================================================
// Exercício 1: definir uma struct e criar valores
// ============================================================
// Vamos modelar uma Pessoa com Nome, Idade e Email.

type Pessoa struct {
	Nome  string
	Idade int
	Email string
}

func exercicio1() {
	// Literal nomeado — recomendado: fica claro qual campo é qual.
	p1 := Pessoa{
		Nome:  "Ana",
		Idade: 28,
		Email: "ana@email.com",
	}

	// Literal posicional — frágil, mas válido.
	p2 := Pessoa{"Bruno", 35, "bruno@email.com"}

	// Zero value — todos os campos com o valor zero do tipo.
	var p3 Pessoa

	fmt.Printf("p1 = %+v\n", p1)
	fmt.Printf("p2 = %+v\n", p2)
	fmt.Printf("p3 = %+v (zero value)\n", p3)
}

// ============================================================
// Exercício 2: métodos de leitura (receiver de valor)
// ============================================================
// Como só vamos LER os campos, receiver de valor está ótimo.

func (p Pessoa) Apresentar() string {
	return fmt.Sprintf("Olá! Sou %s, tenho %d anos.", p.Nome, p.Idade)
}

func (p Pessoa) Adulto() bool {
	return p.Idade >= 18
}

func exercicio2() {
	p := Pessoa{Nome: "Ana", Idade: 28, Email: "ana@email.com"}

	fmt.Println(p.Apresentar())
	fmt.Println("É adulto?", p.Adulto())
}

// ============================================================
// Exercício 3: struct Retangulo com Area e Perimetro
// ============================================================
// Cálculos puros — só leem campos.

type Retangulo struct {
	Largura float64
	Altura  float64
}

func (r Retangulo) Area() float64 {
	return r.Largura * r.Altura
}

func (r Retangulo) Perimetro() float64 {
	return 2 * (r.Largura + r.Altura)
}

func exercicio3() {
	ret := Retangulo{Largura: 3, Altura: 4}
	fmt.Printf("Retângulo %vx%v\n", ret.Largura, ret.Altura)
	fmt.Println("Área:     ", ret.Area())
	fmt.Println("Perímetro:", ret.Perimetro())
}

// ============================================================
// Exercício 4: receiver de VALOR não modifica
// ============================================================
// Demonstrando a "pegadinha" clássica: o método parece mudar, mas não muda.

func (r Retangulo) EscalarValor(fator float64) {
	// muda apenas a cópia local — não afeta o original
	r.Largura *= fator
	r.Altura *= fator
}

func exercicio4() {
	ret := Retangulo{Largura: 3, Altura: 4}
	ret.EscalarValor(10)
	fmt.Printf("Depois de EscalarValor(10): %+v (não mudou!)\n", ret)
}

// ============================================================
// Exercício 5: receiver de PONTEIRO modifica de verdade
// ============================================================
// Quando precisa alterar a struct, o receiver tem que ser *T.

func (r *Retangulo) EscalarPonteiro(fator float64) {
	r.Largura *= fator
	r.Altura *= fator
}

func exercicio5() {
	ret := Retangulo{Largura: 3, Altura: 4}
	ret.EscalarPonteiro(10) // Go já entende o &ret automaticamente
	fmt.Printf("Depois de EscalarPonteiro(10): %+v (mudou!)\n", ret)
}

// ============================================================
// Exercício 6: struct aninhada (Endereco dentro de Pessoa)
// ============================================================
// Composição: uma struct contém outra. Acesso com .campo.subcampo.

type Endereco struct {
	Rua    string
	Cidade string
	UF     string
}

type PessoaComEndereco struct {
	Nome     string
	Idade    int
	Endereco Endereco
}

func exercicio6() {
	p := PessoaComEndereco{
		Nome:  "Carla",
		Idade: 40,
		Endereco: Endereco{
			Rua:    "Rua das Flores, 123",
			Cidade: "São Paulo",
			UF:     "SP",
		},
	}

	fmt.Println("Nome:  ", p.Nome)
	fmt.Println("Cidade:", p.Endereco.Cidade) // dois pontos para chegar lá
	fmt.Printf("Full: %+v\n", p)
}

// ============================================================
// Exercício 7: slice de structs + ordenação com sort.Slice
// ============================================================
// Coleção de pessoas, ordenada por idade.

func exercicio7() {
	pessoas := []Pessoa{
		{Nome: "Ana", Idade: 28},
		{Nome: "Bruno", Idade: 35},
		{Nome: "Carla", Idade: 22},
		{Nome: "Diego", Idade: 41},
	}

	// sort.Slice recebe o slice e uma função "menor que" — define a regra.
	sort.Slice(pessoas, func(i, j int) bool {
		return pessoas[i].Idade < pessoas[j].Idade
	})

	fmt.Println("Ordenadas por idade (crescente):")
	for _, p := range pessoas {
		fmt.Printf("  %s — %d anos\n", p.Nome, p.Idade)
	}

	// Ordenar por nome (alfabético):
	sort.Slice(pessoas, func(i, j int) bool {
		return pessoas[i].Nome < pessoas[j].Nome
	})

	fmt.Println("Ordenadas por nome (alfabético):")
	for _, p := range pessoas {
		fmt.Printf("  %s\n", p.Nome)
	}
}

// ============================================================
// Exercício 8: "construtor" — função que devolve a struct pronta
// ============================================================
// Em Go não existe `new Pessoa(...)`. Convenção: criar uma função NovaX/NewX.

func NovaPessoa(nome string, idade int, email string) Pessoa {
	return Pessoa{
		Nome:  nome,
		Idade: idade,
		Email: email,
	}
}

// Quando o "construtor" pode falhar, devolva (T, error).
// (Vamos aprofundar erros no módulo 8 — aqui é só um aperitivo.)
func NovaPessoaSegura(nome string, idade int) (Pessoa, error) {
	if nome == "" {
		return Pessoa{}, fmt.Errorf("nome não pode ser vazio")
	}
	if idade < 0 {
		return Pessoa{}, fmt.Errorf("idade não pode ser negativa")
	}
	return Pessoa{Nome: nome, Idade: idade}, nil
}

func exercicio8() {
	p := NovaPessoa("Eduardo", 50, "edu@email.com")
	fmt.Printf("Via construtor: %+v\n", p)

	_, err := NovaPessoaSegura("", 30)
	if err != nil {
		fmt.Println("Erro esperado:", err)
	}

	ok, _ := NovaPessoaSegura("Fernanda", 33)
	fmt.Printf("OK: %+v\n", ok)
}

// ============================================================
// main: executa todos os exercícios em sequência
// ============================================================

func main() {
	fmt.Println("=== Exercício 1: criando structs ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: métodos de leitura ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Retangulo (Area/Perimetro) ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: receiver de VALOR (não modifica) ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: receiver de PONTEIRO (modifica) ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: struct aninhada (Endereco) ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: slice de structs + sort.Slice ===")
	exercicio7()

	fmt.Println("\n=== Exercício 8: construtores (NovaPessoa) ===")
	exercicio8()
}
