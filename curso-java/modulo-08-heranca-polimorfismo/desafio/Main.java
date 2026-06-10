// 🎯 DESAFIO DO MÓDULO 08 — Hierarquia de Ninjas de Konoha
//
// Cenário:
// Você foi contratado pela administração da Vila Oculta da Folha para automatizar
// a folha de pagamento dos ninjas. A vila tem ranks bem definidos, e cada rank
// calcula seu salário mensal de um jeito diferente.
//
// 📐 Hierarquia esperada:
//
//   Ninja                          (campos: nome, salarioBase)
//      |  calcularSalarioMensal()           → retorna o salário base
//      |  calcularSalarioMensal(double bonus) → base + bônus (OVERLOAD)
//      |
//      ├── Genin                   (rank inicial)
//      |      calcularSalarioMensal() → salário base puro
//      |
//      ├── Chunin                  (já passou no exame Chunin)
//      |      calcularSalarioMensal() → base + R$ 800 de bônus de missão
//      |
//      ├── Jonin                   (elite jonin)
//      |      calcularSalarioMensal() → base + R$ 800 (bônus de missão) + 25% extras
//      |
//      └── Hokage                  ← FINAL CLASS — ninguém estende Hokage!
//             calcularSalarioMensal() → base + R$ 800 + 25% + R$ 5000 fixos (cargo máximo)
//
// 📋 Requisitos:
//   1. Crie a classe Ninja (pai) com salarioBase e calcularSalarioMensal().
//   2. Sobrecarregue (overload) calcularSalarioMensal(double bonus) na pai.
//   3. Crie as subclasses Genin, Chunin, Jonin sobrescrevendo calcularSalarioMensal().
//   4. Crie Hokage como CLASSE FINAL (não pode ter subclasse).
//   5. Use @Override em toda sobrescrita.
//   6. Use super(...) nos construtores das filhas.
//   7. Use super.calcularSalarioMensal() dentro do Jonin pra somar em cima do Chunin
//      (ou direto da pai — a sua escolha de design).
//   8. Crie pelo menos: 1 Genin, 1 Chunin, 2 Jonins e 1 Hokage.
//   9. Coloque todos numa MESMA lista (Ninja[] ou List<Ninja>) — polimorfismo.
//  10. Percorra a lista somando calcularSalarioMensal() → folha total.
//  11. Imprima nome + rank + salário de cada um e o total no fim.
//
// 💡 Dicas:
//   - System.out.printf("%.2f", valor) imprime com 2 casas decimais.
//   - Para iterar: for (Ninja n : folha) { ... n.calcularSalarioMensal() ... }
//   - Você NÃO precisa de instanceof: o polimorfismo resolve sozinho.
//   - Use getClass().getSimpleName() pra mostrar o rank no log.
//
// 📤 Saída esperada (valores ilustrativos):
//
//   === Folha de Konoha ===
//   Konohamaru   (Genin)  -> R$  1500.00
//   Iruka        (Chunin) -> R$  3300.00
//   Kakashi      (Jonin)  -> R$  6625.00
//   Asuma        (Jonin)  -> R$  6625.00
//   Tsunade      (Hokage) -> R$ 14000.00
//   ---------------------------------------
//   TOTAL                 -> R$ 32050.00

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO 1: declare a classe Ninja (pai) com salarioBase e calcularSalarioMensal().
    //         Inclua tambem o OVERLOAD: calcularSalarioMensal(double bonus).
    // static class Ninja {
    //     ...
    //     double calcularSalarioMensal() { ... }
    //     double calcularSalarioMensal(double bonus) { ... }   // OVERLOAD
    // }

    // TODO 2: declare Genin extends Ninja — herda direto, sem alterar calcularSalarioMensal().
    // static class Genin extends Ninja {
    //     ...
    // }

    // TODO 3: declare Chunin extends Ninja com bônus de missão (R$ 800).
    // static class Chunin extends Ninja {
    //     @Override double calcularSalarioMensal() { ... }
    // }

    // TODO 4: declare Jonin extends Ninja com bônus de missão + 25% extras.
    //         Dica: pode usar super.calcularSalarioMensal() ou recalcular manualmente.
    // static class Jonin extends Ninja {
    //     @Override double calcularSalarioMensal() { ... }
    // }

    // TODO 5: declare Hokage como FINAL CLASS — base + bônus + 25% + R$ 5000.
    //         Ninguem estende Hokage!
    // static final class Hokage extends Ninja {
    //     @Override double calcularSalarioMensal() { ... }
    // }

    public static void main(String[] args) {
        // TODO 6: monte uma lista (array) de Ninja com pelo menos 5 itens (mix de ranks).
        // TODO 7: imprima nome + rank + salário de cada um e a folha total.
        System.out.println("(implemente a folha da vila aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    // Classe pai: comportamento padrão é retornar o próprio salário base.
    static class Ninja {
        String nome;
        double salarioBase;

        Ninja(String nome, double salarioBase) {
            this.nome = nome;
            this.salarioBase = salarioBase;
        }

        // Método "candidato a sobrescrita". As filhas vão redefinir.
        double calcularSalarioMensal() {
            return salarioBase;
        }

        // OVERLOAD: mesma classe, mesmo nome, parâmetros diferentes.
        // Útil pra calcular salário de um mês especial com bônus extra (ex.: feriado, missão A).
        double calcularSalarioMensal(double bonus) {
            return calcularSalarioMensal() + bonus;
        }

        // Útil pra imprimir o rank dentro do loop de forma genérica.
        String rank() {
            return getClass().getSimpleName();
        }
    }

    // Genin: rank inicial — só o salário base, sem extras.
    // Nem precisa sobrescrever calcularSalarioMensal() — herda o comportamento da pai.
    static class Genin extends Ninja {
        Genin(String nome, double salarioBase) {
            super(nome, salarioBase);   // chama Ninja(nome, salarioBase)
        }
    }

    // Chunin: base + R$ 800 de bônus de missão.
    static class Chunin extends Ninja {
        static final double BONUS_MISSAO = 800.0;

        Chunin(String nome, double salarioBase) {
            super(nome, salarioBase);
        }

        @Override
        double calcularSalarioMensal() {
            return salarioBase + BONUS_MISSAO;
        }
    }

    // Jonin: base + R$ 800 (bônus de missão, igual Chunin) + 25% de adicional de elite.
    // Aqui usamos super.calcularSalarioMensal() pra pegar o base da pai (Ninja),
    // somar o bônus de missão e depois aplicar os 25% de elite.
    static class Jonin extends Ninja {
        static final double BONUS_MISSAO = 800.0;
        static final double ADICIONAL_ELITE = 0.25;

        Jonin(String nome, double salarioBase) {
            super(nome, salarioBase);
        }

        @Override
        double calcularSalarioMensal() {
            double comBonus = super.calcularSalarioMensal() + BONUS_MISSAO;
            return comBonus * (1 + ADICIONAL_ELITE);
        }
    }

    // Hokage: FINAL CLASS — ninguem estende.
    // É o cargo máximo da vila: base + bônus + 25% + R$ 5000 fixos pelo cargo.
    static final class Hokage extends Ninja {
        static final double BONUS_MISSAO = 800.0;
        static final double ADICIONAL_ELITE = 0.25;
        static final double ADICIONAL_HOKAGE = 5000.0;

        Hokage(String nome, double salarioBase) {
            super(nome, salarioBase);
        }

        @Override
        double calcularSalarioMensal() {
            double comBonus = super.calcularSalarioMensal() + BONUS_MISSAO;
            double comElite = comBonus * (1 + ADICIONAL_ELITE);
            return comElite + ADICIONAL_HOKAGE;
        }
    }

    // 💥 Tente descomentar — o compilador trava: "cannot inherit from final Main.Hokage".
    // static class FalsoHokage extends Hokage {
    //     FalsoHokage(String nome, double salarioBase) { super(nome, salarioBase); }
    // }

    public static void main(String[] args) {
        // UMA lista heterogênea: tipo da referência é Ninja, objetos reais variam.
        // Polimorfismo em ação: cada chamada de calcularSalarioMensal() resolve dinamicamente.
        Ninja[] folha = {
            new Genin("Konohamaru", 1500.00),
            new Chunin("Iruka",     2500.00),
            new Jonin("Kakashi",    4500.00),
            new Jonin("Asuma",      4500.00),
            new Hokage("Tsunade",   6500.00)
        };

        System.out.println("=== Folha de Konoha ===");
        double total = 0;
        for (Ninja n : folha) {
            // calcularSalarioMensal() resolve em runtime: cada subclasse usa a sua versão.
            double salario = n.calcularSalarioMensal();
            total += salario;
            System.out.printf("%-12s (%-6s) -> R$ %9.2f%n", n.nome, n.rank(), salario);
        }
        System.out.println("---------------------------------------");
        System.out.printf("%-21s -> R$ %9.2f%n", "TOTAL", total);

        // Exemplo do OVERLOAD: mês de festival, todos ganham R$ 500 de bônus extra.
        System.out.println("\n=== Mes do Festival (bonus extra R$ 500) ===");
        double totalFestival = 0;
        for (Ninja n : folha) {
            double salario = n.calcularSalarioMensal(500.00);   // versão sobrecarregada
            totalFestival += salario;
            System.out.printf("%-12s (%-6s) -> R$ %9.2f%n", n.nome, n.rank(), salario);
        }
        System.out.println("---------------------------------------");
        System.out.printf("%-21s -> R$ %9.2f%n", "TOTAL FESTIVAL", totalFestival);
    }
    */
}
