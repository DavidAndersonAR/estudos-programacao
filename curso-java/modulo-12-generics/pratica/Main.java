// Módulo 12 — Generics
// Tema: Bolsa de Ferramentas Ninja (inspirado no Java10x).
// Prática: type parameter em classes (Bolsa<T>, InfoNinja<T>) e métodos,
// bounded types, wildcards (PECS), múltiplos parâmetros, e type erasure.
//
// Rode com: java Main.java   (JDK 11+)

import java.util.ArrayList;
import java.util.List;

public class Main {

    // =====================================================
    // Tipos do "universo" pra ilustrar os exemplos
    // =====================================================
    // Hierarquia simples de ninjas — usada nos exemplos de bounded e wildcards.
    static class Ninja {
        protected final String nome;
        protected final String aldeia;
        public Ninja(String nome, String aldeia) {
            this.nome = nome;
            this.aldeia = aldeia;
        }
        public String getNome()   { return nome; }
        public String getAldeia() { return aldeia; }
        @Override public String toString() { return nome + " (" + aldeia + ")"; }
    }
    static class Genin  extends Ninja { public Genin(String nome, String aldeia)  { super(nome, aldeia); } }
    static class Jounin extends Ninja { public Jounin(String nome, String aldeia) { super(nome, aldeia); } }

    // Ferramentas que vão entrar na Bolsa.
    static class Kunai      { @Override public String toString() { return "Kunai";      } }
    static class Shuriken   { @Override public String toString() { return "Shuriken";   } }
    static class Pergaminho {
        private final String jutsu;
        public Pergaminho(String jutsu) { this.jutsu = jutsu; }
        @Override public String toString() { return "Pergaminho(" + jutsu + ")"; }
    }

    // =====================================================
    // Exercício 1: Classe genérica simples — Bolsa<T>
    // =====================================================
    // O <T> é um "espaço em branco" pro tipo.
    // A MESMA classe serve pra Kunai, Shuriken, Pergaminho...
    static class Bolsa<T> {
        private T item;

        public void guardar(T item) {
            this.item = item;
        }

        public T pegar() {
            return item;
        }
    }

    static void exercicio1() {
        Bolsa<Kunai> bolsaKunai = new Bolsa<>();
        bolsaKunai.guardar(new Kunai());
        Kunai k = bolsaKunai.pegar();          // sem cast — compilador sabe que é Kunai
        System.out.println("Bolsa<Kunai>      -> " + k);

        Bolsa<Shuriken> bolsaShuriken = new Bolsa<>();
        bolsaShuriken.guardar(new Shuriken());
        System.out.println("Bolsa<Shuriken>   -> " + bolsaShuriken.pegar());

        Bolsa<Pergaminho> bolsaPergaminho = new Bolsa<>();
        bolsaPergaminho.guardar(new Pergaminho("Rasengan"));
        System.out.println("Bolsa<Pergaminho> -> " + bolsaPergaminho.pegar());

        // ❌ bolsaKunai.guardar(new Shuriken());  // erro de COMPILAÇÃO — proteção do generic
    }

    // =====================================================
    // Exercício 2: InfoNinja<T> — guardar QUALQUER informação
    // =====================================================
    // Esse é o exemplo direto do Java10x (Parte 2):
    // uma classe genérica que armazena qualquer dado de um ninja
    // (apelido String, nível Integer, vivo/morto Boolean, etc.).
    static class InfoNinja<T> {
        private final T info;

        public InfoNinja(T info) {
            this.info = info;
        }

        public T getInfo() {
            return info;
        }

        @Override public String toString() {
            return "InfoNinja{" + info + "}";
        }
    }

    static void exercicio2() {
        InfoNinja<String>  apelido = new InfoNinja<>("Raposa de Nove Caudas");
        InfoNinja<Integer> nivel   = new InfoNinja<>(99);
        InfoNinja<Boolean> vivo    = new InfoNinja<>(true);

        // O tipo de retorno de getInfo() já vem certo — sem cast.
        String  s = apelido.getInfo();
        int     n = nivel.getInfo();
        boolean v = vivo.getInfo();

        System.out.println("Apelido: " + s);
        System.out.println("Nível:   " + n);
        System.out.println("Vivo?    " + v);
    }

    // =====================================================
    // Exercício 3: Método genérico — <T> T primeiro(List<T>)
    // =====================================================
    // O <T> ANTES do tipo de retorno DECLARA o parâmetro de tipo.
    // O compilador deduz T a partir do argumento.
    static <T> T primeiro(List<T> lista) {
        return lista.get(0);
    }

    static void exercicio3() {
        List<String> ninjas = List.of("Naruto", "Sasuke", "Sakura");
        String p1 = primeiro(ninjas);          // T vira String
        System.out.println("Primeiro ninja:  " + p1);

        List<Integer> niveis = List.of(99, 80, 70);
        int p2 = primeiro(niveis);             // T vira Integer
        System.out.println("Primeiro nível:  " + p2);
    }

    // =====================================================
    // Exercício 4: Bounded type — <T extends Number>
    // =====================================================
    // "T tem que ser Number ou subclasse de Number".
    // Aqui usamos pra somar o chakra de vários ninjas.
    static <T extends Number> double somarChakra(List<T> chakras) {
        double total = 0;
        for (T c : chakras) {
            total += c.doubleValue();          // posso chamar porque T É Number
        }
        return total;
    }

