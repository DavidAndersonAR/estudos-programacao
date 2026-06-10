# Módulo 07 — Generics

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar **por que** generics existem (em vez de `any` ou código duplicado)
- Escrever funções genéricas com `<T>`
- Criar classes e interfaces genéricas
- Usar **constraints** (`extends`) para limitar o que `T` pode ser
- Definir **defaults** de tipos genéricos
- Trabalhar com **múltiplos parâmetros** genéricos (`<K, V>`)
- Confiar na **inferência** que o TS faz dos generics na chamada

## 🧐 O problema que generics resolvem
Imagine uma função que retorna o primeiro item de um array:

```typescript
function primeiroNumero(arr: number[]): number {
    return arr[0];
}

function primeiroTexto(arr: string[]): string {
    return arr[0];
}
```

Isso é **código duplicado**. A "tentação fácil" é usar `any`:

```typescript
function primeiro(arr: any[]): any {
    return arr[0];
}

const n = primeiro([1, 2, 3]); // n é any 😬 — perdemos a tipagem
n.toUpperCase(); // ❌ Não dá erro de compilação, MAS quebra em runtime
```

`any` mata o TypeScript. Os **generics** resolvem isso: uma assinatura única que **preserva** o tipo de entrada e saída.

```typescript
function primeiro<T>(arr: T[]): T {
    return arr[0];
}

const n = primeiro([1, 2, 3]);          // T inferido: number → n: number
const s = primeiro(["a", "b", "c"]);    // T inferido: string → s: string
```

**Generic é um "parâmetro de tipo"**: em vez de receber um valor, recebe um tipo.

---

## 1. Sintaxe básica `<T>` em funções

```typescript
function identidade<T>(valor: T): T {
    return valor;
}

identidade<number>(10);   // T = number (explícito)
identidade("oi");          // T = string (inferido)
identidade(true);          // T = boolean (inferido)
```

A letra `T` é só **convenção** (vem de "Type"). Você pode usar qualquer nome:

```typescript
function primeiro<Item>(arr: Item[]): Item {
    return arr[0];
}
```

Convenções comuns no ecossistema:
- `T` — tipo genérico padrão
- `U`, `V`, `W` — tipos adicionais
- `K` — Key (chave)
- `V` — Value (valor)
- `E` — Error / Element
- `R` — Return

---

## 2. Generics em classes

A mesma ideia, só que o `<T>` fica **após o nome da classe**:

```typescript
class Caixa<T> {
    private conteudo: T;

    constructor(valor: T) {
        this.conteudo = valor;
    }

    abrir(): T {
        return this.conteudo;
    }

    trocar(novo: T): void {
        this.conteudo = novo;
    }
}

const caixaNumero = new Caixa<number>(42);
caixaNumero.abrir();        // number
caixaNumero.trocar(99);     // ok
// caixaNumero.trocar("x"); // ❌ Argument of type 'string' is not assignable to 'number'

const caixaTexto = new Caixa("olá"); // T inferido como string
```

Aqui `T` está disponível em **todos** os métodos da classe.

---

## 3. Generics em interfaces e types

```typescript
interface Resposta<T> {
    sucesso: boolean;
    dados: T;
}

const r1: Resposta<number> = { sucesso: true, dados: 200 };
const r2: Resposta<string[]> = { sucesso: true, dados: ["a", "b"] };
```

Com `type` é igual:

```typescript
type Resultado<T, E> =
    | { ok: true; valor: T }
    | { ok: false; erro: E };

const sucesso: Resultado<number, string> = { ok: true, valor: 10 };
const falha:   Resultado<number, string> = { ok: false, erro: "deu ruim" };
```

Esse padrão `Resultado<T, E>` é muito usado pra modelar **sucesso ou erro tipado** (estilo Rust/Go).

---

## 4. Constraints — `<T extends ...>`

Às vezes você precisa garantir que `T` tem certas propriedades. Use `extends`:

```typescript
function buscarPorId<T extends { id: number }>(itens: T[], id: number): T | undefined {
    return itens.find(item => item.id === id);
}

const usuarios = [
    { id: 1, nome: "Ana" },
    { id: 2, nome: "Bia" },
];

const u = buscarPorId(usuarios, 1); // u: { id: number; nome: string } | undefined
console.log(u?.nome); // ✅ TS sabe que tem 'nome' (preservou o tipo)

// buscarPorId([{ x: 1 }], 1); // ❌ Property 'id' is missing
```

