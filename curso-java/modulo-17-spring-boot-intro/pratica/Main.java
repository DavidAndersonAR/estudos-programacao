// Módulo 17 — Spring Boot Intro
// Prática: este módulo precisa de um PROJETO MAVEN COMPLETO (Spring Boot não roda
// num único Main.java solto). Por isso, o código de exemplo está TODO comentado
// abaixo — você deve criar o projeto via https://start.spring.io e colar nos
// arquivos correspondentes.
//
// ─────────────────────────────────────────────────────────────────────────────
//                        APP SPRING BOOT MÍNIMA — EXEMPLO
// ─────────────────────────────────────────────────────────────────────────────
//
// Estrutura do projeto (gerada pelo start.spring.io):
//
//   demo/
//   ├── pom.xml
//   ├── mvnw, mvnw.cmd
//   └── src/main/java/com/exemplo/demo/
//       └── DemoApplication.java
//
// ─────────────────────────────────────────────────────────────────────────────
// ARQUIVO 1 — pom.xml  (na raiz do projeto)
// ─────────────────────────────────────────────────────────────────────────────
/*
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
        <relativePath/>
    </parent>

    <groupId>com.exemplo</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>

    <properties>
        <java.version>21</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
*/
//
// ─────────────────────────────────────────────────────────────────────────────
// ARQUIVO 2 — DemoApplication.java
// (em src/main/java/com/exemplo/demo/)
// ─────────────────────────────────────────────────────────────────────────────
/*
package com.exemplo.demo;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

// ┌──────────────────────────────────────────────────────────────────┐
// │ 1) PONTO DE PARTIDA                                              │
// │ @SpringBootApplication = @Configuration + @EnableAutoConfiguration│
// │                          + @ComponentScan                        │
// │ SpringApplication.run liga o motor: cria o contexto IoC,         │
// │ escaneia classes, instancia beans, chama CommandLineRunner.      │
// └──────────────────────────────────────────────────────────────────┘
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}

// ┌──────────────────────────────────────────────────────────────────┐
// │ 2) SERVICE — regra de negócio                                    │
// │ Marcado com @Service, vira um bean no contêiner do Spring.       │
// │ Singleton por padrão (uma instância só pra app inteira).         │
// └──────────────────────────────────────────────────────────────────┘
@Service
class SaudacaoService {
    public String saudar(String nome) {
        return "Olá, " + nome + "! Bem-vindo ao Spring Boot.";
    }
}

// ┌──────────────────────────────────────────────────────────────────┐
// │ 3) COMPONENT que roda ao iniciar                                 │
// │ CommandLineRunner.run() é chamado UMA vez depois que o contexto  │
// │ sobe. Perfeito pra demonstrar injeção de dependência.            │
// │                                                                  │
// │ Note a INJEÇÃO POR CONSTRUTOR: o Spring vê que App precisa de    │
// │ SaudacaoService e ENTREGA pronto. Você NUNCA dá `new`.           │
// └──────────────────────────────────────────────────────────────────┘
@Component
class App implements CommandLineRunner {

    private final SaudacaoService saudacaoService;

    public App(SaudacaoService saudacaoService) {  // ← injeção de dependência
        this.saudacaoService = saudacaoService;
    }

    @Override
    public void run(String... args) {
        System.out.println(saudacaoService.saudar("David"));
        System.out.println("Spring Boot rodou. Beans instanciados pelo contêiner IoC.");
    }
}
*/
//
// ─────────────────────────────────────────────────────────────────────────────
// ARQUIVO 3 — application.properties
// (em src/main/resources/)
// ─────────────────────────────────────────────────────────────────────────────
/*
spring.application.name=demo
# servidor web só sobe se você tiver spring-boot-starter-web no pom
# server.port=8080
*/
//
// ─────────────────────────────────────────────────────────────────────────────
// COMO RODAR
// ─────────────────────────────────────────────────────────────────────────────
//
//   Linux/Mac:  ./mvnw spring-boot:run
//   Windows:    mvnw.cmd spring-boot:run
//
// Saída esperada (depois do banner do Spring):
//   Olá, David! Bem-vindo ao Spring Boot.
//   Spring Boot rodou. Beans instanciados pelo contêiner IoC.
//
// ─────────────────────────────────────────────────────────────────────────────
// FLUXO POR DENTRO (o que aconteceu)
// ─────────────────────────────────────────────────────────────────────────────
//
//   1. main() chama SpringApplication.run(DemoApplication.class, args)
//   2. Spring cria o ApplicationContext (o contêiner IoC)
//   3. @ComponentScan varre o pacote com.exemplo.demo e subpacotes
//   4. Acha SaudacaoService (@Service) e App (@Component)
//   5. Cria SaudacaoService primeiro (não depende de nada)
//   6. Cria App, e percebe que o construtor pede SaudacaoService
//   7. INJETA o SaudacaoService no construtor de App
//   8. Como App é CommandLineRunner, chama run(...) automaticamente
//   9. run() imprime as mensagens e o programa termina

public class Main {
    public static void main(String[] args) {
        System.out.println("Este módulo precisa de projeto Maven — veja as instruções no comentário acima.");
    }
}
