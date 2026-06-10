// 🎯 DESAFIO DO MÓDULO 12 — Caixa Genérica do Ninja
//
// Contexto:
// O Naruto quer organizar o estoque da vila. Em vez de criar uma classe pra cada tipo
// de coisa (CaixaDeKunai, CaixaDeNinja, CaixaDePergaminho...), você vai criar UMA
// classe genérica Caixa<T> que serve pra qualquer coisa — e ainda permite filtrar
// itens com um Filtro<T> próprio (vamos evitar Predicate da stdlib de propósito;
// Functional Interfaces é o Módulo 13).
//
// Requisitos:
// 1. Interface genérica `Filtro<T>` com um único método:
//        boolean teste(T item);
//
// 2. Classe genérica `Caixa<T>` armazenando vários itens (use `List<T>` internamente).
//    Métodos:
//      - void   adicionar(T item)
//      - boolean remover(T item)                  // devolve true se removeu
//      - int    tamanho()
//      - List<T> filtrar(Filtro<T> f)             // só os itens que passam no teste
//      - void   imprimir()                        // imprime [itens] + tamanho
//
// 3. No main, demonstre o uso com DOIS tipos diferentes:
//    a) Caixa<Kunai>  — filtre as kunais AFIADAS.
//    b) Caixa<Ninja>  — filtre os ninjas da aldeia de Konoha.
//
//    Em cada uma: adicione itens, imprima, filtre, remova um item, imprima de novo.
//
// Resultado esperado (algo nessa linha):
//
//   === Caixa<Kunai> ===
//   Itens: [Kunai(afiada), Kunai(cega), Kunai(afiada), Kunai(cega)]
//   Tamanho: 4
//   Filtro "afiadas": [Kunai(afiada), Kunai(afiada)]
//   Após remover uma cega:
//   Itens: [Kunai(afiada), Kunai(afiada), Kunai(cega)]
//   Tamanho: 3
//
//   === Caixa<Ninja> ===
//   Itens: [Naruto/Konoha, Gaara/Areia, Sasuke/Konoha, Kakashi/Konoha]
//   Tamanho: 4
//   Filtro "aldeia=Konoha": [Naruto/Konoha, Sasuke/Konoha, Kakashi/Konoha]
//   Após remover Gaara:
//   Itens: [Naruto/Konoha, Sasuke/Konoha, Kakashi/Konoha]
//   Tamanho: 3
//
// 💡 Dicas:
//   - Use `private final List<T> itens = new ArrayList<>();` no campo da Caixa.
//   - O método `filtrar` percorre a lista e usa `f.teste(item)` pra decidir o que entra.
//   - Crie o Filtro<T> como CLASSE ANÔNIMA (estilo pré-lambda):
//        Filtro<Kunai> afiadas = new Filtro<Kunai>() {
//            public boolean teste(Kunai k) { return k.isAfiada(); }
//        };
//   - Pra Kunai e Ninja sobrescreva toString() pra ficar legível.
//   - Repare no fim: a MESMA Caixa<T> e o MESMO Filtro<T> serviram pra dois tipos
//     totalmente diferentes. Esse é o ganho real dos generics.

import java.util.ArrayList;
import java.util.List;

public class Main {

    // ============================
    // Tipos de apoio do desafio
    // ============================
    static class Kunai {
        private final boolean afiada;
        public Kunai(boolean afiada) { this.afiada = afiada; }
        public boolean isAfiada()    { return afiada; }
        @Override public String toString() { return "Kunai(" + (afiada ? "afiada" : "cega") + ")"; }
    }

    static class Ninja {
        private final String nome;
        private final String aldeia;
        public Ninja(String nome, String aldeia) {
            this.nome = nome;
            this.aldeia = aldeia;
        }
        public String getNome()   { return nome; }
        public String getAldeia() { return aldeia; }
        @Override public String toString() { return nome + "/" + aldeia; }
    }

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO: declare aqui a interface Filtro<T> com o método boolean teste(T item).

    // TODO: declare aqui a classe Caixa<T> com:
    //   - campo List<T> itens
    //   - adicionar(T)
    //   - remover(T) -> boolean
    //   - tamanho() -> int
    //   - filtrar(Filtro<T>) -> List<T>
    //   - imprimir()

