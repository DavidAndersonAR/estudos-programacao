# Módulo 17 — Observability

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diagnosticar pod em **CrashLoopBackOff**, **ImagePullBackOff** e **Pending** em menos de 1 minuto
- Usar os **3 pilares da observabilidade**: logs, métricas, eventos
- Dominar `kubectl logs`, `kubectl describe`, `kubectl top`, `kubectl get events`
- Saber em qual ferramenta (Prometheus, Loki, Grafana, Jaeger) cada pilar fica em produção

## 👀 Por que observabilidade existe?

Em desenvolvimento local você dá `docker logs` e pronto. Em produção tem **50 pods em 10 nodes**, alguns morrendo, alguns gargalando, e o usuário reclamando que "tá lento". Sem ferramentas certas, você fica cego.

**Observabilidade ≠ monitoramento**. Monitoramento avisa que **algo está errado**. Observabilidade te dá ferramentas pra **descobrir por quê**, mesmo quando o problema é novo e nunca aconteceu antes.

## 🏛️ Os 3 pilares

### 1. Logs — o que o app escreveu
Texto que o container imprimiu em `stdout`/`stderr`. Resposta pra "o que aconteceu?".

### 2. Métricas — números ao longo do tempo
CPU, memória, requests/segundo, latência. Resposta pra "quanto?" e "está dentro do normal?".

### 3. Eventos — o que o cluster fez
Decisões do K8s: agendou pod, falhou pull, matou por OOM, marcou node como NotReady. Resposta pra "o que o Kubernetes fez (ou tentou fazer)?".

Bônus moderno: **traces** (Jaeger/Tempo) — caminho de uma request entre microserviços. Importante mas fora do escopo deste módulo.

---

## 📜 Pilar 1: Logs

### Básico
```bash
kubectl logs meu-pod                  # logs do pod (1 container)
kubectl logs -f meu-pod               # follow (igual tail -f)
kubectl logs --tail=50 meu-pod        # últimas 50 linhas
kubectl logs --since=10m meu-pod      # últimos 10 minutos
kubectl logs --since=1h meu-pod       # última hora
kubectl logs --timestamps meu-pod     # com data/hora em cada linha
```

### --previous (a pegadinha mais útil do mundo)
Quando um container **crasha e reinicia**, `kubectl logs` mostra os logs **do container novo** — que pode ainda estar subindo e não ter logs interessantes. Pra ver os logs **do container que morreu** (onde está o erro de verdade):

```bash
kubectl logs --previous meu-pod
kubectl logs -p meu-pod               # atalho
```

Se você vê `CrashLoopBackOff` e `kubectl logs` não mostra nada útil, **sempre tente `-p`**.

### Multi-container (pods com sidecar)
```bash
kubectl logs meu-pod -c app           # container chamado "app"
kubectl logs meu-pod -c sidecar       # container chamado "sidecar"
kubectl logs meu-pod --all-containers # todos de uma vez
```

### Várias réplicas — selecionar por label
```bash
kubectl logs -l app=nginx             # logs de TODOS os pods com label app=nginx
kubectl logs -l app=nginx --tail=20   # útil pra checar deployment
```

### Stern / kail — o jeito profissional
`kubectl logs -l` mostra logs **de uma vez só** e mistura tudo. **Stern** mostra logs **coloridos por pod, em tempo real, com filtro de regex**. É padrão de mercado pra debug.

```bash
# Instalar
winget install stern.stern            # Windows
brew install stern                    # mac

# Uso
stern meu-app                          # follow todos pods com "meu-app" no nome
stern -n producao .                    # tudo do namespace producao
stern meu-app --tail 50                # últimas 50 linhas de cada pod
stern meu-app --since 5m               # últimos 5 min
stern meu-app -c app                   # só o container "app"
```

`kail` (kubernetes tail) é uma alternativa com sintaxe diferente — mesma ideia.

---

## 📊 Pilar 2: Métricas

### kubectl top — uso básico
```bash
kubectl top nodes                      # CPU/RAM de cada node
kubectl top pods                       # CPU/RAM de cada pod (namespace atual)
kubectl top pods -A                    # todos os namespaces
kubectl top pods --containers          # quebra por container
kubectl top pods --sort-by=memory      # ordena por consumo de memória
```

