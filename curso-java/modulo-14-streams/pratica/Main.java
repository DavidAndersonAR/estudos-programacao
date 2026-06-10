// Módulo 14 — Streams API
// Prática: 8 exercícios cobrindo filter, map, reduce, collect, sorted,
// distinct, groupingBy, joining e IntStream.range.
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Main {

    // Exercício 1: filter — só os pares
    // filter recebe um Predicate (n -> boolean) e mantém quem passa.
    static void exercicio1() {
        List<Integer> numeros = List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        List<Integer> pares = numeros.stream()
                .filter(n -> n % 2 == 0)
                .collect(Collectors.toList());

        System.out.println("Pares: " + pares); // [2, 4, 6, 8, 10]
        System.out.println("Original intacta: " + numeros);
    }

    // Exercício 2: map — dobrar cada número
    // map transforma cada elemento aplicando uma Function.
    static void exercicio2() {
        List<Integer> numeros = List.of(1, 2, 3, 4, 5);

        List<Integer> dobrados = numeros.stream()
                .map(n -> n * 2)
                .collect(Collectors.toList());

        System.out.println("Dobrados: " + dobrados); // [2, 4, 6, 8, 10]
    }

    // Exercício 3: reduce — somar tudo
    // reduce combina os elementos dois a dois até sobrar um valor.
    // O primeiro argumento é o valor inicial (identidade).
    static void exercicio3() {
        List<Integer> numeros = List.of(1, 2, 3, 4, 5);

        int soma = numeros.stream()
                .reduce(0, (acc, n) -> acc + n);

        // Forma equivalente com Integer::sum
        int soma2 = numeros.stream().reduce(0, Integer::sum);

        // Forma mais idiomática para somar inteiros:
        int soma3 = numeros.stream().mapToInt(Integer::intValue).sum();

        System.out.println("Soma (reduce): " + soma);   // 15
        System.out.println("Soma (sum):    " + soma2);  // 15
        System.out.println("Soma (IntStream): " + soma3); // 15
    }

    // Exercício 4: count — quantos elementos passam num filtro?
    static void exercicio4() {
        List<String> palavras = List.of("java", "go", "python", "rust", "c", "kotlin");

        long longas = palavras.stream()
                .filter(p -> p.length() >= 4)
                .count();

        System.out.println("Palavras com 4+ letras: " + longas); // 4
    }

    // Exercício 5: sorted — ordenar
    // sorted() usa a ordem natural. Pra ordem customizada, passe um Comparator.
    static void exercicio5() {
        List<String> nomes = List.of("Carlos", "Ana", "Bruno", "Daniel");

        List<String> ordemAlfabetica = nomes.stream()
                .sorted()
                .collect(Collectors.toList());

        List<String> porTamanho = nomes.stream()
                .sorted((a, b) -> a.length() - b.length())
                .collect(Collectors.toList());

        System.out.println("Alfabética: " + ordemAlfabetica);
        System.out.println("Por tamanho: " + porTamanho);
    }

    // Exercício 6: distinct + groupingBy
    // distinct remove duplicados. groupingBy agrupa em um Map por critério.
    static void exercicio6() {
        List<String> palavras = List.of("ana", "bia", "ana", "bruno", "bia", "carlos");

        // Sem duplicados
        List<String> unicas = palavras.stream()
                .distinct()
                .collect(Collectors.toList());
        System.out.println("Únicas: " + unicas);

        // Agrupar por primeira letra
        Map<Character, List<String>> porLetra = palavras.stream()
                .distinct()
                .collect(Collectors.groupingBy(s -> s.charAt(0)));
        System.out.println("Por letra inicial: " + porLetra);

        // Contar quantas vezes cada palavra aparece
        Map<String, Long> contagem = palavras.stream()
                .collect(Collectors.groupingBy(s -> s, Collectors.counting()));
        System.out.println("Contagem: " + contagem);
    }

    // Exercício 7: joining — juntar strings com separador
    // joining(separador, prefixo, sufixo) é ótimo pra montar CSVs e logs.
    static void exercicio7() {
        List<String> linguagens = List.of("Java", "Go", "Rust", "Python");

        String csv = linguagens.stream()
                .collect(Collectors.joining(", "));

        String entreColchetes = linguagens.stream()
                .map(String::toUpperCase)
                .collect(Collectors.joining(", ", "[", "]"));

        System.out.println("CSV: " + csv);
        System.out.println("Formatado: " + entreColchetes);
    }

    // Exercício 8: IntStream.range — gerar faixa de números
    // range(a, b) vai de a até b-1. rangeClosed(a, b) vai até b.
    static void exercicio8() {
        // Soma de 1 a 100
        int somaAte100 = IntStream.rangeClosed(1, 100).sum();
        System.out.println("Soma 1..100: " + somaAte100); // 5050

        // Tabuada do 7
        System.out.print("Tabuada do 7: ");
        IntStream.rangeClosed(1, 10)
                .map(n -> n * 7)
                .forEach(n -> System.out.print(n + " "));
        System.out.println();

        // Quadrados pares de 1 a 20 — coletados em List
        List<Integer> quadradosPares = IntStream.rangeClosed(1, 20)
                .filter(n -> n % 2 == 0)
                .map(n -> n * n)
                .boxed() // IntStream -> Stream<Integer>
                .collect(Collectors.toList());
        System.out.println("Quadrados pares: " + quadradosPares);
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: filter — pares ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: map — dobrar ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: reduce — somar ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: count ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: sorted ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: distinct + groupingBy ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: joining ===");
        exercicio7();

        System.out.println("\n=== Exercício 8: IntStream.range ===");
        exercicio8();
    }
}
