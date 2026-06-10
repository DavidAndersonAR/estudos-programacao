// Módulo 06 — Classes e Objetos
// Prática: criar classes, instanciar objetos, métodos com parâmetros,
// referência de memória vs valor em memória, e toString().
//
// Tema: Naruto (Ninja, Uzumaki, Uchiha).
// Rode com: java Main.java   (JDK 11+)

public class Main {

    // ============================
    // Classe usada nos exercícios
    // ============================
    //
    // "static class" aqui é só uma forma de declarar a classe dentro
    // de um único arquivo de prática. Na vida real, cada classe fica
    // em seu próprio arquivo (Ninja.java).

    static class Ninja {
        String nome;
        String cla;
        int chakra;

        // Método de instância SEM parâmetro.
        void apresentar() {
            System.out.println("Eu sou " + this.nome + " do clã " + this.cla
                    + " (chakra=" + this.chakra + ")");
        }

        // Método de instância COM parâmetro — recebe outro Ninja como alvo.
        // Como objetos são REFERÊNCIAS, mexer em alvo.chakra altera o original.
        void atacar(Ninja alvo) {
            System.out.println(this.nome + " atacou " + alvo.nome + "!");
            alvo.chakra = alvo.chakra - 30;
        }

        // Método que MODIFICA o próprio objeto via this.
        void meditar() {
            this.chakra = this.chakra + 50;
        }

        // Sobrescrita do toString() — usada nos exercícios 6 e 7.
        @Override
        public String toString() {
            return "Ninja{nome='" + nome + "', cla='" + cla + "', chakra=" + chakra + "}";
        }
    }

    // ============================
    // Exercícios
    // ============================

    // Exercício 1: criar um objeto Ninja, preencher campos, chamar método.
    static void exercicio1() {
        Ninja naruto = new Ninja();      // cria o objeto na memória
        naruto.nome = "Naruto";
        naruto.cla = "Uzumaki";
        naruto.chakra = 9000;
        naruto.apresentar();             // método de instância: precisa do objeto
    }

    // Exercício 2: criar VÁRIOS objetos da mesma classe.
    // Cada new gera um Ninja independente, com seus próprios valores.
    static void exercicio2() {
        Ninja naruto = new Ninja();
        naruto.nome = "Naruto"; naruto.cla = "Uzumaki"; naruto.chakra = 9000;

        Ninja sasuke = new Ninja();
        sasuke.nome = "Sasuke"; sasuke.cla = "Uchiha"; sasuke.chakra = 7500;

        Ninja sakura = new Ninja();
        sakura.nome = "Sakura"; sakura.cla = "Haruno"; sakura.chakra = 5000;

        naruto.apresentar();
        sasuke.apresentar();
        sakura.apresentar();
    }

    // Exercício 3: PRIMITIVOS vs OBJETOS — cópia de valor vs cópia de referência.
    // Este é o exercício-chave do módulo. Repete na cabeça até virar reflexo.
    static void exercicio3() {
        // ---- Primitivos: cópia de VALOR ----
        int chakraA = 100;
        int chakraB = chakraA;     // copia o valor
        chakraB = 999;             // mexe só no B
        System.out.println("chakraA = " + chakraA + " | chakraB = " + chakraB);
        // chakraA = 100 | chakraB = 999   ← independentes

        // ---- Objetos: cópia de REFERÊNCIA ----
        Ninja a = new Ninja();
        a.nome = "Naruto"; a.cla = "Uzumaki"; a.chakra = 9000;

        Ninja b = a;               // NÃO copia o objeto — copia a SETA
        b.nome = "Boruto";         // mexe pelo b...
        System.out.println("a.nome = " + a.nome + " | b.nome = " + b.nome);
        // a.nome = Boruto | b.nome = Boruto   ← MESMO objeto

        System.out.println("a == b ? " + (a == b));   // true (mesma referência)
    }

    // Exercício 4: objeto como parâmetro de método (REFERÊNCIA — modifica o original).
    // Quem mexe no alvo dentro do método mexe no objeto lá de fora também.
    static void zerarChakra(Ninja n) {
        n.chakra = 0;             // mexe direto no objeto original
    }

    static void exercicio4() {
        Ninja kakashi = new Ninja();
        kakashi.nome = "Kakashi"; kakashi.cla = "Hatake"; kakashi.chakra = 8000;

        System.out.println("Antes: chakra = " + kakashi.chakra);
        zerarChakra(kakashi);
        System.out.println("Depois: chakra = " + kakashi.chakra);   // 0, não 8000
    }

