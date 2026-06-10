# Módulo 05 — Persistência com Hibernate ORM + Panache

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Subir um Postgres automaticamente em dev com **Dev Services** (sem instalar nada)
- Mapear entidades com **`PanacheEntity`** (active record) e com **`PanacheRepository`** (repository)
- Escrever queries fluentes: `find`, `list`, `count`, `delete`, `update`, com paginação
- Modelar relacionamentos `@ManyToOne` / `@OneToMany`
- Usar `@Transactional` no lugar certo (só onde grava)
- Reconhecer as armadilhas clássicas: **LazyInitializationException** e **N+1**

## 🐘 Dev Services: Postgres de graça em dev

Você adicionou `quarkus-jdbc-postgresql` e `quarkus-hibernate-orm-panache`. Pergunta natural: "preciso instalar Postgres?"

**Não.** Em modo dev/teste, se você não configurar `quarkus.datasource.jdbc.url`, o Quarkus **sobe um container Docker** com Postgres pronto e plugga sua app nele. Isso é **Dev Services**.

Requisito: ter **Docker** (ou Podman/Testcontainers) rodando na máquina.

No `application.properties` você só precisa de:
```properties
quarkus.datasource.db-kind=postgresql
quarkus.hibernate-orm.database.generation=drop-and-create
quarkus.hibernate-orm.log.sql=true
```

Sem URL, sem usuário, sem senha. Em **produção** você configura via env:
```
QUARKUS_DATASOURCE_JDBC_URL=jdbc:postgresql://db.prod:5432/livraria
QUARKUS_DATASOURCE_USERNAME=app
QUARKUS_DATASOURCE_PASSWORD=...
```

## 🐼 O que é Panache?

JPA puro é verboso: `EntityManager`, `CriteriaBuilder`, DAOs cheios de boilerplate. **Panache** é a camada Quarkus em cima do Hibernate que corta isso. Você escolhe um de dois estilos:

### Estilo 1: `PanacheEntity` (Active Record)
A entidade **é** o repositório. Métodos estáticos pra tudo.

```java
@Entity
public class Autor extends PanacheEntity {
    public String nome;
    public LocalDate nascimento;
}

// uso:
Autor a = new Autor();
a.nome = "Clarice";
a.persist();

List<Autor> todos = Autor.listAll();
Autor um = Autor.findById(1L);
Autor.delete("nome", "Clarice");
```

`PanacheEntity` já te dá um `id` Long autogerado. Campos podem ser **públicos** — Panache gera getters/setters em tempo de build, e se você precisar de lógica num getter, é só escrever ele que Panache respeita.

### Estilo 2: `PanacheRepository` (Repository pattern)
A entidade fica "limpa" e um repositório separado faz as queries.

```java
@Entity
public class Livro {
    @Id @GeneratedValue Long id;
    public String titulo;
}

@ApplicationScoped
public class LivroRepository implements PanacheRepository<Livro> {
    // findById, listAll, persist, count, delete... já vêm de graça
    public List<Livro> doAutor(Long autorId) {
        return list("autor.id", autorId);
    }
}
```

### Qual usar?
- **Active Record** (`PanacheEntity`) — projetos novos, domínio simples, código curto.
- **Repository** — equipe vinda de Spring/JPA tradicional, regras de negócio complexas, vontade de separar responsabilidades.

Ambos performam igual. Não misture os dois pra mesma entidade.

## 🔎 Queries fluentes

Você não escreve JPQL inteiro toda hora. Panache aceita **fragmentos**:

```java
// só o WHERE:
Livro.list("titulo", "Memórias Póstumas");
Livro.list("titulo like ?1", "Memórias%");
Livro.list("autor.nome = :nome", Parameters.with("nome", "Machado"));

// ordenação:
Livro.list("autor.id", Sort.by("titulo").descending(), 1L);

// count e delete:
long quantos = Livro.count("titulo like ?1", "O%");
long deletados = Livro.delete("autor.id", 99L);

// update em massa (precisa de @Transactional):
Livro.update("preco = preco * 1.1 where autor.id = ?1", 1L);

// findById:
Livro l = Livro.findById(42L);
```

### Paginação
```java
List<Livro> pagina = Livro.findAll(Sort.by("titulo"))
        .page(Page.of(0, 20))   // página 0, 20 itens
        .list();

PanacheQuery<Livro> q = Livro.findAll();
int totalPaginas = q.page(Page.ofSize(20)).pageCount();
```

