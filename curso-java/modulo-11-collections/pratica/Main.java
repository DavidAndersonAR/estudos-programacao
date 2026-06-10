// Módulo 11 — Collections (PRÁTICA)
// Tema: Naruto. 10 exercícios resolvidos cobrindo List, Stack, Queue,
// LinkedList, HashSet, LinkedHashSet, TreeSet e HashMap.
//
// Rode com: java Main.java   (JDK 11+)
// Ou:       javac Main.java && java Main

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.Set;
import java.util.Stack;
import java.util.TreeSet;

public class Main {

    // POJO simples pra alguns exercícios.
    static class Ninja {
        String nome;
        String aldeia;
        int nivelChakra;

        Ninja(String nome, String aldeia, int nivelChakra) {
            this.nome = nome;
            this.aldeia = aldeia;
            this.nivelChakra = nivelChakra;
        }

        @Override
        public String toString() {
            return nome + "(" + aldeia + ", chakra=" + nivelChakra + ")";
        }
    }

    // -------------------------------------------------------------------
    // Exercício 1: ArrayList de Ninjas — add, get, size, contains, iteração
    // A coleção mais usada do Java. Pense num "time" de ninjas.
    // -------------------------------------------------------------------
    static void exercicio1() {
        List<Ninja> time7 = new ArrayList<>();
        time7.add(new Ninja("Naruto",  "Konoha", 9000));
        time7.add(new Ninja("Sasuke",  "Konoha", 8500));
        time7.add(new Ninja("Sakura",  "Konoha", 5000));
        time7.add(new Ninja("Kakashi", "Konoha", 9500));

        System.out.println("Tamanho do Time 7: " + time7.size());            // 4
        System.out.println("Primeiro membro:   " + time7.get(0).nome);       // Naruto
        System.out.println("Último membro:     " + time7.get(time7.size() - 1).nome); // Kakashi

        // for-each (forma idiomática).
        System.out.println("Listando o time:");
        for (Ninja n : time7) {
            System.out.println("  - " + n);
        }
    }

    // -------------------------------------------------------------------
    // Exercício 2: ArrayList vs LinkedList — sentindo a diferença na prática
    // Vamos inserir 100 mil ninjas no COMEÇO de cada lista e medir o tempo.
    // ArrayList sofre (precisa deslocar tudo), LinkedList voa (só ajusta nós).
    // -------------------------------------------------------------------
    static void exercicio2() {
        int N = 100_000;

        // ArrayList — inserir no começo é O(n).
        List<Integer> arr = new ArrayList<>();
        long t1 = System.nanoTime();
        for (int i = 0; i < N; i++) {
            arr.add(0, i);   // sempre na posição 0 — desloca todo mundo
        }
        long arrTempo = (System.nanoTime() - t1) / 1_000_000;

        // LinkedList — inserir no começo é O(1).
        List<Integer> link = new LinkedList<>();
        long t2 = System.nanoTime();
        for (int i = 0; i < N; i++) {
            link.add(0, i);
        }
        long linkTempo = (System.nanoTime() - t2) / 1_000_000;

        System.out.println("Inserir " + N + " elementos no começo:");
        System.out.println("  ArrayList:  " + arrTempo + " ms");
        System.out.println("  LinkedList: " + linkTempo + " ms");
        System.out.println("  -> LinkedList ganhou feio nessa operação.");

        // PORÉM: pra ACESSO por índice, é o contrário.
        long t3 = System.nanoTime();
        for (int i = 0; i < 10_000; i++) arr.get(i);
        long arrGet = (System.nanoTime() - t3) / 1_000_000;

        long t4 = System.nanoTime();
        for (int i = 0; i < 10_000; i++) link.get(i);
        long linkGet = (System.nanoTime() - t4) / 1_000_000;

        System.out.println("Acessar por índice 10.000 vezes:");
        System.out.println("  ArrayList:  " + arrGet + " ms");
        System.out.println("  LinkedList: " + linkGet + " ms");
        System.out.println("  -> Agora ArrayList ganhou disparado.");
    }

    // -------------------------------------------------------------------
    // Exercício 3: Iteração com Iterator + remoção segura
    // Remover durante for-each estoura ConcurrentModificationException.
    // Iterator.remove() é o jeito certo.
    // -------------------------------------------------------------------
    static void exercicio3() {
        List<String> akatsuki = new ArrayList<>(List.of(
            "Itachi", "Kisame", "Pain", "Konan", "Deidara", "Sasori", "Hidan"
        ));

        // Queremos remover todos os nomes que começam com "S".
        Iterator<String> it = akatsuki.iterator();
        while (it.hasNext()) {
            String nome = it.next();
            if (nome.startsWith("S")) {
                it.remove();   // remove com segurança
            }
        }
        System.out.println("Akatsuki sem 'S': " + akatsuki); // Sasori sai
    }

