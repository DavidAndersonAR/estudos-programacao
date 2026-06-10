# Módulo 06 — Classes em TypeScript

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Declarar classes com construtor, propriedades e métodos tipados
- Usar `public`, `private`, `protected` e `readonly` corretamente
- Escrever **parameter properties** (o atalho que economiza 80% do boilerplate)
- Criar `get`/`set` com validação
- Usar `static` para membros que pertencem à classe
- Definir `abstract class` e `abstract method` (contrato + base parcial)
- Implementar interfaces com `implements`
- Herdar com `extends` e chamar pai com `super(...)`
- Diferenciar `private` (só TS) de `#privateFields` (privado de verdade no JS)

## 🧐 Por que classes importam aqui?
JavaScript moderno (ES2015+) já tem `class`. O que o TS adiciona é o **sistema de tipos em cima**: modificadores de acesso, contratos via `interface`/`abstract`, parameter properties, etc.

**Angular é orientado a classes**: Component, Service, Pipe, Directive, Guard — tudo é classe decorada. Dominar classes em TS é o ponto de inflexão entre "saber TypeScript" e "estar pronto pra Angular".

## 🧱 Declaração básica

```typescript
class Pessoa {
    nome: string;
    idade: number;

    constructor(nome: string, idade: number) {
        this.nome = nome;
        this.idade = idade;
    }

    apresentar(): string {
        return `${this.nome}, ${this.idade} anos`;
    }
}

const p = new Pessoa("Ana", 30);
console.log(p.apresentar());
```

Repare:
- Declaração de propriedades **antes** do construtor (`nome: string;`)
- Construtor recebe valores e atribui com `this.x = x`
- Métodos parecem funções, mas sem a palavra `function`

## 🔒 Modificadores de acesso

| Modificador | Quem enxerga? |
|---|---|
| `public` (padrão) | Qualquer um |
| `protected` | A própria classe e subclasses |
| `private` | Só a própria classe |
| `readonly` | Pode ler, mas só escreve no construtor |

```typescript
class Conta {
    public titular: string;
    private saldo: number;
    protected agencia: string;
    readonly numero: number;

    constructor(titular: string, numero: number) {
        this.titular = titular;
        this.numero = numero;
        this.saldo = 0;
        this.agencia = "0001";
    }
}

const c = new Conta("Maria", 12345);
console.log(c.titular);   // ✅ public
// console.log(c.saldo);  // ❌ private
// c.numero = 99;         // ❌ readonly
```

⚠️ **Aviso importante**: `private` do TS só vale em **tempo de compilação**. No `.js` gerado, qualquer um consegue ler `objeto.saldo` em runtime. Pra privado real veja `#privateFields` mais abaixo.

## ⚡ Parameter properties — o atalho que muda tudo

Escrever propriedade + atribuição no construtor é repetitivo:

```typescript
// 😩 Verboso
class Produto {
    nome: string;
    preco: number;

    constructor(nome: string, preco: number) {
        this.nome = nome;
        this.preco = preco;
    }
}
```

TS permite **declarar e atribuir na assinatura do construtor**:

```typescript
// 😎 Conciso — parameter properties
class Produto {
    constructor(public nome: string, public preco: number) {}
}
```

As duas versões são equivalentes. A regra é simples: **se o parâmetro tiver um modificador (`public`, `private`, `protected`, `readonly`), ele vira propriedade automaticamente**.

```typescript
class Usuario {
    constructor(
        public readonly id: number,
        public nome: string,
        private senha: string
    ) {}
}
```

Esse padrão é o que você vai ver **em todo serviço Angular**:
```typescript
constructor(private http: HttpClient, private auth: AuthService) {}
```

## 🎛️ Getters e setters

Permitem que algo *pareça* propriedade, mas execute código (validação, formatação, cache).

```typescript
class Temperatura {
    private _celsius: number = 0;

    get celsius(): number {
        return this._celsius;
    }

    set celsius(valor: number) {
        if (valor < -273.15) {
            throw new Error("Abaixo do zero absoluto!");
        }
        this._celsius = valor;
    }

    get fahrenheit(): number {
        return this._celsius * 9 / 5 + 32;
    }
}

const t = new Temperatura();
t.celsius = 25;            // chama o setter
console.log(t.celsius);    // chama o getter → 25
console.log(t.fahrenheit); // 77
// t.celsius = -300;       // 💥 erro: abaixo do zero absoluto
```

Convenção comum: campo interno com `_` (`_celsius`), getter/setter sem.

## 🧰 Membros `static`
Pertencem à **classe**, não à instância. Bom pra utilitários e constantes.

```typescript
class MathUtil {
    static readonly PI = 3.14159;

    static dobro(n: number): number {
        return n * 2;
    }
}

console.log(MathUtil.PI);          // 3.14159
console.log(MathUtil.dobro(5));    // 10
// new MathUtil().dobro(5);        // ❌ dobro não está na instância
```

