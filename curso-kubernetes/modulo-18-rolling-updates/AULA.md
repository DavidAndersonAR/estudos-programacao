# Módulo 18 — Rolling Updates e Estratégias de Deploy

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar **RollingUpdate** vs **Recreate** e quando usar cada um
- Calcular `maxUnavailable` + `maxSurge` e prever o comportamento do rollout
- Usar `kubectl rollout` pra pausar, retomar, ver histórico e fazer **undo**
- Implementar **Blue/Green** e **Canary** manualmente (sem Argo Rollouts)
- Saber quando ir além do que o Deployment nativo entrega

## 🤔 Por que estratégia de deploy importa?

Você tem 4 réplicas rodando v1 e quer subir v2. Três jeitos errados:
- **Para tudo, sobe a nova** → downtime (clássico legado anos 2000).
- **Sobe a nova ao lado, derruba a antiga na mão** → erro humano, sem rollback automático.
- **Reza** → 🙏

Kubernetes resolve isso de forma **declarativa** via `strategy` do Deployment. Você descreve **como** trocar v1 por v2 e o controller cuida.

## 🔁 strategy.type: as duas nativas

### RollingUpdate (default)
Sobe pods novos **aos poucos**, derruba os antigos **aos poucos**. Zero downtime se a app tiver `readinessProbe` honesto.

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1   # quantos podem ficar fora durante o update
      maxSurge: 1         # quantos a mais podem subir além do desired
```

### Recreate
Mata **todos** os pods da versão antiga, depois sobe a nova. Tem downtime, mas garante **1 versão por vez**.

```yaml
spec:
  strategy:
    type: Recreate
```

Quando usar `Recreate`?
- App que **não tolera 2 versões em paralelo** (ex.: migration de schema incompatível).
- App **stateful com lock global** (1 instância só pode estar viva por vez).
- Janela de manutenção planejada.

## 🧮 Fórmula do maxUnavailable + maxSurge

Você tem `replicas: 10`. Durante o rollout:
- Pods **disponíveis** nunca podem ser menos que `replicas - maxUnavailable`.
- Pods **totais** (velhos + novos) nunca podem passar de `replicas + maxSurge`.

Aceitam **número absoluto** (`2`) ou **percentual** (`25%`, arredonda pra cima no surge e pra baixo no unavailable).

### Exemplos com `replicas: 10`
| maxUnavailable | maxSurge | Comportamento |
|---|---|---|
| `25%` (2) | `25%` (3) | Default. Sobe 3 novos → mata 2 antigos → repete. Rápido. |
| `0` | `1` | Conservador. **Nunca fica abaixo de 10 disponíveis**. Sobe 1 novo, espera Ready, derruba 1 antigo. Lento mas seguro. |
| `1` | `0` | Sem surge (útil em cluster apertado). Derruba 1 antigo → sobe 1 novo. **Fica em 9 durante o update**. |
| `50%` | `50%` | Agressivo. Bom pra apps stateless leves. |

> ⚠️ `maxUnavailable: 0` + `maxSurge: 0` é **inválido** — rollout travaria pra sempre.

## 🎛️ kubectl rollout — o controle do deploy

```bash
# Acompanhar em tempo real
kubectl rollout status deployment/minha-app

# Ver histórico
kubectl rollout history deployment/minha-app
kubectl rollout history deployment/minha-app --revision=3

# Voltar pra revisão anterior
kubectl rollout undo deployment/minha-app

# Voltar pra revisão específica
kubectl rollout undo deployment/minha-app --to-revision=2

# Pausar (útil pra rollout manual / canary caseiro)
kubectl rollout pause deployment/minha-app

# Retomar
kubectl rollout resume deployment/minha-app

# Forçar restart (recria pods com a mesma imagem — útil pra recarregar Secret/ConfigMap)
kubectl rollout restart deployment/minha-app
```

### O ciclo de vida de um rollout
1. Você muda algo (ex.: `image: v1` → `image: v2`) e dá `kubectl apply`.
2. Deployment cria um **novo ReplicaSet** (RS-v2) com 0 réplicas.
3. RS-v2 escala pra `maxSurge`, RS-v1 reduz respeitando `maxUnavailable`.
4. A cada pod novo `Ready`, mais um velho cai.
5. Quando RS-v2 == `replicas` e RS-v1 == 0 → rollout completo.
6. RS-v1 fica guardado (zerado) pra `rollout undo`. `revisionHistoryLimit` controla quantos manter (default 10).

## 🩺 Readiness probe — o segredo do zero-downtime

Sem `readinessProbe`, K8s considera o pod pronto assim que o container starta. Mas sua app pode levar 5s pra abrir a porta — e nesses 5s o Service manda tráfego pra um pod que ainda não responde = **erro 502/connection refused**.

```yaml
readinessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 2
  periodSeconds: 3
  failureThreshold: 2
```

**Regra de ouro**: `maxUnavailable: 0` + `readinessProbe` honesto = zero-downtime real.

## 🔵🟢 Blue/Green

Duas versões **completas** rodando lado a lado. Service aponta pra uma só. Cutover = mudar o `selector`.

```
    ┌─ Service (selector: version=blue)
    │
    ├─→ Deployment blue (v1)  ← recebe 100% do tráfego
    └─  Deployment green (v2) ← warm, recebendo 0%
