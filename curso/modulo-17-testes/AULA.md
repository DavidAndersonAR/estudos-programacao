# Módulo 17 — Testes

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever testes automatizados com o pacote `testing`
- Organizar testes em arquivos `_test.go`
- Rodar e interpretar `go test`, `go test -v` e `go test -cover`
- Usar **table-driven tests** e **sub-tests** com `t.Run`
- Escrever **benchmarks** para medir performance

## 🤔 Por que testar?
Imagina que você escreveu uma função `Dividir(a, b)`. Ela funciona pro caso `10 / 2`. E quando `b = 0`? E quando os números são negativos? E daqui a 3 meses, depois de mexer em outras 50 funções, será que ela ainda funciona?

**Testes automatizados** respondem essas perguntas em segundos. Você roda `go test` e:
- Sabe na hora se quebrou algo (regressão).
- Documenta como sua função deve se comportar.
- Tem coragem de refatorar — porque se quebrar, o teste avisa.

Em Go, testes são **parte da linguagem**. Não precisa instalar framework. Tudo já vem pronto.

## 🧱 O teste mais simples possível

Suponha que você tem:

```go
// arquivo: matematica.go
package matematica

func Somar(a, b int) int {
    return a + b
}
```

O teste fica num arquivo **com o mesmo nome + `_test.go`**:

```go
// arquivo: matematica_test.go
package matematica

import "testing"

func TestSomar(t *testing.T) {
    resultado := Somar(2, 3)
    esperado := 5
    if resultado != esperado {
        t.Errorf("Somar(2, 3) = %d; esperado %d", resultado, esperado)
    }
}
```

Para rodar:
```bash
go test ./...
```

Se passar, aparece `ok`. Se falhar, mostra a mensagem do `t.Errorf`.

## 🔍 Quebrando linha por linha

### Arquivo `_test.go`
O Go reconhece automaticamente qualquer arquivo terminado em `_test.go` como arquivo de teste. Ele **não vai pro binário final** — só roda quando você chama `go test`.

### `import "testing"`
O pacote padrão de testes do Go. Vem na biblioteca padrão.

### `func TestXxx(t *testing.T)`
Toda função de teste:
- Começa com **`Test`** (com T maiúsculo).
- Recebe **um único parâmetro** `t *testing.T`.
- Não retorna nada.

O `t` é o "controlador do teste": é por ele que você avisa que algo falhou.

### `t.Errorf` vs `t.Fatalf`
- **`t.Errorf(formato, args...)`** — marca o teste como falho, mas **continua executando** as próximas linhas.
- **`t.Fatalf(formato, args...)`** — marca como falho e **para na hora**. Use quando faria pouco sentido continuar (ex: erro inesperado na configuração).

```go
if err != nil {
    t.Fatalf("não deveria ter dado erro, mas deu: %v", err)
}
// se chegou aqui, dá pra usar o resultado com segurança
```

## 🛠️ Comandos essenciais

### `go test` — roda os testes
Roda todos os testes do pacote atual:
```bash
go test
```
Ou em todos os pacotes do projeto:
```bash
go test ./...
```

### `go test -v` — modo verboso
Mostra cada teste passando (nome + tempo):
```bash
go test -v
```
Saída típica:
```
=== RUN   TestSomar
--- PASS: TestSomar (0.00s)
PASS
ok      meu/pacote  0.123s
```

### `go test -run` — rodar um teste específico
Por nome (aceita regex):
```bash
go test -run TestSomar
```

### `go test -cover` — cobertura de código
Mostra qual porcentagem das linhas do seu código está sendo exercitada pelos testes:
```bash
go test -cover
```
Saída tipo: `coverage: 87.5% of statements`.

## 🍱 Table-driven tests — o padrão Go

Em vez de escrever uma função `TestSomar1`, `TestSomar2`, `TestSomar3`... você cria uma **tabela** (slice) de casos e roda todos num laço. É o padrão da comunidade.

```go
func TestSomar(t *testing.T) {
    casos := []struct {
        nome     string
        a, b     int
        esperado int
    }{
        {"dois positivos", 2, 3, 5},
        {"negativo com positivo", -1, 1, 0},
        {"dois zeros", 0, 0, 0},
        {"dois negativos", -2, -3, -5},
    }

    for _, c := range casos {
        resultado := Somar(c.a, c.b)
        if resultado != c.esperado {
            t.Errorf("%s: Somar(%d, %d) = %d; esperado %d",
                c.nome, c.a, c.b, resultado, c.esperado)
        }
    }
}
```

