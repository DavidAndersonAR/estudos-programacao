package main

import (
	"fmt"
	"strings"
)

// Exercícios avançados: Embedding (Composição)

// Exercício 1: Embedding básico de struct
type Animal struct {
	Nome  string
	Idade int
}

func (a Animal) Apresentar() string {
	return fmt.Sprintf("%s tem %d anos", a.Nome, a.Idade)
}

type Cachorro struct {
	Animal // embedded
	Raca   string
}

func exercicio1() {
	c := Cachorro{
		Animal: Animal{Nome: "Rex", Idade: 5},
		Raca:   "Labrador",
	}
	// Acesso direto (promoção)
	fmt.Println(c.Nome)         // promovido de Animal
	fmt.Println(c.Apresentar()) // método de Animal
	fmt.Println(c.Raca)         // próprio de Cachorro
}

// Exercício 2: Sobrescrita de método
type Veiculo struct {
	Modelo string
}

func (v Veiculo) Descrever() string {
	return "veículo: " + v.Modelo
}

type Carro struct {
	Veiculo
	Portas int
}

// Sobrescreve Descrever
func (c Carro) Descrever() string {
	return fmt.Sprintf("carro: %s com %d portas", c.Modelo, c.Portas)
}

func exercicio2() {
	c := Carro{Veiculo: Veiculo{Modelo: "Fusca"}, Portas: 2}
	fmt.Println(c.Descrever())          // versão de Carro
	fmt.Println(c.Veiculo.Descrever())  // versão original
}

// Exercício 3: Embedding com ponteiro
type Logger struct {
	Prefixo string
}

func (l *Logger) Log(msg string) {
	fmt.Printf("%s %s\n", l.Prefixo, msg)
}

type Servico struct {
	*Logger // embedded por ponteiro
	Nome    string
}

func exercicio3() {
	s := Servico{
		Logger: &Logger{Prefixo: "[SVC]"},
		Nome:   "auth",
	}
	s.Log("serviço iniciado") // método promovido
}

// Exercício 4: Embedding de interface em interface
type Reader interface {
	Read() string
}

type Writer interface {
	Write(s string)
}

// Combina as duas
type ReadWriter interface {
	Reader
	Writer
}

type Buffer struct {
	conteudo string
}

func (b *Buffer) Read() string {
	return b.conteudo
}

func (b *Buffer) Write(s string) {
	b.conteudo += s
}

func exercicio4() {
	var rw ReadWriter = &Buffer{}
	rw.Write("olá")
	rw.Write(" mundo")
	fmt.Println(rw.Read())
}

// Exercício 5: Embedding de interface em struct (delegation)
// Implementa "decorator" — adiciona comportamento sem reescrever tudo.
type Notificador interface {
	Notificar(msg string)
}

type EmailNotificador struct{}

func (e EmailNotificador) Notificar(msg string) {
	fmt.Println("email enviado:", msg)
}

// Decorator que adiciona timestamp
type NotificadorComTimestamp struct {
	Notificador // delega via interface embutida
}

func (n NotificadorComTimestamp) Notificar(msg string) {
	mensagemFormatada := "[12:00] " + msg
	n.Notificador.Notificar(mensagemFormatada)
}

func exercicio5() {
	base := EmailNotificador{}
	decorado := NotificadorComTimestamp{Notificador: base}
	decorado.Notificar("conta criada")
}

// Exercício 6: Pilha de funcionalidades com embedding
type Pessoa struct {
	Nome string
}

func (p Pessoa) DizerOla() string {
	return "Oi, sou " + p.Nome
}

type Funcionario struct {
	Pessoa
	Cargo string
}

func (f Funcionario) DescreverCargo() string {
	return strings.ToUpper(f.Cargo)
}

type Gerente struct {
	Funcionario
	Equipe []string
}

func (g Gerente) ListarEquipe() string {
	return "Equipe: " + strings.Join(g.Equipe, ", ")
}

func exercicio6() {
	g := Gerente{
		Funcionario: Funcionario{
			Pessoa: Pessoa{Nome: "Carlos"},
			Cargo:  "TI",
		},
		Equipe: []string{"Ana", "Bruno", "Diana"},
	}

	// Todos esses métodos vêm de níveis diferentes
	fmt.Println(g.DizerOla())        // Pessoa
	fmt.Println(g.DescreverCargo())  // Funcionario
	fmt.Println(g.ListarEquipe())    // Gerente
}

func main() {
	exercicio1()
	exercicio2()
	exercicio3()
	exercicio4()
	exercicio5()
	exercicio6()
}
