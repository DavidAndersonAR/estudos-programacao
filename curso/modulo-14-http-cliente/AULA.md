# Módulo 14 — HTTP Cliente

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Fazer requisições HTTP GET e POST com o pacote `net/http`
- Ler o corpo (body) de uma resposta com `io.ReadAll`
- Sempre fechar o body com `defer resp.Body.Close()`
- Interpretar status codes (200, 404, 500…)
- Decodificar JSON em struct com `encoding/json`
- Customizar requisições com `http.NewRequest` (headers, métodos)
- Criar um `http.Client` com timeout para evitar travamentos

## 🌐 O que é um cliente HTTP?
Quando você abre o navegador e digita um endereço, o navegador é um **cliente HTTP**: ele manda uma requisição pro servidor, recebe uma resposta, e mostra o resultado.

Em Go, a gente vai fazer o mesmo — mas de dentro do código. Isso é a base de:
- Consumir APIs (ViaCEP, GitHub, OpenWeather…)
- Webhooks
- Integrações entre sistemas
- Scrapers

A boa notícia: Go já vem com tudo pronto no pacote `net/http`. Nada de instalar biblioteca.

## 🚀 O GET mais simples possível

```go
package main

import (
    "fmt"
    "io"
    "net/http"
)

func main() {
    resp, err := http.Get("https://httpbin.org/get")
    if err != nil {
        fmt.Println("erro:", err)
        return
    }
    defer resp.Body.Close()

    body, err := io.ReadAll(resp.Body)
    if err != nil {
        fmt.Println("erro ao ler body:", err)
        return
    }

    fmt.Println("Status:", resp.Status)
    fmt.Println("Body:", string(body))
}
```

Vamos quebrar isso:

### `http.Get(url)`
Função pronta que faz uma requisição GET. Retorna dois valores: `*http.Response` e `error`. Como sempre em Go, checa o erro antes de seguir.

### `defer resp.Body.Close()`
**Não esqueça disso.** O body é um stream (uma conexão aberta com o servidor). Se você não fechar, a conexão fica viva, vaza memória e pode acabar travando seu programa. Use `defer` logo depois de checar o erro — assim o close acontece quando a função terminar, aconteça o que acontecer.

### `io.ReadAll(resp.Body)`
Lê tudo o que o servidor mandou e devolve um `[]byte`. Pra exibir como texto, converte com `string(body)`.

### `resp.Status` e `resp.StatusCode`
- `resp.Status` → string tipo `"200 OK"`
- `resp.StatusCode` → inteiro tipo `200`

## 🚦 Status codes (os mais comuns)
- **200 OK** — deu certo
- **201 Created** — recurso criado (POST geralmente)
- **301/302** — redirecionamento
- **400 Bad Request** — você mandou algo errado
- **401 Unauthorized** — falta autenticar
- **403 Forbidden** — autenticou, mas não pode
- **404 Not Found** — não existe
- **500 Internal Server Error** — o servidor quebrou

**Importante:** `http.Get` **só** retorna erro em falhas de rede (DNS, sem internet, timeout). Se o servidor responde 404 ou 500, NÃO é erro do ponto de vista de Go — é uma resposta válida. Você precisa checar o `StatusCode` na mão:

```go
if resp.StatusCode != http.StatusOK {
    fmt.Println("resposta inesperada:", resp.Status)
    return
}
```

## 📦 Decodificando JSON
A maioria das APIs modernas devolve JSON. Em Go, a gente cria uma `struct` que espelha o formato esperado e deixa o `encoding/json` fazer o resto.

```go
type Usuario struct {
    ID    int    `json:"id"`
    Nome  string `json:"name"`
    Email string `json:"email"`
}
```

As **tags** entre crases (`` `json:"name"` ``) dizem ao Go: "o campo `Nome` vem do JSON com a chave `name`". Sem isso, ele tentaria casar por nome exato (sensível a maiúsculas).

### Jeito 1 — `json.Unmarshal` (lê tudo, depois decodifica)
```go
body, _ := io.ReadAll(resp.Body)
var u Usuario
err := json.Unmarshal(body, &u)
```

