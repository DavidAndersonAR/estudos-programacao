# Módulo 17 — Healthcheck e Restart

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever um `HEALTHCHECK` no Dockerfile com parâmetros corretos
- Entender os 3 estados de saúde: **starting**, **healthy**, **unhealthy**
- Escolher a **restart policy** certa pro seu caso (`no`, `on-failure`, `always`, `unless-stopped`)
- Usar `--init` pra resolver zombies e signal handling
- Diferenciar a auto-recuperação do Docker simples vs Kubernetes/Swarm

## 🩺 Por que healthcheck existe?

Container rodando **não significa** app funcionando. Cenários clássicos:

- App travou em loop infinito — processo vivo, requisições não respondem
- Conexão com banco caiu — app sobe mas falha em toda requisição
- Memory leak — app respondendo mas lento demais

Sem healthcheck, o Docker acha que está tudo bem porque o **processo principal não morreu**. Você precisa de um sinal melhor: "tá respondendo?"

## 🏥 `HEALTHCHECK` no Dockerfile

Sintaxe básica:

```dockerfile
HEALTHCHECK [OPÇÕES] CMD comando
```

Exemplo com `curl`:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

Tradução: a cada 30s, faz a requisição. Se demorar mais de 3s OU falhar 3 vezes seguidas, marca como **unhealthy**. Nos primeiros 5s, falhas não contam (app ainda subindo).

### Opções

| Flag | Default | O que faz |
|---|---|---|
| `--interval` | 30s | Tempo entre checks |
| `--timeout` | 30s | Quanto esperar antes de declarar check falhado |
| `--start-period` | 0s | Tempo de boot — falhas não contam |
| `--retries` | 3 | Quantas falhas seguidas pra ficar unhealthy |
| `--start-interval` | 5s | Intervalo durante o start-period |

### O comando precisa ter exit code

- `exit 0` → healthy
- `exit 1` → unhealthy
- Qualquer outro → também conta como falha

Por isso o `|| exit 1` no final do `curl`: curl pode retornar 22, 6, etc. — uniformiza pra 1.

### Imagem não tem curl?

Imagens mínimas (Alpine, distroless) podem não ter `curl`. Alternativas:

```dockerfile
# wget (vem no Alpine)
HEALTHCHECK CMD wget --quiet --tries=1 --spider http://localhost:3000/health || exit 1

# Script Node próprio
HEALTHCHECK CMD node /app/healthcheck.js

# Para banco: pg_isready, mysqladmin ping
HEALTHCHECK CMD pg_isready -U postgres
```

## 🚦 Os 3 estados

```
   docker run
       ↓
   starting  ← start-period rolando
       ↓
   healthy   ← check passou
       ↕
   unhealthy ← N falhas seguidas
```

Ver o estado:

```bash
docker ps                                    # coluna STATUS mostra (healthy)
docker inspect --format='{{.State.Health.Status}}' meu-app
docker inspect --format='{{json .State.Health}}' meu-app | jq
```

O histórico dos últimos checks fica em `.State.Health.Log` — útil pra debugar **por que** ficou unhealthy.

## 🔁 Restart policies

Aqui vem a parte de auto-recuperação. Por padrão, container que morre fica morto. As policies mudam isso:

| Policy | Quando reinicia | Quando usar |
|---|---|---|
| `no` (default) | Nunca | Jobs pontuais, testes |
| `on-failure[:max]` | Exit code ≠ 0, até N tentativas | Workers, batch jobs |
| `always` | Sempre (até se você parar manualmente, na próxima vez que o Docker subir) | Daemons que SEMPRE têm que rodar |
| `unless-stopped` | Sempre, EXCETO se você parou explicitamente | **O default sensato pra produção** |

Como aplicar:

```bash
docker run --restart unless-stopped meu-app
docker run --restart on-failure:5 meu-worker
```

No Compose:

```yaml
services:
  app:
    restart: unless-stopped
```

### `always` vs `unless-stopped` — a diferença sutil

