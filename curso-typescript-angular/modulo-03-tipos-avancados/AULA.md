# Módulo 03 — Tipos Avançados

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Combinar tipos com **union** (`A | B`) e **intersection** (`A & B`)
- Restringir valores com **literal types** (`"GET" | "POST"`)
- Fazer **type narrowing** com `typeof`, `in` e `instanceof`
- Escrever **type guards** customizados (`x is T`)
- Modelar estados com **discriminated unions** e `switch` exaustivo usando `never`
- Travar literais com `as const`

## 🧩 Por que "tipos avançados"?
No módulo 2 você viu os tipos básicos (`string`, `number`, `boolean`, arrays, objetos). Eles resolvem 70% do dia a dia. Os outros 30% — APIs reais, estados de UI, formulários, respostas de fetch — exigem **modelar variação**: "isso pode ser X **ou** Y", "esse campo só aceita esses 4 valores", "se o status é erro, então tem mensagem". É exatamente isso que os tipos avançados fazem.

E, spoiler: o Angular usa isso o tempo todo (`HttpClient`, `Reactive Forms`, `Signals` com estados).

## 🔀 Union types — "isso OU aquilo"

Use `|` para dizer "o valor pode ser um destes tipos".

```typescript
let id: string | number;
id = "abc-123";  // ok
id = 42;         // ok
id = true;       // ❌ Type 'boolean' is not assignable
```

Útil quando uma função aceita múltiplos formatos:

```typescript
function formatarId(id: string | number): string {
    return `ID-${id}`;
}
```

Mas atenção: dentro da função, o TS **só deixa você usar o que é comum aos dois tipos**. Não dá pra chamar `.toUpperCase()` direto num `string | number` — porque número não tem isso. Pra isso existe o **narrowing**.

## 🎯 Type narrowing — afunilando o tipo

**Narrowing** é quando o TS, vendo um `if`, **estreita** o tipo da variável dentro daquele bloco.

### Com `typeof` (pra primitivos)

```typescript
function formatar(valor: string | number): string {
    if (typeof valor === "string") {
        return valor.toUpperCase(); // TS sabe: aqui valor é string
    }
    return valor.toFixed(2);        // aqui valor é number
}
```

### Com `in` (pra checar propriedade em objetos)

```typescript
type Peixe = { nadar: () => void };
type Passaro = { voar: () => void };

function mover(animal: Peixe | Passaro): void {
    if ("nadar" in animal) {
        animal.nadar();
    } else {
        animal.voar();
    }
}
```

### Com `instanceof` (pra classes)

```typescript
function tamanho(x: Date | string): number {
    if (x instanceof Date) {
        return x.getTime();
    }
    return x.length;
}
```

## 🛡️ Type guards customizados

Quando `typeof`/`in`/`instanceof` não resolvem, você cria uma **função de type guard**. A assinatura especial é `param is Tipo`:

```typescript
type Cachorro = { latir: () => void };
type Gato = { miar: () => void };

function isCachorro(a: Cachorro | Gato): a is Cachorro {
    return "latir" in a;
}

function falar(animal: Cachorro | Gato): void {
    if (isCachorro(animal)) {
        animal.latir(); // TS sabe: é Cachorro
    } else {
        animal.miar();  // TS sabe: é Gato
    }
}
```

O `: a is Cachorro` é a parte mágica — diz ao TS "se essa função retornar `true`, pode tratar `a` como `Cachorro`".

## ➕ Intersection types — "isso E aquilo"

Use `&` para **combinar** tipos. O resultado tem **todas** as propriedades dos dois.

```typescript
type Pessoa = { nome: string };
type Funcionario = { cargo: string; salario: number };

type Colaborador = Pessoa & Funcionario;

const c: Colaborador = {
    nome: "Ana",
    cargo: "Dev",
    salario: 5000,
};
```

Pense assim:
- `|` (union) = **menos** capacidade (só o que é comum)
- `&` (intersection) = **mais** capacidade (tudo somado)

## 📌 Literal types — valores específicos como tipo

Em vez de aceitar qualquer `string`, você restringe a **valores exatos**:

