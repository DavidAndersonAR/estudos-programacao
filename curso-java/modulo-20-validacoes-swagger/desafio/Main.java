// 🎯 DESAFIO DO MÓDULO 20 — API Completa Documentada
//
// Enunciado:
// Junte TUDO que aprendeu nos últimos módulos numa única API REST profissional:
//
//   - CRUD JPA (módulo 19)          → entidade, repositório, service
//   - Validações (módulo 20)        → @Valid no controller, anotações no DTO
//   - Exception handler global      → @ControllerAdvice + ProblemDetail
//   - Documentação Swagger          → @Tag, @Operation, @ApiResponses
//
// Domínio: cadastro de PRODUTOS de uma loja.
//
// Endpoints obrigatórios:
//   POST   /produtos          → cria (valida payload)
//   GET    /produtos          → lista todos
//   GET    /produtos/{id}     → busca por id (404 se não existe)
//   PUT    /produtos/{id}     → atualiza (valida payload + 404)
//   DELETE /produtos/{id}     → deleta (404 se não existe)
//
// Regras de validação (no DTO CriarProdutoRequest):
//   - nome:    obrigatório, 2 a 100 caracteres
//   - preco:   maior que zero (use @Positive)
//   - estoque: zero ou positivo (@PositiveOrZero)
//   - sku:     padrão "PROD-\d{4}" (use @Pattern)
//
// Critério de aceite:
//   - Subir o projeto (mvn spring-boot:run)
//   - Abrir http://localhost:8080/swagger-ui.html no browser
//   - Conseguir executar cada endpoint pela própria UI
//   - Payload inválido retorna 400 com mapa de erros
//   - Buscar id inexistente retorna 404 em formato ProblemDetail
//
// 💡 Dicas:
//   - Use @Tag na classe do controller, @Operation em cada método
//   - Use @ApiResponses pra documentar 200/201/400/404
//   - Crie ProdutoNaoEncontradoException estendendo RuntimeException
//   - O service joga a exceção; o handler global converte em 404
//   - Não esqueça @Valid no controller!

public class Main {

    public static void main(String[] args) {
        System.out.println("=== DESAFIO Módulo 20 — API Completa Documentada ===");
        System.out.println();
        System.out.println("Este é um projeto Spring Boot completo.");
        System.out.println();
        System.out.println("PASSOS:");
        System.out.println("  1. Gere projeto em start.spring.io com dependências:");
        System.out.println("       - Spring Web");
        System.out.println("       - Spring Data JPA");
        System.out.println("       - Validation");
        System.out.println("       - H2 Database");
        System.out.println("  2. Adicione no pom.xml:");
        System.out.println("       springdoc-openapi-starter-webmvc-ui (2.5.0)");
        System.out.println("  3. Copie as classes que estão em COMENTÁRIO abaixo");
        System.out.println("  4. mvn spring-boot:run");
        System.out.println("  5. Abra no browser: http://localhost:8080/swagger-ui.html");
        System.out.println("  6. Teste cada endpoint pela própria UI do Swagger");
    }
}

/* ============================================================
   SOLUÇÃO DE REFERÊNCIA — copie cada bloco em seu arquivo .java
   ============================================================ */


