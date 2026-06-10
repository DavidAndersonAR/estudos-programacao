# Módulo 16 — JSON e Persistência

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é JSON e por que ele é o "esperanto" da web
- Converter struct em JSON com `json.Marshal`
- Converter JSON em struct com `json.Unmarshal`
- Gerar JSON bonitinho (com indentação) usando `json.MarshalIndent`
- Controlar nomes de campo no JSON com **struct tags** (`json:"nome"`)
- Omitir campos vazios com `,omitempty`
- Salvar dados em arquivo `.json` e carregar de volta
- Trabalhar com JSON em streaming via `json.Encoder` / `json.Decoder`
- Saber que existe `database/sql` e SQLite — pra quando o JSON não der mais conta

## 🤔 Por que JSON?
JSON (JavaScript Object Notation) virou o **formato universal** pra trocar dados entre programas. APIs REST falam JSON. Arquivos de configuração usam JSON. Banco de dados aceitam JSON. Praticamente toda linguagem do mundo lê e escreve JSON sem esforço.

A vantagem: é **texto legível por humanos** e tem só 4 tipos básicos (string, número, booleano, null) mais dois compostos (objeto `{}` e array `[]`). Simples assim.

Em Go, o pacote `encoding/json` faz a ponte entre **structs** (do mundo Go) e **texto JSON** (do mundo de fora). É o que a gente chama de **(des)serialização**.

## 📦 O pacote `encoding/json`
Tudo que você vai usar nesse módulo mora aqui:

```go
import "encoding/json"
```

As 4 funções/tipos centrais:
- `json.Marshal(v)` — pega um valor Go e devolve `[]byte` com o JSON
- `json.Unmarshal(data, &v)` — pega JSON em bytes e preenche um valor Go
- `json.MarshalIndent(v, prefix, indent)` — igual `Marshal`, mas bonitinho
- `json.NewEncoder(w)` / `json.NewDecoder(r)` — pra streaming (arquivos, rede)

## ✍️ Struct → JSON (Marshal)

```go
type Pessoa struct {
    Nome  string
    Idade int
}

p := Pessoa{Nome: "Ana", Idade: 28}
dados, _ := json.Marshal(p)
fmt.Println(string(dados))
// {"Nome":"Ana","Idade":28}
```

Detalhes importantes:
- `Marshal` devolve `[]byte`, então convertemos pra `string` na hora de imprimir.
- **Só campos exportados** (que começam com maiúscula) aparecem no JSON. Campos privados são ignorados.
- O nome no JSON, por padrão, é exatamente o nome do campo na struct.

## 📖 JSON → Struct (Unmarshal)

```go
texto := []byte(`{"Nome":"Bia","Idade":35}`)
var p Pessoa
err := json.Unmarshal(texto, &p)
if err != nil {
    fmt.Println("erro:", err)
}
fmt.Println(p.Nome, p.Idade) // Bia 35
```

Repare:
- Passamos `&p` (ponteiro). O `Unmarshal` precisa **escrever** dentro da variável, e pra isso ele precisa do endereço.
- Campos que existem no JSON mas **não** existem na struct são silenciosamente ignorados.
- Campos da struct que **não** aparecem no JSON ficam no valor zero (`""`, `0`, `false`).

## 🎨 JSON bonitinho com `MarshalIndent`
JSON em uma única linha é ótimo pra máquinas, péssimo pra humanos. Pra arquivos de configuração ou logs, use:

```go
dados, _ := json.MarshalIndent(p, "", "  ") // prefixo vazio, 2 espaços de indentação
fmt.Println(string(dados))
/*
{
  "Nome": "Ana",
  "Idade": 28
}
*/
```

O segundo argumento (prefixo) quase sempre é `""`. O terceiro (indentação) costuma ser `"  "` (2 espaços) ou `"\t"` (tab).

## 🏷️ Struct tags — controlando o JSON
Por padrão, o JSON usa o nome do campo Go (`Nome`, `Idade`). Mas APIs e arquivos costumam usar **snake_case** ou **camelCase**. A solução são as **tags**:

```go
type Pessoa struct {
    Nome  string `json:"nome"`
    Idade int    `json:"idade"`
    Email string `json:"email_principal"`
}
```

