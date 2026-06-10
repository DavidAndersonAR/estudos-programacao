# Curso de Docker — do Básico ao Avançado

> Mesmo padrão dos cursos anteriores. 20 módulos progressivos, do primeiro `docker run` até deploy em produção com BuildKit e multi-arch. Você já tem **Docker instalado e funcionando** (verificado).

## Estrutura

Cada módulo tem 3 arquivos:
1. **AULA.md** — teoria condensada com exemplos
2. **pratica/** — comandos e exemplos resolvidos (`comandos.sh` ou `Dockerfile`)
3. **desafio/** — miniprojeto com TODOs e solução comentada

## Ementa

### Fase 1 — Fundamentos
- **01 — Bem-vindo + Setup** — `docker version`, `docker info`, primeiro `hello-world`. 🎯 *Rodar 3 imagens prontas*
- **02 — Primeiro Container** — `run`, `ps`, `stop`, `start`, `rm`, `exec`. 🎯 *Container interativo + execução em background*
- **03 — Imagens e Registry** — `pull`, `images`, `rmi`, `inspect`, Docker Hub. 🎯 *Explorar e usar imagens populares*
- **04 — Dockerfile Básico** — FROM, RUN, COPY, WORKDIR, CMD, ENTRYPOINT. 🎯 *Imagem custom Node simples*
- **05 — Build, Tag, Push** — `build`, `tag`, semantic versioning, login + `push`. 🎯 *Publicar sua primeira imagem*

### Fase 2 — Trabalhando com Containers
- **06 — Camadas e Cache** — como funciona o cache, ordem do Dockerfile. 🎯 *Acelerar build em 10x*
- **07 — Volumes** — bind mount vs named volume vs tmpfs. 🎯 *Persistência de dados*
- **08 — Networks** — bridge, host, custom networks, DNS interno. 🎯 *Containers conversando*
- **09 — Variáveis de Ambiente** — `-e`, `--env-file`, ENV no Dockerfile. 🎯 *Config 12-factor*
- **10 — Logs e Monitoramento** — `logs`, drivers de log, `stats`, `top`. 🎯 *Coletar métricas básicas*

### Fase 3 — Docker Compose
- **11 — Compose Básico** — `docker-compose.yml`, `up`/`down`, services. 🎯 *App + DB em 1 comando*
- **12 — Compose Multi-Serviço** — depends_on, healthchecks, profiles, networks compartilhados. 🎯 *Stack web completa*

### Fase 4 — Produção e Avançado
- **13 — Multi-stage Builds** — várias FROMs, `COPY --from`. 🎯 *Imagem Go enxuta de 12MB*
- **14 — Otimização de Imagem** — alpine, distroless, .dockerignore, ordem do Dockerfile. 🎯 *Reduzir imagem 80%*
- **15 — Segurança** — USER non-root, scan (docker scout), secrets, read-only. 🎯 *Hardening da imagem*
- **16 — Private Registry** — registry local, GitHub Container Registry, autenticação. 🎯 *Publicar em registry privado*
- **17 — Healthcheck e Restart** — HEALTHCHECK, restart policies, init system. 🎯 *Container que se recupera sozinho*
- **18 — Debugging** — `exec`, `logs -f`, `inspect`, `stats`, `cp`. 🎯 *Diagnosticar container com problema*
- **19 — Produção: Boas Práticas** — checklist completo, deploy patterns. 🎯 *Checklist do que NÃO fazer*
- **20 — BuildKit + buildx** — cache avançado, multi-arch (amd64+arm64), secrets em build. 🎯 *Imagem cross-platform com cache mount*

## Pré-requisitos
- **Docker Engine 20+** (você já tem 29.4 ✅)
- **Docker Compose v2+** (você tem v5.1 ✅)
- Conta no Docker Hub (gratuita) para os módulos 5 e 16

## Como rodar os exemplos
Cada módulo tem comandos prontos em `pratica/comandos.sh` (ou `Dockerfile`/`docker-compose.yml`). Você pode:
- Rodar linha por linha no terminal
- Ou dar `bash comandos.sh` (revise antes!)

## Material de apoio
- Docs oficiais: https://docs.docker.com
- Docker Hub: https://hub.docker.com
- Play with Docker (sandbox grátis): https://labs.play-with-docker.com
- Dockerfile reference: https://docs.docker.com/engine/reference/builder/

Bom estudo!
