// Módulo 07 — Generics
// Prática: 7 exercícios resolvidos cobrindo função genérica, classe genérica,
// constraints, default type params, múltiplos params e inferência.
//
// Rode com: npx tsx main.ts

// Exercício 1: Função identidade <T>
// O "hello world" dos generics — devolve o que recebe, preservando o tipo.
function identidade<T>(valor: T): T {
    return valor;
}

function exercicio1(): void {
    const n = identidade(42);          // T inferido: number
    const s = identidade("texto");      // T inferido: string
    const b = identidade<boolean>(true); // T explícito: boolean

    console.log("identidade(42):", n, "| typeof:", typeof n);
    console.log("identidade('texto'):", s, "| typeof:", typeof s);
    console.log("identidade(true):", b, "| typeof:", typeof b);
}

// Exercício 2: primeiro<T> — função genérica em array
// Mostra o ganho: a mesma função serve pra qualquer tipo SEM perder tipagem.
function primeiro<T>(arr: T[]): T | undefined {
    return arr.length > 0 ? arr[0] : undefined;
}

function exercicio2(): void {
    const numeros = [10, 20, 30];
    const palavras = ["alfa", "beta", "gama"];
    const vazio: number[] = [];

    const n = primeiro(numeros);   // n: number | undefined
    const p = primeiro(palavras);  // p: string | undefined
    const v = primeiro(vazio);

    console.log("primeiro(numeros):", n);
    console.log("primeiro(palavras):", p?.toUpperCase()); // TS sabe que é string
    console.log("primeiro(vazio):", v);
}

// Exercício 3: Pair<A, B> — type com 2 parâmetros genéricos
// Modela um par de valores de tipos potencialmente diferentes.
type Pair<A, B> = {
    primeiro: A;
    segundo: B;
};

function criarPar<A, B>(a: A, b: B): Pair<A, B> {
    return { primeiro: a, segundo: b };
}

function exercicio3(): void {
    const p1: Pair<string, number> = { primeiro: "idade", segundo: 30 };
    const p2 = criarPar("ativo", true);    // Pair<string, boolean>
    const p3 = criarPar(1, [1, 2, 3]);     // Pair<number, number[]>

    console.log("p1:", p1);
    console.log("p2:", p2);
    console.log("p3:", p3);
}

// Exercício 4: classe Pilha<T> — estrutura de dados genérica
// LIFO (last in, first out). Funciona pra qualquer T.
class Pilha<T> {
    private itens: T[] = [];

    empilhar(item: T): void {
        this.itens.push(item);
    }

    desempilhar(): T | undefined {
        return this.itens.pop();
    }

    topo(): T | undefined {
        return this.itens[this.itens.length - 1];
    }

    tamanho(): number {
        return this.itens.length;
    }
}

function exercicio4(): void {
    const pNumeros = new Pilha<number>();
    pNumeros.empilhar(1);
    pNumeros.empilhar(2);
    pNumeros.empilhar(3);
    console.log("topo (números):", pNumeros.topo());       // 3
    console.log("desempilhar:", pNumeros.desempilhar());    // 3
    console.log("tamanho:", pNumeros.tamanho());            // 2

    const pTextos = new Pilha<string>();
    pTextos.empilhar("a");
    pTextos.empilhar("b");
    console.log("topo (textos):", pTextos.topo());          // "b"
    // pNumeros.empilhar("x"); // ❌ Argument of type 'string' is not assignable to 'number'
}

// Exercício 5: constraint <T extends { id: number }>
// buscarPorId só aceita arrays cujos itens TENHAM uma propriedade 'id: number'.
function buscarPorId<T extends { id: number }>(itens: T[], id: number): T | undefined {
    return itens.find(item => item.id === id);
}

function exercicio5(): void {
    const usuarios = [
        { id: 1, nome: "Ana",    email: "ana@x.com" },
        { id: 2, nome: "Bia",    email: "bia@x.com" },
        { id: 3, nome: "Carlos", email: "carlos@x.com" },
    ];

    const produtos = [
        { id: 100, sku: "ABC", preco: 19.9 },
        { id: 200, sku: "DEF", preco: 49.9 },
    ];

    const u = buscarPorId(usuarios, 2);
    const p = buscarPorId(produtos, 100);
    console.log("usuário 2:", u?.nome);      // TS sabe que 'nome' existe
    console.log("produto 100:", p?.sku);     // TS sabe que 'sku' existe

    // buscarPorId([{ nome: "x" }], 1); // ❌ Property 'id' is missing
}

// Exercício 6: default type param <T = number>
// Se o caller não especifica, T vira number automaticamente.
interface Contador<T = number> {
    valor: T;
    label: string;
}

function exercicio6(): void {
    const c1: Contador = { valor: 10, label: "cliques" };           // T = number (default)
    const c2: Contador<string> = { valor: "dez", label: "label" };  // T = string
    const c3: Contador<bigint> = { valor: 100n, label: "big" };     // T = bigint

    console.log("c1:", c1);
    console.log("c2:", c2);
    console.log("c3:", c3);
}

// Exercício 7: map<T, U>(arr, fn) — múltiplos generics + inferência
// Transforma um array de T em um array de U. O TS infere os dois!
function map<T, U>(arr: T[], fn: (item: T) => U): U[] {
    const resultado: U[] = [];
    for (const item of arr) {
        resultado.push(fn(item));
    }
    return resultado;
}

function exercicio7(): void {
    const numeros = [1, 2, 3, 4, 5];

    const dobrados = map(numeros, n => n * 2);              // T=number, U=number
    const textos   = map(numeros, n => `n=${n}`);            // T=number, U=string
    const pares    = map(numeros, n => ({ valor: n, par: n % 2 === 0 })); // T=number, U={valor,par}

    console.log("dobrados:", dobrados);
    console.log("textos:", textos);
    console.log("pares:", pares);
}

function main(): void {
    console.log("=== Exercício 1: identidade<T> ===");
    exercicio1();

    console.log("\n=== Exercício 2: primeiro<T> ===");
    exercicio2();

    console.log("\n=== Exercício 3: Pair<A, B> ===");
    exercicio3();

    console.log("\n=== Exercício 4: classe Pilha<T> ===");
    exercicio4();

    console.log("\n=== Exercício 5: constraint <T extends { id: number }> ===");
    exercicio5();

    console.log("\n=== Exercício 6: default <T = number> ===");
    exercicio6();

    console.log("\n=== Exercício 7: map<T, U> ===");
    exercicio7();
}

main();
