# Módulo 05 — Build, Tag, Push

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Buildar imagens com `docker build` (incluindo `-t`, `-f`, build context)
- Usar `.dockerignore` pra não vazar lixo na imagem
- Entender a **naming convention** `usuario/imagem:tag` do Docker Hub
- Aplicar **semantic versioning** (1.0.0, 1.0, 1, latest) em imagens
- Criar **aliases** com `docker tag`
- Logar no registry (`docker login`) e publicar (`docker push`)
- Diferenciar namespace **público** vs **privado**
- Tornar builds **reproduzíveis** fixando o `FROM` por SHA

## 🏗️ `docker build` — do Dockerfile à imagem

O ciclo é sempre o mesmo:

```
Dockerfile + arquivos → docker build → imagem local → docker push → registry
```

Forma básica:

```bash
docker build -t minha-app .
```

Quebrando o comando:
- `-t minha-app` — dá um **nome (tag)** pra imagem. Sem isso ela só recebe um ID hexadecimal e fica difícil de referenciar.
- `.` — é o **build context** (mais sobre isso já já). É o diretório atual.

### `-f` — Dockerfile com outro nome ou em outra pasta

Por padrão, `docker build` procura um arquivo chamado `Dockerfile` na raiz do contexto. Se você tem variações (`Dockerfile.dev`, `Dockerfile.prod`):

```bash
docker build -f Dockerfile.prod -t minha-app:prod .
```

### Build context — o que vai pro daemon

Quando você roda `docker build .`, o Docker **empacota o diretório `.` inteiro** e envia pro daemon (motor do Docker). Isso significa:
- Se o seu projeto tem 2GB de `node_modules`, vai mandar 2GB no upload pro daemon (lento e desnecessário).
- Arquivos sensíveis (`.env`, `.git`, chaves) podem acabar dentro da imagem se algum `COPY` pescar.

**Solução**: `.dockerignore`.

## 🚫 `.dockerignore` — o `gitignore` do Docker

Mesma sintaxe do `.gitignore`. Coloca na raiz do contexto:

```
node_modules
.git
.env
*.log
dist
.vscode
*.md
```

Ganhos:
- Build mais rápido (menos arquivo enviado)
- Imagem menor (menos arquivo copiado por engano)
- Mais segurança (chaves não vazam)

Regra prática: comece com `.git`, `node_modules`, `.env*` e adicione conforme for percebendo lixo.

## 🏷️ Naming convention: `usuario/imagem:tag`

Toda imagem completa tem 3 partes:

```
davidanderson / minha-app : 1.0.0
   namespace    nome       tag
```

- **namespace**: seu usuário no Docker Hub (ou organização). Sem isso é considerado **oficial** (só Docker pode publicar — `nginx`, `redis`, `postgres`).
- **nome**: o nome do projeto/app.
- **tag**: a versão. Se omitir, vira `latest`.

Outros registries têm um prefixo a mais:

```
ghcr.io/usuario/imagem:1.0.0           # GitHub Container Registry
gcr.io/projeto/imagem:1.0.0            # Google
123456789.dkr.ecr.us-east-1.amazonaws.com/imagem:1.0.0   # AWS ECR
```

Sem prefixo → Docker Hub (default).

## 📐 Semantic Versioning (semver) em imagens

Convenção amplamente usada: **MAJOR.MINOR.PATCH** (ex: `2.5.3`).
- **MAJOR** muda quando tem quebra de compatibilidade
- **MINOR** muda quando tem feature nova (compatível)
- **PATCH** muda quando é só bugfix

A boa prática é publicar **várias tags apontando pra mesma imagem**, escalonando a especificidade:

| Tag        | Significado                          |
|------------|--------------------------------------|
| `1.0.0`    | exatamente essa versão (imutável)    |
| `1.0`      | última patch da 1.0 (1.0.x mais nova)|
| `1`        | última minor da 1 (1.x.x mais nova)  |
| `latest`   | última versão de tudo (sem garantia) |

Assim, quem quer segurança usa `1.0.0`; quem quer pegar fix automaticamente usa `1.0`; quem só quer testar usa `latest`.

⚠️ **Em produção NUNCA use `latest`** — ela muda sem aviso e quebra deploys.

## 🔁 `docker tag` — apelidos pra mesma imagem

`docker tag` **não cria imagem nova**, só cria um **apelido** (ponteiro) pra uma imagem existente:

```bash
docker tag minha-app:1.0.0 davidanderson/minha-app:1.0.0
docker tag minha-app:1.0.0 davidanderson/minha-app:1.0
docker tag minha-app:1.0.0 davidanderson/minha-app:1
docker tag minha-app:1.0.0 davidanderson/minha-app:latest
```

Agora as 4 tags apontam pro mesmo SHA. Quando publicar, vai mandar a imagem **uma vez** e os 4 ponteiros.

Atalho: dá pra passar várias `-t` direto no `build`:

```bash
docker build \
  -t davidanderson/minha-app:1.0.0 \
  -t davidanderson/minha-app:1.0 \
  -t davidanderson/minha-app:1 \
  -t davidanderson/minha-app:latest \
  .
```

## 🔐 `docker login` — autenticando

Antes de empurrar imagem pra registry, precisa logar:

