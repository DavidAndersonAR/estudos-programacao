# Módulo 18 — Native Image com GraalVM

## 🎯 Objetivos

- Entender a diferença entre **JIT** (Just-In-Time) e **AOT** (Ahead-Of-Time).
- Gerar um executável nativo do Quarkus usando GraalVM.
- Usar **container build** para não precisar instalar GraalVM localmente.
- Conhecer os limites do native (reflection, proxy dinâmico, recursos).
- Usar `@RegisterForReflection` e hints de recursos.
- Empacotar o binário nativo em uma imagem Docker mínima.

---

## 1. JIT vs AOT — explicação simples

| Característica | JVM (JIT) | Native (AOT) |
|---|---|---|
| Quando compila | Em tempo de execução, conforme aquece | Antes de rodar, no build |
| Startup | ~1-3 segundos | ~0,02-0,05 segundos |
| Memória RAM | ~150-300 MB | ~20-50 MB |
| Throughput (pico) | Maior, depois de aquecer | Levemente menor |
| Tamanho do artefato | Jar pequeno + JRE grande | Binário único ~50-80 MB |
| Tempo de build | Segundos | 1-3 minutos |

**Quando usar nativo?** Funções serverless (AWS Lambda), CLIs, microsserviços que escalam para zero e precisam subir rápido.

**Quando manter JVM?** Cargas longas com throughput máximo, apps que se beneficiam do JIT otimizar hot paths.

---

## 2. Build local vs container

### Local (precisa GraalVM 21 instalado)

```bash
# Precisa do GraalVM CE 21 + native-image instalados
./mvnw package -Pnative
```

### Container (recomendado — só precisa Docker)

```bash
./mvnw package -Pnative -Dquarkus.native.container-build=true
```

O Quarkus baixa uma imagem oficial `quay.io/quarkus/ubi-quarkus-mandrel-builder-image` que já tem o GraalVM e gera o binário dentro do container. O resultado fica em `target/`.

> Use **container build** sempre que possível: garante reprodutibilidade e evita conflitos de versão de GraalVM.

Resultado: `target/seu-app-1.0.0-SNAPSHOT-runner` (Linux ELF).

---

## 3. Rodando o nativo

```bash
./target/seu-app-1.0.0-SNAPSHOT-runner
```

Para medir o startup:

```bash
time ./target/seu-app-1.0.0-SNAPSHOT-runner
```

Compare com:

```bash
time java -jar target/quarkus-app/quarkus-run.jar
```

A diferença é gritante.

---

## 4. Limites do native (e como contornar)

O `native-image` faz **análise estática** no build. Tudo que ele não consegue "ver" é eliminado. Isso quebra:

### 4.1 Reflection

Se uma classe é instanciada/lida só via reflection (ex.: deserialização Jackson de um DTO genérico, ou um config externo), o GraalVM remove a classe. Solução:

```java
import io.quarkus.runtime.annotations.RegisterForReflection;

@RegisterForReflection
public class ConfiguracaoExterna {
    public String chave;
    public String valor;
}
```

Ou registrar várias de uma vez:

```java
@RegisterForReflection(targets = { Cliente.class, Pedido.class })
public class ReflectionConfig {}
```

### 4.2 Proxy dinâmico

`java.lang.reflect.Proxy` precisa ser declarado no build. Frameworks (Hibernate, REST Client) já cuidam disso. Código próprio com proxy dinâmico exige hints manuais.

### 4.3 Recursos (arquivos em `resources/`)

Arquivos lidos via `getResourceAsStream("dados.json")` precisam ser incluídos:

```properties
quarkus.native.resources.includes=dados.json,templates/**.html
```

### 4.4 Classes carregadas dinamicamente

`Class.forName("...")` com nome em runtime falha. Evite ou registre explicitamente.

---

## 5. Build time vs run time properties

No nativo, **algumas configurações são fixadas no momento do build** e não podem mudar em runtime.

- **Build time:** drivers de banco, extensões ativas, `quarkus.datasource.db-kind`. Mudar exige recompilar.
- **Run time:** URLs, senhas, portas, valores de negócio. Podem vir de variáveis de ambiente.

A regra: configurações marcadas como `@ConfigPhase.BUILD_TIME` (na doc das extensões) ficam congeladas no binário.

---

## 6. Args extras do build

```properties
# application.properties
quarkus.native.additional-build-args=-H:+ReportExceptionStackTraces,--initialize-at-run-time=com.exemplo.MinhaClasse
```

Útil para diagnosticar erros (`-H:+ReportExceptionStackTraces`) ou ajustar inicialização de classes problemáticas.

---

## 7. Empacotando em Docker

Dockerfile multi-stage usando `ubi-minimal` (~70 MB de imagem final):

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4
WORKDIR /work/
COPY target/*-runner /work/application
RUN chmod 775 /work
EXPOSE 8080
USER 1001
ENTRYPOINT ["./application", "-Dquarkus.http.host=0.0.0.0"]
```

A imagem final tem **só o SO mínimo + seu binário**. Sem JVM, sem dependências.

---

## 💡 Detalhes

- **Testes nativos:** use `@QuarkusIntegrationTest` em vez de `@QuarkusTest`. Ele sobe o binário nativo e roda os testes contra ele de fora (HTTP). Rodar com `./mvnw verify -Pnative`.
- **CDS / AppCDS:** se native for exagero, a JVM moderna tem AppCDS que reduz startup. É um meio termo.
- **Mandrel:** é a distribuição GraalVM mantida pela Red Hat focada em Quarkus. Mais leve que o GraalVM completo.
- **Tracing agent:** se você tem uma lib legada com muita reflection, rode com `java -agentlib:native-image-agent=config-output-dir=...` na JVM primeiro para gerar os hints automaticamente.

---

## 🚦 Próximos passos

- Módulo 19: Observabilidade (Micrometer, Prometheus, OpenTelemetry).
- Módulo 20: Deploy em Kubernetes com a imagem nativa.

---

## ✅ Auto-verificação

1. Qual a diferença entre JIT e AOT em uma frase?
2. Por que `container-build=true` é recomendado?
3. Para que serve `@RegisterForReflection`?
4. Por que `Class.forName(nomeDinamico)` quebra no native?
5. Qual a diferença entre propriedade build time e run time?
6. Como medir o startup do binário nativo?
7. Qual annotation usar para testes de integração contra o binário?
