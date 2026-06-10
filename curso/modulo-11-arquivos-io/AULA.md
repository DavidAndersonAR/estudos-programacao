# Módulo 11 — Arquivos e I/O

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Ler e escrever arquivos com `os.ReadFile` e `os.WriteFile`
- Abrir arquivos com `os.Open` e `os.Create` e usar `defer file.Close()`
- Entender em uma frase o que são `io.Reader` e `io.Writer`
- Ler arquivos linha a linha com `bufio.Scanner`
- Escrever com buffer usando `bufio.NewWriter` e o famoso `Flush`
- Copiar dados entre duas pontas com `io.Copy`
- Montar caminhos portáveis com `path/filepath`

## 🤔 Por que arquivos e I/O importam?
Até agora tudo que seu programa fez morreu junto com ele. Quando o `main` termina, a memória some. Para guardar coisas de verdade — logs, configurações, dados, exportações — você precisa **persistir** em algum lugar. O lugar mais simples e universal é um **arquivo no disco**.

Em Go, mexer com arquivos é direto. O pacote `os` te dá o básico, e o pacote `bufio` te dá performance e conveniência (ler linha a linha, por exemplo).

## 📦 Os pacotes que você vai usar
- **`os`** — abrir, criar, remover, listar arquivos. Conversa direto com o sistema operacional.
- **`io`** — interfaces genéricas (`Reader`, `Writer`) e utilitários como `io.Copy`.
- **`bufio`** — leitura e escrita com **buffer**, ou seja, com cache em memória pra ser mais rápido.
- **`path/filepath`** — junta caminhos de forma portável entre Windows e Linux/Mac.

## 📄 Forma mais simples: ler tudo de uma vez

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    conteudo, err := os.ReadFile("notas.txt")
    if err != nil {
        fmt.Println("erro:", err)
        return
    }
    fmt.Println(string(conteudo)) // conteudo é []byte, convertemos para string
}
```

Detalhes:
- `os.ReadFile` lê o arquivo **inteiro** para a memória. Ótimo pra arquivos pequenos, ruim pra arquivos de gigabytes.
- Retorna `[]byte` mais um `error`. Sempre cheque o erro.
- `string(conteudo)` converte os bytes para texto.

## ✍️ Escrever de uma vez

```go
texto := []byte("Olá, arquivo!\nSegunda linha.\n")
err := os.WriteFile("saida.txt", texto, 0644)
if err != nil {
    fmt.Println("erro:", err)
}
```

- `0644` é a **permissão** (em notação Unix): dono pode ler/escrever, todo mundo pode ler. No Windows isso é praticamente ignorado, mas sempre coloque.
- Se o arquivo existe, ele é **sobrescrito** (cuidado!).

## 🔓 Abrir e fechar: a forma manual

`os.ReadFile` e `os.WriteFile` são atalhos. Por baixo deles, Go usa `os.Open` (leitura) e `os.Create` (escrita):

```go
arq, err := os.Open("notas.txt")
if err != nil {
    fmt.Println("erro:", err)
    return
}
defer arq.Close() // garante que vai fechar quando a função terminar
```

### `defer file.Close()` — o seu novo melhor amigo
`defer` agenda uma função pra rodar **quando a função atual terminar**. Combinado com `Close`, é a forma idiomática de garantir que arquivos não fiquem abertos por engano. Coloca **logo depois de abrir** e esquece.

```go
arq, err := os.Create("saida.txt") // cria (ou trunca) o arquivo
if err != nil {
    return
}
defer arq.Close()

arq.WriteString("conteúdo\n")
```

## 📚 `io.Reader` e `io.Writer` — em uma frase
Em Go, qualquer coisa que sabe **ler bytes** implementa `io.Reader`. Qualquer coisa que sabe **escrever bytes** implementa `io.Writer`. Arquivos, conexões de rede, buffers em memória — tudo segue essas duas interfaces.

Isso significa que funções como `io.Copy(destino, origem)` funcionam **igualzinho** pra arquivo, rede ou string. Você aprende uma vez e usa pra sempre.

## 📜 Ler linha a linha com `bufio.Scanner`
Pra arquivos grandes ou pra processar linha por linha (logs, CSVs simples), o jeito certo é:

```go
arq, _ := os.Open("notas.txt")
defer arq.Close()

scanner := bufio.NewScanner(arq)
for scanner.Scan() {
    linha := scanner.Text() // a linha atual, sem o \n
    fmt.Println(linha)
}

