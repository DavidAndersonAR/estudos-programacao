// 🎯 DESAFIO DO MÓDULO 10 — Validador Robusto de Cadastro
//
// Cenário:
// Você é a primeira linha de defesa do cadastro de um app. Antes de
// salvar um Usuario no banco, sua função `validar(Usuario)` precisa
// gritar — com a exceção certa — exatamente qual campo está errado.
//
// Objetivo:
// Implemente a classe Usuario e o validador. Pra CADA tipo de erro
// você cria uma exceção específica (e não usa IllegalArgumentException
// pra tudo). Quem chama deve conseguir capturar e mostrar a mensagem
// adequada pra cada falha.
//
// Requisitos:
// 1. Classe `Usuario` com: nome, email, idade (int), senha. Construtor
//    com todos os campos.
// 2. Crie 4 exceções, todas estendendo RuntimeException:
//      - CampoVazioException        (qualquer campo null ou vazio)
//      - EmailInvalidoException     (sem '@' ou sem '.')
//      - IdadeInvalidaException     (< 18 ou > 120)
//      - SenhaFracaException        (menos de 8 caracteres OU sem número)
// 3. Método `static void validar(Usuario u)` que lança a exceção
//    apropriada na PRIMEIRA falha encontrada (ordem: campos vazios,
//    email, idade, senha).
// 4. No `main`, teste com pelo menos 5 usuários: 1 válido e 4 com
//    problemas diferentes (um pra cada exceção). Capture CADA tipo
//    com um catch específico e imprima a mensagem.
//
// Resultado esperado (exemplo):
//
//   --- Validando usuário 1 ---
//   ✅ Usuário válido: David
//   --- Validando usuário 2 ---
//   ❌ Campo vazio: nome
//   --- Validando usuário 3 ---
//   ❌ Email inválido: 'davidemail.com'
//   --- Validando usuário 4 ---
//   ❌ Idade inválida: 15
//   --- Validando usuário 5 ---
//   ❌ Senha fraca: precisa de 8+ caracteres e pelo menos um número
//
// 💡 Dicas:
//   - Pra checar string vazia: s == null || s.isBlank()
//   - Email simples: !email.contains("@") || !email.contains(".")
//   - Pra ver se a senha tem número: percorra char a char com
//     Character.isDigit(c)
//   - Cada exceção precisa de um construtor que passe a mensagem
//     pro super (RuntimeException).

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO 1: declare as 4 exceções aqui (extends RuntimeException).
    //         Cada uma com um construtor que recebe String mensagem.

    // TODO 2: declare a classe Usuario (campos + construtor).

    // TODO 3: implemente o método validar(Usuario u).

    public static void main(String[] args) {
        // TODO 4: crie 5 usuários (1 válido + 4 com problemas) e
        //         valide cada um dentro de try/catch.
        System.out.println("(implemente o validador aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
    // ============================

    /*
    // --- Exceções customizadas ---

    static class CampoVazioException extends RuntimeException {
        public CampoVazioException(String mensagem) { super(mensagem); }
    }

    static class EmailInvalidoException extends RuntimeException {
        public EmailInvalidoException(String mensagem) { super(mensagem); }
    }

    static class IdadeInvalidaException extends RuntimeException {
        public IdadeInvalidaException(String mensagem) { super(mensagem); }
    }

    static class SenhaFracaException extends RuntimeException {
        public SenhaFracaException(String mensagem) { super(mensagem); }
    }

    // --- Modelo ---

    static class Usuario {
        String nome;
        String email;
        int idade;
        String senha;

        Usuario(String nome, String email, int idade, String senha) {
            this.nome = nome;
            this.email = email;
            this.idade = idade;
            this.senha = senha;
        }
    }

    // --- Validador ---

    static void validar(Usuario u) {
        // 1) Campos vazios (null ou só espaços)
        if (u.nome == null || u.nome.isBlank()) {
            throw new CampoVazioException("nome");
        }
        if (u.email == null || u.email.isBlank()) {
            throw new CampoVazioException("email");
        }
        if (u.senha == null || u.senha.isBlank()) {
            throw new CampoVazioException("senha");
        }

        // 2) Email — checagem simples (sem regex pra não complicar)
        if (!u.email.contains("@") || !u.email.contains(".")) {
            throw new EmailInvalidoException("'" + u.email + "'");
        }

        // 3) Idade
        if (u.idade < 18 || u.idade > 120) {
            throw new IdadeInvalidaException(String.valueOf(u.idade));
        }

        // 4) Senha forte: 8+ chars E pelo menos um dígito
        if (u.senha.length() < 8) {
            throw new SenhaFracaException(
                "precisa de 8+ caracteres e pelo menos um número"
            );
        }
        boolean temNumero = false;
        for (char c : u.senha.toCharArray()) {
            if (Character.isDigit(c)) {
                temNumero = true;
                break;
            }
        }
        if (!temNumero) {
            throw new SenhaFracaException(
                "precisa de 8+ caracteres e pelo menos um número"
            );
        }
    }

    // --- main ---

    public static void main(String[] args) {
        Usuario[] usuarios = {
            new Usuario("David",   "david@email.com",       30, "senha123"),    // ok
            new Usuario("",        "ana@email.com",         25, "outraSenha9"), // nome vazio
            new Usuario("Bruno",   "brunoemail.com",        28, "minhasenha1"), // email sem @
            new Usuario("Carla",   "carla@email.com",       15, "carla1234"),   // menor de idade
            new Usuario("Daniela", "daniela@email.com",     40, "semnumero"),   // senha sem número
        };

        for (int i = 0; i < usuarios.length; i++) {
            System.out.println("--- Validando usuário " + (i + 1) + " ---");
            Usuario u = usuarios[i];
            try {
                validar(u);
                System.out.println("✅ Usuário válido: " + u.nome);
            } catch (CampoVazioException e) {
                System.out.println("❌ Campo vazio: " + e.getMessage());
            } catch (EmailInvalidoException e) {
                System.out.println("❌ Email inválido: " + e.getMessage());
            } catch (IdadeInvalidaException e) {
                System.out.println("❌ Idade inválida: " + e.getMessage());
            } catch (SenhaFracaException e) {
                System.out.println("❌ Senha fraca: " + e.getMessage());
            }
        }
    }
    */
}
