# Módulo 09 — Testes em Quarkus

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever testes unitários puros (JUnit) pra **Services** sem subir o Quarkus
- Escrever testes de integração com `@QuarkusTest` + **RestAssured**
- Trocar um bean real por um **mock** com `@InjectMock`
- Mudar configuração só pro teste com `@TestProfile`
- Saber a diferença entre `@QuarkusTest` e `@QuarkusIntegrationTest`
- Usar o **Continuous Testing** (modo `r` no dev) pra rodar testes enquanto digita

## 🔺 Pirâmide de testes (versão Quarkus)

```
        ▲   @QuarkusIntegrationTest  ← roda contra o jar/native já buildado (lento)
        │   @QuarkusTest             ← sobe app real em memória + RestAssured (médio)
        │   JUnit puro               ← só a classe, sem container (rápido, maioria)
        ▼
```

Regra prática: **a maioria dos testes deveria ser JUnit puro** (testa Service, regra de negócio). `@QuarkusTest` só quando você precisa do framework rodando — pra validar Resource + JSON + injeção CDI funcionando juntos.

## 🧪 Anatomia de `@QuarkusTest`

```java
@QuarkusTest
class ProdutoResourceTest {

    @Test
    void listarDeveRetornar200() {
        given()
          .when().get("/produtos")
          .then()
             .statusCode(200);
    }
}
```

O que a anotação faz:
- **Sobe o Quarkus uma vez** antes da classe (não a cada teste — é rápido)
- Disponibiliza **injeção CDI** dentro do teste (`@Inject MeuService svc`)
- Configura o **RestAssured** apontando pra `http://localhost:8081` (porta de teste, evita conflito com `quarkus dev` rodando)
- Roda em profile `test` — `application.properties` aceita prefixo `%test.` pra valores só de teste

## 🎯 RestAssured: `given().when().then()`

DSL de teste HTTP que lê quase como inglês:

```java
given()
    .contentType(ContentType.JSON)
    .body(new Produto("Caneta", 5.0))
.when()
    .post("/produtos")
.then()
    .statusCode(201)
    .body("id", notNullValue())
    .body("nome", is("Caneta"));
```

- `given()` — o que você manda (body, headers, query params)
- `when()` — o verbo HTTP e o path
- `then()` — o que você espera (status, body, header)

Asserções de body usam **JsonPath**: `body("itens.size()", is(3))`, `body("itens[0].nome", is("X"))`.

## 🎭 `@InjectMock` — trocar bean por mock

Útil quando o Resource depende de algo caro/externo (banco, API). Você sobrescreve só aquele bean:

```java
@QuarkusTest
class ProdutoResourceMockTest {

    @InjectMock
    ProdutoService service;     // bean CDI real é substituído

    @Test
    void devolve404QuandoServiceNaoAcha() {
        Mockito.when(service.buscar(999L))
               .thenReturn(Optional.empty());

        given()
          .when().get("/produtos/999")
          .then()
             .statusCode(404);
    }
}
```

Por baixo dos panos é **Mockito** — `Mockito.when(...).thenReturn(...)`, `verify(svc).deletar(1L)`, etc. Pra usar, precisa da extensão `quarkus-junit5-mockito`.

## 🎚️ `@TestProfile` — outra config só pra esse teste

Quando você quer rodar um conjunto de testes com properties diferentes (banco vazio, feature flag ligada, URL fake):

```java
public class BancoVazioProfile implements QuarkusTestProfile {
    @Override
    public Map<String, String> getConfigOverrides() {
        return Map.of("app.seed", "false");
    }
}

@QuarkusTest
@TestProfile(BancoVazioProfile.class)
class ProdutoVazioTest { ... }
```

Atenção: **trocar de profile reinicia o Quarkus** entre as classes — agrupe testes do mesmo profile pra não ficar lento.

## ⚡ Continuous Testing (modo `r`)

