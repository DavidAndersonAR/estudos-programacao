package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 01 — Cartão de Visitas
//
// Objetivo:
// Crie um programa que imprima um "cartão de visitas" formatado com:
//   - Seu nome
//   - Sua profissão
//   - Email
//   - Cidade
//   - Uma frase favorita
//
// O resultado deve ficar bonito, tipo:
//
//   +-------------------------------+
//   | David Anderson                |
//   | Programador em formação       |
//   | david@email.com               |
//   | São Paulo / SP                |
//   +-------------------------------+
//   | "Comece. O resto vem."        |
//   +-------------------------------+
//
// Requisitos:
// 1. Use pelo menos 3 funções diferentes do pacote fmt (Println, Print, Printf).
// 2. Use uma variável para cada dado.
// 3. Brinque com a formatação — alinhamento, separadores, etc.
//
// 💡 Dicas:
// - %s formata strings.
// - %-20s alinha à esquerda em 20 caracteres (útil pra "+ texto +").
// - Println pode mostrar string crua ou variável.
// - Strings com crases `...` aceitam quebra de linha real.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente seu cartão aqui.
	// Apague esta linha e construa o seu.
	fmt.Println("(escreva seu cartão de visitas aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
func main() {
	nome := "David Anderson"
	profissao := "Programador em formação"
	email := "david@email.com"
	cidade := "São Paulo"
	estado := "SP"
	frase := "Comece. O resto vem."

	linha := "+-------------------------------+"

	fmt.Println(linha)
	fmt.Printf("| %-30s|\n", nome)
	fmt.Printf("| %-30s|\n", profissao)
	fmt.Printf("| %-30s|\n", email)
	fmt.Printf("| %s / %s%s|\n", cidade, estado, espacos(30-len(cidade)-len(estado)-3))
	fmt.Println(linha)
	fmt.Printf("| %-30s|\n", `"`+frase+`"`)
	fmt.Println(linha)
}

// função auxiliar para preencher com espaços
func espacos(n int) string {
	s := ""
	for i := 0; i < n; i++ {
		s += " "
	}
	return s
}
*/
