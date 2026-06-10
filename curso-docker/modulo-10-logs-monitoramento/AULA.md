# Módulo 10 — Logs e Monitoramento

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Inspecionar logs de containers com `docker logs` e suas flags úteis
- Entender por que apps em container logam pra **stdout/stderr** (e não pra arquivo)
- Escolher um **logging driver** adequado e configurar rotação
- Tirar métricas em tempo real com `docker stats`, `docker top`, `docker events`
- Saber onde os logs ficam no disco e quando partir pra Prometheus / Loki / ELK

## 📜 `docker logs` — o pão com manteiga

Todo container tem um log associado ao processo principal. O comando básico:

```bash
docker logs CONTAINER
```

Mas as flags é que fazem o trabalho ficar bom:

| Flag | O que faz |
|---|---|
| `--follow` (`-f`) | Acompanha em tempo real (tipo `tail -f`) |
| `--tail N` | Mostra só as últimas N linhas |
| `--since 10m` | Logs dos últimos 10 minutos (aceita `1h`, `2024-01-01`, etc.) |
| `--until 5m` | Logs ATÉ 5 minutos atrás |
| `--timestamps` (`-t`) | Prefixa cada linha com a hora |
| `-n` | Alias de `--tail` |

Exemplo prático de debugging:

```bash
docker logs --tail 100 -f --timestamps meu-app
```

Combinando com grep dá pra filtrar (no shell):

```bash
docker logs meu-app 2>&1 | grep -i error
```

**Detalhe importante**: `docker logs` lê stdout E stderr. Pra separar no shell, redirecione:

```bash
docker logs meu-app 2>/tmp/err.log 1>/tmp/out.log
```

## 🚰 stdout / stderr — a regra de ouro

Em container, sua aplicação **deve logar pra stdout/stderr**. Não pra arquivo dentro do container.

Por quê?
- O Docker captura essas streams e gerencia (rotaciona, encaminha pra coletor, etc.)
- Arquivo dentro do container some quando ele é removido
- Volume só pra log é complicação desnecessária
- Ferramentas (Kubernetes, ECS, Loki, Datadog) **esperam** stdout/stderr

Se o seu app loga em arquivo, mude. Em apps de produção isso é um sinal de "container-naive".

Convencionalmente:
- **stdout** = mensagens normais / acesso
- **stderr** = erros e warnings

## 🔌 Logging drivers — pra onde o log vai

Por baixo dos panos, o Docker tem um **logging driver** que decide o que fazer com o que sai pelo stdout/stderr.

| Driver | Quando usar |
|---|---|
| `json-file` | **Default**. Salva como JSON no disco do host |
| `local` | Mais novo, mais eficiente, formato binário. Recomendado pra novos setups |
| `journald` | Joga pro systemd journal (útil em servidor Linux) |
| `syslog` | Manda pro syslog (clássico) |
| `fluentd` | Stream pro Fluentd / Fluent Bit (agregador) |
| `gelf` | Pra Graylog |
| `awslogs`, `gcplogs` | Pra CloudWatch / Google Cloud Logging |
| `none` | Desativa logs (raramente útil) |

Configurar global (recomendado, em `/etc/docker/daemon.json`):

