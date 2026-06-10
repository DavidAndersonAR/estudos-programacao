// Módulo 03 — Condicionais
// Prática: if/else, switch clássico, switch expression e ternário.
//
// Rode com: java Main.java   (JDK 11+, mas switch expression precisa de JDK 14+)
// Ou:       javac Main.java && java Main

public class Main {

    // Exercício 1: par ou ímpar
    // O resto da divisão por 2 indica paridade.
    // Operador % (módulo) devolve o resto: 10 % 2 == 0, 7 % 2 == 1.
    static void exercicio1() {
        int numero = 7;

        if (numero % 2 == 0) {
            System.out.println(numero + " é par");
        } else {
            System.out.println(numero + " é ímpar");
        }
    }

    // Exercício 2: FizzBuzz (versão de um número)
    // Múltiplo de 3 → "Fizz", de 5 → "Buzz", de 15 → "FizzBuzz".
    // A ordem dos ifs importa: testa o "mais específico" (15) primeiro.
    static void exercicio2() {
        int numero = 15;

        if (numero % 15 == 0) {
            System.out.println("FizzBuzz");
        } else if (numero % 3 == 0) {
            System.out.println("Fizz");
        } else if (numero % 5 == 0) {
            System.out.println("Buzz");
        } else {
            System.out.println(String.valueOf(numero));
        }
    }

    // Exercício 3: classificar nota com if-else
    // Cadeia de else if testa de cima pra baixo.
    static void exercicio3() {
        double nota = 8.5;

        if (nota >= 9.0) {
            System.out.println("Conceito A");
        } else if (nota >= 7.0) {
            System.out.println("Conceito B");
        } else if (nota >= 5.0) {
            System.out.println("Conceito C");
        } else if (nota >= 3.0) {
            System.out.println("Conceito D");
        } else {
            System.out.println("Conceito F (reprovado)");
        }
    }

    // Exercício 4: dia da semana com switch CLÁSSICO
    // Note os 'break' obrigatórios pra não cair no próximo case.
    static void exercicio4() {
        int dia = 4;

        switch (dia) {
            case 1:
                System.out.println("Segunda");
                break;
            case 2:
                System.out.println("Terça");
                break;
            case 3:
                System.out.println("Quarta");
                break;
            case 4:
                System.out.println("Quinta");
                break;
            case 5:
                System.out.println("Sexta");
                break;
            case 6:
            case 7:
                System.out.println("Fim de semana");
                break;
            default:
                System.out.println("Dia inválido");
        }
    }

    // Exercício 5: dia da semana com SWITCH EXPRESSION (Java 14+)
    // Sem break, sem fall-through, com múltiplos labels e retorno de valor.
    static void exercicio5() {
        int dia = 6;

        String nome = switch (dia) {
            case 1 -> "Segunda";
            case 2 -> "Terça";
            case 3 -> "Quarta";
            case 4 -> "Quinta";
            case 5 -> "Sexta";
            case 6, 7 -> "Fim de semana"; // múltiplos labels em um case
            default -> "Dia inválido";
        };

        System.out.println("Dia " + dia + ": " + nome);
    }

    // Exercício 6: maior de dois com TERNÁRIO
    // Forma: condicao ? valorSeTrue : valorSeFalse
    // Ideal quando o if/else só serve pra escolher um valor.
    static void exercicio6() {
        int a = 12;
        int b = 30;

        int maior = (a > b) ? a : b;
        System.out.println("Maior entre " + a + " e " + b + ": " + maior);

        // Ternário aninhado dá pra fazer, mas legibilidade despenca rápido.
        // Use com moderação.
        int c = 25;
        int maiorDos3 = (a > b)
                ? (a > c ? a : c)
                : (b > c ? b : c);
        System.out.println("Maior dos 3: " + maiorDos3);
    }

    // Exercício 7: validação de senha
    // Combina operadores lógicos (&&) e de comparação (>=, !=).
    // Regras: mínimo 8 caracteres, diferente de "12345678", não pode ser nula/vazia.
    static void exercicio7() {
        String senha = "MinhaS3nha!";

        boolean tamanhoOk = senha != null && senha.length() >= 8;
        boolean naoEhObvia = !senha.equals("12345678") && !senha.equals("senha123");

        if (tamanhoOk && naoEhObvia) {
            System.out.println("Senha aceita");
        } else {
            // Detalhamento usando ternário pra mensagem
            String motivo = !tamanhoOk ? "tamanho menor que 8" : "senha óbvia demais";
            System.out.println("Senha recusada: " + motivo);
        }
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: par ou ímpar ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: FizzBuzz ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: classificar nota (if-else) ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: dia (switch clássico) ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: dia (switch expression) ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: maior de 2 (ternário) ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: validação de senha ===");
        exercicio7();
    }
}
