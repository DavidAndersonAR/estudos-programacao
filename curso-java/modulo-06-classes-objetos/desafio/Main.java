// 🎯 DESAFIO DO MÓDULO 06 — Sistema de Personagens (Batalha Ninja)
//
// Objetivo:
// Criar um mini-sistema de batalha entre ninjas, exercitando classes, objetos,
// métodos com parâmetros, e — o mais importante — a diferença entre
// REFERÊNCIA de memória (objetos) e VALOR em memória (primitivos).
//
// Requisitos:
// 1. Crie uma classe interna `Ninja` com os campos:
//      - String nome
//      - String cla    (ex: "Uzumaki", "Uchiha")
//      - int hp        (pontos de vida)
//      - int dano      (quanto causa por ataque)
//      - int chakra    (quanto gasta por ataque)
// 2. Implemente os métodos de instância:
//      - void atacar(Ninja alvo)   → reduz hp do alvo em "dano" e gasta chakra
//      - boolean estaVivo()        → true se hp > 0
//      - @Override toString()      → ex.: "Naruto/Uzumaki (HP=80, Dano=15, Chakra=200)"
// 3. No main:
//      - Crie 3 ninjas com nomes, clãs, hp e dano diferentes.
//      - Demonstre REFERÊNCIA vs VALOR antes da batalha começar (veja dica abaixo).
//      - Faça uma luta em loop: enquanto houver pelo menos 2 vivos,
//        cada ninja vivo ataca o próximo (em rodízio).
//      - Imprima o estado depois de cada rodada (usando toString()).
//      - Anuncie quem sobrou (ou empate, se todos caírem na mesma rodada).
//
// Exemplo de saída esperada (resumida):
//
//   --- Rodada 1 ---
//   Naruto atacou Sasuke causando 25 de dano.
//   Sasuke atacou Kakashi causando 30 de dano.
//   Kakashi atacou Naruto causando 20 de dano.
//   Estado: Naruto/Uzumaki (HP=80, Dano=25, Chakra=180) | ...
//   ...
//   🏆 Vencedor: Naruto Uzumaki!
//
// 💡 Dicas:
//   - Use um array Ninja[] pra guardar os 3 e percorrer com loop.
//   - O alvo do ninja na posição i pode ser (i+1) % tamanho (rodízio circular).
//   - Pule turnos de quem já morreu (if (!n.estaVivo()) continue;).
//   - Pra evitar loop infinito, tenha um teto de rodadas (ex: 50).
//   - Demonstre referência: crie uma cópia (Ninja outro = naruto;), mude um campo
//     pelo "outro" e veja que mexeu no naruto também. ANTES de iniciar a batalha.

public class Main {

    // ============================
    // SUA CLASSE NINJA AQUI
    // ============================
    static class Ninja {
        // TODO: declare os campos nome, cla, hp, dano, chakra

        // TODO: implemente atacar(Ninja alvo)

        // TODO: implemente estaVivo()

