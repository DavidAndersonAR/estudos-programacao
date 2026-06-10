// Módulo 05 — Funções em TypeScript
// Prática: anotação, opcional, default, rest, arrow, callback, overload, tipo função.
//
// Rode com: npx tsx main.ts

// Exercício 1: Função básica com parâmetros e retorno tipados
// Anote SEMPRE os parâmetros. O retorno pode ser inferido, mas anotar deixa o contrato claro.
function somar(a: number, b: number): number {
    return a + b;
}

function exercicio1(): void {
    console.log("2 + 3 =", somar(2, 3));
    // somar("2", 3); // ❌ Argument of type 'string' is not assignable...
}

// Exercício 2: Parâmetro opcional (?)
// O parâmetro pode não vir. Dentro da função o tipo é `string | undefined`.
function cumprimentar(nome: string, titulo?: string): string {
    if (titulo) return `${titulo} ${nome}`;
    return nome;
}

function exercicio2(): void {
    console.log(cumprimentar("Ana"));            // Ana
    console.log(cumprimentar("Ana", "Dra."));    // Dra. Ana
}

// Exercício 3: Valor default
// Se não passar, usa o default. O tipo dentro da função é só `number` (sem undefined).
function potencia(base: number, expoente: number = 2): number {
    return base ** expoente;
}

function exercicio3(): void {
    console.log("3^2 =", potencia(3));      // 9 (usa default)
    console.log("3^4 =", potencia(3, 4));   // 81
}

// Exercício 4: Rest parameters (...args)
// Coleta argumentos restantes num array. Tem que ser o ÚLTIMO parâmetro.
function somarTodos(...numeros: number[]): number {
    return numeros.reduce((acc, n) => acc + n, 0);
}

function exercicio4(): void {
    console.log("soma vazia:", somarTodos());              // 0
    console.log("soma de 1..5:", somarTodos(1, 2, 3, 4, 5)); // 15
}

// Exercício 5: Arrow function tipada
// Sintaxe enxuta, mesma ideia de anotação.
const dobrar = (n: number): number => n * 2;
const concatenar = (a: string, b: string): string => `${a} ${b}`;

function exercicio5(): void {
    console.log("dobro de 7:", dobrar(7));                   // 14
    console.log(concatenar("TypeScript", "rocks"));          // TypeScript rocks
}

// Exercício 6: Função recebendo função (callback tipado)
// O segundo parâmetro `fn` é uma função (number) => number.
function aplicar(n: number, fn: (x: number) => number): number {
    return fn(n);
}

function exercicio6(): void {
    console.log("aplicar dobrar em 5:", aplicar(5, dobrar));     // 10
    console.log("aplicar inline em 4:", aplicar(4, (x) => x * x)); // 16 (x é inferido como number)
}

// Exercício 7: Overload signatures
// Múltiplas assinaturas + UMA implementação compatível com todas.
// O chamador só vê as assinaturas — a implementação fica "escondida".
function processar(valor: string): number;
function processar(valor: number): string;
function processar(valor: string | number): string | number {
    if (typeof valor === "string") return valor.length;
    return valor.toString();
}

function exercicio7(): void {
    const a = processar("hello"); // a: number
    const b = processar(42);      // b: string
    console.log(`processar("hello") = ${a} (${typeof a})`);  // 5 (number)
    console.log(`processar(42) = "${b}" (${typeof b})`);      // "42" (string)
}

// Exercício 8: Tipo função armazenado em variável
// Declaramos o TIPO de uma variável que vai guardar uma função.
type Operacao = (a: number, b: number) => number;

const adicao: Operacao = (a, b) => a + b;       // a, b inferidos como number
const multiplicacao: Operacao = (a, b) => a * b;
const subtracao: Operacao = (a, b) => a - b;

function executar(op: Operacao, x: number, y: number): number {
    return op(x, y);
}

function exercicio8(): void {
    console.log("adicao(2, 3) =", executar(adicao, 2, 3));            // 5
    console.log("multiplicacao(2, 3) =", executar(multiplicacao, 2, 3)); // 6
    console.log("subtracao(10, 4) =", executar(subtracao, 10, 4));     // 6
}

function main(): void {
    console.log("=== Exercício 1: Função básica tipada ===");
    exercicio1();

    console.log("\n=== Exercício 2: Parâmetro opcional ===");
    exercicio2();

    console.log("\n=== Exercício 3: Valor default ===");
    exercicio3();

    console.log("\n=== Exercício 4: Rest parameters ===");
    exercicio4();

    console.log("\n=== Exercício 5: Arrow function tipada ===");
    exercicio5();

    console.log("\n=== Exercício 6: Callback tipado ===");
    exercicio6();

    console.log("\n=== Exercício 7: Overload signatures ===");
    exercicio7();

    console.log("\n=== Exercício 8: Tipo função em variável ===");
    exercicio8();
}

main();