### metrics-server (pré-requisito!)
`kubectl top` só funciona com o **metrics-server** instalado. Em clusters gerenciados (EKS, GKE, AKS) geralmente já vem. No **kind** você precisa instalar:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# No kind, precisa ignorar TLS (cluster usa cert self-signed)
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

Espere ~30 segundos e teste `kubectl top nodes`.

### Prometheus + Grafana (produção de verdade)
`kubectl top` só mostra o **agora**. Pra ver "memória do pod nas últimas 24h", "quantas requests/s o app está recebendo", "p99 da latência" — você precisa de um sistema que **armazene histórico** de métricas.

- **Prometheus**: coleta métricas dos pods (via endpoint `/metrics`), guarda séries temporais, permite query com **PromQL**.
- **Grafana**: dashboards bonitos em cima do Prometheus.
- **kube-prometheus-stack** (Helm chart): instala Prometheus + Grafana + Alertmanager + exporters de uma vez. Padrão de mercado.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

---

## 📰 Pilar 3: Eventos

Eventos são **logs do próprio Kubernetes** sobre o que ele fez (ou tentou fazer). Vivem ~1 hora no etcd e somem.

```bash
kubectl get events                                  # eventos do namespace atual
kubectl get events -A                               # todos os namespaces
kubectl get events --sort-by=.lastTimestamp         # ordena por tempo (último embaixo)
kubectl get events --sort-by=.lastTimestamp -A      # combo poderoso
kubectl get events --field-selector type=Warning    # só warnings/erros
kubectl get events --field-selector involvedObject.name=meu-pod  # eventos de UM pod
```

### O que aparece em eventos
- `FailedScheduling` — scheduler não achou node que cabe o pod (sem CPU/RAM, taint não tolerado, etc)
- `Failed` + `ErrImagePull` / `ImagePullBackOff` — imagem não existe, ou registry sem credencial
- `BackOff` — container reiniciando em loop (`CrashLoopBackOff`)
- `OOMKilled` (aparece como evento + no status) — container estourou limite de memória, kernel matou
- `Unhealthy` — readiness/liveness probe falhou
- `FailedMount` — volume/secret/configmap não encontrado
- `Pulled`, `Created`, `Started`, `Scheduled` — eventos normais de sucesso

---

## 🔍 kubectl describe — o canivete suíço

`kubectl describe` junta **tudo**: spec, status, e **eventos do recurso específico no fim**. Pra debug de pod, é geralmente o **primeiro comando** que você dá.

```bash
kubectl describe pod meu-pod
```

A seção `Events:` no fim mostra os últimos eventos **daquele pod específico** — onde aparece o erro de pull, OOM, probe failing, etc.

Funciona pra qualquer recurso:
```bash
kubectl describe deployment meu-app
kubectl describe svc meu-svc
kubectl describe node node-01
```

---

## 🐛 Common issues — receita de bolo

### CrashLoopBackOff
Container sobe, crasha, K8s reinicia, crasha de novo, K8s espera cada vez mais (exponential backoff) e fica em loop.

```bash
kubectl describe pod NOME                      # ver Exit Code + razão
kubectl logs --previous NOME                   # logs do container que morreu
kubectl logs --previous NOME -c container-X    # se for multi-container
```

Causas comuns:
- App quebrou na inicialização (config errada, falta env var, banco indisponível)
- Comando errado no `command`/`args`
- Liveness probe matando o container antes dele ficar pronto

### ImagePullBackOff / ErrImagePull
K8s não conseguiu baixar a imagem.

```bash
kubectl describe pod NOME    # mensagem exata vai estar em Events
```

Causas:
- Typo no nome (`nginz` em vez de `nginx`)
- Tag não existe (`nginx:9.99`)
- Registry privado sem `imagePullSecret`
- Limite de pull rate do Docker Hub (sem login)

### ContainerCreating travado
Pod fica em `ContainerCreating` há minutos.

```bash
kubectl describe pod NOME
```

Causas:
- Volume não montou (PVC sem PV, NFS fora do ar)
- Secret/ConfigMap referenciado não existe
- Pull de imagem grande demorado
- Runtime do node com problema

### Pending
Pod nem foi agendado em node nenhum.

```bash
kubectl describe pod NOME    # vai ter FailedScheduling em Events
kubectl get events --sort-by=.lastTimestamp | grep -i schedul
```

Causas:
- Cluster sem CPU/RAM disponível pros `requests` do pod
- `nodeSelector` que não bate com nenhum node
- Taint sem toleration
- PVC pendente esperando provisionamento