    // -------------------------------------------------------------------
    // Exercício 4: Stack — pilha de pergaminhos proibidos (LIFO)
    // O último pergaminho empilhado é o primeiro a ser pego.
    // -------------------------------------------------------------------
    static void exercicio4() {
        Stack<String> pergaminhos = new Stack<>();
        pergaminhos.push("Pergaminho do Kage Bunshin");      // entra primeiro
        pergaminhos.push("Pergaminho do Edo Tensei");
        pergaminhos.push("Pergaminho do Hiraishin");          // entra por último

        System.out.println("Pilha: " + pergaminhos);
        System.out.println("Topo (peek): " + pergaminhos.peek()); // Hiraishin (não remove)

        // pop: tira o do topo (sai o último que entrou).
        System.out.println("Pop: " + pergaminhos.pop()); // Hiraishin
        System.out.println("Pop: " + pergaminhos.pop()); // Edo Tensei

        System.out.println("Vazia? " + pergaminhos.isEmpty()); // false
        System.out.println("Restou: " + pergaminhos);           // [Kage Bunshin]
    }

    // -------------------------------------------------------------------
    // Exercício 5: Queue — fila de missões no balcão da Tsunade (FIFO)
    // Quem chegou primeiro é atendido primeiro.
    // -------------------------------------------------------------------
    static void exercicio5() {
        // LinkedList implementa Queue — instância padrão pra FIFO.
        Queue<String> filaDeMissoes = new LinkedList<>();
        filaDeMissoes.offer("Capturar a gata Tora");
        filaDeMissoes.offer("Escoltar o construtor Tazuna");
        filaDeMissoes.offer("Recuperar pergaminho roubado");

        System.out.println("Próxima da fila (peek): " + filaDeMissoes.peek());
        // -> Capturar a gata Tora (só espia, não remove)

        // poll: retira a primeira (a mais antiga).
        while (!filaDeMissoes.isEmpty()) {
            System.out.println("Atendendo: " + filaDeMissoes.poll());
        }
        // Saída na ordem: Tora -> Tazuna -> Pergaminho

        // poll() em fila vazia retorna null (não estoura).
        System.out.println("Fila vazia, poll: " + filaDeMissoes.poll()); // null
    }

    // -------------------------------------------------------------------
    // Exercício 6: PriorityQueue — fila com prioridade
    // Missões rank S saem antes das rank D, independente da ordem de chegada.
    // -------------------------------------------------------------------
    static void exercicio6() {
        // Vamos modelar uma missão como "rank: descrição".
        // PriorityQueue ordena alfabeticamente pelas strings (S < B < D no exemplo? não...).
        // Pra controlar, usamos um Comparator customizado: ordem dos ranks.
        Comparator<String> porRank = Comparator.comparingInt(missao -> {
            char rank = missao.charAt(0);
            // S = mais urgente -> menor número.
            switch (rank) {
                case 'S': return 0;
                case 'A': return 1;
                case 'B': return 2;
                case 'C': return 3;
                default:  return 4; // D
            }
        });

        PriorityQueue<String> missoes = new PriorityQueue<>(porRank);
        missoes.offer("D: capturar Tora");
        missoes.offer("S: enfrentar a Akatsuki");
        missoes.offer("B: escoltar Tazuna");
        missoes.offer("A: resgatar Gaara");

        // poll sai sempre a mais prioritária.
        while (!missoes.isEmpty()) {
            System.out.println("Despachando -> " + missoes.poll());
        }
        // S -> A -> B -> D
    }

    // -------------------------------------------------------------------
    // Exercício 7: HashSet — aldeias únicas (sem duplicatas)
    // Set ignora repetidos. Ordem caótica.
    // -------------------------------------------------------------------
    static void exercicio7() {
        // Lista crua, com aldeias repetidas (vários ninjas da mesma).
        List<String> aldeiasDeOrigem = List.of(
            "Konoha", "Suna", "Konoha", "Kiri", "Suna", "Iwa", "Kumo", "Konoha"
        );

        Set<String> aldeiasUnicas = new HashSet<>(aldeiasDeOrigem);
        System.out.println("Crua:   " + aldeiasDeOrigem);
        System.out.println("Únicas: " + aldeiasUnicas); // ordem indefinida!
        System.out.println("Total de aldeias distintas: " + aldeiasUnicas.size()); // 5

        // contains é O(1) em média — superrrápido.
        System.out.println("Tem Konoha? " + aldeiasUnicas.contains("Konoha")); // true
        System.out.println("Tem Otogakure? " + aldeiasUnicas.contains("Otogakure")); // false
    }

