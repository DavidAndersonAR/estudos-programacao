# Módulo 15 — Resources e Autoscaling

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Definir `requests` e `limits` de CPU e memória em pods
- Entender as **QoS classes** (Guaranteed / Burstable / BestEffort)
- Instalar o **metrics-server** no kind
- Configurar um **HPA** (Horizontal Pod Autoscaler) e ver ele escalando sob carga
- Diferenciar HPA, VPA e Cluster Autoscaler — saber quando usar cada um

## 🤔 Por que isso importa?

Imagina que você sobe um pod sem dizer quanta CPU/memória ele precisa. O scheduler do K8s vai **chutar** onde colocar — pode lotar um node enquanto outros ficam vazios. Pior: se o app vazar memória, ele pode comer toda a RAM da máquina e derrubar **pods vizinhos**.

Resources resolvem isso. Autoscaling resolve o passo seguinte: "tá chegando muito tráfego, sobe mais réplicas; passou o pico, derruba". Sem precisar de humano apertando botão.

## 📦 Requests vs Limits — a diferença que muda tudo

```yaml
resources:
  requests:    # "Eu preciso DISSO pra rodar"
    cpu: "100m"
    memory: "128Mi"
  limits:      # "Mais que ISSO eu não posso usar"
    cpu: "500m"
    memory: "256Mi"
```

### `requests` — o que o scheduler reserva
É a **base pra alocação no node**. O scheduler olha quanto sobra em cada node e só coloca o pod onde os requests cabem. **Não é o que o pod vai usar de verdade** — é o que ele garantiu pra si.

Sem requests → scheduler chuta. O pod até roda, mas pode ir parar num node lotado e brigar por recursos.

### `limits` — o teto
Se o pod tenta passar do limit, o kernel reage diferente pra CPU e memória:

| Recurso | Passou do limit | O que acontece |
|---|---|---|
| **CPU** | Throttling | Kernel **estrangula** o processo. Roda mais devagar, mas vive. |
| **Memória** | OOMKilled | Kernel **mata** o container (Out Of Memory Killed). K8s reinicia. |

Por isso CPU passar do limit "dói menos" que memória passar. Memória estourou → morre.

## 📐 Unidades — milicores e mebibytes

### CPU
- **1 core = 1000m (milicores)**
- `100m` = 0.1 core = 10% de 1 CPU
- `500m` = meia CPU
- `2` ou `2000m` = 2 cores inteiros

CPU é **compressível** — dá pra dividir, throttle, etc.

### Memória
- `Mi` = mebibyte (1024²) — preferido em K8s
- `Gi` = gibibyte (1024³)
- `M`/`G` (sem `i`) = mega/giga decimal (1000²). Use `Mi` pra evitar confusão.

Memória é **incompressível** — ou tem ou não tem. Por isso o kernel mata em vez de "throttlar".

## 🏅 QoS Classes — como o K8s decide quem morre primeiro

Quando o node fica sem recursos, o K8s precisa matar alguém. Ele decide pela **QoS class** que **você não escolhe direto** — ela é deduzida de como você setou requests/limits:

### 1. **Guaranteed** (melhor) 🥇
`requests == limits` pra **todos** os containers, **CPU e memória**.

```yaml
resources:
  requests: { cpu: "500m", memory: "256Mi" }
  limits:   { cpu: "500m", memory: "256Mi" }
```

K8s prioriza ao máximo. Mata **por último**. Use pra DBs, apps críticos.

### 2. **Burstable** 🥈
Tem requests, mas requests ≠ limits (ou só tem um dos dois).

```yaml
resources:
  requests: { cpu: "100m", memory: "128Mi" }
  limits:   { cpu: "500m", memory: "256Mi" }
```

Pode usar mais que reservou se sobrar — mas se a casa apertar, é candidato a morrer antes do Guaranteed. **80% dos seus apps vão cair aqui.**

### 3. **BestEffort** (pior) 🥉
**Sem requests e sem limits**. Nada.

```yaml
# resources nem aparece
```

Roda no que sobrar. **Primeiro a morrer** quando o node aperta. Use só pra batch job descartável.

## 📊 HPA — Horizontal Pod Autoscaler

