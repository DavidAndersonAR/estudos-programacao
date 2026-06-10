// 🎯 DESAFIO DO MÓDULO 07 — Container Genérico Reutilizável (Cache<K, V>)
//
// Objetivo:
// Implemente uma classe `Cache<K, V>` genérica que funcione como um mini-Map,
// usando um `Map<K, V>` interno como armazenamento.
//
// API exigida:
//   - set(chave: K, valor: V): void          → guarda o par no cache
//   - get(chave: K): V | undefined           → recupera o valor
//   - has(chave: K): boolean                 → checa se a chave existe
//   - delete(chave: K): boolean              → remove (retorna true se existia)
//   - keys(): K[]                            → lista todas as chaves
//   - size(): number                         → quantidade de itens
//
// Depois, demonstre o cache em DOIS cenários (pra mostrar o ganho dos generics):
//
//   1) Cache<string, number>  — contador de cliques por botão
//        Ex.: cache.set("btn-salvar", 3)
//
//   2) Cache<number, User>    — cache de usuários por ID
//        type User = { id: number; nome: string; email: string }
//        Ex.: cache.set(1, { id: 1, nome: "Ana", email: "ana@x.com" })
//
// Requisitos:
// 1. A classe deve ser GENÉRICA em K e V (use `<K, V>` no nome da classe).
// 2. Use `Map<K, V>` por baixo — não invente roda quadrada.
// 3. Cada método deve preservar a tipagem (sem `any`).
// 4. Imprima o estado dos dois caches no console.
// 5. Tente provocar 1 erro de tipo de propósito (ex.: `cliques.set("x", "três")`)
//    pra sentir o TS reclamando — depois corrija.
//
// 💡 Dicas:
//   - `Map<K, V>` já tem `.get`, `.set`, `.has`, `.delete`, `.size` — você só
//     vai delegar pra ele.
//   - `Array.from(this.mapa.keys())` converte o iterador em array.
//   - O `delete` do Map já retorna boolean — repasse direto.
//
// Rode: npx tsx main.ts

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

class Cache<K, V> {
    // TODO 1: declare o armazenamento interno (um Map<K, V>)

    // TODO 2: implemente set(chave, valor): void

    // TODO 3: implemente get(chave): V | undefined

    // TODO 4: implemente has(chave): boolean

    // TODO 5: implemente delete(chave): boolean

    // TODO 6: implemente keys(): K[]

    // TODO 7: implemente size(): number
}

type User = {
    id: number;
    nome: string;
    email: string;
};

function main(): void {
    // TODO: instancie Cache<string, number> e Cache<number, User>
    //       chame set/get/has/delete/keys/size em cada um, imprima resultados.
    console.log("(implemente o Cache<K, V> e demonstre os 2 cenários)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
class Cache<K, V> {
    private mapa: Map<K, V> = new Map();

    set(chave: K, valor: V): void {
        this.mapa.set(chave, valor);
    }

    get(chave: K): V | undefined {
        return this.mapa.get(chave);
    }

    has(chave: K): boolean {
        return this.mapa.has(chave);
    }

    delete(chave: K): boolean {
        return this.mapa.delete(chave);
    }

    keys(): K[] {
        return Array.from(this.mapa.keys());
    }

    size(): number {
        return this.mapa.size;
    }
}

type User = {
    id: number;
    nome: string;
    email: string;
};

function main(): void {
    // ---------------------------------------------
    // Cenário 1: Cache<string, number> — contador de cliques
    // ---------------------------------------------
    console.log("=== Cache<string, number> — cliques por botão ===");
    const cliques = new Cache<string, number>();

    cliques.set("btn-salvar", 1);
    cliques.set("btn-cancelar", 0);
    cliques.set("btn-salvar", (cliques.get("btn-salvar") ?? 0) + 1); // incrementa

    console.log("size:", cliques.size());                    // 2
    console.log("keys:", cliques.keys());                    // ['btn-salvar', 'btn-cancelar']
    console.log("btn-salvar:", cliques.get("btn-salvar"));   // 2
    console.log("has(btn-x):", cliques.has("btn-x"));        // false
    console.log("delete(btn-cancelar):", cliques.delete("btn-cancelar")); // true
    console.log("size após delete:", cliques.size());        // 1

    // cliques.set("x", "três"); // ❌ Argument of type 'string' is not assignable to 'number'

    // ---------------------------------------------
    // Cenário 2: Cache<number, User> — usuários por ID
    // ---------------------------------------------
    console.log("\n=== Cache<number, User> — usuários por ID ===");
    const usuarios = new Cache<number, User>();

    usuarios.set(1, { id: 1, nome: "Ana",    email: "ana@x.com" });
    usuarios.set(2, { id: 2, nome: "Bia",    email: "bia@x.com" });
    usuarios.set(3, { id: 3, nome: "Carlos", email: "carlos@x.com" });

    console.log("size:", usuarios.size());                   // 3
    console.log("keys:", usuarios.keys());                   // [1, 2, 3]

    const u2 = usuarios.get(2);
    if (u2) {
        // TS sabe que u2 é User → autocomplete de .nome e .email
        console.log(`usuário 2: ${u2.nome} <${u2.email}>`);
    }

    console.log("has(99):", usuarios.has(99));               // false
    console.log("delete(1):", usuarios.delete(1));           // true
    console.log("keys após delete:", usuarios.keys());       // [2, 3]

    // usuarios.set("abc", { ... }); // ❌ K deve ser number
    // usuarios.set(4, { id: 4 });   // ❌ faltam 'nome' e 'email'
}

main();
*/
