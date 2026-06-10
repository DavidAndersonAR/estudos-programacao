# Módulo 10 — Pacotes

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é um **pacote** e por que Go é organizado em pacotes
- Usar `package` na primeira linha de cada arquivo `.go`
- Importar pacotes de várias formas: simples, agrupado, com **apelido**, com `_` (blank)
- Diferenciar identificadores **exportados** (Maiúscula) de **não exportados** (minúscula)
- Entender o papel especial do pacote `main`
- Inicializar um **módulo** com `go mod init` e entender `go.mod` e `go.sum`
- Organizar seu projeto em pastas/subpacotes

## 🤔 O que é um pacote?
Um **pacote** é uma pasta com um ou mais arquivos `.go` que pertencem ao mesmo "grupo". Eles compartilham nomes, compartilham acesso entre si, e podem ser importados por outros pacotes.

Pense num pacote como uma **caixa de ferramentas**:
- Por fora, você vê só o que está escrito no rótulo (as funções com **letra Maiúscula**).
- Por dentro, a caixa tem várias coisas auxiliares (funções com **letra minúscula**) que ninguém de fora precisa ver.

Go já vem com uma biblioteca padrão enorme: `fmt`, `strings`, `strconv`, `math`, `time`, `os`, `sort`, `net/http`… cada um é um pacote separado.

## 🧱 A regra do `package`
Todo arquivo Go **começa** com uma linha:

```go
package nome_do_pacote
```

Algumas regras práticas:
- Todos os arquivos da **mesma pasta** precisam ter o **mesmo nome de pacote**.
- O nome do pacote, por convenção, é **curto, minúsculo e sem underline**: `strings`, `http`, `utils`.
- O pacote `main` é especial: é o que vira um **programa executável**. Todo o resto vira biblioteca.

```go
// arquivo: main.go
package main

import "fmt"

func main() {
    fmt.Println("eu sou um executável")
}
```

```go
// arquivo: utils/matematica.go
package utils

func Somar(a, b int) int { // exportada (M maiúsculo)
    return a + b
}
```

## 📦 `import` — trazendo pacotes pra dentro

### Import simples
Um pacote só, em uma linha:
```go
import "fmt"
```

### Import agrupado (o mais comum)
Vários pacotes, em bloco, **ordenados alfabeticamente** (o `go fmt` faz isso pra você):
```go
import (
    "fmt"
    "math"
    "strings"
)
```

### Import com apelido
Quando dois pacotes têm o mesmo nome final, ou quando você quer encurtar:
```go
import (
    "fmt"
    m "math"          // agora "m" é o apelido de "math"
    str "strings"     // "str" no lugar de "strings"
)

func main() {
    fmt.Println(m.Pi)
    fmt.Println(str.ToUpper("oi"))
}
```

### Import "blank" — `_`
Importa o pacote **só pelos efeitos colaterais** (geralmente registrar drivers, init functions). Você não usa nada dele diretamente:
```go
import (
    _ "image/png"   // registra o decoder PNG no pacote "image"
)
```
Sem o `_`, o Go reclamaria de "import não usado". O `_` diz "eu sei o que estou fazendo".

## 🔓 Exportado (Maiúsculo) vs 🔒 Não exportado (minúsculo)
Go não tem `public` nem `private`. A regra é **só a primeira letra**:

| Identificador | Visibilidade |
|---|---|
| `Somar`, `Cliente`, `Pi`  | **Exportado** — qualquer pacote pode usar |
| `somar`, `cliente`, `pi`  | **Não exportado** — só o próprio pacote |

```go
package utils

func Dobrar(n int) int {   // pode ser chamada de fora: utils.Dobrar(...)
    return multiplicar(n, 2)
}

func multiplicar(a, b int) int { // só visível dentro de "utils"
    return a * b
}
```

Vale para **funções, tipos, constantes, variáveis e até campos de struct**.

```go
type Pessoa struct {
    Nome  string // exportado
    idade int    // não exportado (fora do pacote ninguém lê nem escreve)
}
```

## 🎬 O pacote `main` é especial
- Tem que se chamar **exatamente** `main`.
- Precisa ter uma função `func main()` — que é o ponto de partida do programa.
- Não pode ser importado por outros pacotes (não faz sentido).

Todo executável Go tem um, e só um, pacote `main`.

## 🧰 Módulos — o "projeto" em Go
Antes (Go < 1.11) tudo dependia de `GOPATH`. Hoje, usamos **módulos**.

