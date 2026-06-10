// Módulo 06 — Classes em TypeScript
// Prática: construtor, parameter properties, get/set, static,
// abstract, implements, herança, # private fields.
//
// Rode com: npx tsx main.ts

// Exercício 1: Classe básica com parameter properties
// Atalho: declarar propriedade direto na assinatura do construtor.
class Pessoa {
    constructor(
        public nome: string,
        public idade: number,
        public readonly email: string
    ) {}

    apresentar(): string {
        return `${this.nome}, ${this.idade} anos (${this.email})`;
    }
}

function exercicio1(): void {
    const p = new Pessoa("Ana", 28, "ana@email.com");
    console.log(p.apresentar());
    // p.email = "outro"; // ❌ readonly — não pode reatribuir
}

// Exercício 2: Getter e setter com validação
// O setter intercepta a atribuição pra validar.
class Temperatura {
    private _celsius: number = 0;

    get celsius(): number {
        return this._celsius;
    }

    set celsius(valor: number) {
        if (valor < -273.15) {
            throw new Error("Abaixo do zero absoluto!");
        }
        this._celsius = valor;
    }

    get fahrenheit(): number {
        return this._celsius * 9 / 5 + 32;
    }
}

function exercicio2(): void {
    const t = new Temperatura();
    t.celsius = 25;
    console.log(`Celsius: ${t.celsius} | Fahrenheit: ${t.fahrenheit}`);
    try {
        t.celsius = -300; // dispara o erro do setter
    } catch (e) {
        console.log("Erro capturado:", (e as Error).message);
    }
}

// Exercício 3: Classe utilitária com static
// Membros static pertencem à classe, não às instâncias.
class CalcUtil {
    static readonly PI = 3.14159;

    static dobro(n: number): number {
        return n * 2;
    }

    static mediar(nums: number[]): number {
        if (nums.length === 0) return 0;
        return nums.reduce((acc, n) => acc + n, 0) / nums.length;
    }
}

function exercicio3(): void {
    console.log("PI:", CalcUtil.PI);
    console.log("Dobro de 7:", CalcUtil.dobro(7));
    console.log("Média:", CalcUtil.mediar([10, 20, 30, 40]));
}

// Exercício 4: Classe abstrata + subclasses
// Forma define o contrato (area abstrato) e código comum (descrever).
abstract class Forma {
    constructor(public nome: string) {}

    abstract area(): number; // sem corpo — sub precisa implementar

    descrever(): string {
        return `${this.nome} → área = ${this.area().toFixed(2)}`;
    }
}

class Circulo extends Forma {
    constructor(public raio: number) {
        super("Círculo");
    }

    area(): number {
        return Math.PI * this.raio ** 2;
    }
}

class Quadrado extends Forma {
    constructor(public lado: number) {
        super("Quadrado");
    }

    area(): number {
        return this.lado * this.lado;
    }
}

function exercicio4(): void {
    const formas: Forma[] = [new Circulo(5), new Quadrado(4)];
    formas.forEach(f => console.log(f.descrever()));
    // new Forma("X"); // ❌ Cannot create an instance of an abstract class
}

// Exercício 5: Implementando interface
// A classe é OBRIGADA a ter tudo que a interface declara.
interface Identificavel {
    id: number;
    obterIdentificacao(): string;
}

class Produto implements Identificavel {
    constructor(public id: number, public nome: string, public preco: number) {}

    obterIdentificacao(): string {
        return `#${this.id} — ${this.nome} (R$ ${this.preco.toFixed(2)})`;
    }
}

function exercicio5(): void {
    const p = new Produto(101, "Café", 12.5);
    console.log(p.obterIdentificacao());
}

// Exercício 6: Herança simples com super e override
class Animal {
    constructor(public nome: string) {}

    fazerBarulho(): void {
        console.log(`${this.nome} faz um som genérico.`);
    }
}

class Cachorro extends Animal {
    constructor(nome: string, public raca: string) {
        super(nome); // chama o construtor do pai (obrigatório antes de this)
    }

    // override
    fazerBarulho(): void {
        super.fazerBarulho(); // executa a versão do pai antes
        console.log(`${this.nome} (${this.raca}) late: au au!`);
    }
}

function exercicio6(): void {
    const rex = new Cachorro("Rex", "Labrador");
    rex.fazerBarulho();
}

// Exercício 7: # private fields (privado de verdade)
// Diferente de `private` do TS, `#campo` é inacessível em runtime.
class Cofre {
    #segredo: string;
    #tentativas: number = 0;

    constructor(segredo: string) {
        this.#segredo = segredo;
    }

    abrir(senha: string): string {
        this.#tentativas++;
        if (senha === "1234") {
            return `Aberto na tentativa ${this.#tentativas}: ${this.#segredo}`;
        }
        return `Negado (tentativa ${this.#tentativas})`;
    }
}

function exercicio7(): void {
    const c = new Cofre("barras de ouro");
    console.log(c.abrir("errada"));
    console.log(c.abrir("1234"));
    // console.log(c.#segredo);     // ❌ nem compila
    // console.log((c as any).#segredo); // ❌ bypass falha em runtime
}

// Exercício 8: Tudo junto — classe com modificadores variados
class ContaBancaria {
    private _saldo: number = 0;

    constructor(
        public readonly numero: string,
        public titular: string
    ) {}

    get saldo(): number {
        return this._saldo;
    }

    depositar(valor: number): void {
        if (valor <= 0) throw new Error("Valor deve ser positivo");
        this._saldo += valor;
    }

    sacar(valor: number): boolean {
        if (valor > this._saldo) return false;
        this._saldo -= valor;
        return true;
    }
}

function exercicio8(): void {
    const conta = new ContaBancaria("0001-X", "David");
    conta.depositar(500);
    const ok = conta.sacar(120);
    console.log(`${conta.titular} (${conta.numero}) — saldo: R$ ${conta.saldo} | saque ok? ${ok}`);
    // conta.numero = "outro"; // ❌ readonly
    // conta._saldo = 9999;    // ❌ private
}

function main(): void {
    console.log("=== Exercício 1: Parameter properties ===");
    exercicio1();

    console.log("\n=== Exercício 2: Get/set com validação ===");
    exercicio2();

    console.log("\n=== Exercício 3: Classe utilitária (static) ===");
    exercicio3();

    console.log("\n=== Exercício 4: Abstract + subclasses ===");
    exercicio4();

    console.log("\n=== Exercício 5: Implements interface ===");
    exercicio5();

    console.log("\n=== Exercício 6: Herança (extends + super) ===");
    exercicio6();

    console.log("\n=== Exercício 7: # private fields ===");
    exercicio7();

    console.log("\n=== Exercício 8: Tudo junto (conta bancária) ===");
    exercicio8();
}

main();
