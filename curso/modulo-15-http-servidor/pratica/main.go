// Módulo 15 — HTTP Servidor
// Prática: um servidor com várias rotas mostrando os recursos básicos do net/http.
//
// Rode com `go run .` (ou `go run ./curso/modulo-15-http-servidor/pratica`)
// e abra http://localhost:8080 no navegador, ou use curl:
//
//   curl http://localhost:8080/
//   curl "http://localhost:8080/ola?nome=David"
//   curl http://localhost:8080/json
//   curl -X POST -d "ecoa isso aqui" http://localhost:8080/eco
//   curl -i http://localhost:8080/status

package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

// Rota 1: "/"  — texto simples na raiz.
// Mostra o uso mais básico do ResponseWriter como um io.Writer.
func raiz(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Bem-vindo ao servidor do Módulo 15!")
	fmt.Fprintln(w, "Rotas disponíveis:")
	fmt.Fprintln(w, "  /ola?nome=SEU_NOME   (GET)")
	fmt.Fprintln(w, "  /json                (GET)")
	fmt.Fprintln(w, "  /eco                 (POST)")
	fmt.Fprintln(w, "  /status              (GET)")
}

// Rota 2: "/ola?nome=X" — saudação personalizada por query param.
// Se "nome" não vier, usamos um valor padrão.
func ola(w http.ResponseWriter, r *http.Request) {
	nome := r.URL.Query().Get("nome")
	if nome == "" {
		nome = "visitante"
	}
	fmt.Fprintf(w, "Olá, %s! Que bom te ver por aqui.\n", nome)
}

// Rota 3: "/json" — devolve um JSON de exemplo.
// Definimos o Content-Type e usamos json.NewEncoder direto no writer.
func respostaJSON(w http.ResponseWriter, r *http.Request) {
	type Curso struct {
		Nome     string   `json:"nome"`
		Modulo   int      `json:"modulo"`
		Topicos  []string `json:"topicos"`
		Concluso bool     `json:"concluso"`
	}

	dados := Curso{
		Nome:    "Estudo Go",
		Modulo:  15,
		Topicos: []string{"net/http", "handlers", "query params", "JSON"},
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(dados); err != nil {
		// Se a codificação falhar, devolvemos 500.
		http.Error(w, "erro ao codificar JSON", http.StatusInternalServerError)
		return
	}
}

// Rota 4: "/eco" (POST) — lê o body e devolve de volta.
// Mostra como filtrar pelo método HTTP e ler r.Body.
func eco(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed) // 405
		fmt.Fprintln(w, "esta rota só aceita POST. Tente: curl -X POST -d 'oi' http://localhost:8080/eco")
		return
	}

	corpo, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "não consegui ler o body", http.StatusInternalServerError)
		return
	}
	defer r.Body.Close()

	if len(corpo) == 0 {
		fmt.Fprintln(w, "(body vazio — mande algum conteúdo com -d)")
		return
	}

	fmt.Fprintf(w, "Você mandou: %s\n", corpo)
}

// Rota 5: "/status" — devolve 200 explicitamente, com uma mensagem.
// Útil pra checagem de "está vivo?" (healthcheck).
func status(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK) // 200 (já é o padrão, mas explicitamos pra estudar)
	fmt.Fprintln(w, "OK — servidor de pé e respondendo.")
}

func main() {
	// Registra cada rota no roteador padrão.
	http.HandleFunc("/", raiz)
	http.HandleFunc("/ola", ola)
	http.HandleFunc("/json", respostaJSON)
	http.HandleFunc("/eco", eco)
	http.HandleFunc("/status", status)

	endereco := ":8080"
	fmt.Printf("Servidor rodando em http://localhost%s — aperte Ctrl+C para parar.\n", endereco)

	// log.Fatal exibe o erro e encerra se o servidor falhar ao subir
	// (por exemplo, se a porta já estiver em uso).
	log.Fatal(http.ListenAndServe(endereco, nil))
}
