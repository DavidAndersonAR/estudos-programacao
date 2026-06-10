// 🎯 DESAFIO DO MÓDULO 06 — Sistema de Personagens RPG
//
// Objetivo:
// Construir um mini-sistema de combate usando TUDO que viu no módulo:
// classe abstrata, herança, parameter properties, modificadores de acesso,
// interface com `implements` e polimorfismo.
//
// O que implementar:
//
// 1. Classe abstrata `Personagem`
//    - Propriedades: `nome: string`, `hp: number` (protected, pra subclasse mexer)
//    - Construtor recebe nome e hp inicial
//    - Método abstrato: `atacar(alvo: Personagem): void`
//    - Método concreto: `receberDano(dano: number): void`
//      → reduz hp, sem deixar abaixo de 0; loga "X recebeu Y de dano (HP: Z)"
//    - Método concreto: `estaVivo(): boolean` → hp > 0
//    - Método concreto: `status(): string` → "Nome [HP/HPMax]"
//
// 2. Classe `Guerreiro extends Personagem`
//    - Tem `forca: number` (ataque físico)
//    - `atacar(alvo)`: causa dano = forca, loga "X golpeia Y com a espada!"
//      e chama `alvo.receberDano(forca)`
//
// 3. Interface `Curavel`
//    - `curar(quantidade: number): void`
//
// 4. Classe `Mago extends Personagem implements Curavel`
//    - Tem `mana: number` e `poderMagico: number`
//    - `atacar(alvo)`: se mana >= 10, gasta 10, causa dano = poderMagico,
//      loga "X lança bola de fogo em Y!" e chama `alvo.receberDano(...)`.
//      Senão loga "X está sem mana!"
//    - `curar(quantidade)`: aumenta o próprio hp (sem ultrapassar hpMax),
//      gasta 5 de mana se tiver; loga "X se cura em Z (HP: ...)"
//
// 5. Função `simularLuta(a: Personagem, b: Personagem): void`
//    - Em loop, alterna turnos enquanto os dois estiverem vivos
//    - Imprime o status no início de cada turno
//    - Limite de 20 turnos pra evitar empate eterno
//    - Anuncia o vencedor no final
//
// 💡 Dicas:
//   - Guarde o `hpMax` separado pra cap de cura.
//   - `Math.min(hpMax, hp + quantidade)` evita estourar a cura.
//   - Polimorfismo: `simularLuta` recebe `Personagem`, mas funciona com
//     Guerreiro OU Mago porque `atacar` é virtual.
//
// Rode: npx tsx main.ts

// ============================
// SUA SOLUÇÃO ABAIXO
// ============================

function main(): void {
    // TODO:
    // 1) Criar classe abstrata Personagem
    // 2) Criar interface Curavel
    // 3) Criar Guerreiro extends Personagem
    // 4) Criar Mago extends Personagem implements Curavel
    // 5) Instanciar dois personagens e chamar simularLuta(a, b)
    console.log("(implemente o sistema RPG aqui)");
}

main();

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
// ============================

/*
abstract class Personagem {
    protected hpMax: number;

    constructor(public nome: string, protected hp: number) {
        this.hpMax = hp;
    }

    // contrato — toda subclasse define como ataca
    abstract atacar(alvo: Personagem): void;

    receberDano(dano: number): void {
        this.hp = Math.max(0, this.hp - dano);
        console.log(`  → ${this.nome} recebeu ${dano} de dano (HP: ${this.hp}/${this.hpMax})`);
    }

    estaVivo(): boolean {
        return this.hp > 0;
    }

    status(): string {
        return `${this.nome} [${this.hp}/${this.hpMax}]`;
    }
}

interface Curavel {
    curar(quantidade: number): void;
}

class Guerreiro extends Personagem {
    constructor(nome: string, hp: number, public forca: number) {
        super(nome, hp);
    }

    atacar(alvo: Personagem): void {
        console.log(`${this.nome} golpeia ${alvo.nome} com a espada!`);
        alvo.receberDano(this.forca);
    }
}

class Mago extends Personagem implements Curavel {
    constructor(
        nome: string,
        hp: number,
        public mana: number,
        public poderMagico: number
    ) {
        super(nome, hp);
    }

    atacar(alvo: Personagem): void {
        if (this.mana < 10) {
            console.log(`${this.nome} tenta lançar magia, mas está sem mana!`);
            return;
        }
        this.mana -= 10;
        console.log(`${this.nome} lança bola de fogo em ${alvo.nome}! (mana: ${this.mana})`);
        alvo.receberDano(this.poderMagico);
    }

    curar(quantidade: number): void {
        if (this.mana >= 5) this.mana -= 5;
        const antes = this.hp;
        this.hp = Math.min(this.hpMax, this.hp + quantidade);
        const ganho = this.hp - antes;
        console.log(`${this.nome} se cura em ${ganho} (HP: ${this.hp}/${this.hpMax}, mana: ${this.mana})`);
    }
}

function simularLuta(a: Personagem, b: Personagem): void {
    console.log(`\n⚔️  LUTA: ${a.nome} vs ${b.nome}\n`);
    const MAX_TURNOS = 20;
    let turno = 1;

    while (a.estaVivo() && b.estaVivo() && turno <= MAX_TURNOS) {
        console.log(`--- Turno ${turno} ---`);
        console.log(`Estado: ${a.status()} | ${b.status()}`);

        a.atacar(b);
        if (!b.estaVivo()) break;

        b.atacar(a);
        turno++;
    }

    console.log("\n=== Fim da luta ===");
    if (a.estaVivo() && !b.estaVivo()) {
        console.log(`🏆 Vencedor: ${a.nome}!`);
    } else if (b.estaVivo() && !a.estaVivo()) {
        console.log(`🏆 Vencedor: ${b.nome}!`);
    } else {
        console.log(`🤝 Empate (ou tempo esgotado)`);
    }
}

function main(): void {
    const aragorn = new Guerreiro("Aragorn", 100, 22);
    const gandalf = new Mago("Gandalf", 80, 50, 30);

    // Mago se cura antes da luta pra mostrar a interface Curavel
    gandalf.receberDano(20);
    gandalf.curar(15);

    simularLuta(aragorn, gandalf);
}

main();
*/
