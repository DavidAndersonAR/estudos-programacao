package main

import "fmt"

// 🎯 DESAFIO DO MÓDULO 08 — Validador de Cadastro
//
// Objetivo:
// Crie um sistema que valide um cadastro de usuário e devolva erros
// CLAROS e ESTRUTURADOS para cada campo problemático.
//
// Estrutura base:
//
//   type Usuario struct {
//       Nome  string
//       Email string
//       Idade int
//       Senha string
//   }
//
// Regras de validação:
//   - Nome  : não pode ser vazio
//   - Email : precisa conter o caractere '@'
//   - Idade : precisa ser >= 18
//   - Senha : precisa ter no mínimo 8 caracteres
//
// Crie a função:
//   func Validar(u Usuario) error
//
// Requisitos:
// 1. Crie um tipo próprio de erro (ex.: `ErroValidacao`) com `Campo` e `Mensagem`,
//    e dê a ele um método `Error() string`.
// 2. OU crie erros sentinela (`ErrNomeVazio`, `ErrEmailSemArroba`, etc.) e
//    embrulhe-os com `fmt.Errorf("... %w", ...)` para adicionar contexto.
// 3. Demonstre no `main` com pelo menos 2 cadastros válidos e 3 inválidos
//    (cada um falhando em um campo diferente).
// 4. Mostre como usar `errors.Is` ou `errors.As` para identificar o erro.
//
// 💡 Dicas:
// - `strings.Contains(email, "@")` ajuda no email.
// - `len(senha) >= 8` para a senha.
// - Pare na primeira falha OU acumule várias (sua escolha — a solução de
//   referência para na primeira; tente acumular se quiser desafio extra).
// - Lembre: o método Error() costuma ser definido sobre PONTEIRO (`*ErroValidacao`).

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

type Usuario struct {
	Nome  string
	Email string
	Idade int
	Senha string
}

// TODO: defina ErroValidacao (ou erros sentinela).

// TODO: implemente Validar.
func Validar(u Usuario) error {
	// Apague isto e implemente sua lógica.
	return nil
}

func main() {
	// TODO: crie alguns Usuario, chame Validar e mostre os resultados.
	u := Usuario{Nome: "", Email: "sem-arroba", Idade: 15, Senha: "123"}
	if err := Validar(u); err != nil {
		fmt.Println("erro:", err)
		return
	}
	fmt.Println("cadastro ok!")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
package main

import (
	"errors"
	"fmt"
	"strings"
)

// Tipo próprio de erro: carrega CAMPO e MENSAGEM, não só texto.
type ErroValidacao struct {
	Campo    string
	Mensagem string
}

func (e *ErroValidacao) Error() string {
	return fmt.Sprintf("validação falhou em %q: %s", e.Campo, e.Mensagem)
}

// Erros sentinela: úteis quando quem chama precisa REAGIR a um caso específico
// (por ex., na UI mostrar "senha muito curta" diferente de "idade inválida").
var (
	ErrNomeVazio       = errors.New("nome vazio")
	ErrEmailInvalido   = errors.New("email sem '@'")
	ErrMenorDeIdade    = errors.New("menor de 18 anos")
	ErrSenhaCurta      = errors.New("senha com menos de 8 caracteres")
)

type Usuario struct {
	Nome  string
	Email string
	Idade int
	Senha string
}

// Validar para na primeira falha encontrada.
// O ErroValidacao "embrulha" o erro sentinela com %w, dando o melhor dos dois mundos:
//   - quem quer mensagem amigável usa err.Error()
//   - quem quer reagir a um caso específico usa errors.Is
//   - quem quer o campo problemático usa errors.As para extrair *ErroValidacao
func Validar(u Usuario) error {
	if u.Nome == "" {
		return &ErroValidacao{Campo: "Nome", Mensagem: ErrNomeVazio.Error()}
	}
	if !strings.Contains(u.Email, "@") {
		// fmt.Errorf com %w: embrulha o sentinela mantendo-o detectável por errors.Is.
		return fmt.Errorf("campo %q: %w", "Email", ErrEmailInvalido)
	}
	if u.Idade < 18 {
		return fmt.Errorf("campo %q: %w (idade=%d)", "Idade", ErrMenorDeIdade, u.Idade)
	}
	if len(u.Senha) < 8 {
		return fmt.Errorf("campo %q: %w (tem %d, mínimo 8)", "Senha", ErrSenhaCurta, len(u.Senha))
	}
	return nil
}

func descreverErro(err error) {
	// Mensagem geral.
	fmt.Println("  erro:", err)

	// Caso 1: extrair tipo próprio (ErroValidacao) para pegar o Campo.
	var ev *ErroValidacao
	if errors.As(err, &ev) {
		fmt.Printf("    → tipo ErroValidacao | campo=%q\n", ev.Campo)
	}

	// Caso 2: identificar erros sentinela específicos.
	switch {
	case errors.Is(err, ErrNomeVazio):
		fmt.Println("    → causa: nome em branco")
	case errors.Is(err, ErrEmailInvalido):
		fmt.Println("    → causa: email mal formado")
	case errors.Is(err, ErrMenorDeIdade):
		fmt.Println("    → causa: precisa ser maior de 18")
	case errors.Is(err, ErrSenhaCurta):
		fmt.Println("    → causa: senha precisa ter 8+ caracteres")
	}
}

func main() {
	cadastros := []Usuario{
		// VÁLIDOS
		{Nome: "Ana Silva", Email: "ana@exemplo.com", Idade: 30, Senha: "supersegura"},
		{Nome: "Bruno Costa", Email: "bruno@empresa.io", Idade: 19, Senha: "12345678"},

		// INVÁLIDOS (cada um falhando em um campo diferente)
		{Nome: "", Email: "vazio@x.com", Idade: 25, Senha: "qualquercoisa"},        // nome vazio
		{Nome: "Carla", Email: "email-sem-arroba", Idade: 40, Senha: "longasenha"}, // email
		{Nome: "Davi", Email: "davi@x.com", Idade: 16, Senha: "longasenha"},        // idade
		{Nome: "Eva", Email: "eva@x.com", Idade: 22, Senha: "curta"},               // senha
	}

	for i, u := range cadastros {
		fmt.Printf("\n[%d] %+v\n", i+1, u)
		err := Validar(u)
		if err == nil {
			fmt.Println("  cadastro válido ✔")
			continue
		}
		descreverErro(err)
	}
}
*/