### Projeções
Pra trazer só alguns campos (mais rápido que carregar a entidade inteira):
```java
record TituloAutor(String titulo, String autorNome) {}

List<TituloAutor> r = Livro.find("select l.titulo, l.autor.nome from Livro l")
        .project(TituloAutor.class)
        .list();
```

## 🔗 Relacionamentos básicos

```java
@Entity
public class Autor extends PanacheEntity {
    public String nome;

    @OneToMany(mappedBy = "autor", cascade = CascadeType.ALL)
    public List<Livro> livros = new ArrayList<>();
}

@Entity
public class Livro extends PanacheEntity {
    public String titulo;

    @ManyToOne
    public Autor autor;
}
```

O dono da relação é o lado do `@ManyToOne` (tem a FK). O `@OneToMany` referencia via `mappedBy`.

## 💾 `@Transactional`: só onde grava

Hibernate exige transação **pra escrever** (insert/update/delete). Leitura simples não precisa. Anote o método do Resource ou do Service que altera dados:

```java
@POST
@Transactional
public Livro criar(Livro l) {
    l.persist();
    return l;
}
```

Se esquecer, vai estourar `TransactionRequiredException` ou um silencioso "nada foi salvo". Em código novo, a regra fácil: **POST/PUT/DELETE = `@Transactional`**.

## ⚠️ Armadilhas clássicas

### LazyInitializationException
Por padrão, `@OneToMany` é **lazy** — a coleção só carrega quando você acessa. Se você devolve a entidade do Resource e a transação já fechou, Jackson tenta serializar a lista e... boom.

Soluções:
1. Use `fetch = FetchType.EAGER` (cuidado, pode puxar muita coisa).
2. Acesse a coleção dentro da transação (`autor.livros.size()` força o carregamento).
3. Use uma **projeção** ou DTO — devolva só o que o cliente precisa.
4. Anote o método com `@Transactional` (mantém a sessão aberta durante a serialização).

### N+1
Listar 100 autores e pra cada um acessar `livros` = 1 query nos autores + 100 queries nos livros. Sintoma: app lenta, log SQL gigante.

Conserto rápido: **fetch join**:
```java
Autor.find("select distinct a from Autor a left join fetch a.livros").list();
```

## 💡 Detalhes que valem ouro
- **Campos públicos não são "ruim"**: Panache reescreve em build-time pra usar getters/setters. Você pode adicionar getter customizado depois — Panache detecta e respeita.
- **`drop-and-create`** apaga o banco a cada start. Em prod use `none` ou `validate` (e gerencie schema com **Flyway**/**Liquibase**, módulos futuros).
- **`import.sql`** na pasta `resources/` roda automaticamente após criar o schema — ótimo pra seed de dev.
- **Dev UI** (http://localhost:8080/q/dev) tem painel **Datasources** com console SQL e o **Hibernate ORM** mostra entidades/queries.
- **Log SQL**: `quarkus.hibernate-orm.log.sql=true` mostra cada query no console. Indispensável pra caçar N+1.
- **`persistAndFlush()`** força o INSERT na hora (útil pra pegar erro de constraint antes de sair do método).
- **`@Transactional` em Resource** funciona, mas costuma viver melhor em Service — separação que vai ficar mais clara nos módulos 06+.

## 🚦 Próximos passos
1. Abra `pratica/` e copie os arquivos pro seu projeto (precisa das extensões `hibernate-orm-panache` + `jdbc-postgresql`)
2. Garanta que o **Docker está rodando** (Dev Services precisa)
3. `quarkus dev` — observe no log a linha "Dev Services for default datasource (postgresql) started"
4. Rode o `comandos.sh` e veja os SQLs aparecerem no console
5. Abra `http://localhost:8080/q/dev` e explore o painel do Hibernate
6. Encare o desafio de **Categoria/Produto**

## ✅ Auto-verificação
- [ ] Sei o que Dev Services faz e por que não preciso configurar URL em dev
- [ ] Sei a diferença entre `PanacheEntity` e `PanacheRepository`
- [ ] Sei escrever queries com fragmento (`list("titulo", ...)`)
- [ ] Sei paginação com `Page.of(n, tam)`
- [ ] Lembro de `@Transactional` em todo método que grava
- [ ] Reconheço N+1 lendo o log SQL
- [ ] Entendo por que LazyInit acontece e tenho 1 estratégia pra evitar

Próximo módulo: **REST Client** — consumindo APIs externas de forma type-safe.
