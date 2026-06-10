# Módulo 03 — Injeção de Dependência (CDI)

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é **CDI** (Contexts and Dependency Injection — sistema de injeção do Java EE/Jakarta usado pelo Quarkus)
- Escolher o **escopo** certo: `@ApplicationScoped`, `@RequestScoped`, `@Singleton`, `@Dependent`
- Injetar dependências via **construtor** (preferido) ou **field**
- Quebrar uma API em camadas: **Resource → Service → Repository**
- Usar `@Produces`, **qualifiers** (`@Named`/customizado) e callbacks de ciclo de vida (`@PostConstruct` / `@PreDestroy`)

---

## 🧠 Por que injeção de dependência?

Se uma classe **cria** suas dependências (`new ProdutoRepository()` dentro do Service), elas viram concreto-acopladas: trocar a implementação ou mockar no teste é difícil. **DI inverte isso**: alguém de fora (o container CDI) fabrica e entrega a dependência pronta. Seu código só **declara** que precisa.

Em Quarkus o container é o **ArC**, uma implementação compilada em tempo de build (sem reflection cara em runtime — por isso o startup é rápido). Você usa as anotações Jakarta normais; o ArC resolve tudo na compilação.

---

## 🏷️ Escopos comparados

| Escopo | Quantas instâncias | Quando criada | Uso típico |
|---|---|---|---|
| `@ApplicationScoped` | **1** por app | **Lazy** (na 1ª chamada via proxy) | Services, Repositories, qualquer bean stateless reutilizado |
| `@Singleton` | **1** por app | **Eager** (no startup) — sem proxy | Beans muito chamados onde overhead de proxy importa, ou que precisam existir já no boot |
| `@RequestScoped` | **1 por requisição HTTP** | Início da request, destruída no fim | Estado de uma request (usuário logado, contexto da transação) |
| `@Dependent` | **1 por ponto de injeção** | Junto com quem injeta | Helpers descartáveis, beans sem estado próprio |
| `@SessionScoped` / `@ConversationScoped` | Web tradicional | (raro em REST) | Pouco usado em APIs REST stateless |

### `@ApplicationScoped` vs `@Singleton` — a confusão clássica
Ambos = **1 instância** por app. Diferenças:

- **`@ApplicationScoped`** → o que você injeta é um **proxy** (objeto intermediário). A instância real só é criada na **primeira chamada de método** (lazy). Vantagem: permite ciclos de injeção, hot-swap em dev, dá pra trocar a implementação em testes via `@Alternative`.
- **`@Singleton`** → injeção **direta**, sem proxy. Instância criada **no startup** (eager). Mais rápido por chamada (sem hop do proxy), mas perde flexibilidade.

**Regra prática**: comece sempre com `@ApplicationScoped`. Use `@Singleton` só quando medir overhead em hot paths ou precisar do bean já pronto antes da primeira request.

---

## 💉 `@Inject` — construtor vs field

### Construtor (preferido)
```java
@ApplicationScoped
public class ProdutoService {

    private final ProdutoRepository repo;

    @Inject  // opcional no construtor único; CDI já entende
    public ProdutoService(ProdutoRepository repo) {
        this.repo = repo;
    }
}
```

Por que preferir construtor:
- **Imutabilidade**: campo `final` garantido
- **Testabilidade**: `new ProdutoService(mockRepo)` no JUnit sem mexer no container
- **Dependências explícitas**: o construtor lista tudo que o bean precisa
- **Falha cedo**: se faltar um bean, estoura na construção, não na 1ª chamada

### Field (mais curto, mas pior)
```java
@ApplicationScoped
public class ProdutoService {
    @Inject ProdutoRepository repo;   // package-private, sem final
}
```

Funciona, mas só dá pra testar via container. Quarkus aceita os dois — escolha construtor no código novo.

> 💡 **Setter injection** também existe (`@Inject` num setter) mas é raríssimo em apps modernas. Esquece.

---

## 🏭 `@Produces` — quando o bean não é "seu"

Às vezes você precisa injetar algo que **não pode anotar** (classe de biblioteca terceira) ou que tem **construção customizada**. Aí declara um método produtor:

```java
@ApplicationScoped
public class Producers {

    @Produces
    @ApplicationScoped
    public ObjectMapper objectMapper() {
        return new ObjectMapper().findAndRegisterModules();
    }
}
```

Agora qualquer `@Inject ObjectMapper mapper` recebe esse objeto. Útil pra clients HTTP, conexões customizadas, etc.

---

## 🏷️ Qualifiers — múltiplas implementações da mesma interface

