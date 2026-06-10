package main

import (
	"errors"
	"fmt"
)

// Módulo 08 — Tratamento de Erros
// Prática: 6 exercícios resolvidos sobre erros como valores em Go.

// ============================================================
// Exercício 1: Divisão com erro de divisão por zero
// Convenção: o erro é o ÚLTIMO valor retornado.
// ============================================================
func dividir(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("divisão por zero")
	}
	return a / b, nil
}

func exercicio1() {
	resultado, err := dividir(10, 2)
	if err != nil {
		fmt.Println("erro:", err)
	} else {
		fmt.Println("10 / 2 =", resultado)
	}

	// Caso de erro: dividir por zero
	resultado, err = dividir(10, 0)
	if err != nil {
		fmt.Println("erro:", err)
	} else {
		fmt.Println("10 / 0 =", resultado)
	}
}

// ============================================================
// Exercício 2: Função que retorna múltiplos erros possíveis
// Use erros "sentinela" para que quem chama possa diferenciar.
// ============================================================
var (
	ErrSaldoInsuficiente = errors.New("saldo insuficiente")
	ErrValorInvalido     = errors.New("valor inválido")
)

func sacar(saldo, valor float64) (float64, error) {
	if valor <= 0 {
		return saldo, ErrValorInvalido
	}
	if valor > saldo {
		return saldo, ErrSaldoInsuficiente
	}
	return saldo - valor, nil
}

func exercicio2() {
	casos := []struct {
		saldo, valor float64
	}{
		{100, 30},  // ok
		{100, -5},  // valor inválido
		{100, 200}, // saldo insuficiente
	}

	for _, c := range casos {
		novo, err := sacar(c.saldo, c.valor)
		if err != nil {
			fmt.Printf("saldo %.2f, sacar %.2f → erro: %v\n", c.saldo, c.valor, err)
			continue
		}
		fmt.Printf("saldo %.2f, sacar %.2f → novo saldo: %.2f\n", c.saldo, c.valor, novo)
	}
}

// ============================================================
// Exercício 3: errors.New vs fmt.Errorf
// errors.New = mensagem fixa.
// fmt.Errorf = mensagem com dados formatados.
// ============================================================
func buscar(id int) error {
	// errors.New — mensagem fixa
	if id < 0 {
		return errors.New("id não pode ser negativo")
	}
	// fmt.Errorf — mensagem com dados dinâmicos
	if id > 1000 {
		return fmt.Errorf("id %d acima do máximo permitido (1000)", id)
	}
	return nil
}

func exercicio3() {
	for _, id := range []int{42, -1, 9999} {
		err := buscar(id)
		if err == nil {
			fmt.Printf("id %d ok\n", id)
			continue
		}
		fmt.Printf("id %d → %v\n", id, err)
	}
}

// ============================================================
// Exercício 4: Tipo próprio de erro — ErroValidacao
// Struct com método Error() vira um error.
// Carrega DADOS, não só mensagem.
// ============================================================
type ErroValidacao struct {
	Campo    string
	Mensagem string
}

func (e *ErroValidacao) Error() string {
	return fmt.Sprintf("validação no campo %q: %s", e.Campo, e.Mensagem)
}

func validarNome(nome string) error {
	if nome == "" {
		return &ErroValidacao{Campo: "nome", Mensagem: "não pode ser vazio"}
	}
	return nil
}

func exercicio4() {
	err := validarNome("")
	if err == nil {
		fmt.Println("nome ok")
		return
	}
	fmt.Println("mensagem:", err)

	// Extrair os dados do erro com errors.As
	var ev *ErroValidacao
	if errors.As(err, &ev) {
		fmt.Println("  campo problemático:", ev.Campo)
		fmt.Println("  detalhe          :", ev.Mensagem)
	}
}

// ============================================================
// Exercício 5: Wrap com %w e verificação com errors.Is
// %w embrulha o erro mantendo o original acessível.
// ============================================================
var ErrUsuarioNaoEncontrado = errors.New("usuário não encontrado")

func buscarNoBanco(id int) error {
	// Simula um banco que não achou o usuário
	return ErrUsuarioNaoEncontrado
}

func carregarPerfil(id int) error {
	if err := buscarNoBanco(id); err != nil {
		// Adicionamos contexto SEM perder o erro original
		return fmt.Errorf("carregar perfil do id %d: %w", id, err)
	}
	return nil
}

func exercicio5() {
	err := carregarPerfil(7)
	fmt.Println("erro completo:", err)

	// Comparar com == NÃO funciona em erro embrulhado.
	// Sempre use errors.Is:
	if errors.Is(err, ErrUsuarioNaoEncontrado) {
		fmt.Println("  → identificado como 'usuário não encontrado'")
	}
}

// ============================================================
// Exercício 6: panic e recover (uso DEFENSIVO, não fluxo normal)
// recover() só funciona DENTRO de um defer.
// ============================================================
func acessarIndice(lista []int, i int) int {
	// Se i estiver fora, o Go entra em panic sozinho.
	return lista[i]
}

func executarComSeguranca(lista []int, i int) (resultado int, err error) {
	// O defer roda mesmo se houver panic.
	defer func() {
		if r := recover(); r != nil {
			// Convertemos o panic em error — bem mais civilizado.
			err = fmt.Errorf("recuperado de panic: %v", r)
		}
	}()

	resultado = acessarIndice(lista, i)
	return resultado, nil
}

func exercicio6() {
	lista := []int{10, 20, 30}

	// Caso normal
	v, err := executarComSeguranca(lista, 1)
	if err != nil {
		fmt.Println("erro:", err)
	} else {
		fmt.Println("lista[1] =", v)
	}

	// Caso que causaria panic — agora vira erro tranquilo
	v, err = executarComSeguranca(lista, 99)
	if err != nil {
		fmt.Println("erro:", err)
	} else {
		fmt.Println("lista[99] =", v)
	}
}

// ============================================================
// main — roda todos os exercícios
// ============================================================
func main() {
	fmt.Println("=== Exercício 1: Divisão com erro ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Múltiplos erros possíveis ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: errors.New vs fmt.Errorf ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Tipo próprio (ErroValidacao) ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Wrap com %w e errors.Is ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: panic e recover ===")
	exercicio6()
}
