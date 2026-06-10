# Módulo 19 — JPA + Banco H2

> **Cadastro de Ninjas — Spring + H2 + Migrations**
>
> Corresponde às aulas do Java10x sobre persistência: JPA, Hibernate, Spring Data JPA, H2 e migrations com Flyway.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é **ORM** (Object-Relational Mapping) e por que ele existe
- Diferenciar **JPA** (especificação), **Hibernate** (implementação) e **Spring Data JPA** (camada mágica do Spring)
- Mapear uma classe Java para uma tabela com anotações (`@Entity`, `@Id`, `@Column`, `@Table`)
- Criar relacionamentos `@OneToMany` / `@ManyToOne`
- Usar `JpaRepository<T, ID>` para ganhar CRUD pronto sem escrever SQL
- Escrever **derived queries** só pelo nome do método (`findByVila`)
- Usar `@Query` para escrever JPQL quando o nome não dá conta
- Configurar o **H2** (banco em memória) e abrir o console no browser
- Saber o que são **migrations** com Flyway (versionar o schema do banco)

---

## 🗄️ Por que ORM existe?

Imagine que você quer salvar um `Ninja` no banco. Sem ORM, você escreveria SQL na mão:

```sql
INSERT INTO ninja (nome, vila, nivel) VALUES ('Naruto', 'Konoha', 99);
```

E para ler:

```sql
SELECT id, nome, vila, nivel FROM ninja WHERE vila = 'Konoha';
```

Depois você teria que **converter** cada linha do resultado num objeto `Ninja` manualmente, campo a campo. Multiplique isso por 30 entidades e 200 telas... vira um inferno.

**ORM (Object-Relational Mapping)** = mapeamento entre objetos (Java) e tabelas (banco relacional). Você fala "salva esse ninja" e o ORM gera o SQL pra você.

```java
ninjaRepository.save(new Ninja("Naruto", "Konoha", 99));
List<Ninja> deKonoha = ninjaRepository.findByVila("Konoha");
```

Pronto. Sem `INSERT`, sem `SELECT`, sem `ResultSet`.

---

## 📚 JPA, Hibernate, Spring Data JPA — quem é quem?

Essa sopa de nomes confunde todo mundo no começo. Olha a hierarquia:

| Camada | O que é | Analogia |
|---|---|---|
| **JPA** (Jakarta Persistence API) | **Especificação** (interface, contrato). Define as anotações `@Entity`, `@Id`, etc. | "Como deve ser um motor de carro" (norma) |
| **Hibernate** | **Implementação** mais famosa da JPA. Quem realmente gera o SQL. | "Motor da Volkswagen" (fabricante seguindo a norma) |
| **Spring Data JPA** | Camada do Spring **em cima** da JPA. Te dá `JpaRepository` com CRUD pronto. | "Carro automático já montado" |

Você vai escrever **anotações JPA** + **interfaces Spring Data JPA**, e o **Hibernate** trabalha por baixo dos panos. Você raramente lida com ele diretamente.

---

## 🏷️ Anotações de mapeamento (o básico)

```java
@Entity                              // "Essa classe é uma tabela"
@Table(name = "ninjas")              // (opcional) nome da tabela no banco
public class Ninja {

    @Id                              // chave primária
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // banco gera (autoincremento)
    private Long id;

    @Column(name = "nome", nullable = false, length = 100)
    private String nome;

    @Column(nullable = false)
    private String vila;

    private int nivel;               // sem @Column → usa o nome do campo

    // construtor vazio é OBRIGATÓRIO pra JPA
    public Ninja() {}

    // getters, setters, construtor com args...
}
```

### Estratégias de `@GeneratedValue`
- `IDENTITY` → banco gera (autoincremento). Mais comum em H2, MySQL, PostgreSQL.
- `SEQUENCE` → usa sequência do banco (Oracle, Postgres).
- `AUTO` → o Hibernate escolhe (não recomendo, vira surpresa).

---

## 🔗 Relacionamentos: `@OneToMany` e `@ManyToOne`

Um **Time** tem vários **Ninjas**. Cada **Ninja** pertence a um **Time**.

