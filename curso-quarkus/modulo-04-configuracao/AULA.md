# Módulo 04 — Configuração com MicroProfile Config

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Ler valores de configuração com `@ConfigProperty`
- Agrupar configs em uma interface tipada com `@ConfigMapping`
- Usar **profiles** (`%dev.`, `%prod.`, `%test.`) pra trocar comportamento por ambiente
- Sobrescrever configs em produção via **variáveis de ambiente**
- Entender a **ordem de precedência** entre as fontes de configuração
- Saber o que é (e quando criar) um `ConfigSource` customizado

## 🧠 Por que isso importa?

Toda app séria tem **valores que mudam por ambiente**: URL de banco, chave de API, limites de rate, e-mail de remetente. Não dá pra hardcodar — e também não dá pra ficar caçando `if (env == "prod")` no código.

Quarkus segue a spec **MicroProfile Config**, que padroniza isso: você pede um valor por nome e o framework resolve **de onde vier** — `.properties`, env, system property, Vault, etc. Seu código não muda.

## 📂 Onde colocar config

`src/main/resources/application.properties` (padrão Quarkus). Exemplo:

```properties
app.email.remetente=no-reply@exemplo.com
app.email.assunto-padrao=Boas-vindas
app.limite.requisicoes=100
```

Prefere YAML? Adiciona a extensão e usa `application.yaml`:

```bash
quarkus ext add config-yaml
```

```yaml
app:
  email:
    remetente: no-reply@exemplo.com
    assunto-padrao: Boas-vindas
  limite:
    requisicoes: 100
```

Os dois funcionam iguais. YAML é melhor pra estrutura aninhada; properties é mais simples e universal.

## 🪝 Lendo valor único: `@ConfigProperty`

```java
import org.eclipse.microprofile.config.inject.ConfigProperty;
import jakarta.inject.Inject;

@ApplicationScoped
public class EmailService {

    @ConfigProperty(name = "app.email.remetente")
    String remetente;

    @ConfigProperty(name = "app.email.assunto-padrao", defaultValue = "Sem assunto")
    String assuntoPadrao;
}
```

- `name` → chave da config
- `defaultValue` → fallback se ninguém setou (senão, app **não sobe**)
- Suporta `int`, `boolean`, `Duration`, `List<String>`, `Optional<String>` etc — conversão automática

Tipo `Optional` é ótimo quando o valor é genuinamente opcional:

```java
@ConfigProperty(name = "app.feature.beta")
Optional<Boolean> betaAtivo;
```

## 🏷️ Agrupando: `@ConfigMapping` (a forma profissional)

`@ConfigProperty` solto fica feio quando você tem 10 configs. Use uma **interface tipada**:

```java
import io.smallrye.config.ConfigMapping;

@ConfigMapping(prefix = "app")
public interface AppConfig {

    Email email();
    int limiteRequisicoes();

    interface Email {
        String remetente();
        String assuntoPadrao();
    }
}
```

Properties associadas:

```properties
app.email.remetente=no-reply@exemplo.com
app.email.assunto-padrao=Boas-vindas
app.limite-requisicoes=100
```

Quarkus gera a implementação. Você injeta como qualquer bean:

```java
@Inject AppConfig config;
// uso: config.email().remetente()
```

**Vantagens**: tipado, agrupado, valida na hora do boot (config faltando = erro claro), aceita `Optional<T>`, `List<T>`, defaults via `@WithDefault`.

```java
@WithDefault("100")
int limiteRequisicoes();
```

Convenção de nomes: `assuntoPadrao()` no Java vira `assunto-padrao` no properties (kebab-case).

## 🌱 Profiles: configs por ambiente

Prefixe a chave com `%nome.`:

```properties
# Default (todos os profiles)
app.email.remetente=no-reply@exemplo.com

# Só em dev
%dev.app.email.remetente=dev@local.test
%dev.quarkus.log.level=DEBUG

# Só em prod
%prod.app.email.remetente=contato@empresa.com

# Só em test
%test.app.email.remetente=test@fake.io
```

Profiles padrão:
- `dev` → ativo quando você roda `quarkus dev`
- `test` → ativo durante `./mvnw test`
- `prod` → ativo no JAR/native (`java -jar ...`)

