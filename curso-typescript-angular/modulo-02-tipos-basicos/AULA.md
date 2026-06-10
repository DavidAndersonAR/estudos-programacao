# Módulo 02 — Tipos Básicos

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Reconhecer e usar todos os tipos primitivos do TS
- Saber a diferença entre `any` e `unknown` (e por que `unknown` é melhor)
- Entender o papel de `void`, `never`, `null` e `undefined`
- Escolher entre `enum` e união de literais (`"a" | "b" | "c"`)
- Modelar coleções com array (`T[]`) e tupla (`[string, number]`)

## 🧱 Os primitivos
TS herda os primitivos de JS e adiciona anotações de tipo.

### `number`
Inteiros e floats, tudo junto. Não tem `int` vs `float` como em outras linguagens.
```typescript
const idade: number = 30;
const preco: number = 19.90;
const hex: number = 0xff;
const bin: number = 0b1010;
```

### `string`
Texto. Use aspas simples, duplas ou crase (template literal).
```typescript
const nome: string = "Ana";
const saudacao: string = `Olá, ${nome}!`;
```

### `boolean`
`true` ou `false`.
```typescript
const ativo: boolean = true;
```

### `bigint`
Inteiros **arbitrariamente grandes** — quando `number` não dá conta (acima de `2^53`).
```typescript
const enorme: bigint = 9007199254740993n; // sufixo n
const outro: bigint = BigInt("12345678901234567890");
```
Você quase nunca vai usar isso no Angular. Saiba que existe.

### `symbol`
Valores únicos e imutáveis, usados como chaves "secretas" de objetos.
```typescript
const id: symbol = Symbol("id");
```
Caso de uso avançado (metaprogramação). **Mencionei pra você ter visto** — pode esquecer por ora.

## 📦 Array
Coleção ordenada do **mesmo tipo**. Duas sintaxes equivalentes:
```typescript
const numeros: number[] = [1, 2, 3];
const palavras: Array<string> = ["a", "b", "c"];
```
Use `T[]` para tipos simples e `Array<T>` quando `T` é complexo (ex.: `Array<{ id: number }>`). É só preferência estética.

## 🎯 Tuple (tupla)
Array de **tamanho fixo** com **tipos específicos** em cada posição.
```typescript
const par: [string, number] = ["idade", 30];
const rgb: [number, number, number] = [255, 100, 0];

par[0].toUpperCase(); // ✅ TS sabe que [0] é string
par[1].toFixed(2);    // ✅ TS sabe que [1] é number
```
Útil para retornar múltiplos valores (estilo `useState` do React: `[valor, setValor]`).

## 🔢 Enum
Conjunto nomeado de constantes.
```typescript
enum Status {
    Ativo,    // 0
    Inativo,  // 1
    Pendente  // 2
}

const s: Status = Status.Ativo;
```
Por padrão são números. Dá pra usar string:
```typescript
enum Cor {
    Vermelho = "RED",
    Verde = "GREEN",
    Azul = "BLUE"
}
```

### ⚠️ Por que muita gente prefere **união de literais** ao `enum`?
```typescript
type Status = "ativo" | "inativo" | "pendente";

const s: Status = "ativo";   // ✅
const x: Status = "outro";   // ❌ Erro
```
Vantagens da união:
- **Não gera código em runtime** (enum gera um objeto JS).
- Mais fácil de serializar/comparar com strings vindas de API.
- Sintaxe mais leve.

Use `enum` quando precisar iterar sobre os valores ou quando o time já tem essa convenção. Caso contrário, prefira união de literais. O Angular usa as duas formas.

## 🌫️ `any` vs `unknown`

### `any` — "desliga o TS"
```typescript
let x: any = 10;
x = "texto";
x = { qualquer: "coisa" };
x.metodoQueNaoExiste(); // ✅ TS não reclama (mas vai quebrar em runtime)
```
**Evite.** `any` apaga a segurança que o TS te dá. Use só quando estiver migrando JS antigo e ainda não tem como tipar.

### `unknown` — "eu não sei o tipo, mas você vai me provar"
```typescript
let x: unknown = pegarDaAPI();

x.toUpperCase(); // ❌ Erro — TS exige checagem

if (typeof x === "string") {
    x.toUpperCase(); // ✅ agora TS sabe que é string
}
```
**Prefira `unknown`** quando o tipo de fato é desconhecido (parsing JSON, dados externos). Força você a **estreitar** (`narrow`) antes de usar.

## 🚫 `void`
Retorno de função que **não devolve nada**.
```typescript
function logar(msg: string): void {
    console.log(msg);
    // sem return
}
```
Não confunda com `undefined`: `void` é um conceito de assinatura, "não me importo com o que volta".

## 💀 `never`
Função que **nunca retorna** (lança erro ou loop infinito).
```typescript
function explodir(msg: string): never {
    throw new Error(msg);
}

function loopEterno(): never {
    while (true) { /* ... */ }
}
```
Também aparece em situações onde o TS deduz que "esse caso é impossível" — útil em verificações exaustivas de `switch`.

## ❓ `null` e `undefined`
Dois tipos, dois significados culturais:
- `undefined` — "nunca atribuído" (default do JS).
- `null` — "explicitamente vazio".

```typescript
let a: string | null = null;
let b: string | undefined = undefined;
```

### `strictNullChecks` (ligado por padrão em projetos modernos)
Com ele ativo, `null` e `undefined` **não entram em qualquer tipo** automaticamente:
```typescript
// strictNullChecks ON
let nome: string = null; // ❌ erro

let nome2: string | null = null; // ✅ você precisa permitir explicitamente
```
Isso te força a tratar valores ausentes — um dos maiores benefícios do TS. **Mantenha ligado sempre.**

## 🧠 Resumão visual
| Tipo | Uso típico |
|------|------------|
| `number` | qualquer número |
| `string` | texto |
| `boolean` | flag |
| `bigint` | inteiros gigantes (raro) |
| `symbol` | chave única (raro) |
| `T[]` / `Array<T>` | lista homogênea |
| `[A, B]` | tupla, posições fixas |
| `enum` | conjunto nomeado (prefira união) |
| `"a" \| "b"` | união de literais |
| `any` | EVITE |
| `unknown` | tipo desconhecido seguro |
| `void` | função sem retorno |
| `never` | função que nunca retorna |
| `null` / `undefined` | ausência (com `strictNullChecks`) |

## 🚦 Próximos passos
1. Abra `pratica/main.ts` e rode com `npx tsx`.
2. Brinque com `unknown` — tente usar antes de checar, veja o TS chiar.
3. Encare o **desafio**: validador de formulário tipado.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `any` e `unknown`
- [ ] Sei quando usar tupla em vez de array
- [ ] Sei justificar por que muita gente prefere união de literais a enum
- [ ] Sei o que `void` e `never` significam
- [ ] Sei o que `strictNullChecks` faz

Próximo módulo: **Funções e Inferência** — assinaturas, opcionais, default, rest, overloads.