Você roda com `--restart always`, depois faz `docker stop meu-app` (parou manualmente). Quando você reinicia o Docker (boot da máquina), o container **sobe sozinho de novo**.

Com `unless-stopped`, se você parou manualmente, fica parado até você dizer `docker start`. É o comportamento que quase todo mundo quer.

## ⚠️ Healthcheck NÃO reinicia o container

Detalhe crítico: Docker simples (sem orquestrador) só usa o status `unhealthy` como **informação**. Ele não vai matar e reiniciar o container automaticamente.

Pra restart automático em cima de unhealthy, você precisa de:
- **Docker Swarm**: faz isso nativamente
- **Kubernetes**: liveness probe + restart policy do pod
- **Workaround manual**: container "autoheal" (`willfarrell/autoheal`) que monitora os outros

Mas mesmo sem isso, o healthcheck serve pra:
- `depends_on: condition: service_healthy` no Compose (Módulo 11)
- Load balancer saber se manda tráfego ou não
- Você ver no `docker ps` que algo está errado
- Métricas / alertas

## 🧟 `--init` — resolvendo zombies e Ctrl+C

Por padrão, seu app é o **PID 1** dentro do container. Isso traz dois problemas:

1. **Zombies**: PID 1 tem que dar `wait()` em processos órfãos. Node, Python, etc. não fazem isso direito.
2. **Signals**: PID 1 ignora SIGTERM/SIGINT por padrão (proteção do kernel). Resultado: `docker stop` espera 10s e mata na marra com SIGKILL.

A flag `--init` injeta o **tini** (init mínimo) como PID 1. Ele:
- Repassa sinais pro seu app
- Recolhe zombies
- Termina limpinho

```bash
docker run --init meu-app
```

No Compose:

```yaml
services:
  app:
    init: true
```

Custa nada e resolve dor de cabeça. Use sempre que sua imagem rodar Node, Python, Ruby ou qualquer linguagem sem init de verdade.

## 🎯 Docker simples vs orquestrador

Resumo rápido de quem cuida do quê:

| Comportamento | Docker simples | Swarm / K8s |
|---|---|---|
| Reinicia container que morreu | Sim, via `--restart` | Sim, padrão |
| Reinicia em cima de `unhealthy` | **Não** | Sim |
| Reagenda em outro nó se a máquina cair | Não | Sim |
| Rolling update sem downtime | Não | Sim |
| Scale horizontal | Não | Sim |

Pra projeto pessoal, MVP, dev local: `--restart unless-stopped` + healthcheck já te leva longe. Pra produção séria com vários nós, é hora do Swarm (Módulo 15) ou Kubernetes.

## 💡 Detalhes que economizam tempo
- **Healthcheck custa CPU**: rodar a cada 5s em 100 containers vira tráfego. Use `30s` pra serviços normais.
- **O comando do healthcheck roda DENTRO do container**: precisa que `curl`/`wget` exista lá. Senão, COPY um script.
- **Logs do healthcheck**: `.State.Health.Log` guarda só os últimos 5. Pra debug mais profundo, faça o app logar.
- **Imagens oficiais já têm healthcheck**: postgres, redis, nginx oficial — muitas vezes você não precisa adicionar.
- **`HEALTHCHECK NONE`**: usa pra desabilitar healthcheck herdado da imagem base.
- **Restart conta tentativas**: `on-failure:3` para depois de 3 falhas. Não fica em loop infinito.

## 🚦 Próximos passos
1. Faça a prática: app com `/health`, restart policy
2. Faça o desafio: app que morre depois de N requests e auto-recupera
3. Vá pro Módulo 18 — onde vamos focar em segurança e usuários não-root

## ✅ Auto-verificação
- [ ] Sei escrever `HEALTHCHECK` com `interval`, `timeout`, `retries`, `start-period`
- [ ] Sei a diferença entre `always` e `unless-stopped`
- [ ] Sei que Docker simples NÃO reinicia em cima de unhealthy
- [ ] Sei o que `--init` resolve
- [ ] Sei inspecionar o histórico de checks com `docker inspect`

Próximo módulo: **Segurança Básica e Usuários Não-Root**.
