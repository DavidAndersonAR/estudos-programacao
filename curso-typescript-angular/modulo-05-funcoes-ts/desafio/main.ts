// 🎯 DESAFIO DO MÓDULO 05 — Biblioteca de Utilitários Tipados
//
// Objetivo:
// Construa uma mini biblioteca com 4 funções utilitárias bem tipadas,
// usando tudo que viu no módulo (anotação, opcional, default, genéricos,
// função como tipo, composição).
//
// Funções a implementar:
//
// 1) capitalizar(s: string): string
//    - Recebe uma string e devolve com a 1ª letra maiúscula, resto minúsculo.
//    - Exemplo: capitalizar("oLÁ") → "Olá"
//
// 2) formatarMoeda(n: number, moeda?: string): string
//    - Formata um número como moeda. Default da moeda: "BRL".
//    - Use Intl.NumberFormat("pt-BR", { style: "currency", currency: moeda }).
//    - Exemplo: formatarMoeda(1234.5) → "R$ 1.234,50"
//
// 3) agruparPor<T>(items: T[], chave: (i: T) => string): Record<string, T[]>
//    - Agrupa um array em um objeto, usando a função `chave` pra decidir o grupo.
//    - Exemplo:
//        const pessoas = [{nome:"Ana",cidade:"SP"}, {nome:"Bia",cidade:"RJ"}, {nome:"Caio",cidade:"SP"}];
//        agruparPor(pessoas, p => p.cidade)
//        → { SP: [Ana, Caio], RJ: [Bia] }
//
// 4) compor<A,B,C>(f: (b: B) => C, g: (a: A) => B): (a: A) => C
//    - Composição de funções: compor(f, g)(x) = f(g(x))
//    - Devolve uma nova função.
//    - Exemplo:
//        const dobrar = (n: number) => n * 2;
//        const paraString = (n: number) => `valor=${n}`;
//        const pipeline = compor(paraString, dobrar);
//        pipeline(5) → "valor=10"
//
// Requisitos:
// - Todas as funções devem ter PARÂMETROS e RETORNO tipados.
// - `agruparPor` e `compor` devem usar genéricos.
// - Demonstre as 4 funções dentro de main(), uma de cada vez.
//
// 💡 Dicas:
//   - `s[0].toUpperCase() + s.slice(1).toLowerCase()` resolve `capitalizar`.
//   - Em `agruparPor`, inicialize o array se ainda não existe: `acc[k] ??= []`.
//   - Em `compor`, o retorno É uma função: `return (a) => f(g(a));`
//
// Rode: npx tsx main.ts

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

function capitalizar(s: string): string {
    // TODO
    return s;
}

function formatarMoeda(n: number, moeda?: string): string {
    // TODO
    return String(n);
}

function agruparPor<T>(items: T[], chave: (i: T) => string): Record<string, T[]> {
    // TODO
    return {};
}

function compor<A, B, C>(f: (b: B) => C, g: (a: A) => B): (a: A) => C {
    // TODO
    return (a: A) => f(g(a));
}

function main(): void {
    console.log("(implemente as 4 funções e demonstre cada uma aqui)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// 1) capitalizar — primeira letra maiúscula, resto minúsculo.
function capitalizar(s: string): string {
    if (s.length === 0) return s;
    return s[0].toUpperCase() + s.slice(1).toLowerCase();
}

// 2) formatarMoeda — default "BRL", usa Intl.NumberFormat (já vem com Node).
function formatarMoeda(n: number, moeda: string = "BRL"): string {
    return new Intl.NumberFormat("pt-BR", {
        style: "currency",
        currency: moeda,
    }).format(n);
}

// 3) agruparPor — genérico em T. A função `chave` extrai o "bucket".
function agruparPor<T>(items: T[], chave: (i: T) => string): Record<string, T[]> {
    const resultado: Record<string, T[]> = {};
    for (const item of items) {
        const k = chave(item);
        // `??=` cria o array se ainda não existir
        resultado[k] ??= [];
        resultado[k].push(item);
    }
    return resultado;
}

// 4) compor — composição f ∘ g. Recebe duas funções, devolve uma nova função.
function compor<A, B, C>(f: (b: B) => C, g: (a: A) => B): (a: A) => C {
    return (a: A) => f(g(a));
}

function main(): void {
    console.log("=== 1) capitalizar ===");
    console.log(capitalizar("oLÁ mundo"));     // "Olá mundo"
    console.log(capitalizar("TYPESCRIPT"));    // "Typescript"
    console.log(capitalizar(""));              // ""

    console.log("\n=== 2) formatarMoeda ===");
    console.log(formatarMoeda(1234.5));            // R$ 1.234,50
    console.log(formatarMoeda(99.9, "USD"));       // US$ 99,90
    console.log(formatarMoeda(1000000, "EUR"));    // € 1.000.000,00

    console.log("\n=== 3) agruparPor ===");
    type Pessoa = { nome: string; cidade: string };
    const pessoas: Pessoa[] = [
        { nome: "Ana",   cidade: "SP" },
        { nome: "Bia",   cidade: "RJ" },
        { nome: "Caio",  cidade: "SP" },
        { nome: "Davi",  cidade: "MG" },
        { nome: "Elis",  cidade: "RJ" },
    ];
    const porCidade = agruparPor(pessoas, (p) => p.cidade);
    console.log(porCidade);
    // { SP: [Ana, Caio], RJ: [Bia, Elis], MG: [Davi] }

    // Também funciona com números — genérico em ação:
    const numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    const porParidade = agruparPor(numeros, (n) => (n % 2 === 0 ? "par" : "impar"));
    console.log(porParidade);
    // { impar: [1,3,5,7,9], par: [2,4,6,8,10] }

    console.log("\n=== 4) compor ===");
    const dobrar = (n: number): number => n * 2;
    const paraString = (n: number): string => `valor=${n}`;

    // compor(paraString, dobrar)(5) = paraString(dobrar(5)) = paraString(10) = "valor=10"
    const pipeline = compor(paraString, dobrar);
    console.log(pipeline(5));   // "valor=10"
    console.log(pipeline(21));  // "valor=42"

    // Combinando tudo: capitalizar ∘ (trim de espaços)
    const trim = (s: string): string => s.trim();
    const limpar = compor(capitalizar, trim);
    console.log(limpar("   hELLO world   "));  // "Hello world"
}

main();
*/