    // Exercício 5: método de instância COM PARÂMETRO — atacar(Ninja alvo).
    // Dois ninjas interagindo: um chama o método passando o outro como alvo.
    static void exercicio5() {
        Ninja naruto = new Ninja();
        naruto.nome = "Naruto"; naruto.cla = "Uzumaki"; naruto.chakra = 9000;

        Ninja sasuke = new Ninja();
        sasuke.nome = "Sasuke"; sasuke.cla = "Uchiha"; sasuke.chakra = 7500;

        System.out.println("Antes do ataque: " + sasuke.chakra);
        naruto.atacar(sasuke);     // chama método de instância passando outro objeto
        System.out.println("Depois do ataque: " + sasuke.chakra);

        // Sasuke revida
        sasuke.atacar(naruto);
        System.out.println("Naruto agora tem chakra: " + naruto.chakra);
    }

    // Exercício 6: toString() — ANTES e DEPOIS de sobrescrever.
    // Sem @Override toString(), println imprimiria "Ninja@1b6d3586" (endereço).
    // Como já sobrescrevemos lá em cima, agora sai bonito.
    static void exercicio6() {
        Ninja naruto = new Ninja();
        naruto.nome = "Naruto"; naruto.cla = "Uzumaki"; naruto.chakra = 9000;

        // println detecta o toString() sobrescrito e imprime os campos.
        System.out.println(naruto);
        // Ninja{nome='Naruto', cla='Uzumaki', chakra=9000}

        // Concatenação com "+" também chama toString() implicitamente.
        System.out.println("Status atual: " + naruto);

        // Pra ver como SERIA sem sobrescrever, usamos o hashCode da classe Object:
        System.out.println("Endereço bruto (Object.toString seria assim):"
                + " Ninja@" + Integer.toHexString(System.identityHashCode(naruto)));
    }

    // Exercício 7: ARRAY de objetos — a vila inteira.
    // Cada posição do array guarda uma REFERÊNCIA pra um Ninja.
    static void exercicio7() {
        Ninja[] vila = new Ninja[3];

        vila[0] = new Ninja(); vila[0].nome = "Naruto"; vila[0].cla = "Uzumaki"; vila[0].chakra = 9000;
        vila[1] = new Ninja(); vila[1].nome = "Sasuke"; vila[1].cla = "Uchiha";  vila[1].chakra = 7500;
        vila[2] = new Ninja(); vila[2].nome = "Sakura"; vila[2].cla = "Haruno";  vila[2].chakra = 5000;

        // Percorre o array imprimindo cada Ninja (usa toString automaticamente).
        for (int i = 0; i < vila.length; i++) {
            System.out.println(vila[i]);
        }

        // Faz a vila inteira meditar (modifica via referência).
        for (Ninja n : vila) {
            n.meditar();
        }
        System.out.println("Depois de meditar (+50 chakra cada):");
        for (Ninja n : vila) {
            System.out.println(n);
        }
    }

    // Exercício 8: array que aponta pro MESMO objeto em duas posições.
    // Mostra que array de objetos é array de SETAS, não de objetos.
    static void exercicio8() {
        Ninja naruto = new Ninja();
        naruto.nome = "Naruto"; naruto.cla = "Uzumaki"; naruto.chakra = 9000;

        Ninja[] time = new Ninja[2];
        time[0] = naruto;
        time[1] = naruto;          // MESMA referência nas duas posições

        time[0].chakra = 100;      // mexe na posição 0...
        System.out.println("time[1].chakra = " + time[1].chakra);   // ...e a posição 1 enxerga
        System.out.println("naruto.chakra = " + naruto.chakra);     // 100 também
        System.out.println("time[0] == time[1] ? " + (time[0] == time[1])); // true
    }

    // ============================
    // main
    // ============================
    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Criando o primeiro Ninja ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: Vários ninjas da mesma classe ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Primitivos (valor) vs Objetos (referência) ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Ninja como parâmetro de método ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: Método com parâmetro — atacar(Ninja alvo) ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: toString() sobrescrito ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Array de ninjas (a vila) ===");
        exercicio7();

        System.out.println("\n=== Exercício 8: Duas posições, mesmo objeto ===");
        exercicio8();
    }
}
