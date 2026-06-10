// Módulo 09 — Abstração e Interfaces (PRÁTICA)
// Tema: Naruto. Mostramos classe abstrata, interfaces, default methods,
// implementação múltipla e a combinação polimorfismo + abstração.
//
// Rode com: java Main.java   (JDK 11+)

public class Main {

    // ============================================================
    // Classe ABSTRATA: Ninja
    // - tem estado (nome, vila) e construtor
    // - tem método concreto (apresentar) E método abstrato (habilidade)
    // - NÃO pode ser instanciada direto: new Ninja(...) NÃO compila
    // ============================================================
    static abstract class Ninja {
        protected String nome;
        protected String vila;

        public Ninja(String nome, String vila) {
            this.nome = nome;
            this.vila = vila;
        }

        // Método CONCRETO: filhas herdam pronto.
        public void apresentar() {
            System.out.println("Eu sou " + nome + " da vila " + vila + ".");
        }

        // Método ABSTRATO: cada filha É OBRIGADA a implementar.
        public abstract void habilidade();
    }

    // Filhas concretas: cada clã implementa habilidade() do seu jeito.
    static class Uzumaki extends Ninja {
        public Uzumaki(String nome) { super(nome, "Konoha"); }
        @Override public void habilidade() { System.out.println(nome + " usa Rasengan!"); }
    }

    static class Uchiha extends Ninja {
        public Uchiha(String nome) { super(nome, "Konoha"); }
        @Override public void habilidade() { System.out.println(nome + " ativa o Sharingan!"); }
    }

    static class Hyuuga extends Ninja {
        public Hyuuga(String nome) { super(nome, "Konoha"); }
        @Override public void habilidade() { System.out.println(nome + " usa Juuken (punho gentil)!"); }
    }

    // ============================================================
    // INTERFACES — "é capaz de"
    // ============================================================

    // Interface simples (contrato puro).
    interface Voador {
        void voar();
    }

    interface Nadador {
        void nadar();
    }

    // Interface com DEFAULT method.
    // Quem implementa ganha atacarMultiplos() de graça, sem precisar codar.
    interface Atacavel {
        void atacar(String alvo);

        default void atacarMultiplos(String... alvos) {
            for (String a : alvos) {
                atacar(a);   // reusa o atacar() de quem implementa
            }
        }
    }

    // ============================================================
    // Implementação MÚLTIPLA (extends 1 classe, implements N interfaces)
    // Itachi é Ninja (extends) E Voador + Atacavel (implements vários).
    // ============================================================
    static class Itachi extends Ninja implements Voador, Atacavel {
        public Itachi() { super("Itachi", "Konoha"); }

        @Override public void habilidade()   { System.out.println(nome + " usa Tsukuyomi!"); }
        @Override public void voar()         { System.out.println(nome + " voa montado num corvo gigante."); }
        @Override public void atacar(String alvo) {
            System.out.println(nome + " ataca " + alvo + " com Amaterasu!");
        }
    }

    // Outra classe que combina abstração + 2 interfaces.
    // Kisame é ninja, nada como um peixe e ataca com a Samehada.
    static class Kisame extends Ninja implements Nadador, Atacavel {
        public Kisame() { super("Kisame", "Kirigakure"); }

        @Override public void habilidade()         { System.out.println(nome + " absorve chakra com Samehada."); }
        @Override public void nadar()              { System.out.println(nome + " desliza pela água como um tubarão."); }
        @Override public void atacar(String alvo)  { System.out.println(nome + " corta " + alvo + " com Samehada."); }
    }

    // ============================================================
    // EXERCÍCIOS
    // ============================================================

    // Exercício 1 — Classe abstrata NÃO pode ser instanciada direto.
    // Mostra que só dá pra instanciar pelas filhas concretas.
    static void exercicio1() {
        // Ninja n = new Ninja("X", "Y");  // ❌ não compila: "Ninja is abstract"
        Ninja a = new Uzumaki("Naruto");
        Ninja b = new Uchiha("Sasuke");

        a.apresentar();   // método concreto (vem da Ninja)
        a.habilidade();   // método abstrato implementado pelo Uzumaki

        b.apresentar();
        b.habilidade();
    }

