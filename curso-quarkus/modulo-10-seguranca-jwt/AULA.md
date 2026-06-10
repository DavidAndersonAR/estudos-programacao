# Módulo 10 — Segurança com JWT

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender a anatomia de um **JWT** (header.payload.signature)
- Escolher entre **RSA** e **HS256** (e saber por que Quarkus usa RSA por padrão)
- Gerar par de chaves com `openssl` e configurar `mp.jwt.verify.publickey.location`
- Proteger endpoints com `@RolesAllowed`, `@PermitAll`, `@Authenticated`
- Ler claims (`sub`, `groups`, custom) injetando `JsonWebToken`
- Emitir tokens com `quarkus-smallrye-jwt-build` num endpoint de login

## 🤔 O que é JWT?

**JSON Web Token** é uma string com 3 partes separadas por `.`:

```
eyJhbGciOi...   .   eyJzdWIiOi...   .   sP9aLm-Q...
   header              payload          signature
```

- **header** → algoritmo (`RS256`, `HS256`) e tipo
- **payload** → claims (dados): `sub` (subject/usuário), `iss` (issuer/quem emitiu), `exp` (expiration), `groups` (roles no MicroProfile JWT), e o que mais você quiser
- **signature** → assinatura criptográfica do `header.payload`

Quem recebe o token **verifica a assinatura** — se bater, confia no payload sem precisar consultar banco. É **stateless**: o servidor não guarda sessão.

## 🔐 RSA vs HS256

| | HS256 (HMAC) | RS256 (RSA) |
|---|---|---|
| Chave | uma só (secret compartilhado) | par (privada assina, pública verifica) |
| Quem assina | quem tem o secret | só quem tem a privada |
| Quem verifica | precisa do mesmo secret | qualquer um com a pública |
| Bom para | monolito que assina e verifica | microsserviços — auth-service assina, outros só verificam |

**Quarkus + MicroProfile JWT** usam **RS256 por padrão**. Combina com cenário de várias APIs, e a pública pode ficar até num arquivo público sem dor.

## 🔑 Gerando as chaves

Com `openssl` no terminal:

```bash
# privada (NUNCA committar)
openssl genrsa -out privateKey.pem 2048

# pública (essa pode versionar / expor)
openssl rsa -in privateKey.pem -pubout -out publicKey.pem
```

Coloque os dois em `src/main/resources/` (a privada **só em dev** — em prod vem de env/secret manager).

## 📦 Extensões

```bash
quarkus ext add smallrye-jwt smallrye-jwt-build
```

- `quarkus-smallrye-jwt` → valida tokens recebidos
- `quarkus-smallrye-jwt-build` → **emite** tokens (só onde você tem login)

## ⚙️ Configuração

`application.properties`:

```properties
mp.jwt.verify.publickey.location=publicKey.pem
mp.jwt.verify.issuer=https://meusite.dev
smallrye.jwt.sign.key.location=privateKey.pem
quarkus.native.resources.includes=publicKey.pem,privateKey.pem
```

- `verify.publickey.location` → pra **verificar** tokens recebidos
- `verify.issuer` → recusa token com `iss` diferente
- `sign.key.location` → pra **assinar** tokens novos (login)

## 🚧 Protegendo endpoints

```java
import jakarta.annotation.security.RolesAllowed;
import jakarta.annotation.security.PermitAll;
import io.quarkus.security.Authenticated;

@Path("/api")
public class Recurso {

    @GET @Path("/publico") @PermitAll
    public String aberto() { return "qualquer um vê"; }

    @GET @Path("/eu") @Authenticated
    public String logado() { return "qualquer usuário autenticado"; }

    @GET @Path("/admin") @RolesAllowed("admin")
    public String soAdmin() { return "só quem tem groups: [admin]"; }
}
```

- `@PermitAll` → libera (útil quando a classe toda é restrita)
- `@Authenticated` → exige token válido, sem role específica
- `@RolesAllowed("admin")` → exige que `groups` do JWT contenha `admin`

