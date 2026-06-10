# Módulo 15 — HTTP Servidor

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Subir um servidor HTTP em Go com pouquíssimas linhas
- Registrar rotas com `http.HandleFunc`
- Escrever uma função handler que recebe `ResponseWriter` e `*Request`
- Ler **query parameters**, **método HTTP** e o **body** da requisição
- Definir o **status code** da resposta (`w.WriteHeader`)
- Devolver respostas em **texto simples** ou em **JSON**

## 🤔 Servidor HTTP — por que Go é tão bom nisso?
Em muitas linguagens, fazer um servidor HTTP envolve um framework pesado (Express, Spring, Django...). Em Go, o **pacote padrão `net/http`** já te entrega tudo o que precisa: servidor, roteamento básico, parsing de requisição, escrita de resposta. Sem instalar nada.

Go nasceu pensando em servidores: cada requisição já vira automaticamente uma **goroutine** (lembra do Módulo 12?). Você escreve código simples e ele aguenta milhares de conexões em paralelo. É por isso que Docker, Kubernetes e tantas APIs grandes são feitas em Go.

## 🧱 O servidor HTTP mais simples possível

```go
package main

import (
    "fmt"
    "net/http"
)

func ola(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w, "Olá, mundo!")
}

func main() {
    http.HandleFunc("/", ola)
    http.ListenAndServe(":8080", nil)
}
```

Roda com `go run .` e abre o navegador em `http://localhost:8080`. Pronto: você tem um servidor web. Vamos destrinchar.

### `http.HandleFunc("/rota", handler)`
Diz ao servidor: "quando alguém pedir a rota `/rota`, chame essa função". O segundo argumento é uma função com uma **assinatura específica**:

```go
func(w http.ResponseWriter, r *http.Request)
```

- `w` (ResponseWriter) — é onde você **escreve a resposta** (texto, JSON, status...).
- `r` (Request) — é o que o cliente **mandou**: URL, método, headers, body, etc.

### `http.ListenAndServe(":8080", nil)`
Sobe o servidor na porta 8080. O `nil` significa "use o roteador padrão" (aquele que `HandleFunc` configurou). Esse é o bloqueante: o programa fica rodando até você apertar `Ctrl+C`.

> ⚠️ `ListenAndServe` retorna um `error`. Em programas sérios, você captura isso com `log.Fatal(http.ListenAndServe(...))`.

## ✍️ Escrevendo a resposta

`http.ResponseWriter` **é uma interface** que se comporta como um `io.Writer` (lembra do Módulo 11?). Então tudo que escreve em `io.Writer` funciona aqui:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w, "texto simples")               // escreve sem quebra
    fmt.Fprintln(w, "com quebra de linha")       // pula linha
    fmt.Fprintf(w, "olá %s, idade %d\n", "Ana", 30) // formatado
}
```

### Definindo o status code
Por padrão, a resposta sai com `200 OK`. Para mudar:

```go
w.WriteHeader(http.StatusNotFound) // 404
fmt.Fprint(w, "não achei")
```

> ⚠️ Chame `WriteHeader` **antes** de escrever o corpo. Depois que você começou a escrever, é tarde.

Constantes úteis em `net/http`:
- `http.StatusOK` (200)
- `http.StatusCreated` (201)
- `http.StatusBadRequest` (400)
- `http.StatusNotFound` (404)
- `http.StatusInternalServerError` (500)

## 🔎 Lendo a requisição

### Query parameters (`?nome=david&idade=30`)
```go
nome := r.URL.Query().Get("nome")   // "david"
idade := r.URL.Query().Get("idade") // "30" (vem como string!)
```

Se a chave não existe, vem string vazia. Para checar:
```go
if nome == "" {
    w.WriteHeader(http.StatusBadRequest)
    fmt.Fprint(w, "faltou o parâmetro 'nome'")
    return
}
```

### Método HTTP (GET, POST, PUT, DELETE...)
```go
if r.Method != http.MethodPost {
    w.WriteHeader(http.StatusMethodNotAllowed) // 405
    fmt.Fprint(w, "use POST aqui")
    return
}
```

### Lendo o body da requisição
O body é um `io.Reader`. Lê com `io.ReadAll`:

```go
import "io"

