# Módulo 08 — Utility Types + Decorators

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Usar os principais **utility types** do TS para derivar tipos a partir de outros (em vez de duplicar interfaces)
- Saber quando aplicar `Partial`, `Required`, `Readonly`, `Pick`, `Omit`, `Record`, `ReturnType`, `Parameters`, `Awaited`, `NonNullable`
- Entender o que é um **decorator** e por que ele aparece em todo lugar no Angular (`@Component`, `@Injectable`, `@Input`...)
- Escrever um decorator de classe e um decorator de método simples
- Configurar o `tsconfig.json` para decorators (Stage 3 nativo ou legacy)

## 🤔 Por que utility types existem?

Imagine que você tem uma `interface Usuario` com 10 campos. Aí precisa:
- Um tipo pra **criar** usuário (sem `id` que ainda não existe)
- Um tipo pra **atualizar** (todos os campos opcionais)
- Um tipo **público** (sem o campo `senha`)
- Um tipo **somente leitura** pra passar pra um componente que não pode editar

Sem utility types, você duplicaria a interface 4 vezes. Quando um campo mudar, você esqueceria de atualizar uma delas — e bug. Utility types **derivam** esses tipos automaticamente da interface original. Mudou a original? Os derivados se ajustam sozinhos.

Isso é **a base** de como o Angular gera DTOs, formulários reativos e estados de componente.

---

## 📦 Os utility types essenciais

### 1. `Partial<T>` — tudo opcional
Transforma todos os campos de `T` em opcionais (`?`).

```typescript
interface Usuario {
    id: number;
    nome: string;
    email: string;
}

// Equivalente a: { id?: number; nome?: string; email?: string }
type UsuarioUpdate = Partial<Usuario>;

function atualizar(id: number, dados: UsuarioUpdate) {
    // dados pode ter só { nome: "novo" } ou só { email: "x@x" } ou os dois
}

atualizar(1, { nome: "Ana" });  // ✅
atualizar(1, { email: "a@b" }); // ✅
atualizar(1, {});               // ✅ (todos opcionais)
```

**Quando usar**: PATCH de API, formulários parciais, configs com defaults.

---

### 2. `Required<T>` — tudo obrigatório
O oposto de `Partial`. Tira todos os `?`.

```typescript
interface Config {
    host?: string;
    porta?: number;
    timeout?: number;
}

type ConfigCompleta = Required<Config>;
// { host: string; porta: number; timeout: number }

const padrao: ConfigCompleta = {
    host: "localhost",
    porta: 3000,
    timeout: 5000
}; // se faltar 1 campo, erro
```

**Quando usar**: garantir que um objeto de defaults tenha **todos** os campos preenchidos.

---

### 3. `Readonly<T>` — congelado
Todos os campos viram `readonly` — não dá pra reatribuir.

```typescript
interface Pessoa {
    nome: string;
    idade: number;
}

const ana: Readonly<Pessoa> = { nome: "Ana", idade: 30 };
ana.nome = "Maria"; // ❌ Cannot assign to 'nome' because it is a read-only property
```

**Quando usar**: parâmetros de função que não devem ser mutados, estado imutável (Redux/NgRx).

---

### 4. `Pick<T, K>` — escolhe campos
Cria um tipo só com os campos `K` de `T`.

```typescript
interface Usuario {
    id: number;
    nome: string;
    email: string;
    senha: string;
    createdAt: Date;
}

type UsuarioResumo = Pick<Usuario, "id" | "nome">;
// { id: number; nome: string }

const lista: UsuarioResumo[] = [{ id: 1, nome: "Ana" }];
```

**Quando usar**: DTOs de leitura, "view models" simplificados, tabelas que mostram só algumas colunas.

---

### 5. `Omit<T, K>` — remove campos
O oposto de `Pick`. Cria um tipo com todos os campos **exceto** `K`.

```typescript
interface Usuario {
    id: number;
    nome: string;
    senha: string;
    createdAt: Date;
}

type UsuarioPublico = Omit<Usuario, "senha">;
// { id; nome; createdAt } — sem senha

type UsuarioCreate = Omit<Usuario, "id" | "createdAt">;
// { nome; senha } — campos que o backend gera ficam de fora
```

**Quando usar**: DTOs de criação (sem `id`), responses públicas (sem dados sensíveis).

---

### 6. `Record<K, V>` — mapa tipado
Cria um objeto onde as chaves são do tipo `K` e os valores do tipo `V`.

```typescript
type StatusHTTP = "ok" | "erro" | "pendente";

const mensagens: Record<StatusHTTP, string> = {
    ok: "Sucesso!",
    erro: "Algo deu errado",
    pendente: "Aguardando..."
};

// Versão mais "dicionário":
type UsuariosPorId = Record<number, { nome: string }>;
const cache: UsuariosPorId = {
    1: { nome: "Ana" },
    2: { nome: "Bia" }
};
```

**Quando usar**: dicionários, mapas de tradução, caches indexados por id, traduzir enum em algo.

---

### 7. `ReturnType<F>` — pega o tipo de retorno
Extrai o tipo de retorno de uma função.

```typescript
function criarUsuario(nome: string) {
    return { id: 1, nome, ativo: true };
}

type Usuario = ReturnType<typeof criarUsuario>;
// { id: number; nome: string; ativo: boolean }

const u: Usuario = criarUsuario("Ana"); // já tipado!
```

**Quando usar**: você tem uma função (geralmente factory ou de API) e quer o tipo dela sem redigitar.

