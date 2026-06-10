// 🎯 DESAFIO DO MÓDULO 08 — Refatoração com Utility Types
//
// Cenário:
// Você está num sistema de cadastro de usuários e percebeu que tem 4 interfaces
// quase iguais espalhadas pelo código:
//   - Uma pra criar usuário (sem id e sem createdAt)
//   - Uma pra atualizar (todos os campos opcionais, sem id)
//   - Uma pra exibir publicamente (sem senha)
//   - Um "mapa" de usuários indexado por id (cache em memória)
//
// Sua missão:
// Derivar TODOS esses tipos a partir de UMA interface `Usuario` base, usando
// utility types. Nada de duplicar interfaces "quase iguais".
//
// Interface base:
//
//   interface Usuario {
//       id: number;
//       nome: string;
//       email: string;
//       senha: string;
//       idade: number;
//       ativo: boolean;
//       createdAt: Date;
//       updatedAt: Date;
//   }
//
// Tipos que você precisa criar:
//
//   1. UsuarioCreate    → sem 'id', sem 'createdAt', sem 'updatedAt'
//                         (Omit)
//
//   2. UsuarioUpdate    → todos opcionais, sem 'id' (não pode mudar id)
//                         (Partial + Omit — compor utility types!)
//
//   3. UsuarioPublico   → todos os campos EXCETO 'senha'
//                         (Omit)
//
//   4. UsuariosPorId    → mapa { 1: Usuario, 2: Usuario, ... }
//                         (Record)
//
// Implemente também as 4 funções abaixo usando esses tipos.
//
// Rode: npx tsx main.ts

// ============================
// INTERFACE BASE (não mexer)
// ============================
interface Usuario {
    id: number;
    nome: string;
    email: string;
    senha: string;
    idade: number;
    ativo: boolean;
    createdAt: Date;
    updatedAt: Date;
}

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

// TODO 1: type UsuarioCreate = ?
// TODO 2: type UsuarioUpdate = ?
// TODO 3: type UsuarioPublico = ?
// TODO 4: type UsuariosPorId = ?

// TODO 5: implemente a função `criar` que recebe UsuarioCreate
//         e retorna Usuario (gera id, createdAt, updatedAt).

// TODO 6: implemente `atualizar` que recebe (id, UsuarioUpdate)
//         e retorna Usuario atualizado a partir do cache.

// TODO 7: implemente `paraPublico` que recebe Usuario
//         e retorna UsuarioPublico (sem senha).

// TODO 8: monte um cache UsuariosPorId, crie 2 usuários,
//         atualize 1, e imprima a versão pública de cada um.

function main(): void {
    console.log("(implemente sua solução acima e chame as funções aqui)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
// 1. CreateDTO — sem o que o backend gera
type UsuarioCreate = Omit<Usuario, "id" | "createdAt" | "updatedAt">;

// 2. UpdateDTO — todos opcionais, mas sem id (id nunca muda)
//    Composição: primeiro removemos id, depois marcamos tudo como opcional.
type UsuarioUpdate = Partial<Omit<Usuario, "id">>;

// 3. Público — sem o campo sensível
type UsuarioPublico = Omit<Usuario, "senha">;

// 4. Cache em memória — chave é o id (number)
type UsuariosPorId = Record<number, Usuario>;

let proximoId = 1;
const cache: UsuariosPorId = {};

function criar(dados: UsuarioCreate): Usuario {
    const agora = new Date();
    const novo: Usuario = {
        ...dados,
        id: proximoId++,
        createdAt: agora,
        updatedAt: agora
    };
    cache[novo.id] = novo;
    return novo;
}

function atualizar(id: number, dados: UsuarioUpdate): Usuario {
    const existente = cache[id];
    if (!existente) throw new Error(`Usuário ${id} não encontrado`);

    const atualizado: Usuario = {
        ...existente,
        ...dados,
        updatedAt: new Date()
    };
    cache[id] = atualizado;
    return atualizado;
}

function paraPublico(u: Usuario): UsuarioPublico {
    // Desestruturação retira 'senha' e o resto vira o objeto público.
    const { senha: _senha, ...publico } = u;
    return publico;
}

function main(): void {
    const ana = criar({
        nome: "Ana",
        email: "ana@email.com",
        senha: "segredo123",
        idade: 28,
        ativo: true
    });

    const bia = criar({
        nome: "Bia",
        email: "bia@email.com",
        senha: "outrosegredo",
        idade: 35,
        ativo: false
    });

    console.log("Antes do update:");
    console.log(" -", paraPublico(cache[ana.id]));
    console.log(" -", paraPublico(cache[bia.id]));

    // Update parcial — só 2 campos
    atualizar(bia.id, { ativo: true, idade: 36 });

    console.log("\nDepois do update da Bia (versão pública, sem senha):");
    for (const id of Object.keys(cache).map(Number)) {
        console.log(" -", paraPublico(cache[id]));
    }

    // Confirma que a senha nunca vazou:
    const publico = paraPublico(ana);
    // publico.senha; // ❌ Property 'senha' does not exist on type 'UsuarioPublico'
    console.log("\nO TS garante: 'senha' não existe em UsuarioPublico ✅");
}

main();
*/
