package main

import "fmt"

// Em Go, um bloco e basicamente um pedaço de código entre chaves { e }. Dentro de um bloco a gente pode
// declarar variáveis, escrever comandos e organizar a lógica do programa.

// Além dos blocos que a gente escreve com chaves, o Go tem alguns blocos invisíveis (chamados implícitos) que
// existem mesmo sem aparecer no código. Eles ajudam o compilador a saber o que esta visível em cada programa.

// 1. O que é um bloco
// Um bloco e uma sequência de declarações e comandos delimitada por chaves. Toda variável declarada
// num bloco so vive ali dentro, quando o bloco termina ela some.

// Um bloco simples entre chaves
// {
//	 mensagem := "Ola"
//	 fmt.Println(mensagem)
// } Aqui o bloco acaba e "mensagem deixa de existir"
//Tentar usa mensagem aqui fora daria erro de compilacao

// 2. Blocos explicitos com chaves
// Sao os blocos que a gente ve no codigo: tudo que esta dentro de { ... }. Aparecem no corpo de funcoes,
// dentro de if, for, switch e atr soltos no meio do codigo.

func exemplo1() {
	//Este e o bloco da funcao

	if true {
		// Este e outro bloco, dentro do if
		x := 10
		fmt.Println(x)
	}

	// Da pra criar um bloco solto so para organizar
	{
		temporario := "so vive aqui"
		fmt.Println(temporario)
	}
	// temporario não existe mais aqui
}

// 3. Bloco universo
// E o bloco mais externo do Go, que envolve todo o codigo de qualquer programa. Nele moram os nomes
// pre-definidos pela linguagem, como int, string, true, false, nil. len, make, append etc. Por isso que
// a gente pode usar esses nomes em qualquer lugar sem importar nada


// Tudo isso vem do bloco universo - ja existe pronto

// var n int = 10
// ok := true
// tamanho := len("texto")
// lista := make([]int, 3)

// 4. Bloco de pacote
// Cada pacote tem o seu próprio bloco, que envolve todos os arquivos daquele pacote

// arquivo: usuario.go

// package app
// Esta variável está no bloco do pacote app
// var versão = "1.0"
//func MostrarVersao() {
//	fmt.Println(versao)
//}

// Arquivo main.go (mesmo pacote de app)
// package app
func iniciar() {
	//Da pra usar "versao" aqui sem problemas,
	//porque esta no mesmo bloco de pacote
	//fmt.Println(versao)
}


// 5. Bloco de arquivo
// Cada arquivo .go tem o seu proprio bloco tambem. Ele serve principalmente para os imports: o que voce
// importa num arquivo so vale para aquele arquivo, não para o pacote inteiro

// Arquivo: a.go

//package app
//import "fmt" 	este fmt so vale neste arquivo
//func ola() {
//	fmt.Println("oi")
//}

// Arquivo: b.go

//package app

// Se eu não importar "fmt" aqui, não consigo usar fmt neste arquivo,
// mesmo que o arquivo a.go já tenha importado

//import "fmt"
//func tchau() {
//	fmt.Println("Ate logo")
//}


// 6. Bloco de funcao
// toda funcao tem o seu proprio bloco, que comeca em { e termina em }. Os parametos da funcao
// tambem fazem parte desse bloco, entao eles existem do comeco ao fim da funcao

func saudar(nome string) {
	// Aqui dentro estamos no bloco da funcao "saudar"
	// O parametro "nome" vive neste bloco

	mensagem := "Ola, " + nome
	fmt.Println(mensagem)
} // bloco da funcao termina aqui; "nome" e "mensagem" somem



// 7. Blocos implicitos de if, for e switch
// Cada if, for e switch cria um bloco invisivel que envolve a condicao/inicializacao. Isso e importante
// porque variaveis delaradas alo na abertura do comando so existem dentro daquele if/for/switch

// No if da pra declarar uma variavel antes da condicao
// Essa variavel so vive dentro do if/else

if idade := 18; idade >= 18 {
	fmt.Println("Maior de idade")
} else {
	fmt.Println("Menos de idade", idade) // ainda da pra usar aqui
}
// Aqui fora idade nao existe mais

// No for tambem tem um bloco implicito que segura o "i"
for i := 0; i < 3; i++ {
	fmt.Println(i)
}
//i nao existe mais aqui

// No switch a variavel declarada dentro dele so vale nele
switch dia := "segunda"; dia {
case "sabado", "domingo":
	fmt.Println("Fim de semana")
default:
	fmt.Println("Dia util: ", dia)
}

// 8. Blocos implicitos no case e select
// Cada case de um switch e cada case de um select tambem e um bloco invisivel.
// Ou seja o que voce declara dentro de um case do vale naquele case

switch nota := 8; {
case nota >= 7:
	status := aprovado "aprovado"	//so existe neste case
	fmt.Println(status)
case nota >= 5:
	status := "recuperacao"		//outro status, outro bloco
	fmt.Println(status)
default:
	fmt.Println("reprovado")
}

// Exemplo com select (usado em canais)
select {
case msg := <-canal1:
	//msg so existe nesse case
	fmt.Println("veio do canal1", msg)
case msg := <-canal2:
	fmt.Println("veio do canal2", msg)
}


















