    static void exercicio4() {
        List<Integer> chakraInteiro = List.of(100, 250, 180);
        List<Double>  chakraDecimal = List.of(99.5, 80.5, 70.0);

        System.out.println("Chakra total (ints):    " + somarChakra(chakraInteiro)); // 530.0
        System.out.println("Chakra total (doubles): " + somarChakra(chakraDecimal)); // 250.0

        // ❌ somarChakra(List.of("a", "b"));  // erro — String não é Number
    }

    // =====================================================
    // Exercício 5: Wildcards — ?, ? extends, ? super (PECS)
    // =====================================================

    // ? puro: aceita lista de QUALQUER tipo (só leitura como Object).
    static void inspecionarBolsa(List<?> bolsa) {
        System.out.print("[ ");
        for (Object item : bolsa) {
            System.out.print(item + " ");
        }
        System.out.println("]");
        // ❌ bolsa.add(new Kunai());   // não dá pra adicionar — tipo desconhecido
    }

    // ? extends Ninja: aceita List<Ninja>, List<Genin>, List<Jounin>...
    // Bom pra LER (consumir) — Producer Extends.
    static void apresentarTime(List<? extends Ninja> time) {
        for (Ninja n : time) {
            System.out.println(" - " + n.getNome() + " da aldeia " + n.getAldeia());
        }
    }

    // ? super Genin: aceita List<Genin>, List<Ninja>, List<Object>.
    // Bom pra ESCREVER (produzir) — Consumer Super.
    static void recrutarGenin(List<? super Genin> registro) {
        registro.add(new Genin("Konohamaru", "Konoha"));
        registro.add(new Genin("Moegi",      "Konoha"));
    }

    static void exercicio5() {
        // ? puro — qualquer tipo
        inspecionarBolsa(List.of(new Kunai(), new Kunai()));
        inspecionarBolsa(List.of(new Pergaminho("Kage Bunshin")));
        inspecionarBolsa(List.of("texto avulso", 42, true));

        // ? extends — covariância (leitura)
        List<Genin>  genins  = List.of(new Genin("Naruto", "Konoha"), new Genin("Sasuke", "Konoha"));
        List<Jounin> jounins = List.of(new Jounin("Kakashi", "Konoha"));
        System.out.println("Time de Genin:");
        apresentarTime(genins);
        System.out.println("Time de Jounin:");
        apresentarTime(jounins);

        // ? super — contravariância (escrita)
        List<Ninja> registro = new ArrayList<>();
        recrutarGenin(registro);                  // funciona: Ninja é super de Genin
        System.out.println("Recrutas:");
        apresentarTime(registro);

        // Mnemônico PECS:
        //   Producer Extends, Consumer Super
        //   (se LÊ → extends; se ESCREVE → super)
    }

    // =====================================================
    // Exercício 6: Múltiplos parâmetros — <K, V>
    // =====================================================
    // Catálogo de jutsus por dono: chave = nome do ninja, valor = jutsu favorito.
    static class Par<K, V> {
        private final K chave;
        private final V valor;

        public Par(K chave, V valor) {
            this.chave = chave;
            this.valor = valor;
        }

        public K getChave() { return chave; }
        public V getValor() { return valor; }

        @Override public String toString() {
            return "(" + chave + " => " + valor + ")";
        }
    }

    static void exercicio6() {
        Par<String, String>  jutsuFav     = new Par<>("Naruto",  "Rasengan");
        Par<String, Integer> nivelNinja   = new Par<>("Sasuke",  80);
        Par<Integer, String> codigoMissao = new Par<>(7, "Resgatar o Gaara");

        System.out.println("Jutsu favorito: " + jutsuFav);
        System.out.println("Nível:          " + nivelNinja);
        System.out.println("Missão:         " + codigoMissao);
    }

    // =====================================================
    // Exercício 7: Type erasure — o que NÃO dá pra fazer
    // =====================================================
    // Em runtime, o Java APAGA o tipo genérico. Bolsa<Kunai> e Bolsa<Shuriken>
    // viram a mesma coisa (só Bolsa). Isso bloqueia algumas operações.
    static <T> void demonstrarErasure(T item) {
        // ❌ if (item instanceof T) { ... }   // não compila — T não existe em runtime
        // ❌ T novo = new T();                // não compila — sem informação de tipo
        // ❌ T[] array = new T[10];           // não compila — array genérico proibido
        // ❌ Class<T> c = T.class;            // não compila — T não tem .class

        // O que dá pra fazer: usar o getClass() do PRÓPRIO objeto recebido.
        System.out.println(" -> objeto da classe: " + item.getClass().getSimpleName());
    }

    static void exercicio7() {
        demonstrarErasure(new Kunai());
        demonstrarErasure(new Pergaminho("Chidori"));
        demonstrarErasure("texto");
        demonstrarErasure(42);

        // Prova prática: duas Bolsas de tipos DIFERENTES têm o MESMO getClass() em runtime.
        Bolsa<Kunai>      bk = new Bolsa<>();
        Bolsa<Pergaminho> bp = new Bolsa<>();
        System.out.println("Mesma classe em runtime? " + (bk.getClass() == bp.getClass()));
        // true — porque os genéricos foram apagados (type erasure).

        // Mesma coisa com List:
        List<String>  a = new ArrayList<>();
        List<Integer> b = new ArrayList<>();
        System.out.println("List<String> == List<Integer> em runtime? " + (a.getClass() == b.getClass()));
        // true.
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: Bolsa<T> (classe genérica) ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: InfoNinja<T> (estilo Java10x) ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Método genérico primeiro() ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Bounded <T extends Number> (somar chakra) ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: Wildcards ?, ? extends, ? super (PECS) ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: Múltiplos parâmetros <K, V> ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: Type erasure ===");
        exercicio7();
    }
}
