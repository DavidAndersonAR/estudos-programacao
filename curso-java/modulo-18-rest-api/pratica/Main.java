// Módulo 18 — REST API com Spring
// Prática: um controller "Olá" mostrando os 4 modos básicos de receber dados
// num endpoint REST: nada, path variable, query param e request body.
//
// IMPORTANTE: este arquivo NÃO roda standalone (precisa do contexto Spring Boot).
// Ele serve como REFERÊNCIA de código pra você reproduzir num projeto Spring real.
//
// Como criar o projeto:
//   1. Vá em https://start.spring.io
//   2. Tipo: Maven | Java 21 | Spring Boot 3.x
//   3. Dependência: "Spring Web"
//   4. Gere, abra no IntelliJ, e cole as classes abaixo em src/main/java/...
//   5. Rode a classe @SpringBootApplication — sobe em http://localhost:8080
//
// =====================================================================
// CÓDIGO COMPLETO DE REFERÊNCIA (descomente num projeto Spring real)
// =====================================================================
/*
package com.exemplo.ola;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

// DTO de exemplo — record é o padrão moderno (imutável, conciso).
// Jackson serializa/desserializa records automaticamente.
public record MensagemDTO(String texto) {}

@RestController
@RequestMapping("/api")
public class HelloController {

    // ------------------------------------------------------------------
    // 1) GET sem parâmetro — endpoint mais simples possível.
    //    URL: GET http://localhost:8080/api/hello
    //    Retorno: {"texto":"Olá, mundo!"}
    // ------------------------------------------------------------------
    @GetMapping("/hello")
    public MensagemDTO ola() {
        return new MensagemDTO("Olá, mundo!");
    }

    // ------------------------------------------------------------------
    // 2) GET com @PathVariable — pega trecho da URL.
    //    URL: GET http://localhost:8080/api/hello/David
    //    Retorno: {"texto":"Olá, David!"}
    //
    //    O nome no path ({nome}) deve bater com o parâmetro Java,
    //    OU você usa @PathVariable("nome") String x pra renomear.
    // ------------------------------------------------------------------
    @GetMapping("/hello/{nome}")
    public MensagemDTO olaPath(@PathVariable String nome) {
        return new MensagemDTO("Olá, " + nome + "!");
    }

    // ------------------------------------------------------------------
    // 3) GET com @RequestParam — pega query string (?chave=valor).
    //    URL: GET http://localhost:8080/api/saudacao?nome=David
    //    Retorno: {"texto":"Olá, David!"}
    //
    //    required = false torna opcional. defaultValue dá um padrão.
    // ------------------------------------------------------------------
    @GetMapping("/saudacao")
    public MensagemDTO olaQuery(
            @RequestParam(required = false, defaultValue = "anônimo") String nome) {
        return new MensagemDTO("Olá, " + nome + "!");
    }

    // ------------------------------------------------------------------
    // 4) POST com @RequestBody — recebe JSON no corpo.
    //    URL: POST http://localhost:8080/api/eco
    //    Body: {"texto":"oi"}
    //    Retorno: {"texto":"você disse: oi"}
    //
    //    O Jackson converte o JSON automaticamente pro record MensagemDTO.
    // ------------------------------------------------------------------
    @PostMapping("/eco")
    public MensagemDTO eco(@RequestBody MensagemDTO entrada) {
        return new MensagemDTO("você disse: " + entrada.texto());
    }
}

// Classe principal do Spring Boot — sobe o servidor embutido (Tomcat).
@org.springframework.boot.autoconfigure.SpringBootApplication
class OlaApplication {
    public static void main(String[] args) {
        org.springframework.boot.SpringApplication.run(OlaApplication.class, args);
    }
}
*/

// =====================================================================
// TESTES COM curl (depois de subir o projeto Spring real)
// =====================================================================
//
// 1) GET simples:
//    curl http://localhost:8080/api/hello
//
// 2) GET com path variable:
//    curl http://localhost:8080/api/hello/David
//
// 3) GET com query param:
//    curl "http://localhost:8080/api/saudacao?nome=David"
//
// 4) POST com body JSON:
//    curl -X POST http://localhost:8080/api/eco \
//         -H "Content-Type: application/json" \
//         -d "{\"texto\":\"oi\"}"
//
// =====================================================================
// Este Main.java só imprime instruções — o código real está no comentário.
// =====================================================================

public class Main {
    public static void main(String[] args) {
        System.out.println("=== Módulo 18 — Prática: REST com Spring ===");
        System.out.println();
        System.out.println("Veja os exemplos no comentário acima — implemente");
        System.out.println("num projeto Spring real (gerado em start.spring.io).");
        System.out.println();
        System.out.println("Endpoints de exemplo (depois de subir o projeto):");
        System.out.println("  GET  /api/hello             → Olá, mundo!");
        System.out.println("  GET  /api/hello/{nome}      → Olá, <nome>!");
        System.out.println("  GET  /api/saudacao?nome=X   → Olá, X!");
        System.out.println("  POST /api/eco  (body JSON)  → você disse: ...");
    }
}
