// 🎯 DESAFIO DO MÓDULO 01 — Sua Bio Tipada
//
// Objetivo:
// Crie um programa TypeScript que imprima sua bio formatada, com:
//   - Nome (string)
//   - Idade (number)
//   - Profissão (string)
//   - Email (string)
//   - Hobbies (array de strings)
//   - Em formação? (boolean)
//   - Uma função `apresentar()` que retorna uma string formatada
//
// Saída esperada (estilo):
//
//   ┌────────────────────────────────┐
//   │ David Anderson                 │
//   │ 30 anos · Programador          │
//   │ david@email.com                │
//   ├────────────────────────────────┤
//   │ Hobbies: ler, correr, código   │
//   │ Em formação: sim               │
//   └────────────────────────────────┘
//
// Requisitos:
// 1. Todas as variáveis devem ter tipo anotado OU inferido corretamente.
// 2. A função `apresentar()` deve declarar parâmetros e retorno tipados.
// 3. Use pelo menos 1 template literal `${...}`.
// 4. Tente provocar 1 erro de tipo de propósito (e depois corrija) só pra sentir o TS chiando.
//
// 💡 Dicas:
//   - `nome.padEnd(30)` deixa string com comprimento fixo (preenche com espaço).
//   - `hobbies.join(", ")` une array num texto separado por vírgula.
//
// Rode: npx tsx main.ts

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

function main(): void {
    // TODO: implemente sua bio aqui.
    console.log("(escreva sua bio tipada aqui)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
const nome: string = "David Anderson";
const idade: number = 30;
const profissao: string = "Programador em formação";
const email: string = "david@email.com";
const hobbies: string[] = ["ler", "correr", "código"];
const emFormacao: boolean = true;

function apresentar(nome: string, idade: number, profissao: string): string {
    return `${nome} | ${idade} anos · ${profissao}`;
}

function main(): void {
    const linha = "┌────────────────────────────────┐";
    const meio  = "├────────────────────────────────┤";
    const fim   = "└────────────────────────────────┘";

    console.log(linha);
    console.log(`│ ${nome.padEnd(30)} │`);
    console.log(`│ ${`${idade} anos · ${profissao}`.padEnd(30)} │`);
    console.log(`│ ${email.padEnd(30)} │`);
    console.log(meio);
    console.log(`│ Hobbies: ${hobbies.join(", ").padEnd(21)} │`);
    console.log(`│ Em formação: ${(emFormacao ? "sim" : "não").padEnd(17)} │`);
    console.log(fim);

    console.log("\nApresentação:", apresentar(nome, idade, profissao));
}

main();
*/
