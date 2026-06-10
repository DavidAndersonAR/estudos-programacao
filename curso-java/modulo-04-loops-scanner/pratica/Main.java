// Módulo 04 — Loops e Scanner
// Prática: for, for-each, while, do-while, break/continue e Scanner.
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

import java.util.Scanner;

public class Main {

    // Exercício 1: somar 1 a N usando for clássico
    // Mostra o for tradicional acumulando um valor.
    static void exercicio1() {
        int n = 10;
        int soma = 0;
        for (int i = 1; i <= n; i++) {
            soma += i; // mesmo que: soma = soma + i
        }
        System.out.println("Soma de 1 a " + n + " = " + soma);
    }

    // Exercício 2: tabuada com for aninhado
    // Um for de fora (i) controla qual tabuada; o de dentro (j) multiplica de 1 a 10.
    static void exercicio2() {
        for (int i = 1; i <= 3; i++) {
            System.out.println("--- Tabuada do " + i + " ---");
            for (int j = 1; j <= 10; j++) {
                System.out.printf("%d x %d = %d%n", i, j, i * j);
            }
        }
    }

    // Exercício 3: while com break
    // Roda até achar o primeiro número divisível por 7 acima de 50.
    static void exercicio3() {
        int n = 50;
        while (true) { // loop "infinito" controlado por break
            n++;
            if (n % 7 == 0) {
                System.out.println("Primeiro múltiplo de 7 depois de 50: " + n);
                break; // sai do while
            }
        }
    }

    // Exercício 4: contar caracteres com for-each
    // Conta quantas vogais existem num array de char.
    static void exercicio4() {
        char[] letras = {'j', 'a', 'v', 'a', ' ', 'r', 'o', 'c', 'k', 's'};
        int vogais = 0;
        for (char c : letras) {              // para cada char c em letras
            if ("aeiouAEIOU".indexOf(c) >= 0) {
                vogais++;
            }
        }
        System.out.println("Vogais encontradas: " + vogais);
    }

    // Exercício 5: do-while
    // Sorteia números até cair um maior que 90 (garante pelo menos um sorteio).
    static void exercicio5() {
        int sorteado;
        int tentativas = 0;
        do {
            sorteado = (int) (Math.random() * 100) + 1; // 1..100
            tentativas++;
            System.out.println("Sorteou: " + sorteado);
        } while (sorteado <= 90);
        System.out.println("Achou " + sorteado + " em " + tentativas + " tentativa(s).");
    }

    // Exercício 6: Scanner lendo nome (try-with-resources)
    // O Scanner é declarado dentro do try — fecha sozinho no fim.
    // Obs: comentei a leitura real pra você poder rodar o Main inteiro sem travar.
    //      Descomente quando quiser testar interativo.
    static void exercicio6() {
        /*
        try (Scanner sc = new Scanner(System.in)) {
            System.out.print("Qual é o seu nome? ");
            String nome = sc.nextLine();
            System.out.println("Prazer, " + nome + "!");
        } // sc.close() automático aqui
        */
        System.out.println("(exercicio6 — descomente o bloco pra testar leitura do teclado)");
    }

    // Exercício 7: Scanner lendo número com validação
    // Usa hasNextInt() pra não quebrar se digitar letra; repete até vir um int válido.
    static void exercicio7() {
        /*
        try (Scanner sc = new Scanner(System.in)) {
            int idade;
            while (true) {
                System.out.print("Digite sua idade (int): ");
                if (sc.hasNextInt()) {
                    idade = sc.nextInt();
                    if (idade >= 0 && idade < 130) break;
                    System.out.println("Idade fora da faixa. Tente de novo.");
                } else {
                    System.out.println("Isso não é um número. Tente de novo.");
                    sc.next(); // descarta o token inválido
                }
            }
            System.out.println("Idade registrada: " + idade);
        }
        */
        System.out.println("(exercicio7 — descomente o bloco pra testar leitura validada)");
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: soma 1..N (for) ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: tabuada (for aninhado) ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: while com break ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: for-each contando vogais ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: do-while sorteando ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Scanner lê nome ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Scanner valida número ===");
        exercicio7();
    }
}
