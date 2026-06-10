package main

import "testing"

// 🎯 DESAFIO DO MÓDULO 17 — escreva os testes!
//
// Estão aqui 3 esqueletos de teste, um para cada função do main.go.
// Sua missão:
//   1. Preencher a "tabela" de casos (slice de struct).
//   2. Escrever o corpo do laço comparando got vs esperado.
//   3. Usar t.Run para criar sub-tests com nome.
//   4. Lembrar de testar casos felizes E casos de erro.
//
// 💡 Dicas:
// - Use t.Errorf para reportar a falha com a mensagem informativa.
// - Para funções que retornam erro, teste os dois caminhos (com e sem erro).
// - Quanto mais casos diferentes, melhor — pense em "casos esquisitos".
//
// Quando terminar, rode:
//   go test ./curso/modulo-17-testes/desafio -v
//   go test ./curso/modulo-17-testes/desafio -cover
//
// E confira no fim deste arquivo a SOLUÇÃO DE REFERÊNCIA.

// ============================
// ESQUELETO 1 — TestValidarEmail
// ============================
func TestValidarEmail(t *testing.T) {
	casos := []struct {
		nome     string
		email    string
		esperado bool
	}{
		// TODO: preencha pelo menos 5 casos. Sugestões:
		// - email comum
		// - sem @
		// - com dois @
		// - sem ponto no domínio
		// - string vazia
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			// TODO: chame ValidarEmail e compare com c.esperado.
			_ = c
		})
	}
}

// ============================
// ESQUELETO 2 — TestCalcularDesconto
// ============================
func TestCalcularDesconto(t *testing.T) {
	// TODO: implementar.
	// Cuidado: a função retorna (float64, error).
	// Lembre-se de testar:
	//   - cada cupom válido (DEZ, VINTE, METADE)
	//   - cupom vazio
	//   - cupom inválido (deve dar erro)
	//   - preço negativo (deve dar erro)
}

// ============================
// ESQUELETO 3 — TestClassificarIdade
// ============================
func TestClassificarIdade(t *testing.T) {
	// TODO: implementar.
	// Cubra as fronteiras: 0, 12, 13, 17, 18, 59, 60, e um número negativo.
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
func TestValidarEmail(t *testing.T) {
	casos := []struct {
		nome     string
		email    string
		esperado bool
	}{
		{"email válido simples", "david@email.com", true},
		{"email com subdomínio", "david@mail.empresa.com", true},
		{"sem arroba", "davidemail.com", false},
		{"dois arrobas", "david@@email.com", false},
		{"sem ponto no domínio", "david@emailcom", false},
		{"string vazia", "", false},
		{"só arroba", "@", false},
		{"começa com ponto", ".david@email.com", false},
		{"termina com ponto", "david@email.com.", false},
		{"usuário vazio", "@email.com", false},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := ValidarEmail(c.email)
			if got != c.esperado {
				t.Errorf("ValidarEmail(%q) = %v; esperado %v", c.email, got, c.esperado)
			}
		})
	}
}

func TestCalcularDesconto(t *testing.T) {
	t.Run("cupom DEZ aplica 10%", func(t *testing.T) {
		got, err := CalcularDesconto(100, "DEZ")
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 90 {
			t.Errorf("CalcularDesconto(100, DEZ) = %v; esperado 90", got)
		}
	})

	t.Run("cupom VINTE aplica 20%", func(t *testing.T) {
		got, err := CalcularDesconto(100, "VINTE")
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 80 {
			t.Errorf("CalcularDesconto(100, VINTE) = %v; esperado 80", got)
		}
	})

	t.Run("cupom METADE aplica 50%", func(t *testing.T) {
		got, err := CalcularDesconto(200, "METADE")
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 100 {
			t.Errorf("CalcularDesconto(200, METADE) = %v; esperado 100", got)
		}
	})

	t.Run("cupom vazio mantém preço", func(t *testing.T) {
		got, err := CalcularDesconto(50, "")
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 50 {
			t.Errorf("CalcularDesconto(50, \"\") = %v; esperado 50", got)
		}
	})

	t.Run("cupom desconhecido dá erro", func(t *testing.T) {
		_, err := CalcularDesconto(100, "XPTO")
		if err == nil {
			t.Errorf("cupom inválido deveria ter retornado erro")
		}
	})

	t.Run("preço negativo dá erro", func(t *testing.T) {
		_, err := CalcularDesconto(-10, "DEZ")
		if err == nil {
			t.Errorf("preço negativo deveria ter retornado erro")
		}
	})
}

func TestClassificarIdade(t *testing.T) {
	casos := []struct {
		nome     string
		idade    int
		esperado string
	}{
		{"bebê", 0, "criança"},
		{"criança no limite superior", 12, "criança"},
		{"adolescente no limite inferior", 13, "adolescente"},
		{"adolescente no limite superior", 17, "adolescente"},
		{"adulto jovem", 18, "adulto"},
		{"adulto", 35, "adulto"},
		{"adulto no limite", 59, "adulto"},
		{"idoso no limite", 60, "idoso"},
		{"idoso", 80, "idoso"},
		{"negativo", -5, "idade inválida"},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := ClassificarIdade(c.idade)
			if got != c.esperado {
				t.Errorf("ClassificarIdade(%d) = %q; esperado %q", c.idade, got, c.esperado)
			}
		})
	}
}
*/