```bash
docker login                          # Docker Hub (default)
docker login ghcr.io                  # GitHub Container Registry
docker login meu-registry.empresa.com # registry privado interno
```

Vai pedir usuário e senha (ou token — recomendado). No Docker Hub: gere um **Personal Access Token** em *Account Settings → Security* e use como senha. Pode escopar pra read/write/delete.

As credenciais ficam em `~/.docker/config.json` (no Windows: `C:\Users\seu-user\.docker\config.json`).

## 📤 `docker push` — publicando

```bash
docker push davidanderson/minha-app:1.0.0
docker push davidanderson/minha-app:1.0
docker push davidanderson/minha-app:1
docker push davidanderson/minha-app:latest
```

Atalho pra mandar todas as tags do repo de uma vez:

```bash
docker push --all-tags davidanderson/minha-app
```

Como as 4 tags apontam pra mesma imagem, o upload do conteúdo acontece **uma vez** — depois é só registrar os apelidos. Bem rápido.

## 🌐 Público vs Privado

No Docker Hub:
- **Pública**: qualquer um faz `pull` (default na conta free).
- **Privada**: só quem você liberar (conta free: 1 repo privado; conta paga: ilimitado).

Você decide isso no painel do Docker Hub (*Settings → Visibility*) ou ao criar o repo.

Para CI/CD ou empresas, normalmente se usa:
- **GHCR** (gratuito, integrado ao GitHub) — `ghcr.io/usuario/imagem`
- **AWS ECR** — privado, integrado ao IAM
- **Harbor / Nexus / Artifactory** — self-hosted em empresas grandes

## 🔒 Builds reproduzíveis (FROM com SHA)

Problema: `FROM nginx:alpine` parece fixo, mas a tag `alpine` da nginx é **mutável** — eles republicam toda semana. Hoje você builda e funciona; amanhã puxa e o `nginx:alpine` é outra coisa.

Solução: fixar pelo **digest** (SHA256 imutável):

```dockerfile
FROM nginx:alpine@sha256:6c1f08fe5d12dc...e91e
```

Você pega o digest assim:

```bash
docker pull nginx:alpine
docker inspect --format='{{index .RepoDigests 0}}' nginx:alpine
```

Para builds 100% reproduzíveis (mesmo input → mesma imagem byte a byte), use SHA no `FROM` + lockfiles do gerenciador de pacotes (`package-lock.json`, `go.sum`, `Pipfile.lock`).

Em produção crítica, isso é regra. Em projeto pessoal, dá pra começar com tag de versão (`nginx:1.27-alpine`).

## 🎯 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `docker build -t nome .` | Builda imagem com tag a partir do diretório atual |
| `docker build -f Arquivo -t nome .` | Builda usando Dockerfile com outro nome |
| `docker build -t a -t b -t c .` | Builda e marca com várias tags de uma vez |
| `docker tag origem destino` | Cria apelido pra uma imagem existente |
| `docker login [registry]` | Loga no registry (Docker Hub se omitir) |
| `docker logout [registry]` | Desloga |
| `docker push usuario/imagem:tag` | Publica uma tag específica |
| `docker push --all-tags usuario/imagem` | Publica todas as tags do repo |
| `docker pull usuario/imagem:tag` | Baixa do registry |
| `docker inspect imagem` | Vê metadados, incluindo digest |

## 💡 Detalhes que economizam tempo

- **`-t` é obrigatório na prática**: sem nome, você só consegue referenciar a imagem pelo ID hexadecimal. Sempre marca.
- **Tag `latest` é convenção, não regra**: o Docker não trata `latest` de forma especial; só é o default quando você não passa tag.
- **Mesma imagem com várias tags = 1 upload**: o registry guarda por digest, não por tag.
- **Repo deve existir antes de pushar?** No Docker Hub não — o primeiro push cria automaticamente (público por padrão).
- **Nome do repo vs nome local**: a imagem `minha-app:1.0.0` (sem namespace) só existe localmente. Pra pushar, **precisa** ter namespace (`usuario/minha-app:1.0.0`) — daí o `docker tag`.
- **`docker push` falhando com `denied: requested access...`**: ou você não tá logado, ou o namespace não bate com seu usuário.
- **CI/CD nunca usa `docker login` interativo**: usa `echo $TOKEN | docker login -u user --password-stdin`.

## 🚦 Próximos passos
1. Crie sua conta no Docker Hub (se ainda não tem)
2. Gere um Personal Access Token
3. Faça a prática (publica nginx customizado)
4. Faça o desafio (publica sua própria imagem com 3 tags)
5. Vá pro Módulo 06 — onde a gente otimiza imagens com cache e multi-stage builds

## ✅ Auto-verificação
- [ ] Sei buildar com `-t` e por que o `.` aparece no final
- [ ] Sei explicar `.dockerignore` em uma frase
- [ ] Entendo a convenção `usuario/imagem:tag`
- [ ] Sei aplicar semver com 4 tags (1.0.0, 1.0, 1, latest)
- [ ] Sei a diferença entre `docker tag` e `docker build -t`
- [ ] Consegui logar no Docker Hub
- [ ] Sei por que `FROM com SHA` deixa o build reproduzível

Próximo módulo: **Otimização de imagem** — cache de layers, multi-stage builds, imagens minúsculas.
