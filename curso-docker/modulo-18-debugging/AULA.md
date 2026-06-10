# Módulo 18 — Debugging

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diagnosticar um container que **não sobe** ou que **sobe e morre na hora**
- Usar a **toolbox de debugging** do Docker sem entrar em pânico
- Saber qual ferramenta usar pra cada sintoma (logs? inspect? exec?)
- Sobrepor um `ENTRYPOINT` quebrado pra entrar e investigar
- Copiar arquivos pra dentro/fora de um container vivo

## 🩺 A regra de ouro do debugging

> **Antes de mexer, observe.**
> Logs primeiro. Inspect depois. Exec só se precisar entrar.

Resista à tentação de `docker rm -f` e recomeçar — o container morto é a sua **cena do crime**. Tudo que você precisa pra entender o que aconteceu tá ali (exit code, último log, config aplicada).

## 🧰 A toolbox

### `docker logs` — o que o container disse
```bash
docker logs CONTAINER                  # tudo desde o início
docker logs -f CONTAINER               # follow (igual tail -f)
docker logs --tail 100 CONTAINER       # só as últimas 100 linhas
docker logs -f --tail 100 CONTAINER    # combo perfeito pra produção
docker logs --since 10m CONTAINER      # só o que saiu nos últimos 10 min
```
99% dos bugs aparecem aqui. **Sempre comece por logs.**

### `docker inspect` — a ficha técnica completa
```bash
docker inspect CONTAINER
docker inspect --format '{{.State.ExitCode}}' CONTAINER
docker inspect --format '{{.State.Error}}'    CONTAINER
docker inspect --format '{{.Config.Env}}'     CONTAINER
docker inspect --format '{{.Config.Cmd}}'     CONTAINER
docker inspect --format '{{json .NetworkSettings.Ports}}' CONTAINER
docker inspect --format '{{json .Mounts}}'    CONTAINER
docker inspect --format '{{json .State.Health}}' CONTAINER
```
Mostra **tudo**: config, env vars aplicadas, IPs, mounts, health check, exit code, mensagem de erro do runtime.

### `docker exec` — entrar dentro do container vivo
```bash
docker exec -it CONTAINER sh           # shell mínimo (alpine, busybox)
docker exec -it CONTAINER bash         # se a imagem tiver bash
docker exec CONTAINER ps aux           # rodar um único comando, sem TTY
docker exec -u root -it CONTAINER sh   # entrar como root mesmo se a app rodar como user
```
`-i` = interativo (stdin aberto), `-t` = TTY (terminal de verdade). **Só funciona com container rodando.**

### `docker stats` — recursos em tempo real
```bash
docker stats                           # todos containers, atualizando
docker stats CONTAINER                 # só um
docker stats --no-stream               # snapshot único (bom pra script)
```
CPU%, memória, rede, I/O de disco. Útil pra ver se o container tá **estourando memória** (OOMKilled) ou comendo CPU.

### `docker top` — processos rodando dentro
```bash
docker top CONTAINER
docker top CONTAINER aux               # passa flags pro ps de dentro
```
Equivalente a `ps` rodado dentro do container, mas você nem precisa entrar.

### `docker port` — mapeamentos de porta
```bash
docker port CONTAINER                  # todos
docker port CONTAINER 80               # só a porta 80
```
Útil quando você fez `-p 0:80` (porta aleatória) e precisa descobrir qual saiu.

### `docker diff` — o que mudou no filesystem
```bash
docker diff CONTAINER
```
Lista cada arquivo que foi **A**dicionado, **C**hanged ou **D**eleted comparado com a imagem original. Ótimo pra entender o que a app escreveu em disco.

### `docker cp` — copiar arquivo entre host e container
```bash
docker cp CONTAINER:/var/log/app.log ./app.log    # de dentro pra fora
docker cp ./fix.conf CONTAINER:/etc/app/fix.conf  # de fora pra dentro
docker cp CONTAINER:/data .                       # diretório inteiro
```
Funciona com container **rodando ou parado**. Salva quando você precisa pegar log de um container morto.

### `docker events` — stream global do Docker
```bash
docker events --since 1h
docker events --filter container=meu-app
docker events --filter event=die --since 30m
```
Stream de tudo que acontece no daemon: criação, start, die, kill, OOM, health check, image pull... Bom pra investigar **por que um container reiniciou** ou foi morto.

## 🚨 Cenário 1: Container morre na hora que sobe

```bash
docker run --name app minha-imagem
# volta o prompt na hora
docker ps               # não tá lá
docker ps -a            # Exited (127) 2 seconds ago
```

**Receita:**
```bash
docker logs app                                       # 1. o que a app disse?
docker inspect --format '{{.State.ExitCode}}' app     # 2. qual exit code?
docker inspect --format '{{.State.Error}}'    app     # 3. erro do runtime?
```

