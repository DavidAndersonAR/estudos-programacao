package main

// Servidor HTTP simples pra demonstrar multi-stage build.
// Sem dependências externas — Go puro, fica fácil compilar estático.

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
)

func main() {
	porta := os.Getenv("PORTA")
	if porta == "" {
		porta = "8080"
	}

	// Rota raiz: mensagem simples.
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Olá do servidor Go rodando em container!\n")
		fmt.Fprintf(w, "Imagem multi-stage de ~12MB — sem toolchain Go dentro.\n")
	})

	// Rota /info: mostra versão Go e SO (do binário, não do container).
	http.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Go version: %s\n", runtime.Version())
		fmt.Fprintf(w, "GOOS/GOARCH: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	})

	// Health check (útil pro Módulo 17).
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "ok")
	})

	log.Printf("Servidor escutando na porta %s", porta)
	if err := http.ListenAndServe(":"+porta, nil); err != nil {
		log.Fatal(err)
	}
}