Se há **duas implementações** de `Notificador`, o CDI não sabe qual injetar. Solução: qualificar.

### Jeito simples: `@Named`
```java
@ApplicationScoped @Named("email")
public class NotificadorEmail implements Notificador { ... }

@ApplicationScoped @Named("sms")
public class NotificadorSms implements Notificador { ... }

// No consumidor:
@Inject @Named("email") Notificador notificador;
```

### Jeito robusto: qualifier customizado
```java
@Qualifier @Retention(RUNTIME) @Target({FIELD, PARAMETER, METHOD})
public @interface Email {}

@ApplicationScoped @Email
public class NotificadorEmail implements Notificador { ... }

@Inject @Email Notificador notificador;
```

Customizado é checado em tempo de build — se errar o nome o ArC reclama. `@Named` usa string e só estoura em runtime.

---

## 🔄 Ciclo de vida: `@PostConstruct` e `@PreDestroy`

```java
@ApplicationScoped
public class CacheLocal {

    private Map<String,String> dados;

    @PostConstruct
    void init() {
        // Roda logo após a injeção, antes do bean ser usado
        dados = new ConcurrentHashMap<>();
    }

    @PreDestroy
    void shutdown() {
        // Roda quando o app vai parar (ou request acaba, se @RequestScoped)
        dados.clear();
    }
}
```

Importação: `jakarta.annotation.PostConstruct` / `PreDestroy`. Útil pra warm-up de cache, abrir conexões persistentes, fechar arquivos, etc.

> 💡 Em `@ApplicationScoped` o `@PostConstruct` só roda na **1ª chamada de método** (lazy). Se precisar rodar no boot, use `@Singleton` + `@Startup` (extensão `quarkus-arc`) ou observe o evento `StartupEvent`.

---

## 🧱 O padrão Resource → Service → Repository

```
HTTP  →  ProdutoResource  →  ProdutoService  →  ProdutoRepository  →  (Map/BD)
         (camada web)        (regras)            (acesso a dados)
```

Cada camada com **uma responsabilidade**:

- **Resource** (`@Path`) — só traduz HTTP ↔ Java. Sem regra de negócio.
- **Service** (`@ApplicationScoped`) — orquestra regras, validações, transações.
- **Repository** (`@ApplicationScoped`) — só lê/grava dados. Troca de BD não vaza pra cima.

Vantagem real: dá pra **testar o service** sem subir HTTP, e **trocar o repository** (Map → JPA no Módulo 05) sem mexer no resto.

Veja `pratica/` pra implementação completa.

---

## 💡 Detalhes que valem ouro
- Em **classes com construtor único**, o `@Inject` é opcional — o Quarkus deduz.
- Use **interfaces** quando vai ter mais de uma implementação ou quer trocar em testes. Caso contrário, classe concreta serve.
- `@ApplicationScoped` exige construtor **sem args** (ou com args injetáveis). Se a classe é `final` ou tem só construtor com parâmetros não-injetáveis, vira erro de build.
- Dev UI em `/q/dev` tem aba **Arc** mostrando todos os beans, escopos e dependências. Excelente pra debugar "bean não encontrado".
- Erro comum: `UnsatisfiedResolutionException` — esqueceu de anotar a classe com algum escopo, ou tem 2 implementações sem qualifier.
- `Instance<T>` permite injetar **todos** os beans de um tipo (`Instance<Notificador>`) e iterar — útil pra plugins.
- `@Transactional` (Jakarta) marca método transacional. Combina lindo com Service. Veremos no Módulo 05.

---

## 🚦 Próximos passos
1. Abra o módulo 02 (`meu-app` ou similar) ou crie um novo:
   `quarkus create app com.exemplo:produtos-api --extension=rest-jackson --java=21`
2. Copie os 3 arquivos de `pratica/` pra `src/main/java/com/exemplo/`
3. Rode `quarkus dev`
4. Execute os `curl` de `pratica/comandos.sh`
5. Abra `/q/dev` → aba **Arc** e localize seus beans
6. Encare o desafio: refatorar o `PedidoResource` gigante em camadas

## ✅ Auto-verificação
- [ ] Sei diferenciar `@ApplicationScoped` de `@Singleton`
- [ ] Prefiro injeção por construtor e sei explicar por quê
- [ ] Consigo quebrar uma API em Resource / Service / Repository
- [ ] Sei o que faz `@Produces` e quando uso qualifier
- [ ] Sei onde rodam `@PostConstruct` / `@PreDestroy`

Próximo módulo: **Configuração** — `application.properties`, `@ConfigProperty`, profiles dev/test/prod.
