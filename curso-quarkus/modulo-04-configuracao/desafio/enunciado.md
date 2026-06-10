# 🎯 Desafio do Módulo 04 — Config tipada de rate-limiting

## Contexto
Sua API precisa de **rate-limiting** configurável. Os parâmetros mudam por ambiente:
- Em **dev** você quer limites folgados pra testar à vontade.
- Em **prod** os valores devem vir de **variáveis de ambiente** (operação ajusta sem rebuild).

Você vai criar uma interface `@ConfigMapping` chamada `LimitesConfig` com **4 propriedades aninhadas**.

## Requisitos

### 1. Estrutura da config
Prefixo: `limites`. Estrutura:

```
limites
├── requisicoes
│   ├── por-minuto        (int)
│   └── por-dia           (int)
└── tamanho
    ├── max-payload-kb    (int)
    └── max-headers       (int)
```

### 2. Defaults (em `application.properties`, sem profile)
```properties
limites.requisicoes.por-minuto=60
limites.requisicoes.por-dia=10000
limites.tamanho.max-payload-kb=512
limites.tamanho.max-headers=50
```

### 3. Profile `%dev.` mais folgado
- 600 requisições/minuto
- 1.000.000 requisições/dia
- payload de 4096 KB

### 4. Endpoint `GET /limites`
Retorna JSON com os 4 valores efetivos.

### 5. Override em prod via env var
Buildar (`./mvnw package`), rodar com:

```bash
LIMITES_REQUISICOES_POR_MINUTO=30 \
LIMITES_TAMANHO_MAX_PAYLOAD_KB=128 \
java -jar target/quarkus-app/quarkus-run.jar
```

E confirmar via `curl /limites` que os dois valores mudaram (os outros 2 mantêm o default).

## Critérios de pronto
- [ ] Interface `LimitesConfig` com 2 sub-interfaces (`Requisicoes`, `Tamanho`)
- [ ] Sem `@ConfigProperty` solto — tudo via `@ConfigMapping`
- [ ] `application.properties` com defaults + bloco `%dev.`
- [ ] `GET /limites` funciona em dev mostrando valores de dev
- [ ] Build em prod respeita env vars

## 💡 Dicas
- `assuntoPadrao()` em Java vira `assunto-padrao` no properties. Idem aqui: `porMinuto()` → `por-minuto`.
- Pra defaults dentro do mapping, use `@io.smallrye.config.WithDefault("60")`.
- Mapeamento env → properties: troca `.` e `-` por `_` e bota maiúscula. `limites.requisicoes.por-minuto` ↔ `LIMITES_REQUISICOES_POR_MINUTO`.
- A app **não sobe** se a interface bater com config faltando. É um recurso, não um bug.

## Bônus (se sobrar fôlego)
- Adicione `limites.bloqueio-duracao` do tipo `java.time.Duration` (`PT5M` = 5 minutos) e mostre em `/limites`.
- Faça um `@PostConstruct` no endpoint logar os limites no startup.

Veja `LimitesConfig.java.solucao`, `application.properties.solucao` e `LimitesResource.java.solucao` se travar.
