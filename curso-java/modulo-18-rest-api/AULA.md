# Módulo 18 — REST API com Spring

> Corresponde ao módulo **Cadastro de Ninjas** do Java10x — só que agora, em vez de só rodar Spring na unha, a gente vai entender de verdade o que é REST e como o Spring transforma anotações em endpoints HTTP.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é uma **API REST** (recursos, verbos, status)
- Criar um `@RestController` com endpoints GET, POST, PUT, DELETE
- Receber dados via **path variable**, **query param** e **request body**
- Devolver respostas controladas com `ResponseEntity` (status + body + headers)
- Entender o papel do **DTO** (Data Transfer Object) na separação API ⇄ model interno
- Saber por que tudo "vira JSON" sozinho (content negotiation via Jackson)

## 🌐 O que é REST (em uma página)

REST (Representational State Transfer) é um **estilo arquitetural** pra APIs web. Não é protocolo, não é biblioteca — é um conjunto de convenções que usa o próprio HTTP do jeito que o HTTP foi pensado.

Ideias centrais:

1. **Tudo é recurso** (substantivo, não verbo).
   - Bom: `/tarefas`, `/tarefas/42`
   - Ruim: `/listarTarefas`, `/criarTarefa`
2. **O verbo HTTP diz o que fazer** com o recurso.
3. **Stateless**: cada request carrega tudo que precisa (sem sessão guardada no server).
4. **Representação JSON** (default moderno) — antes era XML.

### Verbos HTTP × CRUD

| Verbo | Significado | CRUD | Idempotente? |
|---|---|---|---|
| `GET` | ler recurso(s) | Read | sim |
| `POST` | criar recurso novo | Create | não |
| `PUT` | substituir recurso inteiro | Update | sim |
| `PATCH` | atualizar parcial | Update | depende |
| `DELETE` | remover | Delete | sim |

> **Idempotente** = chamar 1× ou 10× dá o mesmo estado final. `POST` cria um novo a cada chamada, por isso não é idempotente.

### Status codes que você precisa decorar

| Faixa | Significado | Exemplos |
|---|---|---|
| **2xx** | sucesso | `200 OK`, `201 Created`, `204 No Content` |
| **3xx** | redirecionamento | `301 Moved`, `304 Not Modified` |
| **4xx** | erro do cliente | `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict` |
| **5xx** | erro do servidor | `500 Internal Server Error`, `503 Service Unavailable` |

Regrinhas práticas:
- `POST` que cria com sucesso → `201 Created` (+ header `Location` pro recurso novo)
- `DELETE` com sucesso e sem body → `204 No Content`
- Recurso não existe → `404 Not Found`
- Dados inválidos do cliente → `400 Bad Request`

## 🌱 Spring Web — as anotações

O Spring vê as anotações e gera o "encanamento" HTTP pra você. Você só descreve o que quer.

### `@RestController`
Marca a classe como controlador REST. Equivale a `@Controller + @ResponseBody` — ou seja, **tudo que o método retornar vira corpo da resposta** (em JSON, por padrão).

```java
/*
@RestController
public class OlaController {
    @GetMapping("/ola")
    public String ola() {
        return "oi"; // vira: corpo HTTP "oi"
    }
}
*/
```

### `@RequestMapping` — prefixo da classe
Define a "base" das rotas daquele controller.

```java
/*
@RestController
@RequestMapping("/api/tarefas")
public class TarefaController { ... }
*/
```

### `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`
Atalho para `@RequestMapping(method = ...)`. Use sempre os atalhos — código fica mais limpo.

```java
/*
@GetMapping            // GET  /api/tarefas
@GetMapping("/{id}")   // GET  /api/tarefas/42
@PostMapping           // POST /api/tarefas
@PutMapping("/{id}")   // PUT  /api/tarefas/42
@DeleteMapping("/{id}")// DELETE /api/tarefas/42
*/
```

### `@PathVariable` — pedaço da URL
Captura um trecho variável do path.

```java
/*
@GetMapping("/tarefas/{id}")
public Tarefa buscar(@PathVariable Long id) { ... }

// GET /tarefas/42  →  id = 42L
*/
```

### `@RequestParam` — query string
Captura `?chave=valor` da URL.

```java
/*
@GetMapping("/tarefas")
public List<Tarefa> listar(@RequestParam(required = false) String filtro) { ... }

// GET /tarefas?filtro=urgente  →  filtro = "urgente"
*/
```

### `@RequestBody` — corpo da requisição
Pega o JSON do body e converte pra objeto Java (Jackson faz a mágica).

```java
/*
@PostMapping("/tarefas")
public Tarefa criar(@RequestBody TarefaDTO dto) { ... }

// POST /tarefas
// body: {"titulo":"estudar","feita":false}
*/
```

## 📦 DTO — Data Transfer Object

DTO é um **objeto que existe só pra trafegar dados pela API**. Por que não usar a classe do modelo direto?

- A API e o banco evoluem em ritmos diferentes. Se você expõe o model interno, qualquer renomeação **quebra clientes**.
- Você pode querer **esconder campos** (senha, hash interno, flags de admin).
- Você pode querer **agregar/transformar** (somar campos, formatar datas).