/* ------------------------------------------------------------
   application.properties (src/main/resources/)
   ------------------------------------------------------------

   # H2 em memória
   spring.datasource.url=jdbc:h2:mem:loja
   spring.datasource.driverClassName=org.h2.Driver
   spring.datasource.username=sa
   spring.datasource.password=
   spring.h2.console.enabled=true
   spring.jpa.hibernate.ddl-auto=update
   spring.jpa.show-sql=true

   # Swagger / Springdoc
   springdoc.swagger-ui.path=/swagger-ui.html
   springdoc.api-docs.path=/v3/api-docs
   springdoc.swagger-ui.operationsSorter=method
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   Produto.java (entidade JPA)
   ------------------------------------------------------------

   import jakarta.persistence.*;
   import java.math.BigDecimal;

   @Entity
   @Table(name = "produtos")
   public class Produto {

       @Id
       @GeneratedValue(strategy = GenerationType.IDENTITY)
       private Long id;

       private String nome;
       private BigDecimal preco;
       private int estoque;
       private String sku;

       public Produto() {}

       public Produto(String nome, BigDecimal preco, int estoque, String sku) {
           this.nome = nome;
           this.preco = preco;
           this.estoque = estoque;
           this.sku = sku;
       }

       // getters / setters omitidos por brevidade
       public Long getId() { return id; }
       public String getNome() { return nome; }
       public void setNome(String nome) { this.nome = nome; }
       public BigDecimal getPreco() { return preco; }
       public void setPreco(BigDecimal preco) { this.preco = preco; }
       public int getEstoque() { return estoque; }
       public void setEstoque(int estoque) { this.estoque = estoque; }
       public String getSku() { return sku; }
       public void setSku(String sku) { this.sku = sku; }
   }
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   CriarProdutoRequest.java (DTO validado)
   ------------------------------------------------------------

   import jakarta.validation.constraints.*;
   import java.math.BigDecimal;
   import io.swagger.v3.oas.annotations.media.Schema;

   @Schema(description = "Payload para criação/atualização de produto")
   public record CriarProdutoRequest(

       @Schema(example = "Caneta BIC", description = "Nome do produto")
       @NotBlank(message = "nome é obrigatório")
       @Size(min = 2, max = 100)
       String nome,

       @Schema(example = "2.50")
       @NotNull
       @Positive(message = "preço deve ser maior que zero")
       BigDecimal preco,

       @Schema(example = "150")
       @PositiveOrZero(message = "estoque não pode ser negativo")
       int estoque,

       @Schema(example = "PROD-0001")
       @Pattern(regexp = "PROD-\\d{4}", message = "SKU deve seguir PROD-XXXX")
       String sku
   ) {}
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   ProdutoRepository.java
   ------------------------------------------------------------

   import org.springframework.data.jpa.repository.JpaRepository;

   public interface ProdutoRepository extends JpaRepository<Produto, Long> {}
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   ProdutoNaoEncontradoException.java
   ------------------------------------------------------------

   public class ProdutoNaoEncontradoException extends RuntimeException {
       public ProdutoNaoEncontradoException(Long id) {
           super("Produto " + id + " não encontrado");
       }
   }
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   ProdutoService.java
   ------------------------------------------------------------

   import org.springframework.stereotype.Service;
   import java.util.List;

   @Service
   public class ProdutoService {

       private final ProdutoRepository repo;

       public ProdutoService(ProdutoRepository repo) { this.repo = repo; }

       public Produto criar(CriarProdutoRequest req) {
           Produto p = new Produto(req.nome(), req.preco(), req.estoque(), req.sku());
           return repo.save(p);
       }

       public List<Produto> listar() { return repo.findAll(); }

       public Produto buscar(Long id) {
           return repo.findById(id)
               .orElseThrow(() -> new ProdutoNaoEncontradoException(id));
       }

       public Produto atualizar(Long id, CriarProdutoRequest req) {
           Produto p = buscar(id); // joga 404 se não existe
           p.setNome(req.nome());
           p.setPreco(req.preco());
           p.setEstoque(req.estoque());
           p.setSku(req.sku());
           return repo.save(p);
       }

       public void deletar(Long id) {
           if (!repo.existsById(id)) throw new ProdutoNaoEncontradoException(id);
           repo.deleteById(id);
       }
   }
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   ProdutoController.java (TODO documentado no Swagger)
   ------------------------------------------------------------

   import io.swagger.v3.oas.annotations.Operation;
   import io.swagger.v3.oas.annotations.responses.ApiResponse;
   import io.swagger.v3.oas.annotations.responses.ApiResponses;
   import io.swagger.v3.oas.annotations.tags.Tag;
   import jakarta.validation.Valid;
   import org.springframework.http.ResponseEntity;
   import org.springframework.web.bind.annotation.*;
   import java.util.List;

   @RestController
   @RequestMapping("/produtos")
   @Tag(name = "Produtos", description = "CRUD de produtos da loja")
   public class ProdutoController {

       private final ProdutoService service;

       public ProdutoController(ProdutoService service) { this.service = service; }

       @PostMapping
       @Operation(summary = "Cria um produto", description = "Valida payload e persiste")
       @ApiResponses({
           @ApiResponse(responseCode = "201", description = "Produto criado"),
           @ApiResponse(responseCode = "400", description = "Dados inválidos")
       })
       public ResponseEntity<Produto> criar(@Valid @RequestBody CriarProdutoRequest req) {
           return ResponseEntity.status(201).body(service.criar(req));
       }

       @GetMapping
       @Operation(summary = "Lista todos os produtos")
       public List<Produto> listar() { return service.listar(); }

       @GetMapping("/{id}")
       @Operation(summary = "Busca produto por ID")
       @ApiResponses({
           @ApiResponse(responseCode = "200", description = "Encontrado"),
           @ApiResponse(responseCode = "404", description = "Não encontrado")
       })
       public Produto buscar(@PathVariable Long id) { return service.buscar(id); }

       @PutMapping("/{id}")
       @Operation(summary = "Atualiza produto existente")
       @ApiResponses({
           @ApiResponse(responseCode = "200", description = "Atualizado"),
           @ApiResponse(responseCode = "400", description = "Dados inválidos"),
           @ApiResponse(responseCode = "404", description = "Não encontrado")
       })
       public Produto atualizar(@PathVariable Long id,
                                @Valid @RequestBody CriarProdutoRequest req) {
           return service.atualizar(id, req);
       }

       @DeleteMapping("/{id}")
       @Operation(summary = "Remove produto")
       @ApiResponses({
           @ApiResponse(responseCode = "204", description = "Removido"),
           @ApiResponse(responseCode = "404", description = "Não encontrado")
       })
       public ResponseEntity<Void> deletar(@PathVariable Long id) {
           service.deletar(id);
           return ResponseEntity.noContent().build();
       }
   }
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   GlobalExceptionHandler.java
   ------------------------------------------------------------

   import org.springframework.http.*;
   import org.springframework.web.bind.MethodArgumentNotValidException;
   import org.springframework.web.bind.annotation.*;
   import java.util.HashMap;
   import java.util.Map;

   @ControllerAdvice
   public class GlobalExceptionHandler {

       @ExceptionHandler(ProdutoNaoEncontradoException.class)
       public ProblemDetail naoEncontrado(ProdutoNaoEncontradoException ex) {
           ProblemDetail pd = ProblemDetail.forStatusAndDetail(
               HttpStatus.NOT_FOUND, ex.getMessage()
           );
           pd.setTitle("Produto não encontrado");
           return pd;
       }

       @ExceptionHandler(MethodArgumentNotValidException.class)
       public ResponseEntity<Map<String, String>> validacao(
               MethodArgumentNotValidException ex) {
           Map<String, String> erros = new HashMap<>();
           ex.getBindingResult().getFieldErrors().forEach(e ->
               erros.put(e.getField(), e.getDefaultMessage())
           );
           return ResponseEntity.badRequest().body(erros);
       }

       @ExceptionHandler(Exception.class)
       public ProblemDetail generico(Exception ex) {
           return ProblemDetail.forStatusAndDetail(
               HttpStatus.INTERNAL_SERVER_ERROR,
               "Erro interno: " + ex.getClass().getSimpleName()
           );
       }
   }
   ------------------------------------------------------------ */


