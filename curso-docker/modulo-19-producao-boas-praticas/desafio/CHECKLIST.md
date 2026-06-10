# 🎯 Desafio — Transformar DEV em PROD usando o Checklist

## 🧩 Cenário

Você herdou de um colega o `Dockerfile` e o `docker-compose.yml` desta pasta — eles funcionam em DEV, mas estão **cheios de problemas de produção**. Seu papel é virar a chave: revisar item por item do checklist e corrigir.

## 📋 Como fazer o desafio

1. **Leia** o `Dockerfile` e o `docker-compose.yml` desta pasta — ambos tem TODOs marcando os pontos a corrigir.
2. **Antes de mexer**, marque mentalmente cada item da lista abaixo: o arquivo atual passa ou falha?
3. **Edite os dois arquivos** aplicando as correções.
4. **Compare** com a solução de referência no fim do `Dockerfile` (`/* ... */`) e do compose (`# SOLUTION ... # SOLUTION`).

> Objetivo: deixar AMBOS arquivos passando em todos os itens do checklist.

---

## ✅ Checklist a aplicar

### 🔨 Build (no `Dockerfile`)
- [ ] **C1.** `FROM` com versão fixa (não `latest`)
- [ ] **C2.** Imagem base mínima (alpine/distroless)
- [ ] **C3.** Multi-stage build (build separado do runtime)
- [ ] **C4.** `WORKDIR` definido (não rodando em `/`)
- [ ] **C5.** Manifest copiado ANTES do código (cache de deps funciona)
- [ ] **C6.** Install determinístico (`npm ci`, não `npm install`)
- [ ] **C7.** Sem cache de gerenciador de pacotes na imagem final (`--no-cache`, `npm cache clean`, `rm -rf /var/lib/apt/lists/*`)
- [ ] **C8.** Apenas dependências de produção no runtime (`--omit=dev`)
- [ ] **C9.** `.dockerignore` existe e cobre `.git`, `node_modules`, `*.env`, `dist`

### 🔒 Segurança (no `Dockerfile`)
- [ ] **S1.** `USER` non-root definido (UID alto, ex 10001)
- [ ] **S2.** Sem secrets hardcoded (sem `ENV API_KEY=...`, sem `ENV DB_PASSWORD=...`)
- [ ] **S3.** Sem `sudo`/`setuid`/chaves no filesystem da imagem
- [ ] **S4.** Arquivos copiados com `--chown` correto (não precisa `chown -R` depois)

### 🏃 Runtime (no `Dockerfile` + `docker-compose.yml`)
- [ ] **R1.** `HEALTHCHECK` definido
- [ ] **R2.** `CMD` em forma exec (`["node", "x"]`), não `CMD node x` (shell)
- [ ] **R3.** PID 1 correto — `tini` no Dockerfile OU `init: true` no compose
- [ ] **R4.** `restart: unless-stopped` ou `on-failure` (não `always` sem critério)
- [ ] **R5.** Limites de recurso (`deploy.resources.limits` ou `mem_limit`/`cpus`)
- [ ] **R6.** `read_only: true` + `tmpfs` pra `/tmp`
- [ ] **R7.** `cap_drop: [ALL]` + `security_opt: [no-new-privileges:true]`
- [ ] **R8.** Logs estruturados pra `stdout` (sem `> /app/log.txt` no CMD)
- [ ] **R9.** Logging driver com rotação (`max-size`, `max-file`)

### 📦 Compose / Deploy (no `docker-compose.yml`)
- [ ] **D1.** `image:` com tag imutável (SHA ou semver), não `:latest`
- [ ] **D2.** Sem `build:` no compose de produção (usar imagem do registry)
- [ ] **D3.** Sem volume montando código-fonte (`./src:/app` é de DEV)
- [ ] **D4.** Secrets via `secrets:` (não `environment: DB_PASSWORD=...`)
- [ ] **D5.** Dados persistentes em volume nomeado
- [ ] **D6.** Network do banco com `internal: true` (sem rota pra internet)
- [ ] **D7.** Portas: só expor o necessário (banco NÃO precisa de `5432:5432`)
- [ ] **D8.** `depends_on` com `condition: service_healthy` quando faz sentido

---

## 🧪 Como validar

Depois de aplicar, rode:

```bash
# 1. Build sem erro
docker build -t desafio-19:prod .

# 2. Imagem ficou pequena?
docker images desafio-19:prod

# 3. Não roda como root?
docker run --rm --entrypoint /bin/sh desafio-19:prod -c 'id'

# 4. Sem secret no history?
docker history --no-trunc desafio-19:prod | grep -i -E 'password|api_key|secret' && echo "VAZOU!" || echo "OK"

# 5. Compose sobe sem erro?
export APP_VERSION=prod
mkdir -p secrets && echo "trocar" > secrets/db_password.txt
docker compose up -d
docker compose ps     # status: healthy?
```

---

## 🏆 Critério de aprovação

- Todos os 26 itens marcados
- `docker history` NÃO mostra secret
- Container fica `healthy` em < 30s
- `docker stats` mostra limite de memória respeitado
- `docker compose exec api whoami` retorna `appuser` (não `root`)

Se passou em tudo: parabéns, você acabou de revisar um stack como um SRE faria. Vá pro Módulo 20.
