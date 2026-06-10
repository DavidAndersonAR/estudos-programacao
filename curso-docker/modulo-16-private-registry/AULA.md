# Módulo 16 — Private Registry

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que uma empresa precisa de **registry privado**
- Rodar seu próprio registry local com `registry:2`
- Publicar imagens no **GitHub Container Registry (ghcr.io)**
- Conhecer as opções de cloud (ECR, GCR, ACR) e self-hosted (Harbor, Quay)
- Fazer `docker login` em qualquer registry custom e `retag + push`

---

## 🤔 Por que um registry privado?

Até agora você usou o **Docker Hub** (público). Funciona, mas tem limites pra projetos sérios:

1. **Controle de acesso** — sua imagem com código proprietário NÃO pode ficar pública. Pessoas vão ler segredos, configs, lógica de negócio.
2. **Compliance / LGPD** — muitas empresas precisam manter artefatos *dentro* da própria infraestrutura (banco, governo, saúde).
3. **Latência e custo de banda** — baixar imagem de 800MB do outro lado do mundo, 50x por deploy, é lento e cobra egress. Registry no mesmo datacenter resolve.
4. **Rate limit** — o Docker Hub limita pulls anônimos (100 a cada 6h por IP). Em CI/CD agressivo você bate o teto rápido.
5. **Auditoria** — quem fez push do quê, e quando? Registry corporativo registra tudo.

Resumo: registry privado = imagens internas seguras, rápidas e auditáveis.

---

## 🧱 As opções principais

### 1. Registry oficial (self-hosted) — `registry:2`

A própria Docker mantém uma imagem chamada `registry:2`. Você roda como container e tem um registry funcional em segundos.

```bash
docker run -d -p 5000:5000 --name meu-registry registry:2
```

Pronto. Agora `localhost:5000` é um registry. Ideal pra:
- Testes locais
- CI interno simples
- Caching de imagens públicas (modo *pull-through cache*)

Sem autenticação por padrão — você adiciona depois (veremos no desafio com **htpasswd**).

### 2. GitHub Container Registry — `ghcr.io`

Grátis pra repos públicos, generoso pra privados. Integra com GitHub Actions naturalmente.

Autenticação via **Personal Access Token (PAT)** com escopo `write:packages`:

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u SEU_USUARIO --password-stdin
docker tag minha-app ghcr.io/SEU_USUARIO/minha-app:v1
docker push ghcr.io/SEU_USUARIO/minha-app:v1
```

### 3. GitLab Container Registry

Vem embutido em cada projeto GitLab (`registry.gitlab.com/grupo/projeto`). Mesma ideia — login com token, push.

### 4. Docker Hub privado

Docker Hub permite repositórios **privados**, mas o plano gratuito limita a 1. Planos pagos (Pro/Team) liberam mais.

### 5. Registries de cloud

| Cloud | Serviço | Endpoint típico |
|---|---|---|
| AWS | **ECR** (Elastic Container Registry) | `123456.dkr.ecr.us-east-1.amazonaws.com` |
| Google | **Artifact Registry** (ex-GCR) | `us-central1-docker.pkg.dev/projeto/repo` |
| Azure | **ACR** (Azure Container Registry) | `meuacr.azurecr.io` |

Vantagem: integração nativa com IAM da cloud (sem PAT, usa role/credencial da máquina). É o padrão pra quem já vive na cloud.

### 6. Self-hosted enterprise — Harbor e Quay

Pra empresa grande que precisa rodar registry **dentro** da própria infra com features avançadas:

- **Harbor** (CNCF) — UI bonita, scan de vulnerabilidade (Trivy embutido), replicação, RBAC, assinatura de imagens. Padrão de fato em on-premise.
- **Quay** (Red Hat) — concorrente do Harbor, vem com OpenShift.

---

## 🔁 O fluxo: retag e push

Toda imagem no Docker tem o formato:

```
[REGISTRY/]USUARIO/IMAGEM:TAG
```

Quando o registry é omitido, o Docker assume `docker.io` (Docker Hub). Pra mandar pra outro lugar, você **retagueia** com o endpoint na frente:

```bash
# Você buildou local:
docker build -t minha-app:v1 .

# Retag pra ghcr:
docker tag minha-app:v1 ghcr.io/davidanderson/minha-app:v1

# Login (uma vez):
docker login ghcr.io

# Push:
docker push ghcr.io/davidanderson/minha-app:v1
```

A imagem física é a mesma — só ganhou um *apelido* apontando pro registry de destino.

---

## 🔑 `docker login` em registry custom

```bash
docker login REGISTRY [-u USUARIO] [--password-stdin]
```

Exemplos:
```bash
docker login                           # Docker Hub (padrão)
docker login ghcr.io                   # GitHub
docker login registry.gitlab.com       # GitLab
docker login localhost:5000            # seu registry local
docker login meuacr.azurecr.io         # Azure ACR
```

As credenciais ficam em `~/.docker/config.json` (no Windows: `%USERPROFILE%\.docker\config.json`). Em produção, prefira `--password-stdin` e **NUNCA** cole token na linha de comando (vai pro histórico do shell).

---

## 🌐 API HTTP do registry

O `registry:2` expõe uma API REST simples (especificação **OCI Distribution Spec**). Útil pra inspecionar sem `docker` na mão:

```bash
curl http://localhost:5000/v2/_catalog
# {"repositories":["minha-app","alpine"]}

curl http://localhost:5000/v2/minha-app/tags/list
# {"name":"minha-app","tags":["v1","v2"]}
```

Toda registry compatível com Docker fala essa API por baixo dos panos.

---

## 💡 Detalhes que economizam tempo

- **HTTPS é obrigatório por padrão**. Pra usar HTTP (registry local sem TLS), adicione em `daemon.json`:
  ```json
  { "insecure-registries": ["meu-host:5000"] }
  ```
  e reinicie o Docker. `localhost:5000` já é considerado inseguro/permitido por padrão.
- **Tag `latest` é uma armadilha em registry privado também** — sempre use versão fixa (SHA do commit, semver, build number).
- **Limpeza**: registry local guarda tudo. Use `docker exec -it meu-registry registry garbage-collect /etc/docker/registry/config.yml` periodicamente.
- **`docker scout`** (novo) faz scan de vulnerabilidade direto da CLI antes de você dar push numa imagem suja.
- **CI/CD**: nunca coloque o token no Dockerfile ou no repo. Use *secrets* do GitHub Actions / GitLab CI / variáveis de ambiente.

---

## 🚦 Próximos passos

1. Rode a prática — registry local + push + pull + API.
2. Faça o desafio — registry local **com autenticação** (htpasswd).
3. Se tiver conta no GitHub, gere um PAT e teste publicar no ghcr.io de verdade.

## ✅ Auto-verificação
- [ ] Sei 3 motivos pra usar registry privado
- [ ] Sei rodar `registry:2` local
- [ ] Sei o formato `REGISTRY/USUARIO/IMAGEM:TAG` e fiz um retag
- [ ] Sei autenticar com PAT no ghcr.io
- [ ] Conheço pelo menos 2 opções de cloud e 1 self-hosted enterprise

Próximo módulo: **CI/CD com Docker** — agora que você sabe publicar, vamos automatizar.