if err := scanner.Err(); err != nil {
    fmt.Println("erro de leitura:", err)
}
```

- `scanner.Scan()` retorna `true` enquanto tem linha; `false` quando acaba ou dá erro.
- `scanner.Text()` te dá a linha **sem** quebra de linha no fim.

## 🚀 Escrever com `bufio.NewWriter` (e não esquece o Flush!)

Quando você vai escrever **muitas** coisas pequenas, escrever direto no arquivo é lento (cada chamada é uma ida ao disco). O `bufio.NewWriter` junta tudo num buffer em memória e só escreve de verdade quando enche — ou quando você chama `Flush`.

```go
arq, _ := os.Create("saida.txt")
defer arq.Close()

w := bufio.NewWriter(arq)
for i := 1; i <= 1000; i++ {
    fmt.Fprintf(w, "linha %d\n", i)
}
w.Flush() // ⚠️ ESSENCIAL: sem isso, parte pode não chegar no disco!
```

**Esqueceu o `Flush`?** O arquivo pode ficar incompleto. Acostume: `defer w.Flush()` logo depois de criar o writer.

## 🔁 `io.Copy` — copiar de A para B
Quando você só quer despejar uma fonte (Reader) em um destino (Writer):

```go
origem, _ := os.Open("entrada.txt")
defer origem.Close()
destino, _ := os.Create("copia.txt")
defer destino.Close()

n, err := io.Copy(destino, origem)
fmt.Printf("copiou %d bytes (erro=%v)\n", n, err)
```

Por usar as interfaces `Reader`/`Writer`, `io.Copy` funciona entre qualquer combinação: arquivo → arquivo, HTTP → arquivo, buffer → arquivo, etc.

## 🗂️ Caminhos com `filepath`
No Windows, o separador é `\`. No Linux/Mac, é `/`. Hardcoded vira problema. Use:

```go
import "path/filepath"

caminho := filepath.Join("dados", "2026", "junho.txt")
// no Windows: dados\2026\junho.txt
// no Linux:   dados/2026/junho.txt
```

Outros úteis:
- `filepath.Base("/tmp/foo.txt")` → `"foo.txt"`
- `filepath.Dir("/tmp/foo.txt")` → `"/tmp"`
- `filepath.Ext("foo.txt")` → `".txt"`

## 🧪 Listar arquivos de um diretório

```go
entradas, _ := os.ReadDir(".")
for _, e := range entradas {
    fmt.Println(e.Name(), e.IsDir())
}
```

`os.ReadDir` te dá uma fatia com cada entrada — pode ser arquivo ou pasta. `IsDir()` te diz qual.

## 💡 Detalhes que valem ouro
- **Sempre cheque o erro** em I/O. Disco cheio, arquivo inexistente, sem permissão — qualquer um pode acontecer.
- **`defer Close` logo após abrir.** Não deixe pra depois — você esquece.
- **Não confunda `os.Open` com `os.Create`.** `Open` é só leitura; `Create` cria/trunca pra escrita.
- **Use `os.CreateTemp`** quando precisar de um arquivo temporário (testes, scripts). Ele cria com nome único em `os.TempDir()` e não suja seu projeto.
- **Caminhos relativos** dependem de onde o programa foi rodado. Em dúvida, use `filepath.Abs` pra debugar.
- **`bufio.Scanner` tem um limite padrão de linha** (~64 KB). Pra linhas gigantes, configure com `scanner.Buffer(...)`.

## 👀 Comparando jeitos de ler

```go
// Modo 1: tudo de uma vez (arquivos pequenos)
conteudo, _ := os.ReadFile("a.txt")

// Modo 2: linha a linha (arquivos médios/grandes, processamento por linha)
arq, _ := os.Open("a.txt")
defer arq.Close()
scanner := bufio.NewScanner(arq)
for scanner.Scan() {
    fmt.Println(scanner.Text())
}

// Modo 3: streaming bruto (binários, copiar)
arq2, _ := os.Open("a.bin")
defer arq2.Close()
io.Copy(os.Stdout, arq2) // joga direto na saída padrão
```

## 🚦 Próximos passos
1. Leia **`pratica/main.go`** e rode: `go run ./curso/modulo-11-arquivos-io/pratica`
2. Repare como os exemplos usam **arquivos temporários** — boa prática pra não sujar o projeto.
3. Encare o **desafio**: o **Contador de Palavras**.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `os.ReadFile` e `os.Open`
- [ ] Sempre coloco `defer file.Close()` logo depois de abrir
- [ ] Lembro de chamar `Flush()` quando uso `bufio.NewWriter`
- [ ] Sei usar `bufio.Scanner` pra ler linha a linha
- [ ] Uso `filepath.Join` em vez de concatenar caminhos com `"/"` ou `"\\"`
- [ ] Sei que `io.Reader` e `io.Writer` são interfaces que muita coisa implementa

Próximo módulo: **Erros em Go** — onde você vai aprender a tratar erros do jeito idiomático, e não só ignorar com `_`.
