# Módulo 16 — Maven e Estrutura de Projetos

> **Base para os módulos Spring Boot.** Antes de mergulhar em frameworks, é fundamental entender como projetos Java de verdade são organizados, construídos e como suas dependências são gerenciadas.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar **por que** Maven existe (e por que ninguém compila "na mão" depois que aprende)
- Reconhecer a **estrutura padrão** de um projeto Maven
- Ler e escrever um **`pom.xml`** básico
- Conhecer as principais **fases do lifecycle** (clean, compile, test, package, install, deploy)
- Adicionar uma dependência do **Maven Central**
- Rodar os comandos `mvn` mais comuns
- Saber que **Gradle** existe como alternativa

## 🤔 Por que Maven?

Imagine um projeto Java sem Maven:
- Você baixa **manualmente** o `.jar` de cada biblioteca (Gson, JDBC, JUnit...)
- Cada biblioteca tem suas próprias dependências, que precisam de outras... ("dependency hell")
- Você compila com `javac` listando 30 jars no classpath
- Cada colega organiza o projeto de um jeito diferente
- Não tem padrão de onde ficam os testes, recursos, etc

**Maven resolve tudo isso de uma vez:**
1. **Gerenciamento de dependências**: declara no `pom.xml` e o Maven baixa (com transitivas)
2. **Estrutura padrão**: todo projeto Maven tem a mesma cara
3. **Build automatizado**: compilar, testar, empacotar — um comando
4. **Lifecycle bem definido**: fases padronizadas que qualquer dev reconhece
5. **Ecossistema gigante**: Maven Central tem **milhões** de bibliotecas prontas

> Em projetos profissionais, Maven (ou Gradle) é **obrigatório**. Quase todo tutorial de Spring, Hibernate, etc, assume que você usa um deles.

## 📁 Estrutura padrão de um projeto Maven

```
meu-projeto/
├── pom.xml                          ← o "coração" do projeto
├── src/
│   ├── main/
│   │   ├── java/                    ← código-fonte da aplicação
│   │   │   └── com/exemplo/app/
│   │   │       └── Main.java
│   │   └── resources/               ← arquivos não-Java (config, imagens, SQL)
│   │       └── application.properties
│   └── test/
│       ├── java/                    ← código de teste (JUnit)
│       │   └── com/exemplo/app/
│       │       └── MainTest.java
│       └── resources/               ← recursos só de teste
└── target/                          ← gerado pelo Maven (compilados, jars)
```

**Por que essa estrutura importa?**
- Qualquer dev Java abre o projeto e **já sabe onde tudo está**
- Plugins, IDEs, CI/CD funcionam automaticamente
- Separação clara entre **código de produção** e **testes**
- `target/` vai pro `.gitignore` (é só artefato gerado)

## 📜 O `pom.xml` — coração do projeto

POM = **Project Object Model**. É um XML que descreve seu projeto.

Estrutura mínima:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <!-- Identidade do projeto (coordenadas) -->
    <groupId>com.exemplo</groupId>
    <artifactId>meu-app</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>

    <!-- Versão do Java -->
    <properties>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <!-- Dependências (bibliotecas que seu projeto usa) -->
    <dependencies>
        <dependency>
            <groupId>com.google.code.gson</groupId>
            <artifactId>gson</artifactId>
            <version>2.10.1</version>
        </dependency>
    </dependencies>