Com `quarkus dev` rodando, aperte **`r`** no terminal. Aparece uma barra com `Tests paused`. Aperte `r` de novo: ele entra em modo contínuo e **roda só os testes afetados pela classe que você acabou de mudar**. Mudou `ProdutoService`? Ele roda `ProdutoServiceTest` e qualquer teste que toca esse bean.

Atalhos úteis no modo:
- `r` — rodar todos
- `f` — rodar só os que falharam
- `o` — abrir/fechar verbose
- `b` — toggle "rodar testes em background" (default ligado)

## 📦 `@QuarkusIntegrationTest` — não é unit

```java
@QuarkusIntegrationTest
class ProdutoResourceIT { ... }
```

Diferença crítica: ele **não roda em JVM compartilhada com o teste**. Ele empacota a app (jar, container ou nativo) e roda **contra esse artefato** como caixa-preta. Por isso `@Inject` **não funciona** aqui — o teste tá fora do processo. Use só pra fumaça final, pós-build.

Convenção: nome termina em `IT` (de _Integration Test_) — o Maven roda no `verify`, não no `test`.

## 🧰 Dev Services em testes

O mesmo Dev Services do Módulo 06 funciona dentro de `@QuarkusTest`: se sua app usa Postgres e você não configurou URL no `%test.`, o Quarkus sobe um **Postgres em container** só pra esse teste e mata no final. Zero setup. Precisa de Docker rodando.

Pra cenários onde você quer **controlar manualmente** o container (Kafka, Redis específico), use `@QuarkusTestResource(MeuRecurso.class)` apontando pra uma classe que implementa `QuarkusTestResourceLifecycleManager`. Tema avançado, mas saiba que existe.

## 💡 Detalhes que valem ouro
- **`@TestProfile` é o jeito limpo de mudar config** — não saia editando `application.properties` pra teste, use o prefixo `%test.` ou um profile.
- **Porta de teste é 8081** por padrão. Pra mudar: `quarkus.http.test-port=8888`.
- **`@InjectMock` ≠ `@Mock`**: `@InjectMock` substitui o bean no contexto CDI da app inteira (até no Resource). `@Mock` do Mockito puro fica só dentro do teste.
- **RestAssured tem `expect()` e `body()` deprecated** em código antigo — use `then().body(...)`.
- **`@QuarkusTest` é lento na primeira classe** (sobe o app). Depois é rápido. Por isso evita fragmentar em N classes pequenas com profiles diferentes.
- **`@TestHTTPEndpoint(ProdutoResource.class)`** deixa você omitir o path base: `when().get("/")` em vez de `when().get("/produtos/")`.
- **Imports estáticos são quase obrigatórios** com RestAssured: `import static io.restassured.RestAssured.given;` e `import static org.hamcrest.Matchers.*;`.

## 🚦 Próximos passos
1. Abra `pratica/` e copie os 4 arquivos `.java` + `BancoVazioProfile` pro `src/main/java/com/exemplo/` (resource e service) e `src/test/java/com/exemplo/` (testes e profile)
2. Confira no `pom.xml` se tem `quarkus-junit5`, `rest-assured` e `quarkus-junit5-mockito`
3. Rode `./mvnw test` (ou veja o `comandos.sh`)
4. Rode `quarkus dev`, aperte `r` duas vezes, mude o `ProdutoService` e veja os testes rodando sozinhos
5. Encare o desafio: testar a API de Pedido com 5 cenários

## ✅ Auto-verificação
- [ ] Sei quando usar JUnit puro vs `@QuarkusTest`
- [ ] Consigo escrever um teste de POST com RestAssured validando status e body
- [ ] Sei trocar um bean por `@InjectMock` e usar `Mockito.when().thenReturn()`
- [ ] Sei pra que serve `@TestProfile` e como criar um
- [ ] Entendo que `@QuarkusIntegrationTest` testa o jar final, não a classe
- [ ] Já usei o modo `r` do Continuous Testing pelo menos uma vez

Próximo módulo: **Hibernate ORM com Panache** — persistência de verdade (e como testar com Dev Services).