    // -------------------------------------------------------------------
    // Exercício 8: LinkedHashSet vs TreeSet — comparando a ordem
    // Mesmo conteúdo, ordem totalmente diferente na iteração.
    // -------------------------------------------------------------------
    static void exercicio8() {
        String[] entrada = {"Sasuke", "Naruto", "Itachi", "Sakura", "Kakashi"};

        // HashSet — sem garantia de ordem.
        Set<String> hash = new HashSet<>(Arrays.asList(entrada));
        System.out.println("HashSet:       " + hash); // caótica

        // LinkedHashSet — preserva ordem de inserção.
        Set<String> linked = new LinkedHashSet<>(Arrays.asList(entrada));
        System.out.println("LinkedHashSet: " + linked); // [Sasuke, Naruto, Itachi, Sakura, Kakashi]

        // TreeSet — ordem natural (alfabética pra String).
        Set<String> tree = new TreeSet<>(Arrays.asList(entrada));
        System.out.println("TreeSet:       " + tree); // [Itachi, Kakashi, Naruto, Sakura, Sasuke]
    }

    // -------------------------------------------------------------------
    // Exercício 9: HashMap<String, Ninja> — ficheiro do Iruka
    // Nome do ninja -> objeto Ninja. Busca por nome em O(1).
    // -------------------------------------------------------------------
    static void exercicio9() {
        Map<String, Ninja> ficheiro = new HashMap<>();
        ficheiro.put("Naruto",  new Ninja("Naruto",  "Konoha", 9500));
        ficheiro.put("Sasuke",  new Ninja("Sasuke",  "Konoha", 9000));
        ficheiro.put("Gaara",   new Ninja("Gaara",   "Suna",   8800));
        ficheiro.put("Itachi",  new Ninja("Itachi",  "Konoha", 9700));

        // Busca direta por chave.
        Ninja n = ficheiro.get("Gaara");
        System.out.println("Gaara: " + n);

        // getOrDefault — evita NullPointer.
        Ninja desconhecido = ficheiro.getOrDefault("Madara",
            new Ninja("Desconhecido", "?", 0));
        System.out.println("Madara não cadastrado -> " + desconhecido);

        // Iterando com entrySet — chave e valor de uma vez.
        System.out.println("Ficheiro completo:");
        for (Map.Entry<String, Ninja> e : ficheiro.entrySet()) {
            System.out.println("  " + e.getKey() + " -> " + e.getValue());
        }
    }

    // -------------------------------------------------------------------
    // Exercício 10: Ordenando ninjas — Collections.sort + Comparator
    // -------------------------------------------------------------------
    static void exercicio10() {
        List<Ninja> ninjas = new ArrayList<>(List.of(
            new Ninja("Naruto",  "Konoha", 9500),
            new Ninja("Sasuke",  "Konoha", 9000),
            new Ninja("Gaara",   "Suna",   8800),
            new Ninja("Itachi",  "Konoha", 9700),
            new Ninja("Sakura",  "Konoha", 5000)
        ));

        // Ordena por nível de chakra DECRESCENTE (maior primeiro).
        ninjas.sort(Comparator.comparingInt((Ninja n) -> n.nivelChakra).reversed());
        System.out.println("Por chakra (desc):");
        for (Ninja n : ninjas) System.out.println("  " + n);

        // Ordena por nome ASCENDENTE.
        ninjas.sort(Comparator.comparing(n -> n.nome));
        System.out.println("Por nome (asc):");
        for (Ninja n : ninjas) System.out.println("  " + n);

        // Bônus: Collections.reverse vira tudo de cabeça pra baixo.
        Collections.reverse(ninjas);
        System.out.println("Invertido:");
        for (Ninja n : ninjas) System.out.println("  " + n);
    }

    public static void main(String[] args) {
        System.out.println("=== Exercício 1: ArrayList de Ninjas ===");
        exercicio1();

        System.out.println("\n=== Exercício 2: ArrayList vs LinkedList (performance) ===");
        exercicio2();

        System.out.println("\n=== Exercício 3: Iterator + remoção segura ===");
        exercicio3();

        System.out.println("\n=== Exercício 4: Stack — pilha de pergaminhos (LIFO) ===");
        exercicio4();

        System.out.println("\n=== Exercício 5: Queue — fila de missões (FIFO) ===");
        exercicio5();

        System.out.println("\n=== Exercício 6: PriorityQueue — por rank da missão ===");
        exercicio6();

        System.out.println("\n=== Exercício 7: HashSet — aldeias únicas ===");
        exercicio7();

        System.out.println("\n=== Exercício 8: HashSet vs LinkedHashSet vs TreeSet ===");
        exercicio8();

        System.out.println("\n=== Exercício 9: HashMap<String, Ninja> ===");
        exercicio9();

        System.out.println("\n=== Exercício 10: Ordenando ninjas ===");
        exercicio10();
    }
}