```java
@Entity
public class Time {
    @Id @GeneratedValue
    private Long id;
    private String nome;

    @OneToMany(mappedBy = "time", cascade = CascadeType.ALL)
    private List<Ninja> ninjas = new ArrayList<>();
}

@Entity
public class Ninja {
    @Id @GeneratedValue
    private Long id;
    private String nome;

    @ManyToOne                      // muitos ninjas pertencem a um time
    @JoinColumn(name = "time_id")   // FK na tabela ninja
    private Time time;
}
```

**Dono do relacionamento** = lado que tem a FK (Foreign Key). No exemplo, é `Ninja`. O outro lado usa `mappedBy = "time"` (nome do campo no dono).

> ⚠️ Em relacionamentos `@OneToMany` evite carregar listas gigantes sem necessidade — por padrão é `LAZY` (carrega só quando você acessa).

---

## 🛠️ `JpaRepository<T, ID>` — CRUD pronto

Você cria uma **interface** que estende `JpaRepository<Entidade, TipoDoId>` e ganha de graça:

```java
public interface NinjaRepository extends JpaRepository<Ninja, Long> {
    // Vazio? Sim. Já tem CRUD completo.
}
```

Métodos que vêm prontos:
- `save(entidade)` → INSERT ou UPDATE
- `findById(id)` → SELECT por PK, retorna `Optional<T>`
- `findAll()` → SELECT * FROM tabela
- `deleteById(id)` → DELETE
- `count()` → COUNT(*)
- `existsById(id)` → existe?

E você não escreve **uma linha** de SQL.

---

## 🔍 Derived Queries (consultas pelo nome do método)

O Spring Data JPA **interpreta o nome do método** e gera o SQL. Mágica? Quase.

```java
public interface NinjaRepository extends JpaRepository<Ninja, Long> {

    List<Ninja> findByVila(String vila);
    // → SELECT * FROM ninja WHERE vila = ?

    List<Ninja> findByNivelGreaterThan(int nivel);
    // → SELECT * FROM ninja WHERE nivel > ?

    List<Ninja> findByVilaAndNivelGreaterThanEqual(String vila, int nivel);
    // → SELECT * FROM ninja WHERE vila = ? AND nivel >= ?

    Optional<Ninja> findByNome(String nome);
    // → SELECT * FROM ninja WHERE nome = ? LIMIT 1

    long countByVila(String vila);
    // → SELECT COUNT(*) FROM ninja WHERE vila = ?
}
```

Palavras-chave úteis no nome:
`And`, `Or`, `Between`, `LessThan`, `GreaterThan`, `Like`, `In`, `OrderBy...Asc/Desc`, `Top10`, `First`.

> 💡 Dica: se o nome do método ficar enorme (`findByVilaAndNivelGreaterThanAndNomeContaining...`), é hora de usar `@Query`.

---

## 📝 `@Query` — JPQL quando precisa

JPQL (Java Persistence Query Language) parece SQL, mas opera **em cima de entidades**, não tabelas.

```java
public interface NinjaRepository extends JpaRepository<Ninja, Long> {

    @Query("SELECT n FROM Ninja n WHERE n.vila = :vila ORDER BY n.nivel DESC")
    List<Ninja> topDaVila(@Param("vila") String vila);

    @Query("SELECT n FROM Ninja n WHERE n.nivel >= :min AND n.nivel <= :max")
    List<Ninja> entreNiveis(@Param("min") int min, @Param("max") int max);
}
```

Repare: `Ninja` é a **classe** (não a tabela), `n.vila` é o **campo** (não a coluna). Isso é JPQL.

Se quiser SQL puro, use `@Query(value = "...", nativeQuery = true)`.

---

## 💾 H2 — banco em memória para desenvolvimento

**H2** é um banco SQL escrito em Java, leve, que pode rodar **em memória** (some quando você desliga a aplicação). Perfeito pra dev e testes.

### `pom.xml` (dependências relevantes)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

### `application.properties` (config H2)

```properties
# URL do banco em memória; "testdb" é só um nome
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# Dialeto avisa ao Hibernate qual SQL gerar
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Cria/atualiza tabelas a partir das @Entity (ótimo pra dev, RUIM em produção)
spring.jpa.hibernate.ddl-auto=update

# Mostra o SQL gerado no console (didático)
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Habilita o console web do H2
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

### Console do H2 no browser
1. Rode o Spring Boot.
2. Abra `http://localhost:8080/h2-console`.
3. Preencha: **JDBC URL** = `jdbc:h2:mem:testdb`, **User** = `sa`, **Password** vazio.
4. Conecte e rode `SELECT * FROM NINJA;`.

