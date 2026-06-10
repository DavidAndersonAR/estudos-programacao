// Módulo 03 — Tipos Avançados
// Prática: union, intersection, literal types, narrowing, type guards,
// discriminated unions, exhaustive check com never, as const.
//
// Rode com: npx tsx main.ts

// Exercício 1: Union + narrowing por typeof
// O parâmetro aceita string OU number. Dentro da função usamos `typeof`
// para o TS "afunilar" o tipo e liberar métodos específicos.
function formatarId(id: string | number): string {
    if (typeof id === "string") {
        return `ID-${id.toUpperCase()}`; // TS sabe: id é string aqui
    }
    return `ID-${id.toFixed(0)}`;        // TS sabe: id é number aqui
}

function exercicio1(): void {
    console.log(formatarId("abc"));
    console.log(formatarId(42));
    // formatarId(true); // ❌ boolean não é string nem number
}

// Exercício 2: Intersection — combinando dois tipos em um só
// Pessoa & Funcionario = um objeto que tem TUDO de pessoa E TUDO de funcionário.
type Pessoa = { nome: string; idade: number };
type Funcionario = { cargo: string; salario: number };
type Colaborador = Pessoa & Funcionario;

function exercicio2(): void {
    const c: Colaborador = {
        nome: "Ana",
        idade: 28,
        cargo: "Dev Frontend",
        salario: 7500,
    };
    console.log(`${c.nome} (${c.idade}) — ${c.cargo}, R$ ${c.salario}`);
}

// Exercício 3: Literal types — restringir aos valores permitidos
// HttpMethod só aceita exatamente um destes 4 strings.
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

function request(url: string, method: HttpMethod): string {
    return `[${method}] ${url}`;
}

function exercicio3(): void {
    console.log(request("/api/users", "GET"));
    console.log(request("/api/users", "POST"));
    // console.log(request("/api/users", "PATCH")); // ❌ literal não permitido
}

// Exercício 4: Type guard customizado (x is T)
// Quando typeof/in não dão conta, criamos uma função que ensina o TS
// a estreitar o tipo. A assinatura mágica: `parametro is Tipo`.
type Email = { tipo: "email"; valor: string };
type Telefone = { tipo: "telefone"; valor: string };
type Contato = Email | Telefone;

function isEmail(c: Contato): c is Email {
    return c.tipo === "email";
}

function exercicio4(): void {
    const lista: Contato[] = [
        { tipo: "email", valor: "ana@x.com" },
        { tipo: "telefone", valor: "11-99999" },
        { tipo: "email", valor: "bob@y.com" },
    ];

    // .filter com type guard: o TS sabe que `emails` é Email[]
    const emails = lista.filter(isEmail);
    emails.forEach((e) => console.log(`Email: ${e.valor}`));
}

// Exercício 5: Discriminated union — Cachorro | Gato com campo `kind`
// Cada variante tem um literal único em `kind`. Dentro do switch o TS
// estreita automaticamente para o tipo certo.
type Cachorro = { kind: "cachorro"; nome: string; raca: string };
type Gato     = { kind: "gato"; nome: string; vidas: number };
type Pet = Cachorro | Gato;

function descreverPet(p: Pet): string {
    if (p.kind === "cachorro") {
        return `${p.nome} é um cachorro da raça ${p.raca}`; // TS conhece `raca`
    }
    return `${p.nome} é um gato com ${p.vidas} vidas`;       // TS conhece `vidas`
}

function exercicio5(): void {
    const rex: Pet = { kind: "cachorro", nome: "Rex", raca: "Labrador" };
    const mia: Pet = { kind: "gato", nome: "Mia", vidas: 9 };
    console.log(descreverPet(rex));
    console.log(descreverPet(mia));
}

// Exercício 6: Exhaustive check com `never`
// Garantia em tempo de compilação: se um novo `kind` for adicionado à union
// e esquecermos de tratar, o TS quebra a build. `never` é o tipo "impossível".
type Circulo  = { kind: "circulo"; raio: number };
type Quadrado = { kind: "quadrado"; lado: number };
type Forma = Circulo | Quadrado;

function area(f: Forma): number {
    switch (f.kind) {
        case "circulo":
            return Math.PI * f.raio ** 2;
        case "quadrado":
            return f.lado * f.lado;
        default:
            // Se um dia adicionarmos `type Triangulo = { kind: "triangulo"; ... }`
            // à union Forma, esta linha vai dar erro de compilação até tratarmos.
            const _exhaustive: never = f;
            throw new Error(`Forma não tratada: ${_exhaustive}`);
    }
}

function exercicio6(): void {
    console.log("Área círculo r=3:", area({ kind: "circulo", raio: 3 }).toFixed(2));
    console.log("Área quadrado l=4:", area({ kind: "quadrado", lado: 4 }));
}

// Exercício 7: as const — literal narrowing e readonly
// Sem `as const` o TS infere tipos largos (string, number).
// Com `as const` cada valor vira literal exato e tudo fica readonly.
function exercicio7(): void {
    // Sem as const: method é inferido como string
    const configSolto = { method: "GET", retries: 3 };
    configSolto.method = "POST"; // permitido — é só string

    // Com as const: method vira literal "GET" e congela
    const configTravado = { method: "GET", retries: 3 } as const;
    // configTravado.method = "POST"; // ❌ Cannot assign to readonly

    console.log("Solto:", configSolto);
    console.log("Travado:", configTravado);

    // Bônus: gerar union type a partir de array as const
    const ROLES = ["admin", "user", "guest"] as const;
    type Role = typeof ROLES[number]; // "admin" | "user" | "guest"
    const meuRole: Role = "admin";
    // const x: Role = "outro"; // ❌
    console.log("Role:", meuRole, "| Todos:", ROLES.join(", "));
}

function main(): void {
    console.log("=== Exercício 1: Union + typeof narrowing ===");
    exercicio1();

    console.log("\n=== Exercício 2: Intersection ===");
    exercicio2();

    console.log("\n=== Exercício 3: Literal types (HttpMethod) ===");
    exercicio3();

    console.log("\n=== Exercício 4: Type guard customizado ===");
    exercicio4();

    console.log("\n=== Exercício 5: Discriminated union (Pet) ===");
    exercicio5();

    console.log("\n=== Exercício 6: Exhaustive check com never ===");
    exercicio6();

    console.log("\n=== Exercício 7: as const ===");
    exercicio7();
}

main();
