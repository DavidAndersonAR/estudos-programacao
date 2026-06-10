# Módulo 04 — Interfaces e Type Aliases

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Modelar **objetos** com `interface` e `type`
- Saber **quando usar cada um** (sem dogma)
- Usar **campos opcionais** (`?`) e **readonly**
- Aplicar **index signatures** pra dicionários
- Estender interfaces (uma ou várias) e fazer **intersection** com `type`
- Declarar **métodos** em interface
- Tipar **funções** com `type`

## 🧩 O problema que interfaces resolvem
Sem interface, você acaba repetindo a "forma" do objeto em todo lugar:

```typescript
function imprimir(p: { nome: string; idade: number; email: string }): void { /* ... */ }
function salvar (p: { nome: string; idade: number; email: string }): void { /* ... */ }
```

Com interface, você dá um **nome** pra essa forma:

```typescript
interface Pessoa {
    nome: string;
    idade: number;
    email: string;
}

function imprimir(p: Pessoa): void { /* ... */ }
function salvar (p: Pessoa): void { /* ... */ }
```

Mudou a forma? Você muda em **um lugar só**.

## 🆚 `interface` vs `type` — qual usar?

Os dois servem pra dar nome a um tipo de objeto. Na prática:

```typescript
interface PessoaI {
    nome: string;
    idade: number;
}

type PessoaT = {
    nome: string;
    idade: number;
};
```

Os dois exemplos acima são **praticamente equivalentes**. Diferenças que importam:

| Recurso                          | `interface` | `type`         |
|----------------------------------|-------------|----------------|
| Modelar objeto                   | ✅          | ✅             |
| Estender (`extends` / `&`)       | `extends`   | intersection `&` |
| Declaration merging (junta declarações com mesmo nome) | ✅ | ❌ |
| Union (`A \| B`)                 | ❌          | ✅             |
| Tipar primitivos / tuplas / funções diretamente | ❌ | ✅ |

**Regra prática (estilo Angular)**:
- **Objeto / contrato de classe** → `interface`
- **União, alias de primitivo, tipo de função, tipo utilitário** → `type`

Não brigue com essa escolha — siga a regra acima e siga em frente.

## ❓ Campos opcionais — o `?`

Marcam que a propriedade **pode não existir**:

```typescript
interface Usuario {
    nome: string;
    email: string;
    telefone?: string;  // opcional
}

const u1: Usuario = { nome: "Ana", email: "a@x.com" };               // ✅
const u2: Usuario = { nome: "Bia", email: "b@x.com", telefone: "9" }; // ✅
```

Cuidado: o tipo de `telefone` vira `string | undefined`. Você precisa **checar** antes de usar:

```typescript
if (u1.telefone) {
    console.log(u1.telefone.length); // ok
}
```

## 🔒 `readonly` — não pode reatribuir

Marca propriedade que só pode ser definida na criação:

```typescript
interface Produto {
    readonly id: number;
    nome: string;
}

const p: Produto = { id: 1, nome: "Caneta" };
p.nome = "Lápis"; // ✅
p.id = 2;         // ❌ Cannot assign to 'id' because it is a read-only property
```

Bom pra IDs, timestamps de criação, qualquer coisa imutável por design.

## 📚 Index signature — dicionários

Quando você não sabe os nomes das chaves, mas sabe o tipo de **toda chave** e **todo valor**:

```typescript
interface Notas {
    [materia: string]: number;
}

const minhasNotas: Notas = {
    matematica: 9.5,
    portugues:  8.0,
    historia:   7.5,
};

minhasNotas.fisica = 10; // ✅ qualquer string vira chave válida
minhasNotas.quimica = "A"; // ❌ valor tem que ser number
```

O nome `materia` é só documentação — o que importa é o tipo da chave (`string`) e do valor (`number`).

## 🧬 Estendendo interfaces — `extends`

Reaproveita campos de outra interface:

```typescript
interface Animal {
    nome: string;
    idade: number;
}

interface Cachorro extends Animal {
    raca: string;
}

const rex: Cachorro = { nome: "Rex", idade: 4, raca: "Labrador" };
```

Pode estender **várias** ao mesmo tempo:

```typescript
interface Nadador  { nadar(): void; }
interface Voador   { voar(): void; }
interface Pato extends Animal, Nadador, Voador {
    grasnar(): void;
}
```

## ⛓️ Intersection com `type` — `&`

O equivalente de `extends` para `type`:

```typescript
type Animal2   = { nome: string };
type Cachorro2 = Animal2 & { raca: string };

const r: Cachorro2 = { nome: "Rex", raca: "Labrador" };
```

Igual em poder, sintaxe diferente.

## 🛠️ Métodos em interface

Você descreve a **assinatura**, sem corpo:

```typescript
interface Calculadora {
    somar(a: number, b: number): number;
    subtrair(a: number, b: number): number;
}

const calc: Calculadora = {
    somar:    (a, b) => a + b,
    subtrair: (a, b) => a - b,
};
```

No módulo de classes a gente vê `class X implements Calculadora` — esse é o uso clássico em Angular (services implementam interfaces).

## 🎯 Tipando funções com `type`

Em vez de repetir `(e: Event) => void` em todo lugar:

```typescript
type Handler = (e: Event) => void;

const onClick: Handler = (e) => console.log("clique em", e.type);
const onKey:   Handler = (e) => console.log("tecla", e.type);
```

Muito usado em Angular pra callbacks e em `EventEmitter`.

## 💡 Padrões de uso comuns

- Objeto de domínio (`Cliente`, `Produto`, `Pedido`) → **interface**
- DTO de resposta de API → **interface**
- Tipo de função (callback, handler) → **type**
- União de estados (`"loading" | "ok" | "erro"`) → **type**
- Combinação ad-hoc (`User & { token: string }`) → **type intersection**

## 🚦 Próximos passos
1. Faça `pratica/main.ts` — exercícios curtos pra cada conceito.
2. Encare o **desafio**: modelar um sistema de pedido (Cliente + Endereço + Itens + Pedido + total).

## ✅ Auto-verificação
- [ ] Sei a diferença prática entre `interface` e `type`
- [ ] Sei usar `?` e `readonly`
- [ ] Sei criar um dicionário com index signature
- [ ] Sei estender interface (uma e várias) e fazer intersection com `type`
- [ ] Sei tipar uma função com `type`

Próximo módulo: **Classes e POO em TypeScript** — `class`, `implements`, modificadores de acesso.
