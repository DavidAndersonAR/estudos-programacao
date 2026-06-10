// Módulo 01 — Bem-vindo ao TypeScript
// Prática: primeiras anotações de tipo, inferência, template literals.
//
// Rode com: npx tsx main.ts

// Exercício 1: Hello World tipado
// Anotação explícita de tipo após o nome da variável.
function exercicio1(): void {
    const nome: string = "David";
    console.log(`Olá, ${nome}!`);
}

// Exercício 2: Tipos básicos
// number, string, boolean — os 3 mais comuns.
function exercicio2(): void {
    const idade: number = 30;
    const nome: string = "Ana";
    const ativo: boolean = true;

    console.log(`${nome}, ${idade} anos, ativo: ${ativo}`);
}

// Exercício 3: Inferência de tipos
// Você NÃO precisa anotar quando o TS consegue deduzir.
function exercicio3(): void {
    const numero = 42;          // TS infere: number
    const texto = "Olá";        // TS infere: string
    const lista = [1, 2, 3];    // TS infere: number[]
    const ativo = true;         // TS infere: boolean

    console.log(typeof numero, typeof texto, typeof ativo, Array.isArray(lista));
    // Tentar mudar o tipo dá erro:
    // numero = "outro";  // ❌ Type 'string' is not assignable to type 'number'
}

// Exercício 4: Função com parâmetros e retorno tipados
// Boa prática: SEMPRE anotar parâmetros e retorno em funções públicas.
function somar(a: number, b: number): number {
    return a + b;
}

function exercicio4(): void {
    const resultado = somar(2, 3); // resultado é number (inferido do retorno)
    console.log("Soma:", resultado);
    // somar("2", 3); // ❌ Erro de compilação
}

// Exercício 5: Template literals
// Substitui concatenação com + e é mais legível.
function exercicio5(): void {
    const nome = "Carlos";
    const ano = 2026;
    const mensagem = `Hoje é ${nome}, ano ${ano}. Em ${ano + 1} faremos mais.`;
    console.log(mensagem);
}

// Exercício 6: Array tipado
// Duas sintaxes equivalentes: T[] e Array<T>
function exercicio6(): void {
    const numeros: number[] = [1, 2, 3, 4, 5];
    const palavras: Array<string> = ["a", "b", "c"];

    // Soma dos números com reduce (já tipado pelo TS)
    const total = numeros.reduce((acc, n) => acc + n, 0);
    console.log("Total:", total, "| Palavras:", palavras.length);
}

function main(): void {
    console.log("=== Exercício 1: Hello World tipado ===");
    exercicio1();

    console.log("\n=== Exercício 2: Tipos básicos ===");
    exercicio2();

    console.log("\n=== Exercício 3: Inferência ===");
    exercicio3();

    console.log("\n=== Exercício 4: Função tipada ===");
    exercicio4();

    console.log("\n=== Exercício 5: Template literals ===");
    exercicio5();

    console.log("\n=== Exercício 6: Array tipado ===");
    exercicio6();
}

main();
