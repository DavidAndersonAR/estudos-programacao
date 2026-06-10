# Módulo 15 — Segurança

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Rodar containers como **usuário non-root** (e justificar por quê)
- Usar `--read-only` + `tmpfs` pra travar o filesystem
- Aplicar **menor privilégio** com `--cap-drop ALL` e adicionar só o que precisa
- Saber onde NÃO guardar secrets (e onde guardar)
- Scanear imagens com **docker scout**
- Conhecer **rootless docker** e `--security-opt no-new-privileges`

## 🛡️ Por que segurança importa (mesmo em dev)?

Container **não é VM**. Ele compartilha o kernel com o host. Se um atacante escapa do container rodando como **root**, ele é root no **host**. Isso já aconteceu várias vezes (CVEs reais — runc, containerd, etc.).

A boa notícia: 80% dos riscos somem se você seguir um **checklist curto**. É isso que a gente vai ver.

## 👤 1. NUNCA rode como root

Por padrão, container roda como `root` (UID 0). Isso é o **default mais perigoso** do Docker.

**Errado:**
```dockerfile
FROM node:20-alpine
COPY . /app
CMD ["node", "/app/server.js"]
# Roda como root!
```

**Certo:**
```dockerfile
FROM node:20-alpine
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --chown=app:app . .
USER app
CMD ["node", "server.js"]
```

Verificar:
```bash
docker run --rm minha-imagem id
# uid=1000(app) gid=1000(app)  ← bom
# uid=0(root)                  ← ruim
```

Você também pode forçar no `run` mesmo que a imagem não tenha USER:
```bash
docker run --user 1000:1000 nginx
```

## 📛 2. Filesystem somente leitura (`--read-only`)

Se o app não escreve nada, o filesystem **não precisa ser gravável**. Travar isso bloqueia muito ataque (instalar binário, sobrescrever config, persistir backdoor).

```bash
docker run --read-only --tmpfs /tmp meu-app
```

- `--read-only` → tudo é read-only
- `--tmpfs /tmp` → cria área gravável **em memória** em `/tmp` (some quando o container morre)

Se o app precisa escrever em `/var/cache`, adicione mais um `--tmpfs /var/cache`. Use **volume nomeado** só pra dados que precisam persistir.

## 🔐 3. Capabilities — menor privilégio

Linux divide o poder do root em **capabilities** (CAP_NET_ADMIN, CAP_SYS_ADMIN, etc.). Por padrão, Docker dá um conjunto razoável — mas a maioria dos apps **não precisa de nenhuma**.

```bash
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE meu-app
```

- `--cap-drop ALL` → tira tudo
- `--cap-add NET_BIND_SERVICE` → só adiciona o que precisa (ouvir em porta <1024, ex. 80/443)

Apps que ouvem em porta >1024 (3000, 8080) normalmente **não precisam de nenhuma** capability.

## 🚫 4. `--security-opt no-new-privileges`

Bloqueia que processos dentro do container **escalem** privilégio (via `setuid`, `sudo`, etc.):

```bash
docker run --security-opt no-new-privileges meu-app
```

Combine sempre com `USER` non-root. Dá um sanduíche bem fechado.

## 🤫 5. Secrets — onde NÃO colocar

**NUNCA** ponha senha, token, chave em:
- `ENV` no Dockerfile (fica em `docker history`, qualquer um vê)
- `ARG` no build (idem, fica nas layers)
- Imagem em si (mesmo apagando depois — fica na layer anterior)
- Repositório git

**Onde colocar:**
- **Docker Secrets** (com Swarm/Compose): monta em `/run/secrets/NOME`, fica só em memória
- **BuildKit `--mount=type=secret`** durante o build (não vaza pra layer)
- **External secret manager**: Vault, AWS Secrets Manager, GCP Secret Manager
- Em dev: `.env` fora do repositório + `env_file` no compose (NUNCA commitar)

Exemplo BuildKit:
```dockerfile
# syntax=docker/dockerfile:1.7
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm install
```

