# Módulo 10 — DaemonSets, Jobs e CronJobs

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar quando usar **DaemonSet** em vez de Deployment
- Diferenciar **Job** (roda até terminar) de Deployment (roda pra sempre)
- Escrever um **CronJob** com sintaxe cron de 5 campos
- Controlar paralelismo, retries e retenção de histórico

## 🤔 O problema: nem tudo é "app web 24/7"

Até agora você só viu **Deployment** — workload que roda pra sempre e o K8s reinicia se cair. Mas a vida real tem outros padrões:

1. **"Quero 1 agente em CADA node, sempre"** — coletor de log, monitoring, CNI, storage driver. → **DaemonSet**
2. **"Quero rodar UMA tarefa que termina"** — migration de banco, processar um lote, calcular pi. → **Job**
3. **"Quero rodar uma tarefa NO HORÁRIO X"** — backup diário, limpeza às 3h da manhã, relatório toda segunda. → **CronJob**

Cada um existe pra um caso que Deployment não resolve direito.

## 🛡️ DaemonSet — 1 pod por node, automaticamente

**Regra de ouro**: novo node entra no cluster → DaemonSet sobe pod nele sozinho. Node sai → pod some junto.

### Casos de uso típicos
- **Agente de log** (Fluentd, Filebeat, Promtail) — precisa ler `/var/log` de cada node
- **Monitoring** (node-exporter do Prometheus) — métricas de CPU/RAM por node
- **Network plugin** (Calico, Cilium, Flannel) — instala a rede em cada node
- **Storage driver** (CSI) — monta volumes no node
- **Security agent** (Falco) — observa syscalls

Padrão comum: o pod precisa rodar **no host**, não na lógica de aplicação.

### Rodar em só alguns nodes
DaemonSet padrão = todos os nodes. Pra restringir, use **node selector** ou **node affinity**:

```yaml
spec:
  template:
    spec:
      nodeSelector:
        disktype: ssd       # só nodes com label disktype=ssd
```

Útil pra: "só roda agente de GPU em nodes com GPU", "só CSI em nodes com storage".

### YAML mínimo
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
spec:
  selector:
    matchLabels: { app: log-agent }
  template:
    metadata:
      labels: { app: log-agent }
    spec:
      containers:
        - name: agent
          image: busybox
          command: ["sh", "-c", "while true; do echo tick; sleep 30; done"]
```

> 💡 **No kind com 1 node**, DaemonSet roda 1 pod. Adicione `--workers 2` na criação do cluster pra ver "1 por node" funcionando de verdade.

## 🏁 Job — roda até completar

Deployment quer pod **sempre vivo**. Job quer pod que **termina com sucesso e fica como histórico**.

### Caso de uso
- Rodar migration de banco antes de subir nova versão da app
- Processar um lote de dados (ETL)
- Mandar email em massa
- Treinar um modelo ML
- O clássico exemplo K8s: calcular pi com perl

### Campos importantes

| Campo | O que faz |
|---|---|
| `completions` | Quantos pods precisam **terminar com sucesso** pra Job ser "Complete". Default: 1. |
| `parallelism` | Quantos pods rodam **em paralelo**. Default: 1. |
| `backoffLimit` | Quantas vezes o K8s tenta de novo se o pod **falhar** antes de marcar como "Failed". Default: 6. |
| `activeDeadlineSeconds` | Timeout máximo (em segundos). Excedeu → Job marcado como falho. |
| `ttlSecondsAfterFinished` | Auto-delete do Job N segundos depois de terminar. Bom pra não acumular lixo. |

### Padrões de execução

- **completions=1, parallelism=1** → "rode uma vez". Migration típica.
- **completions=10, parallelism=1** → "rode 10 vezes, uma por vez". Fila sequencial.
- **completions=10, parallelism=3** → "rode 10 vezes, até 3 em paralelo". Worker pool.
- **completions não definido, parallelism=N** → workers consumindo de fila externa até alguém decidir parar.

### restartPolicy num Job

Em Job só pode ser `OnFailure` ou `Never`. **`Always` não faz sentido** — Job quer terminar, e Always reiniciaria pra sempre. K8s nem deixa você usar.

- `OnFailure` → mesmo pod reinicia (mais rápido, conta como retry interno)
- `Never` → cria pod novo a cada tentativa (mais limpo pra debug, ocupa mais histórico)

### YAML clássico (calcular pi)
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  completions: 1
  parallelism: 1
  backoffLimit: 4
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: pi
          image: perl:5.34
          command: ["perl","-Mbignum=bpi","-wle","print bpi(2000)"]
```

## ⏰ CronJob — Job recorrente no horário certo

CronJob = **Job + schedule cron**. Toda hora marcada, ele cria um Job, que cria um pod, que faz a tarefa.

### Casos de uso
- Backup do banco às 2h da manhã todo dia
- Limpeza de arquivos temporários a cada hora
- Sincronizar dados com sistema externo a cada 15min
- Gerar relatório toda segunda 8h
- Renovar certificado todo dia 1 às 3h