</project>
```

### As "coordenadas" (groupId : artifactId : version)
Toda biblioteca Maven é identificada por um trio:
- **groupId**: organização/empresa, padrão de domínio invertido (`com.google.code.gson`)
- **artifactId**: nome da biblioteca (`gson`)
- **version**: a versão (`2.10.1`)

Você vai ver isso milhares de vezes — é o "CPF" de cada biblioteca.

### Tipos comuns de seções no `pom.xml`
- `<dependencies>`: bibliotecas que seu código usa
- `<plugins>`: ferramentas que rodam durante o build (compilar, empacotar, etc)
- `<properties>`: variáveis reutilizáveis (versão do Java, encoding...)
- `<parent>`: herda de outro pom (muito usado no Spring Boot)

## 🔁 Lifecycle do Maven (fases)

Maven tem **fases** que rodam em sequência. Quando você chama uma fase, **todas as anteriores rodam também**.

| Fase | O que faz |
|---|---|
| `clean` | Apaga `target/` (limpa builds anteriores) |
| `validate` | Verifica se o projeto está OK |
| `compile` | Compila `src/main/java` → `target/classes` |
| `test` | Roda os testes de `src/test/java` |
| `package` | Empacota em `.jar` (ou `.war`) dentro de `target/` |
| `verify` | Roda verificações de integração |
| `install` | Copia o `.jar` pro **repositório local** (`~/.m2/repository`) |
| `deploy` | Envia pro **repositório remoto** (ex: Nexus, Maven Central) |

> Exemplo: `mvn package` roda automaticamente `validate → compile → test → package`.

## ⌨️ Comandos `mvn` mais usados

```bash
mvn clean                  # apaga target/
mvn compile                # compila o código
mvn test                   # roda os testes
mvn package                # gera o .jar em target/
mvn clean package          # limpa e gera o .jar do zero
mvn install                # instala no repositório local (.m2)
mvn dependency:tree        # mostra a árvore de dependências
mvn archetype:generate     # cria um projeto novo a partir de template
```

> `mvn clean package` é o que você vai mais digitar na vida. Decora.

## 🌍 Maven Central — o "npm" do Java

[**Maven Central**](https://search.maven.org/) é o repositório público gigante onde estão **quase todas** as bibliotecas Java do mundo: Gson, Jackson, JUnit, Spring, Hibernate, Apache Commons...

Você procura a biblioteca lá, copia o `<dependency>` e cola no seu `pom.xml`. Maven baixa automaticamente.

### Repositório local (`~/.m2/repository`)
Tudo que o Maven baixa fica em `~/.m2/repository` no seu computador. Da próxima vez que precisar da mesma biblioteca, ele usa a versão local — **não baixa de novo**.

## 🆚 E o Gradle?

**Gradle** é a alternativa moderna ao Maven. Em vez de XML, usa Groovy ou Kotlin DSL. Pontos:
- Sintaxe mais concisa: `implementation 'com.google.code.gson:gson:2.10.1'`
- Build incremental mais inteligente (mais rápido em projetos grandes)
- Padrão no **Android**
- Suportado pelo Spring Boot também

Maven ainda é mais comum em projetos corporativos Java/Spring. **Vale dominar Maven primeiro** — depois Gradle vira fácil.

## 💡 Pegadinhas que valem ouro

- **Não comite a pasta `target/`** — vai no `.gitignore`
- **Não comite `~/.m2/`** — é cache do Maven
- **A primeira execução demora**: Maven baixa milhares de coisas; depois fica rápido
- **Versão fixa > "LATEST"**: nunca use `<version>LATEST</version>` em produção
- **Mudou o `pom.xml`?** No IntelliJ, clique no ícone de "reimport" (ou `Ctrl+Shift+O`)
- **Encoding**: sempre defina `UTF-8` em `<properties>` — evita dor de cabeça com acentos
- **groupId** segue convenção de domínio invertido: `com.suaempresa.projeto`

## 🚦 Próximos passos
1. Leia **`pratica/Main.java`** — exemplo de como uma classe vive num projeto Maven.
2. Encare o **desafio**: criar um projeto Maven do zero e adicionar a dependência do Gson.
3. Dali pra frente, todo módulo de Spring Boot vai assumir que você entende Maven.

## ✅ Auto-verificação
- [ ] Sei explicar por que Maven existe (gerenciar dependências + padronizar build)
- [ ] Sei a estrutura padrão (`src/main/java`, `src/main/resources`, `src/test/java`)
- [ ] Sei o que são groupId, artifactId, version
- [ ] Conheço as fases principais do lifecycle (clean, compile, test, package, install)
- [ ] Sei o que é Maven Central e onde fica o repositório local
- [ ] Sei rodar `mvn clean package`
- [ ] Sei que Gradle é uma alternativa

Próximo módulo: **Spring Boot — primeiros passos** (agora com Maven na bagagem).
