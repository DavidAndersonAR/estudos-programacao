// Módulo 04 — Interfaces e Type Aliases
// Prática: interface vs type, opcional, readonly, index signature, extends, type de função.
//
// Rode com: npx tsx main.ts

// Exercício 1: interface Pessoa
// A forma mais comum de modelar um objeto de domínio.
interface Pessoa {
    nome: string;
    idade: number;
}

function exercicio1(): void {
    const p: Pessoa = { nome: "Ana", idade: 28 };
    console.log(`${p.nome}, ${p.idade} anos`);
}

// Exercício 2: type Pessoa — equivalência básica com interface
// Para objetos simples, type e interface dão no mesmo resultado.
type PessoaT = {
    nome: string;
    idade: number;
};

function exercicio2(): void {
    const p: PessoaT = { nome: "Bia", idade: 31 };
    // Note: poderíamos passar `p` numa função que aceita `Pessoa` (estrutura igual).
    console.log(`${p.nome}, ${p.idade} anos (via type)`);
}

// Exercício 3: campos opcionais com ?
// telefone pode não existir — o tipo vira string | undefined.
interface Contato {
    nome: string;
    email: string;
    telefone?: string;
}

function exercicio3(): void {
    const c1: Contato = { nome: "Carlos", email: "c@x.com" };
    const c2: Contato = { nome: "Diana",  email: "d@x.com", telefone: "9999-0000" };

    // Precisa checar antes de usar:
    const tel1 = c1.telefone ?? "(sem telefone)";
    const tel2 = c2.telefone ?? "(sem telefone)";
    console.log(`${c1.nome}: ${tel1}`);
    console.log(`${c2.nome}: ${tel2}`);
}

// Exercício 4: readonly
// id não pode ser reatribuído depois de criado.
interface Produto {
    readonly id: number;
    nome: string;
    preco: number;
}

function exercicio4(): void {
    const p: Produto = { id: 1, nome: "Caneta", preco: 3.5 };
    p.nome = "Caneta azul"; // ✅ ok
    p.preco = 4.0;          // ✅ ok
    // p.id = 2;            // ❌ Cannot assign to 'id' because it is a read-only property
    console.log(p);
}

// Exercício 5: extends — Cachorro herda campos de Animal
interface Animal {
    nome: string;
    idade: number;
}

interface Cachorro extends Animal {
    raca: string;
}

function exercicio5(): void {
    const rex: Cachorro = { nome: "Rex", idade: 4, raca: "Labrador" };
    console.log(`${rex.nome} (${rex.raca}), ${rex.idade} anos`);
}

// Exercício 6: index signature — dicionário de notas
// Qualquer chave string mapeia para um number.
interface Notas {
    [materia: string]: number;
}

function exercicio6(): void {
    const notas: Notas = {
        matematica: 9.5,
        portugues:  8.0,
        historia:   7.5,
    };
    notas.fisica = 10; // ✅ adicionar chave nova é livre

    let soma = 0;
    let qtd  = 0;
    for (const m in notas) {
        soma += notas[m];
        qtd++;
    }
    console.log(`Média: ${(soma / qtd).toFixed(2)}`);
}

// Exercício 7: interface estendendo duas + type de função
// Pato é Animal + Nadador + Voador. E Handler é um type de função.
interface Nadador { nadar(): void; }
interface Voador  { voar():  void; }
interface Pato extends Animal, Nadador, Voador {
    grasnar(): void;
}

type Handler = (msg: string) => void;

function exercicio7(): void {
    const donald: Pato = {
        nome: "Donald",
        idade: 5,
        nadar:   () => console.log("  splash"),
        voar:    () => console.log("  flap flap"),
        grasnar: () => console.log("  quack!"),
    };

    const log: Handler = (msg) => console.log(`[log] ${msg}`);

    log(`${donald.nome} se prepara...`);
    donald.nadar();
    donald.voar();
    donald.grasnar();
}

function main(): void {
    console.log("=== Exercício 1: interface Pessoa ===");
    exercicio1();

    console.log("\n=== Exercício 2: type Pessoa (equivalente) ===");
    exercicio2();

    console.log("\n=== Exercício 3: campos opcionais (?) ===");
    exercicio3();

    console.log("\n=== Exercício 4: readonly ===");
    exercicio4();

    console.log("\n=== Exercício 5: extends ===");
    exercicio5();

    console.log("\n=== Exercício 6: index signature ===");
    exercicio6();

    console.log("\n=== Exercício 7: extends múltiplo + type de função ===");
    exercicio7();
}

main();
