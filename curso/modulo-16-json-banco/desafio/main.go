package main

import (
	"fmt"
	// Os imports abaixo serão necessários quando você implementar a solução.
	// Descomente conforme for usando:
	// "encoding/json"
	// "os"
	// "path/filepath"
)

// 🎯 DESAFIO DO MÓDULO 16 — CRUD de Tarefas com Persistência em JSON
//
// Objetivo:
// Construir um pequeno gerenciador de tarefas que salva o estado num arquivo JSON.
// Toda operação (criar, marcar como feita, remover) atualiza o arquivo no disco —
// se você fechar o programa e abrir de novo, as tarefas continuam lá.
//
// A struct base:
//
//   type Tarefa struct {
//       ID     int    `json:"id"`
//       Titulo string `json:"titulo"`
//       Feita  bool   `json:"feita"`
//   }
//
// Funções que você precisa implementar:
//
//   - Adicionar(t Tarefa)  -> acrescenta uma tarefa nova e salva
//   - Listar() []Tarefa    -> devolve todas as tarefas (lê do arquivo)
//   - Marcar(id int)       -> marca uma tarefa como Feita = true e salva
//   - Remover(id int)      -> tira a tarefa do slice e salva
//
// Roteiro de demonstração (no main):
//   1. Adicionar 3 tarefas
//   2. Listar (todas com Feita=false)
//   3. Marcar uma como feita
//   4. Remover outra
//   5. Listar de novo (pra ver o estado final)
//
// 💡 Dicas:
// - Persistir = ler/gravar um arquivo .json em os.TempDir().
// - Antes de adicionar, leia o arquivo, modifique o slice, e grave de novo.
// - Use json.MarshalIndent pra o arquivo ficar legível (ajuda no debug).
// - Se o arquivo ainda não existe, trate como "lista vazia".
// - Pra remover, faça um slice novo: append(s[:i], s[i+1:]...)
//
// Requisitos:
// 1. O caminho do arquivo deve estar numa constante/variável só (fácil de mudar).
// 2. Cada operação que modifica deve SALVAR o estado.
// 3. Listar sempre deve LER o arquivo (nunca cachear em variável global).
// 4. Trate erros — pelo menos imprima o que deu errado.

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

func main() {
	// TODO: implemente as funções Adicionar, Listar, Marcar, Remover
	//       e demonstre o fluxo aqui dentro.
	fmt.Println("(implemente seu CRUD de tarefas aqui)")
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// Tarefa é o "item" do nosso CRUD.
// As tags json controlam como ela aparece dentro do arquivo.
type Tarefa struct {
	ID     int    `json:"id"`
	Titulo string `json:"titulo"`
	Feita  bool   `json:"feita"`
}

// arquivoTarefas é onde vamos persistir tudo. Usamos TempDir pra não
// sujar a pasta do projeto durante o desenvolvimento.
var arquivoTarefas = filepath.Join(os.TempDir(), "tarefas.json")

// carregar lê o arquivo e devolve o slice de tarefas.
// Se o arquivo NÃO existe ainda, devolve slice vazio sem erro —
// é o caso da "primeira execução".
func carregar() ([]Tarefa, error) {
	dados, err := os.ReadFile(arquivoTarefas)
	if err != nil {
		if os.IsNotExist(err) {
			return []Tarefa{}, nil // primeira vez — lista vazia
		}
		return nil, err
	}

	var tarefas []Tarefa
	if err := json.Unmarshal(dados, &tarefas); err != nil {
		return nil, err
	}
	return tarefas, nil
}

// salvar grava o slice no arquivo, em JSON indentado (mais legível).
func salvar(tarefas []Tarefa) error {
	dados, err := json.MarshalIndent(tarefas, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(arquivoTarefas, dados, 0644)
}

// Adicionar lê o estado atual, acrescenta a nova tarefa e salva.
func Adicionar(t Tarefa) error {
	tarefas, err := carregar()
	if err != nil {
		return err
	}
	tarefas = append(tarefas, t)
	return salvar(tarefas)
}

// Listar devolve as tarefas atuais lidas do arquivo.
func Listar() ([]Tarefa, error) {
	return carregar()
}

// Marcar localiza a tarefa pelo ID e seta Feita = true.
// Se não achar, devolve um erro descritivo.
func Marcar(id int) error {
	tarefas, err := carregar()
	if err != nil {
		return err
	}
	for i := range tarefas {
		if tarefas[i].ID == id {
			tarefas[i].Feita = true
			return salvar(tarefas)
		}
	}
	return fmt.Errorf("tarefa %d não encontrada", id)
}

// Remover retira a tarefa do slice (se existir) e salva.
func Remover(id int) error {
	tarefas, err := carregar()
	if err != nil {
		return err
	}
	for i, t := range tarefas {
		if t.ID == id {
			// truque clássico pra remover índice i mantendo a ordem
			tarefas = append(tarefas[:i], tarefas[i+1:]...)
			return salvar(tarefas)
		}
	}
	return fmt.Errorf("tarefa %d não encontrada", id)
}

// imprimir é só pra deixar a saída bonitinha durante a demo.
func imprimir(titulo string, tarefas []Tarefa) {
	fmt.Println("---", titulo, "---")
	if len(tarefas) == 0 {
		fmt.Println("(nenhuma tarefa)")
		return
	}
	for _, t := range tarefas {
		marca := "[ ]"
		if t.Feita {
			marca = "[x]"
		}
		fmt.Printf("  %s #%d %s\n", marca, t.ID, t.Titulo)
	}
}

func main() {
	// Começa limpo: se sobrou arquivo de execução anterior, apaga.
	os.Remove(arquivoTarefas)
	fmt.Println("Arquivo de tarefas:", arquivoTarefas)
	fmt.Println()

	// 1. Adicionar 3 tarefas
	if err := Adicionar(Tarefa{ID: 1, Titulo: "Estudar JSON em Go"}); err != nil {
		fmt.Println("erro:", err)
	}
	if err := Adicionar(Tarefa{ID: 2, Titulo: "Fazer compras"}); err != nil {
		fmt.Println("erro:", err)
	}
	if err := Adicionar(Tarefa{ID: 3, Titulo: "Caminhar 30 min"}); err != nil {
		fmt.Println("erro:", err)
	}

	// 2. Listar estado inicial
	lista, _ := Listar()
	imprimir("Depois de adicionar 3", lista)

	// 3. Marcar a #1 como feita
	if err := Marcar(1); err != nil {
		fmt.Println("erro:", err)
	}

	// 4. Remover a #2
	if err := Remover(2); err != nil {
		fmt.Println("erro:", err)
	}

	// 5. Listar estado final
	lista, _ = Listar()
	fmt.Println()
	imprimir("Depois de marcar #1 e remover #2", lista)

	// 6. Bônus: mostrar o conteúdo cru do arquivo, pra você ver
	// que a persistência aconteceu de verdade.
	fmt.Println()
	conteudo, _ := os.ReadFile(arquivoTarefas)
	fmt.Println("--- Conteúdo bruto do arquivo JSON ---")
	fmt.Println(string(conteudo))
}
*/