Agora o JSON sai:
```json
{"nome":"Ana","idade":28,"email_principal":"ana@x.com"}
```

A tag é uma **string entre crases** (não aspas duplas!) logo depois do tipo. Sintaxe: `` `json:"nome_no_json"` ``.

### `,omitempty` — sumir quando vazio
Tem campos que só fazem sentido às vezes. Com `omitempty`, eles **somem do JSON** quando estão no valor zero:

```go
type Pessoa struct {
    Nome     string `json:"nome"`
    Apelido  string `json:"apelido,omitempty"`  // some se string vazia
    Idade    int    `json:"idade,omitempty"`    // some se 0
}

p := Pessoa{Nome: "Ana"}
dados, _ := json.Marshal(p)
fmt.Println(string(dados))
// {"nome":"Ana"}   <- apelido e idade sumiram!
```

### `-` — ignorar de vez
Quer que um campo **nunca** apareça no JSON (mesmo sendo público)? Use `-`:

```go
type Usuario struct {
    Nome  string `json:"nome"`
    Senha string `json:"-"`   // NUNCA vai pro JSON
}
```

Ótimo pra senhas, tokens e dados sensíveis.

## 💾 Salvar e carregar de arquivo
A combinação clássica: serializar pra JSON e gravar no disco.

```go
// SALVAR
p := Pessoa{Nome: "Ana", Idade: 28}
dados, _ := json.MarshalIndent(p, "", "  ")
err := os.WriteFile("pessoa.json", dados, 0644)
if err != nil {
    fmt.Println("erro ao salvar:", err)
}

// CARREGAR
conteudo, err := os.ReadFile("pessoa.json")
if err != nil {
    fmt.Println("erro ao ler:", err)
}
var p2 Pessoa
json.Unmarshal(conteudo, &p2)
fmt.Println(p2) // {Ana 28}
```

Pronto — **persistência caseira**, sem precisar de banco de dados. Pra muita coisa (configurações, listas pequenas, caches) isso basta.

## 🌊 Streaming com Encoder e Decoder
Quando os dados são grandes (logs, listas longas) ou vêm de uma conexão de rede, ler tudo pra memória é desperdício. Use os tipos `Encoder`/`Decoder` que conversam direto com qualquer `io.Reader`/`io.Writer`:

```go
// Escrevendo num arquivo via Encoder
arq, _ := os.Create("dados.json")
defer arq.Close()

enc := json.NewEncoder(arq)
enc.SetIndent("", "  ")
enc.Encode(p) // escreve direto no arquivo
```

```go
// Lendo de um arquivo via Decoder
arq, _ := os.Open("dados.json")
defer arq.Close()

var p Pessoa
dec := json.NewDecoder(arq)
dec.Decode(&p)
```

Vantagens:
- Não precisa converter pra `[]byte` no meio.
- Funciona com HTTP, sockets, qualquer coisa que seja `Reader`/`Writer`.
- Pra múltiplos objetos em sequência, `Decode` pode ser chamado em loop.

## 🧩 Campos opcionais com ponteiros
Tem casos em que você precisa distinguir entre **"campo veio com valor zero"** e **"campo não veio"**. O truque é usar **ponteiros**:

```go
type Config struct {
    Tema    string `json:"tema"`
    Timeout *int   `json:"timeout,omitempty"`  // ponteiro para int
}
```

Se o JSON traz `"timeout": 0`, `Timeout` vai apontar pra um `int` com valor 0.
Se o JSON **não** traz `timeout`, `Timeout` fica `nil`.

```go
if cfg.Timeout != nil {
    fmt.Println("timeout configurado:", *cfg.Timeout)
} else {
    fmt.Println("sem timeout — usa o padrão")
}
```

## 🗄️ E quando o JSON não dá mais conta? `database/sql` + SQLite
Arquivo JSON é ótimo para:
- Configurações
- Listas pequenas (até alguns milhares de itens)
- Estado de aplicativos simples

Mas começa a ficar ruim quando:
- Você precisa fazer **buscas** rápidas (sem ler o arquivo inteiro)
- Vários processos escrevem ao mesmo tempo
- Os dados crescem pra centenas de milhares de itens

