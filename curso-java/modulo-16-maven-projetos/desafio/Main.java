// 🎯 DESAFIO DO MÓDULO 16 — Setup de Projeto Maven
//
// Objetivo:
// Criar um projeto Maven do ZERO, adicionar uma dependência do Maven Central
// (Gson — biblioteca de JSON do Google) e gerar o .jar.
//
// Este desafio é PRÁTICO mas NÃO se executa neste arquivo:
// você vai criar arquivos/pastas no seu sistema seguindo os passos abaixo.
//
// ============================================================
// PASSO A PASSO — VIA LINHA DE COMANDO
// ============================================================
//
// 1. Verifique se o Maven está instalado:
//      mvn -v
//    (Se não tiver, baixe em https://maven.apache.org/download.cgi
//     ou instale via SDKMAN/Chocolatey/brew.)
//
// 2. Crie o projeto a partir de um ARQUÉTIPO (template oficial):
//      mvn archetype:generate \
//          -DgroupId=com.exemplo \
//          -DartifactId=meu-primeiro-app \
//          -DarchetypeArtifactId=maven-archetype-quickstart \
//          -DarchetypeVersion=1.4 \
//          -DinteractiveMode=false
//
//    No Windows (PowerShell), use crase (`) ou tudo em uma linha:
//      mvn archetype:generate -DgroupId=com.exemplo -DartifactId=meu-primeiro-app -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
//
// 3. Entre na pasta e explore a estrutura criada:
//      cd meu-primeiro-app
//
//    Você verá:
//      meu-primeiro-app/
//      ├── pom.xml
//      └── src/
//          ├── main/java/com/exemplo/App.java
//          └── test/java/com/exemplo/AppTest.java
//
// 4. Abra o pom.xml e ADICIONE a dependência do Gson dentro de <dependencies>:
//      <dependency>
//          <groupId>com.google.code.gson</groupId>
//          <artifactId>gson</artifactId>
//          <version>2.10.1</version>
//      </dependency>
//
//    Atualize também a versão do Java (na seção <properties> ou <build>):
//      <maven.compiler.source>21</maven.compiler.source>
//      <maven.compiler.target>21</maven.compiler.target>
//
// 5. Modifique src/main/java/com/exemplo/App.java pra usar o Gson:
//      package com.exemplo;
//      import com.google.gson.Gson;
//      import java.util.Map;
//
//      public class App {
//          public static void main(String[] args) {
//              Gson gson = new Gson();
//              String json = gson.toJson(Map.of("nome", "David", "modulo", 16));
//              System.out.println(json);
//          }
//      }
//
// 6. Compile, teste e empacote:
//      mvn clean package
//
//    Se tudo der certo, vai aparecer:
//      target/meu-primeiro-app-1.0-SNAPSHOT.jar
//
// 7. Rode o jar (precisa do classpath com o Gson):
//      mvn exec:java -Dexec.mainClass=com.exemplo.App
//    OU configure o plugin shade pra gerar um "fat jar" com tudo dentro.
//
// ============================================================
// PASSO A PASSO — VIA INTELLIJ IDEA
// ============================================================
//
// 1. File → New → Project...
// 2. Escolha "Maven" no painel da esquerda
// 3. Preencha:
//      Name:        meu-primeiro-app
//      GroupId:     com.exemplo
//      ArtifactId:  meu-primeiro-app
//      JDK:         21
// 4. Clique "Create". O IntelliJ cria a estrutura padrão automaticamente.
// 5. Abra o pom.xml, adicione a dependência do Gson (mesmo XML do passo 4 acima).
// 6. Clique no ícone de "Load Maven Changes" (canto superior direito do editor)
//    ou pressione Ctrl+Shift+O — o IntelliJ baixa o Gson.
// 7. Edite src/main/java/com/exemplo/App.java e use o Gson.
// 8. Rode pelo botão verde (▶) ao lado do main, ou no terminal:
//      mvn clean package
//
// ============================================================
// EXEMPLO DE pom.xml COMPLETO (o que você deve ter ao final)
// ============================================================
/*
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <!-- Coordenadas do projeto -->
    <groupId>com.exemplo</groupId>
    <artifactId>meu-primeiro-app</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>meu-primeiro-app</name>
    <url>http://www.example.com</url>

    <!-- Propriedades reutilizáveis -->
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <gson.version>2.10.1</gson.version>
        <junit.version>5.10.0</junit.version>
    </properties>

    <!-- Dependências -->
    <dependencies>
        <!-- Gson: serialização JSON -->
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>${gson.version}</version>
        </dependency>

        <!-- JUnit 5: testes (scope=test só vai no classpath de teste) -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <!-- Plugins de build -->
    <build>
        <plugins>
            <!-- Plugin do compilador (garante versão do Java) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
            </plugin>

            <!-- Plugin pra rodar testes -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
            </plugin>
        </plugins>
    </build>
</project>
*/
// ============================================================
// CRITÉRIO DE SUCESSO
// ============================================================
//
// Você termina o desafio quando:
//   [ ] Tem uma pasta meu-primeiro-app/ com a estrutura padrão Maven
//   [ ] O pom.xml tem groupId, artifactId, version e a dependência do Gson
//   [ ] `mvn clean package` roda sem erros e gera o .jar em target/
//   [ ] Seu App.java consegue importar e usar a classe Gson
//   [ ] Você consegue explicar (em voz alta) o que cada seção do pom.xml faz
//
// 💡 DICAS:
//   - Se `mvn` não for reconhecido, instale o Maven e adicione ao PATH
//   - A primeira execução baixa MUITA coisa do Maven Central — paciência
//   - Para ver a árvore de dependências: mvn dependency:tree
//   - Para limpar e recomeçar: mvn clean (apaga target/)
//   - No IntelliJ, o "Maven tool window" (lateral direita) mostra tudo visualmente

public class Main {

    // ============================
    // ESTE ARQUIVO É SÓ UM ROTEIRO
    // ============================
    // O desafio acontece no seu sistema de arquivos (criar pasta, pom.xml, etc).
    // O main() abaixo só lembra você de seguir as instruções no topo.

    public static void main(String[] args) {
        System.out.println("Veja as instruções no topo do arquivo.");
        System.out.println("Este desafio é prático: crie o projeto Maven seguindo o passo a passo.");
    }
}
