// 🎯 DESAFIO DO MÓDULO 04 — Jogo de Adivinhação
//
// Objetivo:
// O computador sorteia um número entre 1 e 100. O jogador tenta adivinhar.
// A cada palpite, o programa responde:
//   - "maior"   → se o número certo é MAIOR que o palpite
//   - "menor"   → se o número certo é MENOR que o palpite
//   - "acertou" → quando bater certinho
//
// Regras:
// 1. Sorteie 1..100 com Math.random() ou java.util.Random.
// 2. Leia palpites do teclado em loop com Scanner.
// 3. Limite a 7 tentativas. Se estourar, revela o número e encerra.
// 4. Mostre quantas tentativas faltam após cada palpite.
// 5. Use try-with-resources no Scanner.
// 6. Valide a entrada: se vier letra, avise e continue (sem gastar tentativa).
//
// Exemplo de execução:
//   Sorteei um número de 1 a 100. Você tem 7 tentativas.
//   Palpite #1 (faltam 7): 50
//   maior! (faltam 6)
//   Palpite #2 (faltam 6): 75
//   menor! (faltam 5)
//   Palpite #3 (faltam 5): 62
//   acertou em 3 tentativas! 🎉
//
// 💡 Dicas:
//   - int alvo = (int)(Math.random() * 100) + 1;   // 1..100
//   - Use um int "tentativas" e decremente a cada palpite.
//   - break quando acertar; while (tentativas > 0) controla o limite.
//   - hasNextInt() evita crash quando o usuário digita letra.

import java.util.Scanner;

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        // TODO: implemente o jogo aqui.
        //
        // Roteiro sugerido:
        // 1. Sortear o número-alvo (1..100).
        // 2. Imprimir mensagem de boas-vindas.
        // 3. Abrir Scanner em try-with-resources.
        // 4. Loop while (tentativasRestantes > 0):
        //      - pedir palpite, validar com hasNextInt()
        //      - comparar com o alvo → "maior" / "menor" / "acertou"
        //      - se acertou: break
        //      - decrementar tentativas
        // 5. Se saiu do loop sem acertar, revelar o alvo.
        System.out.println("(escreva seu jogo de adivinhação aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    public static void main(String[] args) {
        final int MAX_TENTATIVAS = 7;
        int alvo = (int) (Math.random() * 100) + 1; // 1..100
        int tentativasRestantes = MAX_TENTATIVAS;
        boolean acertou = false;

        System.out.println("Sorteei um número de 1 a 100. Você tem " + MAX_TENTATIVAS + " tentativas.");

        try (Scanner sc = new Scanner(System.in)) {
            while (tentativasRestantes > 0) {
                int usadas = MAX_TENTATIVAS - tentativasRestantes + 1;
                System.out.printf("Palpite #%d (faltam %d): ", usadas, tentativasRestantes);

                // Validação: se não veio int, avisa e refaz sem gastar tentativa
                if (!sc.hasNextInt()) {
                    System.out.println("Isso não é um número inteiro. Tenta de novo.");
                    sc.next(); // descarta o lixo
                    continue;
                }

                int palpite = sc.nextInt();

                if (palpite < 1 || palpite > 100) {
                    System.out.println("Tem que ser entre 1 e 100. Tenta de novo.");
                    continue;
                }

                if (palpite == alvo) {
                    int total = MAX_TENTATIVAS - tentativasRestantes + 1;
                    System.out.println("acertou em " + total + " tentativa(s)! 🎉");
                    acertou = true;
                    break;
                } else if (palpite < alvo) {
                    tentativasRestantes--;
                    System.out.println("maior! (faltam " + tentativasRestantes + ")");
                } else {
                    tentativasRestantes--;
                    System.out.println("menor! (faltam " + tentativasRestantes + ")");
                }
            }

            if (!acertou) {
                System.out.println("Fim de jogo! O número era " + alvo + ".");
            }
        } // Scanner fecha sozinho aqui
    }
    */
}