```

Quando estiver confiante:
```bash
kubectl patch service minha-app -p '{"spec":{"selector":{"version":"green"}}}'
```
Tráfego cortado pra v1, agora vai pra v2. **Rollback = mudar selector de volta**.

### Vantagens / desvantagens
- ✅ Rollback **instantâneo** (1 patch).
- ✅ Testa v2 inteira em prod (com tráfego sintético) antes do cutover.
- ❌ Custa **2x recursos** durante a janela.
- ❌ Schema do DB tem que servir as duas versões (compatível pra frente/trás).

> Ferramenta que automatiza: **Argo Rollouts** (CRD `Rollout` com `strategy.blueGreen`).

## 🐤 Canary

Manda **uma fatia pequena** (5%, 10%) do tráfego pra v2. Observa métricas (erro, latência). Se OK, aumenta. Se ruim, derruba.

### Canary "pobre" (mesmo Service, mesma label)
Mais simples: 2 Deployments com **mesma label** que o Service casa, mas **réplicas diferentes**.
- v1: 9 réplicas
- v2: 1 réplica
- Service balanceia round-robin → ~10% vai pra v2.

```yaml
# v1
spec:
  replicas: 9
  template:
    metadata:
      labels:
        app: minha-app   # ← mesma do Service
---
# v2
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: minha-app   # ← mesma do Service (canary recebe 10%)
```

### Canary com Ingress weights (mais preciso)
Nginx Ingress / Traefik / Istio aceitam anotação tipo:
```yaml
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-weight: "10"
```
Aí o tráfego é repartido por **peso real**, independente de número de pods.

### Canary com Argo Rollouts
```yaml
strategy:
  canary:
    steps:
      - setWeight: 10
      - pause: {duration: 5m}
      - setWeight: 25
      - pause: {duration: 5m}
      - setWeight: 50
      - pause: {duration: 10m}
```
Promove ou aborta automático com base em **AnalysisTemplate** (consulta Prometheus, etc).

## 🅰️🅱️ A/B Testing (header-based)

Canary divide por **percentual**. A/B divide por **regra** — ex.: header `X-Beta: true` vai pra v2, resto fica em v1.

```yaml
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-by-header: "X-Beta"
nginx.ingress.kubernetes.io/canary-by-header-value: "true"
```

Usado pra:
- Beta program (usuários opt-in vão pra v2).
- Feature flags por região/dispositivo.
- Dogfooding interno (funcionários veem v2).

## 🆚 Quando usar o quê?

| Cenário | Estratégia |
|---|---|
| App stateless web normal | **RollingUpdate** (default) |
| Migration incompatível | **Recreate** ou Blue/Green com schema dual |
| Stack crítica + budget pra 2x recurso | **Blue/Green** |
| Quer confiança antes de promover | **Canary** |
| Quer testar com um subset específico | **A/B testing** |
| Quer tudo automatizado com análise de métricas | **Argo Rollouts** |

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl rollout status deploy/X` | Acompanha o rollout |
| `kubectl rollout history deploy/X` | Lista revisões |
| `kubectl rollout undo deploy/X` | Rollback pra anterior |
| `kubectl rollout undo deploy/X --to-revision=N` | Rollback pra revisão N |
| `kubectl rollout pause deploy/X` | Congela o rollout no estado atual |
| `kubectl rollout resume deploy/X` | Retoma |
| `kubectl rollout restart deploy/X` | Recria pods (mesma imagem) |
| `kubectl set image deploy/X c=img:v2` | Imperativo: troca imagem |
| `kubectl patch svc X -p '{...}'` | Patch JSON (útil pra mudar selector blue/green) |
| `kubectl get rs` | Vê os ReplicaSets (1 por revisão) |

## 💡 Detalhes que valem ouro
- **Sem readinessProbe, RollingUpdate é uma ilusão de zero-downtime.** Adicione *sempre*.
- **`maxUnavailable: 0`** é o setting "produção séria" — paga em velocidade, ganha em disponibilidade.
- **`kubectl set image` cria revisão nova.** `kubectl edit` em vez de `apply` também — mas o histórico fica confuso. Use `apply` com manifesto versionado.
- **Rollback NÃO restaura ConfigMap/Secret.** Se v2 mudou um ConfigMap, o `undo` volta a imagem mas o ConfigMap continua novo. Versione tudo junto (ex.: nome `config-v2`).
- **`revisionHistoryLimit: 0`** = sem histórico → sem undo. Não faça isso.
- **Argo Rollouts vale a pena** quando você precisa de canary baseado em métricas, automação de promoção, ou integração com tráfego (Istio/Linkerd).
- **Blue/Green com DB compartilhado** exige que v1 e v2 leiam/escrevam o mesmo schema. Migrations precisam ser **expand-contract** (adiciona coluna nova compatível → migra app → remove coluna velha em outra release).

## 🚦 Próximos passos
1. Leia `pratica/v1.yaml` e `pratica/v2.yaml` pra ver a diferença.
2. Rode `pratica/comandos.sh` — vai te levar por rollout, pausa, retomada e undo.
3. Encare o desafio: implemente blue/green e canary na mão.

## ✅ Auto-verificação
- [ ] Sei a diferença RollingUpdate vs Recreate
- [ ] Sei calcular maxUnavailable + maxSurge
- [ ] Sei pausar, retomar e fazer undo de um rollout
- [ ] Implementei blue/green manualmente (Service + selector)
- [ ] Implementei canary manualmente (réplicas desbalanceadas)
- [ ] Entendi por que readinessProbe é essencial

Próximo módulo: **Helm** — empacotar tudo isso em chart reutilizável.