```bash
docker build --secret id=npm_token,src=$HOME/.npm_token .
```

## 🔍 6. Scan de vulnerabilidades — `docker scout`

Toda imagem tem CVEs. A questão é: você sabe quais?

```bash
docker scout quickview minha-imagem:latest
docker scout cves minha-imagem:latest
docker scout recommendations minha-imagem:latest
```

`recommendations` sugere imagem base melhor (ex.: trocar `node:20` por `node:20-alpine` ou `node:20-slim` corta 90% dos CVEs).

Alternativa: **Trivy** (`aquasec/trivy`) — open source, MUITO bom.

## 🧹 7. Imagens enxutas = menos superfície de ataque

Cada binário extra é potencial vulnerabilidade.

**Evitar nas imagens de produção:**
- `curl`, `wget` (usados em ataques pra baixar payload)
- `sudo` (sem motivo, USER já resolve)
- Compiladores (`gcc`, `make`) — só no estágio de build (multi-stage, Módulo 06)
- Shell interativo? Distroless nem tem shell.

Imagens recomendadas pra prod:
- `*-alpine` (Alpine Linux, ~5MB)
- `*-slim` (Debian slim)
- `gcr.io/distroless/*` (Google distroless — sem shell, sem package manager)

## 🌱 8. Rootless Docker (bônus)

Por padrão o **daemon** do Docker roda como root. **Rootless mode** faz o daemon rodar como seu usuário — se algo escapar, não chega no root do host.

```bash
dockerd-rootless-setuptool.sh install
```

Trade-off: algumas features (porta <1024, alguns drivers de rede) ficam limitadas. Pra dev e CI, é ótimo.

## ✅ Checklist de hardening (cola na parede)

| Item | Como |
|---|---|
| Não rodar como root | `USER appuser` no Dockerfile + `--user` no run |
| Filesystem read-only | `--read-only --tmpfs /tmp` |
| Sem capabilities extras | `--cap-drop ALL --cap-add NET_BIND_SERVICE` |
| Sem escalada | `--security-opt no-new-privileges` |
| Sem secrets em ENV/ARG | Docker Secrets, BuildKit, Vault |
| Scan CVEs | `docker scout cves` (CI) |
| Imagem mínima | alpine, slim, distroless |
| Tag fixa | `nginx:1.27`, nunca `:latest` em prod |
| Sem `curl`/`sudo` na final | multi-stage build |
| Daemon rootless | `dockerd-rootless-setuptool.sh` |

## 💡 Detalhes que economizam tempo (e CVEs)
- **`docker history minha-imagem`** mostra TUDO que está em cada layer — inclusive secret esquecido no `ENV`.
- **`docker inspect`** mostra o `User`, `Cmd`, `ReadonlyRootfs` — bom pra auditar.
- **Compose** tem `read_only: true`, `cap_drop`, `cap_add`, `security_opt`, `user` — tudo igual ao CLI.
- **Kubernetes** chama de `securityContext` (`runAsNonRoot: true`, `readOnlyRootFilesystem: true`, `capabilities.drop`). Os conceitos são os MESMOS.
- **Não confunda**: container "sem root" ≠ daemon "rootless". Você pode (e deve) usar USER non-root mesmo no Docker tradicional.

## 🚦 Próximos passos
1. Faça a **prática**: compare `Dockerfile.inseguro` vs `Dockerfile.seguro`
2. Faça o **desafio**: hardening completo de uma imagem
3. Rode `docker scout cves` em alguma imagem sua de produção — prepare-se pro susto
4. Vá pro Módulo 16

## ✅ Auto-verificação
- [ ] Sei criar usuário non-root no Dockerfile
- [ ] Entendo `--read-only` + `tmpfs`
- [ ] Sei pra que serve `--cap-drop ALL`
- [ ] Sei onde NÃO guardar secrets
- [ ] Rodei `docker scout` em pelo menos uma imagem
- [ ] Sei o que `no-new-privileges` faz

Próximo módulo: **Módulo 16** — seguindo o curso.
