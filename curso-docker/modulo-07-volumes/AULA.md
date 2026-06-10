# Módulo 07 — Volumes

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que containers **perdem dados** quando removidos
- Diferenciar os 3 tipos de armazenamento: **bind mount**, **named volume**, **tmpfs**
- Persistir dados de um banco (Postgres) entre execuções
- Usar `docker volume` para gerenciar volumes (criar, listar, inspecionar, remover)
- Escolher o tipo certo pra cada situação

## 💾 Por que volumes existem?

Container é **efêmero** (descartável, de vida curta). Tudo que você grava no sistema de arquivos dele **some** quando você remove o container.

Imagine:
```bash
docker run --name banco postgres:16
# ... insere 10 mil registros ...
docker rm banco
# 💀 todos os dados sumiram
```

Pra problemas reais a gente precisa que os dados **sobrevivam** ao container. É aí que entram os **volumes** — pedaços de disco da máquina hospedeira (host) que são "plugados" dentro do container.

## 🧱 Os 3 tipos de armazenamento

### 1. Bind mount — "monta uma pasta do meu PC dentro do container"

Você indica um caminho real do seu computador e o Docker liga ele a uma pasta do container.

```bash
docker run -v /caminho/no/host:/caminho/no/container imagem
# No Windows PowerShell:
docker run -v ${PWD}/dados:/var/lib/postgresql/data postgres:16
```

- ✅ Ótimo pra **desenvolvimento** (hot-reload — editar código no editor e o container ver)
- ✅ Você vê os arquivos direto no Explorer/Finder
- ❌ Acoplado ao caminho da máquina (não portável)
- ❌ Pode ter problemas de permissão no Linux

### 2. Named volume — "Docker, cuida disso pra mim"

Você dá um **nome** e o Docker cria/guarda numa pasta interna que ele gerencia.

```bash
docker volume create dados-postgres
docker run -v dados-postgres:/var/lib/postgresql/data postgres:16
```

- ✅ **Recomendado pra produção** (banco de dados, principalmente)
- ✅ Portável (não depende de caminho local)
- ✅ Docker gerencia permissões e localização
- ❌ Você não acessa os arquivos "à mão" tão fácil

### 3. tmpfs — "guarda em memória RAM, não no disco"

Sumiu o container, sumiu o dado (não persiste). Mas é **rápido** e seguro pra coisas sensíveis.

```bash
docker run --tmpfs /tmp:size=64m alpine
```

- ✅ Performance (RAM > disco)
- ✅ Segurança (segredos temporários que não devem tocar o disco)
- ❌ Não persiste — quando o container para, o dado some
- ❌ Limitado pelo tamanho da RAM

---

## ⚙️ Comandos `docker volume`

| Comando | O que faz |
|---|---|
| `docker volume create NOME` | Cria um named volume |
| `docker volume ls` | Lista todos os volumes |
| `docker volume inspect NOME` | Mostra onde o volume está no host + metadados |
| `docker volume rm NOME` | Remove um volume (precisa estar sem uso) |
| `docker volume prune` | Remove TODOS volumes não usados (cuidado!) |

```bash
docker volume create meus-dados
docker volume ls
docker volume inspect meus-dados
# Vai mostrar algo como:
# "Mountpoint": "/var/lib/docker/volumes/meus-dados/_data"
```

---

## 🧩 Sintaxe `-v` vs `--mount`

Tem duas formas de montar — fazem a mesma coisa, sintaxe diferente:

```bash
# Forma curta (-v) — mais comum
docker run -v meu-volume:/dados imagem

# Forma longa (--mount) — mais explícita, recomendada em scripts
docker run --mount type=volume,src=meu-volume,dst=/dados imagem
docker run --mount type=bind,src=/host/path,dst=/container/path imagem
docker run --mount type=tmpfs,dst=/tmp imagem
```

Use `--mount` quando quiser que fique **óbvio no script** qual o tipo. Use `-v` quando for digitar rápido.

---

## 📦 VOLUME no Dockerfile

Você pode declarar no próprio Dockerfile que um diretório **deve** ser um volume:

```dockerfile
FROM postgres:16
VOLUME /var/lib/postgresql/data
```

Isso garante que aquele caminho sempre será montado como volume — se o usuário não passar `-v`, o Docker cria um **volume anônimo** (nome aleatório) automaticamente.

A imagem oficial do Postgres já faz isso por você.

---

## 🤔 Quando usar cada tipo?

| Situação | Tipo recomendado |
|---|---|
| Dados de banco em produção | **Named volume** |
| Código-fonte durante desenvolvimento (hot-reload) | **Bind mount** |
| Configs/segredos temporários | **tmpfs** |
| Logs que precisam ser lidos pelo host | **Bind mount** |
| Cache de build/dependências | **Named volume** |
| Inicializar banco com um SQL de schema | **Bind mount** (read-only) |

---

## 💡 Detalhes que economizam tempo

- **Volume não é backup**: se você apagar o volume, dados vão embora junto. Faça `pg_dump` periódico em produção.
- **`:ro` deixa read-only**: `-v config:/etc/conf:ro` — o container não consegue escrever.
- **Removeu container, volume continua**: `docker rm` NÃO mexe nos volumes. Use `docker rm -v` se quiser remover ambos.
- **Volume anônimo vira lixo**: se você não dá nome, o Docker cria um com hash. Use `docker volume prune` de vez em quando.
- **Windows + bind mount**: caminhos do PowerShell precisam `${PWD}` (não `$(pwd)`). E o Docker Desktop precisa ter o drive compartilhado.
- **Postgres usa `/var/lib/postgresql/data`**: é onde a imagem oficial guarda os dados. Sempre monte o volume aí.

---

## 🚦 Próximos passos
1. Faça a prática (`pratica/comandos.sh`) — vai usar named volume com Postgres
2. Faça o desafio (`desafio/comandos.sh`) — carregar schema e provar a persistência
3. Vá pro Módulo 08 — **Networks** (como containers conversam entre si)

## ✅ Auto-verificação
- [ ] Explico em uma frase por que volumes existem
- [ ] Sei diferenciar named volume de bind mount
- [ ] Sei quando usar tmpfs
- [ ] Consigo rodar Postgres com dados que sobrevivem ao `docker rm`
- [ ] Conheço pelo menos 4 comandos do `docker volume`

Próximo módulo: **Networks** — colocando containers pra conversar.