Vantagens:
- Adicionar caso novo = adicionar **uma linha**.
- Fácil de ler — parece uma planilha.

## 🪆 Sub-tests com `t.Run`

Você pode dar **nome próprio** a cada caso, e o Go trata como teste separado:

```go
for _, c := range casos {
    t.Run(c.nome, func(t *testing.T) {
        resultado := Somar(c.a, c.b)
        if resultado != c.esperado {
            t.Errorf("Somar(%d, %d) = %d; esperado %d",
                c.a, c.b, resultado, c.esperado)
        }
    })
}
```

Agora `go test -v` mostra:
```
=== RUN   TestSomar/dois_positivos
--- PASS: TestSomar/dois_positivos (0.00s)
=== RUN   TestSomar/negativo_com_positivo
--- PASS: TestSomar/negativo_com_positivo (0.00s)
```

E você pode rodar **só um** sub-test:
```bash
go test -run TestSomar/dois_positivos
```

## ⚡ Benchmarks — medindo performance

Funções de benchmark seguem o mesmo padrão, mas começam com **`Benchmark`** e recebem `*testing.B`:

```go
func BenchmarkSomar(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Somar(2, 3)
    }
}
```

O `b.N` é definido pelo Go automaticamente: ele aumenta até medir um tempo confiável.

Para rodar:
```bash
go test -bench=.
```

Saída típica:
```
BenchmarkSomar-8   1000000000   0.25 ns/op
```
Ou seja: rodou 1 bilhão de vezes, cada chamada custou 0,25 nanossegundos.

## 💡 Detalhes que valem ouro
- **Mesmo pacote**: o arquivo `_test.go` precisa ter o **mesmo `package`** do arquivo testado (ou então `pacote_test` para testes "de fora", caixa-preta).
- **Não use `fmt.Println` em teste**: use `t.Logf` (só aparece com `-v`).
- **Teste primeiro o caminho feliz**, depois os de erro (divisão por zero, slice vazio, etc.).
- **Cobertura 100% não garante qualidade** — significa só que cada linha rodou, não que cada cenário foi testado.
- **Nomes de teste descrevem comportamento**: `TestDividir_ErroQuandoDivisorEhZero` é melhor que `TestDividir2`.

## 👀 Exemplo completo de erro

Se você tem:
```go
func Dividir(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("divisão por zero")
    }
    return a / b, nil
}
```

O teste verifica os **dois caminhos**:

```go
func TestDividir(t *testing.T) {
    t.Run("divisão normal", func(t *testing.T) {
        r, err := Dividir(10, 2)
        if err != nil {
            t.Fatalf("não esperava erro, recebi %v", err)
        }
        if r != 5 {
            t.Errorf("esperava 5, recebi %v", r)
        }
    })

    t.Run("divisão por zero", func(t *testing.T) {
        _, err := Dividir(10, 0)
        if err == nil {
            t.Errorf("esperava erro, recebi nil")
        }
    })
}
```

## 🚦 Próximos passos
1. Abra **`pratica/main.go`** e leia as funções (Somar, Dividir, etc).
2. Abra **`pratica/main_test.go`** e estude como cada teste foi escrito.
3. Rode: `go test ./curso/modulo-17-testes/pratica -v`
4. Rode com cobertura: `go test ./curso/modulo-17-testes/pratica -cover`
5. Rode o benchmark: `go test ./curso/modulo-17-testes/pratica -bench=.`
6. Encare o **desafio**: testar uma calculadora de verdade — com validações.

## ✅ Auto-verificação
- [ ] Sei criar um arquivo `_test.go` e uma função `TestXxx`
- [ ] Entendo a diferença entre `t.Errorf` e `t.Fatalf`
- [ ] Consigo escrever um table-driven test com sub-tests (`t.Run`)
- [ ] Sei rodar `go test`, `go test -v` e `go test -cover`
- [ ] Sei escrever um `BenchmarkXxx` simples

Próximo módulo: **Concorrência** — onde Go realmente brilha, com goroutines e canais.
