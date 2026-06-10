// Módulo 08 — Utility Types + Decorators
// Prática: 8 exercícios cobrindo os utility types principais + 1 decorator.
//
// Rode com: npx tsx main.ts
//
// Obs: o decorator de método usa sintaxe Stage 3 (TS 5+). Funciona com tsx
// sem precisar de "experimentalDecorators".

// ============================================================
// Tipo base usado em vários exercícios
// ============================================================
interface Usuario {
    id: number;
    nome: string;
    email: string;
    senha: string;
    idade: number;
    ativo: boolean;
    createdAt: Date;
}

// ============================================================
// Exercício 1 — Partial<T>: update parcial
// Aceita qualquer subconjunto dos campos para um PATCH.
// ============================================================
function exercicio1(): void {
    type UsuarioUpdate = Partial<Usuario>;

    function atualizar(id: number, dados: UsuarioUpdate): string {
        // Em produção: faria UPDATE no banco só nos campos enviados.
        const campos = Object.keys(dados).join(", ");
        return `Usuário ${id} atualizado nos campos: ${campos || "(nenhum)"}`;
    }

    console.log(atualizar(1, { nome: "Ana Maria" }));
    console.log(atualizar(2, { email: "novo@email.com", ativo: false }));
    console.log(atualizar(3, {})); // válido — todos opcionais
}

// ============================================================
// Exercício 2 — Pick<T, K>: DTO de leitura (resumo)
// Só os campos que a tela de listagem precisa.
// ============================================================
function exercicio2(): void {
    type UsuarioResumo = Pick<Usuario, "id" | "nome" | "ativo">;

    const lista: UsuarioResumo[] = [
        { id: 1, nome: "Ana", ativo: true },
        { id: 2, nome: "Bia", ativo: false },
        { id: 3, nome: "Caio", ativo: true }
    ];

    // Vantagem: o TS GARANTE que não vamos vazar email/senha aqui.
    lista.forEach(u => console.log(`#${u.id} ${u.nome} — ${u.ativo ? "ativo" : "inativo"}`));
}

// ============================================================
// Exercício 3 — Omit<T, K>: CreateDTO sem id nem createdAt
// O backend é quem gera id e timestamp; o cliente não envia.
// ============================================================
function exercicio3(): void {
    type UsuarioCreate = Omit<Usuario, "id" | "createdAt">;

    function criar(dados: UsuarioCreate): Usuario {
        return {
            ...dados,
            id: Math.floor(Math.random() * 1000),
            createdAt: new Date()
        };
    }

    const novo = criar({
        nome: "David",
        email: "david@email.com",
        senha: "1234",
        idade: 30,
        ativo: true
    });
    console.log("Criado:", { id: novo.id, nome: novo.nome });
}

// ============================================================
// Exercício 4 — Record<K, V>: mapa de configuração
// Chaves controladas por union type, valores estruturados.
// ============================================================
function exercicio4(): void {
    type Ambiente = "dev" | "homolog" | "prod";

    interface ConfigAmbiente {
        url: string;
        timeout: number;
        debug: boolean;
    }

    const configs: Record<Ambiente, ConfigAmbiente> = {
        dev:     { url: "http://localhost:3000", timeout: 30000, debug: true  },
        homolog: { url: "https://hml.app.com",   timeout: 10000, debug: true  },
        prod:    { url: "https://app.com",       timeout: 5000,  debug: false }
    };

    // Se eu tentar acessar configs.qa o TS reclama — só os 3 ambientes existem.
    const ambienteAtual: Ambiente = "dev";
    console.log(`Ambiente ${ambienteAtual}:`, configs[ambienteAtual]);
}

// ============================================================
// Exercício 5 — ReturnType<F>: inferindo tipo de retorno
// Útil pra factories — pega o tipo automaticamente.
// ============================================================
function exercicio5(): void {
    function criarProduto(nome: string, preco: number) {
        return {
            id: Math.random(),
            nome,
            preco,
            precoFormatado: `R$ ${preco.toFixed(2)}`
        };
    }

    // Sem ReturnType: precisaríamos digitar a interface igual à do return.
    // Com ele: o tipo "anda junto" com a função. Mudou o return? Mudou o tipo.
    type Produto = ReturnType<typeof criarProduto>;

    const p: Produto = criarProduto("Café", 12.5);
    console.log("Produto:", p.nome, "—", p.precoFormatado);
}

