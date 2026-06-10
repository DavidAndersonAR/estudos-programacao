package main

import (
	"fmt"
	"strings"
)

// 🎯 DESAFIO DO MÓDULO 17 — Testando uma Calculadora (e mais)
//
// Objetivo:
// Você recebeu 3 funções já implementadas neste arquivo:
//   1. ValidarEmail(email string) bool
//   2. CalcularDesconto(preco float64, cupom string) (float64, error)
//   3. ClassificarIdade(idade int) string
//
// Sua missão: escrever os TESTES dessas funções no arquivo main_test.go.
// O esqueleto já está pronto, é só preencher os casos e o corpo do teste.
//
// Regras das funções (LEIA antes de testar — é o "contrato"):
//
// === ValidarEmail ===
// Retorna true se o email for "válido". Para este exercício, válido significa:
//   - Tem exatamente um "@".
//   - Tem pelo menos um "." DEPOIS do "@".
//   - Não começa nem termina com "@" ou ".".
//   - Não é string vazia.
//
// === CalcularDesconto ===
// Aplica um cupom sobre o preço:
//   - "DEZ"     -> 10% de desconto
//   - "VINTE"   -> 20% de desconto
//   - "METADE"  -> 50% de desconto
//   - cupom vazio "" -> sem desconto (devolve o preço original)
//   - qualquer outro cupom -> erro "cupom inválido"
//   - preço negativo -> erro "preço inválido"
//
// === ClassificarIdade ===
//   -  0 a 12  -> "criança"
//   - 13 a 17  -> "adolescente"
//   - 18 a 59  -> "adulto"
//   - 60+      -> "idoso"
//   - negativo -> "idade inválida"

// ============================
// CÓDIGO PRONTO — NÃO PRECISA MEXER
// ============================

func ValidarEmail(email string) bool {
	if email == "" {
		return false
	}
	if strings.Count(email, "@") != 1 {
		return false
	}
	partes := strings.Split(email, "@")
	usuario, dominio := partes[0], partes[1]
	if usuario == "" || dominio == "" {
		return false
	}
	if !strings.Contains(dominio, ".") {
		return false
	}
	if strings.HasPrefix(email, ".") || strings.HasSuffix(email, ".") {
		return false
	}
	return true
}

func CalcularDesconto(preco float64, cupom string) (float64, error) {
	if preco < 0 {
		return 0, fmt.Errorf("preço inválido")
	}
	switch cupom {
	case "":
		return preco, nil
	case "DEZ":
		return preco * 0.9, nil
	case "VINTE":
		return preco * 0.8, nil
	case "METADE":
		return preco * 0.5, nil
	default:
		return 0, fmt.Errorf("cupom inválido")
	}
}

func ClassificarIdade(idade int) string {
	switch {
	case idade < 0:
		return "idade inválida"
	case idade <= 12:
		return "criança"
	case idade <= 17:
		return "adolescente"
	case idade <= 59:
		return "adulto"
	default:
		return "idoso"
	}
}

func main() {
	// Demonstração rápida — o foco do desafio é o arquivo main_test.go.
	fmt.Println("ValidarEmail(\"david@email.com\") =", ValidarEmail("david@email.com"))
	fmt.Println("ValidarEmail(\"sem-arroba\")      =", ValidarEmail("sem-arroba"))

	preco, _ := CalcularDesconto(100, "VINTE")
	fmt.Println("CalcularDesconto(100, \"VINTE\") =", preco)

	fmt.Println("ClassificarIdade(15) =", ClassificarIdade(15))

	fmt.Println("\nAgora abra main_test.go e implemente os testes!")
	fmt.Println("Depois rode: go test ./curso/modulo-17-testes/desafio -v")
}
