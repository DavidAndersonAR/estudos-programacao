// Módulo 15 — Java Moderno (Optional, Records, Sealed, Pattern Matching)
// Prática: 7 exercícios cobrindo os recursos modernos do Java 14-21.
//
// Rode com: java --enable-preview --source 21 Main.java
// Ou só:    java Main.java   (JDK 21+ — tudo aqui já é estável)

import java.util.Optional;

public class Main {

    // ============================================================
    // Exercício 1: Optional — criação e leitura básica
    // ------------------------------------------------------------
    // Optional<T> é uma "caixinha" que ou tem valor, ou está vazia.
    // Substitui o uso de null em retornos de método.
    // ============================================================
    static void exercicio1() {
        Optional<String> cheio = Optional.of("Java");
        Optional<String> vazio = Optional.empty();

        // isPresent() / isEmpty() — checa se tem valor
        System.out.println("cheio tem valor? " + cheio.isPresent()); // true
        System.out.println("vazio está vazio? " + vazio.isEmpty()); // true

        // orElse — pega o valor OU um padrão se estiver vazio
        System.out.println("cheio.orElse: " + cheio.orElse("(nada)")); // Java
        System.out.println("vazio.orElse: " + vazio.orElse("(nada)")); // (nada)

        // ifPresent — só roda se tiver valor (evita o if)
        cheio.ifPresent(v -> System.out.println("achei: " + v));
        vazio.ifPresent(v -> System.out.println("não vai imprimir"));
    }

    // ============================================================
    // Exercício 2: Optional — encadear map / filter
    // ------------------------------------------------------------
    // O pulo do gato: tratar valor possivelmente ausente como pipeline.
    // ============================================================
    static void exercicio2() {
        Optional<String> nome = Optional.of("david anderson");

        // map: transforma o valor (se existir) — continua dentro do Optional
        // filter: mantém o valor só se passar no teste
        String resultado = nome
                .map(String::toUpperCase)              // "DAVID ANDERSON"
                .filter(s -> s.startsWith("D"))         // continua presente
                .orElse("ANÔNIMO");
        System.out.println("Pipeline 1: " + resultado); // DAVID ANDERSON

        // Quando o filter elimina, cai no orElse
        String resultado2 = Optional.of("ana")
                .map(String::toUpperCase)              // "ANA"
                .filter(s -> s.length() > 5)            // some — só 3 chars
                .orElse("CURTO DEMAIS");
        System.out.println("Pipeline 2: " + resultado2); // CURTO DEMAIS

        // Optional.empty() ignora map/filter — vai direto pro orElse
        String resultado3 = Optional.<String>empty()
                .map(String::toUpperCase)
                .orElse("VAZIO");
        System.out.println("Pipeline 3: " + resultado3); // VAZIO
    }

    // ============================================================
    // Exercício 3: record — declaração básica
    // ------------------------------------------------------------
    // Substitui um POJO inteiro: construtor, getters, equals,
    // hashCode e toString vêm de graça.
    // ============================================================

    // Repare: UMA LINHA. Sem getters, sem nada.
    record Pessoa(String nome, int idade) {}

    static void exercicio3() {
        Pessoa p = new Pessoa("David", 30);

        // Acesso aos campos: SEM prefixo "get"
        System.out.println("nome: " + p.nome());       // David
        System.out.println("idade: " + p.idade());     // 30

        // toString automático e bonitinho
        System.out.println("toString: " + p);          // Pessoa[nome=David, idade=30]
    }

    // ============================================================
    // Exercício 4: record — equals e hashCode automáticos
    // ------------------------------------------------------------
    // Dois records são "iguais" se TODOS os campos forem iguais.
    // Em classe comum, equals compara REFERÊNCIA (==) por padrão.
    // ============================================================
    static void exercicio4() {
        Pessoa p1 = new Pessoa("David", 30);
        Pessoa p2 = new Pessoa("David", 30); // mesmos dados, objeto diferente
        Pessoa p3 = new Pessoa("Ana", 25);

        System.out.println("p1 == p2 (referência): " + (p1 == p2));     // false
        System.out.println("p1.equals(p2) (valor): " + p1.equals(p2));  // true ✅
        System.out.println("p1.equals(p3):           " + p1.equals(p3)); // false

        // hashCode também bate quando o conteúdo bate — útil em HashMap/HashSet
        System.out.println("hash p1: " + p1.hashCode());
        System.out.println("hash p2: " + p2.hashCode()); // igual ao p1
    }

