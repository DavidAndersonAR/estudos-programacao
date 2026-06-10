// Módulo 10 — Exceções
// Prática: try/catch/finally, multi-catch, try-with-resources,
// throw, throws e exceção própria.
//
// Rode com: java Main.java
// Dica: alguns exercícios usam Scanner — digite valores quando pedido.

import java.util.InputMismatchException;
import java.util.Scanner;

public class Main {

    // ===========================================================
    // Exceção própria (custom) — usada nos exercícios 4 e 7
    // ===========================================================
    // Extende RuntimeException (unchecked) — não obriga quem chama
    // a tratar. Padrão moderno pra exceções de negócio.
    static class SaldoInsuficienteException extends RuntimeException {
        public SaldoInsuficienteException(String mensagem) {
            super(mensagem); // delega a mensagem pra RuntimeException
        }
    }

    // ===========================================================
    // Exercício 1: divisão por zero (ArithmeticException)
    // ===========================================================
    // Inteiro dividido por zero lança ArithmeticException em runtime.
    // (Curiosidade: com double, 10.0 / 0 dá Infinity — não lança.)
    static void exercicio1() {
        try {
            int a = 10;
            int b = 0;
            int resultado = a / b; // BOOM: ArithmeticException
            System.out.println("Resultado: " + resultado);
        } catch (ArithmeticException e) {
            System.out.println("Erro aritmético: " + e.getMessage());
            // e.getMessage() aqui retorna "/ by zero"
        }
    }

    // ===========================================================
    // Exercício 2: índice fora do array (ArrayIndexOutOfBoundsException)
    // ===========================================================
    static void exercicio2() {
        int[] numeros = {10, 20, 30};
        try {
            System.out.println("Posição 5: " + numeros[5]); // BOOM
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("Índice inválido! Array tem só "
                + numeros.length + " posições. Detalhe: " + e.getMessage());
        }
    }

    // ===========================================================
    // Exercício 3: texto onde se espera número (NumberFormatException)
    // ===========================================================
    // Integer.parseInt lança NumberFormatException se a string
    // não for um número válido.
    static void exercicio3() {
        String entrada = "abc123";
        try {
            int n = Integer.parseInt(entrada);
            System.out.println("Convertido: " + n);
        } catch (NumberFormatException e) {
            System.out.println("'" + entrada + "' não é um número válido.");
        }
    }

    // ===========================================================
    // Exercício 4: criar exceção própria e capturar
    // ===========================================================
    // Simula um saque numa conta. Se o valor passa do saldo,
    // lança SaldoInsuficienteException (definida lá em cima).
    static void sacar(double saldo, double valor) {
        if (valor > saldo) {
            // throw (verbo): lança AGORA
            throw new SaldoInsuficienteException(
                "Saldo de R$" + saldo + " insuficiente para sacar R$" + valor
            );
        }
        System.out.println("Saque de R$" + valor + " aprovado. "
            + "Saldo restante: R$" + (saldo - valor));
    }

    static void exercicio4() {
        try {
            sacar(100.0, 50.0);   // ok
            sacar(100.0, 500.0);  // BOOM: saldo insuficiente
        } catch (SaldoInsuficienteException e) {
            System.out.println("Operação negada: " + e.getMessage());
        }
    }

    // ===========================================================
    // Exercício 5: try-with-resources com Scanner
    // ===========================================================
    // O Scanner implementa AutoCloseable — try-with-resources fecha
    // ele automaticamente, mesmo se der exceção no meio.
    //
    // Aqui usamos um Scanner sobre uma String pra não travar pedindo
    // input do teclado durante a execução automática.
    static void exercicio5() {
        String dadosFalsos = "David\n30\n";
        try (Scanner sc = new Scanner(dadosFalsos)) {
            System.out.print("Digite seu nome: ");
            String nome = sc.nextLine();
            System.out.println(nome);

            System.out.print("Digite sua idade: ");
            int idade = sc.nextInt();
            System.out.println(idade);

            System.out.println("Olá, " + nome + ", " + idade + " anos!");
        } // <- sc.close() chamado automaticamente aqui
        catch (InputMismatchException e) {
            System.out.println("Esperava número e veio outra coisa.");
        }
    }

    // ===========================================================
    // Exercício 6: finally SEMPRE executa
    // ===========================================================
    // Mesmo com return dentro do try, o finally roda antes de sair.
    // Útil pra liberar recursos quando não dá pra usar
    // try-with-resources.
    static String exercicio6() {
        try {
            System.out.println("1. entrando no try");
            String[] vazio = {};
            System.out.println(vazio[0]); // BOOM
            return "valor do try"; // nunca chega aqui
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("2. caí no catch: " + e.getMessage());
            return "valor do catch";
        } finally {
            // executa MESMO com return acima
            System.out.println("3. finally rodou (sempre roda)");
        }
    }

    // ===========================================================
    // Exercício 7: throws na assinatura + multi-catch
    // ===========================================================
    // Esse método DECLARA que pode lançar a exceção.
    // Quem chama escolhe: tratar ou propagar mais pra cima.
    static int converterIdade(String texto) throws NumberFormatException {
        int idade = Integer.parseInt(texto); // pode lançar
        if (idade < 0) {
            // outra exceção possível
            throw new IllegalArgumentException("idade negativa: " + idade);
        }
        return idade;
    }

    static void exercicio7() {
        String[] entradas = {"25", "abc", "-5", "42"};
        for (String entrada : entradas) {
            try {
                int idade = converterIdade(entrada);
                System.out.println("'" + entrada + "' -> idade " + idade);
            } catch (NumberFormatException | IllegalArgumentException e) {
                // multi-catch: mesmo tratamento pros dois tipos
                System.out.println("'" + entrada
                    + "' -> ignorado (" + e.getMessage() + ")");
            }
        }
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: divisão por zero ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: índice fora do array ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: NumberFormatException ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: exceção própria ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: try-with-resources ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: finally sempre executa ===");
        String resultado = exercicio6();
        System.out.println("4. resultado retornado: " + resultado);

        System.out.println("\n=== Exercício 7: throws + multi-catch ===");
        exercicio7();
    }
}
