// 🎯 DESAFIO DO MÓDULO 17 — Primeira App Spring
//
// Objetivo:
// Criar seu PRIMEIRO projeto Spring Boot do zero, gerado pelo start.spring.io,
// que ao iniciar imprime "Spring rodando!" e demonstra injeção de dependência
// (um @Service injetado num CommandLineRunner).
//
// Por que isso importa:
// Todo backend Java sério usa Spring Boot. Saber gerar um projeto, entender a
// estrutura e fazer a injeção funcionar é o "Hello World" do mundo corporativo.
//
// ─────────────────────────────────────────────────────────────────────────────
// PASSO A PASSO
// ─────────────────────────────────────────────────────────────────────────────
//
// 1) Vá em https://start.spring.io
//
// 2) Configure assim:
//      Project       : Maven
//      Language      : Java
//      Spring Boot   : versão estável mais recente (sem SNAPSHOT)
//      Group         : com.seunome
//      Artifact      : primeira-app
//      Name          : primeira-app
//      Packaging     : Jar
//      Java          : 21
//
// 3) Em "Dependencies" clique ADD DEPENDENCIES e adicione:
//      - Spring Web         (REST, MVC, Tomcat embutido)
//      - Spring Boot DevTools (opcional, reload em dev)
//
// 4) Clique GENERATE. Baixa um .zip. Descompacte numa pasta.
//
// 5) Abra a pasta no IntelliJ (File > Open > escolha a pasta do projeto).
//    Espere o IntelliJ baixar as dependências (Maven faz isso sozinho).
//
// 6) Edite a classe principal (PrimeiraAppApplication.java) para adicionar
//    o @Service e o CommandLineRunner — veja o exemplo abaixo.
//
// 7) Rode com:
//      Linux/Mac:  ./mvnw spring-boot:run
//      Windows:    mvnw.cmd spring-boot:run
//    Ou pelo botão verde do IntelliJ.
//
// 8) Confirme no console:
//      Spring rodando!
//      Mensagem do service: Tudo certo!
//
// ─────────────────────────────────────────────────────────────────────────────
// EXEMPLO DE CÓDIGO (cole/adapte em PrimeiraAppApplication.java)
// ─────────────────────────────────────────────────────────────────────────────
/*
package com.seunome.primeiraapp;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

@SpringBootApplication
public class PrimeiraAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(PrimeiraAppApplication.class, args);
    }
}

// regra de negócio — Spring vai instanciar e gerenciar isso
@Service
class MensagemService {
    public String mensagem() {
        return "Tudo certo!";
    }
}

// roda uma vez quando o contexto sobe
@Component
class Inicializador implements CommandLineRunner {

    private final MensagemService service;

    // injeção por construtor — Spring entrega o MensagemService pronto
    public Inicializador(MensagemService service) {
        this.service = service;
    }

    @Override
    public void run(String... args) {
        System.out.println("Spring rodando!");
        System.out.println("Mensagem do service: " + service.mensagem());
    }
}
*/
//
// ─────────────────────────────────────────────────────────────────────────────
// REQUISITOS DA ENTREGA
// ─────────────────────────────────────────────────────────────────────────────
// 1. Projeto gerado pelo start.spring.io (estrutura Maven correta).
// 2. Pelo menos uma classe @Service.
// 3. Pelo menos um @Component implementando CommandLineRunner.
// 4. Injeção de dependência por CONSTRUTOR (não usar @Autowired no campo).
// 5. Console mostra "Spring rodando!" e a mensagem do service.
//
// 💡 Dicas:
//  - Se der "NullPointerException" no service: provavelmente esqueceu @Service.
//  - Se o Inicializador não rodar: confira o @Component e o implements
//    CommandLineRunner.
//  - Se o IntelliJ não acha as dependências: clique direito no pom.xml >
//    "Maven > Reload Project".
//  - O Spring imprime um banner de tomate na cor verde no início — é normal.
//  - Pra parar a app: Ctrl+C no terminal.
//
// 🌶️  Variações pra brincar (opcional):
//  - Crie um segundo @Service e injete os dois no Inicializador.
//  - Adicione Spring Web e crie um @RestController com um GET "/" que devolve
//    a mensagem do service (preview do módulo 18).
//  - Mude server.port no application.properties pra 9090 e veja a diferença.

public class Main {
    public static void main(String[] args) {
        System.out.println("veja instruções");
    }
}