    // ============================================================
    // Exercício 5: pattern matching para instanceof
    // ------------------------------------------------------------
    // Antes: precisava fazer cast manual após o instanceof.
    // Agora: a variável tipada já sai pronta.
    // ============================================================
    static void descrever(Object obj) {
        // Padrão antigo (não use mais):
        //   if (obj instanceof String) {
        //       String s = (String) obj;  // cast manual feio
        //       ...
        //   }

        if (obj instanceof String s) {
            System.out.println("é String de " + s.length() + " chars: " + s);
        } else if (obj instanceof Integer i && i > 0) {
            // dá pra usar a variável JÁ no mesmo if, com &&
            System.out.println("é Integer positivo: " + i);
        } else if (obj instanceof Double d) {
            System.out.printf("é Double: %.2f%n", d);
        } else {
            System.out.println("outro tipo: " + obj);
        }
    }

    static void exercicio5() {
        descrever("Olá");
        descrever(42);
        descrever(3.14);
        descrever(true);
    }

    // ============================================================
    // Exercício 6: sealed interface + records
    // ------------------------------------------------------------
    // "sealed" diz EXATAMENTE quem pode implementar a interface.
    // Records combinam perfeitamente porque já são final.
    // ============================================================

    sealed interface Forma permits Circulo, Quadrado, Triangulo {}
    record Circulo(double raio) implements Forma {}
    record Quadrado(double lado) implements Forma {}
    record Triangulo(double base, double altura) implements Forma {}

    static void exercicio6() {
        Forma f1 = new Circulo(5);
        Forma f2 = new Quadrado(3);
        Forma f3 = new Triangulo(4, 6);

        // Cada uma sabe seu próprio tipo pelo toString do record
        System.out.println(f1); // Circulo[raio=5.0]
        System.out.println(f2); // Quadrado[lado=3.0]
        System.out.println(f3); // Triangulo[base=4.0, altura=6.0]

        // Note: ninguém fora deste arquivo pode criar uma Forma nova,
        // o compilador garante. Isso destrava o switch do próximo exercício.
    }

    // ============================================================
    // Exercício 7: switch expression com pattern matching
    // ------------------------------------------------------------
    // Java 21: switch sabe casar TIPOS e já cria a variável.
    // Combinado com sealed, o compilador exige que você cubra
    // TODOS os casos — adeus default esquecido.
    // ============================================================
    static double area(Forma f) {
        return switch (f) {
            case Circulo c   -> Math.PI * c.raio() * c.raio();
            case Quadrado q  -> q.lado() * q.lado();
            case Triangulo t -> t.base() * t.altura() / 2;
            // sem default! sealed garante exaustividade.
        };
    }

    static void exercicio7() {
        Forma[] formas = {
                new Circulo(5),
                new Quadrado(4),
                new Triangulo(3, 6),
        };

        for (Forma f : formas) {
            System.out.printf("Área de %s = %.2f%n", f, area(f));
        }

        // Bônus: TEXT BLOCK — string multi-linha com """..."""
        // Útil pra JSON, SQL, HTML, mensagens longas.
        String json = """
                {
                  "forma": "Circulo",
                  "raio": 5,
                  "area": %.2f
                }
                """.formatted(area(new Circulo(5)));
        System.out.println("\nText block (JSON):");
        System.out.println(json);
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Optional básico ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: Optional pipeline ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: record básico ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: equals automático ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: pattern matching instanceof ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: sealed interface ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: switch expression + text block ===");
        exercicio7();
    }
}
