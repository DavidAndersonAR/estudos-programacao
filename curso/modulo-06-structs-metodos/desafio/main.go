package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 06 — Sistema Bancário Simples
//
// Objetivo:
// Modelar um pequeno sistema bancário usando structs e métodos.
//
// Requisitos:
// 1. Crie uma struct `ContaBancaria` com os campos:
//      - Titular     (string)
//      - NumeroConta (string)
//      - Saldo       (float64)
//
// 2. Implemente os seguintes MÉTODOS na ContaBancaria.
//    Pense bem: cada método precisa de receiver de valor ou de ponteiro?
//
//      - Depositar(valor float64) error
//          • Adiciona o valor ao saldo.
//          • Se o valor for <= 0, retorne erro.
//
//      - Sacar(valor float64) error
//          • Subtrai o valor do saldo.
//          • Se o valor for <= 0, retorne erro.
//          • Se o saldo for insuficiente, retorne erro
//            (não permitir saldo negativo).
//
//      - Transferir(destino *ContaBancaria, valor float64) error
//          • Faz um saque na conta atual e um depósito na conta destino.
//          • Se destino for nil, retorne erro.
//          • Se algo falhar no caminho, NÃO deixe a conta em estado inconsistente.
//
//      - Extrato()
//          • Imprime na tela:
//              - Titular
//              - Número da conta
//              - Saldo formatado com R$ e 2 casas decimais
//
// 3. No main, demonstre o sistema com 2 ou 3 contas:
//      - Crie as contas.
//      - Faça alguns depósitos e saques.
//      - Faça pelo menos uma transferência.
//      - Tente sacar mais do que tem (mostre o erro).
//      - Imprima o extrato final de todas as contas.
//
// 💡 Dicas:
// - Métodos que MODIFICAM o saldo precisam de receiver de PONTEIRO (*ContaBancaria).
//   Se você usar receiver de valor, os depósitos somem que nem mágica.
// - Para criar erros: `fmt.Errorf("mensagem: %v", coisa)`.
// - Para imprimir saldo bonito: `fmt.Printf("R$ %.2f\n", saldo)`.
// - Para "construir" uma conta, crie uma função `NovaConta(titular, numero string)`.
// - Em Transferir, chame os próprios métodos Sacar/Depositar — não duplique lógica.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente seu sistema bancário aqui.
	// Apague esta linha quando começar.
	fmt.Println("(implemente o sistema bancário aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// ContaBancaria representa uma conta corrente simples.
type ContaBancaria struct {
	Titular     string
	NumeroConta string
	Saldo       float64
}

// NovaConta é o "construtor" — convenção Go para criar structs prontas.
// Receber só os dados imutáveis (titular, número) e começar com saldo zero.
func NovaConta(titular, numero string) *ContaBancaria {
	return &ContaBancaria{
		Titular:     titular,
		NumeroConta: numero,
		Saldo:       0,
	}
}

// Depositar precisa de PONTEIRO porque vai alterar o Saldo.
func (c *ContaBancaria) Depositar(valor float64) error {
	if valor <= 0 {
		return fmt.Errorf("valor de depósito deve ser positivo (recebido: %.2f)", valor)
	}
	c.Saldo += valor
	return nil
}

// Sacar também é de ponteiro — modifica o saldo.
func (c *ContaBancaria) Sacar(valor float64) error {
	if valor <= 0 {
		return fmt.Errorf("valor de saque deve ser positivo (recebido: %.2f)", valor)
	}
	if valor > c.Saldo {
		return fmt.Errorf("saldo insuficiente: saldo=%.2f, saque=%.2f", c.Saldo, valor)
	}
	c.Saldo -= valor
	return nil
}

// Transferir reusa Sacar e Depositar — sem duplicar regras de validação.
// Se o Sacar falhar, nada acontece. Se o Depositar falhar (raro aqui),
// devolvemos o dinheiro pra não deixar a conta inconsistente.
func (c *ContaBancaria) Transferir(destino *ContaBancaria, valor float64) error {
	if destino == nil {
		return fmt.Errorf("conta destino não pode ser nil")
	}
	if destino == c {
		return fmt.Errorf("não dá pra transferir para a mesma conta")
	}
	if err := c.Sacar(valor); err != nil {
		return fmt.Errorf("falha no saque da transferência: %v", err)
	}
	if err := destino.Depositar(valor); err != nil {
		// Estorna pra não sumir dinheiro.
		c.Saldo += valor
		return fmt.Errorf("falha no depósito da transferência: %v", err)
	}
	return nil
}

// Extrato é só leitura — receiver de valor seria OK, mas mantemos
// *ContaBancaria por consistência com os outros métodos.
func (c *ContaBancaria) Extrato() {
	fmt.Println("---------------------------------")
	fmt.Printf("Titular:     %s\n", c.Titular)
	fmt.Printf("Conta:       %s\n", c.NumeroConta)
	fmt.Printf("Saldo:       R$ %.2f\n", c.Saldo)
	fmt.Println("---------------------------------")
}

func main() {
	// Cria três contas.
	ana := NovaConta("Ana Silva", "0001")
	bruno := NovaConta("Bruno Costa", "0002")
	carla := NovaConta("Carla Souza", "0003")

	// Movimentações iniciais.
	must(ana.Depositar(1000))
	must(bruno.Depositar(500))
	must(carla.Depositar(2000))

	// Saque normal.
	must(ana.Sacar(200))

	// Transferência: Carla -> Bruno.
	must(carla.Transferir(bruno, 800))

	// Tentativa de saque acima do saldo (deve falhar).
	if err := bruno.Sacar(99999); err != nil {
		fmt.Println("⚠️  Tentativa inválida:", err)
	}

	// Tentativa de depósito com valor negativo (deve falhar).
	if err := ana.Depositar(-50); err != nil {
		fmt.Println("⚠️  Tentativa inválida:", err)
	}

	// Extrato final.
	fmt.Println("\n=== EXTRATO FINAL ===")
	ana.Extrato()
	bruno.Extrato()
	carla.Extrato()
}

// must é um pequeno helper pra deixar o main limpo: se a operação
// deu erro de verdade (inesperado), exibe e segue.
func must(err error) {
	if err != nil {
		fmt.Println("erro inesperado:", err)
	}
}
*/
