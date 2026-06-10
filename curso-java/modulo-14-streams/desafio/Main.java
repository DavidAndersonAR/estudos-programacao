// 🎯 DESAFIO DO MÓDULO 14 — Análise de Vendas
//
// Cenário:
// Uma loja registrou suas vendas do semestre. Cada venda tem:
//   - produto    (String)  ex: "Notebook"
//   - categoria  (String)  ex: "Eletrônicos"
//   - valor      (double)  ex: 3500.00
//   - mes        (int)     1 = janeiro, ..., 6 = junho
//
// A diretoria quer relatórios. Você vai gerar TUDO com Streams API
// (sem for tradicional, sem if/else fora dos lambdas).
//
// O que calcular:
//   1) Total geral de vendas (soma de todos os valores)
//   2) Total por categoria  -> Map<String, Double>
//   3) Ticket médio por mês -> Map<Integer, Double>
//   4) Top 3 produtos mais caros (lista de Venda ordenada por valor desc)
//   5) Vendas acima da média (lista de Venda com valor > média geral)
//
// Requisitos:
// - Use Streams pra TODOS os cálculos.
// - Imprima cada resultado de forma legível.
// - NÃO modifique a lista original `vendas`.
//
// 💡 Dicas:
//   - mapToDouble(Venda::getValor).sum() pra somar
//   - Collectors.groupingBy(chave, Collectors.summingDouble(valor))
//   - Collectors.groupingBy(chave, Collectors.averagingDouble(valor))
//   - sorted(Comparator.comparingDouble(Venda::getValor).reversed()).limit(3)
//   - filter(v -> v.getValor() > media)

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Main {

    // ============================
    // CLASSE VENDA (já pronta — não precisa mexer)
    // ============================
    static class Venda {
        private final String produto;
        private final String categoria;
        private final double valor;
        private final int mes;

        public Venda(String produto, String categoria, double valor, int mes) {
            this.produto = produto;
            this.categoria = categoria;
            this.valor = valor;
            this.mes = mes;
        }

        public String getProduto()   { return produto; }
        public String getCategoria() { return categoria; }
        public double getValor()     { return valor; }
        public int getMes()          { return mes; }

        @Override
        public String toString() {
            return String.format("%s [%s] R$ %.2f (mês %d)",
                    produto, categoria, valor, mes);
        }
    }

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        List<Venda> vendas = List.of(
                new Venda("Notebook",       "Eletrônicos", 3500.00, 1),
                new Venda("Mouse",          "Eletrônicos",  120.00, 1),
                new Venda("Cadeira",        "Móveis",       850.00, 2),
                new Venda("Mesa",           "Móveis",      1200.00, 2),
                new Venda("Smartphone",     "Eletrônicos", 2800.00, 3),
                new Venda("Camiseta",       "Vestuário",     80.00, 3),
                new Venda("Tênis",          "Vestuário",    350.00, 4),
                new Venda("Monitor",        "Eletrônicos", 1500.00, 4),
                new Venda("Sofá",           "Móveis",      4200.00, 5),
                new Venda("Jaqueta",        "Vestuário",    220.00, 5),
                new Venda("Teclado",        "Eletrônicos",  450.00, 6),
                new Venda("Estante",        "Móveis",       980.00, 6)
        );

        // TODO 1: Total geral
        // double totalGeral = ...
        // System.out.println("Total geral: R$ " + totalGeral);

        // TODO 2: Total por categoria
        // Map<String, Double> porCategoria = ...
        // porCategoria.forEach(...);

        // TODO 3: Ticket médio por mês
        // Map<Integer, Double> mediaPorMes = ...

        // TODO 4: Top 3 mais caros
        // List<Venda> top3 = ...

        // TODO 5: Vendas acima da média
        // double media = ...
        // List<Venda> acimaDaMedia = ...

        System.out.println("(implemente seu relatório aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    public static void main(String[] args) {
        List<Venda> vendas = List.of(
                new Venda("Notebook",       "Eletrônicos", 3500.00, 1),
                new Venda("Mouse",          "Eletrônicos",  120.00, 1),
                new Venda("Cadeira",        "Móveis",       850.00, 2),
                new Venda("Mesa",           "Móveis",      1200.00, 2),
                new Venda("Smartphone",     "Eletrônicos", 2800.00, 3),
                new Venda("Camiseta",       "Vestuário",     80.00, 3),
                new Venda("Tênis",          "Vestuário",    350.00, 4),
                new Venda("Monitor",        "Eletrônicos", 1500.00, 4),
                new Venda("Sofá",           "Móveis",      4200.00, 5),
                new Venda("Jaqueta",        "Vestuário",    220.00, 5),
                new Venda("Teclado",        "Eletrônicos",  450.00, 6),
                new Venda("Estante",        "Móveis",       980.00, 6)
        );

        // 1) Total geral
        // mapToDouble vira DoubleStream e ganhamos .sum() direto.
        double totalGeral = vendas.stream()
                .mapToDouble(Venda::getValor)
                .sum();
        System.out.printf("1) Total geral: R$ %.2f%n%n", totalGeral);

        // 2) Total por categoria
        // groupingBy + summingDouble = soma por grupo.
        Map<String, Double> porCategoria = vendas.stream()
                .collect(Collectors.groupingBy(
                        Venda::getCategoria,
                        Collectors.summingDouble(Venda::getValor)));
        System.out.println("2) Total por categoria:");
        porCategoria.forEach((cat, total) ->
                System.out.printf("   %-12s R$ %.2f%n", cat, total));
        System.out.println();

        // 3) Ticket médio por mês
        // averagingDouble já entrega Double com a média.
        Map<Integer, Double> mediaPorMes = vendas.stream()
                .collect(Collectors.groupingBy(
                        Venda::getMes,
                        Collectors.averagingDouble(Venda::getValor)));
        System.out.println("3) Ticket médio por mês:");
        mediaPorMes.forEach((mes, media) ->
                System.out.printf("   Mês %d: R$ %.2f%n", mes, media));
        System.out.println();

        // 4) Top 3 produtos mais caros
        // Comparator.comparingDouble(...).reversed() = ordem decrescente.
        List<Venda> top3 = vendas.stream()
                .sorted(Comparator.comparingDouble(Venda::getValor).reversed())
                .limit(3)
                .collect(Collectors.toList());
        System.out.println("4) Top 3 mais caros:");
        top3.forEach(v -> System.out.println("   - " + v));
        System.out.println();

        // 5) Vendas acima da média geral
        // average() em DoubleStream retorna OptionalDouble — use orElse(0).
        double media = vendas.stream()
                .mapToDouble(Venda::getValor)
                .average()
                .orElse(0);
        List<Venda> acimaDaMedia = vendas.stream()
                .filter(v -> v.getValor() > media)
                .sorted(Comparator.comparingDouble(Venda::getValor).reversed())
                .collect(Collectors.toList());
        System.out.printf("5) Vendas acima da média (R$ %.2f):%n", media);
        acimaDaMedia.forEach(v -> System.out.println("   - " + v));

        // Bônus: a lista original continua intacta.
        System.out.printf("%nTotal de vendas registradas: %d (lista original preservada)%n",
                vendas.size());
    }
    */
}
