// 🎯 DESAFIO DO MÓDULO 13 — Sistema de Filtros Configuráveis
//
// Objetivo:
// Construir um sistema de filtros que aceita QUALQUER regra de filtragem
// usando Predicate<Produto> — sem precisar criar um método novo pra cada caso.
//
// Cenário:
// Você tem uma loja com vários produtos. O dono quer relatórios diferentes:
//   - "produtos caros (acima de R$ 500)"
//   - "produtos sem estoque"
//   - "produtos de eletrônicos"
//   - "produtos caros E sem estoque" (combinação)
//   - "produtos baratos OU sem estoque"
//
// Em vez de fazer um método pra cada combinação, faça UM método genérico:
//   filtrar(List<Produto>, Predicate<Produto>)
// e construa as regras com lambdas + Predicate.and / Predicate.or / Predicate.negate.
//
// Requisitos:
// 1. Classe `Produto` com: nome (String), preco (double), categoria (String), estoque (int).
// 2. Lista com pelo menos 6 produtos variados.
// 3. Método estático `filtrar(List<Produto> lista, Predicate<Produto> regra)` que
//    devolve uma nova `List<Produto>` com os itens que passaram no teste.
// 4. Demonstre pelo menos 5 filtros diferentes, incluindo um com `.and(...)`.
// 5. Imprima de forma legível o resultado de cada filtro.
//
// 💡 Dicas:
//   - Predicate<Produto> caro = p -> p.preco > 500;
//   - Predicate<Produto> semEstoque = p -> p.estoque == 0;
//   - caro.and(semEstoque) → produtos caros E sem estoque
//   - caro.or(semEstoque)  → caros OU sem estoque
//   - caro.negate()        → NÃO caros (baratos)
//   - Pra imprimir bonito, sobrescreva toString() em Produto.

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.Predicate;

public class Main {

    // ============================
    // CLASSE PRODUTO (use essa)
    // ============================
    static class Produto {
        String nome;
        double preco;
        String categoria;
        int estoque;

        Produto(String nome, double preco, String categoria, int estoque) {
            this.nome = nome;
            this.preco = preco;
            this.categoria = categoria;
            this.estoque = estoque;
        }

        @Override
        public String toString() {
            return String.format("%-20s R$%7.2f  [%s]  estoque=%d",
                    nome, preco, categoria, estoque);
        }
    }

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO: implemente o método filtrar
    // static List<Produto> filtrar(List<Produto> lista, Predicate<Produto> regra) {
    //     ...
    // }

    // TODO: método auxiliar pra imprimir bonito (opcional, mas ajuda)
    // static void imprimirRelatorio(String titulo, List<Produto> produtos) {
    //     ...
    // }

    public static void main(String[] args) {
        // TODO:
        // 1. Crie a lista de produtos (mínimo 6).
        // 2. Crie pelo menos 5 Predicates diferentes:
        //    - caros (preço > 500)
        //    - sem estoque (estoque == 0)
        //    - da categoria "Eletrônicos"
        //    - caros E sem estoque (com .and)
        //    - baratos OU sem estoque (com .or e .negate)
        // 3. Chame filtrar(lista, regra) pra cada uma e imprima.
        System.out.println("(implemente o sistema de filtros aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    static List<Produto> filtrar(List<Produto> lista, Predicate<Produto> regra) {
        List<Produto> resultado = new ArrayList<>();
        for (Produto p : lista) {
            if (regra.test(p)) {
                resultado.add(p);
            }
        }
        return resultado;
    }

    static void imprimirRelatorio(String titulo, List<Produto> produtos) {
        System.out.println("\n=== " + titulo + " (" + produtos.size() + " itens) ===");
        if (produtos.isEmpty()) {
            System.out.println("(nenhum produto)");
            return;
        }
        for (Produto p : produtos) {
            System.out.println("  " + p);
        }
    }

    public static void main(String[] args) {
        List<Produto> estoque = Arrays.asList(
            new Produto("Notebook",     3500.00, "Eletrônicos",  5),
            new Produto("Mouse",          80.00, "Eletrônicos", 30),
            new Produto("Teclado",       250.00, "Eletrônicos",  0),
            new Produto("Cadeira",       899.00, "Móveis",       2),
            new Produto("Mesa",          450.00, "Móveis",       0),
            new Produto("Caneta",          5.50, "Papelaria",   100),
            new Produto("Caderno",        25.00, "Papelaria",    15),
            new Produto("Monitor 4K",   2200.00, "Eletrônicos",  0)
        );

        // Predicates "tijolos" — comportamento isolado, fácil de combinar
        Predicate<Produto> caro         = p -> p.preco > 500;
        Predicate<Produto> semEstoque   = p -> p.estoque == 0;
        Predicate<Produto> eletronico   = p -> p.categoria.equals("Eletrônicos");
        Predicate<Produto> barato       = caro.negate();              // preço <= 500
        Predicate<Produto> baratoOuSemEstoque = barato.or(semEstoque);
        Predicate<Produto> caroESemEstoque   = caro.and(semEstoque);

        // Aplicando os filtros — note que o método filtrar não muda,
        // só a "regra" (Predicate) que passamos como argumento.
        imprimirRelatorio("Produtos caros (> R$ 500)",
                filtrar(estoque, caro));

        imprimirRelatorio("Produtos sem estoque",
                filtrar(estoque, semEstoque));

        imprimirRelatorio("Eletrônicos",
                filtrar(estoque, eletronico));

        imprimirRelatorio("Caros E sem estoque (precisa repor urgente)",
                filtrar(estoque, caroESemEstoque));

        imprimirRelatorio("Baratos OU sem estoque",
                filtrar(estoque, baratoOuSemEstoque));

        // Bônus: dá pra montar a regra direto na chamada, sem variável nomeada
        imprimirRelatorio("Eletrônicos com estoque > 0",
                filtrar(estoque, eletronico.and(p -> p.estoque > 0)));

        // Bônus 2: filtro inline anônimo
        imprimirRelatorio("Nome começa com 'C'",
                filtrar(estoque, p -> p.nome.startsWith("C")));
    }
    */
}
