// 🎯 DESAFIO DO MÓDULO 02 — Validador de Formulário Simples
//
// Objetivo:
// Crie uma função `validarFormulario(dados)` que receba um objeto com:
//   - nome:           string  (não pode ser vazio nem ter menos de 3 caracteres)
//   - idade:          number  (precisa ser inteiro entre 0 e 120)
//   - email:          string  (precisa conter "@" e pelo menos um "." depois do @)
//   - aceitouTermos:  boolean (precisa ser `true`)
//
// A função deve retornar um `string[]`:
//   - vazio (`[]`) se tudo válido
//   - com uma mensagem por campo inválido caso contrário
//
// Saída esperada (estilo):
//
//   --- Form 1 ---
//   ✅ Formulário válido!
//
//   --- Form 2 ---
//   ❌ Erros encontrados:
//    - Nome precisa ter pelo menos 3 caracteres
//    - Idade precisa ser um inteiro entre 0 e 120
//    - Email inválido
//    - Você precisa aceitar os termos
//
// Requisitos:
// 1. Use uma `type` ou `interface` para o formato do formulário (vamos ver melhor no Módulo 4 — pode usar inline aqui).
// 2. O retorno DEVE ser `string[]`.
// 3. Use pelo menos uma checagem com `Number.isInteger`.
// 4. Trate cada campo de forma independente (acumula todos os erros, não para no primeiro).
//
// 💡 Dicas:
//   - `email.includes("@")` checa se tem arroba.
//   - `email.indexOf("@")` te dá a posição — útil pra verificar se tem `.` depois.
//   - `nome.trim().length` ignora espaços nas pontas.
//
// Rode: npx tsx main.ts

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

type Formulario = {
    nome: string;
    idade: number;
    email: string;
    aceitouTermos: boolean;
};

function validarFormulario(dados: Formulario): string[] {
    // TODO: implemente as 4 validações e devolva um array de erros (ou vazio).
    return ["(ainda não implementado)"];
}

function imprimirResultado(label: string, erros: string[]): void {
    console.log(`\n--- ${label} ---`);
    if (erros.length === 0) {
        console.log("✅ Formulário válido!");
    } else {
        console.log("❌ Erros encontrados:");
        for (const e of erros) {
            console.log(" - " + e);
        }
    }
}

function main(): void {
    const form1: Formulario = {
        nome: "David Anderson",
        idade: 30,
        email: "david@email.com",
        aceitouTermos: true
    };

    const form2: Formulario = {
        nome: "Jo",
        idade: 200,
        email: "emailruim",
        aceitouTermos: false
    };

    imprimirResultado("Form 1", validarFormulario(form1));
    imprimirResultado("Form 2", validarFormulario(form2));
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
type Formulario = {
    nome: string;
    idade: number;
    email: string;
    aceitouTermos: boolean;
};

function validarFormulario(dados: Formulario): string[] {
    const erros: string[] = [];

    // Nome
    if (dados.nome.trim().length < 3) {
        erros.push("Nome precisa ter pelo menos 3 caracteres");
    }

    // Idade — precisa ser inteiro entre 0 e 120
    if (!Number.isInteger(dados.idade) || dados.idade < 0 || dados.idade > 120) {
        erros.push("Idade precisa ser um inteiro entre 0 e 120");
    }

    // Email — tem "@" e tem "." depois do @
    const arroba = dados.email.indexOf("@");
    const ponto = dados.email.indexOf(".", arroba);
    if (arroba < 1 || ponto < arroba + 2) {
        erros.push("Email inválido");
    }

    // Termos
    if (dados.aceitouTermos !== true) {
        erros.push("Você precisa aceitar os termos");
    }

    return erros;
}

function imprimirResultado(label: string, erros: string[]): void {
    console.log(`\n--- ${label} ---`);
    if (erros.length === 0) {
        console.log("✅ Formulário válido!");
    } else {
        console.log("❌ Erros encontrados:");
        for (const e of erros) {
            console.log(" - " + e);
        }
    }
}

function main(): void {
    const form1: Formulario = {
        nome: "David Anderson",
        idade: 30,
        email: "david@email.com",
        aceitouTermos: true
    };

    const form2: Formulario = {
        nome: "Jo",
        idade: 200,
        email: "emailruim",
        aceitouTermos: false
    };

    imprimirResultado("Form 1", validarFormulario(form1));
    imprimirResultado("Form 2", validarFormulario(form2));
}

main();
*/
