// 🎯 DESAFIO DO MÓDULO 05 — Cadastro de Ninjas
//
// Objetivo:
// Montar um mini-cadastro de ninjas usando ARRAYS PARALELOS.
// Arrays paralelos: 3 arrays do mesmo tamanho onde o índice `i` representa
// o mesmo ninja em todos eles.
//
//   índice:    0          1          2          3          4
//   nomes:   "Naruto"  "Sasuke"  "Sakura"  "Kakashi" "Itachi"
//   niveis:    50        55         48        80         85
//   vilas:   "Folha"   "Folha"   "Folha"   "Folha"   "Folha"
//
// (Sim, antes da Akatsuki o Itachi ainda morava na Folha. Foco no exercício.)
//
// Você deve implementar 4 funções:
//
// 1) listarTodos(nomes, niveis, vilas)
//    Imprime cada ninja no formato:
//      [0] Naruto - Nível 50 - Vila da Folha
//      [1] Sasuke - Nível 55 - Vila da Folha
//      ...
//
// 2) buscarPorNome(nomes, alvo) -> int
//    Retorna o ÍNDICE do ninja com aquele nome.
//    Se não achar, retorna -1.
//
// 3) filtrarPorVila(nomes, vilas, vilaAlvo)
//    Imprime só os ninjas que moram na vila informada.
//
// 4) nivelMedio(niveis) -> double
//    Retorna a média dos níveis (soma / quantidade).
//
// Resultado esperado (com os dados-exemplo):
//
//   === Todos os ninjas ===
//   [0] Naruto - Nível 50 - Vila da Folha
//   [1] Sasuke - Nível 55 - Vila da Areia
//   [2] Sakura - Nível 48 - Vila da Folha
//   [3] Gaara  - Nível 80 - Vila da Areia
//   [4] Itachi - Nível 85 - Vila da Folha
//
//   === Buscar 'Gaara' ===
//   Encontrado no índice: 3
//
//   === Buscar 'Madara' ===
//   Não encontrado (-1)
//
//   === Ninjas da Vila da Folha ===
//   Naruto (Nível 50)
//   Sakura (Nível 48)
//   Itachi (Nível 85)
//
//   === Nível médio ===
//   63.6
//
// 💡 Dicas:
//   - Todos os arrays têm o MESMO tamanho. Use nomes.length pra percorrer todos.
//   - Pra comparar Strings em Java use .equals(), NÃO ==.
//     Ex: if (nomes[i].equals(alvo)) { ... }
//   - Pra fazer média retornando double, divida por (double) quantidade
//     ou some num double — senão a divisão de int trunca.
//   - Não precisa criar arrays novos pra filtrar — só imprima na hora.

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    static void listarTodos(String[] nomes, int[] niveis, String[] vilas) {
        // TODO: implemente — percorra os arrays e imprima cada ninja.
    }

    static int buscarPorNome(String[] nomes, String alvo) {
        // TODO: implemente — retorne o índice de quem se chama 'alvo', ou -1.
        return -1;
    }

    static void filtrarPorVila(String[] nomes, int[] niveis, String[] vilas, String vilaAlvo) {
        // TODO: implemente — imprima só os ninjas cuja vila == vilaAlvo.
    }

    static double nivelMedio(int[] niveis) {
        // TODO: implemente — retorne a média dos níveis.
        return 0.0;
    }

    public static void main(String[] args) {
        // Dados do cadastro (arrays paralelos — mesmo índice = mesmo ninja)
        String[] nomes  = {"Naruto", "Sasuke", "Sakura", "Gaara", "Itachi"};
        int[]    niveis = {50,       55,       48,       80,      85};
        String[] vilas  = {"Folha",  "Areia",  "Folha",  "Areia", "Folha"};

        System.out.println("=== Todos os ninjas ===");
        listarTodos(nomes, niveis, vilas);

        System.out.println("\n=== Buscar 'Gaara' ===");
        int i1 = buscarPorNome(nomes, "Gaara");
        System.out.println(i1 >= 0 ? "Encontrado no índice: " + i1 : "Não encontrado (-1)");

        System.out.println("\n=== Buscar 'Madara' ===");
        int i2 = buscarPorNome(nomes, "Madara");
        System.out.println(i2 >= 0 ? "Encontrado no índice: " + i2 : "Não encontrado (-1)");

        System.out.println("\n=== Ninjas da Vila da Folha ===");
        filtrarPorVila(nomes, niveis, vilas, "Folha");

        System.out.println("\n=== Nível médio ===");
        System.out.println(nivelMedio(niveis));
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    static void listarTodos(String[] nomes, int[] niveis, String[] vilas) {
        // Percorre por índice porque precisamos casar as 3 arrays na mesma posição.
        for (int i = 0; i < nomes.length; i++) {
            System.out.println(
                "[" + i + "] " + nomes[i] +
                " - Nível " + niveis[i] +
                " - Vila da " + vilas[i]
            );
        }
    }

    static int buscarPorNome(String[] nomes, String alvo) {
        // Busca linear: percorre até achar; se não achar, retorna -1.
        // Em Java, NUNCA compare String com == — use .equals().
        // (== compara referências; .equals() compara o CONTEÚDO do texto.)
        for (int i = 0; i < nomes.length; i++) {
            if (nomes[i].equals(alvo)) {
                return i;
            }
        }
        return -1; // convenção clássica pra "não encontrado"
    }

    static void filtrarPorVila(String[] nomes, int[] niveis, String[] vilas, String vilaAlvo) {
        // Não criamos array novo — só imprimimos quem bate com a vila.
        for (int i = 0; i < nomes.length; i++) {
            if (vilas[i].equals(vilaAlvo)) {
                System.out.println(nomes[i] + " (Nível " + niveis[i] + ")");
            }
        }
    }

    static double nivelMedio(int[] niveis) {
        // Acumula num double pra evitar truncamento da divisão inteira.
        double soma = 0;
        for (int n : niveis) {
            soma += n;
        }
        // niveis.length é int, mas como soma é double, o resultado vira double.
        return soma / niveis.length;
    }
    */
}
