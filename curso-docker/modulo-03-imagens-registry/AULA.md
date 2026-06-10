# Módulo 03 — Imagens e Registry

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é uma **imagem** e por que ela é feita de **layers**
- Baixar imagens com `docker pull` (por tag ou por digest)
- Listar, filtrar e formatar imagens locais com `docker images`
- Inspecionar metadados e camadas com `docker inspect` e `docker history`
- Entender tags, versionamento e por que `latest` é cilada em produção
- Limpar imagens com `docker rmi` e `docker image prune`
- Saber o que é Docker Hub, imagens oficiais, slim/alpine e digests imutáveis

## 🧱 O que é uma imagem (de verdade)?

Uma imagem Docker é um **empilhamento de camadas read-only** (layers). Cada camada é um snapshot de mudanças no sistema de arquivos — instalar um pacote, copiar um arquivo, mudar uma config — e fica congelada pra sempre.

```
┌──────────────────────────┐  ← camada do seu app (read-only)
├──────────────────────────┤  ← camada com dependências (read-only)
├──────────────────────────┤  ← camada do runtime (Node, Python...) (read-only)
└──────────────────────────┘  ← camada base (Alpine, Debian...) (read-only)

       Container (writable layer no topo)  ← criada quando você dá `docker run`
```

Por que isso importa?
- **Cache**: se a camada do runtime não mudou, Docker reaproveita ela em todos os builds. Muito mais rápido.
- **Compartilhamento**: duas imagens que usam `alpine:3.20` como base **dividem a mesma layer** no disco. Não duplica.
- **Imutabilidade**: a imagem é o mesmo bit a bit em qualquer lugar. Reprodutibilidade garantida.

## ⬇️ `docker pull` — baixando imagens

```bash
docker pull nginx              # baixa nginx:latest (cuidado!)
docker pull nginx:1.27-alpine  # baixa tag específica — melhor
docker pull nginx@sha256:abc...  # baixa pelo digest — imutável, garantido
```

O pull baixa **só as camadas que faltam**. Se você já tem `alpine:3.20` e baixa outra imagem que usa essa base, ele pula a camada compartilhada.

## 📋 `docker images` — listar com filtro e formato

```bash
docker images                            # lista tudo
docker images nginx                      # só nginx
docker images --filter "dangling=true"   # imagens órfãs (sem tag)
docker images --filter "reference=*:alpine"  # só tags alpine
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
docker images --format "{{.Repository}}:{{.Tag}} - {{.Size}}"
```

`--format` usa **Go templates** (mesma sintaxe que você já conhece). Útil pra script.

## 🔍 `docker inspect` — metadados da imagem

```bash
docker inspect nginx:1.27-alpine
docker inspect --format '{{.Config.ExposedPorts}}' nginx
docker inspect --format '{{.Config.Env}}' postgres:16
docker inspect --format '{{.RootFS.Layers}}' alpine  # lista os SHAs das camadas
```

Retorna JSON gigante com **tudo**: env vars, portas expostas, comando padrão, layers, autor, data de build, arquitetura, digest...

`docker history IMAGEM` mostra **como cada camada foi criada** (útil pra entender o tamanho da imagem):

```bash
docker history nginx:1.27-alpine
```

## 🏷️ Tags e versionamento — por que `latest` é cilada

Uma imagem tem formato: `REPOSITORIO:TAG`. Sem tag, Docker assume `:latest`.

```bash
nginx                  # = nginx:latest
nginx:1.27             # versão major.minor
nginx:1.27.3           # versão exata
nginx:1.27-alpine      # variante alpine
nginx:stable-perl      # variante com perl
```

**Por que NUNCA `latest` em produção?**
- `latest` é só uma tag — o mantenedor pode mover ela pra qualquer versão a qualquer momento
- Hoje você sobe `nginx:latest` = `1.27`. Amanhã pode virar `2.0` (breaking change) sem aviso
- Deploy "estável" vira loteria: cada `docker pull` pode trazer algo diferente
- Em prod: **fixe a versão** (`nginx:1.27.3`) ou — melhor ainda — **fixe o digest** (`nginx@sha256:...`)

## 🆔 Manifest e digest — o SHA256 imutável

Cada imagem tem um **digest** SHA256 que identifica o conteúdo exato:

```
nginx:1.27-alpine@sha256:a1b2c3d4...
```

- Tags são **mutáveis** (mantenedor pode mover)
- Digests são **imutáveis** (mudou um bit, mudou o SHA)
- Em produção crítica (e CI/CD reprodutível), referencie pelo digest

```bash
docker inspect --format '{{.RepoDigests}}' nginx:1.27-alpine
docker pull nginx@sha256:a1b2c3d4...
```

O **manifest** é o "índice" da imagem — descreve arquiteturas suportadas (amd64, arm64...) e aponta pros blobs de cada camada. Você quase nunca mexe nele direto.