    // Exercício 2 — POLIMORFISMO via classe abstrata.
    // O loop trata todo mundo como Ninja, mas cada um responde diferente.
    static void exercicio2() {
        Ninja[] esquadrao = {
            new Uzumaki("Naruto"),
            new Uchiha("Sasuke"),
            new Hyuuga("Hinata")
        };

        for (Ninja n : esquadrao) {
            n.apresentar();    // igual pra todos (concreto)
            n.habilidade();    // diferente por filha (abstrato → polimorfismo!)
        }
        // Amanhã chega Aburame? Basta criar a classe — o loop NÃO muda.
    }

    // Exercício 3 — Interface simples (contrato).
    // Atacavel diz: "se você é Atacavel, tem que ter atacar(alvo)".
    static void exercicio3() {
        Atacavel a = new Itachi();        // tratamos Itachi PELA interface
        a.atacar("Sasuke");
    }

    // Exercício 4 — DEFAULT method em interface.
    // Itachi NÃO implementou atacarMultiplos() — ganhou de graça do default.
    static void exercicio4() {
        Itachi itachi = new Itachi();
        itachi.atacarMultiplos("Kakashi", "Asuma", "Kurenai");
    }

    // Exercício 5 — Implementação MÚLTIPLA de interfaces.
    // Itachi pode voar? Pode atacar? Ele implementa as duas.
    // Em Java, é assim que se faz "herança múltipla": uma classe + várias interfaces.
    static void exercicio5() {
        Itachi itachi = new Itachi();

        Voador v = itachi;            // mesmo objeto, "visto" como Voador
        v.voar();

        Atacavel a = itachi;          // mesmo objeto, "visto" como Atacavel
        a.atacar("Naruto");

        Ninja n = itachi;             // mesmo objeto, "visto" como Ninja
        n.apresentar();
        n.habilidade();
        // Mesmo objeto, três "papéis" — abstração no seu melhor.
    }

    // Exercício 6 — Comparação PRÁTICA: abstract class vs interface.
    // - Ninja (abstract) compartilha estado (nome, vila) e código (apresentar).
    // - Voador/Nadador/Atacavel (interface) são habilidades plugáveis.
    // Kisame é Ninja E Nadador E Atacavel. Repare como cada peça tem um papel.
    static void exercicio6() {
        Kisame kisame = new Kisame();
        kisame.apresentar();    // veio da abstract class (estado compartilhado)
        kisame.habilidade();    // método abstrato implementado pelo Kisame
        kisame.nadar();         // veio da interface Nadador
        kisame.atacar("Gai");   // veio da interface Atacavel
        kisame.atacarMultiplos("Lee", "Tenten");  // veio do DEFAULT da Atacavel
    }

    // Exercício 7 — Interface da stdlib: Runnable (lambda).
    // Runnable tem UM método (run) — é uma "functional interface", ideal pra lambda.
    static void exercicio7() {
        Runnable jutsu = () -> System.out.println("Kage Bunshin no Jutsu! (10 clones)");
        jutsu.run();    // chamamos direto, sem thread, pra simplificar

        // Comparable de verdade (stdlib): String já implementa.
        int cmp = "Naruto".compareTo("Sasuke");
        System.out.println("\"Naruto\".compareTo(\"Sasuke\") = " + cmp + "  (negativo = vem antes em ordem alfabética)");
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Classe abstrata não instanciável ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: Polimorfismo via classe abstrata ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Interface simples (Atacavel) ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Default method (atacarMultiplos) ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: Implementação múltipla (Itachi: Ninja + Voador + Atacavel) ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Abstract class + Interfaces juntos (Kisame) ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Interfaces da stdlib (Runnable, Comparable) ===");
        exercicio7();
    }
}
