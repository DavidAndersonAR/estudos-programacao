// Módulo 13 — Lambdas e Functional Interfaces
// Prática: 7 exercícios cobrindo lambdas, interfaces de java.util.function,
// method reference e Functional Interface própria.
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.BiFunction;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.function.Supplier;

public class Main {

    // Exercício 1: Lambda como variável usando Function<T, R>
    // Function<Integer, Integer> = recebe Integer, devolve Integer.
    // A lambda "n -> n * 2" é o comportamento atribuído à variável.
    static void exercicio1() {
        Function<Integer, Integer> dobrar = n -> n * 2;
        Function<Integer, Integer> aoQuadrado = n -> n * n;

        System.out.println("dobrar(5) = " + dobrar.apply(5));         // 10
        System.out.println("aoQuadrado(7) = " + aoQuadrado.apply(7)); // 49
    }

    // Exercício 2: Predicate<T> filtrando lista manualmente
    // Predicate.test(T) devolve boolean. Aqui filtramos números pares.
    static void exercicio2() {
        List<Integer> numeros = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        Predicate<Integer> ehPar = n -> n % 2 == 0;

        List<Integer> pares = new ArrayList<>();
        for (Integer n : numeros) {
            if (ehPar.test(n)) {
                pares.add(n);
            }
        }
        System.out.println("Pares: " + pares); // [2, 4, 6, 8, 10]

        // Bônus: combinando Predicates com .and()
        Predicate<Integer> maiorQue4 = n -> n > 4;
        Predicate<Integer> parEMaiorQue4 = ehPar.and(maiorQue4);

        List<Integer> filtrados = new ArrayList<>();
        for (Integer n : numeros) {
            if (parEMaiorQue4.test(n)) filtrados.add(n);
        }
        System.out.println("Pares > 4: " + filtrados); // [6, 8, 10]
    }

    // Exercício 3: Consumer<T> iterando lista
    // Consumer.accept(T) não devolve nada — é "faz alguma coisa com o valor".
    // forEach de List recebe um Consumer.
    static void exercicio3() {
        List<String> nomes = Arrays.asList("Ana", "Bruno", "Carla");

        Consumer<String> imprimir = nome -> System.out.println("> " + nome);
        nomes.forEach(imprimir);

        // forEach com Consumer direto (lambda inline)
        nomes.forEach(nome -> System.out.println("Olá, " + nome + "!"));
    }

    // Exercício 4: Supplier<T> gerando valor sob demanda
    // Supplier.get() não recebe argumento, devolve T.
    // Útil pra "fábricas" simples ou valores calculados na hora.
    static void exercicio4() {
        Supplier<Double> aleatorio = () -> Math.random();
        Supplier<String> saudacao = () -> "Olá, mundo!";
        Supplier<List<String>> listaVazia = () -> new ArrayList<>();

        System.out.println("Aleatório: " + aleatorio.get());
        System.out.println("Saudação: " + saudacao.get());
        System.out.println("Lista nova: " + listaVazia.get());

        // Cada get() é uma nova chamada — Supplier é "preguiçoso"
        System.out.println("Outro aleatório: " + aleatorio.get());
    }

    // Exercício 5: BiFunction<T, U, R>
    // Recebe dois argumentos (podem ser tipos diferentes) e devolve um terceiro.
    static void exercicio5() {
        BiFunction<Integer, Integer, Integer> soma = (a, b) -> a + b;
        BiFunction<String, Integer, String> repetir = (texto, vezes) -> texto.repeat(vezes);
        BiFunction<String, String, String> juntar = (a, b) -> a + " " + b;

        System.out.println("soma(3, 4) = " + soma.apply(3, 4));            // 7
        System.out.println("repetir(\"oi \", 3) = " + repetir.apply("oi ", 3)); // oi oi oi
        System.out.println("juntar = " + juntar.apply("Olá,", "mundo!"));   // Olá, mundo!
    }

    // Exercício 6: Method reference
    // Quando a lambda só repassa o argumento pra um método, troca por Classe::metodo.
    static void exercicio6() {
        // Método estático: Integer.parseInt(String)
        Function<String, Integer> parsear = Integer::parseInt;
        System.out.println("parsear(\"42\") = " + parsear.apply("42"));

        // Método de instância de um tipo: String.length()
        Function<String, Integer> tamanho = String::length;
        System.out.println("tamanho(\"lambda\") = " + tamanho.apply("lambda"));

        // Método de instância de objeto específico: System.out::println
        Consumer<String> imprime = System.out::println;
        imprime.accept("Imprimindo via method reference");

        // Comparando lambda x method reference
        Function<String, String> upperLambda = s -> s.toUpperCase();
        Function<String, String> upperRef = String::toUpperCase;
        System.out.println(upperLambda.apply("ola"));
        System.out.println(upperRef.apply("ola"));
    }

    // Exercício 7: Criar uma Functional Interface própria
    // @FunctionalInterface garante "exatamente 1 método abstrato".
    @FunctionalInterface
    interface Calculadora {
        double calcular(double a, double b);
        // Métodos default e static são permitidos
        default String descricao() {
            return "Sou uma calculadora";
        }
    }

    static void exercicio7() {
        Calculadora soma = (a, b) -> a + b;
        Calculadora subtracao = (a, b) -> a - b;
        Calculadora multiplicacao = (a, b) -> a * b;
        Calculadora divisao = (a, b) -> {
            if (b == 0) throw new ArithmeticException("divisão por zero");
            return a / b;
        };

        System.out.println("soma: " + soma.calcular(10, 3));            // 13.0
        System.out.println("subtracao: " + subtracao.calcular(10, 3));  // 7.0
        System.out.println("multiplicacao: " + multiplicacao.calcular(10, 3)); // 30.0
        System.out.println("divisao: " + divisao.calcular(10, 3));      // ~3.33
        System.out.println(soma.descricao()); // método default
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Function como variável ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: Predicate filtrando ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Consumer iterando ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Supplier gerando ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: BiFunction ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Method reference ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Functional Interface própria ===");
        exercicio7();
    }
}
