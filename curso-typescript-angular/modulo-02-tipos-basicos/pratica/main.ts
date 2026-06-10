// Módulo 02 — Tipos Básicos
// Prática: number, string, boolean, array, tuple, enum/união, any/unknown, void/never, null/undefined.
//
// Rode com: npx tsx main.ts

// Exercício 1: Primitivos básicos
// number, string, boolean — e uma menção a bigint.
function exercicio1(): void {
    const idade: number = 30;
    const preco: number = 19.9;
    const nome: string = "Ana";
    const ativo: boolean = true;
    const enorme: bigint = 9007199254740993n;

    console.log(`${nome} | ${idade} anos | R$${preco} | ativo: ${ativo} | bigint: ${enorme}`);
}

// Exercício 2: Array — duas sintaxes equivalentes
// T[] e Array<T> são a mesma coisa. Use a que te agradar.
function exercicio2(): void {
    const numeros: number[] = [10, 20, 30];
    const palavras: Array<string> = ["foo", "bar", "baz"];

    const soma = numeros.reduce((acc, n) => acc + n, 0);
    const juntas = palavras.join(" - ");

    console.log("Soma:", soma, "| Palavras:", juntas);
    // numeros.push("texto"); // ❌ Argument of type 'string' is not assignable to parameter of type 'number'
}

// Exercício 3: Tuple — array de tamanho fixo, tipos por posição
// Útil quando você quer "retornar duas coisas" sem criar um objeto.
function dividirComResto(a: number, b: number): [number, number] {
    return [Math.floor(a / b), a % b];
}

function exercicio3(): void {
    const par: [string, number] = ["idade", 30];
    console.log(`${par[0]}: ${par[1]}`); // par[0] é string, par[1] é number

    const [quociente, resto] = dividirComResto(17, 5);
    console.log(`17 / 5 = ${quociente}, resto ${resto}`);
}

// Exercício 4: Enum vs união de literais
// Mostro os dois lado a lado para você sentir a diferença.
enum Status {
    Ativo = "ATIVO",
    Inativo = "INATIVO",
    Pendente = "PENDENTE"
}

type Cor = "vermelho" | "verde" | "azul"; // união de literais

function exercicio4(): void {
    const s: Status = Status.Ativo;
    const c: Cor = "verde";
    console.log("Status:", s, "| Cor:", c);
    // const c2: Cor = "amarelo"; // ❌ Type '"amarelo"' is not assignable to type 'Cor'
}

// Exercício 5: any vs unknown
// any desliga o TS. unknown obriga você a checar o tipo antes de usar.
function exercicio5(): void {
    const inseguro: any = "texto";
    inseguro.metodoQueNaoExiste?.(); // TS deixa passar (perigoso)

    const seguro: unknown = "texto";
    // seguro.toUpperCase(); // ❌ Object is of type 'unknown'

    if (typeof seguro === "string") {
        // dentro do if, TS estreitou o tipo para string
        console.log("Estreitou pra string:", seguro.toUpperCase());
    }
}

// Exercício 6: void e never
// void = não retorna nada.  never = nunca termina normalmente.
function logar(msg: string): void {
    console.log("[LOG]", msg);
    // sem return
}

function explodir(motivo: string): never {
    throw new Error(motivo);
}

function exercicio6(): void {
    logar("função void chamada");

    try {
        explodir("falha intencional pra demonstrar 'never'");
    } catch (e) {
        // capturamos o erro pra não derrubar o programa
        console.log("Capturado:", (e as Error).message);
    }
}

// Exercício 7: null, undefined e strictNullChecks
// Com strict ligado, você precisa declarar explicitamente que o valor pode ser ausente.
function buscarNome(id: number): string | null {
    if (id === 1) return "Ana";
    return null;
}

function exercicio7(): void {
    const nome: string | null = buscarNome(1);
    const naoAchado: string | null = buscarNome(99);

    // Tem que tratar o null antes de usar:
    if (nome !== null) {
        console.log("Achou:", nome.toUpperCase());
    }
    console.log("Sem nome:", naoAchado ?? "(vazio)");

    let opcional: string | undefined;
    console.log("Opcional não atribuído:", opcional);
}

function main(): void {
    console.log("=== Exercício 1: Primitivos básicos ===");
    exercicio1();

    console.log("\n=== Exercício 2: Array ===");
    exercicio2();

    console.log("\n=== Exercício 3: Tuple ===");
    exercicio3();

    console.log("\n=== Exercício 4: Enum vs união ===");
    exercicio4();

    console.log("\n=== Exercício 5: any vs unknown ===");
    exercicio5();

    console.log("\n=== Exercício 6: void e never ===");
    exercicio6();

    console.log("\n=== Exercício 7: null e undefined ===");
    exercicio7();
}

main();