corpo, err := io.ReadAll(r.Body)
if err != nil {
    w.WriteHeader(http.StatusInternalServerError)
    return
}
defer r.Body.Close()

fmt.Fprintf(w, "recebi: %s", corpo)
```

## 📦 Devolvendo JSON

A maneira idiomática é montar uma struct e codar com `encoding/json`:

```go
import "encoding/json"

type Resposta struct {
    Mensagem string `json:"mensagem"`
    Codigo   int    `json:"codigo"`
}

func handlerJSON(w http.ResponseWriter, r *http.Request) {
    dados := Resposta{Mensagem: "tudo certo", Codigo: 200}

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(dados)
}
```

Saída: `{"mensagem":"tudo certo","codigo":200}`

> 💡 O `Content-Type` ajuda o cliente (navegador, curl, app) a saber **o que** chegou. Sem ele, um JSON vira só texto solto.

## 💡 Detalhes que valem ouro
- **Cada requisição é uma goroutine** — o servidor lida com várias ao mesmo tempo sozinho. Mas cuidado com variáveis compartilhadas (mutex do Módulo 13).
- **Não escreva header depois do body** — depois do primeiro `Fprint`, o `WriteHeader` é ignorado (e o Go até loga um aviso).
- **`r.URL.Query()` retorna `url.Values`** — que é só um `map[string][]string`. `.Get` pega o primeiro valor.
- **Sempre `defer r.Body.Close()`** quando você lê o body. Boas práticas evitam vazamento.
- **Porta em uso?** Erro comum: "address already in use". Algum servidor anterior travou — mate ele ou troque a porta.

## 👀 Variações para você entender melhor

```go
// Múltiplas rotas, cada uma com sua função
http.HandleFunc("/", inicio)
http.HandleFunc("/sobre", sobre)
http.HandleFunc("/api/usuarios", listarUsuarios)

// Roteando pelo método dentro do mesmo handler
func usuarios(w http.ResponseWriter, r *http.Request) {
    switch r.Method {
    case http.MethodGet:
        fmt.Fprint(w, "listando usuários")
    case http.MethodPost:
        fmt.Fprint(w, "criando usuário")
    default:
        http.Error(w, "método não suportado", http.StatusMethodNotAllowed)
    }
}

// Helper http.Error: escreve status + texto de uma vez
http.Error(w, "deu ruim", http.StatusInternalServerError)
```

## 🧪 Testando com curl

Enquanto seu servidor está rodando em outro terminal:
```bash
curl http://localhost:8080/                       # GET simples
curl "http://localhost:8080/ola?nome=David"       # com query param
curl -X POST -d "olá mundo" http://localhost:8080/eco  # POST com body
curl -i http://localhost:8080/status              # -i mostra os headers
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia o código com calma.
2. Rode: `go run ./curso/modulo-15-http-servidor/pratica`
3. Abra o navegador em `http://localhost:8080` e teste cada rota.
4. Use o `curl` para bater nas rotas com diferentes métodos e parâmetros.
5. Encare o **desafio**: API de Saudação Multilíngue.

## ✅ Auto-verificação
- [ ] Sei subir um servidor HTTP com `net/http` em menos de 10 linhas
- [ ] Entendo a assinatura `func(w http.ResponseWriter, r *http.Request)`
- [ ] Sei pegar query parameters com `r.URL.Query().Get(...)`
- [ ] Sei diferenciar o método HTTP (`r.Method`) e responder de acordo
- [ ] Sei ler o body com `io.ReadAll(r.Body)`
- [ ] Sei devolver JSON com `json.NewEncoder(w).Encode(...)`
- [ ] Sei mudar o status code com `w.WriteHeader(...)`

Próximo módulo: **JSON e Banco de Dados** — onde você vai juntar tudo isso com persistência real.
