package com.exemplo;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.List;
import java.util.Optional;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
class ProdutoResourceMockTest {

    @InjectMock
    ProdutoService service;     // substitui o bean real no contexto CDI

    @Test
    void resourceUsaOQueOMockDevolve() {
        Mockito.when(service.listar())
               .thenReturn(List.of(new Produto(42L, "Mockado", 99.0)));

        given()
          .when().get("/produtos")
          .then()
             .statusCode(200)
             .body("size()", is(1))
             .body("[0].id", is(42))
             .body("[0].nome", is("Mockado"));
    }

    @Test
    void buscaQueRetornaEmptyVira404() {
        Mockito.when(service.buscar(7L)).thenReturn(Optional.empty());

        given()
          .when().get("/produtos/7")
          .then()
             .statusCode(404);
    }

    @Test
    void deletarChamaServiceComIdCorreto() {
        Mockito.when(service.deletar(5L)).thenReturn(true);

        given()
          .when().delete("/produtos/5")
          .then()
             .statusCode(204);

        Mockito.verify(service).deletar(5L);
    }
}