/* ------------------------------------------------------------
   Application.java (entry point Spring Boot)
   ------------------------------------------------------------

   import org.springframework.boot.SpringApplication;
   import org.springframework.boot.autoconfigure.SpringBootApplication;
   import io.swagger.v3.oas.annotations.OpenAPIDefinition;
   import io.swagger.v3.oas.annotations.info.Info;

   @SpringBootApplication
   @OpenAPIDefinition(info = @Info(
       title = "API da Loja",
       version = "1.0",
       description = "CRUD de produtos com validação e exception handler global"
   ))
   public class Application {
       public static void main(String[] args) {
           SpringApplication.run(Application.class, args);
       }
   }
   ------------------------------------------------------------ */


/* ============================================================
   AO RODAR (mvn spring-boot:run)
   ============================================================

   Abra no navegador:
       → http://localhost:8080/swagger-ui.html

   Você verá a UI interativa do Swagger, com a tag "Produtos"
   listando os 5 endpoints. Clique em qualquer um → "Try it out"
   → preencha → "Execute". A própria UI mostra request, response,
   código HTTP e headers.

   Console H2 (espiar o banco):
       → http://localhost:8080/h2-console
       (URL: jdbc:h2:mem:loja, user: sa, sem senha)

   Teste o handler global:
   1. POST /produtos com nome vazio e preco negativo → 400 com mapa de erros
   2. GET /produtos/9999 → 404 em formato ProblemDetail (RFC 7807)
   ============================================================ */
