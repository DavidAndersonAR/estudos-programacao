// 🎯 DESAFIO DO MÓDULO 07 — Banco em Konoha 🍥
//
// Você foi contratado pra modelar o sistema bancário da Vila da Folha.
// Cada ninja tem uma conta — corrente ou poupança — e o sistema precisa
// respeitar encapsulamento de verdade: o saldo NUNCA pode ser lido ou
// alterado direto de fora — só por métodos.
//
// Requisitos:
// 1. ENUM TipoConta com os valores: CORRENTE, POUPANCA
//
// 2. Classe abstract ContaBancaria com os campos PRIVADOS:
//      - titular     (String)
//      - numeroConta (int)
//      - saldo       (double)
//      - tipo        (TipoConta)
//    (vamos usar `abstract` só pra marcar que não se instancia direto;
//     herança/polimorfismo de verdade vem no próximo módulo. Aqui basta
//     deixar a classe abstrata e criar UMA subclasse concreta pra testar —
//     ou, mais simples ainda, usar `static class ContaBancaria` sem abstract.
//     Se preferir tudo concreto, fique à vontade.)
//
// 3. Construtor recebe titular, numeroConta e tipo. Saldo começa em 0.
//    Validar: titular não pode ser vazio, numeroConta deve ser > 0, tipo != null.
//
// 4. Métodos públicos:
//      - depositar(double valor)       -> valor > 0
//      - sacar(double valor)           -> valor > 0 E valor <= saldo
//      - transferir(ContaBancaria destino, double valor)
//                                      -> reutiliza sacar() + depositar()
//      - extrato()                     -> imprime titular, número, tipo e saldo formatado
//
// 5. Getters APENAS pra titular, numeroConta, tipo e saldo.
//    NUNCA setSaldo() exposto. A única forma de mexer no saldo é via
//    depositar / sacar / transferir.
//
// 6. Operações inválidas devem lançar IllegalArgumentException
//    (ou IllegalStateException pra saldo insuficiente, se preferir).
//
// Demonstre no main:
//   - Crie 3 contas (1 poupança + 2 corrente, por exemplo)
//   - Faça depósitos
//   - Tente um saque maior que o saldo (try/catch) — DEVE FALHAR
//   - Faça uma transferência válida entre contas
//   - Imprima o extrato das 3 contas no final
//
// 💡 Dicas:
//   - Use String.format("%.2f", saldo) pra mostrar 2 casas decimais
//   - Centralize validações em métodos privados (DRY)
//   - "Saldo nunca acessível diretamente" => campo private + sem setter

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO 1: implemente o enum TipoConta { CORRENTE, POUPANCA }
    //
    // TODO 2: implemente a classe ContaBancaria (pode ser static class dentro de Main).
    //
    // static class ContaBancaria {
    //     // campos privados: titular, numeroConta, saldo, tipo
    //
    //     // construtor com validação (chama setters internos)
    //
    //     // depositar / sacar / transferir / extrato
    //
    //     // getters de titular, numeroConta, tipo, saldo (sem setSaldo!)
    // }

    public static void main(String[] args) {
        // TODO:
        // 1. Crie 3 contas (ex: Naruto, Sasuke, Sakura)
        // 2. Deposite valores em todas
        // 3. Tente um saque maior que o saldo (try/catch IllegalStateException)
        // 4. Faça uma transferência (ex: Sakura -> Sasuke)
        // 5. Imprima o extrato de cada conta
        System.out.println("(implemente seu desafio aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    // ---- enum: tipo de conta ----
    enum TipoConta {
        CORRENTE, POUPANCA
    }

    // ---- classe abstrata: ContaBancaria ----
    // Marcamos como `abstract` pra deixar claro que ela não é "uma conta de verdade"
    // — é o molde. Como ainda não vimos herança a fundo, criamos uma subclasse
    // concreta mínima logo abaixo só pra poder instanciar.
    static abstract class ContaBancaria {
        private String titular;
        private int numeroConta;
        private double saldo;       // só o próprio objeto mexe aqui
        private TipoConta tipo;

        public ContaBancaria(String titular, int numeroConta, TipoConta tipo) {
            // Reaproveita os setters internos pra centralizar validação
            setTitular(titular);
            setNumeroConta(numeroConta);
            setTipo(tipo);
            this.saldo = 0.0; // saldo SEMPRE começa zerado
        }

        // ---- getters ----
        public String getTitular()    { return titular; }
        public int getNumeroConta()   { return numeroConta; }
        public double getSaldo()      { return saldo; } // leitura ok, escrita NÃO
        public TipoConta getTipo()    { return tipo; }

        // ---- setters internos (privados) — só pra construtor reaproveitar ----
        private void setTitular(String titular) {
            if (titular == null || titular.isBlank()) {
                throw new IllegalArgumentException("Titular não pode ser vazio");
            }
            this.titular = titular;
        }

        private void setNumeroConta(int numeroConta) {
            if (numeroConta <= 0) {
                throw new IllegalArgumentException("Número da conta deve ser > 0: " + numeroConta);
            }
            this.numeroConta = numeroConta;
        }

        private void setTipo(TipoConta tipo) {
            if (tipo == null) {
                throw new IllegalArgumentException("Tipo da conta não pode ser nulo");
            }
            this.tipo = tipo;
        }

        // ---- operações ----
        public void depositar(double valor) {
            exigirValorPositivo(valor, "depósito");
            saldo += valor;
            System.out.printf("[%d] Depósito de R$ %.2f — novo saldo: R$ %.2f%n",
                    numeroConta, valor, saldo);
        }

        public void sacar(double valor) {
            exigirValorPositivo(valor, "saque");
            if (valor > saldo) {
                throw new IllegalStateException(
                        String.format("Saldo insuficiente: saldo R$ %.2f, saque R$ %.2f",
                                saldo, valor));
            }
            saldo -= valor;
            System.out.printf("[%d] Saque de R$ %.2f — novo saldo: R$ %.2f%n",
                    numeroConta, valor, saldo);
        }

        public void transferir(ContaBancaria destino, double valor) {
            if (destino == null) {
                throw new IllegalArgumentException("Conta destino não pode ser nula");
            }
            if (destino == this) {
                throw new IllegalArgumentException("Não dá pra transferir pra si mesmo");
            }
            // Reaproveita sacar() (valida saldo) e depositar() (valida valor)
            this.sacar(valor);
            destino.depositar(valor);
            System.out.printf("--> Transferência de R$ %.2f da conta %d para a conta %d concluída%n",
                    valor, this.numeroConta, destino.numeroConta);
        }

        public void extrato() {
            System.out.println("---------- EXTRATO ----------");
            System.out.println("Titular:       " + titular);
            System.out.println("Nº da conta:   " + numeroConta);
            System.out.println("Tipo:          " + tipo);
            System.out.printf( "Saldo atual:   R$ %.2f%n", saldo);
            System.out.println("-----------------------------");
        }

        // Validação compartilhada — DRY
        private void exigirValorPositivo(double valor, String operacao) {
            if (valor <= 0) {
                throw new IllegalArgumentException(
                        "Valor de " + operacao + " deve ser > 0: " + valor);
            }
        }
    }

    // ---- subclasse concreta mínima pra podermos instanciar ----
    // (herança "de verdade" vem no próximo módulo)
    static class ContaSimples extends ContaBancaria {
        public ContaSimples(String titular, int numeroConta, TipoConta tipo) {
            super(titular, numeroConta, tipo);
        }
    }

    public static void main(String[] args) {
        // 1. Cria 3 contas (mistura corrente + poupança)
        ContaBancaria naruto = new ContaSimples("Naruto", 1001, TipoConta.CORRENTE);
        ContaBancaria sasuke = new ContaSimples("Sasuke", 1002, TipoConta.CORRENTE);
        ContaBancaria sakura = new ContaSimples("Sakura", 1003, TipoConta.POUPANCA);

        // 2. Depósitos iniciais
        System.out.println("=== Depósitos iniciais ===");
        naruto.depositar(500.00);
        sasuke.depositar(200.00);
        sakura.depositar(1_000.00);

        // 3. Saque que dá certo
        System.out.println("\n=== Saque válido ===");
        naruto.sacar(150.00);

        // 4. Saque que estoura — capturamos a exceção
        System.out.println("\n=== Saque inválido (saldo insuficiente) ===");
        try {
            sasuke.sacar(9_999.00);
        } catch (IllegalStateException e) {
            System.out.println("Falhou (esperado): " + e.getMessage());
        }

        // 5. Tentativa de depósito com valor negativo
        System.out.println("\n=== Depósito com valor inválido ===");
        try {
            sakura.depositar(-50);
        } catch (IllegalArgumentException e) {
            System.out.println("Falhou (esperado): " + e.getMessage());
        }

        // 6. Transferência válida
        System.out.println("\n=== Transferência Sakura -> Sasuke ===");
        sakura.transferir(sasuke, 300.00);

        // 7. Extratos finais
        System.out.println("\n=== Extratos finais ===");
        naruto.extrato();
        sasuke.extrato();
        sakura.extrato();

        // 8. Encapsulamento na prática:
        // naruto.saldo = 1_000_000;  // <- NÃO COMPILA: campo private
        // Única forma de mexer no saldo é via depositar/sacar/transferir.
        System.out.println("\nSaldo do Naruto (via getter): R$ "
                + String.format("%.2f", naruto.getSaldo()));
    }
    */
}
