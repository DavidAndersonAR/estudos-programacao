// Módulo 16 — Maven e Estrutura de Projetos
// Prática: este módulo é TEÓRICO-CONCEITUAL.
//
// Não tem muito código pra rodar aqui — o que importa é entender:
//   1. Como uma classe Java vive DENTRO de um projeto Maven
//   2. Como o pom.xml descreve o projeto e suas dependências
//   3. Onde cada arquivo fica na estrutura padrão
//
// Num projeto Maven de verdade, este arquivo estaria em:
//   meu-projeto/src/main/java/com/exemplo/app/Main.java
//
// E o pacote (primeira linha do arquivo) bateria com o caminho:
//   package com.exemplo.app;
//
// Aqui no curso, pra simplificar a execução solta com `java Main.java`,
// vamos deixar SEM declaração de package — mas em projetos reais
// SEMPRE existe um package que reflete a estrutura de pastas.
//
// ============================================================
// EXEMPLO DE pom.xml MÍNIMO QUE ACOMPANHARIA ESTE ARQUIVO
// ============================================================
/*
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.exemplo</groupId>
    <artifactId>app-pratica</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Sem dependências externas neste exemplo mínimo -->
    </dependencies>
</project>
*/
// ============================================================
//
// Com esse pom.xml e este Main.java em src/main/java/com/exemplo/app/,
// os comandos seriam:
//
//   mvn clean compile        # compila o código
//   mvn package              # gera target/app-pratica-1.0.0.jar
//   java -cp target/app-pratica-1.0.0.jar com.exemplo.app.Main
//
// ============================================================
// COMO SERIA A CLASSE NUM PROJETO MAVEN REAL
// (no curso, omitimos o package pra rodar solta — mas ela existiria)
// ============================================================
//
// package com.exemplo.app;
//
// public class Main {
//     public static void main(String[] args) {
//         System.out.println("Olá de dentro de um projeto Maven!");
//     }
// }
//
// ============================================================

public class Main {

    // Demonstra a estrutura típica: o "main" é só o ponto de entrada,
    // e a lógica fica em métodos/classes separadas (que em projetos
    // Maven reais ficariam em outros arquivos dentro do mesmo package).
    static void mostrarEstrutura() {
        System.out.println("Estrutura padrão de um projeto Maven:");
        System.out.println("  meu-projeto/");
        System.out.println("  ├── pom.xml");
        System.out.println("  ├── src/main/java/com/exemplo/app/Main.java");
        System.out.println("  ├── src/main/resources/application.properties");
        System.out.println("  ├── src/test/java/com/exemplo/app/MainTest.java");
        System.out.println("  └── target/   (gerado pelo build)");
    }

    static void mostrarCoordenadas() {
        // Toda biblioteca/projeto Maven tem 3 coordenadas:
        String groupId = "com.exemplo";
        String artifactId = "app-pratica";
        String version = "1.0.0";

        System.out.printf("Coordenadas Maven: %s:%s:%s%n", groupId, artifactId, version);
        System.out.println("Isso identifica unicamente este projeto no mundo Maven.");
    }

    static void mostrarFasesLifecycle() {
        String[] fases = {
            "validate", "compile", "test", "package", "verify", "install", "deploy"
        };

        System.out.println("Fases do lifecycle Maven (em ordem):");
        for (int i = 0; i < fases.length; i++) {
            System.out.printf("  %d. %s%n", i + 1, fases[i]);
        }
        System.out.println("Rodar uma fase executa TODAS as anteriores também.");
    }

    public static void main(String[] args) {
        System.out.println("=== Módulo 16: Maven (teórico) ===\n");

        System.out.println("--- Estrutura padrão ---");
        mostrarEstrutura();

        System.out.println("\n--- Coordenadas ---");
        mostrarCoordenadas();

        System.out.println("\n--- Lifecycle ---");
        mostrarFasesLifecycle();

        System.out.println("\n=> Veja a AULA.md para o conteúdo completo.");
        System.out.println("=> Encare o desafio em desafio/Main.java.");
    }
}
