// Módulo 08 — Herança + Polimorfismo + Overload + Override + Final
// Prática: hierarquia Ninja → Uzumaki / Uchiha, com tudo que o módulo cobre.
//
// Rode com: java Main.java   (JDK 16+ para pattern matching de instanceof)
// Ou:       javac Main.java && java Main

public class Main {

    // ============================================================
    // CLASSES DA HIERARQUIA
    // ============================================================

    // Superclasse Ninja.
    // Não precisa escrever "extends Object" — é implícito.
    static class Ninja {
        String nome;
        int chakra;

        Ninja(String nome, int chakra) {
            this.nome = nome;
            this.chakra = chakra;
        }

        // Construtor sem argumentos — útil pra alguns exercícios.
        Ninja() {
            this("desconhecido", 100);
        }

        // Método "candidato a override".
        String realizarJutsu() {
            return nome + " executa um jutsu básico (substituicao).";
        }

        // ========================
        // OVERLOAD: três versões do mesmo "atacar".
        // Mesmo nome, parâmetros diferentes — resolvido em tempo de COMPILAÇÃO.
        // ========================
        String atacar() {
            return nome + " ataca com kunai.";
        }

        String atacar(String alvo) {
            return nome + " ataca " + alvo + " com kunai.";
        }

        String atacar(String alvo, int forca) {
            return nome + " ataca " + alvo + " com forca " + forca + ".";
        }

        // ========================
        // MÉTODO FINAL: nenhuma subclasse pode sobrescrever este getNome().
        // Mexer aqui quebraria a forma como identificamos um ninja no resto do sistema.
        // ========================
        public final String getNome() {
            return "[Ninja] " + nome;
        }

        // Sobrescrevendo o toString() herdado de Object — fica legível ao imprimir.
        @Override
        public String toString() {
            return getClass().getSimpleName() + "(" + nome + ", chakra=" + chakra + ")";
        }
    }

    // Subclasse: Uzumaki É UM Ninja.
    // Sobrescreve completamente realizarJutsu().
    static class Uzumaki extends Ninja {
        Uzumaki(String nome, int chakra) {
            super(nome, chakra);   // chama Ninja(nome, chakra) — PRIMEIRA linha
        }

        @Override
        String realizarJutsu() {
            return nome + " grita: Kage Bunshin no Jutsu! (clones das sombras)";
        }

        // Comportamento extra que só Uzumaki tem.
        String rasengan() {
            return nome + " concentra chakra e lanca o Rasengan!";
        }
    }

    // Subclasse: Uchiha.
    // Aqui vamos ESTENDER o jutsu — chamar a versão da pai e ADICIONAR algo.
    static class Uchiha extends Ninja {
        boolean sharinganAtivo;

        Uchiha(String nome, int chakra, boolean sharinganAtivo) {
            super(nome, chakra);
            this.sharinganAtivo = sharinganAtivo;
        }

        @Override
        String realizarJutsu() {
            // super.realizarJutsu() chama a versão da pai (Ninja),
            // mesmo a gente tendo sobrescrito aqui.
            return super.realizarJutsu()
                + " | depois ativa Sharingan e usa Katon: Goukakyuu!";
        }

        String sharingan() {
            return nome + (sharinganAtivo ? " esta com o Sharingan ATIVO." : " ainda nao despertou o Sharingan.");
        }
    }

    // ============================================================
    // CLASSE FINAL: ninguém pode estender Hokage.
    // (Tenta descomentar a classe abaixo e o compilador trava o build.)
    // ============================================================
    static final class Hokage extends Ninja {
        int numero;     // 1º Hokage, 2º Hokage, ...

        Hokage(String nome, int chakra, int numero) {
            super(nome, chakra);
            this.numero = numero;
        }

        @Override
        String realizarJutsu() {
            return nome + " (Hokage #" + numero + ") executa um jutsu lendario digno do cargo!";
        }
    }

    // 💥 Descomenta pra ver o erro de compilação: "cannot inherit from final ..."
    // static class HokageReserva extends Hokage {
    //     HokageReserva(String nome, int chakra, int numero) { super(nome, chakra, numero); }
    // }

    // ============================================================
    // EXERCÍCIOS
    // ============================================================

    // Exercício 1: herança básica + reuso de campos.
    // Uzumaki herda nome, chakra e atacar() — tudo "de graça".
    static void exercicio1() {
        Uzumaki naruto = new Uzumaki("Naruto", 9000);
        System.out.println("Nome herdado: " + naruto.nome);
        System.out.println("Chakra herdado: " + naruto.chakra);
        System.out.println(naruto.atacar());          // método herdado de Ninja
        System.out.println(naruto.rasengan());        // método específico de Uzumaki
    }

    // Exercício 2: @Override e polimorfismo na prática.
    // Referência Ninja, objeto real Uzumaki/Uchiha — JVM escolhe a versão certa em runtime.
    static void exercicio2() {
        Ninja n1 = new Uzumaki("Naruto", 9000);
        Ninja n2 = new Uchiha("Sasuke", 7000, true);
        Ninja n3 = new Ninja("Generico", 1000);

        System.out.println(n1.realizarJutsu());   // versão do Uzumaki
        System.out.println(n2.realizarJutsu());   // versão do Uchiha (com super.realizarJutsu dentro)
        System.out.println(n3.realizarJutsu());   // versão da pai (Ninja)
    }

