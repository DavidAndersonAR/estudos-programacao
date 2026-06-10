# Módulo 09 — Variáveis de Ambiente

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar **por que** config vem do ambiente e não do código (12-factor)
- Passar envs de 3 formas: `-e`, `--env-file` e `ENV` no Dockerfile
- Diferenciar **ARG** (só build) de **ENV** (build + runtime)
- Substituir variáveis em `CMD`/`ENTRYPOINT` corretamente
- Saber por que **NUNCA** colocar segredo em env crua

## 📜 12-factor: config vem do ambiente

Imagine o mesmo app rodando em **dev**, **staging** e **prod**. Cada ambiente aponta pra um banco diferente, tem nível de log diferente, feature flag diferente. Como fazer?

❌ **Jeito errado**: hardcoded no código
```python
DB_HOST = "prod-db.empresa.com"  # ops, comitado no git
```

❌ **Jeito errado**: um Dockerfile pra cada ambiente
```
Dockerfile.dev, Dockerfile.staging, Dockerfile.prod  # manutenção do inferno
```

✅ **Jeito 12-factor**: **uma imagem só**, config injetada via **variáveis de ambiente** na hora de rodar.

> **Princípio 3 do [12-factor app](https://12factor.net/config)**: *"Store config in the environment"*.
> A mesma imagem que rodou em dev é a que vai pra prod — muda só o ambiente.

Por que isso é poderoso:
- A imagem é **imutável** (build uma vez, roda em qualquer lugar)
- Config nunca vaza pro git
- Trocar config = trocar env, **não rebuildar**
- Funciona igual em Docker, Kubernetes, ECS, Cloud Run, etc.

## 🛠️ As 3 formas de passar envs

### Forma 1: `-e KEY=valor` (flag direta)
```bash
docker run -e LOG_LEVEL=debug -e PORT=3000 minha-app
```
Boa pra **1-2 vars** ou pra **sobrescrever** algo pontualmente.

### Forma 2: `--env-file arquivo.env`
Arquivo `.env`:
```
LOG_LEVEL=debug
PORT=3000
DB_HOST=db.local
```
Comando:
```bash
docker run --env-file .env minha-app
```
Boa pra **várias vars**. Atenção: o `.env` **não vai pro git** (`.gitignore`).

Sintaxe do `.env`:
- `CHAVE=valor` (um por linha)
- **Sem** aspas (Docker não as interpreta)
- **Sem** `export`
- Linhas começando com `#` são comentário

### Forma 3: `ENV` no Dockerfile (default da imagem)
```dockerfile
ENV LOG_LEVEL=info
ENV PORT=8080
```
Define o **valor default** que vai junto na imagem. Quem rodar pode sobrescrever com `-e` ou `--env-file`.

## 🥊 Precedência (quem vence?)

Do **mais fraco** ao **mais forte**:
1. `ENV` no Dockerfile (default)
2. `--env-file`
3. `-e KEY=val` (último ganha)

Ou seja: `-e` sempre vence. Isso permite ter um default sensato na imagem e ajustar pontualmente no run.

## 🧪 ARG vs ENV — o erro clássico

| | **ARG** | **ENV** |
|---|---|---|
| Disponível durante o **build** | ✅ | ✅ |
| Disponível em **runtime** (container rodando) | ❌ | ✅ |
| Definido com | `ARG NOME=val` | `ENV NOME=val` |
| Passado no build com | `--build-arg NOME=val` | (não se passa no build) |
| Sobrescrito no run com | (não dá) | `-e NOME=val` |

Use **ARG** pra coisas que importam só pra construir a imagem (ex: versão a baixar, URL de proxy do build). Use **ENV** pra config que o app precisa **rodando**.

**Padrão útil**: ARG vira ENV.
```dockerfile
ARG APP_VERSION=1.0
ENV APP_VERSION=$APP_VERSION
```
Assim você define a versão **no build** e ela fica disponível **em runtime**.

## 🐚 Shell form vs exec form do CMD

A forma como você escreve `CMD` muda se as variáveis são substituídas:

```dockerfile
# Shell form — usa /bin/sh -c, faz substituição de $VAR
CMD echo "Oi $NOME"

# Exec form — array JSON, NÃO substitui $VAR (passa literal)
CMD ["echo", "Oi $NOME"]   # imprime literal: Oi $NOME
```

**Solução** pra usar exec form com variáveis: chame o shell explicitamente.
```dockerfile
CMD ["sh", "-c", "echo Oi $NOME"]
```

Recomendação: **exec form** quase sempre (recebe sinais corretamente — Ctrl+C funciona). Use `sh -c` quando precisar de expansão.

## ⚠️ Envs NÃO são segredos

Olha isso:
```bash
docker inspect meu-container | grep -A20 "Env"
```
Saída:
```
"Env": [
  "DB_PASSWORD=supersecreto123",
  "API_KEY=sk-abc..."
]
```

**Qualquer um** com acesso ao Docker vê tudo. Envs também aparecem em:
- `docker inspect`
- Logs do orquestrador
- `ps auxe` no host (em alguns casos)
- Crash dumps

**Regra**: env é OK pra **config** (porta, host, log level). **NÃO** pra **segredos** (senha, token, chave). Pra segredos, use:
- Docker **secrets** (Swarm) — Módulo 15
- Kubernetes Secrets
- HashiCorp Vault, AWS Secrets Manager, etc.

## 🎯 Cheat sheet

| Coisa | Como |
|---|---|
| Default na imagem | `ENV CHAVE=val` no Dockerfile |
| Sobrescrever no run | `docker run -e CHAVE=novo` |
| Vários envs de uma vez | `docker run --env-file .env` |
| Repassar do host (sem redefinir) | `docker run -e CHAVE` (sem `=val`) |
| Var só pro build | `ARG CHAVE` + `--build-arg CHAVE=val` |
| Ver envs de um container | `docker inspect CONTAINER` → `Env` |
| Ver de dentro do container | `docker exec CONTAINER env` |

## 💡 Detalhes que economizam tempo
- **`.env` no `.gitignore`, `.env.example` no git**: o exemplo lista as chaves esperadas (sem valores reais), o real fica fora.
- **Caso especial do `docker compose`**: ele lê automaticamente um arquivo `.env` no diretório do `compose.yml` pra interpolar variáveis (`${VAR}`) — é outra mecânica, vemos no Módulo 11.
- **Ordem importa no Dockerfile**: `ENV` definido depois de `RUN` não afeta os RUNs anteriores. Defina ENV cedo se ele influencia o build.
- **Cuidado com aspas no `--env-file`**: `NOME="João"` vira literalmente `NOME` = `"João"` (com aspas). Não use aspas no arquivo.
- **Variável vazia ≠ não definida**: `-e DEBUG=` cria `DEBUG` com valor vazio (string vazia). Use `-e DEBUG` (sem `=`) pra herdar do host.

## 🚦 Próximos passos
1. Faça a **prática** (`pratica/`) — vai brincar com `-e`, `--env-file` e `ENV`
2. Encare o **desafio** (`desafio/`) — config 12-factor com 4 envs
3. Vá pro Módulo 10 — **Networking**

## ✅ Auto-verificação
- [ ] Sei dizer em uma frase por que config vai no ambiente
- [ ] Sei 3 formas de passar env e a precedência entre elas
- [ ] Sei a diferença ARG vs ENV
- [ ] Sei por que `CMD ["echo", "$X"]` não substitui
- [ ] Sei por que **nunca** colocar senha em env crua

Próximo módulo: **Networking** — fazendo containers conversarem entre si.
