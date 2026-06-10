// Módulo 02 — Variáveis e Tipos
// Prática: declarar variáveis, usar tipos primitivos e referência, conversões, var, final.
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

import java.math.BigDecimal;

public class Main {

    // Exercício 1: Tipos primitivos básicos
    // Declaração clássica: tipo nome = valor;
    static void exercicio1() {
        byte idadeByte = 30;        // byte: -128 a 127
        short ano = 2026;            // short: -32k a 32k
        int populacao = 215_000_000; // int: padrão pra inteiros (note o _ visual)
        long distanciaSol = 149_600_000_000L; // long precisa do sufixo L

        float pi = 3.14f;            // float precisa do sufixo f
        double precisao = 3.141592653589793; // double: padrão pra decimais

        char inicial = 'D';          // aspas SIMPLES
        boolean ativo = true;        // só true ou false

        System.out.println("Idade (byte): " + idadeByte);
        System.out.println("Ano (short): " + ano);
        System.out.println("População (int): " + populacao);
        System.out.println("Distância ao Sol em m (long): " + distanciaSol);
        System.out.println("Pi (float): " + pi);
        System.out.println("Pi mais preciso (double): " + precisao);
        System.out.println("Inicial (char): " + inicial);
        System.out.println("Ativo (boolean): " + ativo);
    }

    // Exercício 2: var — inferência de tipo (Java 10+)
    // O compilador descobre o tipo pelo valor da direita. Só funciona em variável local.
    static void exercicio2() {
        var idade = 30;              // int
        var altura = 1.75;           // double
        var nome = "David";          // String
        var ativo = true;            // boolean

        // var continua sendo estaticamente tipado:
        // idade = "trinta"; // ERRO de compilação — idade já é int pra sempre

        System.out.println("idade=" + idade + " altura=" + altura
                + " nome=" + nome + " ativo=" + ativo);
    }

    // Exercício 3: Conversão implícita (widening) e explícita (casting)
    static void exercicio3() {
        // Widening: cabe sem perda → automático
        int i = 100;
        long l = i;          // int → long, ok
        double d = i;        // int → double, ok
        System.out.println("Widening: i=" + i + " l=" + l + " d=" + d);

        // Narrowing: pode perder informação → casting explícito
        double pi = 3.99;
        int truncado = (int) pi;     // 3 (a parte decimal é jogada fora)
        System.out.println("Casting double→int: " + pi + " vira " + truncado);

        // Pegadinha: int / int = int (divisão inteira)
        int a = 10, b = 3;
        System.out.println("10 / 3 (int): " + (a / b));       // 3
        System.out.println("10 / 3 (double): " + (a / (double) b)); // 3.333...
    }

    // Exercício 4: Constantes com final
    // O valor não pode mudar depois de atribuído. Convenção: MAIÚSCULAS.
    static void exercicio4() {
        final double PI = 3.14159;
        final int MAX_TENTATIVAS = 3;

        // PI = 3.14; // ERRO de compilação — final não muda

        double raio = 2.0;
        double area = PI * raio * raio;
        System.out.println("Área do círculo (raio=2): " + area);
        System.out.println("Máximo de tentativas: " + MAX_TENTATIVAS);
    }

    // Exercício 5: String e métodos básicos
    // String é imutável: os métodos retornam uma string NOVA, não alteram a original.
    static void exercicio5() {
        String nome = "David Anderson";

        int tamanho = nome.length();                  // 14
        String maiusculo = nome.toUpperCase();        // "DAVID ANDERSON"
        String minusculo = nome.toLowerCase();        // "david anderson"
        String primeiroNome = nome.substring(0, 5);   // "David"
        boolean contemDavid = nome.contains("David"); // true

        System.out.println("Original: " + nome);
        System.out.println("Tamanho: " + tamanho);
        System.out.println("Maiúsculo: " + maiusculo);
        System.out.println("Minúsculo: " + minusculo);
        System.out.println("Primeiro nome: " + primeiroNome);
        System.out.println("Contém 'David'? " + contemDavid);
        System.out.println("Original continua: " + nome); // imutável!
    }

    // Exercício 6: Wrappers vs primitivos (Integer vs int)
    // Wrappers são OBJETOS — podem ser null, têm métodos, vão em coleções.
    static void exercicio6() {
        int primitivo = 42;
        Integer wrapper = 42;        // autoboxing: int → Integer

        int desempacotado = wrapper; // unboxing: Integer → int
        System.out.println("Primitivo: " + primitivo);
        System.out.println("Wrapper: " + wrapper);
        System.out.println("Desempacotado: " + desempacotado);

        // Wrapper aceita null; primitivo NÃO
        Integer talvez = null;
        System.out.println("Wrapper pode ser null: " + talvez);

        // Método utilitário no wrapper
        int numero = Integer.parseInt("123"); // converte String → int
        System.out.println("parseInt(\"123\") = " + numero);
        System.out.println("Integer.MAX_VALUE = " + Integer.MAX_VALUE);
    }

    // Exercício 7: O erro de 50 milhões — dinheiro com double vs BigDecimal
    // double APROXIMA decimais em binário. Pra dinheiro, use BigDecimal.
    static void exercicio7() {
        // ERRADO: double com dinheiro
        double a = 0.1;
        double b = 0.2;
        double somaErrada = a + b;
        System.out.println("0.1 + 0.2 com double: " + somaErrada); // 0.30000000000000004

        // CERTO: BigDecimal (passe String no construtor!)
        BigDecimal x = new BigDecimal("0.1");
        BigDecimal y = new BigDecimal("0.2");
        BigDecimal somaCerta = x.add(y);
        System.out.println("0.1 + 0.2 com BigDecimal: " + somaCerta); // 0.3 exato

        // Exemplo prático: preço * quantidade
        BigDecimal preco = new BigDecimal("19.90");
        BigDecimal quantidade = new BigDecimal("3");
        BigDecimal total = preco.multiply(quantidade);
        System.out.println("19.90 * 3 = " + total); // 59.70 exato
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Tipos primitivos ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: var (inferência) ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Conversões (widening e casting) ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Constantes com final ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: String e métodos ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Wrappers vs primitivos ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Dinheiro — double vs BigDecimal ===");
        exercicio7();
    }
}