    public static void main(String[] args) {
        // TODO: crie uma Caixa<Kunai>, adicione kunais (algumas afiadas, outras cegas),
        //       imprima, filtre as afiadas, remova uma cega, imprima de novo.

        // TODO: crie uma Caixa<Ninja>, adicione ninjas de várias aldeias,
        //       imprima, filtre os de Konoha, remova um ninja, imprima de novo.

        System.out.println("(implemente o desafio aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    // Interface própria — sem usar Predicate da stdlib (isso vem no Módulo 13).
    // Repare: ela TAMBÉM é genérica. Quem usa decide o tipo testado.
    interface Filtro<T> {
        boolean teste(T item);
    }

    // Classe genérica que guarda vários itens do tipo T.
    static class Caixa<T> {
        private final List<T> itens = new ArrayList<>();

        public void adicionar(T item) {
            itens.add(item);
        }

        public boolean remover(T item) {
            return itens.remove(item);     // remove a primeira ocorrência
        }

        public int tamanho() {
            return itens.size();
        }

        // Percorre os itens e devolve só os que passam no teste.
        public List<T> filtrar(Filtro<T> f) {
            List<T> resultado = new ArrayList<>();
            for (T item : itens) {
                if (f.teste(item)) {
                    resultado.add(item);
                }
            }
            return resultado;
        }

        public void imprimir() {
            System.out.println("Itens: " + itens);
            System.out.println("Tamanho: " + tamanho());
        }
    }

    public static void main(String[] args) {
        // ---------- Caixa<Kunai> ----------
        System.out.println("=== Caixa<Kunai> ===");
        Caixa<Kunai> bolsaKunai = new Caixa<>();
        bolsaKunai.adicionar(new Kunai(true));
        bolsaKunai.adicionar(new Kunai(false));
        bolsaKunai.adicionar(new Kunai(true));
        Kunai cegaParaRemover = new Kunai(false);
        bolsaKunai.adicionar(cegaParaRemover);
        bolsaKunai.imprimir();

        // Filtro como CLASSE ANÔNIMA (jeito pré-lambda).
        Filtro<Kunai> afiadas = new Filtro<Kunai>() {
            @Override
            public boolean teste(Kunai k) {
                return k.isAfiada();
            }
        };
        System.out.println("Filtro \"afiadas\": " + bolsaKunai.filtrar(afiadas));

        bolsaKunai.remover(cegaParaRemover);   // remove pela referência guardada
        System.out.println("Após remover uma cega:");
        bolsaKunai.imprimir();

        // ---------- Caixa<Ninja> ----------
        System.out.println("\n=== Caixa<Ninja> ===");
        Caixa<Ninja> equipe = new Caixa<>();
        equipe.adicionar(new Ninja("Naruto",  "Konoha"));
        Ninja gaara = new Ninja("Gaara",   "Areia");
        equipe.adicionar(gaara);
        equipe.adicionar(new Ninja("Sasuke",  "Konoha"));
        equipe.adicionar(new Ninja("Kakashi", "Konoha"));
        equipe.imprimir();

        // Mesma interface Filtro<T>, agora pra Ninja. Repare: NENHUMA mudança na Caixa.
        Filtro<Ninja> deKonoha = new Filtro<Ninja>() {
            @Override
            public boolean teste(Ninja n) {
                return "Konoha".equals(n.getAldeia());
            }
        };
        System.out.println("Filtro \"aldeia=Konoha\": " + equipe.filtrar(deKonoha));

        equipe.remover(gaara);                 // remove pela MESMA referência adicionada
        System.out.println("Após remover Gaara:");
        equipe.imprimir();

        // 💡 Observação importante:
        // A MESMA classe Caixa<T> e a MESMA interface Filtro<T> funcionaram
        // pra Kunai E pra Ninja — sem cast, sem duplicar código, com segurança de tipo
        // em tempo de compilação. É exatamente esse o ganho real dos generics.
        //
        // 🕵️ Type erasure aparecendo na prática:
        // Em runtime, bolsaKunai.getClass() == equipe.getClass() é TRUE,
        // porque o <T> some depois da compilação. Mesmo assim, o COMPILADOR garantiu
        // que ninguém botou um Ninja na Caixa<Kunai>.
    }
    */
}
