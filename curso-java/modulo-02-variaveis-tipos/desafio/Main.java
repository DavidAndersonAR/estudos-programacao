// 🎯 DESAFIO DO MÓDULO 02 — Calculadora de IMC
//
// Objetivo:
// Calcule o Índice de Massa Corporal (IMC) e classifique o resultado.
// Por enquanto, peso e altura ficam HARDCODED (depois você aprende Scanner).
//
// Fórmula:
//   IMC = peso / (altura * altura)
//   - peso em quilos (double)
//   - altura em metros (double)
//
// Classificação (Organização Mundial da Saúde):
//   IMC < 18.5         → "Abaixo do peso"
//   18.5 <= IMC < 25   → "Peso normal"
//   25   <= IMC < 30   → "Sobrepeso"
//   IMC >= 30          → "Obesidade"
//
// Resultado esperado (exemplo):
//
//   === Calculadora de IMC ===
//   Peso: 75.0 kg
//   Altura: 1.75 m
//   IMC: 24.49
//   Classificação: Peso normal
//
// Requisitos:
// 1. Use variáveis com tipos apropriados (double para peso/altura/imc, String para classificação).
// 2. Use pelo menos uma constante com `final` (ex.: limites da classificação).
// 3. Use `if/else if/else` para a classificação.
// 4. Imprima o IMC com 2 casas decimais (use printf com %.2f).
//
// 💡 Dicas:
//   - Multiplicar altura por ela mesma: altura * altura  (ou Math.pow(altura, 2))
//   - printf com %.2f arredonda visualmente para 2 casas
//   - Encadeie if/else if pra não testar a mesma condição duas vezes
//   - Teste com vários valores: 50/1.70, 75/1.75, 95/1.80, 120/1.75

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        // TODO: implemente a calculadora aqui.
        // 1. Declare peso (double) e altura (double) com valores fixos.
        // 2. Calcule o IMC.
        // 3. Classifique usando if/else if/else.
        // 4. Imprima peso, altura, IMC (2 casas) e a classificação.

        System.out.println("(implemente a calculadora de IMC aqui)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    public static void main(String[] args) {
        // Constantes com os limites da classificação (OMS)
        final double LIMITE_ABAIXO_PESO = 18.5;
        final double LIMITE_PESO_NORMAL = 25.0;
        final double LIMITE_SOBREPESO   = 30.0;

        // Dados de entrada (hardcoded por enquanto)
        double peso = 75.0;     // kg
        double altura = 1.75;   // m

        // Cálculo do IMC
        double imc = peso / (altura * altura);

        // Classificação
        String classificacao;
        if (imc < LIMITE_ABAIXO_PESO) {
            classificacao = "Abaixo do peso";
        } else if (imc < LIMITE_PESO_NORMAL) {
            classificacao = "Peso normal";
        } else if (imc < LIMITE_SOBREPESO) {
            classificacao = "Sobrepeso";
        } else {
            classificacao = "Obesidade";
        }

        // Saída formatada
        System.out.println("=== Calculadora de IMC ===");
        System.out.printf("Peso: %.1f kg%n", peso);
        System.out.printf("Altura: %.2f m%n", altura);
        System.out.printf("IMC: %.2f%n", imc);
        System.out.println("Classificação: " + classificacao);
    }
    */
}
