package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// Módulo 16 — JSON e Persistência
// Prática: brincando com encoding/json e gravando em arquivos temporários.

// Exercício 1: Struct → JSON com Marshal
// Marshal pega um valor Go e retorna um []byte com o JSON correspondente.
// Só campos EXPORTADOS (Maiúscula) entram no JSON.
func exercicio1() {
	type Pessoa struct {
		Nome  string
		Idade int
		Ativo bool
	}

	p := Pessoa{Nome: "Ana", Idade: 28, Ativo: true}

	dados, err := json.Marshal(p)
	if err != nil {
		fmt.Println("erro:", err)
		return
	}

	// dados é []byte — convertemos pra string pra imprimir bonitinho
	fmt.Println("JSON cru:", string(dados))
	// Saída: {"Nome":"Ana","Idade":28,"Ativo":true}
}

// Exercício 2: JSON → Struct com Unmarshal
// Unmarshal faz o caminho contrário: recebe []byte e preenche a struct.
// CUIDADO: precisa passar PONTEIRO (&p), porque Unmarshal escreve dentro da variável.
func exercicio2() {
	type Pessoa struct {
		Nome  string
		Idade int
	}

	// JSON vindo "de fora" — pode ser de um arquivo, API, etc.
	textoJSON := []byte(`{"Nome":"Beto","Idade":35}`)

	var p Pessoa
	err := json.Unmarshal(textoJSON, &p) // <- repare no &
	if err != nil {
		fmt.Println("erro:", err)
		return
	}

	fmt.Printf("Decodificado: nome=%q, idade=%d\n", p.Nome, p.Idade)

	// JSON com campo extra é OK — Go ignora o que não existe na struct
	textoExtra := []byte(`{"Nome":"Cris","Idade":40,"Cidade":"SP"}`)
	var p2 Pessoa
	json.Unmarshal(textoExtra, &p2)
	fmt.Printf("Com campo extra: nome=%q, idade=%d (Cidade foi ignorada)\n", p2.Nome, p2.Idade)
}

// Exercício 3: MarshalIndent — JSON formatado para humanos lerem
// Igual Marshal, mas com indentação. Bom pra arquivos de configuração e logs.
func exercicio3() {
	type Livro struct {
		Titulo string
		Autor  string
		Ano    int
	}

	livros := []Livro{
		{Titulo: "O Hobbit", Autor: "Tolkien", Ano: 1937},
		{Titulo: "Duna", Autor: "Herbert", Ano: 1965},
	}

	// "" = sem prefixo no início de cada linha
	// "  " = 2 espaços por nível de indentação
	dados, _ := json.MarshalIndent(livros, "", "  ")
	fmt.Println(string(dados))
}

// Exercício 4: Struct tags — controlando os nomes no JSON
// Sem tag, o nome no JSON é igual ao nome do campo (com Maiúscula).
// Com tag `json:"..."`, você escolhe o nome.
// Com `,omitempty`, o campo SOME do JSON quando estiver no valor zero.
// Com `json:"-"`, o campo NUNCA vai pro JSON.
func exercicio4() {
	type Usuario struct {
		ID      int    `json:"id"`
		Nome    string `json:"nome_completo"`
		Apelido string `json:"apelido,omitempty"` // some se vazio
		Email   string `json:"email"`
		Senha   string `json:"-"` // nunca aparece no JSON
	}

	// Caso 1: usuário com todos os campos preenchidos
	u1 := Usuario{
		ID:      1,
		Nome:    "Ana Silva",
		Apelido: "Aninha",
		Email:   "ana@x.com",
		Senha:   "supersecreta", // NÃO vai aparecer
	}
	dados, _ := json.MarshalIndent(u1, "", "  ")
	fmt.Println("Com apelido:")
	fmt.Println(string(dados))

	// Caso 2: usuário sem apelido — repare que o campo SOME
	u2 := Usuario{
		ID:    2,
		Nome:  "Beto",
		Email: "beto@x.com",
	}
	dados, _ = json.MarshalIndent(u2, "", "  ")
	fmt.Println("\nSem apelido (omitempty):")
	fmt.Println(string(dados))
}

