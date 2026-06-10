package main

import "testing"

// Módulo 17 — Testes
// Aqui estão os testes RESOLVIDOS para as funções do main.go.
// Estude cada padrão: table-driven, t.Run para sub-tests, mensagens informativas.

// ============================
// TestSomar — table-driven básico
// ============================
func TestSomar(t *testing.T) {
	casos := []struct {
		nome     string
		a, b     int
		esperado int
	}{
		{"dois positivos", 2, 3, 5},
		{"positivo com negativo", 10, -3, 7},
		{"dois negativos", -4, -6, -10},
		{"com zero", 0, 7, 7},
		{"ambos zero", 0, 0, 0},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := Somar(c.a, c.b)
			if got != c.esperado {
				t.Errorf("Somar(%d, %d) = %d; esperado %d", c.a, c.b, got, c.esperado)
			}
		})
	}
}

// ============================
// TestSubtrair
// ============================
func TestSubtrair(t *testing.T) {
	casos := []struct {
		nome     string
		a, b     int
		esperado int
	}{
		{"resultado positivo", 10, 4, 6},
		{"resultado negativo", 3, 8, -5},
		{"resultado zero", 5, 5, 0},
		{"subtrair zero", 9, 0, 9},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := Subtrair(c.a, c.b)
			if got != c.esperado {
				t.Errorf("Subtrair(%d, %d) = %d; esperado %d", c.a, c.b, got, c.esperado)
			}
		})
	}
}

// ============================
// TestMultiplicar
// ============================
func TestMultiplicar(t *testing.T) {
	casos := []struct {
		nome     string
		a, b     int
		esperado int
	}{
		{"dois positivos", 6, 7, 42},
		{"com zero", 99, 0, 0},
		{"com um", 5, 1, 5},
		{"sinais opostos", -3, 4, -12},
		{"dois negativos", -3, -4, 12},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := Multiplicar(c.a, c.b)
			if got != c.esperado {
				t.Errorf("Multiplicar(%d, %d) = %d; esperado %d", c.a, c.b, got, c.esperado)
			}
		})
	}
}

// ============================
// TestDividir — função com erro: testa os dois caminhos
// ============================
func TestDividir(t *testing.T) {
	t.Run("divisão exata", func(t *testing.T) {
		got, err := Dividir(10, 2)
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 5 {
			t.Errorf("Dividir(10, 2) = %v; esperado 5", got)
		}
	})

	t.Run("divisão com decimal", func(t *testing.T) {
		got, err := Dividir(7, 2)
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 3.5 {
			t.Errorf("Dividir(7, 2) = %v; esperado 3.5", got)
		}
	})

	t.Run("divisão por zero deve dar erro", func(t *testing.T) {
		_, err := Dividir(10, 0)
		if err == nil {
			t.Errorf("Dividir(10, 0) deveria ter retornado erro, mas retornou nil")
		}
	})

	t.Run("zero dividido por número", func(t *testing.T) {
		got, err := Dividir(0, 5)
		if err != nil {
			t.Fatalf("não esperava erro, recebi %v", err)
		}
		if got != 0 {
			t.Errorf("Dividir(0, 5) = %v; esperado 0", got)
		}
	})
}

// ============================
// TestEhPar
// ============================
func TestEhPar(t *testing.T) {
	casos := []struct {
		nome     string
		n        int
		esperado bool
	}{
		{"dois é par", 2, true},
		{"três é ímpar", 3, false},
		{"zero é par", 0, true},
		{"negativo par", -4, true},
		{"negativo ímpar", -7, false},
		{"cem é par", 100, true},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := EhPar(c.n)
			if got != c.esperado {
				t.Errorf("EhPar(%d) = %v; esperado %v", c.n, got, c.esperado)
			}
		})
	}
}

// ============================
// TestReverter — inclui caso com acento (UTF-8)
// ============================
func TestReverter(t *testing.T) {
	casos := []struct {
		nome     string
		entrada  string
		esperado string
	}{
		{"palavra simples", "abc", "cba"},
		{"frase com espaço", "ola mundo", "odnum alo"},
		{"string vazia", "", ""},
		{"um caractere só", "a", "a"},
		{"com acento", "café", "éfac"},
		{"palíndromo", "ovo", "ovo"},
	}

	for _, c := range casos {
		t.Run(c.nome, func(t *testing.T) {
			got := Reverter(c.entrada)
			if got != c.esperado {
				t.Errorf("Reverter(%q) = %q; esperado %q", c.entrada, got, c.esperado)
			}
		})
	}
}

// ============================
// BenchmarkSomar — medindo performance
// ============================
// Rode com:  go test -bench=.
// O Go ajusta b.N automaticamente até medir um tempo confiável.
func BenchmarkSomar(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Somar(123, 456)
	}
}
