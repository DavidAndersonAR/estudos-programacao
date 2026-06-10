// 🎯 DESAFIO DO MÓDULO 11 — Sistema de Missões em Konoha
//
// Cenário:
// Você foi contratado pela Tsunade pra montar o sistema interno do balcão
// de missões da Vila da Folha. Ele precisa coordenar 4 estruturas ao mesmo
// tempo, cada uma com um papel:
//
//   1. Queue<Missao>          -> fila de missões PENDENTES (FIFO).
//                                Quem chegou primeiro é despachado primeiro.
//   2. Stack<Missao>          -> pilha de missões CONCLUÍDAS (LIFO).
//                                A última concluída fica visível em cima
//                                (igual o "histórico recente" da Hokage).
//   3. Set<String>            -> conjunto de ALDEIAS já atendidas.
//                                Sem repetição — se Suna já apareceu, não
//                                conta de novo.
//   4. Map<String, List<String>> -> NINJAS POR ALDEIA.
//                                  Chave = nome da aldeia, valor = lista
//                                  dos ninjas que despacharam missão dela.
//
// Operações que o sistema precisa suportar:
//   - adicionarMissao(Missao m)        -> entra no fim da fila pendente.
//   - concluirProximaMissao()          -> tira a 1ª da fila, empilha em
//                                         concluídas, registra aldeia, e
//                                         adiciona o ninja no map daquela
//                                         aldeia.
//   - listarStatus()                   -> imprime resumo: quantas pendentes,
//                                         a próxima, a última concluída,
//                                         aldeias atendidas, e ninjas por
//                                         aldeia.
//
// Esperado (exemplo da execução do main, ao chamar listarStatus no fim):
//
//   === Status do Balcão de Missões ===
//   Missões pendentes: 1
//   Próxima da fila:   [B] Investigar bandidos em Iwa (Shikamaru/Konoha)
//   Última concluída:  [A] Resgatar Gaara (Naruto/Konoha)
//   Total concluídas:  3
//
//   Aldeias atendidas (3):
//     - Konoha
//     - Suna
//     - Kiri
//
//   Ninjas por aldeia:
//     - Konoha: [Naruto, Sakura]
//     - Suna:   [Gaara]
//     - Kiri:   [Zabuza]
//
// Requisitos técnicos:
//   1. Use Queue (LinkedList) pra fila pendente.
//   2. Use Stack pras concluídas.
//   3. Use HashSet pras aldeias (sem duplicatas).
//   4. Use HashMap<String, List<String>> pra ninjas por aldeia, e use
//      computeIfAbsent (ou getOrDefault) pra criar a lista na primeira vez
//      que a aldeia aparece.
//   5. Cuide pra não estourar quando a fila/pilha estiver vazia (use peek
//      e cheque com isEmpty antes de pop/poll).
//
// 💡 Dicas:
//   - map.computeIfAbsent("Konoha", k -> new ArrayList<>()).add("Naruto");
//   - Stack.peek() te dá o topo sem remover (o "último concluído").
//   - Queue.peek() te dá o começo sem remover (a "próxima a despachar").

// Quando você for implementar, vai precisar destes imports — descomente:
// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.HashSet;
// import java.util.LinkedList;
// import java.util.List;
// import java.util.Map;
// import java.util.Queue;
// import java.util.Set;
// import java.util.Stack;

public class Main {

    // POJO da missão.
    static class Missao {
        String rank;       // "S", "A", "B", "C", "D"
        String descricao;
        String ninja;
        String aldeia;

        Missao(String rank, String descricao, String ninja, String aldeia) {
            this.rank = rank;
            this.descricao = descricao;
            this.ninja = ninja;
            this.aldeia = aldeia;
        }

        @Override
        public String toString() {
            return "[" + rank + "] " + descricao + " (" + ninja + "/" + aldeia + ")";
        }
    }

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        // TODO 1: declare as 4 estruturas:
        //   - Queue<Missao> pendentes
        //   - Stack<Missao> concluidas
        //   - Set<String>   aldeiasAtendidas
        //   - Map<String, List<String>> ninjasPorAldeia

        // TODO 2: implemente os métodos auxiliares
        //   adicionarMissao(m) e concluirProximaMissao(...) e listarStatus(...).
        //   Aqui no main use eles assim:

        // Sugestão de dados de teste:
        //   adicionarMissao(new Missao("A", "Resgatar Gaara",          "Naruto",    "Konoha"));
        //   adicionarMissao(new Missao("S", "Combate contra Zabuza",   "Zabuza",    "Kiri"));
        //   adicionarMissao(new Missao("D", "Capturar Tora",           "Sakura",    "Konoha"));
        //   adicionarMissao(new Missao("B", "Escoltar irmãos Suna",    "Gaara",     "Suna"));
        //   adicionarMissao(new Missao("B", "Investigar bandidos Iwa", "Shikamaru", "Konoha"));
        //
        //   concluirProximaMissao();   // Resgatar Gaara
        //   concluirProximaMissao();   // Combate contra Zabuza
        //   concluirProximaMissao();   // Capturar Tora
        //   concluirProximaMissao();   // Escoltar irmãos Suna
        //
        //   listarStatus();

        System.out.println("(implemente o sistema aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    // Estruturas globais do sistema.
    static Queue<Missao> pendentes = new LinkedList<>();
    static Stack<Missao> concluidas = new Stack<>();
    static Set<String> aldeiasAtendidas = new HashSet<>();
    static Map<String, List<String>> ninjasPorAldeia = new HashMap<>();

    // Adiciona uma missão no FIM da fila pendente (FIFO).
    static void adicionarMissao(Missao m) {
        pendentes.offer(m);
        System.out.println("Recebida: " + m);
    }

    // Despacha a próxima missão da fila.
    // 1) tira do começo da fila (poll)
    // 2) empilha em concluidas (push)
    // 3) registra a aldeia no set
    // 4) acrescenta o ninja no map daquela aldeia
    static void concluirProximaMissao() {
        // Sempre confira se há algo antes de mexer — poll/pop em vazio dá ruim.
        if (pendentes.isEmpty()) {
            System.out.println("Nenhuma missão pendente!");
            return;
        }

        Missao m = pendentes.poll();   // tira do começo (FIFO)
        concluidas.push(m);            // empilha na pilha de concluídas (LIFO)

        // Set garante que a aldeia entra UMA VEZ só, mesmo que apareça em
        // várias missões.
        aldeiasAtendidas.add(m.aldeia);

        // computeIfAbsent: se a chave "Konoha" não existe ainda no map,
        // cria uma lista vazia. Depois adicionamos o ninja na lista resultante.
        ninjasPorAldeia
            .computeIfAbsent(m.aldeia, k -> new ArrayList<>())
            .add(m.ninja);

        System.out.println("Concluída: " + m);
    }

    static void listarStatus() {
        System.out.println("\n=== Status do Balcão de Missões ===");
        System.out.println("Missões pendentes: " + pendentes.size());

        // peek olha sem remover — null se vazio.
        Missao proxima = pendentes.peek();
        System.out.println("Próxima da fila:   "
            + (proxima != null ? proxima : "(nenhuma)"));

        // Stack.peek olha o topo, isEmpty pra evitar EmptyStackException.
        Missao ultima = concluidas.isEmpty() ? null : concluidas.peek();
        System.out.println("Última concluída:  "
            + (ultima != null ? ultima : "(nenhuma)"));
        System.out.println("Total concluídas:  " + concluidas.size());

        // Set não tem ordem; iteramos só pra listar.
        System.out.println("\nAldeias atendidas (" + aldeiasAtendidas.size() + "):");
        for (String a : aldeiasAtendidas) {
            System.out.println("  - " + a);
        }

        // Map: entrySet pra pegar chave + lista de ninjas de uma vez.
        System.out.println("\nNinjas por aldeia:");
        for (Map.Entry<String, List<String>> e : ninjasPorAldeia.entrySet()) {
            System.out.println("  - " + e.getKey() + ": " + e.getValue());
        }
    }

    public static void main(String[] args) {
        adicionarMissao(new Missao("A", "Resgatar Gaara",          "Naruto",    "Konoha"));
        adicionarMissao(new Missao("S", "Combate contra Zabuza",   "Zabuza",    "Kiri"));
        adicionarMissao(new Missao("D", "Capturar Tora",           "Sakura",    "Konoha"));
        adicionarMissao(new Missao("B", "Escoltar irmãos Suna",    "Gaara",     "Suna"));
        adicionarMissao(new Missao("B", "Investigar bandidos Iwa", "Shikamaru", "Konoha"));

        // Despacha as 4 primeiras. A última fica pendente.
        concluirProximaMissao();   // Resgatar Gaara
        concluirProximaMissao();   // Combate contra Zabuza
        concluirProximaMissao();   // Capturar Tora
        concluirProximaMissao();   // Escoltar irmãos Suna

        listarStatus();
    }
    */
}
