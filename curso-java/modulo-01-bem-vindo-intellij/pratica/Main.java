// Módulo 01 — Bem-vindo + IntelliJ
// Prática: formas básicas de imprimir e estruturar um programa Java.
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

public class Main {

    // Exercício 1: Hello World tradicional
    // O programa mais simples possível em Java.
    static void exercicio1() {
        System.out.println("Olá, mundo!");
    }

    // Exercício 2: Várias linhas com println
    // Cada println pula uma linha no final.
    static void exercicio2() {
        System.out.println("Linha 1");
        System.out.println("Linha 2");
        System.out.println("Linha 3");
    }

    // Exercício 3: print (sem quebra automática) vs println
    static void exercicio3() {
        System.out.print("sem ");
        System.out.print("quebra ");
        System.out.print("automática\n"); // quebra manual com \n
        System.out.println("agora sim, com quebra");
    }

    // Exercício 4: printf — formatação com placeholders
    // %s = string, %d = inteiro, %f = decimal, %n = quebra de linha portável
    static void exercicio4() {
        String nome = "David";
        int idade = 30;
        double altura = 1.75;

        System.out.printf("Nome: %s%n", nome);
        System.out.printf("Idade: %d anos%n", idade);
        System.out.printf("Altura: %.2f m%n", altura); // 2 casas decimais
        System.out.printf("Resumo: %s, %d, %.2f m%n", nome, idade, altura);
    }

    // Exercício 5: Concatenação de strings
    // Você pode juntar textos com + (Java converte automaticamente).
    static void exercicio5() {
        String saudacao = "Olá";
        String nome = "mundo";
        int ano = 2026;

        String mensagem = saudacao + ", " + nome + "! Ano " + ano + ".";
        System.out.println(mensagem);

        // Também dá pra usar String.format (parecido com printf)
        String outra = String.format("%s, %s! Ano %d.", saudacao, nome, ano);
        System.out.println(outra);
    }

    // Exercício 6: Comentários
    // Linha (//), bloco (/* ... */), Javadoc (/** ... */)
    static void exercicio6() {
        // Isso é um comentário de linha
        int x = 10;

        /* Isso é um comentário
           de bloco, pode ter
           várias linhas */
        int y = 20;

        /**
         * Isso é um Javadoc — fica em cima de classes, métodos.
         * Ferramentas geram documentação HTML a partir dele.
         */
        System.out.println(x + y);
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Hello World ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: Várias linhas ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: print vs println ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: printf ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: Concatenação ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Comentários ===");
        exercicio6();
    }
}