Padrão moderno em Java: usar `record` (imutável, conciso).

```java
/*
// Model interno (pode ter campos sensíveis)
public class Tarefa {
    private Long id;
    private String titulo;
    private boolean feita;
    private String criadaPor; // não quero expor
}

// DTO de entrada (o que o cliente manda)
public record CriarTarefaDTO(String titulo) {}

// DTO de saída (o que devolvemos)
public record TarefaDTO(Long id, String titulo, boolean feita) {}
*/
```

Regra de ouro: **nunca exponha sua entidade JPA direto na API**. Mesmo que hoje pareça igual, amanhã divergem.

## 📨 `ResponseEntity` — controle fino da resposta

Quando você retorna um objeto direto, o Spring usa `200 OK` por default. Mas e se quiser `201 Created`, ou `404 Not Found`, ou colocar um header? Use `ResponseEntity<T>`.

```java
/*
@PostMapping
public ResponseEntity<TarefaDTO> criar(@RequestBody CriarTarefaDTO dto) {
    TarefaDTO criada = service.criar(dto);
    return ResponseEntity
        .status(HttpStatus.CREATED) // 201
        .header("Location", "/api/tarefas/" + criada.id())
        .body(criada);
}

@GetMapping("/{id}")
public ResponseEntity<TarefaDTO> buscar(@PathVariable Long id) {
    return service.buscar(id)
        .map(ResponseEntity::ok)            // 200 + body
        .orElse(ResponseEntity.notFound().build()); // 404
}

@DeleteMapping("/{id}")
public ResponseEntity<Void> remover(@PathVariable Long id) {
    service.remover(id);
    return ResponseEntity.noContent().build(); // 204
}
*/
```

## 🔄 Content negotiation (a mágica do JSON)

Você nunca escreve `objeto.toJson()` nem `parseJson(...)`. O Spring olha:
- O header `Accept` do request (cliente quer JSON? XML?)
- O header `Content-Type` (o body que chegou é JSON?)

E usa o **Jackson** (biblioteca incluída no `spring-boot-starter-web`) pra converter automaticamente:

- Java → JSON na saída (serialização)
- JSON → Java na entrada (desserialização)

Records funcionam perfeitamente — o Jackson usa os componentes do record como campos.

```java
/*
// Você escreve:
@GetMapping("/{id}")
public TarefaDTO buscar(@PathVariable Long id) {
    return new TarefaDTO(id, "estudar", false);
}

// O cliente recebe:
// HTTP/1.1 200 OK
// Content-Type: application/json
//
// {"id":1,"titulo":"estudar","feita":false}
*/
```

## 🧪 Como testar uma API REST

Antes de ter um front-end, use:

- **curl** (terminal — universal)
- **Postman** ou **Insomnia** (interface gráfica)
- **HTTPie** (mais bonito que curl)
- Aba **Network** do navegador (pra GETs simples)

Exemplos com `curl`:

```bash
# Listar
curl http://localhost:8080/api/tarefas

# Buscar por id
curl http://localhost:8080/api/tarefas/1

# Criar
curl -X POST http://localhost:8080/api/tarefas \
  -H "Content-Type: application/json" \
  -d '{"titulo":"estudar Spring","feita":false}'

# Atualizar
curl -X PUT http://localhost:8080/api/tarefas/1 \
  -H "Content-Type: application/json" \
  -d '{"titulo":"estudar Spring (revisão)","feita":true}'

# Remover
curl -X DELETE http://localhost:8080/api/tarefas/1
```

## 💡 Pegadinhas que valem ouro
- **`@RestController` ≠ `@Controller`**: este último volta view (Thymeleaf etc); aquele volta body.
- **Esquecer `@RequestBody`**: o Spring tenta achar query params com os nomes do objeto e não acha → 400 ou null em tudo.
- **`@PathVariable` com nomes diferentes**: se o path é `{idTarefa}` e o parâmetro é `Long id`, use `@PathVariable("idTarefa") Long id`.
- **Retornar `null` em `@GetMapping`**: vira `200 OK` com body vazio — geralmente você queria `404`. Use `ResponseEntity`.
- **Concorrência em "banco em memória"**: `ArrayList` + `int` não são thread-safe. Use `ConcurrentHashMap` + `AtomicLong` se for sério.
- **Não exponha entidade JPA direto**: hoje parece igual, amanhã não é.

## 🚦 Próximos passos
1. Veja **`pratica/Main.java`** — controller "Olá" com path var, query param e body.
2. Encare o **desafio**: CRUD de Tarefas em memória, completo, com curl pra testar.
3. Quando estiver confortável, vá pro próximo módulo (JPA + banco real).

## ✅ Auto-verificação
- [ ] Sei dizer qual verbo HTTP usar pra cada operação CRUD
- [ ] Conheço pelo menos 5 status codes e quando usar cada um
- [ ] Sei diferença entre `@PathVariable`, `@RequestParam` e `@RequestBody`
- [ ] Sei por que existe DTO (e por que não expor entidade direto)
- [ ] Sei usar `ResponseEntity` pra controlar status e headers
- [ ] Sei testar a API com `curl`

Próximo módulo: **JPA e banco de dados real** — chega de `ArrayList` em memória.
