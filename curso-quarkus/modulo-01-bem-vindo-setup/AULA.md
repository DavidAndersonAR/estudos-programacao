# Módulo 01 — Bem-vindo + Setup

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que Quarkus resolve
- Instalar Quarkus CLI
- Criar um projeto novo
- Rodar em modo dev com live reload
- Criar seu primeiro endpoint REST

## ☕ O que é Quarkus?

Java tem fama de ser "lento pra subir, pesado em RAM". Isso era verdade nos tempos do app servers JEE de 30s de startup. **Quarkus quebra isso**:

- **Startup em ~0.05s** (vs ~5s do Spring Boot tradicional)
- **RAM ~30 MB** (vs ~200 MB)
- **Native image** (GraalVM): vira binário standalone tipo Go/Rust — startup ~0.005s, RAM ~10 MB

Quarkus = Java repaginado pra **cloud, Kubernetes, serverless** — onde subir rápido e ocupar pouco importa muito (escalar pods, cold start lambda, etc).

E o melhor: **APIs que você já conhece** — JAX-RS, CDI, JPA, etc. Não é framework novo do zero; é a stack Jakarta EE/MicroProfile compilada de um jeito mais inteligente.

## 🆚 Quarkus vs Spring Boot

| | Quarkus | Spring Boot |
|---|---|---|
| Startup | ~50ms | ~3-5s |
| RAM idle | ~30 MB | ~200 MB |
| Native image | Suporte nativo | Spring Native (mais novo) |
| Live reload | Sim, instantâneo | DevTools (mais lento) |
| Ecossistema | Crescendo | Gigante |
| Curva | Suave se conhece JEE | Idem |

Não é um substituto universal. Spring ainda domina enterprise. Quarkus ganha em **serverless, microsserviços leves e tudo que escala em K8s**.

## 🛠️ Setup

### 1. JDK 21
```bash
java --version
# openjdk 21+ — ok
```

Se não tiver: `winget install Eclipse.Temurin.21.JDK`

### 2. Quarkus CLI (via JBang)
JBang é um runner pra apps Java distribuídos como scripts. Instala uma vez, usa pra sempre.

```powershell
# Instalar JBang
winget install JBang.JBang

# Instalar Quarkus CLI via JBang
jbang app install --fresh --force quarkus@quarkusio

# Verificar
quarkus --version
```

### 3. Docker
Já temos do curso anterior. Quarkus Dev Services usa pra subir Postgres/Kafka/etc automaticamente.

## 🚀 Criar primeiro projeto

```bash
quarkus create app com.exemplo:meu-app --extension=rest-jackson
cd meu-app
```

Opções comuns:
- `--extension=rest-jackson` → REST + JSON
- `--extension=rest-jackson,hibernate-orm-panache,jdbc-postgresql` → API + BD
- `--gradle` → usa Gradle em vez de Maven
- `--java=21` → escolhe versão do Java

### Estrutura gerada
```
meu-app/
├── pom.xml                          # Maven com extensões Quarkus
├── src/
│   ├── main/
│   │   ├── java/com/exemplo/
│   │   │   └── GreetingResource.java  # endpoint inicial
│   │   └── resources/
│   │       └── application.properties # config
│   └── test/
│       └── java/com/exemplo/
│           └── GreetingResourceTest.java
└── README.md
```

## 🔥 Modo Dev (a parte mágica)

```bash
quarkus dev
```

O que você ganha:
- App sobe em **< 1s**
- Alterou código? **Salva → próxima requisição já tá com a mudança**. Sem restart manual.
- **Dev UI** em http://localhost:8080/q/dev — visualiza extensões, env, logs
- **Continuous testing**: testes rodam em background a cada mudança
- **Dev Services**: precisa de Postgres? Quarkus sobe um container automaticamente

Atalhos no console:
- `s` → re-run testes
- `r` → continuous testing on/off
- `o` → dev UI no browser
- `q` → sair

## 📝 Anatomia do GreetingResource

```java
package com.exemplo;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/hello")
public class GreetingResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Hello from Quarkus REST";
    }
}
```

- `@Path("/hello")` — URL base do recurso
- `@GET` — método HTTP
- `@Produces` — content-type da resposta
- Spec: **JAX-RS** (padrão Jakarta EE) — mesma API do RESTEasy, Jersey, etc

Teste: `curl http://localhost:8080/hello`

## 🎨 Dev UI

http://localhost:8080/q/dev mostra:
- Todas as extensões instaladas
- Configuração efetiva
- Endpoints REST
- Beans CDI
- Logs em tempo real
- Continuous testing
- Banco de dados (se tiver Panache)

Vale a pena explorar 5 minutos.

## 💡 Detalhes que valem ouro
- **Code Quarkus** (https://code.quarkus.io) é o "Spring Initializr" do Quarkus. Útil pra ver todas as extensões.
- `quarkus ext list -i` → lista extensões instaladas
- `quarkus ext add hibernate-orm-panache` → adiciona extensão no projeto
- `application.properties` aceita **profile**: `%dev.quarkus.log.level=DEBUG` só vale em dev
- Live reload **não recompila tudo** — só o que mudou, na primeira requisição depois da mudança
- Se aparecer erro de port em uso: `quarkus dev -Dquarkus.http.port=8081`

## 🚦 Próximos passos
1. Instale JDK 21, JBang, Quarkus CLI
2. Crie o projeto: `quarkus create app com.exemplo:meu-app --extension=rest-jackson`
3. Entre: `cd meu-app`
4. Rode: `quarkus dev`
5. Abra http://localhost:8080/hello
6. Veja `pratica/` pro passo a passo
7. Encare o desafio

## ✅ Auto-verificação
- [ ] JDK 21 e Quarkus CLI instalados
- [ ] Projeto criado e rodando em `quarkus dev`
- [ ] Sei o que é live reload
- [ ] Vi a Dev UI

Próximo módulo: **REST básico** — endpoints com path/query params e JSON.