// ============================================================
// Exercício 6 — Readonly<T> + NonNullable<T>
// Estado imutável + refino de tipo após checagem.
// ============================================================
function exercicio6(): void {
    interface Estado {
        contador: number;
        ultimoUsuario: string | null;
    }

    const estado: Readonly<Estado> = { contador: 0, ultimoUsuario: null };
    // estado.contador = 1; // ❌ readonly — erro de compilação

    function descreverUsuario(nome: string | null | undefined): string {
        if (!nome) return "Anônimo";
        // Aqui dentro o TS já sabe que nome é string (narrowing).
        // NonNullable serviria se viesse de um tipo mais complexo.
        const nomeCerto: NonNullable<typeof nome> = nome;
        return nomeCerto.toUpperCase();
    }

    console.log("Estado:", estado);
    console.log("Usuário:", descreverUsuario(estado.ultimoUsuario));
    console.log("Usuário:", descreverUsuario("Ana"));
}

// ============================================================
// Exercício 7 — Parameters<F> + Awaited<P>
// Wrappers que reaproveitam assinatura e desembrulham Promise.
// ============================================================
function exercicio7(): void {
    async function buscarPreco(produto: string, moeda: string): Promise<number> {
        // Simula chamada de API
        return produto === "café" ? 12.5 : 0;
    }

    // Parameters: pega os tipos como tupla [string, string]
    type ArgsBusca = Parameters<typeof buscarPreco>;
    // Awaited: pega o tipo "dentro" da Promise — number, não Promise<number>
    type Preco = Awaited<ReturnType<typeof buscarPreco>>;

    const args: ArgsBusca = ["café", "BRL"];

    buscarPreco(...args).then((p: Preco) => {
        console.log(`Preço de ${args[0]}: R$ ${p.toFixed(2)}`);
    });
}

// ============================================================
// Exercício 8 — Decorator de método: log de chamadas
// Sintaxe Stage 3 (TS 5+). Roda com `npx tsx main.ts` sem flags.
// ============================================================
function exercicio8(): void {
    function Log<This, Args extends any[], Return>(
        metodoOriginal: (this: This, ...args: Args) => Return,
        ctx: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>
    ) {
        const nome = String(ctx.name);
        return function (this: This, ...args: Args): Return {
            console.log(`  > ${nome}(${args.map(a => JSON.stringify(a)).join(", ")})`);
            const resultado = metodoOriginal.call(this, ...args);
            console.log(`  < retornou: ${JSON.stringify(resultado)}`);
            return resultado;
        };
    }

    class Calculadora {
        @Log
        somar(a: number, b: number): number {
            return a + b;
        }

        @Log
        dobrar(x: number): number {
            return x * 2;
        }
    }

    const calc = new Calculadora();
    calc.somar(2, 3);
    calc.dobrar(7);
}

// ============================================================
function main(): void {
    console.log("=== Exercício 1: Partial<T> — update parcial ===");
    exercicio1();

    console.log("\n=== Exercício 2: Pick<T,K> — DTO de leitura ===");
    exercicio2();

    console.log("\n=== Exercício 3: Omit<T,K> — CreateDTO sem id ===");
    exercicio3();

    console.log("\n=== Exercício 4: Record<K,V> — mapa de configuração ===");
    exercicio4();

    console.log("\n=== Exercício 5: ReturnType<F> — inferindo retorno ===");
    exercicio5();

    console.log("\n=== Exercício 6: Readonly + NonNullable ===");
    exercicio6();

    console.log("\n=== Exercício 7: Parameters + Awaited ===");
    exercicio7();

    console.log("\n=== Exercício 8: Decorator de método — log ===");
    exercicio8();
}

main();
