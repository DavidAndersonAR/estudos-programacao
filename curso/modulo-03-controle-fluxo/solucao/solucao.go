package main

import (
	"fmt"
	"math/rand"
)


func main () {
	valor := rand.Intn(100) + 1
	tentativas := []int{17,21,33,47,55,69,78, 63,25,12,14,65,100,91,74,85,82,86,84}
	acertou := false
	for _, tentativa := range tentativas {
		if tentativa > valor {
			fmt.Println("A tentativa e maior que o valor", tentativa)
		}else if tentativa < valor {
			fmt.Println("A tentativa e menor que o valor", tentativa)
		} else {
			fmt.Println("A tentativa e igual ao valor", "Tentativa: ", tentativa, "Valor: ", valor)
			break
		}
	}

	for _, tentativa := range tentativas {
		switch {
		case tentativa > valor:
			fmt.Println("A sua tentativa foi maio que o valor: ", tentativa)
		case tentativa < valor:
			fmt.Println("A sua tentativa foi menor que o valor: ", tentativa)
		default:
			fmt.Println("Voce acertou, valor: ", valor, "Tentativa: ", tentativa)
			acertou = true	
		}
		if acertou == true {
			break
		}
		
	}
}