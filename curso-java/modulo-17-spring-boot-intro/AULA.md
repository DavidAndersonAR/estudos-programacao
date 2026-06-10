# Módulo 17 — Spring Boot Intro

> Corresponde ao módulo **Cadastro de Ninjas** do Java10x.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é **Spring Framework** e por que ele virou padrão de mercado
- Entender o que é **Spring Boot** (Spring com configuração automática)
- Explicar **IoC** e **DI** sem decorar palavras bonitas
- Reconhecer `@SpringBootApplication`, `@Component`, `@Service`, `@Repository`
- Criar um projeto novo via [start.spring.io](https://start.spring.io)
- Saber o que vai dentro do `application.properties`

## 🌱 O que é o Spring Framework?
Spring é um **framework** (não uma biblioteca) que cuida da parte chata de construir aplicações Java de verdade: como instanciar objetos, conectar com banco, expor endpoints HTTP, segurança, transações, etc.

Antes do Spring, fazer uma aplicação corporativa em Java era doloroso (EJB, XML por toda parte). O Spring chegou propondo:
- **Código simples** (POJOs — Plain Old Java Objects)
- **Inversão de Controle** (você não fica dando `new` em tudo)
- **Modularidade** (você só pega o que precisa: Spring Web, Spring Data, Spring Security…)

Hoje é o padrão de fato no backend Java. Quem usa: Nubank, Itaú, iFood, Mercado Livre, Netflix, basicamente o mercado todo.

## 🚀 E o Spring Boot?
Spring Boot é **Spring com configuração automática**. Antes era preciso configurar 50 XMLs pra subir um servidor web. Com Spring Boot:

- Você roda `main()` e ele **sobe o Tomcat embutido** pra você
- **Convenção em vez de configuração**: ele adivinha o que você quer
- Um arquivo `application.properties` resolve a maior parte das configs
- Dependências vêm em "starters" (`spring-boot-starter-web` traz tudo que precisa pra REST)

Resumindo: **Spring Boot = Spring + autoconfig + servidor embutido + starters**.

## 🔄 Inversão de Controle (IoC) — em português claro

**Modo tradicional** (você no controle):
```java
public class PedidoService {
    private EmailService email = new EmailService();   // VOCÊ cria
    private EstoqueService estoque = new EstoqueService(); // VOCÊ cria
}
```
Você dá `new` em tudo. Você "controla" a criação dos objetos.

**Com IoC** (Spring no controle):
```java
@Service
public class PedidoService {
    private final EmailService email;
    private final EstoqueService estoque;

    public PedidoService(EmailService email, EstoqueService estoque) {
        this.email = email;
        this.estoque = estoque;
    }
}
```
**Você não dá `new`.** O Spring percebe que `PedidoService` precisa de `EmailService` e `EstoqueService`, vai lá, cria essas coisas e **entrega prontas pra você** pelo construtor.

A "inversão" é essa: quem controla a criação **deixou de ser você** e passou a ser o framework. Daí o nome **Inversão de Controle**.

## 💉 Injeção de Dependência (DI)
DI é **o jeito que o Spring usa pra fazer IoC acontecer**. Ele "injeta" (entrega) as dependências que sua classe pede.

Três formas de injetar (use a primeira sempre):

### 1. Construtor (jeito recomendado)
```java
@Service
public class PedidoService {
    private final EmailService email;

    public PedidoService(EmailService email) {  // Spring passa o EmailService aqui
        this.email = email;
    }
}
```

### 2. Campo (`@Autowired` em cima do atributo) — evite
```java
@Service
public class PedidoService {
    @Autowired
    private EmailService email;  // funciona, mas é ruim pra testar
}
```

### 3. Setter — quase nunca usado
```java
@Autowired
public void setEmail(EmailService email) { this.email = email; }
```

**Por que construtor é o melhor?**
- Dependências ficam `final` (imutáveis)
- Fica óbvio o que a classe precisa pra existir
- Fácil de testar (passa os mocks manualmente)
- Se faltar alguma, **não compila** — bug pego cedo

## 🏷️ Anotações de Componente
Pra o Spring saber **quais classes ele precisa gerenciar**, você marca elas com anotações. Tudo que tem essas anotações vira um **bean** (objeto controlado pelo Spring).

| Anotação | Pra que serve |
|---|---|
| `@Component` | Componente genérico. Qualquer classe que o Spring gerencie. |
| `@Service` | **Regra de negócio**. Tecnicamente é um `@Component`, mas o nome deixa claro o papel. |
| `@Repository` | **Camada de acesso a dados** (banco). Também ganha tratamento de exceções de banco. |
| `@Controller` / `@RestController` | **Camada web**. Recebe requisições HTTP. |

São todas a mesma coisa por baixo dos panos (todas são `@Component`). A diferença é **semântica** — fica claro pra quem lê o código qual é o papel de cada classe.

## 🚪 `@SpringBootApplication` — o ponto de partida
```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

Essa única anotação é, na verdade, **três em uma**:
- `@Configuration` — diz que essa classe define beans
- `@EnableAutoConfiguration` — liga a autoconfig do Boot (Tomcat, JSON, etc)
- `@ComponentScan` — varre o pacote atual e os subpacotes procurando `@Component`/`@Service`/etc

`SpringApplication.run(...)` é o que **liga o motor**: cria o contêiner IoC, escaneia classes, instancia beans, sobe o servidor web (se for app web) e chama `CommandLineRunner` se existir.

## 🏭 BeanFactory — quem instancia os objetos
Por baixo do `@SpringBootApplication` mora o **ApplicationContext** (uma versão mais poderosa do `BeanFactory`). Ele é o **contêiner IoC**: a "fábrica de beans" do Spring.

O ciclo é mais ou menos assim:
1. Você roda `SpringApplication.run(...)`
2. O Spring **escaneia** suas classes procurando anotações (`@Component` etc)
3. Pra cada classe encontrada, ele descobre as dependências (olhando o construtor)
4. Cria os beans **na ordem certa** (primeiro os que não dependem de nada, depois os que dependem dos primeiros)
5. **Injeta** as dependências
6. Guarda tudo no contexto, pronto pra usar

Por padrão beans são **singletons** — uma instância só pra app inteira. Você pode mudar com `@Scope("prototype")`, mas raramente precisa.

## 🌐 Criando um projeto no [start.spring.io](https://start.spring.io)
O **Spring Initializr** é o jeito oficial de começar um projeto. Você não precisa criar `pom.xml` na unha.

Passo a passo:
1. Acesse https://start.spring.io
2. **Project**: Maven
3. **Language**: Java
4. **Spring Boot**: a versão estável mais recente (sem `SNAPSHOT`)
5. **Project Metadata**:
   - Group: `com.seunome` (domínio invertido)
   - Artifact: `nome-do-projeto`
   - Packaging: Jar
   - Java: **21**
6. **Dependencies**: clique "ADD DEPENDENCIES" e escolha as que precisa. Pra começar:
   - **Spring Web** (REST, MVC, Tomcat embutido)
   - **Spring Boot DevTools** (reload automático em dev)
   - **Lombok** (opcional — gera getters/setters)
7. Clique em **GENERATE** → baixa um `.zip`
8. Descompacte e abra no IntelliJ (`File > Open` → escolha a pasta)

Pra rodar:
```bash
./mvnw spring-boot:run     # Linux/Mac
mvnw.cmd spring-boot:run   # Windows
```

## ⚙️ `application.properties`
Fica em `src/main/resources/application.properties`. É onde vão as configurações da aplicação.

Exemplos comuns:
```properties
# nome da aplicação
spring.application.name=cadastro-ninjas

# porta do servidor (padrão é 8080)
server.port=8080

# nível de log (TRACE, DEBUG, INFO, WARN, ERROR)
logging.level.root=INFO
logging.level.com.seunome=DEBUG

# banco de dados (vamos usar no módulo 18)
# spring.datasource.url=jdbc:h2:mem:testdb
# spring.datasource.username=sa
# spring.datasource.password=

# JPA (também módulo 18)
# spring.jpa.hibernate.ddl-auto=update
# spring.jpa.show-sql=true
```

> Existe também `application.yml` (mesma coisa, sintaxe YAML). Fica a gosto — `.properties` é o default.

## 🧱 Estrutura típica de um projeto Spring Boot
```
cadastro-ninjas/
├── pom.xml
├── mvnw, mvnw.cmd          # wrapper do Maven (não precisa ter Maven instalado)
└── src/
    ├── main/
    │   ├── java/com/seunome/cadastroninjas/
    │   │   ├── CadastroNinjasApplication.java   ← @SpringBootApplication
    │   │   ├── controller/   ← @RestController
    │   │   ├── service/      ← @Service
    │   │   ├── repository/   ← @Repository
    │   │   └── model/        ← entidades (POJOs)
    │   └── resources/
    │       ├── application.properties
    │       └── static/       ← arquivos estáticos (se for o caso)
    └── test/
        └── java/...          ← testes
```

A separação **controller / service / repository / model** é convenção fortíssima. Decora — é o que você vai ver em 99% dos projetos Spring por aí.

## 💡 Pegadinhas
- **Esqueceu a anotação?** A classe não vira bean, ninguém injeta, dá `NullPointerException`.
- **Classe fora do pacote do `@SpringBootApplication`?** O `@ComponentScan` não acha. Mantenha tudo no mesmo pacote ou em subpacotes.
- **Dois beans do mesmo tipo?** Spring reclama (`NoUniqueBeanDefinitionException`). Use `@Qualifier` ou `@Primary` pra desempatar.
- **Não dá `new` no que é gerenciado pelo Spring** — isso quebra a injeção. Deixa o Spring criar.
- **`pom.xml` é XML do Maven**, o gerenciador de dependências. Vamos ver melhor mais pra frente.

## 🚦 Próximos passos
1. Leia o `pratica/Main.java` — tem o código completo de uma app Spring Boot minimal **no comentário**, porque este módulo precisa de projeto Maven de verdade.
2. Faça o **desafio**: gere seu primeiro projeto no [start.spring.io](https://start.spring.io) seguindo as instruções.
3. No próximo módulo (18) a gente faz a app **Cadastro de Ninjas** completa, com REST e banco.

## ✅ Auto-verificação
- [ ] Sei explicar IoC com minhas palavras (sem decorar)
- [ ] Entendo o que `@SpringBootApplication` faz por baixo dos panos
- [ ] Sei a diferença entre `@Component`, `@Service` e `@Repository`
- [ ] Consigo gerar um projeto no start.spring.io sem ajuda
- [ ] Sei onde fica e pra que serve o `application.properties`

Próximo módulo: **Spring Boot REST + JPA** — a app *Cadastro de Ninjas* de verdade.
