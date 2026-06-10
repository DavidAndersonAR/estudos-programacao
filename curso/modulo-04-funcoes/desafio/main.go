package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 04 — Calculadora Modular
//
// Objetivo:
// Construir uma calculadora onde **cada operação é uma função separada**, e
// uma função genérica `calcular` aplica qualquer operação aos dois números.
//
// Operações que sua calculadora precisa ter (uma função pra cada):
//   - somar(a, b float64) float64
//   - subtrair(a, b float64) float64
//   - multiplicar(a, b float64) float64
//   - dividir(a, b float64) float64
//   - potencia(a, b float64) float64   // a elevado a b
//
// Requisitos:
// 1. Implemente uma função genérica:
//      calcular(a, b float64, op func(float64, float64) float64) float64
//    Ela recebe os dois números E a operação como parâmetro, e retorna o
//    resultado de aplicar `op` em `a` e `b`.
//
// 2. Monte um **map de operações** ligando o nome ao código:
//      operacoes := map[string]func(float64, float64) float64{
//          "+":  somar,
//          "-":  subtrair,
//          ...
//      }
//
// 3. Percorra esse map e mostre o resultado de cada operação com `a = 10` e
//    `b = 3`. Algo do tipo:
//      10.00 + 3.00 = 13.00
//      10.00 - 3.00 = 7.00
//      ...
//
// 4. (Bônus) Trate a divisão por zero — você pode usar uma função separada
//    `dividirSeguro` que devolve `(float64, error)`, ou retornar 0 com aviso.
//
// 💡 Dicas:
// - `math.Pow(a, b)` existe no pacote `math`, mas tente fazer a sua própria
//   só com `for` pra praticar.
// - Map em Go é declarado com `map[chave]valor{...}`.
// - Iterar map: `for nome, op := range operacoes { ... }`.
// - Lembra: função em Go é um valor — você pode botar dentro de map, slice,
//   struct, passar como parâmetro, retornar de outra função.
//
// Padrão esperado:
//   - Cada operação como função separada (comentada).
//   - `calcular` aceitando operação como parâmetro.
//   - main demonstrando o map de operações.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente sua calculadora modular aqui.
	// 1) Crie as funções: somar, subtrair, multiplicar, dividir, potencia.
	// 2) Crie a função `calcular(a, b, op)`.
	// 3) Crie o map de operações.
	// 4) Itere mostrando todos os resultados.
	fmt.Println("(implemente sua calculadora aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
package main

import "fmt"

// Cada operação é uma função separada com a MESMA assinatura:
// func(float64, float64) float64. Isso é o que permite usá-las de forma
// intercambiável dentro de `calcular` e do map.

func somar(a, b float64) float64 {
	return a + b
}

func subtrair(a, b float64) float64 {
	return a - b
}

func multiplicar(a, b float64) float64 {
	return a * b
}

// Aqui devolvemos 0 quando b == 0 só pra manter a assinatura uniforme.
// Em código real, o ideal é retornar (float64, error). Tem um exemplo
// disso logo abaixo como bônus.
func dividir(a, b float64) float64 {
	if b == 0 {
		fmt.Println("  [aviso] divisão por zero — retornando 0")
		return 0
	}
	return a / b
}

// Potência feita "na unha" só com for — sem usar math.Pow.
// Atenção: essa implementação simples só funciona para expoente inteiro >= 0.
func potencia(a, b float64) float64 {
	resultado := 1.0
	for i := 0; i < int(b); i++ {
		resultado *= a
	}
	return resultado
}

// Função genérica: aplica QUALQUER operação que tenha a assinatura
// func(float64, float64) float64. Essa é a peça-chave da calculadora modular.
func calcular(a, b float64, op func(float64, float64) float64) float64 {
	return op(a, b)
}

// Bônus: versão segura da divisão usando retorno múltiplo.
func dividirSeguro(a, b float64) (float64, error) {
	if b == 0 {
		return 0, fmt.Errorf("divisão por zero")
	}
	return a / b, nil
}

func main() {
	a, b := 10.0, 3.0

	// Map ligando o "símbolo" da operação à função que executa ela.
	// Repare como funções estão sendo guardadas como VALORES no map.
	operacoes := map[string]func(float64, float64) float64{
		"+": somar,
		"-": subtrair,
		"*": multiplicar,
		"/": dividir,
		"^": potencia,
	}

	fmt.Println("=== Calculadora Modular ===")
	fmt.Printf("a = %.2f, b = %.2f\n\n", a, b)

	// Itera o map. A ordem do range em map NÃO é garantida em Go —
	// se quiser ordem fixa, dá pra usar um slice de chaves ordenado.
	for simbolo, op := range operacoes {
		resultado := calcular(a, b, op)
		fmt.Printf("%.2f %s %.2f = %.2f\n", a, simbolo, b, resultado)
	}

	// Demonstrando o bônus: divisão segura com tratamento de erro
	fmt.Println("\n=== Bônus: divisão segura ===")
	if r, err := dividirSeguro(10, 0); err != nil {
		fmt.Println("10 / 0 ->", err)
	} else {
		fmt.Println("10 / 0 =", r)
	}

	// E pra mostrar que `calcular` aceita até função anônima:
	resto := calcular(10, 3, func(a, b float64) float64 {
		return float64(int(a) % int(b))
	})
	fmt.Printf("\nUsando função anônima como operação:\n10 %% 3 = %.2f\n", resto)
}
*/
