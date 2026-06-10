// 🎯 DESAFIO DO MÓDULO 03 — Sistema de Status com Discriminated Union
//
// Contexto:
// Toda chamada HTTP (e quase todo estado de UI) passa por três fases:
//   1. carregando — pediu, esperando resposta
//   2. sucesso    — chegou! Tem os dados.
//   3. erro       — falhou, tem uma mensagem do que deu ruim.
//
// O jeito ERRADO de modelar isso (que aparece em código JS legado):
//
//   { carregando: boolean, dados?: T, erro?: string }
//
// O problema: nada impede `{ carregando: true, dados: [...], erro: "boom" }`,
// que é um estado IMPOSSÍVEL. O TS vai te obrigar a checar tudo o tempo todo.
//
// O jeito CERTO: **discriminated union**. Cada estado é uma forma diferente,
// com um campo `status` que discrimina. Estados impossíveis somem.
//
// Objetivo:
// 1. Defina um tipo genérico `Resultado<T>` com 3 variantes:
//      - { status: "carregando" }
//      - { status: "sucesso",   dados: T }
//      - { status: "erro",      mensagem: string }
//
// 2. Implemente `renderizar<T>(r: Resultado<T>): string` que usa switch
//    exaustivo. Inclua um `default` com `never` pro exhaustive check.
//
// 3. Simule os 3 estados (carregando, sucesso com uma lista de usuários,
//    erro com mensagem) e renderize cada um.
//
// 4. (Bônus) Crie uma função `carregarUsuarios(): Promise<Resultado<string[]>>`
//    que simula uma chamada — sorteie sucesso ou erro.
//
// Saída esperada (estilo):
//
//   [carregando] ⏳ Aguarde...
//   [sucesso]    ✅ 3 itens recebidos: Ana, Bruno, Carla
//   [erro]       ❌ Falha: timeout na conexão
//
// 💡 Dicas:
//   - O campo discriminador é o `status` — todas as 3 variantes têm ele,
//     cada uma com um literal diferente.
//   - No `switch (r.status)`, dentro de cada `case` o TS sabe qual variante é
//     e libera o campo certo (`r.dados`, `r.mensagem`).
//   - O `default` com `const _: never = r` força tratar todos os casos.
//
// Rode: npx tsx main.ts

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

// TODO 1: defina o tipo Resultado<T> com as 3 variantes.
// type Resultado<T> = ...

// TODO 2: implemente renderizar com switch exaustivo + never.
// function renderizar<T>(r: Resultado<T>): string { ... }

// TODO 3: no main, crie 3 valores (um de cada estado) e imprima renderizar(...) de cada um.

function main(): void {
    console.log("(implemente o sistema de status com discriminated union)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// 1. Discriminated union genérica.
//    O campo `status` é o discriminador — literal único em cada variante.
type Resultado<T> =
    | { status: "carregando" }
    | { status: "sucesso"; dados: T }
    | { status: "erro"; mensagem: string };

// 2. Renderização com switch exaustivo + never no default.
function renderizar<T>(r: Resultado<T>): string {
    switch (r.status) {
        case "carregando":
            return "[carregando] ⏳ Aguarde...";
        case "sucesso":
            // TS sabe que aqui existe r.dados (do tipo T)
            const itens = Array.isArray(r.dados) ? r.dados : [r.dados];
            return `[sucesso]    ✅ ${itens.length} itens recebidos: ${itens.join(", ")}`;
        case "erro":
            // TS sabe que aqui existe r.mensagem (string)
            return `[erro]       ❌ Falha: ${r.mensagem}`;
        default:
            // Exhaustive check: se um dia adicionarmos uma 4ª variante
            // à union Resultado e esquecermos de tratar acima, o TS
            // quebra a build aqui — porque r não será `never`.
            const _exhaustive: never = r;
            throw new Error(`Status não tratado: ${_exhaustive}`);
    }
}

// 4. (Bônus) Simulação de chamada HTTP que retorna um Resultado.
function carregarUsuarios(): Promise<Resultado<string[]>> {
    return new Promise((resolve) => {
        setTimeout(() => {
            const deuCerto = Math.random() > 0.4;
            if (deuCerto) {
                resolve({ status: "sucesso", dados: ["Ana", "Bruno", "Carla"] });
            } else {
                resolve({ status: "erro", mensagem: "timeout na conexão" });
            }
        }, 300);
    });
}

async function main(): Promise<void> {
    // 3. Simulação dos 3 estados manualmente:
    const s1: Resultado<string[]> = { status: "carregando" };
    const s2: Resultado<string[]> = { status: "sucesso", dados: ["Ana", "Bruno", "Carla"] };
    const s3: Resultado<string[]> = { status: "erro", mensagem: "timeout na conexão" };

    console.log("=== Estados simulados ===");
    console.log(renderizar(s1));
    console.log(renderizar(s2));
    console.log(renderizar(s3));

    // Bônus: ciclo real — começa carregando, depois resolve.
    console.log("\n=== Chamada simulada ===");
    console.log(renderizar<string[]>({ status: "carregando" }));
    const resposta = await carregarUsuarios();
    console.log(renderizar(resposta));

    // Estado impossível? O TS impede:
    // const ruim: Resultado<string[]> = { status: "sucesso" };
    //   ❌ Property 'dados' is missing
    // const ruim2: Resultado<string[]> = { status: "carregando", dados: [] };
    //   ❌ Object literal may only specify known properties
}

main();
*/