---

### 8. `Parameters<F>` — pega os tipos dos parâmetros
Retorna uma **tupla** com os tipos dos parâmetros da função.

```typescript
function cadastrar(nome: string, idade: number, ativo: boolean) {
    return { nome, idade, ativo };
}

type ArgsCadastrar = Parameters<typeof cadastrar>;
// [string, number, boolean]

const args: ArgsCadastrar = ["Ana", 30, true];
cadastrar(...args); // ✅
```

**Quando usar**: wrappers/proxies que precisam aceitar os mesmos args de outra função.

---

### 9. `Awaited<P>` — desembrulha Promise
Pega o tipo "de dentro" de uma `Promise`.

```typescript
async function buscarUsuario(): Promise<{ id: number; nome: string }> {
    return { id: 1, nome: "Ana" };
}

type Resultado = Awaited<ReturnType<typeof buscarUsuario>>;
// { id: number; nome: string } — sem o Promise<>
```

**Quando usar**: funções async — pegar o tipo do **valor resolvido**, não da promise.

---

### 10. `NonNullable<T>` — remove null e undefined
Filtra `null` e `undefined` de um tipo união.

```typescript
type Talvez = string | null | undefined;
type Certeza = NonNullable<Talvez>;
// string

function processar(valor: string | null) {
    if (valor === null) return;
    const x: NonNullable<typeof valor> = valor; // string
}
```

**Quando usar**: depois de checar com `if`, refinar tipos vindos de APIs frouxas.

---

## 🎀 Decorators — o "@algo" do Angular

Você já deve ter visto código Angular com `@Component`, `@Injectable`, `@Input`. Esses `@` são **decorators**: funções que **modificam ou anotam** classes, métodos, propriedades.

### Decorator de classe (Stage 3, TS 5+)

```typescript
function Logado<T extends new (...args: any[]) => any>(Construtor: T, _ctx: ClassDecoratorContext) {
    console.log(`[Logado] Classe ${Construtor.name} foi registrada`);
    return Construtor;
}

@Logado
class Servico {
    nome = "MeuServico";
}

// Ao carregar o arquivo: "[Logado] Classe Servico foi registrada"
```

O decorator roda **na declaração** da classe — não quando você cria instância. É assim que o Angular descobre quais classes são `@Component`.

### Decorator de método

```typescript
function LogChamada(_alvo: any, ctx: ClassMethodDecoratorContext) {
    const nomeMetodo = String(ctx.name);
    return function (this: any, ...args: any[]) {
        console.log(`[chamou ${nomeMetodo}] args:`, args);
        const resultado = (ctx as any).access?.get(this)?.apply(this, args);
        return resultado;
    };
}

// Forma mais simples e prática:
function Log(metodoOriginal: Function, ctx: ClassMethodDecoratorContext) {
    return function (this: any, ...args: any[]) {
        console.log(`> ${String(ctx.name)}(${args.join(", ")})`);
        const r = metodoOriginal.call(this, ...args);
        console.log(`< retornou: ${r}`);
        return r;
    };
}

class Calc {
    @Log
    somar(a: number, b: number): number {
        return a + b;
    }
}

new Calc().somar(2, 3);
// > somar(2, 3)
// < retornou: 5
```

Útil para: logging, métricas, cache, validação de permissão, transações — tudo "transversal" que você não quer poluir o corpo do método com.

### ⚙️ tsconfig.json para decorators

Há **dois sabores**:

**1. Stage 3 (nativo, recomendado em TS 5.0+)** — funciona sem flag extra:
```json
{
    "compilerOptions": {
        "target": "ES2022",
        "module": "ES2022",
        "strict": true
    }
}
```

**2. Legacy (decorators "experimentais", usado pelo Angular ainda)**:
```json
{
    "compilerOptions": {
        "target": "ES2022",
        "experimentalDecorators": true,
        "emitDecoratorMetadata": true
    }
}
```

Angular hoje (v17+) ainda usa o **legacy** porque depende de `emitDecoratorMetadata` para a injeção de dependência. Quando você for criar o projeto Angular, o `ng new` já põe isso pronto.

> 💡 Para os exemplos do Módulo 8 vamos focar no **Stage 3** (rodando com `tsx`), porque é o que o TS puro suporta sem mágica. Os princípios são os mesmos.

---

## 🧠 Regra de ouro
- **Nunca duplique tipos**: se você se pega digitando a mesma interface "quase igual" duas vezes, use um utility type.
- Comece com `Partial`, `Pick`, `Omit` — esses três cobrem 80% dos casos no dia-a-dia.
- Decorators só fazem sentido quando há um padrão **repetitivo** em vários métodos/classes. Pra um caso isolado, é overkill.

## 🚦 Próximos passos
1. Abra `pratica/main.ts` — 8 exercícios resolvidos cobrindo cada utility type + decorator.
2. Faça o **desafio**: refatoração de uma `interface Usuario` usando 4 utility types diferentes.
3. Esse é o último módulo de TS puro — depois entramos em **Angular**.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `Pick` e `Omit`
- [ ] Sei quando usar `Partial` (PATCH / update)
- [ ] Sei criar um `Record<Chave, Valor>`
- [ ] Sei extrair tipo de retorno com `ReturnType`
- [ ] Entendi o que um decorator de método faz
- [ ] Sei diferenciar decorators Stage 3 vs legacy (experimental)

Próximo módulo: **Angular — primeiros passos**. Vamos finalmente criar um projeto com `ng new` e ver os decorators na prática.