## 🐳 Docker Hub — oficial vs comunidade

Docker Hub (hub.docker.com) é o registry público padrão. Quando você roda `docker pull nginx`, vem de lá.

Dois tipos importantes:
- **Docker Official Image** — selo azul "Docker Official Image". Mantida em parceria com o time do Docker, auditada, com padrões. Use sempre que possível: `nginx`, `postgres`, `redis`, `python`, `node`, `alpine`...
- **Verified Publisher** — selo de empresa verificada (ex: `bitnami/`, `mongodb/`). Confiável.
- **Comunidade** — qualquer um pode publicar (`fulano/minha-imagem`). Cuidado: pode ter malware, backdoor, ou simplesmente estar abandonada.

Regra: em prod, prefira oficial. Se for comunidade, audite (Dockerfile público? mantida? popular?).

## 🪶 Slim e Alpine — imagens enxutas

Mesma app, tamanhos bem diferentes:

| Tag                  | Tamanho aprox |
|----------------------|---------------|
| `python:3.12`        | ~1.0 GB       |
| `python:3.12-slim`   | ~130 MB       |
| `python:3.12-alpine` | ~50 MB        |

- **slim** = Debian sem ferramentas extras
- **alpine** = Alpine Linux (~5 MB de base, usa musl libc em vez de glibc)

Vantagens de imagens pequenas: pull mais rápido, menos disco, **menor superfície de ataque** (menos pacotes = menos CVEs).

Pegadinha: Alpine usa **musl libc**, não glibc. Algumas libs compiladas (numpy, certos binários Node) podem dar dor de cabeça. Slim costuma ser o meio-termo seguro.

## 🗑️ `docker rmi` e `docker image prune`

```bash
docker rmi nginx:1.27-alpine        # remove uma imagem
docker rmi $(docker images -q)      # remove TODAS (cuidado!)
docker image prune                  # remove imagens órfãs (sem tag, dangling)
docker image prune -a               # remove TUDO que não está em uso por nenhum container
```

Erro comum: `Error response from daemon: conflict: unable to remove repository reference` — significa que algum container (mesmo parado) está usando a imagem. Solução: remover o container antes (`docker rm CONTAINER`), ou usar `docker rmi -f` (força, mas mantém o ID da imagem flutuando).

## 🎯 Cheat sheet

| Comando | O que faz |
|---|---|
| `docker pull IMG:TAG` | Baixa imagem |
| `docker pull IMG@sha256:...` | Baixa pelo digest (imutável) |
| `docker images` | Lista imagens locais |
| `docker images --filter K=V` | Filtra (dangling, reference, before, since) |
| `docker images --format ...` | Formata saída (Go template) |
| `docker inspect IMG` | JSON com metadados completos |
| `docker history IMG` | Mostra camadas e como foram criadas |
| `docker rmi IMG` | Remove imagem |
| `docker image prune` | Remove dangling |
| `docker image prune -a` | Remove tudo não usado |
| `docker tag IMG NOVO:TAG` | Cria apelido (não duplica) |

## 💡 Detalhes que economizam tempo
- **Layers são imutáveis**: se você "edita" um arquivo numa camada acima, o arquivo original continua ocupando espaço na camada de baixo. Por isso `RUN apt-get install && apt-get clean` precisa estar na **mesma camada** (Módulo 06).
- **`docker tag` não duplica**: é só um ponteiro novo pra mesma imagem. Mesmo Image ID.
- **`<none>` em `docker images`**: são camadas órfãs (dangling). Limpe com `docker image prune`.
- **Pull sem internet**: se a imagem já está local, `docker run` não tenta baixar de novo.
- **Multi-arch**: imagens oficiais costumam ter manifests pra amd64, arm64, etc. Docker pega a certa pro seu host automaticamente.
- **Digest != Image ID**: o digest é do *manifest no registry*; o Image ID é o SHA local da config. Ambos são SHA256, mas valores diferentes.

## 🚦 Próximos passos
1. Faça a prática (`pratica/comandos.sh`) — pull, inspect, history, rmi
2. Faça o desafio (`desafio/comandos.sh`) — comparar imagens populares
3. Espie o Docker Hub e procure 1 imagem oficial e 1 da comunidade
4. Vá pro Módulo 04 — **Dockerfile**: construir suas próprias imagens

## ✅ Auto-verificação
- [ ] Sei explicar layers em uma frase
- [ ] Sei a diferença entre tag e digest
- [ ] Sei por que `latest` é problemático em prod
- [ ] Consigo filtrar `docker images` por reference
- [ ] Sei o que é uma Docker Official Image
- [ ] Removi imagens órfãs com `docker image prune`

Próximo módulo: **Dockerfile** — agora você constrói as suas.