**Sem `extends`**, dentro da função o TS não saberia que `item.id` existe — você nem conseguiria escrever isso.

Outro exemplo clássico (`extends keyof`):

```typescript
function pegar<T, K extends keyof T>(obj: T, chave: K): T[K] {
    return obj[chave];
}

const pessoa = { nome: "Ana", idade: 30 };
pegar(pessoa, "nome");   // string
pegar(pessoa, "idade");  // number
// pegar(pessoa, "x");   // ❌ "x" não é chave de pessoa
```

---

## 5. Defaults — `<T = string>`

Você pode dar um valor **padrão** ao parâmetro de tipo:

```typescript
interface Configuracao<T = string> {
    chave: string;
    valor: T;
}

const c1: Configuracao = { chave: "tema", valor: "escuro" };       // T = string (default)
const c2: Configuracao<number> = { chave: "porta", valor: 8080 };  // T = number
```

Útil quando o caso comum é um tipo específico, mas você quer permitir variação.

---

## 6. Múltiplos parâmetros — `<K, V>`

```typescript
class Par<A, B> {
    constructor(public primeiro: A, public segundo: B) {}
}

const p1 = new Par("idade", 30);          // Par<string, number>
const p2 = new Par<number, boolean>(1, true);

function trocar<A, B>(par: [A, B]): [B, A] {
    return [par[1], par[0]];
}

trocar(["a", 1]); // [number, string]
```

O exemplo mais famoso de múltiplos generics é o `Map<K, V>` do JS:

```typescript
const idades: Map<string, number> = new Map();
idades.set("Ana", 30);
idades.set("Bia", 25);
// idades.set("Carlos", "trinta"); // ❌ V deve ser number
```

---

## 7. Inferência de generics

Quase nunca você precisa passar o tipo explicitamente. O TS deduz:

```typescript
function envolver<T>(valor: T): { valor: T } {
    return { valor };
}

envolver(10);          // T = number
envolver("oi");        // T = string
envolver([1, 2, 3]);   // T = number[]
envolver({ x: 1 });    // T = { x: number }
```

Use `<T>` explícito **apenas** quando:
- A inferência falha (raro)
- Você quer **restringir** mais do que o inferido (ex.: forçar `Array<string | number>`)

---

## 🔥 Quando usar generics?
Pense em **"isso aqui funciona pra qualquer tipo, e o tipo de saída depende do de entrada"**. Sinais clássicos:
- Estruturas de dados (Lista, Pilha, Fila, Árvore, Cache, Map)
- Funções utilitárias (`map`, `filter`, `primeiro`, `agrupar`)
- Respostas de API com payload variável (`Resposta<T>`)
- Wrappers/containers (`Opcional<T>`, `Resultado<T, E>`)

**Não use** generic se o tipo nunca varia — só complica.

---

## ❌ Erros comuns

### 1. Usar `any` quando devia usar `<T>`
```typescript
function eco(x: any): any { return x; }       // ❌ perde tipo
function eco<T>(x: T): T { return x; }         // ✅ preserva tipo
```

### 2. Esquecer constraint quando usa propriedade de `T`
```typescript
function nomeDe<T>(x: T): string {
    return x.nome; // ❌ Property 'nome' does not exist on type 'T'
}
function nomeDe<T extends { nome: string }>(x: T): string {
    return x.nome; // ✅
}
```

### 3. Passar tipo explícito desnecessariamente
```typescript
identidade<number>(10); // funciona mas é redundante
identidade(10);          // melhor — TS infere
```

---

## 🚦 Próximos passos
1. Abra `pratica/main.ts` — 7 exercícios cobrindo tudo isso.
2. Encare o **desafio**: implemente um `Cache<K, V>` genérico, tipo um mini-Map.
3. Próximo módulo: **Utility Types e Decorators** (`Partial`, `Pick`, `Omit`, `Readonly`...).

## ✅ Auto-verificação
- [ ] Sei a sintaxe `function f<T>(x: T): T`
- [ ] Sei criar classe genérica `class C<T>`
- [ ] Sei usar `<T extends ...>` pra limitar tipos
- [ ] Sei usar default `<T = string>`
- [ ] Sei usar múltiplos params `<K, V>`
- [ ] Confio que o TS infere o `T` na chamada
