// 🎯 DESAFIO DO MÓDULO 03 — Classificador de Notas
//
// Objetivo:
// Dado um array de notas (já hardcoded abaixo), pra cada nota:
//   1. Imprima a nota e o conceito correspondente.
//   2. Use switch expression (Java 14+) com múltiplos labels para mapear
//      a faixa da nota em uma letra.
//   3. No final, mostre uma estatística: quantas notas tiraram cada conceito.
//
// Tabela de conceitos:
//   A → nota >= 9
//   B → nota >= 7 (e < 9)
//   C → nota >= 5 (e < 7)
//   D → nota >= 3 (e < 5)
//   F → nota <  3
//
// Resultado esperado (exemplo):
//
//   Nota 9.5 -> A
//   Nota 7.2 -> B
//   Nota 6.0 -> C
//   Nota 4.0 -> D
//   Nota 2.0 -> F
//   Nota 8.0 -> B
//   Nota 9.8 -> A
//
//   === Estatística ===
//   A: 2
//   B: 2
//   C: 1
//   D: 1
//   F: 1
//
// 💡 Dicas:
//   - O switch expression aceita expressões tipo (int) (nota / 1.0) ou um int
//     já convertido. Aqui o truque é trabalhar com a "faixa" da nota.
//   - Um jeito simples: converta a nota em um "índice de faixa" com (int) nota,
//     e use switch expression com múltiplos labels (case 9, 10 -> "A", etc).
//   - Pra contar quantos A, B, C, D, F, use 5 variáveis int (contA, contB, ...)
//     ou um array int[5].
//   - System.out.printf("Nota %.1f -> %s%n", nota, conceito);

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        double[] notas = { 9.5, 7.2, 6.0, 4.0, 2.0, 8.0, 9.8 };

        // TODO 1: percorra o array com um for-each
        // TODO 2: pra cada nota, calcule o conceito usando switch expression
        //         (dica: use (int) nota como entrada do switch)
        // TODO 3: imprima "Nota X.X -> CONCEITO"
        // TODO 4: incremente contadores conforme o conceito
        // TODO 5: no fim, imprima a estatística

        System.out.println("(implemente o classificador aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    public static void main(String[] args) {
        double[] notas = { 9.5, 7.2, 6.0, 4.0, 2.0, 8.0, 9.8 };

        // contadores: índice 0=A, 1=B, 2=C, 3=D, 4=F
        int[] contagem = new int[5];

        for (double nota : notas) {
            String conceito = classificar(nota);
            System.out.printf("Nota %.1f -> %s%n", nota, conceito);

            // incrementa o contador certo usando switch expression
            int indice = switch (conceito) {
                case "A" -> 0;
                case "B" -> 1;
                case "C" -> 2;
                case "D" -> 3;
                default  -> 4; // "F"
            };
            contagem[indice]++;
        }

        System.out.println();
        System.out.println("=== Estatística ===");
        System.out.println("A: " + contagem[0]);
        System.out.println("B: " + contagem[1]);
        System.out.println("C: " + contagem[2]);
        System.out.println("D: " + contagem[3]);
        System.out.println("F: " + contagem[4]);
    }

    // Classifica uma nota em A/B/C/D/F usando switch expression.
    // Trabalhamos com (int) nota pra cair em "faixas inteiras":
    //   9 e 10 -> A
    //   7 e 8  -> B
    //   5 e 6  -> C
    //   3 e 4  -> D
    //   0,1,2  -> F
    static String classificar(double nota) {
        int faixa = (int) nota; // 9.5 -> 9, 7.2 -> 7, 2.0 -> 2

        return switch (faixa) {
            case 9, 10     -> "A";
            case 7, 8      -> "B";
            case 5, 6      -> "C";
            case 3, 4      -> "D";
            default        -> "F"; // 0, 1, 2 (e qualquer valor fora do esperado)
        };
    }
    */
}
