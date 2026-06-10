// Módulo 14 — HTTP Cliente — DESAFIO: Consultor de CEP
//
// =============================================================================
// ENUNCIADO
// =============================================================================
//
// Construa um "Consultor de CEP" usando a API pública ViaCEP.
//
// Endpoint:    https://viacep.com.br/ws/{cep}/json/
// Documentação: https://viacep.com.br/
//
// Requisitos:
//
//   1. Crie uma struct `Endereco` com (pelo menos) os campos:
//        - Logradouro
//        - Bairro
//        - Localidade  (cidade)
//        - UF          (estado)
//        - Cep
//      Use tags JSON corretas — a ViaCEP devolve as chaves em minúsculas.
//
//   2. Implemente:
//        func BuscarCEP(cep string) (Endereco, error)
//      Ela deve:
//        - Usar http.Client com timeout (não use o DefaultClient).
//        - Fazer GET na URL da ViaCEP.
//        - Tratar status code != 200.
//        - Tratar o caso de CEP inválido. A ViaCEP, quando o CEP não existe,
//          devolve status 200 mas com {"erro": "true"} (ou true) — sua função
//          precisa detectar isso e retornar erro.
//        - Decodificar a resposta em Endereco.
//
//   3. No main:
//        - Consulte 2 ou 3 CEPs reais (já tem uma lista abaixo).
//        - Consulte UM cep inválido pra mostrar o tratamento de erro.
//        - Imprima cada endereço bonito (uma linha por campo).
//
// Dicas:
//   - Sempre `defer resp.Body.Close()`.
//   - CEPs válidos pra testar: 01310100 (Av. Paulista), 20040020 (Centro RJ),
//     22071900 (Copacabana), 88010400 (Centro Florianópolis).
//   - Pra simular CEP inválido: "00000000".
//
// =============================================================================
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// =============================================================================
// SOLUÇÃO COMENTADA
// =============================================================================
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// Endereco espelha a resposta JSON da ViaCEP.
// As tags `json:"..."` casam com as chaves devolvidas pela API
// (logradouro, bairro, localidade, uf...).
type Endereco struct {
	Cep         string `json:"cep"`
	Logradouro  string `json:"logradouro"`
	Complemento string `json:"complemento"`
	Bairro      string `json:"bairro"`
	Localidade  string `json:"localidade"`
	UF          string `json:"uf"`

	// A ViaCEP devolve "erro": true quando o CEP não existe.
	// Como esse campo só aparece nesse caso, usamos um *bool ou string
	// pra detectar. Aqui usamos string e marcamos no Unmarshal.
	Erro string `json:"erro,omitempty"`
}

// httpClient compartilhado — uma única instância com timeout pro app inteiro.
// Em código real, geralmente fica como variável global ou injetado.
var httpClient = &http.Client{
	Timeout: 10 * time.Second,
}

// BuscarCEP consulta a API ViaCEP e devolve um Endereco.
// Retorna erro se:
//   - O CEP tem formato errado (não vamos validar a fundo, mas o servidor responde 400).
//   - A rede falhou ou estourou o timeout.
//   - O CEP não existe (ViaCEP devolve {"erro": true} com status 200).
//   - A resposta veio com status diferente de 200.
func BuscarCEP(cep string) (Endereco, error) {
	var end Endereco

	url := fmt.Sprintf("https://viacep.com.br/ws/%s/json/", cep)

	resp, err := httpClient.Get(url)
	if err != nil {
		// Erro de rede / DNS / timeout — note que 404 não cai aqui.
		return end, fmt.Errorf("falha de rede ao buscar CEP %s: %w", cep, err)
	}
	defer resp.Body.Close()

	// Quando o CEP tem formato inválido (ex: "abc"), a ViaCEP devolve 400.
	if resp.StatusCode != http.StatusOK {
		return end, fmt.Errorf("CEP %s: resposta inesperada %s", cep, resp.Status)
	}

	// Decodifica direto do stream — limpo e sem ler tudo na memória primeiro.
	if err := json.NewDecoder(resp.Body).Decode(&end); err != nil {
		return end, fmt.Errorf("CEP %s: falha ao decodificar JSON: %w", cep, err)
	}

	// CEP que não existe: status 200, mas body é {"erro": "true"} (ou true).
	// Nossa tag pega isso como string "true".
	if end.Erro == "true" {
		return Endereco{}, fmt.Errorf("CEP %s não encontrado", cep)
	}

	return end, nil
}

// imprimirEndereco mostra o endereço formatado em um bloco bonitinho.
func imprimirEndereco(e Endereco) {
	fmt.Println("┌─────────────────────────────────────────")
	fmt.Printf("│ CEP        : %s\n", e.Cep)
	fmt.Printf("│ Logradouro : %s\n", e.Logradouro)
	if e.Complemento != "" {
		fmt.Printf("│ Complemento: %s\n", e.Complemento)
	}
	fmt.Printf("│ Bairro     : %s\n", e.Bairro)
	fmt.Printf("│ Cidade     : %s\n", e.Localidade)
	fmt.Printf("│ UF         : %s\n", e.UF)
	fmt.Println("└─────────────────────────────────────────")
}

func main() {
	// Lista de CEPs reais (alguns famosos) + um inválido pra testar o erro.
	ceps := []string{
		"01310100", // Av. Paulista, São Paulo
		"20040020", // Centro, Rio de Janeiro
		"88010400", // Centro, Florianópolis
		"00000000", // inválido — vai cair no fluxo de erro
	}

	fmt.Println("=== Consultor de CEP (ViaCEP) ===")

	for _, cep := range ceps {
		fmt.Printf("\nConsultando CEP %s...\n", cep)

		end, err := BuscarCEP(cep)
		if err != nil {
			// Erro tratado de forma amigável — o programa NÃO quebra,
			// só pula pro próximo CEP.
			fmt.Println("  ✗", err)
			continue
		}

		imprimirEndereco(end)
	}

	fmt.Println("\nFim das consultas.")
}