**Códigos comuns:**
| Exit code | Significa |
|---|---|
| 0   | Saiu normal (CMD terminou) — pode ser script que rodou e acabou |
| 1   | Erro genérico da app |
| 125 | Erro do Docker (flag inválida, imagem corrompida) |
| 126 | Comando achou mas não é executável (sem permissão) |
| 127 | **Comando não existe** — typo no CMD/ENTRYPOINT |
| 137 | Morto por SIGKILL — geralmente **OOM** (memória) |
| 139 | Segfault |
| 143 | Morto por SIGTERM (alguém deu `docker stop`) |

## 🩹 Cenário 2: ENTRYPOINT quebrado — não consigo nem entrar

O container morre antes de você conseguir `exec`. Solução: **sobrepor o entrypoint** com um shell.

```bash
docker run --rm -it --entrypoint sh minha-imagem
```
Agora você caiu num shell dentro da imagem, sem rodar a app. Dali você pode:
- Testar o comando que estava no CMD na mão
- Ver se os arquivos estão onde deveriam (`ls /app`)
- Ver as env vars (`env`)
- Conferir se o binário existe (`which meu-binario`)

Mesmo truque pra `docker compose`:
```bash
docker compose run --rm --entrypoint sh meu-servico
```

## 🔍 Cenário 3: Container roda, mas não responde

App tá "no ar" (`docker ps` mostra), mas você não consegue acessar.

**Checklist:**
1. `docker logs CONTAINER` — tá com erro mascarado?
2. `docker port CONTAINER` — porta tá mapeada mesmo?
3. `docker exec CONTAINER wget -qO- localhost:PORTA` — funciona **de dentro**?
   - Se sim → problema é de mapeamento/rede do host
   - Se não → problema é da app
4. `docker inspect --format '{{.State.Health.Status}}' CONTAINER` — healthcheck reprova?
5. `docker stats --no-stream CONTAINER` — tá comendo CPU/RAM demais?

## 🎯 Cheat sheet de debugging

| Sintoma | Comando que resolve |
|---|---|
| "Container morreu" | `docker logs` + `docker inspect --format '{{.State.ExitCode}}'` |
| "Tá rodando mas não responde" | `docker exec ... wget localhost:PORTA` |
| "Não consigo entrar" | `docker run --entrypoint sh -it IMAGEM` |
| "Tá usando memória demais" | `docker stats` |
| "Quero ver os processos" | `docker top` |
| "Que porta foi mapeada?" | `docker port` |
| "O que mudou em disco?" | `docker diff` |
| "Preciso do log que ficou dentro" | `docker cp CONTAINER:/path/log ./` |
| "Por que reiniciou sozinho?" | `docker events --since 1h` |
| "Env var chegou certinha?" | `docker inspect --format '{{.Config.Env}}'` |

## 💡 Detalhes que economizam tempo
- **`docker logs` mostra stdout + stderr** do PID 1. Se sua app loga em arquivo, você não vê nada — redirecione pra stdout (Módulo 14).
- **`exec` não passa pelo ENTRYPOINT** — é um processo novo. Por isso entrypoint quebrado não atrapalha `exec` (mas atrapalha o container subir, e sem subir não tem onde dar `exec`).
- **`inspect` aceita `--format` com templates Go** — aprenda 3 ou 4 e pare de scrollar JSON gigante.
- **`docker stats` puxa CPU%** relativo a 1 core. `200%` num container = ele usa 2 cores cheios.
- **`docker diff` é ouro pra entender ataques**: arquivos novos em `/tmp` ou `/var/tmp` num container "limpo" são bandeira vermelha.
- **Containers de scratch/distroless não têm shell** — `exec sh` falha. Use `docker cp` pra tirar arquivos e debugue do lado de fora.

## 🚦 Próximos passos
1. Rode `pratica/comandos.sh` — vai criar um container quebrado de propósito e te guiar pelo diagnóstico
2. Faça o desafio: Dockerfile com 3 bugs, ache e conserte usando a toolbox
3. Próximo módulo: **Boas práticas** — pra escrever Dockerfile que não dá bug em primeiro lugar

## ✅ Auto-verificação
- [ ] Sei a diferença entre `logs`, `inspect`, `exec` e quando usar cada um
- [ ] Sei ler exit code e o que 127 / 137 / 143 significam
- [ ] Consigo entrar num container com ENTRYPOINT quebrado
- [ ] Sei copiar arquivo de dentro de container parado
- [ ] Tenho `docker events` no radar pra investigar reinícios misteriosos

Próximo módulo: **Boas Práticas de Dockerfile** — prevenção é melhor que cura.
