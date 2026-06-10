# Módulo 01 — Bem-vindo ao TypeScript

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que é TypeScript e por que ele existe
- Diferenciar JS de TS
- Compilar e rodar um arquivo `.ts` de duas formas (com `tsx` e com `tsc`)
- Reconhecer os erros de compilação mais comuns

## 🧐 O que é TypeScript?
TypeScript (TS) é um **superset** de JavaScript: tudo que é JS válido também é TS válido. A diferença é que TS adiciona um sistema de **tipos estáticos**, ou seja, você declara o tipo de cada variável, parâmetro e retorno.

Por que isso importa?
- **Pega bugs antes de rodar**: errou o nome de uma propriedade? O TS avisa.
- **Autocomplete melhor**: a IDE sabe os tipos, sugere com precisão.
- **Refatoração segura**: renomear, mover, mudar assinatura — o TS aponta tudo que quebra.
- **Documentação que não envelhece**: os tipos são a "documentação" das funções.

Quem usa: Microsoft (que criou), Google (Angular é TS), Slack, Airbnb, Asana, etc. **Angular é 100% TypeScript** — é por isso que vamos passar 8 módulos aqui antes de entrar no Angular.

## 📊 JS vs TS lado a lado

```javascript
// JavaScript — tudo permitido, erros só em runtime
function saudar(nome) {
    return "Olá, " + nome.toUpperCase();
}
saudar(42); // 💥 quebra em runtime: nome.toUpperCase is not a function
```

```typescript
// TypeScript — erro pego pelo compilador
function saudar(nome: string): string {
    return "Olá, " + nome.toUpperCase();
}
saudar(42); // ❌ Erro de compilação: Argument of type 'number' is not assignable to parameter of type 'string'
```

O TS te avisa **antes** do código rodar.

## ⚙️ Como o TS funciona
TS **não roda direto no Node nem no browser**. O fluxo é:
1. Você escreve `.ts`
2. O compilador `tsc` transforma em `.js`
3. O `.js` é o que roda

Hoje, ferramentas modernas (`tsx`, `vite`, `esbuild`, frameworks como Angular) **compilam automaticamente** sem você precisar pensar.

## 🚀 Rodando código TS

### Forma 1 — `tsx` (mais simples)
`tsx` é um runner que executa `.ts` direto. Nem precisa instalar:

```bash
npx tsx arquivo.ts
```

Da primeira vez, o npx baixa o tsx e cacheia. Depois é instantâneo.

### Forma 2 — `tsc` + node (clássica)
```bash
npx tsc arquivo.ts          # gera arquivo.js
node arquivo.js             # roda
```

### Forma 3 — `tsc` com config
Criar `tsconfig.json` com `target`, `module`, etc., aí rodar só `tsc` compila tudo do projeto. Vamos ver melhor no módulo 8.

## 🧱 Primeiro programa TS

```typescript
// hello.ts
const nome: string = "David";
const idade: number = 30;
const ativo: boolean = true;

console.log(`Olá, ${nome}! Você tem ${idade} anos e está ${ativo ? "ativo" : "inativo"}.`);
```

Rode com:
```bash
npx tsx hello.ts
```

## 💡 Sintaxe — diferenças visuais com JS
1. **Anotação de tipo após `:`**: `let x: number = 10`
2. **Anotação de retorno após parâmetros**: `function f(): string {}`
3. **Tipos podem ser opcionais (inferência)**: `let x = 10` — o TS infere `number`.

## 🔥 Conceito-chave: inferência de tipos
Você **não precisa** anotar tudo. O TS é esperto:

```typescript
let nome = "Maria";  // TS infere: string
let idade = 25;      // TS infere: number
let lista = [1, 2, 3]; // TS infere: number[]

nome = 42; // ❌ Erro — TS sabe que nome é string
```

**Regra de ouro**: anote tipos em **assinaturas públicas** (parâmetros, retornos, props de classe). Deixe a inferência fazer o resto.

## ❌ Os 3 erros mais comuns no início

### 1. `Cannot find name 'X'`
Esqueceu de importar ou typou errado.

### 2. `Type 'X' is not assignable to type 'Y'`
Atribuiu valor do tipo errado.

```typescript
let n: number = "três"; // ❌
```

### 3. `Property 'X' does not exist on type 'Y'`
Tentou acessar campo que o tipo não tem.

```typescript
const pessoa = { nome: "Ana" };
console.log(pessoa.idade); // ❌ Property 'idade' does not exist
```

## 🚦 Próximos passos
1. Abra `pratica/main.ts` e rode com `npx tsx`.
2. Mude alguma coisa — provoque erro de tipo de propósito pra ver o TS chiando.
3. Encare o **desafio**: hello world tipado com sua bio.

## ✅ Auto-verificação
- [ ] Sei explicar em uma frase o que TS adiciona ao JS
- [ ] Sei a diferença entre `tsx` e `tsc`
- [ ] Sei rodar um `.ts` no terminal
- [ ] Sei o que é "inferência de tipos"

Próximo módulo: **Tipos Básicos** — o catálogo completo do que dá pra anotar.
