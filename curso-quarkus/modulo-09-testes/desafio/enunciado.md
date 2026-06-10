# Desafio Módulo 09 — Testes pra API de Pedido

## 🎯 Missão
Escrever uma classe `PedidoResourceTest` com `@QuarkusTest` + RestAssured cobrindo **5 cenários** da API de Pedido. Pra te ajudar, já te entreguei prontos: o `Pedido.java`, o `PedidoService.java` e o `PedidoResource.java` (veja arquivos `.solucao`).

## 📋 Os 5 cenários obrigatórios

1. **Criar pedido válido** — `POST /pedidos` com body JSON correto deve retornar **201** e o body com `id` não nulo e `status` igual a `"NOVO"`.
2. **Listar pedidos** — `GET /pedidos` deve retornar **200** e um array com tamanho ≥ 1 depois do cenário anterior. Dica: pra ficar determinístico, use `@TestMethodOrder` ou crie um pedido dentro do próprio teste.
3. **Buscar id inexistente → 404** — `GET /pedidos/9999` deve retornar **404**.
4. **Deletar com sucesso → 204** — crie um pedido, capture o `id` retornado (use `.extract().path("id")`) e mande `DELETE /pedidos/{id}`. Espere **204**. Depois faça `GET /pedidos/{id}` e confirme **404**.
5. **Atualizar inválido → 400** — `PUT /pedidos/{id}` com body que tem `valor` negativo deve retornar **400**.

## 🛠️ Regras
- Use `import static io.restassured.RestAssured.given;` e `import static org.hamcrest.Matchers.*;`
- Cada cenário em um `@Test` separado, com nome em português que descreva o comportamento.
- Pode usar `@TestMethodOrder(MethodOrderer.OrderAnnotation.class)` + `@Order(n)` se precisar de ordem.
- Não precisa mexer no `PedidoService` — só escrever os testes.

## 🏆 Bônus (opcional)
- Adicione um 6º teste usando `@InjectMock` no `PedidoService` pra forçar que `listar()` devolva uma lista hardcoded e valide o JSON sem depender do estado real.
- Crie um `PedidoVazioProfile` (similar ao `BancoVazioProfile`) e use `@TestProfile` numa segunda classe pra rodar com `app.seed=false`.

## ✅ Critérios de aceite
- [ ] `./mvnw test -Dtest=PedidoResourceTest` passa sem erros
- [ ] Os 5 testes existem com asserts de status e (quando aplicável) de body
- [ ] Nada de `System.out.println` ou `Thread.sleep` nos testes
- [ ] Você não editou a classe `PedidoResource` pra fazer um teste passar (testar é validar, não acomodar)

Arquivo modelo de solução: `PedidoResourceTest.java.solucao`. Tenta sozinho antes de espiar!