Escala **réplicas**: 3 pods → 7 pods → 2 pods, conforme a métrica.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: meu-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: meu-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50   # alvo: 50% do request de CPU
```

### Como o HPA calcula
Fórmula simplificada:
```
réplicas_desejadas = ceil( réplicas_atuais × (uso_atual / alvo) )
```
Ex: 2 pods rodando a 100% de CPU, alvo 50% → `ceil(2 × 100/50) = 4`. Sobe pra 4.

**Importante**: HPA precisa que você tenha definido `requests` de CPU/memória — sem isso, ele não tem base de cálculo e não funciona.

### Pré-requisito: metrics-server
HPA pergunta "quanto de CPU/memória os pods estão usando?". Quem responde é o **metrics-server**. Ele **não vem instalado** em kind/minikube — você precisa instalar.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Em kind ainda precisa adicionar `--kubelet-insecure-tls` (cert do kubelet é self-signed). Veja `pratica/metrics-server.sh`.

### Custom metrics
HPA não precisa ser só CPU/memória. Pode escalar por:
- Requests por segundo (precisa de Prometheus Adapter)
- Tamanho de fila (RabbitMQ, SQS — via KEDA)
- Qualquer métrica que vire um endpoint da custom metrics API

Mas pra começar: CPU/memória já resolve 80%.

## 📏 VPA — Vertical Pod Autoscaler

Em vez de mais pods, ajusta **requests/limits** dos pods existentes. "Esse pod está sempre usando 800m de CPU mas você pediu 100m, bora subir o request".

- Bom pra: workload sem horizontal scale (DB monolítico)
- Ruim pra: precisa **recriar o pod** pra mudar requests (causa downtime curto)
- Cuidado: **não use VPA junto com HPA em CPU/memória** — eles brigam.

VPA é menos comum no dia a dia. HPA domina.

## 🌐 Cluster Autoscaler

HPA escala **pods**. Mas e se o node lotou e não cabe mais pod? Aí entra o **Cluster Autoscaler** — pede mais **nodes** pra cloud (AWS, GCP, Azure).

```
Carga sobe → HPA cria pods → nodes lotam → Cluster Autoscaler pede mais node →
cloud provisiona VM → kubelet conecta → pods schedulam.
```

Não funciona em kind (kind não pede VM pra ninguém). Só em cloud de verdade ou managed K8s.

### Resumo das 3 ferramentas

| Ferramenta | O que escala | Direção | Onde funciona |
|---|---|---|---|
| **HPA** | Réplicas (mais/menos pods) | Horizontal | Qualquer cluster + metrics-server |
| **VPA** | Requests/limits do pod | Vertical | Qualquer cluster + VPA instalado |
| **Cluster Autoscaler** | Nodes (máquinas) | Horizontal | Cloud com node pool gerenciável |

## 🧪 Instalando metrics-server no kind

O metrics-server precisa de TLS válido pra falar com o kubelet. No kind, o cert é self-signed — sem patch ele fica em `CrashLoopBackOff`.

```bash
# 1. Aplicar manifest
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 2. Patchar pra aceitar cert inseguro (SÓ em dev/kind)
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# 3. Esperar ficar pronto
kubectl rollout status -n kube-system deployment/metrics-server

# 4. Testar
kubectl top nodes
kubectl top pods -A
```

Quando `kubectl top` funciona, HPA funciona.

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl top nodes` | Uso de CPU/mem por node (precisa metrics-server) |
| `kubectl top pods` | Uso de CPU/mem por pod |
| `kubectl get hpa` | Lista HPAs com alvo/atual/réplicas |
| `kubectl describe hpa NOME` | Detalhes + eventos (por que escalou) |
| `kubectl autoscale deploy NOME --cpu-percent=50 --min=1 --max=10` | Cria HPA imperativo |
| `kubectl get pod NOME -o jsonpath='{.status.qosClass}'` | QoS class do pod |

## 💡 Detalhes que valem ouro
- **Sempre defina requests**. Mesmo que chutado, é melhor que nada. Sem requests, o scheduler joga seu pod no escuro **e o HPA não funciona**.
- **CPU limit é controverso**. Em produção, muita gente NÃO seta CPU limit — throttling em pico atrapalha latência. Memory limit, sempre setar.
- **Memória sem limit = bomba-relógio**. App com vazamento de memória sem limit pode derrubar o node inteiro.
- **HPA tem cooldown**: por padrão demora 15s pra subir e até 5min pra descer. Isso evita "flapping" (sobe-desce-sobe). Customizável via `behavior`.
- **`kubectl top` demora ~30s depois que metrics-server sobe** — ele precisa de 2 amostras antes de reportar.
- **Não use HPA + VPA na mesma métrica**. Se ambos mexem em CPU, brigam. VPA tem modo "Off"/"Initial" pra coexistir.
- **HPA não funciona com `Deployment` sem `requests` de CPU**. O erro fica em `kubectl describe hpa` — `unable to get metrics... missing request`.

## 🚦 Próximos passos
1. Releia a parte de QoS — é o que mais cai em entrevista
2. Veja `pratica/` em ordem: `metrics-server.sh` → `deployment.yaml` → `hpa.yaml` → `comandos.sh`
3. Gere carga e veja o HPA escalar em tempo real (`watch kubectl get hpa,pods`)
4. Encare o desafio: behavior customizado pra evitar escalonamento agressivo

## ✅ Auto-verificação
- [ ] Sei a diferença entre `requests` e `limits`
- [ ] Sei o que acontece quando CPU vs memória passa do limit
- [ ] Sei classificar um pod em Guaranteed / Burstable / BestEffort
- [ ] Instalei metrics-server e `kubectl top` funciona
- [ ] Vi um HPA escalar pods sob carga
- [ ] Sei a diferença entre HPA, VPA e Cluster Autoscaler

Próximo módulo: **Helm** — empacotando tudo isso em charts reutilizáveis.
