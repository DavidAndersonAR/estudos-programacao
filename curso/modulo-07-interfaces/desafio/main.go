package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 07 — Sistema de Notificações Multi-canal
//
// Contexto:
// Uma aplicação precisa avisar usuários por VÁRIOS canais
// (email, SMS, push). Cada canal tem seu próprio jeito de enviar,
// mas do ponto de vista de quem manda a notificação, todos
// deveriam funcionar do mesmo jeito: "envie essa mensagem".
//
// Esse é O caso clássico de uso de interface.
//
// Objetivo:
// 1) Defina a interface Notificador com o método:
//        Enviar(mensagem string) error
//
// 2) Crie 3 tipos que implementem essa interface:
//        - EmailNotificador  (tem campo Destinatario string)
//        - SMSNotificador    (tem campo Numero string)
//        - PushNotificador   (tem campo DeviceID string)
//
//    Cada Enviar pode só imprimir algo tipo:
//      "[EMAIL para alice@x.com] Olá!"
//      "[SMS para +5511...] Olá!"
//      "[PUSH para device-XYZ] Olá!"
//    e devolver nil.
//
// 3) Escreva a função:
//        notificarTodos(canais []Notificador, msg string)
//    que percorre o slice e dispara em todos os canais. Se algum
//    Enviar devolver erro, mostre na tela mas NÃO pare os outros.
//
// 4) No main(), monte um slice de Notificador com pelo menos um
//    de cada tipo e chame notificarTodos.
//
// 💡 Dicas:
// - A grande sacada é: a função notificarTodos NÃO precisa saber
//   se é email, sms ou push. Ela só conhece o contrato.
// - Para criar um "erro qualquer" rapidinho, dá pra usar:
//       errors.New("mensagem")
//   ou:  fmt.Errorf("falhou em %s", canal)
// - Lembre: implementar interface em Go é IMPLÍCITO — basta ter
//   os métodos certos, não precisa escrever "implements".
// - Bônus (opcional): faça um dos Enviar falhar de propósito
//   (ex.: se mensagem for vazia) e veja notificarTodos seguindo
//   adiante mesmo assim.
// - Bônus 2 (opcional): adicione um SlackNotificador depois e
//   note que NADA na função notificarTodos precisa mudar. Esse
//   é o poder da abstração via interface.
//
// Resultado esperado (algo nessa linha):
//   --- Disparando notificação ---
//   [EMAIL para alice@email.com] Bem-vindo ao sistema!
//   [SMS para +5511999990000] Bem-vindo ao sistema!
//   [PUSH para device-ABC123] Bem-vindo ao sistema!
//   --- Fim ---

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

// TODO 1: declare a interface Notificador

// TODO 2: declare EmailNotificador, SMSNotificador, PushNotificador
//         e o método Enviar de cada um.

// TODO 3: declare notificarTodos(canais []Notificador, msg string)

func main() {
	// TODO 4: monte o slice e chame notificarTodos aqui.
	fmt.Println("(implemente o desafio do módulo 07)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
import (
	"errors"
	"fmt"
)

// 1) O contrato. Pequenininho, do jeito Go: um método só.
type Notificador interface {
	Enviar(mensagem string) error
}

// 2) Implementações. Cada uma tem os campos que faz sentido pra ela.

type EmailNotificador struct {
	Destinatario string
}

func (e EmailNotificador) Enviar(mensagem string) error {
	if mensagem == "" {
		return errors.New("email: mensagem vazia")
	}
	fmt.Printf("[EMAIL para %s] %s\n", e.Destinatario, mensagem)
	return nil
}

type SMSNotificador struct {
	Numero string
}

func (s SMSNotificador) Enviar(mensagem string) error {
	if s.Numero == "" {
		return errors.New("sms: número não informado")
	}
	fmt.Printf("[SMS para %s] %s\n", s.Numero, mensagem)
	return nil
}

type PushNotificador struct {
	DeviceID string
}

func (p PushNotificador) Enviar(mensagem string) error {
	fmt.Printf("[PUSH para %s] %s\n", p.DeviceID, mensagem)
	return nil
}

// 3) A função que NÃO sabe (e não precisa saber) o tipo concreto.
//    Ela só confia no contrato Notificador.
func notificarTodos(canais []Notificador, msg string) {
	for _, c := range canais {
		if err := c.Enviar(msg); err != nil {
			// erro num canal não derruba os outros
			fmt.Printf("  ! falha em um canal: %s\n", err)
		}
	}
}

func main() {
	canais := []Notificador{
		EmailNotificador{Destinatario: "alice@email.com"},
		SMSNotificador{Numero: "+5511999990000"},
		PushNotificador{DeviceID: "device-ABC123"},
	}

	fmt.Println("--- Disparando notificação ---")
	notificarTodos(canais, "Bem-vindo ao sistema!")
	fmt.Println("--- Fim ---")

	// Demonstração do "um falha, os outros seguem":
	fmt.Println("\n--- Mensagem vazia (email vai falhar) ---")
	notificarTodos(canais, "")
	fmt.Println("--- Fim ---")

	// Bônus: adicionar um novo canal NÃO exige mudar notificarTodos.
	// type SlackNotificador struct { Canal string }
	// func (s SlackNotificador) Enviar(m string) error { ... }
	// canais = append(canais, SlackNotificador{Canal: "#geral"})
}
*/