### Jeito 2 — `json.NewDecoder` (decodifica direto do stream)
```go
var u Usuario
err := json.NewDecoder(resp.Body).Decode(&u)
```

O segundo é mais econômico de memória pra respostas grandes. Os dois funcionam — use o que ficar mais legível pro seu caso.

## 🛠️ Quando `http.Get` não basta: `http.NewRequest`
`http.Get` é só atalho. Pra coisas mais ricas (headers, POST, autenticação) você monta a requisição na mão:

```go
req, err := http.NewRequest("GET", "https://api.exemplo.com/dados", nil)
if err != nil { /* ... */ }

req.Header.Set("Authorization", "Bearer meu-token")
req.Header.Set("User-Agent", "MeuApp/1.0")

client := &http.Client{}
resp, err := client.Do(req)
```

`http.NewRequest(metodo, url, body)` cria a requisição. O terceiro parâmetro é o corpo (pra POST/PUT) — pode ser `nil` em GET.

## ⏱️ Cliente com timeout (faça isso sempre em produção)
O `http.DefaultClient` **não tem timeout**. Se o servidor travar, seu programa fica preso pra sempre. Solução: crie seu próprio `http.Client`:

```go
client := &http.Client{
    Timeout: 10 * time.Second,
}

resp, err := client.Get("https://api.exemplo.com/dados")
```

Agora, se a resposta demorar mais de 10 segundos, vem erro de timeout e o programa segue vivo.

## 📤 POST com JSON no body
Pra mandar dados:

```go
dados := map[string]string{"nome": "David", "cargo": "dev"}
corpo, _ := json.Marshal(dados)

resp, err := http.Post(
    "https://httpbin.org/post",
    "application/json",
    bytes.NewBuffer(corpo),
)
```

- `json.Marshal` converte struct/map em `[]byte` JSON.
- `bytes.NewBuffer(corpo)` transforma o `[]byte` em algo que se comporta como stream (`io.Reader`), que é o que `http.Post` exige.
- O `"application/json"` é o **Content-Type** — informa o servidor que está chegando JSON.

## 💡 Detalhes que valem ouro
- **Sempre** `defer resp.Body.Close()` logo após checar o erro do `Get`/`Do`.
- **Sempre** cheque `resp.StatusCode` antes de assumir sucesso.
- **Sempre** use `http.Client` com timeout em código de produção.
- `json.NewDecoder(resp.Body).Decode(&v)` é o jeito idiomático pra respostas JSON médias/grandes.
- Use **structs com tags** — não fique tentando ler JSON como `map[string]interface{}` (vira pesadelo).
- `httpbin.org` é um servidor público feito **pra testes** de HTTP — ele responde com eco do que você mandou. Ótimo pra aprender.

## 👀 Variação: GET com query parameters
Você pode montar a URL na mão, mas o pacote `net/url` é mais seguro:

```go
import "net/url"

base, _ := url.Parse("https://httpbin.org/get")
params := url.Values{}
params.Add("nome", "David")
params.Add("idade", "30")
base.RawQuery = params.Encode()

resp, err := http.Get(base.String())
// vira: https://httpbin.org/get?nome=David&idade=30
```

A vantagem: ele faz o **encoding** automático (espaços viram `%20`, acentos são tratados etc).

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia os 6 exercícios resolvidos. Rode um por um.
2. Mexa nos parâmetros (URLs, query strings) e veja a resposta mudar.
3. Encare o **desafio**: o **Consultor de CEP** que consome a API ViaCEP de verdade.

## ✅ Auto-verificação
- [ ] Sei explicar por que `defer resp.Body.Close()` é obrigatório
- [ ] Sei a diferença entre erro de rede e status code 4xx/5xx
- [ ] Consigo decodificar JSON em uma struct usando tags
- [ ] Sei criar um `http.Client` com timeout
- [ ] Sei fazer um POST com JSON no body

Próximo módulo: **HTTP Servidor** — onde você vai do outro lado: criar o servidor que responde às requisições.