```typescript
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

function request(url: string, method: HttpMethod): void {
    console.log(`${method} ${url}`);
}

request("/api", "GET");     // ok
request("/api", "PATCH");   // ❌ não é um dos 4 permitidos
```

Funciona com números e booleanos também:

```typescript
type Dado = 1 | 2 | 3 | 4 | 5 | 6;
type Sim = true;
```

## 🎲 Discriminated unions — o padrão mais poderoso

É a **combinação** de union + literal type + narrowing. Você dá a cada variante um **campo discriminador** (geralmente `kind` ou `type`) com um literal único:

```typescript
type Quadrado = { kind: "quadrado"; lado: number };
type Circulo  = { kind: "circulo"; raio: number };
type Forma = Quadrado | Circulo;

function area(f: Forma): number {
    switch (f.kind) {
        case "quadrado":
            return f.lado * f.lado;  // TS sabe: é Quadrado, tem `lado`
        case "circulo":
            return Math.PI * f.raio ** 2;
    }
}
```

O TS olha pra `f.kind` e **estreita o tipo automaticamente** dentro de cada `case`. Sem `if` aninhado, sem type guard manual.

## 🚫 Exhaustive check com `never`

`never` é o tipo "isso nunca deveria acontecer". Combine com `switch` pra garantir que você tratou **todos** os casos:

```typescript
function area(f: Forma): number {
    switch (f.kind) {
        case "quadrado": return f.lado * f.lado;
        case "circulo":  return Math.PI * f.raio ** 2;
        default:
            const _exhaustive: never = f;
            throw new Error(`Forma não tratada: ${_exhaustive}`);
    }
}
```

Se amanhã você adicionar `type Triangulo = { kind: "triangulo"; base: number; altura: number }` à union, o `default` vai dar **erro de compilação** porque `Triangulo` não é atribuível a `never`. O TS te força a tratar o novo caso.

Essa é uma das técnicas mais valiosas do TS pra código que escala.

## 🔒 `as const` — literal narrowing

Sem `as const`, o TS infere tipos **largos**:

```typescript
const config = {
    method: "GET",      // inferido: string
    timeout: 5000,      // inferido: number
};
// config.method = "POST"; // permitido (string)
```

Com `as const`, tudo vira **literal e readonly**:

```typescript
const config = {
    method: "GET",
    timeout: 5000,
} as const;
// config.method: "GET" (literal exato)
// config.method = "POST"; // ❌ Cannot assign to 'method' because readonly
```

Útil pra constantes, configs, e — principalmente — pra criar union types a partir de arrays:

```typescript
const ROLES = ["admin", "user", "guest"] as const;
type Role = typeof ROLES[number]; // "admin" | "user" | "guest"
```

## 💡 Quando usar o quê — guia rápido

| Situação | Ferramenta |
|---|---|
| Valor pode ser X ou Y | `X \| Y` (union) |
| Combinar capacidades de dois tipos | `X & Y` (intersection) |
| Restringir a valores exatos | literal types (`"a" \| "b"`) |
| Diferenciar dentro de função | narrowing (`typeof`, `in`, `instanceof`) |
| Diferenciar com lógica customizada | type guard (`x is T`) |
| Modelar estados (loading/ok/erro) | discriminated union |
| Garantir tratamento completo | `never` no `default` |
| Travar literais e congelar objeto | `as const` |

## 🚦 Próximos passos
1. Abra `pratica/main.ts` e rode os exercícios.
2. Encare o **desafio**: Sistema de Status com discriminated union — o padrão que você vai usar pra modelar **toda chamada HTTP** no Angular.

## ✅ Auto-verificação
- [ ] Sei diferenciar union (`|`) de intersection (`&`)
- [ ] Sei usar `typeof`, `in` e `instanceof` pra fazer narrowing
- [ ] Sei escrever um type guard `x is T`
- [ ] Sei modelar um estado com discriminated union + `kind`
- [ ] Sei usar `never` pro exhaustive check
- [ ] Sei o que `as const` faz e quando aplicar

Próximo módulo: **Interfaces e Type Aliases** — quando usar cada um e por quê.