    // Exercício 3: overload do método atacar().
    // Mesmo nome, parâmetros diferentes — escolhido em tempo de COMPILAÇÃO.
    static void exercicio3() {
        Ninja sasuke = new Ninja("Sasuke", 7000);
        System.out.println(sasuke.atacar());                    // sem argumento
        System.out.println(sasuke.atacar("Naruto"));            // só alvo
        System.out.println(sasuke.atacar("Naruto", 99));        // alvo + forca

        // Repare: NÃO precisa de @Override aqui — overload não é override.
    }

    // Exercício 4: super(...) no construtor e super.metodo() para estender comportamento.
    // O Uchiha chama super.realizarJutsu() lá dentro e ADICIONA algo na frente.
    static void exercicio4() {
        Uchiha itachi = new Uchiha("Itachi", 8500, true);
        System.out.println(itachi.realizarJutsu());
        // Saída: "Itachi executa um jutsu básico... | depois ativa Sharingan..."

        // Via referência Ninja também funciona — polimorfismo.
        Ninja ref = itachi;
        System.out.println("via Ninja: " + ref.realizarJutsu());
    }

    // Exercício 5: array polimórfico — tratar várias subclasses de forma uniforme.
    // É a forma clássica de explorar polimorfismo: código que aceita Ninja
    // não precisa saber se é Uzumaki, Uchiha ou Hokage.
    static void exercicio5() {
        Ninja[] esquadrao = {
            new Uzumaki("Naruto", 9000),
            new Uchiha("Sasuke", 7000, true),
            new Uzumaki("Boruto", 5000),
            new Hokage("Hashirama", 9999, 1),
            new Ninja("Konohamaru", 3500)
        };

        for (Ninja n : esquadrao) {
            // Cada um responde à sua maneira — dynamic dispatch.
            System.out.println("- " + n.realizarJutsu());
        }
    }

    // Exercício 6: instanceof clássico + downcasting manual.
    // Quando você PRECISA chamar um método que só existe na subclasse,
    // primeiro verifica o tipo, depois faz o cast.
    static void exercicio6() {
        Ninja n = new Uzumaki("Naruto", 9000);

        if (n instanceof Uzumaki) {
            Uzumaki u = (Uzumaki) n;             // downcasting seguro
            System.out.println(u.rasengan());
        }

        Ninja outro = new Uchiha("Sasuke", 7000, true);
        if (outro instanceof Uzumaki) {
            System.out.println("nao chega aqui");
        } else {
            System.out.println(outro.nome + " nao eh Uzumaki, eh " + outro.getClass().getSimpleName());
        }
    }

    // Exercício 7: instanceof com PATTERN MATCHING (Java 16+).
    // Mesmo resultado do exercício 6, mas em UMA linha — sem cast manual.
    static void exercicio7() {
        Ninja[] esquadrao = {
            new Uzumaki("Naruto", 9000),
            new Uchiha("Sasuke", 7000, true),
            new Ninja("Generico", 100)
        };

        for (Ninja n : esquadrao) {
            // Já declara a variável "u" do tipo Uzumaki, e só entra no if se for Uzumaki.
            if (n instanceof Uzumaki u) {
                System.out.println(u.rasengan());
            } else if (n instanceof Uchiha uc) {
                System.out.println(uc.sharingan());
            } else {
                System.out.println(n.nome + " eh so um Ninja.");
            }
        }
    }

    // Exercício 8: método final + classe final.
    // - getNome() é final em Ninja → nenhuma subclasse sobrescreve.
    // - Hokage é final → ninguém estende Hokage.
    // Veja o efeito: mesmo dentro de um Hokage, getNome() vem do Ninja.
    static void exercicio8() {
        Hokage hashirama = new Hokage("Hashirama", 9999, 1);

        // getNome() é final — retorna "[Ninja] Hashirama", versão da pai.
        System.out.println("getNome() (final): " + hashirama.getNome());

        // toString() não é final — Hokage poderia sobrescrever (mas não sobrescreveu);
        // a versão de Ninja já chama getClass().getSimpleName() polimorficamente.
        System.out.println("toString(): " + hashirama);

        // Hokage é final → tenta estender e o compilador trava.
        // (Veja o comentário "HokageReserva" lá em cima, descomenta pra testar.)
        System.out.println("Hokage e uma classe FINAL — ninguem estende.");
    }

    public static void main(String[] args) {
        System.out.println("=== Exercicio 1: heranca basica (reuso) ===");
        exercicio1();

        System.out.println("\n=== Exercicio 2: @Override e polimorfismo ===");
        exercicio2();

        System.out.println("\n=== Exercicio 3: overload de atacar() ===");
        exercicio3();

        System.out.println("\n=== Exercicio 4: super(...) e super.metodo() ===");
        exercicio4();

        System.out.println("\n=== Exercicio 5: array polimorfico de Ninja ===");
        exercicio5();

        System.out.println("\n=== Exercicio 6: instanceof classico + downcast ===");
        exercicio6();

        System.out.println("\n=== Exercicio 7: instanceof pattern matching (Java 16+) ===");
        exercicio7();

        System.out.println("\n=== Exercicio 8: metodo final e classe final ===");
        exercicio8();
    }
}