Custom: `quarkus dev -Dquarkus.profile=staging` → ativa `%staging.`

## 🌍 Override em produção: variáveis de ambiente

Em prod **não** se mexe em `.properties`. Você sobe a mesma imagem em dev/staging/prod e troca o comportamento via env var. MicroProfile Config mapeia automático:

| Property            | Env var               |
|---------------------|-----------------------|
| `app.email.remetente` | `APP_EMAIL_REMETENTE` |
| `quarkus.http.port` | `QUARKUS_HTTP_PORT`   |

Regra: maiúsculas + `.` e `-` viram `_`.

Exemplo concreto:

```bash
APP_EMAIL_REMETENTE=contato@empresa.com \
APP_LIMITE_REQUISICOES=500 \
java -jar target/quarkus-app/quarkus-run.jar
```

Sem rebuild, sem mexer no código.

## 🏛️ Ordem de precedência

Quando o mesmo valor existe em mais de um lugar, **quem ganha**:

```
   maior prioridade
   ┌──────────────────────────────────────────┐
   │ 1. System properties  ( -Dapp.x=y )      │
   │ 2. Variáveis de ambiente  ( APP_X=y )    │
   │ 3. .env  (na raiz do projeto)            │
   │ 4. application.properties  (%profile.)   │
   │ 5. application.properties  (default)     │
   │ 6. Sources customizados / defaults @WithDefault │
   └──────────────────────────────────────────┘
   menor prioridade
```

Resumo prático:
- Em **dev**: edita `application.properties`
- Em **prod**: passa env var
- Pra **debug pontual**: `-Dapp.x=y` na linha de comando ganha de tudo

## 🛠️ ConfigSource customizado (visão rápida)

Se a config tem que vir de um lugar exótico (Vault, AWS Parameter Store, banco, API), você implementa:

```java
public class MeuConfigSource implements ConfigSource {
    public String getValue(String name) { /* busca em qualquer lugar */ }
    public String getName() { return "MeuSource"; }
    public int getOrdinal() { return 275; } // maior = mais prioridade
    public Set<String> getPropertyNames() { /* opcional */ return Set.of(); }
}
```

Registra via SPI em `META-INF/services/org.eclipse.microprofile.config.spi.ConfigSource`.

Na prática, pra Vault/AWS você já tem extensões prontas (`quarkus-vault`, `quarkus-config-consul`) — não precisa escrever do zero. Saber que **existe** já é suficiente neste momento.

## 💡 Detalhes que valem ouro
- **App não sobe** se uma `@ConfigProperty` sem `defaultValue` não for encontrada. Erro vem **no boot**, não em runtime — bom.
- `@ConfigMapping` **valida tudo no boot** também. Se faltar `app.email.remetente`, falha já no startup.
- `quarkus dev` mostra a config efetiva em http://localhost:8080/q/dev → "Configuration".
- Pra ver uma chave específica: `quarkus dev` + Dev UI, ou `curl localhost:8080/q/info` (se a extensão `info` estiver ativa).
- Não cometa o erro de comitar `application.properties` com **secrets**. Use env vars / Vault.
- `%dev.` e env var ao mesmo tempo: env vence (precedência 2 > 4).
- `application.yaml` e `application.properties` podem coexistir; `.properties` ganha empate.
- `@ConfigMapping` exige a extensão `quarkus-config-yaml` apenas se você for usar YAML; o mapping em si é nativo.

## 🚦 Próximos passos
1. Veja `pratica/` — vamos montar um `EmailService` e um `StatusResource`
2. Rode `quarkus dev` e observe a config no `/q/dev`
3. Suba o JAR e teste override via `APP_EMAIL_REMETENTE=...`
4. Encare o desafio: criar um `LimitesConfig` tipado pra rate-limiting

## ✅ Auto-verificação
- [ ] Sei usar `@ConfigProperty` com `defaultValue`
- [ ] Sei criar uma interface `@ConfigMapping` com tipos aninhados
- [ ] Sei mapear `app.x.y` ↔ `APP_X_Y`
- [ ] Lembro a ordem: env > .properties profile > .properties default
- [ ] Sei o que é (e quando NÃO precisa) `ConfigSource` custom

Próximo módulo: **Panache JPA** — persistência idiomática em Quarkus.
