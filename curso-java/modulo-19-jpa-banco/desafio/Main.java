// 🎯 DESAFIO DO MÓDULO 19 — Cadastro de Ninjas com Persistência
//
// Objetivo:
// Combinar o que você fez no Módulo 18 (REST API) com persistência real.
// Em vez de guardar Ninjas numa lista em memória que some ao reiniciar,
// agora eles vão pro banco H2 via Spring Data JPA.
//
// Cenário:
// A Vila Oculta da Folha (Konoha) precisa de um sistema central para
// cadastrar todos os ninjas em atividade. O sistema deve:
//   1. Permitir CRUD completo (criar, listar, buscar por id, atualizar, excluir)
//   2. Buscar ninjas por vila
//   3. Buscar os ninjas TOP da vila X (consulta custom com @Query)
//   4. Persistir tudo no H2 — não pode mais sumir ao reiniciar
//
// Endpoints obrigatórios:
//   POST   /ninjas                       → cria
//   GET    /ninjas                       → lista todos
//   GET    /ninjas/{id}                  → busca por id  (404 se não achar)
//   PUT    /ninjas/{id}                  → atualiza      (404 se não achar)
//   DELETE /ninjas/{id}                  → remove        (204 No Content)
//   GET    /ninjas/vila/{vila}           → lista por vila
//   GET    /ninjas/top?vila=Konoha       → ninjas top da vila (Bonus, @Query)
//
// Requisitos técnicos:
//   - Entidade JPA com @Entity, @Id, @GeneratedValue
//   - NinjaRepository extends JpaRepository<Ninja, Long>
//   - NinjaService injeta o repository
//   - NinjaController injeta o service
//   - Banco H2 em memória configurado
//   - Schema SQL inicial via migration (Flyway) OU script schema.sql
//   - main() imprime instruções pra testar
//
// 💡 Dicas:
//   - Reaproveite a estrutura do Módulo 18; troque a List<Ninja> pelo repo
//   - Use ResponseEntity pra retornar 200/201/204/404 corretamente
//   - O Postman/Insomnia/Bruno é seu amigo. Ou use curl.
//   - Confira o resultado em http://localhost:8080/h2-console

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    public static void main(String[] args) {
        // TODO: implemente o sistema seguindo o roteiro acima.
        // O código real fica nas classes Spring (Ninja, NinjaRepository,
        // NinjaService, NinjaController) em um projeto Maven com as dependências
        // Spring Web + Spring Data JPA + H2 (+ Flyway opcional).
        //
        // Aqui no main você só deixa as instruções:
        System.out.println("(implemente o CRUD persistente seguindo o roteiro)");
    }

    // ============================
    // SOLUÇÃO DE REFERÊNCIA (em comentário — vire um projeto Spring Boot)
    // ============================

    /*
    ============================================================
     pom.xml — dependências relevantes
    ============================================================

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    <!-- Opcional, para migrations: -->
    <dependency>
        <groupId>org.flywaydb</groupId>
        <artifactId>flyway-core</artifactId>
    </dependency>

    ============================================================
     src/main/resources/application.properties
    ============================================================

    spring.datasource.url=jdbc:h2:mem:konoha
    spring.datasource.username=sa
    spring.datasource.password=
    spring.datasource.driver-class-name=org.h2.Driver

    spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
    spring.jpa.show-sql=true
    spring.jpa.properties.hibernate.format_sql=true

    # Se usar Flyway, deixe a JPA só validando:
    # spring.jpa.hibernate.ddl-auto=validate
    # spring.flyway.enabled=true
    # spring.flyway.locations=classpath:db/migration
    #
    # Se NÃO usar Flyway, deixe a JPA criar o schema:
    spring.jpa.hibernate.ddl-auto=update

    spring.h2.console.enabled=true
    spring.h2.console.path=/h2-console

    ============================================================
     src/main/resources/db/migration/V1__cria_tabela_ninja.sql
     (use SE optar pelo Flyway)
    ============================================================

    CREATE TABLE ninja (
        id    BIGINT AUTO_INCREMENT PRIMARY KEY,
        nome  VARCHAR(100) NOT NULL,
        vila  VARCHAR(50)  NOT NULL,
        nivel INT          NOT NULL
    );

    -- Dados iniciais (opcional)
    INSERT INTO ninja (nome, vila, nivel) VALUES ('Naruto', 'Konoha', 99);
    INSERT INTO ninja (nome, vila, nivel) VALUES ('Sasuke', 'Konoha', 95);
    INSERT INTO ninja (nome, vila, nivel) VALUES ('Gaara',  'Suna',   90);

    ============================================================
     src/main/java/com/exemplo/konoha/Ninja.java
    ============================================================

    package com.exemplo.konoha;

    import jakarta.persistence.*;

    @Entity
    @Table(name = "ninja")
    public class Ninja {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @Column(nullable = false, length = 100)
        private String nome;

        @Column(nullable = false, length = 50)
        private String vila;

        @Column(nullable = false)
        private int nivel;

        public Ninja() {}

        public Ninja(String nome, String vila, int nivel) {
            this.nome = nome;
            this.vila = vila;
            this.nivel = nivel;
        }

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getNome() { return nome; }
        public void setNome(String nome) { this.nome = nome; }
        public String getVila() { return vila; }
        public void setVila(String vila) { this.vila = vila; }
        public int getNivel() { return nivel; }
        public void setNivel(int nivel) { this.nivel = nivel; }
    }

    ============================================================
     src/main/java/com/exemplo/konoha/NinjaRepository.java
    ============================================================

    package com.exemplo.konoha;

    import org.springframework.data.jpa.repository.JpaRepository;
    import org.springframework.data.jpa.repository.Query;
    import org.springframework.data.repository.query.Param;
    import java.util.List;

    public interface NinjaRepository extends JpaRepository<Ninja, Long> {

        List<Ninja> findByVila(String vila);

        // BONUS: consulta custom — TOP 5 da vila, ordenados pelo nível DESC
        @Query("SELECT n FROM Ninja n WHERE n.vila = :vila ORDER BY n.nivel DESC")
        List<Ninja> topDaVila(@Param("vila") String vila);
    }

    ============================================================
     src/main/java/com/exemplo/konoha/NinjaService.java
    ============================================================

    package com.exemplo.konoha;

    import org.springframework.stereotype.Service;
    import java.util.List;
    import java.util.Optional;

    @Service
    public class NinjaService {

        private final NinjaRepository repo;

        public NinjaService(NinjaRepository repo) {
            this.repo = repo;
        }

        public Ninja criar(Ninja n)            { return repo.save(n); }
        public List<Ninja> listar()            { return repo.findAll(); }
        public Optional<Ninja> buscar(Long id) { return repo.findById(id); }
        public List<Ninja> porVila(String v)   { return repo.findByVila(v); }
        public List<Ninja> topDaVila(String v) { return repo.topDaVila(v); }

        public Optional<Ninja> atualizar(Long id, Ninja dados) {
            return repo.findById(id).map(existente -> {
                existente.setNome(dados.getNome());
                existente.setVila(dados.getVila());
                existente.setNivel(dados.getNivel());
                return repo.save(existente);
            });
        }

        public boolean remover(Long id) {
            if (!repo.existsById(id)) return false;
            repo.deleteById(id);
            return true;
        }
    }

    ============================================================
     src/main/java/com/exemplo/konoha/NinjaController.java
    ============================================================

    package com.exemplo.konoha;

    import org.springframework.http.ResponseEntity;
    import org.springframework.web.bind.annotation.*;
    import java.net.URI;
    import java.util.List;

    @RestController
    @RequestMapping("/ninjas")
    public class NinjaController {

        private final NinjaService service;

        public NinjaController(NinjaService service) {
            this.service = service;
        }

        @PostMapping
        public ResponseEntity<Ninja> criar(@RequestBody Ninja n) {
            Ninja salvo = service.criar(n);
            return ResponseEntity
                    .created(URI.create("/ninjas/" + salvo.getId()))
                    .body(salvo);
        }

        @GetMapping
        public List<Ninja> listar() {
            return service.listar();
        }

        @GetMapping("/{id}")
        public ResponseEntity<Ninja> buscar(@PathVariable Long id) {
            return service.buscar(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        }

        @PutMapping("/{id}")
        public ResponseEntity<Ninja> atualizar(@PathVariable Long id,
                                               @RequestBody Ninja dados) {
            return service.atualizar(id, dados)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        }

        @DeleteMapping("/{id}")
        public ResponseEntity<Void> remover(@PathVariable Long id) {
            return service.remover(id)
                    ? ResponseEntity.noContent().build()
                    : ResponseEntity.notFound().build();
        }

        @GetMapping("/vila/{vila}")
        public List<Ninja> porVila(@PathVariable String vila) {
            return service.porVila(vila);
        }

        // BONUS: GET /ninjas/top?vila=Konoha
        @GetMapping("/top")
        public List<Ninja> topDaVila(@RequestParam String vila) {
            return service.topDaVila(vila);
        }
    }

    ============================================================
     Como testar (curl)
    ============================================================

    # Criar
    curl -X POST http://localhost:8080/ninjas \
         -H "Content-Type: application/json" \
         -d '{"nome":"Naruto","vila":"Konoha","nivel":99}'

    # Listar
    curl http://localhost:8080/ninjas

    # Buscar por id
    curl http://localhost:8080/ninjas/1

    # Atualizar
    curl -X PUT http://localhost:8080/ninjas/1 \
         -H "Content-Type: application/json" \
         -d '{"nome":"Naruto Uzumaki","vila":"Konoha","nivel":100}'

    # Por vila
    curl http://localhost:8080/ninjas/vila/Konoha

    # Top da vila (custom @Query)
    curl "http://localhost:8080/ninjas/top?vila=Konoha"

    # Remover
    curl -X DELETE http://localhost:8080/ninjas/1

    # Conferir no banco:
    # http://localhost:8080/h2-console  (JDBC URL: jdbc:h2:mem:konoha, user: sa)
    */
}
