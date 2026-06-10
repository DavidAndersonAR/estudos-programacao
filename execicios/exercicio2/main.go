package main

import "fmt"

// Na prática: exercício #2
// Use var para declarar três variáveis. Elas devem ter package-level scope. Não atribua valores a estas variáveis. Utilize os seguintes identificadores e tipos para estas variáveis:
// 		Identificador "x" deverá ter tipo int
// 		Identificador "y" deverá ter tipo string
// 		Identificador "z" deverá ter tipo bool
// Na função main:
// 		Demonstre os valores de cada identificador
// 		O compilador atribuiu valores para essas variáveis. Como esses valores se chamam?
// Solução: https://play.golang.org/p/pAFd-F7uGZ



var x int
var y string
var z bool


func main() {
	fmt.Println(x)
	fmt.Println(y)
	fmt.Println(z)
}