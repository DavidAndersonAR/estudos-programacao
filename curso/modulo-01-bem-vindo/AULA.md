# Módulo 01 — Bem-vindo ao Go

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que é Go e por que ele existe
- Reconhecer a estrutura mínima de um programa Go
- Rodar um programa com `go run` e compilar com `go build`
- Usar `go fmt` para formatar código automaticamente

## 🤔 O que é Go (e por que aprender)?
Go (também chamado de Golang) é uma linguagem criada pelo Google em 2009. Os criadores queriam algo:
- **Simples** como Python (sintaxe enxuta, poucas palavras-chave)
- **Rápido** como C (compilado para código nativo)
- **Bom para concorrência** (vários processos rodando juntos)

Onde Go brilha hoje:
- Servidores web e APIs (Docker, Kubernetes, Terraform são feitos em Go)
- Ferramentas de linha de comando
- Microsserviços
- Programas que precisam de boa performance sem a complexidade de C++

A filosofia é: **menos é mais**. Pouca sintaxe, código previsível, formatação padronizada.

## 🧱 O programa Go mais simples possível

```go
package main

import "fmt"

func main() {
    fmt.Println("Olá, Go!")
}
```

Vamos quebrar isso linha por linha:

### `package main`
Todo arquivo Go pertence a um **pacote**. O pacote chamado `main` é especial: é o que produz um programa executável. Outros pacotes são bibliotecas que vão ser importadas.

### `import "fmt"`
Importa o pacote `fmt` (de "format"), que tem funções para mostrar coisas na tela. Sem importar, não dá pra usar `fmt.Println`.

### `func main()`
A função `main` é o ponto de partida. Quando o programa roda, é ela que executa primeiro.

### `fmt.Println("Olá, Go!")`
Chama a função `Println` (Print Line — imprimir linha) do pacote `fmt`, mostrando o texto e pulando uma linha.

## 🛠️ Ferramentas essenciais

### `go run` — compila e executa de uma vez
Para testar rapidinho:
```bash
go run ./curso/modulo-01-bem-vindo/pratica
```

### `go build` — gera um executável
Quando você quer um binário pronto:
```bash
go build -o saudacao ./curso/modulo-01-bem-vindo/pratica
./saudacao   # roda o binário
```

### `go fmt` — formata o código
Go tem **um único estilo oficial**. Não existe "espaço vs tab" ou "chaves na mesma linha vs próxima". Você roda:
```bash
go fmt ./...
```
e tudo fica padronizado. A discussão acabou antes de começar. Bonito, né?

### `go version`
Mostra qual versão você tem instalada:
```bash
go version
```

## 💡 Detalhes que valem ouro
- **Maiúscula/minúscula importa**: `Println` (com P maiúsculo) é diferente de `println`. A regra do Go é: se começa com maiúscula, é "público" (exportado); minúscula é "privado" do pacote.
- **Ponto-e-vírgula é opcional**: você quase nunca vai escrever um. O compilador adiciona automaticamente no fim das linhas.
- **Import não usado = erro**: se você importa um pacote e não usa, o código nem compila. Mantém o código limpo.
- **Variável não usada = erro**: mesma coisa. Go não deixa você esquecer lixo no código.

## 👀 Variações para você entender melhor

```go
package main

import "fmt"

func main() {
    // Println pula linha no final
    fmt.Println("Linha 1")
    fmt.Println("Linha 2")

    // Print não pula linha
    fmt.Print("sem ")
    fmt.Print("quebra\n")  // a gente coloca \n manualmente

    // Printf permite formatar (estilo C/Python)
    nome := "David"
    idade := 30
    fmt.Printf("Olá %s, você tem %d anos\n", nome, idade)
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia o código com calma.
2. Rode: `go run ./curso/modulo-01-bem-vindo/pratica`
3. Modifique alguma coisa (mude o texto, adicione uma linha) e rode de novo. Erros são bem-vindos — quebrar coisa é como se aprende!
4. Encare o **desafio**: criar seu próprio cartão de visitas.

## ✅ Auto-verificação
- [ ] Sei explicar o que é `package main` em uma frase
- [ ] Sei a diferença entre `Println`, `Print` e `Printf`
- [ ] Consigo rodar um programa Go pela linha de comando
- [ ] Entendi por que `import` não-usado dá erro

Próximo módulo: **Tipos e Variáveis** — onde você vai aprender a guardar dados na memória.