Sem anotação? **Por padrão é público**. Use `quarkus.http.auth.proactive=true` + `@RolesAllowed` consciente.

## 📥 Lendo claims

```java
import org.eclipse.microprofile.jwt.JsonWebToken;
import jakarta.inject.Inject;

@Path("/me")
public class MeResource {

    @Inject JsonWebToken jwt;

    @GET @Authenticated
    public Map<String, Object> eu() {
        return Map.of(
            "usuario", jwt.getName(),          // claim "upn" ou "sub"
            "issuer", jwt.getIssuer(),
            "grupos", jwt.getGroups(),
            "expira", jwt.getExpirationTime(),
            "email", jwt.getClaim("email")     // claim customizado
        );
    }
}
```

## ✍️ Emitindo tokens (login)

```java
import io.smallrye.jwt.build.Jwt;
import java.time.Duration;

@POST @Path("/login") @PermitAll
public String login(Credenciais c) {
    if (!autentica(c)) throw new WebApplicationException(401);
    return Jwt.issuer("https://meusite.dev")
              .upn(c.usuario())
              .groups(Set.of("user", "admin"))
              .claim("email", "x@y.com")
              .expiresIn(Duration.ofHours(1))
              .sign();   // usa smallrye.jwt.sign.key.location
}
```

A chave privada assina. O cliente guarda o token e manda em toda requisição:

```bash
curl -H "Authorization: Bearer eyJhbGc..." http://localhost:8080/me
```

## 🔄 Refresh tokens (só pra mencionar)

Token de acesso curto (15-60min) + refresh token longo (dias) que serve só pra emitir novo access. Quarkus não dá isso pronto — você implementa: tabela de refresh tokens, endpoint `/refresh`, revogação. **Fora do escopo deste módulo**, mas saiba que existe.

## 💡 Detalhes que valem ouro
- **NUNCA committar `privateKey.pem`** — `.gitignore` ele. Em prod, monte via env var (`SMALLRYE_JWT_SIGN_KEY`) ou secret manager (Vault, AWS Secrets Manager, K8s Secret)
- `exp` é **obrigatório** — token sem expiração é bomba relógio
- Em teste use `@TestSecurity(user = "x", roles = "admin")` (do `quarkus-test-security`) em vez de gerar JWT real
- `quarkus.http.auth.policy.*` permite proteger por path no properties, sem anotação
- Dev UI em `/q/dev` tem um gerador de JWT pra colar no header durante testes manuais
- `JsonWebToken#getRawToken()` devolve a string original — útil pra repassar pra outro serviço

## 🚦 Próximos passos
1. `quarkus ext add smallrye-jwt smallrye-jwt-build`
2. Gere `privateKey.pem` e `publicKey.pem` com openssl (script em `pratica/`)
3. Configure `mp.jwt.verify.*` e `smallrye.jwt.sign.key.location`
4. Crie `LoginResource` (emite) e `MeResource` (lê claims)
5. Adicione `AdminResource` com `@RolesAllowed("admin")`
6. Suba (`quarkus dev`), faça login com curl, copie o token, chame `/me`
7. Faça o desafio (API de tarefas com 3 roles)

## ✅ Auto-verificação
- [ ] Sei as 3 partes de um JWT e o que cada uma carrega
- [ ] Sei por que RSA é o default no Quarkus
- [ ] Sei gerar par de chaves com openssl
- [ ] Sei diferenciar `@PermitAll`, `@Authenticated` e `@RolesAllowed`
- [ ] Sei ler claims com `@Inject JsonWebToken`
- [ ] Sei emitir token com `Jwt.issuer(...).upn(...).groups(...).sign()`
- [ ] Entendi por que a private key NÃO vai pro git

Próximo módulo: **OpenAPI e Swagger UI** — documentando sua API de forma automática.
