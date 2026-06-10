// Módulo 07 — Encapsulamento + Construtores + ENUMs
// Prática: campos privados, getters/setters com validação,
// construtores No-Args / All-Args, overload com this(), e enums.
// Tema: Naruto 🍥
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

public class Main {

    // ============================
    // ENUM: NivelNinja
    // ============================
    // Conjunto FIXO de constantes. Cada nível tem um XP mínimo associado.
    // Enum é uma classe especial: tem construtor (sempre privado/package),
    // campos e métodos como qualquer outra classe.
    enum NivelNinja {
        GENIN(100),
        CHUNIN(300),
        JONIN(800),
        HOKAGE(2000);

        private final int xpMinimo;

        NivelNinja(int xpMinimo) {
            this.xpMinimo = xpMinimo;
        }

        public int getXP() {
            return xpMinimo;
        }
    }

    // ============================
    // Classe Ninja: encapsulamento + construtores + enum
    // ============================
    // Campos privados — ninguém de fora mexe direto.
    // Setter de idade valida: idade negativa => IllegalArgumentException.
    // Três construtores demonstram sobrecarga + this() pra delegar.
    // `final` na classe: impede herança e calar warning "overridable method
    //                    call in constructor" (subclasse não pode sobrescrever
    //                    setNome/setIdade e quebrar a inicialização).
    static final class Ninja {
        private String nome;
        private int idade;
        private int chakra;
        private NivelNinja nivel;

        // No-Args constructor — útil quando ainda não temos os dados
        // Delega ao "atalho" só com nome, que delega ao All-Args
        public Ninja() {
            this("Desconhecido");
        }

        // Atalho: só nome — assume idade 12, chakra 100 e nível GENIN
        public Ninja(String nome) {
            this(nome, 12, 100, NivelNinja.GENIN);
        }

        // All-Args constructor — chama os setters pra reaproveitar a validação
        public Ninja(String nome, int idade, int chakra, NivelNinja nivel) {
            setNome(nome);
            setIdade(idade);
            setChakra(chakra);
            setNivel(nivel);
        }

        // ---- getters ----
        public String getNome()       { return nome; }
        public int getIdade()         { return idade; }
        public int getChakra()        { return chakra; }
        public NivelNinja getNivel()  { return nivel; }

        // ---- setters com validação ----
        public void setNome(String nome) {
            if (nome == null || nome.isBlank()) {
                throw new IllegalArgumentException("Nome não pode ser vazio");
            }
            this.nome = nome;
        }

        public void setIdade(int idade) {
            if (idade < 0) {
                throw new IllegalArgumentException("Idade não pode ser negativa: " + idade);
            }
            this.idade = idade;
        }

        public void setChakra(int chakra) {
            if (chakra < 0) {
                throw new IllegalArgumentException("Chakra não pode ser negativo: " + chakra);
            }
            this.chakra = chakra;
        }

        public void setNivel(NivelNinja nivel) {
            if (nivel == null) {
                throw new IllegalArgumentException("Nível não pode ser nulo");
            }
            this.nivel = nivel;
        }

        @Override
        public String toString() {
            return "Ninja{nome='" + nome + "', idade=" + idade
                    + ", chakra=" + chakra + ", nivel=" + nivel + "}";
        }
    }

    // ============================
    // Exercício 1: Criar Ninja via All-Args constructor
    // ============================
    static void exercicio1() {
        Ninja naruto = new Ninja("Naruto", 12, 500, NivelNinja.GENIN);
        System.out.println("Ninja criado: " + naruto);
        System.out.println("Nome (getter):   " + naruto.getNome());
        System.out.println("Chakra (getter): " + naruto.getChakra());
        // naruto.nome = "X"; // <- não compila! campo é private
    }

    // ============================
    // Exercício 2: No-Args constructor + setters
    // ============================
    static void exercicio2() {
        Ninja n = new Ninja();   // No-Args — vira "Desconhecido", 12, 100, GENIN
        System.out.println("Recém criado (No-Args): " + n);

        n.setNome("Sasuke");
        n.setChakra(450);
        n.setNivel(NivelNinja.CHUNIN);
        System.out.println("Depois dos setters:     " + n);
    }

