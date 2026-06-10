// Módulo 14 — HTTP Cliente — Prática
//
// 6 exercícios RESOLVIDOS, do mais simples ao mais completo.
// Rode com:   go run ./curso/modulo-14-http-cliente/pratica
//
// Observação: todos usam APIs públicas reais (httpbin.org, jsonplaceholder.typicode.com, viacep.com.br).
// Se sua conexão estiver lenta, os timeouts podem disparar — é normal.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"
)

func main() {
	fmt.Println("=== Exercício 1: GET simples e status ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: Decodificar JSON em struct ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: GET com query parameters ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: http.Client com timeout ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: POST com JSON no body ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Tratar erro 404 ===")
	exercicio6()
}

// -----------------------------------------------------------------------------
// Exercício 1: GET simples a https://httpbin.org/get
// Imprima status e os primeiros 200 caracteres do body.
// -----------------------------------------------------------------------------
func exercicio1() {
	// http.Get faz uma requisição GET. Retorna *http.Response e error.
	resp, err := http.Get("https://httpbin.org/get")
	if err != nil {
		fmt.Println("erro de rede:", err)
		return
	}
	// SEMPRE feche o body — defer garante que isso aconteça mesmo se houver return.
	defer resp.Body.Close()

	// resp.Status é uma string ("200 OK"); resp.StatusCode é o int (200).
	fmt.Println("Status:", resp.Status)
	fmt.Println("StatusCode:", resp.StatusCode)

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("erro ao ler body:", err)
		return
	}

	// Mostra só um pedacinho pra não poluir a saída.
	preview := string(body)
	if len(preview) > 200 {
		preview = preview[:200] + "..."
	}
	fmt.Println("Body (preview):", preview)
}

// -----------------------------------------------------------------------------
// Exercício 2: Decodificar JSON em struct.
// A API jsonplaceholder devolve um post fake — vamos pegar o post 1.
// -----------------------------------------------------------------------------
type Post struct {
	UserID int    `json:"userId"`
	ID     int    `json:"id"`
	Title  string `json:"title"`
	Body   string `json:"body"`
}

func exercicio2() {
	resp, err := http.Get("https://jsonplaceholder.typicode.com/posts/1")
	if err != nil {
		fmt.Println("erro:", err)
		return
	}
	defer resp.Body.Close()

	var p Post
	// json.NewDecoder lê e decodifica direto do stream — mais econômico que
	// ReadAll + Unmarshal em respostas grandes.
	if err := json.NewDecoder(resp.Body).Decode(&p); err != nil {
		fmt.Println("erro ao decodificar JSON:", err)
		return
	}

	fmt.Printf("Post #%d (user %d)\n", p.ID, p.UserID)
	fmt.Println("Título:", p.Title)
	fmt.Println("Body  :", p.Body)
}

// -----------------------------------------------------------------------------
// Exercício 3: GET com query parameters.
// Mandamos ?nome=David&linguagem=Go pra https://httpbin.org/get e
// o httpbin devolve os args no JSON de resposta.
// -----------------------------------------------------------------------------
func exercicio3() {
	// Em vez de concatenar strings, use net/url — ele faz encoding correto.
	base, err := url.Parse("https://httpbin.org/get")
	if err != nil {
		fmt.Println("url inválida:", err)
		return
	}

	params := url.Values{}
	params.Add("nome", "David")
	params.Add("linguagem", "Go")
	base.RawQuery = params.Encode() // ex: nome=David&linguagem=Go

	fmt.Println("URL montada:", base.String())

	resp, err := http.Get(base.String())
	if err != nil {
		fmt.Println("erro:", err)
		return
	}
	defer resp.Body.Close()

	// A resposta do httpbin tem um campo "args" com o que mandamos.
	var data struct {
		Args map[string]string `json:"args"`
		URL  string            `json:"url"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		fmt.Println("erro ao decodificar:", err)
		return
	}

	fmt.Println("Args ecoados pelo servidor:", data.Args)
}

// -----------------------------------------------------------------------------
// Exercício 4: http.Client customizado com timeout.
// O DefaultClient NÃO tem timeout — em produção, sempre crie o seu.
// -----------------------------------------------------------------------------
func exercicio4() {
	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	// /delay/2 do httpbin demora 2s — passa no timeout.
	// Se trocar pra /delay/10 vai dar erro (context deadline exceeded).
	resp, err := client.Get("https://httpbin.org/delay/2")
	if err != nil {
		fmt.Println("erro (talvez timeout):", err)
		return
	}
	defer resp.Body.Close()

	fmt.Println("Status:", resp.Status)
	fmt.Println("Resposta veio dentro do timeout de 5s.")
}

// -----------------------------------------------------------------------------
// Exercício 5: POST com JSON no body.
// Mandamos um post novo pro jsonplaceholder (ele finge criar e devolve com ID).
// -----------------------------------------------------------------------------
func exercicio5() {
	novoPost := Post{
		UserID: 42,
		Title:  "Aprendendo Go",
		Body:   "Hoje aprendi sobre HTTP cliente em Go!",
	}

	// 1) Serializa a struct em JSON.
	corpo, err := json.Marshal(novoPost)
	if err != nil {
		fmt.Println("erro ao serializar:", err)
		return
	}

	// 2) Faz o POST. bytes.NewBuffer transforma []byte em io.Reader,
	//    que é o que http.Post exige no corpo.
	resp, err := http.Post(
		"https://jsonplaceholder.typicode.com/posts",
		"application/json", // Content-Type — informa o servidor que estamos mandando JSON
		bytes.NewBuffer(corpo),
	)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}
	defer resp.Body.Close()

	fmt.Println("Status:", resp.Status) // espera-se 201 Created

	// 3) Decodifica a resposta — a API devolve o post criado com um ID novo.
	var criado Post
	if err := json.NewDecoder(resp.Body).Decode(&criado); err != nil {
		fmt.Println("erro ao decodificar:", err)
		return
	}
	fmt.Printf("Post criado com ID %d, título %q\n", criado.ID, criado.Title)
}

// -----------------------------------------------------------------------------
// Exercício 6: Tratar erro 404.
// http.Get NÃO retorna erro em 404 — precisa checar o StatusCode na mão.
// -----------------------------------------------------------------------------
func exercicio6() {
	resp, err := http.Get("https://jsonplaceholder.typicode.com/posts/99999")
	if err != nil {
		// Erro AQUI seria de rede (DNS, sem internet…). 404 NÃO cai aqui.
		fmt.Println("erro de rede:", err)
		return
	}
	defer resp.Body.Close()

	// É aqui que detectamos o 404.
	switch {
	case resp.StatusCode == http.StatusNotFound:
		fmt.Println("Recurso não encontrado (404). Tudo certo com a rede, só não existe esse post.")
		return
	case resp.StatusCode >= 500:
		fmt.Println("Erro no servidor:", resp.Status)
		return
	case resp.StatusCode != http.StatusOK:
		fmt.Println("Resposta inesperada:", resp.Status)
		return
	}

	// Só chega aqui se for 200.
	var p Post
	_ = json.NewDecoder(resp.Body).Decode(&p)
	fmt.Println("Achou o post:", p.Title)
}