// Exercício 5: Salvar struct em arquivo JSON e carregar de volta
// O combo clássico: Marshal + os.WriteFile pra salvar; os.ReadFile + Unmarshal pra carregar.
// Usamos os.TempDir() pra não sujar o projeto.
func exercicio5() {
	type Config struct {
		Tema    string `json:"tema"`
		Idioma  string `json:"idioma"`
		Volume  int    `json:"volume"`
	}

	// Caminho num diretório temporário do sistema
	caminho := filepath.Join(os.TempDir(), "minha-config.json")
	fmt.Println("Arquivo:", caminho)

	// --- SALVANDO ---
	original := Config{Tema: "escuro", Idioma: "pt-BR", Volume: 70}

	dados, err := json.MarshalIndent(original, "", "  ")
	if err != nil {
		fmt.Println("erro ao serializar:", err)
		return
	}

	err = os.WriteFile(caminho, dados, 0644)
	if err != nil {
		fmt.Println("erro ao gravar:", err)
		return
	}
	fmt.Println("Salvo com sucesso!")

	// --- CARREGANDO ---
	conteudo, err := os.ReadFile(caminho)
	if err != nil {
		fmt.Println("erro ao ler:", err)
		return
	}

	var recuperada Config
	if err := json.Unmarshal(conteudo, &recuperada); err != nil {
		fmt.Println("erro ao desserializar:", err)
		return
	}

	fmt.Printf("Carregado: %+v\n", recuperada)

	// Limpeza (boa prática em scripts curtos)
	os.Remove(caminho)
}

// Exercício 6: Campos opcionais com ponteiros
// Como diferenciar "veio com valor zero" de "não veio"?
// Resposta: use PONTEIRO. nil = não veio, &valor = veio (mesmo que seja zero).
func exercicio6() {
	type Pedido struct {
		Item     string `json:"item"`
		Quantidade int  `json:"quantidade"`
		// Desconto é OPCIONAL — usamos *int pra saber se veio
		Desconto *int `json:"desconto,omitempty"`
	}

	// Caso A: JSON SEM o campo "desconto"
	jsonA := []byte(`{"item":"café","quantidade":2}`)
	var pa Pedido
	json.Unmarshal(jsonA, &pa)
	fmt.Printf("Pedido A: %+v\n", pa)
	if pa.Desconto == nil {
		fmt.Println("  -> sem desconto informado (usar padrão)")
	}

	// Caso B: JSON COM "desconto": 0 — tem desconto, mas é zero
	jsonB := []byte(`{"item":"chá","quantidade":1,"desconto":0}`)
	var pb Pedido
	json.Unmarshal(jsonB, &pb)
	fmt.Printf("\nPedido B: item=%s, qtd=%d\n", pb.Item, pb.Quantidade)
	if pb.Desconto != nil {
		fmt.Printf("  -> desconto informado: %d%%\n", *pb.Desconto)
	}

	// Caso C: JSON COM "desconto": 15
	jsonC := []byte(`{"item":"bolo","quantidade":1,"desconto":15}`)
	var pc Pedido
	json.Unmarshal(jsonC, &pc)
	fmt.Printf("\nPedido C: item=%s, qtd=%d\n", pc.Item, pc.Quantidade)
	if pc.Desconto != nil {
		fmt.Printf("  -> desconto informado: %d%%\n", *pc.Desconto)
	}
}

func main() {
	fmt.Println("=== Exercício 1: Struct -> JSON (Marshal) ===")
	exercicio1()

	fmt.Println("\n=== Exercício 2: JSON -> Struct (Unmarshal) ===")
	exercicio2()

	fmt.Println("\n=== Exercício 3: MarshalIndent (JSON bonitinho) ===")
	exercicio3()

	fmt.Println("\n=== Exercício 4: Struct tags (json:\"...\", omitempty, -) ===")
	exercicio4()

	fmt.Println("\n=== Exercício 5: Salvar e carregar de arquivo ===")
	exercicio5()

	fmt.Println("\n=== Exercício 6: Campos opcionais com ponteiros ===")
	exercicio6()
}
