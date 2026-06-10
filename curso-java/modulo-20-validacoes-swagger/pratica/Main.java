// Módulo 20 — Validações + Exceções + Swagger (PRÁTICA)
//
// Este arquivo NÃO roda como main() — o módulo é Spring Boot e exige
// projeto Maven completo (pom.xml + estrutura src/main/java). Os blocos
// abaixo ficam em COMENTÁRIO mostrando como cada peça se encaixa.
//
// Estrutura esperada:
//
//   pom.xml
//   src/main/java/com/exemplo/
//       Application.java
//       Usuario.java
//       CriarUsuarioRequest.java
//       UsuarioController.java
//       GlobalExceptionHandler.java
//       RecursoNaoEncontradoException.java
//   src/main/resources/application.properties

public class Main {

    public static void main(String[] args) {
        System.out.println("=== Módulo 20 — Validações + Exceções + Swagger ===");
        System.out.println();
        System.out.println("Este módulo NÃO roda como Java puro.");
        System.out.println("Os blocos de código estão em COMENTÁRIO abaixo.");
        System.out.println();
        System.out.println("Para executar de verdade:");
        System.out.println("  1. Crie projeto Spring Boot em start.spring.io");
        System.out.println("     (Web + Validation + JPA + H2)");
        System.out.println("  2. Cole o pom.xml e as classes deste arquivo");
        System.out.println("  3. mvn spring-boot:run");
        System.out.println("  4. Abra http://localhost:8080/swagger-ui.html");
        System.out.println();
        System.out.println("Leia o AULA.md primeiro!");
    }
}

/* ============================================================
   EXERCÍCIO 1 — pom.xml (dependências essenciais)
   ============================================================

   <project xmlns="http://maven.apache.org/POM/4.0.0">
       <modelVersion>4.0.0</modelVersion>
       <parent>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-parent</artifactId>
           <version>3.3.0</version>
       </parent>
       <groupId>com.exemplo</groupId>
       <artifactId>api-validada</artifactId>
       <version>1.0.0</version>

       <properties>
           <java.version>21</java.version>
       </properties>

       <dependencies>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-web</artifactId>
           </dependency>
           <!-- Bean Validation (Jakarta Validation) -->
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-validation</artifactId>
           </dependency>
           <!-- Swagger / OpenAPI -->
           <dependency>
               <groupId>org.springdoc</groupId>
               <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
               <version>2.5.0</version>
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
   ============================================================ */


/* ============================================================
   EXERCÍCIO 2 — DTO de entrada com Bean Validation
   ============================================================

   import jakarta.validation.constraints.*;

   public record CriarUsuarioRequest(

       @NotBlank(message = "nome é obrigatório")
       @Size(min = 2, max = 100, message = "nome entre 2 e 100 caracteres")
       String nome,

       @NotBlank(message = "email é obrigatório")
       @Email(message = "formato de email inválido")
       String email,

       @Min(value = 18, message = "precisa ter pelo menos 18 anos")
       @Max(value = 120, message = "idade improvável")
       int idade,

       @Pattern(regexp = "\\d{11}", message = "CPF deve ter 11 dígitos")
       String cpf
   ) {}

   // Observação:
   //   @NotBlank — proíbe null, vazio e só-espaços (use SEMPRE pra String)
   //   @NotNull  — só proíbe null (aceita "")
   //   @Email    — valida formato (não verifica se existe de verdade)
   ============================================================ */


/* ============================================================
   EXERCÍCIO 3 — Exceção de negócio própria
   ============================================================

   public class RecursoNaoEncontradoException extends RuntimeException {
       public RecursoNaoEncontradoException(String mensagem) {
           super(mensagem);
       }
   }
   ============================================================ */


/* ============================================================
   EXERCÍCIO 4 — Controller usando @Valid
   ============================================================

   import jakarta.validation.Valid;
   import org.springframework.http.ResponseEntity;
   import org.springframework.web.bind.annotation.*;

   @RestController
   @RequestMapping("/usuarios")
   public class UsuarioController {

       // @Valid é OBRIGATÓRIO — sem ele Spring ignora as anotações do DTO
       @PostMapping
       public ResponseEntity<String> criar(@Valid @RequestBody CriarUsuarioRequest req) {
           // se chegou aqui, passou em TODAS as validações
           return ResponseEntity.status(201).body("Usuário criado: " + req.nome());
       }

       @GetMapping("/{id}")
       public String buscar(@PathVariable Long id) {
           if (id > 100) {
               // exceção própria → handler global vai pegar
               throw new RecursoNaoEncontradoException("Usuário " + id + " não existe");
           }
           return "Usuário " + id;
       }
   }
   ============================================================ */


/* ============================================================
   EXERCÍCIO 5 — Handler global com @ControllerAdvice
   ============================================================

   import org.springframework.http.*;
   import org.springframework.web.bind.MethodArgumentNotValidException;
   import org.springframework.web.bind.annotation.*;
   import java.util.HashMap;
   import java.util.Map;

   @ControllerAdvice
   public class GlobalExceptionHandler {

       // Recurso não encontrado → 404 com ProblemDetail (RFC 7807, Spring 6+)
       @ExceptionHandler(RecursoNaoEncontradoException.class)
       public ProblemDetail tratarNaoEncontrado(RecursoNaoEncontradoException ex) {
           ProblemDetail pd = ProblemDetail.forStatusAndDetail(
               HttpStatus.NOT_FOUND, ex.getMessage()
           );
           pd.setTitle("Recurso não encontrado");
           return pd;
       }

       // Erros de validação → 400 com mapa campo → mensagem
       @ExceptionHandler(MethodArgumentNotValidException.class)
       public ResponseEntity<Map<String, String>> tratarValidacao(
               MethodArgumentNotValidException ex) {
           Map<String, String> erros = new HashMap<>();
           ex.getBindingResult().getFieldErrors().forEach(e ->
               erros.put(e.getField(), e.getDefaultMessage())
           );
           return ResponseEntity.badRequest().body(erros);
       }

       // Catch-all → 500 (último handler, evita vazar stack trace)
       @ExceptionHandler(Exception.class)
       public ProblemDetail tratarGenerico(Exception ex) {
           return ProblemDetail.forStatusAndDetail(
               HttpStatus.INTERNAL_SERVER_ERROR,
               "Erro interno: " + ex.getClass().getSimpleName()
           );
       }
   }
   ============================================================ */


/* ============================================================
   EXERCÍCIO 6 — Testando os erros (manual via curl)
   ============================================================

   Sucesso (HTTP 201):
   curl -X POST http://localhost:8080/usuarios \
        -H "Content-Type: application/json" \
        -d '{"nome":"Ana","email":"ana@ex.com","idade":25,"cpf":"12345678901"}'

   Validação falhando (HTTP 400):
   curl -X POST http://localhost:8080/usuarios \
        -H "Content-Type: application/json" \
        -d '{"nome":"","email":"naoEhEmail","idade":15,"cpf":"123"}'

   Resposta:
   {
     "nome":  "nome é obrigatório",
     "email": "formato de email inválido",
     "idade": "precisa ter pelo menos 18 anos",
     "cpf":   "CPF deve ter 11 dígitos"
   }

   Recurso não encontrado (HTTP 404):
   curl http://localhost:8080/usuarios/999

   Resposta (ProblemDetail):
   {
     "type":   "about:blank",
     "title":  "Recurso não encontrado",
     "status": 404,
     "detail": "Usuário 999 não existe"
   }
   ============================================================ */
