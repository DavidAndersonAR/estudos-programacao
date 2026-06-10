package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// 🎯 DESAFIO DO MÓDULO 15 — API de Saudação Multilíngue
//
// Objetivo:
// Construir uma pequena API HTTP que cumprimenta em vários idiomas.
//
// Rotas obrigatórias:
//
//   GET /saudar?nome=X&idioma=Y
//       Retorna JSON: {"saudacao": "Olá, X!"}
//       Idiomas suportados: pt, en, es
//       - pt -> "Olá, X!"
//       - en -> "Hello, X!"
//       - es -> "¡Hola, X!"
//       Regras:
//         * Se "nome" estiver vazio, use "visitante" como padrão.
//         * Se "idioma" estiver vazio, use "pt".
//         * Se "idioma" for desconhecido, devolva status 400 com um JSON
//           do tipo: {"erro": "idioma 'fr' não suportado"}
//
//   GET /idiomas
//       Retorna JSON listando os idiomas suportados, ex:
//       {"idiomas": ["pt", "en", "es"]}
//
// Requisitos:
// 1. Cada rota é uma função separada com a assinatura padrão de handler.
// 2. Defina o Content-Type como "application/json" nas duas rotas.
// 3. Use uma struct (ou map) para representar a resposta JSON.
// 4. Servidor sobe em :8080 com http.ListenAndServe.
//
// 💡 Dicas:
// - r.URL.Query().Get("chave") pega o query param (vem "" se não existir).
// - json.NewEncoder(w).Encode(dados) escreve direto no ResponseWriter.
// - w.WriteHeader(http.StatusBadRequest) antes de escrever o corpo do erro.
// - Para evitar repetição, monte um map[string]string traduzindo idioma -> "saudação template".
//
// 🧪 Testes manuais (com o servidor rodando):
//   curl "http://localhost:8080/saudar?nome=Ana&idioma=pt"
//   curl "http://localhost:8080/saudar?nome=Ana&idioma=en"
//   curl "http://localhost:8080/saudar?nome=Ana&idioma=es"
//   curl -i "http://localhost:8080/saudar?nome=Ana&idioma=fr"  # 400
//   curl "http://localhost:8080/idiomas"

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: registre as rotas /saudar e /idiomas e suba o servidor em :8080.
	fmt.Println("(implemente sua API aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// Mapa central: idioma -> template com %s para o nome.
// Manter num único lugar facilita adicionar novos idiomas depois.
var saudacoes = map[string]string{
	"pt": "Olá, %s!",
	"en": "Hello, %s!",
	"es": "¡Hola, %s!",
}

// Struct para a resposta bem-sucedida de /saudar.
type RespostaSaudacao struct {
	Saudacao string `json:"saudacao"`
}

// Struct para mensagens de erro em JSON.
type RespostaErro struct {
	Erro string `json:"erro"`
}

// Struct para a listagem de idiomas em /idiomas.
type RespostaIdiomas struct {
	Idiomas []string `json:"idiomas"`
}

// Handler de /saudar — lê query params, escolhe template, devolve JSON.
func handlerSaudar(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	nome := r.URL.Query().Get("nome")
	if nome == "" {
		nome = "visitante"
	}

	idioma := r.URL.Query().Get("idioma")
	if idioma == "" {
		idioma = "pt"
	}

	template, ok := saudacoes[idioma]
	if !ok {
		w.WriteHeader(http.StatusBadRequest) // 400
		json.NewEncoder(w).Encode(RespostaErro{
			Erro: fmt.Sprintf("idioma '%s' não suportado", idioma),
		})
		return
	}

	resp := RespostaSaudacao{
		Saudacao: fmt.Sprintf(template, nome),
	}
	json.NewEncoder(w).Encode(resp)
}

// Handler de /idiomas — devolve a lista de idiomas conhecidos.
func handlerIdiomas(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	lista := make([]string, 0, len(saudacoes))
	for k := range saudacoes {
		lista = append(lista, k)
	}

	json.NewEncoder(w).Encode(RespostaIdiomas{Idiomas: lista})
}

func main() {
	http.HandleFunc("/saudar", handlerSaudar)
	http.HandleFunc("/idiomas", handlerIdiomas)

	fmt.Println("API de Saudação no ar em http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
*/

// Stubs para o arquivo compilar enquanto a solução está comentada.
// Quando você descomentar a referência, apague estas linhas abaixo.
var _ = json.NewEncoder
var _ = http.HandleFunc
var _ = log.Fatal