### OOMKilled
Container excedeu `resources.limits.memory` e o kernel Linux matou.

```bash
kubectl describe pod NOME    # Last State: Terminated, Reason: OOMKilled, Exit Code: 137
```

Solução: aumentar limit, ou investigar memory leak no app.

---

## 🧰 Cheat sheet — fluxo de troubleshooting

| Sintoma | Comando 1 (rápido) | Comando 2 (fundo) |
|---|---|---|
| Pod existe? | `kubectl get pod NOME` | `kubectl get pods -A \| grep NOME` |
| Por que pod tá assim? | `kubectl describe pod NOME` | `kubectl get events --sort-by=.lastTimestamp` |
| App tá logando erro? | `kubectl logs NOME` | `kubectl logs -p NOME` (se crashou) |
| Quantas réplicas? | `kubectl get deploy` | `kubectl describe deploy NOME` |
| Service expõe quem? | `kubectl get endpoints NOME` | `kubectl describe svc NOME` |
| Pod usando muita CPU/RAM? | `kubectl top pods` | `kubectl top pods --containers` |
| Node cheio? | `kubectl top nodes` | `kubectl describe node X \| grep -A5 Allocated` |
| Volume montou? | `kubectl describe pod NOME` | (procura `FailedMount` em Events) |
| DNS funcionando? | `kubectl exec POD -- nslookup kubernetes` | (testa de dentro do cluster) |

---

## 🌌 Stack moderna (o que time de SRE usa)

| Pilar | Ferramenta open-source | O que faz |
|---|---|---|
| Logs | **Loki** + Promtail | Armazena logs como séries temporais, integra com Grafana. Tipo "Prometheus pra logs". |
| Logs (alt) | ELK / OpenSearch | Elasticsearch + Logstash + Kibana. Mais pesado, mais poderoso. |
| Métricas | **Prometheus** | Padrão de mercado. Scrape `/metrics`, PromQL, alertas. |
| Dashboards | **Grafana** | Visualiza Prometheus, Loki, Tempo, etc num lugar só. |
| Traces | **Jaeger** ou Tempo | Rastreia uma request atravessando vários microserviços. |
| All-in-one | **OpenTelemetry** | Padrão pra instrumentar app uma vez e mandar pra qualquer backend. |

**Padrão moderno**: instrumentar app com **OpenTelemetry SDK**, mandar pra Prometheus (métricas) + Loki (logs) + Tempo/Jaeger (traces), visualizar tudo no Grafana.

---

## 💡 Detalhes que valem ouro
- **`kubectl logs` sem `-p` mente** quando o container crashou. Em `CrashLoopBackOff`, **sempre** rode `kubectl logs -p`.
- **Eventos somem em ~1h** (TTL padrão). Se um problema aconteceu de manhã e você só foi olhar à tarde, eventos podem já ter desaparecido — bom motivo pra exportar pra Loki.
- **`kubectl top` exige metrics-server** rodando. Em kind, instale antes do desafio.
- **Logs do container vão pra `stdout`/`stderr`** — se o app escreve em arquivo dentro do container, `kubectl logs` **não vê**. Pratique sempre logar pra stdout.
- **Tail correto**: `kubectl logs --tail=100 -f` em vez de baixar gigabytes de log antigo.
- **Pra debug de probe**: `kubectl describe pod` mostra contagem de falhas; `kubectl get events` mostra a mensagem da falha.
- **`-o wide`** em `kubectl get pods` mostra o **node** onde o pod está — útil quando o problema é de node específico.

## 🚦 Próximos passos
1. Leia a `pratica/` — você vai quebrar 3 pods de propósito e diagnosticar cada um
2. Instale **stern** (`winget install stern.stern`) — facilita muito o dia a dia
3. Encare o desafio: um pod problemático, descobrir o porquê

## ✅ Auto-verificação
- [ ] Sei a diferença entre logs, métricas e eventos
- [ ] Sei que `kubectl logs -p` mostra container anterior (CrashLoopBackOff)
- [ ] Sei que `kubectl describe pod` mostra eventos no fim
- [ ] Sei usar `kubectl get events --sort-by=.lastTimestamp`
- [ ] Sei o que é stern e quando ele bate `kubectl logs`
- [ ] Conheço de nome: Prometheus, Grafana, Loki, Jaeger, OpenTelemetry

Próximo módulo: **Rolling Updates** — fazer deploy sem downtime.
