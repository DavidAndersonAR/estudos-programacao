// 🎯 DESAFIO DO MÓDULO 15 — Modelo Refatorado
//
// Cenário:
// Você herdou um sistema de pedidos escrito em "Java antigo": classes POJO
// cheias de boilerplate, campos que podem ser null, status modelado com
// String, switch com if/else aninhado... uma bagunça.
//
// Sua missão: REFATORAR pro Java moderno (14-21) usando record, Optional,
// sealed e switch expression com pattern matching.
//
// =====================================================================
// CÓDIGO ANTIGO (NÃO ALTERE — está aqui só de referência, no fim do arquivo
// como comentário grande, pra você ver o "antes")
// =====================================================================
//
// O que você precisa entregar:
//
// 1) Um RECORD chamado Pedido com os campos:
//      - int id
//      - String cliente
//      - java.math.BigDecimal total
//      - Optional<String> cupom        ← pode não ter cupom
//
// 2) Uma SEALED INTERFACE chamada Status com 3 implementações
//    (use records vazios — chamados "marker records"):
//      - Pendente
//      - Aprovado(String autorizadoPor)
//      - Cancelado(String motivo)
//
// 3) Uma função descreverStatus(Status s) que retorne uma String
//    usando SWITCH EXPRESSION com pattern matching, cobrindo:
//      - Pendente            → "Pedido aguardando aprovação."
//      - Aprovado            → "Aprovado por <autorizadoPor>."
//      - Cancelado           → "Cancelado: <motivo>."
//    Não use default — sealed garante exaustividade.
//
// 4) Uma função resumoPedido(Pedido p) que retorne um TEXT BLOCK (JSON)
//    contendo id, cliente, total e cupom (mostre "nenhum" quando vazio).
//
// 5) No main, crie pelo menos 3 pedidos com status diferentes e imprima
//    o resumo + a descrição do status de cada um.
//
// 💡 Dicas:
//   - record vazio: `record Pendente() implements Status {}`
//   - cupom ausente: `Optional.empty()`; cupom presente: `Optional.of("DESC10")`
//   - cupom.orElse("nenhum") resolve o "mostre nenhum quando vazio"
//   - switch expression: `return switch (s) { case Pendente p -> "..."; ... };`
//   - text block: """ ... """.formatted(...)

import java.math.BigDecimal;
import java.util.Optional;

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO 1: declare o record Pedido(int id, String cliente, BigDecimal total, Optional<String> cupom)

    // TODO 2: declare a sealed interface Status e os 3 records
    //         (Pendente, Aprovado(String autorizadoPor), Cancelado(String motivo))

    // TODO 3: implemente descreverStatus(Status s) com switch expression

    // TODO 4: implemente resumoPedido(Pedido p) retornando um text block JSON

    public static void main(String[] args) {
        // TODO 5: crie 3 pedidos com status diferentes e imprima resumo + status
        System.out.println("(implemente seu desafio aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    // 1) Pedido como record — campos imutáveis, equals/hashCode/toString grátis.
    //    Note Optional<String> no cupom: comunica "pode não ter" no próprio tipo.
    record Pedido(int id, String cliente, BigDecimal total, Optional<String> cupom) {}

    // 2) Status como sealed interface — só estes 3 podem implementar.
    sealed interface Status permits Pendente, Aprovado, Cancelado {}
    record Pendente() implements Status {}
    record Aprovado(String autorizadoPor) implements Status {}
    record Cancelado(String motivo) implements Status {}

    // 3) Switch expression com pattern matching.
    //    O compilador GARANTE que cobrimos os 3 — adeus default esquecido.
    static String descreverStatus(Status s) {
        return switch (s) {
            case Pendente p          -> "Pedido aguardando aprovação.";
            case Aprovado a          -> "Aprovado por " + a.autorizadoPor() + ".";
            case Cancelado c         -> "Cancelado: " + c.motivo() + ".";
        };
    }

    // 4) Text block com placeholders e .formatted(...).
    //    cupom.orElse("nenhum") resolve o caso vazio sem if.
    static String resumoPedido(Pedido p) {
        return """
                {
                  "id": %d,
                  "cliente": "%s",
                  "total": %s,
                  "cupom": "%s"
                }
                """.formatted(
                        p.id(),
                        p.cliente(),
                        p.total().toPlainString(),
                        p.cupom().orElse("nenhum")
                );
    }

    public static void main(String[] args) {
        // 5) Três pedidos cobrindo cupom presente/ausente e os 3 status.
        Pedido p1 = new Pedido(1, "Ana",   new BigDecimal("199.90"), Optional.of("DESC10"));
        Pedido p2 = new Pedido(2, "Bruno", new BigDecimal("89.00"),  Optional.empty());
        Pedido p3 = new Pedido(3, "Carla", new BigDecimal("1250.00"), Optional.of("FRETEGRATIS"));

        Status s1 = new Aprovado("david@loja.com");
        Status s2 = new Pendente();
        Status s3 = new Cancelado("Cliente desistiu");

        Pedido[] pedidos = { p1, p2, p3 };
        Status[] status  = { s1, s2, s3 };

        for (int i = 0; i < pedidos.length; i++) {
            System.out.println("---- Pedido " + pedidos[i].id() + " ----");
            System.out.println(resumoPedido(pedidos[i]));
            System.out.println("Status: " + descreverStatus(status[i]));
            System.out.println();
        }
    }
    */

    // =====================================================================
    // 📜 CÓDIGO ANTIGO (o "antes" — só pra você comparar mentalmente)
    // =====================================================================
    /*
    // Pedido como POJO clássico — ~40 linhas de boilerplate
    public static class PedidoVelho {
        private final int id;
        private final String cliente;
        private final BigDecimal total;
        private final String cupom; // pode ser null → bomba na unha

        public PedidoVelho(int id, String cliente, BigDecimal total, String cupom) {
            this.id = id;
            this.cliente = cliente;
            this.total = total;
            this.cupom = cupom;
        }
        public int getId() { return id; }
        public String getCliente() { return cliente; }
        public BigDecimal getTotal() { return total; }
        public String getCupom() { return cupom; }
        // + equals, hashCode, toString manuais...
    }

    // Status como String/constante — sem checagem do compilador
    public static final String STATUS_PENDENTE = "PENDENTE";
    public static final String STATUS_APROVADO = "APROVADO";
    public static final String STATUS_CANCELADO = "CANCELADO";

    public static String descreverStatusVelho(String status, String extra) {
        // if/else aninhado, sem garantia de exaustividade
        if (status == null) return "Status desconhecido";
        if (status.equals(STATUS_PENDENTE))  return "Pedido aguardando aprovação.";
        if (status.equals(STATUS_APROVADO))  return "Aprovado por " + extra + ".";
        if (status.equals(STATUS_CANCELADO)) return "Cancelado: " + extra + ".";
        return "Status desconhecido";
    }
    */
}
