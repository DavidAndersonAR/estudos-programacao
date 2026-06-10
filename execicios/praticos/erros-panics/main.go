package main

import (
	"errors"
	"fmt"
)

// Exercícios práticos: Erros e Panics

// Exercício 1: Função que retorna erro
// Convenção: erro é o ÚLTIMO valor retornado.
func dividir(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("divisão por zero não permitida")
	}
	return a / b, nil
}

func exercicio1() {
	resultado, err := dividir(10, 2)
	if err != nil {
		fmt.Println("Erro:", err)
	} else {
		fmt.Println("Resultado:", resultado)
	}

	// Caso de erro
	_, err = dividir(10, 0)
	if err != nil {
		fmt.Println("Erro:", err)
	}
}

// Exercício 2: Tratamento com if err != nil
func buscarUsuario(id int) (string, error) {
	usuarios := map[int]string{1: "Ana", 2: "Bruno"}
	nome, existe := usuarios[id]
	if !existe {
		return "", fmt.Errorf("usuário %d não encontrado", id)
	}
	return nome, nil
}

func exercicio2() {
	for _, id := range []int{1, 2, 99} {
		nome, err := buscarUsuario(id)
		if err != nil {
			fmt.Println("Falha:", err)
			continue
		}
		fmt.Println("Encontrado:", nome)
	}
}

// Exercício 3: Criar erro com errors.New (mensagem simples)
var ErrSaldoInsuficiente = errors.New("saldo insuficiente")

func sacar(saldo, valor float64) (float64, error) {
	if valor > saldo {
		return saldo, ErrSaldoInsuficiente
	}
	return saldo - valor, nil
}

func exercicio3() {
	novoSaldo, err := sacar(100, 150)
	if err != nil {
		fmt.Println("Não pôde sacar:", err)
	}
	fmt.Println("Saldo:", novoSaldo)
}

// Exercício 4: fmt.Errorf com %w (embrulhar erro)
func processarPedido(id int) error {
	_, err := buscarUsuario(id)
	if err != nil {
		// %w "embrulha" o erro original — mantém o erro de baixo
		return fmt.Errorf("falha ao processar pedido %d: %w", id, err)
	}
	return nil
}

func exercicio4() {
	err := processarPedido(99)
	fmt.Println(err)
}

// Exercício 5: Tipo próprio de erro (struct implementa interface error)
type ErroValidacao struct {
	Campo    string
	Mensagem string
}

// Implementa a interface error
func (e *ErroValidacao) Error() string {
	return fmt.Sprintf("validação: campo '%s' — %s", e.Campo, e.Mensagem)
}

func validarIdade(idade int) error {
	if idade < 0 {
		return &ErroValidacao{Campo: "idade", Mensagem: "não pode ser negativa"}
	}
	return nil
}

func exercicio5() {
	err := validarIdade(-5)
	if err != nil {
		fmt.Println(err)
	}
}

// Exercício 6: recover dentro de defer para evitar crash por panic
func arriscado() {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Capturei o panic:", r)
		}
	}()

	var lista []int
	_ = lista[10] // vai gerar panic: index out of range
	fmt.Println("Esta linha nunca executa")
}

func exercicio6() {
	arriscado()
	fmt.Println("Programa continua normalmente após recover")
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	exercicio6()
}
