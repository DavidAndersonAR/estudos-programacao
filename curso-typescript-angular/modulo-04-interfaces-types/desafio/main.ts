// 🎯 DESAFIO DO MÓDULO 04 — Modelagem de Pedido
//
// Objetivo:
// Modele um sistema de pedido usando interfaces e types. Você vai criar:
//
//   - interface `Endereco`   — rua, numero, cidade, uf
//   - interface `Cliente`    — id (readonly), nome, email, endereco (OPCIONAL)
//   - interface `ItemPedido` — id (readonly), descricao, quantidade, precoUnitario
//   - type      `StatusPedido` — union literal: "pendente" | "pago" | "enviado" | "entregue" | "cancelado"
//   - interface `Pedido`     — id (readonly), cliente, itens[], status, criadoEm (Date)
//
// E uma função:
//
//   - calcularTotal(p: Pedido): number
//        // soma quantidade * precoUnitario de cada item.
//
// Requisitos:
// 1. `Endereco` é opcional dentro de `Cliente` (cliente novo pode ainda não ter endereço cadastrado).
// 2. Os `id` (de Cliente, ItemPedido e Pedido) devem ser `readonly`.
// 3. `status` deve ser uma union literal — NÃO use `string`.
// 4. Crie pelo menos 1 pedido completo e imprima:
//       - nome do cliente
//       - status
//       - cada item (descrição + subtotal)
//       - total geral (formatado com 2 casas, ex: "R$ 42.50")
// 5. Tente atribuir a um `id` depois de criado pra ver o TS chiando — depois remova.
//
// 💡 Dicas:
//   - `array.reduce((acc, item) => acc + ..., 0)` é o caminho para o total.
//   - `valor.toFixed(2)` formata número com 2 casas decimais.
//   - Use `?.` (optional chaining) para acessar campos do endereço opcional.
//
// Rode: npx tsx main.ts

// ============================
// SUAS DECLARAÇÕES + SOLUÇÃO ABAIXO
// ============================

// TODO: declare aqui as interfaces Endereco, Cliente, ItemPedido, Pedido e o type StatusPedido.

// TODO: implemente calcularTotal.

function main(): void {
    // TODO: crie um pedido de exemplo e imprima os dados conforme os requisitos.
    console.log("(modele Endereco, Cliente, ItemPedido, Pedido, StatusPedido e calcularTotal aqui)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
interface Endereco {
    rua: string;
    numero: number;
    cidade: string;
    uf: string;
}

interface Cliente {
    readonly id: number;
    nome: string;
    email: string;
    endereco?: Endereco; // opcional: cliente pode ainda não ter cadastrado
}

interface ItemPedido {
    readonly id: number;
    descricao: string;
    quantidade: number;
    precoUnitario: number;
}

// Union literal — só esses 5 valores são aceitos pelo TS.
type StatusPedido = "pendente" | "pago" | "enviado" | "entregue" | "cancelado";

interface Pedido {
    readonly id: number;
    cliente: Cliente;
    itens: ItemPedido[];
    status: StatusPedido;
    criadoEm: Date;
}

// calcularTotal: percorre os itens e soma quantidade * precoUnitario.
function calcularTotal(p: Pedido): number {
    return p.itens.reduce((acc, item) => acc + item.quantidade * item.precoUnitario, 0);
}

// Helper de formatação de moeda (BRL simples, sem Intl para manter foco no TS).
function formatarBRL(v: number): string {
    return `R$ ${v.toFixed(2)}`;
}

function main(): void {
    const cliente: Cliente = {
        id: 1,
        nome: "David Anderson",
        email: "david@email.com",
        endereco: {
            rua: "Rua das Flores",
            numero: 123,
            cidade: "São Paulo",
            uf: "SP",
        },
    };

    const pedido: Pedido = {
        id: 1001,
        cliente,
        status: "pendente",
        criadoEm: new Date(),
        itens: [
            { id: 1, descricao: "Caneta azul",       quantidade: 3, precoUnitario: 3.50 },
            { id: 2, descricao: "Caderno 200 fls",   quantidade: 1, precoUnitario: 24.90 },
            { id: 3, descricao: "Borracha branca",   quantidade: 2, precoUnitario: 1.20 },
        ],
    };

    // Tentativas que o TS bloqueia (descomente pra ver):
    // pedido.id = 2;                  // ❌ readonly
    // cliente.id = 999;               // ❌ readonly
    // pedido.status = "qualquer";     // ❌ não é da union

    console.log("=== Pedido #" + pedido.id + " ===");
    console.log(`Cliente: ${pedido.cliente.nome} <${pedido.cliente.email}>`);
    // Endereço é opcional — checamos com optional chaining + fallback.
    const enderecoTxt = pedido.cliente.endereco
        ? `${pedido.cliente.endereco.rua}, ${pedido.cliente.endereco.numero} — ${pedido.cliente.endereco.cidade}/${pedido.cliente.endereco.uf}`
        : "(sem endereço cadastrado)";
    console.log(`Endereço: ${enderecoTxt}`);
    console.log(`Status:   ${pedido.status}`);
    console.log(`Criado:   ${pedido.criadoEm.toISOString()}`);

    console.log("\nItens:");
    for (const item of pedido.itens) {
        const subtotal = item.quantidade * item.precoUnitario;
        console.log(`  - ${item.descricao.padEnd(22)} x${item.quantidade}  =  ${formatarBRL(subtotal)}`);
    }

    console.log(`\nTotal: ${formatarBRL(calcularTotal(pedido))}`);
}

main();
*/