Pra esses casos, a próxima parada é um **banco de dados**. Go traz o pacote padrão **`database/sql`** que conversa com qualquer banco via "drivers". O mais leve e popular pra aprender é o **SQLite** (banco num único arquivo, zero configuração).

Por que **não** vamos usar SQLite neste módulo? Porque o driver mais comum (`mattn/go-sqlite3`) precisa de **CGO** e um compilador C instalado — complica a vida de quem está aprendendo. Por enquanto, JSON em arquivo te leva longe.

Quando quiser dar o próximo passo, comece por aqui:
- Documentação oficial: https://pkg.go.dev/database/sql
- Tutorial do site oficial do Go: https://go.dev/doc/tutorial/database-access
- Drivers SQLite puros em Go (sem CGO): `modernc.org/sqlite`

## 💡 Detalhes que valem ouro
- **Sempre cheque o erro** de `Marshal` e `Unmarshal`. Tipos incompatíveis, JSON malformado — qualquer coisa retorna erro.
- **Campo precisa ser exportado** (Maiúscula) pra entrar no JSON. Esqueceu? Ele some.
- **Tags vão entre crases**, não aspas. `` `json:"nome"` `` — escrever com `"` quebra.
- **`omitempty` olha o valor zero do tipo.** Pra `int` é `0`, pra `string` é `""`, pra `slice` é `nil`. Cuidado: campo `Ativo bool` com `omitempty` some quando `false` — às vezes não é o que você quer.
- **JSON não tem `int` vs `float`.** Tudo é "number". Se você puser um número num campo `int` e ele tiver casas decimais, dá erro.
- **`MarshalIndent` é só pra humanos lerem.** Pra trocar dados entre programas, prefira `Marshal` (mais compacto).
- **Slice vazio vs nil:** `Marshal` de `nil` vira `null`. `Marshal` de `[]int{}` vira `[]`. Importa pra quem consome o JSON.

## 👀 Variações pra fixar

```go
// Slice vira array JSON
nomes := []string{"Ana", "Beto", "Cris"}
dados, _ := json.Marshal(nomes)
fmt.Println(string(dados)) // ["Ana","Beto","Cris"]

// Map vira objeto JSON
notas := map[string]int{"matematica": 9, "historia": 7}
dados, _ = json.Marshal(notas)
fmt.Println(string(dados)) // {"historia":7,"matematica":9}

// Struct dentro de struct
type Endereco struct {
    Cidade string `json:"cidade"`
    UF     string `json:"uf"`
}
type Cliente struct {
    Nome     string   `json:"nome"`
    Endereco Endereco `json:"endereco"`
}

c := Cliente{Nome: "Ana", Endereco: Endereco{Cidade: "SP", UF: "SP"}}
dados, _ = json.MarshalIndent(c, "", "  ")
fmt.Println(string(dados))
/*
{
  "nome": "Ana",
  "endereco": {
    "cidade": "SP",
    "uf": "SP"
  }
}
*/
```

## 🚦 Próximos passos
1. Leia **`pratica/main.go`** e rode: `go run ./curso/modulo-16-json-banco/pratica`
2. Veja como os exercícios criam arquivos temporários (em `os.TempDir()`) — limpo, sem sujar o projeto.
3. Encare o **desafio**: o **CRUD de Tarefas**, persistido em JSON.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `Marshal` e `Unmarshal`
- [ ] Sei usar struct tags pra renomear campos no JSON
- [ ] Lembro que `Unmarshal` precisa de **ponteiro** (`&v`)
- [ ] Sei quando usar `MarshalIndent` vs `Marshal`
- [ ] Entendo o que `,omitempty` faz e quando ele "engana"
- [ ] Sei combinar `json.Marshal` + `os.WriteFile` pra persistir dados
- [ ] Sei que existem `Encoder`/`Decoder` pra streaming
- [ ] Sei que o próximo nível é `database/sql` + SQLite, e onde aprender

Próximo módulo: **Testes em Go** — onde você vai aprender a escrever testes automatizados com `testing` e ganhar segurança pra mexer no código sem medo.