## 🧬 Herança com `extends` e `super`

```typescript
class Animal {
    constructor(public nome: string) {}

    mover(): void {
        console.log(`${this.nome} se move.`);
    }
}

class Cachorro extends Animal {
    constructor(nome: string, public raca: string) {
        super(nome); // chama o construtor do pai — OBRIGATÓRIO
    }

    latir(): void {
        console.log(`${this.nome} (${this.raca}) faz au au!`);
    }

    // Sobrescreve (override) o método do pai
    mover(): void {
        super.mover();              // chama a versão do pai antes
        console.log("(correndo)");
    }
}

const rex = new Cachorro("Rex", "Labrador");
rex.mover();  // "Rex se move." → "(correndo)"
rex.latir();  // "Rex (Labrador) faz au au!"
```

Regras:
- Subclasse usa `extends Pai`
- Se o pai tem construtor com parâmetros, a sub é obrigada a chamar `super(...)` **antes** de usar `this`
- Pra acessar membro do pai dentro da sub: `super.metodo()`

## 🧱 Classes abstratas
Servem como **base parcial**: têm implementação compartilhada, mas obrigam as subclasses a implementar alguns métodos. **Não dá pra instanciar diretamente**.

```typescript
abstract class Forma {
    constructor(public nome: string) {}

    // Método abstrato: sem corpo, sub precisa implementar
    abstract area(): number;

    // Método concreto: compartilhado por todas as subclasses
    descrever(): string {
        return `${this.nome} tem área ${this.area().toFixed(2)}`;
    }
}

class Circulo extends Forma {
    constructor(public raio: number) {
        super("Círculo");
    }

    area(): number {
        return Math.PI * this.raio ** 2;
    }
}

// new Forma("X");  // ❌ Cannot create an instance of an abstract class
const c = new Circulo(5);
console.log(c.descrever()); // "Círculo tem área 78.54"
```

**Quando usar `abstract` vs `interface`?**
- `interface`: só contrato, zero código.
- `abstract class`: contrato + código compartilhado (campos, métodos prontos).

## 🤝 `implements` — classe ↔ interface

```typescript
interface Voador {
    altitude: number;
    voar(): void;
}

class Aviao implements Voador {
    altitude: number = 0;

    voar(): void {
        this.altitude = 10000;
        console.log(`Voando a ${this.altitude}m`);
    }
}
```

Se faltar algo, o TS reclama:
```typescript
class Pato implements Voador {
    // ❌ Class 'Pato' incorrectly implements interface 'Voador'.
    //    Property 'altitude' is missing
    voar(): void { /* ... */ }
}
```

Uma classe pode implementar **várias** interfaces: `class X implements A, B, C {}`.

## 🔐 `#privateFields` — privacidade DE VERDADE

`private` do TS é checado só pelo compilador. Já o `#campo` (sintaxe nativa do JS moderno) é **inacessível em runtime**:

```typescript
class Cofre {
    #segredo: string;  // privado real

    constructor(segredo: string) {
        this.#segredo = segredo;
    }

    revelar(senha: string): string {
        return senha === "1234" ? this.#segredo : "negado";
    }
}

const c = new Cofre("ouro");
console.log(c.revelar("1234"));
// console.log(c.#segredo); // ❌ erro de sintaxe — nem compila, nem roda
// (c as any).#segredo;     // ❌ idem — bypass não funciona
```

| Critério | `private` (TS) | `#campo` (JS) |
|---|---|---|
| Checagem | Compilador | Runtime |
| Bypass com `(obj as any)` | Funciona | Não funciona |
| Aparece em `Object.keys` | Sim | Não |
| Sintaxe | `private nome` | `#nome` |

**Regra prática**: no dia-a-dia Angular, `private` do TS basta. Use `#` quando privacidade for requisito de segurança ou pra evitar colisão de nomes em libs.

## 🚦 Próximos passos
1. Abra `pratica/main.ts` e rode com `npx tsx main.ts`.
2. Tente acessar uma propriedade `private` de fora — sinta o TS chiando.
3. Encare o **desafio**: sistema de personagens RPG com classes abstratas, herança e interface.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `public`, `private`, `protected` e `readonly`
- [ ] Sei escrever uma classe usando parameter properties no construtor
- [ ] Sei criar getter/setter com validação
- [ ] Sei quando usar `abstract class` em vez de `interface`
- [ ] Sei chamar `super(...)` no construtor de uma subclasse
- [ ] Sei a diferença entre `private` do TS e `#campo` do JS

Próximo módulo: **Generics** — funções e classes que funcionam com qualquer tipo, sem perder a tipagem.
