package main

import "fmt"

// Módulo 07 — Interfaces
// Prática: do contrato básico ao polimorfismo, type assertion e type switch.

// ============================================================
// Exercício 1: Interface Animal com Cachorro e Gato
// ------------------------------------------------------------
// Definimos um contrato (Animal) e dois tipos que o satisfazem
// de forma IMPLÍCITA — basta ter os métodos certos.
// ============================================================

type Animal interface {
	Som() string
	Nome() string
}

type Cachorro struct {
	nome string
}

func (c Cachorro) Som() string  { return "Au au!" }
func (c Cachorro) Nome() string { return c.nome }

type Gato struct {
	nome string
}

func (g Gato) Som() string  { return "Miau!" }
func (g Gato) Nome() string { return g.nome }

func apresentar(a Animal) {
	fmt.Printf("  %s faz %s\n", a.Nome(), a.Som())
}

func exercicio1() {
	rex := Cachorro{nome: "Rex"}
	mia := Gato{nome: "Mia"}

	// A função apresentar aceita qualquer Animal:
	apresentar(rex)
	apresentar(mia)
}

// ============================================================
// Exercício 2: Slice de Animal — polimorfismo de verdade
// ------------------------------------------------------------
// Um slice de interface guarda tipos concretos diferentes
// e iteramos sobre eles sem nos preocupar com qual é qual.
// ============================================================

type Vaca struct {
	nome string
}

func (v Vaca) Som() string  { return "Muuu!" }
func (v Vaca) Nome() string { return v.nome }

func exercicio2() {
	// Mistura de tipos diferentes no mesmo slice — possível
	// porque todos satisfazem a interface Animal.
	bichos := []Animal{
		Cachorro{nome: "Rex"},
		Gato{nome: "Mia"},
		Vaca{nome: "Mimosa"},
	}

	for _, b := range bichos {
		apresentar(b)
	}
}

// ============================================================
// Exercício 3: Stringer — controlar como o tipo é impresso
// ------------------------------------------------------------
// Implementando String() string, fmt.Println usa AUTOMATICAMENTE
// nossa versão bonita. Mágica do pacote fmt.
// ============================================================

type Pessoa struct {
	Nome  string
	Idade int
}

// Basta existir. fmt detecta sozinho.
func (p Pessoa) String() string {
	return fmt.Sprintf("%s (%d anos)", p.Nome, p.Idade)
}

func exercicio3() {
	p := Pessoa{Nome: "David", Idade: 30}

	// Sem String() seria: {David 30}
	// Com String()  fica:  David (30 anos)
	fmt.Println("  ", p)
	fmt.Printf("   Formatado: %s\n", p)
}

// ============================================================
// Exercício 4: Interface Calculadora com várias implementações
// ------------------------------------------------------------
// Mesmo contrato (Calcular), comportamentos completamente
// diferentes. Polimorfismo aplicado em "estratégias".
// ============================================================

type Calculadora interface {
	Calcular(a, b float64) float64
}

type Soma struct{}
type Subtracao struct{}
type Multiplicacao struct{}

func (Soma) Calcular(a, b float64) float64          { return a + b }
func (Subtracao) Calcular(a, b float64) float64     { return a - b }
func (Multiplicacao) Calcular(a, b float64) float64 { return a * b }

func executarConta(c Calculadora, a, b float64) {
	fmt.Printf("  Resultado: %.2f\n", c.Calcular(a, b))
}

func exercicio4() {
	executarConta(Soma{}, 10, 5)
	executarConta(Subtracao{}, 10, 5)
	executarConta(Multiplicacao{}, 10, 5)
}

// ============================================================
// Exercício 5: Type assertion segura (ok pattern)
// ------------------------------------------------------------
// Pegando o tipo concreto de dentro de uma interface SEM
// risco de pânico.
// ============================================================

func descreverComAssertion(x any) {
	// Tentamos converter para string:
	if s, ok := x.(string); ok {
		fmt.Printf("  Era string: %q (tamanho %d)\n", s, len(s))
		return
	}
	// Tentamos converter para int:
	if n, ok := x.(int); ok {
		fmt.Printf("  Era int: %d (dobro = %d)\n", n, n*2)
		return
	}
	fmt.Printf("  Não sei o tipo de %v\n", x)
}

func exercicio5() {
	descreverComAssertion("Olá")
	descreverComAssertion(42)
	descreverComAssertion(3.14) // não é string nem int
}

// ============================================================
// Exercício 6: Type switch — tratar vários tipos elegantemente
// ------------------------------------------------------------
// switch v := x.(type) é a forma idiomática quando precisamos
// agir diferente para 3 ou mais tipos.
// ============================================================

func descrever(x any) {
	switch v := x.(type) {
	case int:
		fmt.Printf("  int: %d (dobro = %d)\n", v, v*2)
	case string:
		fmt.Printf("  string: %q (tamanho = %d)\n", v, len(v))
	case bool:
		fmt.Printf("  bool: %v (negação = %v)\n", v, !v)
	case []int:
		fmt.Printf("  slice de int com %d elementos: %v\n", len(v), v)
	case Animal:
		// Funciona porque Animal é uma interface também.
		fmt.Printf("  É um Animal! %s faz %s\n", v.Nome(), v.Som())
	default:
		fmt.Printf("  tipo desconhecido: %v\n", v)
	}
}

func exercicio6() {
	descrever(7)
	descrever("texto")
	descrever(true)
	descrever([]int{1, 2, 3})
	descrever(Cachorro{nome: "Rex"})
	descrever(3.14) // cai no default
}

// ============================================================
// Exercício 7: error é uma interface — criando o seu próprio
// ------------------------------------------------------------
// "error" é só interface { Error() string }. Implementando esse
// método, qualquer struct vira um erro de verdade.
// ============================================================

type ErroValidacao struct {
	Campo  string
	Motivo string
}

func (e ErroValidacao) Error() string {
	return fmt.Sprintf("campo %q inválido: %s", e.Campo, e.Motivo)
}

func validarIdade(idade int) error {
	if idade < 0 {
		return ErroValidacao{Campo: "idade", Motivo: "não pode ser negativa"}
	}
	if idade > 150 {
		return ErroValidacao{Campo: "idade", Motivo: "exageradamente alta"}
	}
	return nil
}

func exercicio7() {
	for _, i := range []int{30, -5, 999} {
		if err := validarIdade(i); err != nil {
			fmt.Printf("  idade=%d => ERRO: %s\n", i, err)

			// Type assertion para pegar os detalhes:
			if ev, ok := err.(ErroValidacao); ok {
				fmt.Printf("    (campo afetado: %s)\n", ev.Campo)
			}
		} else {
			fmt.Printf("  idade=%d => OK\n", i)
		}
	}
}

func main() {
	fmt.Println("=== Exercício 1: Interface Animal (Cachorro, Gato) ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Slice de Animal (polimorfismo) ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: Stringer (String() string) ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Calculadora (várias implementações) ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Type assertion com ok pattern ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Type switch ===")
	exercicio6()

	fmt.Println("\n=== Exercício 7: Criando seu próprio error ===")
	exercicio7()
}
