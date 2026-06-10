// 🎯 DESAFIO DO MÓDULO 01 — Cartão de Visitas em Java
//
// Objetivo:
// Imprima um "cartão de visitas" formatado com seus dados:
//   - Nome
//   - Profissão
//   - Email
//   - Cidade / Estado
//   - Uma frase favorita
//
// Resultado esperado (ajuste como quiser):
//
//   +-------------------------------+
//   | David Anderson                |
//   | Programador em formação       |
//   | david@email.com               |
//   | São Paulo / SP                |
//   +-------------------------------+
//   | "Comece. O resto vem."        |
//   +-------------------------------+
//
// Requisitos:
// 1. Use println e printf pelo menos uma vez cada.
// 2. Use uma variável para cada dado.
// 3. Brinque com a formatação — alinhamento, separadores.
//
// 💡 Dicas:
//   - %-30s formata string alinhada à esquerda em 30 caracteres
//   - System.out.printf é seu amigo
//   - Crie uma String linha = "+-------------------------------+" e reutilize

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        // TODO: implemente seu cartão aqui.
        // Apague esta linha e construa o seu.
        System.out.println("(escreva seu cartão de visitas aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    public static void main(String[] args) {
        String nome = "David Anderson";
        String profissao = "Programador em formação";
        String email = "david@email.com";
        String cidade = "São Paulo";
        String estado = "SP";
        String frase = "Comece. O resto vem.";

        String linha = "+-------------------------------+";

        System.out.println(linha);
        System.out.printf("| %-30s|%n", nome);
        System.out.printf("| %-30s|%n", profissao);
        System.out.printf("| %-30s|%n", email);
        System.out.printf("| %-30s|%n", cidade + " / " + estado);
        System.out.println(linha);
        System.out.printf("| %-30s|%n", "\"" + frase + "\"");
        System.out.println(linha);
    }
    */
}
