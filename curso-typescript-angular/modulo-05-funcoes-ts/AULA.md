# Módulo 05 — Funções em TypeScript

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Anotar parâmetros e retorno de funções com confiança
- Usar parâmetros **opcionais**, valores **default** e **rest parameters**
- Escrever **arrow functions** com tipos
- Declarar uma variável que armazena uma função (tipo função)
- Entender **overload signatures** (várias assinaturas, uma implementação)
- Decidir quando anotar o retorno e quando deixar o TS inferir

## 🧐 Por que funções merecem um módulo só?
Funções são o coração de qualquer programa. No TS elas ganham um superpoder: a **assinatura** vira contrato. Quem chama sabe exatamente o que passar e o que recebe — sem ler a implementação.

```typescript
// Assinatura = contrato público
function dobrar(n: number): number {
    return n * 2;
}
```

Olhando só `dobrar(n: number): number`, você já sabe **tudo**.

---

## 1. Anotação de parâmetros e retorno

Regra básica: cada parâmetro recebe `: Tipo` e o retorno vai depois dos parênteses, antes do `{`.

```typescript
function saudar(nome: string, vezes: number): string {
    return `Olá, ${nome}! `.repeat(vezes);
}
```

Se o parâmetro não tem tipo, o TS reclama (a menos que `noImplicitAny` esteja desligado — não desligue).

### `void` vs retorno omitido
Função que não retorna nada usa `: void`:

```typescript
function log(msg: string): void {
    console.log(msg);
}
```

---

## 2. Parâmetros opcionais — `x?: T`

Põe `?` depois do nome. O parâmetro pode ser omitido na chamada e, dentro da função, ele vira `T | undefined`.

```typescript
function cumprimentar(nome: string, titulo?: string): string {
    if (titulo) return `${titulo} ${nome}`;
    return nome;
}

cumprimentar("Ana");          // "Ana"
cumprimentar("Ana", "Dra.");  // "Dra. Ana"
```

⚠️ **Opcional só pode vir DEPOIS dos obrigatórios** — `(a?: string, b: number)` é erro.

---

## 3. Valores default

Se o valor não vem, usa o default. Diferente do opcional, **dentro da função** o tipo é só `T` (sem `undefined`).

```typescript
function potencia(base: number, expoente: number = 2): number {
    return base ** expoente;
}

potencia(3);     // 9   (usa default)
potencia(3, 4);  // 81
```

Default e opcional não andam juntos: `(x: number = 0)` já é "opcional por default", o `?` é redundante.

---

## 4. Rest parameters — `...args: T[]`

Coleta todos os argumentos restantes num array.

```typescript
function somar(...numeros: number[]): number {
    return numeros.reduce((acc, n) => acc + n, 0);
}

somar(1, 2, 3);        // 6
somar(1, 2, 3, 4, 5);  // 15
somar();               // 0
```

O rest **tem que ser o último parâmetro** da lista.

---

## 5. Arrow functions tipadas

Mesma ideia, sintaxe enxuta:

```typescript
const dobrar = (n: number): number => n * 2;

const saudar = (nome: string): string => `Olá, ${nome}!`;

const somar = (a: number, b: number): number => a + b;
```

Quando o corpo é uma única expressão, o `return` é implícito (sem chaves).

---

## 6. Função como tipo — `(x: T) => U`

Você pode dizer "essa variável guarda uma função que recebe X e devolve Y":

```typescript
let operacao: (a: number, b: number) => number;

operacao = (a, b) => a + b;   // ✅ TS já sabe que a e b são number
operacao = (a, b) => a * b;   // ✅
operacao = (a) => a;          // ❌ assinatura diferente
```

Isso é fundamental para **callbacks** (função passada como argumento):

```typescript
function aplicar(n: number, fn: (x: number) => number): number {
    return fn(n);
}

aplicar(5, (x) => x * 10);  // 50
```

### `type` para apelidar
Quando a assinatura é longa, dá um nome:

```typescript
type Comparador<T> = (a: T, b: T) => number;

const porIdade: Comparador<{ idade: number }> = (a, b) => a.idade - b.idade;
```

---

## 7. Overload signatures

Quando a mesma função aceita combinações diferentes de tipos e devolve coisas diferentes dependendo da entrada.

Você declara **várias assinaturas** seguidas, e UMA implementação que cobre todas:

```typescript
// Assinaturas públicas (o que o chamador enxerga)
function processar(valor: string): number;
function processar(valor: number): string;
// Implementação (não aparece no autocomplete — é "interna")
function processar(valor: string | number): string | number {
    if (typeof valor === "string") return valor.length;
    return valor.toString();
}

const a = processar("hello");  // a: number (= 5)
const b = processar(42);       // b: string (= "42")
```

A implementação tem que ser compatível com **todas** as assinaturas declaradas. O chamador só vê as assinaturas, não a implementação.

⚠️ Use overload com moderação — muita gente abusa. Quando der pra resolver com union (`string | number`) e retorno único, prefira union.

---

## 8. `this` em funções (rápido)

`this` no TS pode ter o tipo declarado como **primeiro parâmetro** (não conta na chamada):

```typescript
interface Usuario {
    nome: string;
}

function saudar(this: Usuario): string {
    return `Olá, ${this.nome}`;
}
```

Arrow functions **não têm `this` próprio** — elas pegam o `this` do escopo onde foram criadas. Por isso são preferidas em callbacks de classes/métodos. Vamos aprofundar isso no módulo de Classes.

---

## 9. Inferência de retorno — quando anotar?

O TS deduz o retorno olhando o corpo:

```typescript
function dobrar(n: number) {
    return n * 2;
}
// TS sabe: dobrar retorna number
```

**Quando anotar mesmo assim?**
- Funções **públicas** (exportadas, métodos de classe) — o tipo vira documentação e trava acidentes.
- Funções **recursivas** — sem anotação o TS pode dar `any`.
- Quando você quer **forçar** um tipo específico (ex: retornar `unknown` em vez de `string`).

**Quando deixar inferir?**
- Helpers internos pequenos.
- Arrow functions curtas passadas como callback (`arr.map(x => x * 2)`).

Regra de bolso: parâmetro **sempre anota**, retorno **anota em pública, infere em privada/curta**.

---

## 🚦 Próximos passos
1. Abra `pratica/main.ts` — 8 exercícios cobrindo cada conceito acima.
2. Encare o **desafio**: monte uma mini biblioteca de utilitários tipados (`capitalizar`, `formatarMoeda`, `agruparPor`, `compor`).
3. Tente quebrar tudo: passe tipos errados de propósito pra ver o TS chiando.

## ✅ Auto-verificação
- [ ] Sei a diferença entre parâmetro opcional (`?`) e default (`= valor`)
- [ ] Sei escrever uma arrow function tipada
- [ ] Sei declarar o tipo de uma variável que guarda uma função
- [ ] Entendi quando usar overload (e quando preferir union)
- [ ] Sei quando vale anotar o retorno e quando deixar inferir

Próximo módulo: **Objetos e Interfaces** — modelando dados estruturados.
