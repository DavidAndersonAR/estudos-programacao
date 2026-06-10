package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 02 — Calculadora de IMC
//
// Objetivo:
// Crie um programa que calcule o IMC (Índice de Massa Corporal) de uma
// pessoa e mostre a classificação dela.
//
// Fórmula:
//   IMC = peso / (altura * altura)
//
// Tabela de classificação (OMS):
//   IMC < 18.5            -> Abaixo do peso
//   18.5 <= IMC < 25.0    -> Peso normal
//   25.0 <= IMC < 30.0    -> Sobrepeso
//   IMC >= 30.0           -> Obesidade
//
// Exemplo de saída esperada:
//
//   Peso:   72.50 kg
//   Altura: 1.75 m
//   IMC:    23.67
//   Classificação: Peso normal
//
// Requisitos:
// 1. Declare peso (float64) e altura (float64) como variáveis (pode ser
//    hardcoded — não precisa ler do teclado ainda).
// 2. Calcule o IMC e guarde em uma variável.
// 3. Use if/else para decidir a classificação (uma string).
// 4. Imprima tudo com fmt.Printf, mostrando o IMC com 2 casas decimais.
//
// 💡 Dicas:
// - Para elevar ao quadrado, simplesmente faça altura*altura. Nada de math.Pow
//   ainda — vamos manter simples.
// - %.2f imprime float com 2 casas decimais.
// - if/else em Go não usa parênteses na condição: if imc < 18.5 { ... }
// - Lembre: peso é float64 e altura é float64. Mantenha tudo no mesmo tipo
//   para evitar a chatice de conversão.
// - Teste com valores diferentes para ver as 4 classificações funcionando.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente sua Calculadora de IMC aqui.
	peso := 100.70
	altura := 1.67

	imc := peso / (altura * altura)

	var classificacao string

	if imc < 18.5 {
		classificacao = "Voce esta abaixo do peso"
	} else if imc < 25.0 {
		classificacao = "Voce esta com peso normal"
	} else if imc < 30.0 {
		classificacao = "Voce esta com sobrepeso"
	} else {
		classificacao = "Obesidade"
	}

	fmt.Printf("Peso: %.2f kg\n", peso)
	fmt.Printf("Altura: %.2f m\n", altura)
	fmt.Printf("IMC: %.2f\n", imc)
	fmt.Printf("Classificacao: %s\n", classificacao)
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
func main() {
	// 1. Dados de entrada (em uma versão futura, isso vai vir do teclado)
	peso := 72.5    // em quilogramas
	altura := 1.75  // em metros

	// 2. Cálculo do IMC
	imc := peso / (altura * altura)

	// 3. Classificação
	var classificacao string

	if imc < 18.5 {
		classificacao = "Abaixo do peso"
	} else if imc < 25.0 {
		classificacao = "Peso normal"
	} else if imc < 30.0 {
		classificacao = "Sobrepeso"
	} else {
		classificacao = "Obesidade"
	}

	// 4. Saída
	fmt.Printf("Peso:   %.2f kg\n", peso)
	fmt.Printf("Altura: %.2f m\n", altura)
	fmt.Printf("IMC:    %.2f\n", imc)
	fmt.Printf("Classificação: %s\n", classificacao)
}

// Observações para o aluno:
// - Note que peso e altura são float64 — assim a divisão dá um float64
//   e não precisamos converter nada.
// - A ordem dos if/else importa: comparamos do menor para o maior, então
//   "imc < 25.0" já garante implicitamente que imc é >= 18.5 (porque o
//   primeiro if já tratou esse caso).
// - %.2f formata o número com 2 casas decimais. Bom para valores "humanos".
*/