### Sintaxe cron (5 campos)

```
┌── minuto         (0-59)
│ ┌── hora         (0-23)
│ │ ┌── dia do mês (1-31)
│ │ │ ┌── mês      (1-12)
│ │ │ │ ┌── dia da semana (0-6, 0 e 7 = domingo)
│ │ │ │ │
* * * * *
```

Exemplos:
| Cron | Quando |
|---|---|
| `*/1 * * * *` | A cada 1 minuto |
| `0 * * * *` | Toda hora cheia |
| `0 2 * * *` | Todo dia às 02:00 |
| `0 3 * * 0` | Todo domingo às 03:00 |
| `*/15 9-17 * * 1-5` | A cada 15min, das 9 às 17, seg–sex |

> 💡 Quando em dúvida: cole o cron em https://crontab.guru e ele te explica em inglês.

### Campos importantes

| Campo | O que faz |
|---|---|
| `schedule` | A expressão cron. |
| `concurrencyPolicy` | O que fazer se o Job anterior ainda tá rodando quando chega a hora do próximo: `Allow` (deixa rodar junto — default), `Forbid` (pula o novo), `Replace` (mata o antigo e roda o novo). |
| `successfulJobsHistoryLimit` | Quantos Jobs **bem-sucedidos** manter no histórico. Default: 3. |
| `failedJobsHistoryLimit` | Quantos Jobs **falhados** manter. Default: 1. |
| `startingDeadlineSeconds` | Se o K8s perdeu a janela (controlador caiu, p.ex.), quantos segundos depois ainda pode iniciar. |
| `suspend` | `true` pausa o CronJob sem deletar. Útil pra "desligar backup essa semana". |

### YAML
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: hello
              image: busybox
              command: ["sh","-c","date; echo hello do CronJob"]
```

Note a **estrutura aninhada**: CronJob → `jobTemplate` (Job) → `template` (Pod). Três níveis.

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl get ds` | Lista DaemonSets |
| `kubectl get jobs` | Lista Jobs |
| `kubectl get cj` | Lista CronJobs (abreviação) |
| `kubectl get pods --selector=job-name=NOME` | Pods de um Job específico |
| `kubectl logs job/NOME` | Logs do pod do Job |
| `kubectl create job manual --from=cronjob/NOME` | Dispara o CronJob "na mão" agora (ótimo pra testar) |
| `kubectl patch cronjob NOME -p '{"spec":{"suspend":true}}'` | Pausa CronJob |
| `kubectl describe cronjob NOME` | Mostra próximo schedule, último Job, etc. |

## 💡 Detalhes que valem ouro

- **`backoffLimit` é o pulo do gato pra Job que falha em loop**. Sem ele, K8s tenta pra sempre (até 6x por padrão). Em tarefa idempotente coloque alto; em tarefa não-idempotente coloque 0 ou 1.
- **CronJob no fuso UTC** por padrão. Backup "às 2h da manhã" pode rodar às 23h pro seu fuso. Use `spec.timeZone` (K8s 1.27+) ou ajuste o cron mentalmente.
- **`concurrencyPolicy: Forbid`** é quase sempre o certo pra backups. Não quer 2 backups simultâneos brigando pelo arquivo de output.
- **`ttlSecondsAfterFinished` num Job** evita acumular Jobs zumbis. Sem isso, eles ficam pra sempre até alguém limpar.
- **Pods do Job não somem quando o Job termina** — ficam em status `Completed`. Isso é proposital: você quer ver os logs. Use `ttlSecondsAfterFinished` ou limpe na mão.
- **DaemonSet ≠ "1 por pod por node"**. É **1 réplica do DaemonSet por node**. Se o template tem 2 containers, cada node tem 1 pod com 2 containers.
- **CronJob ainda é `batch/v1`** desde K8s 1.21 — antes era `batch/v1beta1` e mudou. Se ver tutorial antigo, atualize.

## 🚦 Próximos passos
1. Veja `pratica/` — DaemonSet, Job (calcular pi) e CronJob (hello a cada minuto)
2. Rode `pratica/comandos.sh` e observe o CronJob criando Jobs sozinho
3. Encare o desafio do `desafio/` — CronJob de backup com retenção

## ✅ Auto-verificação
- [ ] Sei quando usar DaemonSet em vez de Deployment
- [ ] Sei diferença entre `completions` e `parallelism`
- [ ] Sei o que `backoffLimit` faz num Job
- [ ] Consigo escrever um cron schedule de cabeça (ou pelo menos saber consultar)
- [ ] Sei pra que serve `concurrencyPolicy: Forbid`
- [ ] Entendo a estrutura aninhada `CronJob → jobTemplate → template`

Próximo módulo: **Ingress** — expor HTTP/HTTPS pra fora do cluster com regras de roteamento.
