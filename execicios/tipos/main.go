package main

import (
	"fmt"
)

// Tipo em Go
func main() {
	//1. Booleano (bool)
	//Guarda apenas verdadeiro ou falso
	//Forma 1: declarar e depois atribuir
	var ativo bool
	ativo = false
	//Forma 2: declara e ja atribuir
	var logado = false
	//Forma 3: forma curta e mais usada
	aprovado := false
	//Usando em condições
	if aprovado {
		fmt.Println("Passou")
		fmt.Println(ativo, logado)
	}

	//2. Numeros
	//São divididos em 3 familias: inteiros, numeros sem virgula(1, 2, -5). Existem versoes com sinais(aceitam negativos
	//int8, int16, int32, int64) e sem sinal (so positivos: uint8, uint16...)

	//Inteiros
	var idade int = 30
	quantidade := 30       //GO entende que é int
	var pequeno int8 = 127 //Ocupa menos memoria
	var positivo uint = 50 //So aceita numeros >=0

	//Decimais
	var preco float64 = 19.90
	desconto := 0.15

	//byte e rune
	var letra byte = 'a' //guarda o cod 65
	// var emoji rune = '' //guarda o cod unicode

	//Conversao entre tipos numericos(precisa ser explicita)
	var a int = 10
	var b float64 = float64(a)
	if idade == quantidade {
		fmt.Println(pequeno, positivo, preco, desconto, letra, b)
	}

	// 3. Texto
	// criando string
	var nome string = "David"
	saudacao := "Ola, Mundo!"

	// juntar (concatenar) textos
	mensagem := saudacao + " " + nome
	fmt.Println(mensagem)

	// pegar tamanho
	tamanho := len(nome)
	fmt.Println(tamanho)

	// Acessar um caractere pela posicao (retorna um byte)
	primeira := nome[0]
	fmt.Println(primeira)

	// String de varias linhas (com crases)
	texto := `Linha 1
		Linha 2
		Linha 3
		`
	fmt.Println(texto)

	//4.Array
	//Uma caixa com tamanho fixo que guarda varios valores do mesmo tipo. Exemplo: [5]int e uma caixacom exatamente 5 numeros inteiros

	//Declarar array vazio (cada posicao comeca em zero)
	var numeros [5]int

	// Atribuir valores
	numeros[0] = 10
	numeros[1] = 20

	// Criar ja com valores
	notas := [3]float64{8.5, 9.0, 7.5}

	//Deixar o Go contar o tamanho com "..."
	dias := [...]string{"Seg", "Ter", "Qua", "Qui", "Sex"}
	fmt.Println(dias)

	//Acessar valores e tamanho
	primeira = uint8(notas[0])
	total := len(notas)
	fmt.Println(total, primeira)

	//##################################################
	//5.Slice
	//'e como um array, mas flexivel, pode crescer e diminuir. 'E o jeito mais usado de guardar listas em Go
	//Forma 1: criar vazio
	var lista []int

	//Forma 2: ja com valores
	frutas := []string{"maca", "banana", "uva"}

	//Forma 3: usando make, define tamanho inicial
	zeros := make([]int, 5)      //[0,0,0,0,0]
	buffer := make([]int, 3, 10) // tamanho 3, capacidade 10

	//Adicionar elementos (append retorna um novo slice)
	frutas = append(frutas, "laranja")
	lista = append(lista, 1, 2, 3)

	//Fatiar (pegar um pedaco)
	parte := frutas[1:3] // pega do indice 1 ao 2

	//Remover um item (juntando dois pedacos)
	frutas = append(frutas[:1], frutas[2:]...)

	//#########################################################
	//6.Struct
	//Um agrupador de campos com nomes diferentes. Serve para representar uma coisa do mundo real. Exemplo:
	//uma Pessoa com nome e idade. E parecido com o que outras linguagens chaman de objeto ou registro
	//Definindo o tipo
	type Pessoa struct {
		Nome  string
		Idade int
		Email string
	}
	//Criando uma pessoa
	var p1 Pessoa
	p1.Nome = "Ana"
	p1.Idade = 25

	//Criando ja com valores, por nome dos campos-recomendado
	p2 := Pessoa{
		Nome:  "Carlos",
		Idade: 30,
		Email: "carlos@email.com",
	}
	p3 := Pessoa{"Maria", 28, "maria@email.com"}

	//Acessando campos
	fmt.Println(p2.Nome)

	//struct dentro de struct
	type Empresa struct {
		Nome string
		Dono Pessoa
	}

	//#########################################################
	//7. Ponteiro
	//Em vez de guardar um valor, guarda o endereco onde o valor esta na memoria. Util quando voce quer que uma funcao altere um valor original
	//Criar uma variavel normal
	idade := 25

	//Criar um ponteiro para essa variavel (& = "endereco de")
	var ponteiro *int = &idade

	// Ler o valor que o ponteiro aponta (* = "valor em")
	fmt.Println(ponteiro)

	// Mudar o valor original usando o ponteiro
	*ponteiro = 30
	fmt.Println(idade) //30

	// Criar um ponteiro de zero com new
	p := new(int)
	*p = 100

	// Usando em funcao para modificar o original

}
func incrementar(num *int) {
	*num++

}
var x int = 5
incrementar(&x)
fmt.Println(x)



//8. Funcao
//Em go, funcao tambem e um tipo de valor
//Funcao simples
func somar(a int, b int) int {
	return a + b
}

//Funcao com varios retornos
func dividir(a, b float64) (float64, error) {
	if b == 0 {
		return 0, fmt.Errorf("divisao por zero")
	}
	return a / b, nil
}

//Guardar funcao em variavel
var operacao = func(x, y int) int {
	return x * y
}
var resultado = operacao(3,4) //12

//Funcao que recebe outra funcao
func aplicar(valores []int, fn func(int) int) []int {
	resultado := []int{}
	for _, v := range valores {
		resultado = append(resultado, fn(v))
	}
	return resultado
}

var dobrar = func(n int) int {return n * 2}
var dobrados = aplicar([]int{1,2,3}, dobrar) //[2,4,6]

//9. Interfaces
// Define um contrato, uma lista de coisas que um tipo precisa saber fazer

//Definindo uma interface
type Animal interface {
	Falar() string
}

//Criando tipos que cumprem o contrato
type Cachorro struct {
	Nome string
}

func (c Cachorro) Falar() string {
	return "Au au!!"
}

// Usando a interface, aceita qualquer um que tenha o metodo Falar
func apresentar(a Animal) {
	fmt.Println(a.Falar())
}

apresentar(Cachorro{Nome:"Rex"}) //Au au


//10 . Map
// Uma estrutura de chave e valor, como um dicionario

// Forma 1: criar com make
var idades = make(map[string]int)
idades["Ana"] = 25
idades["Carlos"] = 30

//Forma 2: criar ja com valores
var precos = map[string]float64{
	"cafe":5.50,
	"pao":1.20,
	"leite":4.90,
}

//Ler um valor
var preco = precos["cafe"]

// Verificar se a chave existe
var valor, existe = precos["chocolate"]
if existe {
	fmt.Println("Preco: ", valor)
} else {
	fmt.Println("Nao encontrado")
}

//  Remover uma chave
delete(precos, "leite")

//Percorrer todos os itens
for chave, valor := range precos {
	fmt.println(chave, " = ", valor)
}

// Tamanho
total := len(precos)



