        // TODO: sobrescreva toString()
    }

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================
    public static void main(String[] args) {
        // TODO:
        // 1. crie 3 Ninja com new e preencha os campos
        // 2. (opcional) demonstre referência vs valor antes da batalha
        // 3. coloque os ninjas num array
        // 4. simule rodadas até sobrar 1 (ou todos morrerem)
        // 5. imprima o vencedor
        System.out.println("(implemente seu sistema de batalha ninja aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente pra conferir depois de tentar)
    // ============================

    /*
    static class Ninja {
        String nome;
        String cla;
        int hp;
        int dano;
        int chakra;

        // Método de instância COM PARÂMETRO: reduz o hp do alvo (que é outro Ninja).
        // Como objetos são REFERÊNCIAS, alterar alvo.hp mexe no objeto original lá fora.
        void atacar(Ninja alvo) {
            alvo.hp = alvo.hp - this.dano;
            if (alvo.hp < 0) alvo.hp = 0;        // evita HP negativo na exibição
            this.chakra = this.chakra - 20;      // ataque gasta chakra do atacante
            if (this.chakra < 0) this.chakra = 0;
            System.out.println(this.nome + " atacou " + alvo.nome
                    + " causando " + this.dano + " de dano.");
        }

        boolean estaVivo() {
            return this.hp > 0;
        }

        @Override
        public String toString() {
            return nome + "/" + cla + " (HP=" + hp + ", Dano=" + dano + ", Chakra=" + chakra + ")";
        }
    }

    public static void main(String[] args) {
        // 1) criação dos ninjas
        Ninja naruto = new Ninja();
        naruto.nome = "Naruto";  naruto.cla = "Uzumaki";
        naruto.hp = 120; naruto.dano = 25; naruto.chakra = 200;

        Ninja sasuke = new Ninja();
        sasuke.nome = "Sasuke";  sasuke.cla = "Uchiha";
        sasuke.hp = 110; sasuke.dano = 30; sasuke.chakra = 180;

        Ninja kakashi = new Ninja();
        kakashi.nome = "Kakashi"; kakashi.cla = "Hatake";
        kakashi.hp = 100; kakashi.dano = 20; kakashi.chakra = 220;

        // 2) DEMONSTRAÇÃO: referência vs valor
        System.out.println("=== Antes da batalha: referência vs valor ===");
        int chakraCopia = naruto.chakra;     // primitivo: COPIA o valor
        chakraCopia = 999;                   // mexe só na cópia
        System.out.println("naruto.chakra = " + naruto.chakra + " (não mudou)");
        System.out.println("chakraCopia   = " + chakraCopia + " (mudou só aqui)");

        Ninja outroNaruto = naruto;          // objeto: COPIA A REFERÊNCIA
        outroNaruto.hp = 1;                  // mexe pelo "outroNaruto"...
        System.out.println("naruto.hp = " + naruto.hp + " (mudou também — mesma referência!)");
        naruto.hp = 120;                     // volta pro original pra começar a luta limpo

        // 3) array pra facilitar o loop
        Ninja[] arena = { naruto, sasuke, kakashi };

        // 4) simulação de rodadas
        System.out.println("\n=== Início da batalha ===");
        int rodada = 1;
        int limiteRodadas = 50;              // segurança contra loop infinito

        while (rodada <= limiteRodadas && contarVivos(arena) >= 2) {
            System.out.println("\n--- Rodada " + rodada + " ---");

            for (int i = 0; i < arena.length; i++) {
                Ninja atacante = arena[i];
                if (!atacante.estaVivo()) continue;      // morto não ataca

                Ninja alvo = proximoAlvoVivo(arena, i);
                if (alvo == null) break;                 // ninguém mais pra atacar

                atacante.atacar(alvo);
            }

            // estado da arena depois da rodada
            System.out.print("Estado: ");
            for (int i = 0; i < arena.length; i++) {
                System.out.print(arena[i]);
                if (i < arena.length - 1) System.out.print(" | ");
            }
            System.out.println();

            rodada++;
        }

        // 5) anuncia o vencedor
        System.out.println("\n=== FIM DA BATALHA ===");
        Ninja ultimo = null;
        int vivos = 0;
        for (Ninja n : arena) {
            if (n.estaVivo()) { ultimo = n; vivos++; }
        }
        if (vivos == 1) {
            System.out.println("🏆 Vencedor: " + ultimo.nome + " " + ultimo.cla + " (" + ultimo + ")");
        } else if (vivos == 0) {
            System.out.println("☠️ Todos caíram. A vila chora a perda dos três ninjas.");
        } else {
            System.out.println("⏰ Limite de rodadas atingido. Sobreviventes:");
            for (Ninja n : arena) {
                if (n.estaVivo()) System.out.println("  - " + n);
            }
        }
    }

    // ----------- helpers estáticos -----------

    // Conta quantos ninjas ainda têm hp > 0.
    static int contarVivos(Ninja[] arena) {
        int n = 0;
        for (Ninja x : arena) {
            if (x.estaVivo()) n++;
        }
        return n;
    }

    // Acha o próximo ninja vivo a partir de "depoisDe", em rodízio circular.
    // Devolve null se ninguém mais (além do próprio) estiver vivo.
    static Ninja proximoAlvoVivo(Ninja[] arena, int depoisDe) {
        for (int passo = 1; passo < arena.length; passo++) {
            int idx = (depoisDe + passo) % arena.length;
            if (arena[idx].estaVivo()) return arena[idx];
        }
        return null;
    }
    */
}
