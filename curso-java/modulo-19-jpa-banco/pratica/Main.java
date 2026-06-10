// Módulo 19 — JPA + Banco H2
// Prática: persistência de Ninjas com Spring Data JPA + H2 em memória.
//
// Esse arquivo NÃO roda sozinho como Main.java avulso — Spring + JPA
// exigem um projeto Maven/Gradle completo com pom.xml, application.properties
// e estrutura de pastas. O código abaixo está em COMENTÁRIO de bloco como
// referência: você copia para um projeto Spring Boot e roda lá.
//
// Como criar o projeto:
// 1) https://start.spring.io  →  Maven, Java 21, Spring Boot 3.x
// 2) Dependencies: Spring Web, Spring Data JPA, H2 Database
// 3) Gera o ZIP, abre no IntelliJ
// 4) Cola os arquivos abaixo nos pacotes corretos
// 5) Roda a classe ...Application e abre http://localhost:8080/h2-console

public class Main {
    public static void main(String[] args) {
        System.out.println("=== Módulo 19 — JPA + H2 ===");
        System.out.println();
        System.out.println("Esse arquivo é um GUIA, não roda diretamente.");
        System.out.println("Crie um projeto Spring Boot em https://start.spring.io");
        System.out.println("Dependências: Spring Web + Spring Data JPA + H2 Database");
        System.out.println();
        System.out.println("Cole nos pacotes correspondentes:");
        System.out.println(" - Ninja.java         (entidade)");
        System.out.println(" - NinjaRepository.java (interface JPA)");
        System.out.println(" - NinjaService.java  (regra de negócio)");
        System.out.println(" - application.properties (config H2)");
        System.out.println();
        System.out.println("Depois de rodar:");
        System.out.println(" - Console H2: http://localhost:8080/h2-console");
        System.out.println(" - JDBC URL:   jdbc:h2:mem:testdb");
        System.out.println(" - User: sa   Password: (vazio)");
    }
}

/*
============================================================
 1) src/main/java/com/exemplo/ninjas/Ninja.java
============================================================

package com.exemplo.ninjas;

import jakarta.persistence.*;

@Entity
@Table(name = "ninjas")          // (opcional) nome da tabela
public class Ninja {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // autoincremento
    private Long id;

    @Column(nullable = false, length = 100)
    private String nome;

    @Column(nullable = false, length = 50)
    private String vila;

    @Column(nullable = false)
    private int nivel;

    // Construtor vazio é OBRIGATÓRIO para JPA
    public Ninja() {}

    public Ninja(String nome, String vila, int nivel) {
        this.nome = nome;
        this.vila = vila;
        this.nivel = nivel;
    }

    // Getters e setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }

    public String getVila() { return vila; }
    public void setVila(String vila) { this.vila = vila; }

    public int getNivel() { return nivel; }
    public void setNivel(int nivel) { this.nivel = nivel; }

    @Override
    public String toString() {
        return "Ninja{id=" + id + ", nome='" + nome + "', vila='" + vila +
               "', nivel=" + nivel + "}";
    }
}

============================================================
 2) src/main/java/com/exemplo/ninjas/NinjaRepository.java
============================================================

package com.exemplo.ninjas;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

// JpaRepository<Entidade, TipoDoId> → ganha CRUD pronto.
// Spring Data JPA cria a implementação em tempo de execução. Você só declara.
public interface NinjaRepository extends JpaRepository<Ninja, Long> {

    // Derived queries — Spring lê o nome e gera o SQL.

    // SELECT * FROM ninjas WHERE vila = ?
    List<Ninja> findByVila(String vila);

    // SELECT * FROM ninjas WHERE nivel > ?
    List<Ninja> findByNivelGreaterThan(int nivel);

    // SELECT * FROM ninjas WHERE nome = ?  (Optional porque pode não achar)
    Optional<Ninja> findByNome(String nome);

    // SELECT * FROM ninjas WHERE vila = ? AND nivel >= ?
    List<Ninja> findByVilaAndNivelGreaterThanEqual(String vila, int nivel);

    // SELECT COUNT(*) FROM ninjas WHERE vila = ?
    long countByVila(String vila);
}

============================================================
 3) src/main/java/com/exemplo/ninjas/NinjaService.java
============================================================

package com.exemplo.ninjas;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class NinjaService {

    // Injeção via construtor (estilo recomendado)
    private final NinjaRepository repo;

    public NinjaService(NinjaRepository repo) {
        this.repo = repo;
    }

    public Ninja cadastrar(Ninja ninja) {
        // save() vira INSERT (sem id) ou UPDATE (com id existente)
        return repo.save(ninja);
    }

    public List<Ninja> listarTodos() {
        return repo.findAll();
    }

    public Optional<Ninja> buscarPorId(Long id) {
        return repo.findById(id);
    }

    public List<Ninja> buscarPorVila(String vila) {
        return repo.findByVila(vila);
    }

    public List<Ninja> ninjasFortes(int nivelMinimo) {
        return repo.findByNivelGreaterThan(nivelMinimo);
    }

    public long quantosNaVila(String vila) {
        return repo.countByVila(vila);
    }

    public void remover(Long id) {
        repo.deleteById(id);
    }
}

============================================================
 4) src/main/resources/application.properties
============================================================

# ----- H2 em memória -----
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# ----- Hibernate / JPA -----
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# ----- Console web do H2 -----
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

============================================================
 5) Como testar rápido (sem REST, direto no startup)
============================================================
Crie um CommandLineRunner pra popular o banco e testar as queries:

package com.exemplo.ninjas;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
class Seed implements CommandLineRunner {

    private final NinjaService service;

    Seed(NinjaService service) { this.service = service; }

    @Override
    public void run(String... args) {
        service.cadastrar(new Ninja("Naruto",  "Konoha", 99));
        service.cadastrar(new Ninja("Sasuke",  "Konoha", 95));
        service.cadastrar(new Ninja("Gaara",   "Suna",   90));
        service.cadastrar(new Ninja("Sakura",  "Konoha", 70));

        System.out.println("Total:           " + service.listarTodos().size());
        System.out.println("De Konoha:       " + service.buscarPorVila("Konoha"));
        System.out.println("Nivel > 90:      " + service.ninjasFortes(90));
        System.out.println("Quantos Konoha:  " + service.quantosNaVila("Konoha"));
    }
}

Saída esperada no console (resumida):
  Total: 4
  De Konoha: [Naruto, Sasuke, Sakura]
  Nivel > 90: [Naruto, Sasuke]
  Quantos Konoha: 3

E no http://localhost:8080/h2-console você consegue rodar SQL manual.
*/