> ⚠️ Por ser em memória, **os dados somem ao reiniciar**. Pra persistir use `jdbc:h2:file:./dados/meubanco`.

### `ddl-auto` — opções
- `none` → não mexe (produção).
- `validate` → só checa se schema bate com entidades.
- `update` → adiciona colunas/tabelas faltando (dev).
- `create` → apaga e recria toda vez que sobe.
- `create-drop` → cria ao subir, apaga ao desligar (testes).

---

## 🚚 Migrations com Flyway (mencionar)

`ddl-auto=update` é ótimo em dev, mas em produção é **arriscado** (pode dropar dados). A solução profissional: **migrations versionadas**.

**Flyway** é uma ferramenta que executa scripts SQL versionados no banco, na ordem certa, uma única vez cada.

### Estrutura
```
src/main/resources/
└── db/migration/
    ├── V1__cria_tabela_ninja.sql
    ├── V2__adiciona_coluna_email.sql
    └── V3__cria_tabela_time.sql
```

### Exemplo: `V1__cria_tabela_ninja.sql`
```sql
CREATE TABLE ninja (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    vila VARCHAR(50) NOT NULL,
    nivel INT NOT NULL
);
```

### `pom.xml`
```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

### `application.properties`
```properties
spring.jpa.hibernate.ddl-auto=validate     # JPA não mexe, só valida
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
```

Toda vez que sobe a aplicação, o Flyway:
1. Olha a tabela `flyway_schema_history` no banco.
2. Roda as migrations que ainda não rodaram, na ordem do número de versão.
3. Marca como executadas.

Time inteiro fica com banco igual, e nada de "no meu PC funciona".

---

## 🧱 Arquitetura padrão Spring + JPA

```
Controller (HTTP)
   ↓
Service (regras de negócio)
   ↓
Repository (JPA — fala com o banco)
   ↓
Entity (mapeada pra tabela)
```

Cada camada tem uma responsabilidade. Não chame o Repository direto do Controller — passe pelo Service.

```java
@RestController
@RequestMapping("/ninjas")
class NinjaController {
    private final NinjaService service;
    NinjaController(NinjaService s) { this.service = s; }
}

@Service
class NinjaService {
    private final NinjaRepository repo;
    NinjaService(NinjaRepository r) { this.repo = r; }
}

interface NinjaRepository extends JpaRepository<Ninja, Long> { }
```

---

## ⚠️ Pegadinhas que valem ouro

- **Construtor vazio** na `@Entity` é obrigatório (a JPA usa pra instanciar).
- **`equals` e `hashCode`** em entidades: cuidado. Use só `id` (e trate `id == null`).
- **N+1 queries**: ao iterar uma lista e acessar relacionamento `LAZY`, cada item gera um SELECT. Use `JOIN FETCH` no `@Query` ou `@EntityGraph`.
- **`spring.jpa.show-sql=true`** é seu amigo: você **vê** o SQL gerado e pega problema cedo.
- **`@Transactional`** no Service garante que tudo dentro do método é uma transação só.
- **Não retorne entidades JPA direto no Controller** em projetos sérios — use DTOs (próximo módulo). Aqui, por enquanto, vamos retornar pra simplificar.

---

## 🚦 Próximos passos
1. Abra `pratica/Main.java` e leia o código comentado.
2. Suba um projeto Spring Boot com as dependências de JPA e H2.
3. Encare o **desafio**: API CRUD completa de Ninjas com persistência.

## ✅ Auto-verificação
- [ ] Sei explicar a diferença entre JPA, Hibernate e Spring Data JPA
- [ ] Sei anotar uma classe como `@Entity` com `@Id` e `@GeneratedValue`
- [ ] Sei criar um `JpaRepository` e usar derived queries
- [ ] Sei usar `@Query` com JPQL e parâmetros nomeados
- [ ] Configurei o H2 e abri o console no browser
- [ ] Entendo o que é uma migration Flyway e por que ela existe

Próximo módulo: **Validação + DTOs + Tratamento de Erros** — deixar a API profissional.
