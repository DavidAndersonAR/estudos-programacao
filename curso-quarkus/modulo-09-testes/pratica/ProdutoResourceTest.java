package com.exemplo;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@QuarkusTest
class ProdutoResourceTest {

    @Test
    void listarDevolveOsProdutosDoSeed() {
        given()
          .when().get("/produtos")
          .then()
             .statusCode(200)
             .body("size()", greaterThanOrEqualTo(2))
             .body("nome", hasItems("Caneta", "Caderno"));
    }

    @Test
    void buscarInexistenteDevolve404() {
        given()
          .when().get("/produtos/9999")
          .then()
             .statusCode(404);
    }

    @Test
    void criarValidoDevolve201ComId() {
        given()
            .contentType(ContentType.JSON)
            .body("{\"nome\":\"Borracha\",\"preco\":3.5}")
        .when()
            .post("/produtos")
        .then()
            .statusCode(201)
            .body("id", notNullValue())
            .body("nome", is("Borracha"));
    }

    @Test
    void criarComPrecoNegativoDevolve400() {
        given()
            .contentType(ContentType.JSON)
            .body("{\"nome\":\"Errado\",\"preco\":-10}")
        .when()
            .post("/produtos")
        .then()
            .statusCode(400);
    }
}