Um **módulo** é a unidade que o Go usa para versionar e baixar dependências. Cada módulo tem um arquivo `go.mod` na raiz.

### Criando um módulo
Na pasta do seu projeto:
```bash
go mod init github.com/seunome/meuprojeto
```
Isso cria um `go.mod` parecido com:
```
module github.com/seunome/meuprojeto

go 1.22
```

### `go.mod`
- Declara o **caminho do módulo** (o "endereço" oficial dele).
- Diz a **versão do Go**.
- Lista as **dependências** quando você instala alguma.

### `go.sum`
- Aparece depois que você baixa dependências externas (`go get ...`).
- Tem **hashes** de cada versão baixada — garante que o que você baixou hoje é igual ao que outra pessoa vai baixar amanhã.
- **Não edite na mão. Commit junto com o `go.mod`.**

### Comandos úteis
```bash
go mod init github.com/seu/projeto   # cria o módulo
go mod tidy                          # adiciona/remove dependências conforme o código
go get github.com/x/y                # baixa uma lib
go list -m all                       # lista módulos do projeto
```

## 🗂️ Organização de pastas
A convenção:
- **uma pasta = um pacote**.
- O nome do **arquivo** não precisa bater com o nome do pacote.
- Subpastas viram subpacotes, importados pelo caminho completo.

Exemplo de estrutura:
```
meuprojeto/
├── go.mod
├── main.go                    -> package main
└── utils/
    ├── strings.go             -> package utils
    └── numeros.go             -> package utils
```

E no `main.go`:
```go
package main

import (
    "fmt"
    "github.com/seu/meuprojeto/utils"
)

func main() {
    fmt.Println(utils.Somar(2, 3))
}
```

⚠️ O caminho do `import` é o **módulo + subpasta**, não o nome do pacote.

## 💡 Detalhes que valem ouro
- **Pacote != arquivo**. Vários arquivos podem formar um pacote — eles enxergam tudo um do outro (mesmo minúsculo).
- **Ciclos são proibidos**: se A importa B, B **não pode** importar A. Direta ou indiretamente. O compilador trava na hora.
- **`init()`** é uma função especial que roda **antes** do `main()`, automaticamente. Útil para inicializações (registrar coisas, validar config). Pode ter mais de uma, uma por arquivo.
- **`internal/`** é uma pasta mágica: pacotes dentro de `internal/` só podem ser importados pelo próprio módulo. Bom pra esconder partes internas mesmo dentro do seu projeto.
- **Pacote `main` em pastas diferentes** = executáveis diferentes. Bom para CLIs que têm vários comandos.

## 👀 Variações para entender melhor

```go
// Exemplo: usando strings da stdlib
package main

import (
    "fmt"
    "strings"
)

func main() {
    frase := "Olá Mundo Go"
    fmt.Println(strings.ToUpper(frase))         // OLÁ MUNDO GO
    fmt.Println(strings.Contains(frase, "Go"))  // true
    fmt.Println(strings.Split(frase, " "))      // [Olá Mundo Go]
}
```

```go
// Exemplo: import com apelido para encurtar
package main

import (
    "fmt"
    s "strings"
)

func main() {
    fmt.Println(s.Repeat("ab", 3)) // ababab
}
```

```go
// Exemplo: init() rodando antes do main
package main

import "fmt"

func init() {
    fmt.Println("init A — roda antes do main")
}

func init() {
    fmt.Println("init B — também roda antes")
}

func main() {
    fmt.Println("main — última coisa a rodar")
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e veja como usamos vários pacotes da stdlib.
2. Rode: `go run ./curso/modulo-10-pacotes/pratica`
3. Brinque trocando pacotes, testando apelidos, comentando imports e vendo o erro.
4. Encare o **desafio**: montar sua própria **Biblioteca de Utilitários**.

## ✅ Auto-verificação
- [ ] Sei que `package main` cria um executável e o resto cria biblioteca
- [ ] Entendi que letra Maiúscula = exportado, minúscula = privado do pacote
- [ ] Sei usar import simples, agrupado, com apelido e com `_`
- [ ] Consigo criar um módulo com `go mod init`
- [ ] Entendi para que servem `go.mod` e `go.sum`
- [ ] Sei que cada pasta é um pacote e que ciclos são proibidos

Próximo módulo: **Tratamento de Erros** — onde você vai aprender o jeito Go de lidar com problemas.