    // ============================
    // Exercício 3: Sobrecarga de construtores — só com o nome
    // ============================
    static void exercicio3() {
        // Esse construtor delega:  this("Sakura")
        //   -> this("Sakura", 12, 100, GENIN)
        //   -> All-Args (que valida via setters)
        Ninja sakura = new Ninja("Sakura");
        System.out.println("Sakura (só nome): " + sakura);
        System.out.println("Os defaults vieram da cadeia de this()");
    }

    // ============================
    // Exercício 4: Setter rejeita valor inválido — exceção
    // ============================
    static void exercicio4() {
        Ninja kakashi = new Ninja("Kakashi", 27, 1500, NivelNinja.JONIN);
        try {
            kakashi.setIdade(-1); // 💥 IllegalArgumentException
            System.out.println("Isso aqui NUNCA imprime");
        } catch (IllegalArgumentException e) {
            System.out.println("Capturado: " + e.getMessage());
        }
        // Estado do Ninja NÃO foi corrompido — setter falhou antes de atribuir
        System.out.println("Kakashi segue intacto: " + kakashi);
    }

    // ============================
    // Exercício 5: All-Args constructor também valida (reusa o setter)
    // ============================
    static void exercicio5() {
        try {
            Ninja invalido = new Ninja("Bandido", -10, 50, NivelNinja.GENIN);
            System.out.println("NUNCA imprime: " + invalido);
        } catch (IllegalArgumentException e) {
            System.out.println("Construtor recusou criar Ninja inválido: " + e.getMessage());
        }
    }

    // ============================
    // Exercício 6: ENUM — listando valores e XP de cada nível
    // ============================
    static void exercicio6() {
        // NivelNinja.values() devolve todas as constantes na ordem declarada
        for (NivelNinja nivel : NivelNinja.values()) {
            System.out.println(nivel + " requer XP mínimo: " + nivel.getXP());
        }
    }

    // ============================
    // Exercício 7: ENUM em switch — missão típica de cada nível
    // ============================
    static String missaoDe(NivelNinja n) {
        switch (n) {
            case GENIN:  return "Capinar o quintal da vovó (rank D)";
            case CHUNIN: return "Escoltar mercador (rank C)";
            case JONIN:  return "Infiltração em país inimigo (rank A)";
            case HOKAGE: return "Governar a vila inteira";
            default:     return "?";
        }
    }

    static void exercicio7() {
        Ninja[] esquadrao = {
                new Ninja("Konohamaru", 8, 80, NivelNinja.GENIN),
                new Ninja("Shikamaru", 16, 600, NivelNinja.CHUNIN),
                new Ninja("Kakashi",   27, 1500, NivelNinja.JONIN),
                new Ninja("Tsunade",   51, 2500, NivelNinja.HOKAGE),
        };
        for (Ninja n : esquadrao) {
            System.out.println(n.getNome() + " (" + n.getNivel() + ") -> " + missaoDe(n.getNivel()));
        }
    }

    // ============================
    // Exercício 8: comparando enum com == e usando name()/valueOf()
    // ============================
    static void exercicio8() {
        Ninja naruto = new Ninja("Naruto", 17, 9000, NivelNinja.HOKAGE);

        // Comparação direta — sem equals
        if (naruto.getNivel() == NivelNinja.HOKAGE) {
            System.out.println(naruto.getNome() + " virou Hokage! Reverência!");
        }

        // name() -> String, valueOf() -> volta pro enum
        String nomeDoNivel = naruto.getNivel().name();           // "HOKAGE"
        NivelNinja deVolta = NivelNinja.valueOf(nomeDoNivel);    // HOKAGE
        System.out.println("name(): " + nomeDoNivel + " | valueOf -> " + deVolta);
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: All-Args constructor ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: No-Args + setters ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: sobrecarga (só com nome) ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: setter rejeita inválido ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: construtor rejeita inválido ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: enum NivelNinja e XP ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: enum em switch (missões) ===");
        exercicio7();

        System.out.println("\n=== Exercício 8: comparação com == e name()/valueOf() ===");
        exercicio8();
    }
}
