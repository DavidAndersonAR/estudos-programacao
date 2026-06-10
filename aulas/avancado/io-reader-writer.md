# io.Reader e io.Writer — Resumo simples

Duas das interfaces mais importantes do Go. Praticamente tudo que envolve entrada/saída (arquivos, HTTP, strings, compressão, criptografia) usa essas duas. Entender elas é entender o "encanamento" do Go.

## 1. A interface io.Reader
Representa qualquer coisa de onde dá pra LER dados em sequência.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

A função `Read` enche o buffer `p` com até `len(p)` bytes e retorna quantos leu. Quando acabam os dados, devolve `io.EOF`.

```go
import (
    "io"
    "strings"
)

r := strings.NewReader("Olá, mundo!")
buf := make([]byte, 4)

for {
    n, err := r.Read(buf)
    fmt.Printf("%d bytes: %q\n", n, buf[:n])
    if err == io.EOF { break }
}
```

---

## 2. A interface io.Writer
Representa qualquer coisa onde dá pra ESCREVER dados em sequência.

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

Recebe um buffer e escreve, retornando quantos bytes foram escritos.

```go
import "os"

n, err := os.Stdout.Write([]byte("Olá!\n"))
fmt.Println("escreveu", n, "bytes, erro:", err)
```

---

## 3. Tipos que implementam essas interfaces
Praticamente todo I/O em Go usa essas duas:

- `os.File` — arquivo (lê E escreve)
- `bytes.Buffer` — buffer em memória
- `strings.Reader` — lê uma string
- `bytes.Reader` — lê um slice de bytes
- `os.Stdin` / `os.Stdout` / `os.Stderr` — entrada e saída padrão
- `http.Request.Body` (Reader) e `http.ResponseWriter` (Writer)
- `gzip.Reader`/`gzip.Writer`, `bufio.Reader`/`bufio.Writer`, etc.

Tudo isso "encaixa" com qualquer função que aceite `io.Reader` ou `io.Writer`.

---

## 4. io.Copy — copiar de Reader para Writer
Função utilitária pra mover dados de um lado pro outro.

```go
import "io"

origem, _ := os.Open("entrada.txt")
defer origem.Close()

destino, _ := os.Create("saida.txt")
defer destino.Close()

bytes, _ := io.Copy(destino, origem)
fmt.Println("copiados", bytes, "bytes")
```

---

## 5. io.ReadAll — ler tudo de uma vez
Lê o conteúdo inteiro de um Reader como um `[]byte`.

```go
r := strings.NewReader("conteúdo aqui")
dados, _ := io.ReadAll(r)
fmt.Println(string(dados))
```

Cuidado com arquivos enormes — carrega tudo na memória.

---

## 6. Encadear Readers/Writers
A grande sacada: como tudo usa as mesmas interfaces, dá pra encaixar uns nos outros como tubos.

```go
// Comprimir → escrever em arquivo
arquivo, _ := os.Create("dados.txt.gz")
defer arquivo.Close()

gzipWriter := gzip.NewWriter(arquivo)
defer gzipWriter.Close()

gzipWriter.Write([]byte("conteúdo grande"))
// Os bytes passam: gzip → comprimido → arquivo
```

---

## 7. bufio — leitura/escrita com buffer
Lê/escreve em grandes blocos para ser mais eficiente.

```go
import "bufio"

// Leitor com buffer, linha a linha
arquivo, _ := os.Open("texto.txt")
defer arquivo.Close()

scanner := bufio.NewScanner(arquivo)
for scanner.Scan() {
    fmt.Println(scanner.Text())
}
```

```go
// Escritor com buffer (chame Flush no final)
w := bufio.NewWriter(os.Stdout)
defer w.Flush()
w.WriteString("rápido\n")
```

---

## 8. Implementar Reader/Writer próprio
Qualquer tipo seu pode satisfazer a interface implementando `Read` ou `Write`.

```go
type ContadorWriter struct {
    Bytes int
}

func (c *ContadorWriter) Write(p []byte) (int, error) {
    n := len(p)
    c.Bytes += n
    return n, nil
}

// Uso:
c := &ContadorWriter{}
io.Copy(c, strings.NewReader("contando bytes"))
fmt.Println("recebeu", c.Bytes, "bytes")
```

---

## 9. Outras interfaces da família
- `io.ReadCloser` — Reader que precisa ser fechado (`http.Response.Body`)
- `io.Seeker` — quem permite "pular" para uma posição
- `io.ReaderAt` / `io.WriterAt` — ler/escrever em posição específica
- `io.ReadWriter` — implementa as duas

Combinações úteis na stdlib: `io.ReadWriteCloser`, `io.ReadSeeker`, etc.

---

## 10. Padrões úteis
- `io.MultiReader(a, b, c)` — concatena vários readers em sequência.
- `io.MultiWriter(a, b)` — escreve no mesmo conteúdo em vários destinos.
- `io.TeeReader(r, w)` — lê de r e escreve em w ao mesmo tempo (espelho).
- `io.LimitReader(r, n)` — lê no máximo n bytes.

---

Em resumo: `io.Reader` e `io.Writer` são interfaces minúsculas (um método cada), mas formam a base de toda a I/O do Go. Qualquer função que aceita `io.Reader` aceita arquivos, strings, sockets, gzip, etc. — sem precisar de adaptadores. É um dos melhores exemplos do poder das interfaces pequenas em Go.
