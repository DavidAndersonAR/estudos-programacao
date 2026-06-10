# Embedding (Composição) em Go — Resumo simples

Go não tem herança como em outras linguagens. Em vez disso, ele tem **embedding** (composição): um tipo "embute" outro, ganhando seus campos e métodos automaticamente. É o jeito Go de reaproveitar comportamento.

## 1. Embedding de struct em struct
Coloca o tipo dentro de outro sem dar nome ao campo.

```go
type Animal struct {
    Nome  string
    Idade int
}

func (a Animal) Apresentar() string {
    return a.Nome + " tem " + strconv.Itoa(a.Idade) + " anos"
}

type Cachorro struct {
    Animal       // embedded! não tem nome
    Raca   string
}

c := Cachorro{
    Animal: Animal{Nome: "Rex", Idade: 5},
    Raca:   "Labrador",
}

fmt.Println(c.Nome)         // acessa direto, como se fosse de Cachorro
fmt.Println(c.Apresentar()) // método também é "herdado"
```

---

## 2. Promoção de campos e métodos
O que está embutido é "promovido" — você acessa direto pelo tipo que embute, sem precisar passar pelo campo intermediário.

```go
// Sem precisar de c.Animal.Nome
c.Nome
c.Idade
c.Apresentar()
```

Mas se precisar do tipo original, ele ainda está lá:
```go
c.Animal // o struct original
```

---

## 3. Embedding com ponteiro
Pode embutir `*T` em vez de `T`. Útil quando o tipo embutido é grande ou compartilhado.

```go
type Logger struct {
    Prefixo string
}

func (l *Logger) Log(msg string) {
    fmt.Println(l.Prefixo, msg)
}

type Servico struct {
    *Logger  // embedded por ponteiro
    Nome string
}

s := Servico{
    Logger: &Logger{Prefixo: "[SVC]"},
    Nome:   "auth",
}
s.Log("iniciado") // chama Logger.Log
```

---

## 4. Sobrescrita (override)
Se o tipo que embute define um método com o mesmo nome, ele "esconde" o do embutido.

```go
type Base struct{}
func (b Base) Tipo() string { return "base" }

type Filho struct {
    Base
}
func (f Filho) Tipo() string { return "filho" }

f := Filho{}
fmt.Println(f.Tipo())      // "filho" (sobrescrita)
fmt.Println(f.Base.Tipo()) // "base"  (acesso explícito)
```

---

## 5. Embedding de interface em interface
Combina várias interfaces numa só.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// ReadWriter "herda" os métodos das duas
type ReadWriter interface {
    Reader
    Writer
}
```

Quem implementar `ReadWriter` tem que ter os dois métodos.

---

## 6. Embedding de interface em struct
Permite que um struct satisfaça uma interface "delegando" para um campo.

```go
type Cache struct {
    sync.Mutex  // ganha Lock() e Unlock() automaticamente
    dados map[string]string
}

c := &Cache{dados: make(map[string]string)}
c.Lock()        // método do sync.Mutex embutido
c.dados["k"] = "v"
c.Unlock()
```

---

## 7. Ambiguidade
Se dois tipos embutidos têm o mesmo método/campo, o compilador não escolhe — você precisa ser explícito.

```go
type A struct{}
func (A) Hello() string { return "A" }

type B struct{}
func (B) Hello() string { return "B" }

type C struct {
    A
    B
}

c := C{}
// c.Hello()    // ERRO! ambíguo
c.A.Hello()    // OK
c.B.Hello()    // OK
```

---

## 8. Embedding NÃO é herança
Apesar de parecido, há diferenças importantes:
- **Não há polimorfismo**: se um método de `Animal` chama outro método de `Animal`, ele NÃO vai chamar a versão sobrescrita em `Cachorro` (em linguagens com herança, chamaria).
- **Não há "super"** — não dá pra chamar "o método do pai" implicitamente. Você acessa pelo nome do campo: `c.Animal.Apresentar()`.

Go prefere **composição** explícita em vez de hierarquia. Pense em "tem um" em vez de "é um".

---

## 9. Quando usar
- Reaproveitar implementação (struct embute struct).
- Compor interfaces (interface embute interface).
- "Decoradores": um tipo embute outro e adiciona/troca comportamento.

Evite embedding profundo ou em cadeia — fica difícil de seguir.

---

Em resumo: embedding é o jeito Go de fazer reuso. Ele não é herança — é composição com açúcar sintático. Use para combinar comportamentos, mas sem montar árvores complexas.
