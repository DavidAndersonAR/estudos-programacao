# Módulo 02 — Primeiro Container (pra valer)

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o **ciclo de vida** de um container (criado → rodando → parado → removido)
- Usar as **flags principais** do `docker run` (-it, -d, --name, -p, --rm)
- Entrar num container que já está rodando com `docker exec`
- Diferenciar `docker stop` de `docker kill`
- Listar e filtrar containers com `docker ps --format`
- Remover containers em massa sem dor

## 🔄 O ciclo de vida de um container

Um container passa por estados. Saber quais são evita confusão quando algo "some" ou "trava":

```
            docker run                    docker stop / kill
                ↓                                ↓
         [ CRIADO ] ──── inicia ────→ [ RODANDO ] ────→ [ PARADO ]
                                          ↑                  ↓
                                          └── docker start ──┘
                                                             ↓
                                                       docker rm
                                                             ↓
                                                       [ REMOVIDO ]
```

Pontos-chave:
- **Criado**: existe mas não rodou ainda. Raro ver isso (acontece com `docker create`).
- **Rodando**: tem um processo principal vivo.
- **Parado**: o processo principal morreu (terminou, foi parado, crashou). O container **continua existindo** — aparece em `docker ps -a`, ocupa disco.
- **Removido**: sumiu de vez. Só com `docker rm`.

> ⚠️ Container parado **não é** container removido. Quem aprendeu agora costuma deixar dezenas de containers parados pelo caminho. Cuidado.

## 🚀 `docker run` — as flags que importam

A forma básica é `docker run [FLAGS] IMAGEM [COMANDO]`. As flags fazem toda a diferença:

| Flag | Significado | Quando usar |
|---|---|---|
| `-d` | **detached** (background) | Servidores: nginx, postgres, redis |
| `-it` | **interactive + tty** | Shell interativo: bash, python REPL |
| `--name NOME` | dá nome fixo ao container | Sempre que for usar depois (stop, exec, logs) |
| `-p HOST:CONT` | mapeia porta do host pro container | Toda vez que precisa acessar de fora |
| `--rm` | remove automaticamente ao parar | Execuções pontuais, testes rápidos |
| `-e VAR=valor` | passa variável de ambiente | Configs (senha, debug flag, etc.) |
| `-v PASTA:PASTA` | monta volume | Persistir dados (Módulo 07) |

### Exemplos contrastantes

```bash
# Servidor em background, com nome e porta:
docker run -d --name web -p 8080:80 nginx

# Shell interativo no Alpine, descarta ao sair:
docker run -it --rm alpine sh

# Comando único, descarta ao terminar:
docker run --rm python:alpine python -c "print(2+2)"
```

> 💡 `-it` é na verdade duas flags juntas: `-i` (mantém stdin aberto) + `-t` (aloca um terminal). Quase sempre vão juntas.

## 🚪 `docker exec` — entrando num container que já roda

`docker run` **cria** um container novo. Se você quer entrar num que **já está rodando**, use `docker exec`:

```bash
# Sobe um nginx em background
docker run -d --name web nginx

# Entra dentro dele com um shell
docker exec -it web sh

# Ou roda um comando único sem entrar:
docker exec web ls /etc/nginx
```

Dentro do container você vê os arquivos dele, processos dele, rede dele. Sai com `exit` (o container continua rodando).

> ⚠️ Confusão comum: `docker run -it nginx sh` cria um container **novo** que roda `sh` em vez do nginx — não é o que você quer. Pra investigar um container já no ar, é **exec**.

## ⏹️ `docker stop` vs `docker kill`

Os dois param o container, mas com modos diferentes:

- **`docker stop`**: manda um sinal **SIGTERM** ("por favor, desligue") e dá 10s pro processo terminar com elegância. Se não terminar, manda SIGKILL.
- **`docker kill`**: manda **SIGKILL** direto. Para agora, sem chance de salvar nada.

```bash
docker stop web    # educado, espera o nginx fechar conexões
docker kill web    # bruto, mata na hora
```

Use `stop` por padrão. `kill` só quando o container não responde.

## 📋 `docker ps` com `--format`

Por padrão `docker ps` mostra um monte de colunas. Pra script ou pra ver só o que interessa, use `--format`:

```bash
# Só nome e status:
docker ps --format "{{.Names}}  {{.Status}}"

# Só IDs (útil pra encadear comandos):
docker ps -q

# Tabela customizada:
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```

Outros filtros úteis:
```bash
docker ps -a --filter "status=exited"     # só os parados
docker ps --filter "name=web"             # só os que têm "web" no nome
```

## 🧹 `docker rm` em massa

Remover um por um é tedioso. Algumas formas práticas:

```bash
# Remove um específico:
docker rm meu-container

# Força remoção mesmo se estiver rodando:
docker rm -f meu-container

# Remove TODOS os parados (uso diário):
docker container prune -f

# Remove uma lista por substituição:
docker rm $(docker ps -aq --filter "status=exited")
```

> 💡 `docker ps -q` dá só os IDs. Combinado com `$(...)` vira munição pra `rm`, `stop`, `kill`.

## 🎯 Cheat sheet do módulo

| Comando | O que faz |
|---|---|
| `docker run -d --name X IMG` | Sobe container em background com nome |
| `docker run -it --rm IMG sh` | Shell interativo descartável |
| `docker exec -it X sh` | Entra num container rodando |
| `docker stop X` | Para com graça (SIGTERM) |
| `docker kill X` | Mata na hora (SIGKILL) |
| `docker start X` | Religa container parado |
| `docker restart X` | stop + start |
| `docker logs -f X` | Mostra logs e segue (tipo tail -f) |
| `docker top X` | Lista processos dentro do container |
| `docker rm -f X` | Remove (mesmo rodando) |
| `docker container prune -f` | Remove todos os parados |

## 💡 Detalhes que economizam tempo

- **Nome > ID**: sempre dê `--name`. ID hex é horrível de digitar.
- **`--rm` em testes**: evita acumular lixo. Mas perde os logs depois que o container morre.
- **Porta `-p 8080:80`**: 8080 é a porta **no seu PC**, 80 é **dentro do container**. Inverter é o erro mais comum.
- **`docker run` num container que já existe com mesmo nome falha**: ou use `--rm`, ou remova antes.
- **Quando o container para sozinho**: 99% das vezes é porque o processo principal terminou ou crashou. Veja `docker logs`.
- **Shell em Alpine é `sh`, não `bash`**: Alpine não tem bash por padrão.

## 🚦 Próximos passos
1. Faça a prática (`pratica/comandos.sh`)
2. Faça o desafio (`desafio/comandos.sh`) — Redis na linha
3. Vá pro Módulo 03 — onde a gente fala de **imagens** com profundidade

## ✅ Auto-verificação
- [ ] Sei desenhar o ciclo de vida do container
- [ ] Sei a diferença entre `docker run` e `docker exec`
- [ ] Sei quando usar `-it`, `-d`, `--rm`, `--name`, `-p`
- [ ] Sei a diferença entre `stop` e `kill`
- [ ] Sei remover containers parados em massa

Próximo módulo: **Imagens** — Docker Hub, tags, pull, push, build básico.