```json
{
  "log-driver": "local",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Configurar por container (override):

```bash
docker run --log-driver=local --log-opt max-size=5m --log-opt max-file=2 nginx
```

**Pegadinha**: `docker logs` SÓ funciona com `json-file`, `local` e `journald`. Outros drivers (fluentd, syslog) NÃO permitem ler de volta — você precisa do agregador.

## ♻️ Rotação de logs — não esqueça disso

O default do `json-file` é **sem rotação**. Container que loga muito enche o disco do host e te liga às 3 da manhã.

```json
"log-opts": {
  "max-size": "10m",
  "max-file": "5"
}
```

Isso mantém até 5 arquivos de 10MB = 50MB por container. Ajuste pro seu caso.

## 📍 Onde os logs ficam no disco

No host Linux (driver `json-file`):

```
/var/lib/docker/containers/<container-id>/<container-id>-json.log
```

No Docker Desktop (Mac/Windows), o caminho é dentro da VM que ele cria — você não acessa direto. Use sempre `docker logs`.

Pra ver o caminho:

```bash
docker inspect --format='{{.LogPath}}' meu-container
```

## 📊 `docker stats` — métricas em tempo real

```bash
docker stats
```

Mostra ao vivo de TODOS os containers:
- **CPU %** — uso de CPU
- **MEM USAGE / LIMIT** — memória usada / limite
- **MEM %** — % do limite
- **NET I/O** — bytes lidos/escritos na rede
- **BLOCK I/O** — bytes de disco
- **PIDS** — quantos processos

Modo snapshot (uma leitura e sai):

```bash
docker stats --no-stream
```

Formato customizado (top tier pra dashboard rápido):

```bash
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## 🧬 `docker top` — processos dentro do container

```bash
docker top meu-container
```

Mostra os processos rodando no container (ps por dentro). Útil pra saber se o seu app forkou, se algum worker morreu, etc.

## 🔎 `docker inspect` — raio-X completo

```bash
docker inspect meu-container
```

Devolve um JSON enorme com TUDO: config, rede, volumes, healthcheck, restart policy, recursos. Pra extrair só o que importa:

```bash
docker inspect --format='{{.State.Status}}' meu-container
docker inspect --format='{{.NetworkSettings.IPAddress}}' meu-container
```

## 📡 `docker events` — o que o daemon está fazendo

```bash
docker events
```

Stream em tempo real de eventos: container criado, parado, OOM-killed, imagem puxada, network conectada... Excelente pra debugging de "por que esse container reiniciou?".

Filtrar:

```bash
docker events --filter 'container=meu-app' --filter 'event=die'
docker events --since '1h'
```

## 🛰️ Visão geral: ferramentas de produção

`docker logs` e `docker stats` são ótimos pro dia a dia em **uma máquina**. Em produção (várias máquinas, vários containers) você precisa de:

- **Prometheus** — coleta métricas (CPU, mem, métricas custom da app). Métrica = série temporal.
- **Grafana** — dashboards bonitos em cima do Prometheus (e de muita coisa).
- **Loki** — "Prometheus pra logs". Indexa labels, não conteúdo. Leve, integra com Grafana.
- **ELK Stack** (Elasticsearch + Logstash + Kibana) — pesado, poderoso, faz busca full-text em log.
- **Fluentd / Fluent Bit** — agregadores pra mandar log do container pro destino.
- **cAdvisor** — métricas de container (Google), normalmente plugado no Prometheus.

Pra começar pequeno: Prometheus + Grafana + Loki é o combo enxuto da galera moderna.

## 💡 Detalhes que economizam tempo
- **Loga JSON estruturado**: facilita filtro depois (Loki/ELK agradecem).
- **Nível de log via env var**: `LOG_LEVEL=debug` muda comportamento sem rebuildar imagem.
- **`docker stats` consome CPU também** — não deixa rodando em loop infinito em prod.
- **OOM-killed?** Veja `docker inspect` → `.State.OOMKilled`. Aumentou o uso de memória → mate limite ou otimize.
- **Healthcheck no Dockerfile** combina com isso (Módulo 17): permite ver status no `docker ps`.

## 🚦 Próximos passos
1. Rode a prática — exercite `docker logs`, `docker stats`, `docker events`
2. Faça o desafio — monte seu "mini-dashboard" de métricas
3. Vá pro Módulo 11 — Docker Compose básico

## ✅ Auto-verificação
- [ ] Sei usar `--tail`, `--follow`, `--since`, `--timestamps`
- [ ] Sei por que app em container loga pra stdout/stderr
- [ ] Sei configurar rotação com `max-size` / `max-file`
- [ ] Sei tirar snapshot de métricas com `docker stats --no-stream`
- [ ] Sei o que `docker events` me mostra

Próximo módulo: **Docker Compose básico** — vários containers em um arquivo só.
