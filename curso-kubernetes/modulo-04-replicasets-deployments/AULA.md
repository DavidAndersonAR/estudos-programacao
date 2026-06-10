# Módulo 04 — ReplicaSets e Deployments

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que **NUNCA** rodamos Pod direto em produção
- Entender o que um **ReplicaSet** faz (e por que você quase nunca cria um na mão)
- Criar um **Deployment** declarativo com N réplicas
- Fazer **rolling update** e **rollback** sem derrubar o app
- Escalar com `kubectl scale`
- Ler `rollout status / history`

## 🤔 Por que NÃO criar Pod direto?

Você já criou Pod nos módulos anteriores. Funciona, mas tem 3 problemas graves:

1. **Pod morreu = morreu.** Não há auto-restart de Pod "solto". Se o processo dentro crashar, o `restartPolicy` reinicia o container — mas se o **Node** cair, o Pod some e ninguém sobe outro.
2. **Sem escala.** Quer 3 réplicas? Você cria 3 Pods na mão, com 3 nomes diferentes, em 3 YAMLs.
3. **Sem rolling update.** Deploy de nova versão = você deletar Pod, criar outro, torcer.

Por isso existe a **pirâmide de controladores**:

```
Deployment   ← VOCÊ cria isso (90% dos casos)
   │
   ▼ gerencia
ReplicaSet   ← criado automaticamente
   │
   ▼ gerencia
Pods         ← criados automaticamente
```

## 🧱 ReplicaSet

**O que faz**: mantém **exatamente N Pods** rodando, a qualquer custo. Pod morreu? Sobe outro. Pod a mais apareceu? Mata.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx       # ← TEM que bater com o selector
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
```

**Detalhe crucial**: o `selector.matchLabels` é como o ReplicaSet **acha** os Pods que ele controla. Se o `template.metadata.labels` não bate com o selector, o K8s recusa o YAML.

⚠️ **Você quase nunca cria ReplicaSet direto.** Por quê? Ele não sabe fazer rolling update. Pra trocar a imagem, você teria que matar tudo e subir de novo (downtime). Use **Deployment**.

## 🚀 Deployment

**O que faz**: gerencia ReplicaSets pra você, com superpoderes:
- **Rolling update**: troca Pods aos poucos, sem downtime
- **Rollback**: volta pra versão anterior com 1 comando
- **Histórico**: sabe quais versões você já rodou
- **Pause/Resume**: pausa um rollout no meio

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1   # quantos Pods podem estar OFF durante o update
      maxSurge: 1         # quantos Pods EXTRAS podem subir além do replicas
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

Quando você faz `kubectl apply -f` disso:
1. Deployment cria um **ReplicaSet** (com hash no nome, tipo `nginx-deploy-6f4b7c8d9`)
2. ReplicaSet cria 3 **Pods** (com mais um hash: `nginx-deploy-6f4b7c8d9-xkj2p`)
3. Você só precisa pensar no Deployment. O resto é automático.

## 🔄 Rolling Update na prática

Trocar a imagem (`nginx:1.25` → `nginx:1.27`):

```bash
kubectl set image deployment/nginx-deploy nginx=nginx:1.27
```

O que acontece nos bastidores:
1. Deployment cria um **novo ReplicaSet** (vazio, 0 réplicas)
2. Escala o novo pra 1, escala o antigo pra 2 (respeitando `maxSurge`/`maxUnavailable`)
3. Espera o Pod novo ficar Ready
4. Repete até o novo ter 3 e o antigo ter 0
5. ReplicaSet antigo fica parado (com 0 Pods) — guardado pra rollback

Acompanhar:
```bash
kubectl rollout status deployment/nginx-deploy
```

## ⚙️ Estratégias de update

### RollingUpdate (default)
Substitui aos poucos. **Zero downtime**, mas durante o rollout existem 2 versões rodando ao mesmo tempo. Use 99% do tempo.

- `maxUnavailable: 1` → posso ter no máximo 1 Pod fora do ar
- `maxSurge: 1` → posso subir 1 Pod a mais que o `replicas`

Também aceita percentual: `maxUnavailable: 25%`.

### Recreate
Mata **todos** os Pods e sobe os novos. **Tem downtime**. Use só quando:
- A app não tolera 2 versões simultâneas (ex: migration de schema incompatível)
- É um job batch ou stateful chato

```yaml
strategy:
  type: Recreate
```

## 📜 Histórico e Rollback

```bash
# Quais revisões já existiram?
kubectl rollout history deployment/nginx-deploy

# Detalhes da revisão 2
kubectl rollout history deployment/nginx-deploy --revision=2

# Voltar pra revisão anterior
kubectl rollout undo deployment/nginx-deploy

# Voltar pra uma revisão específica
kubectl rollout undo deployment/nginx-deploy --to-revision=1
```

Como o K8s sabe voltar? Cada `kubectl apply` que muda o `template` gera um **novo ReplicaSet**. Os ReplicaSets antigos ficam parados (com 0 réplicas). Rollback = escalar o ReplicaSet antigo de volta pra N.

💡 Por default, o K8s guarda **10 ReplicaSets antigos** (`spec.revisionHistoryLimit`).

## 📏 Escalar

Mudar número de réplicas sem editar YAML:

```bash
kubectl scale deployment/nginx-deploy --replicas=5
```

Útil pra reagir rápido a pico de tráfego. Pra automático, existe **HPA** (Horizontal Pod Autoscaler — módulo futuro).

⚠️ Se você só escala via comando, o YAML versionado fica desatualizado. Em produção, use **GitOps**: muda o YAML, commita, aplica.

## 🏷️ Selectors — o casamento Deployment ↔ Pod

```yaml
spec:
  selector:
    matchLabels:
      app: nginx        # ← Deployment procura Pods com esse label
  template:
    metadata:
      labels:
        app: nginx      # ← Pod nasce com esse label
```

Se eles não baterem, o Deployment não acha "seus" Pods e o `kubectl apply` falha. Selector é **imutável** depois de criado — pra mudar, deleta e cria de novo.

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl apply -f deploy.yaml` | Cria/atualiza Deployment |
| `kubectl get deploy` | Lista Deployments |
| `kubectl get rs` | Lista ReplicaSets (vê o hash) |
| `kubectl get pods -l app=nginx` | Pods filtrados por label |
| `kubectl scale deploy/X --replicas=5` | Muda réplicas |
| `kubectl set image deploy/X cont=img:tag` | Rolling update |
| `kubectl rollout status deploy/X` | Acompanha rollout |
| `kubectl rollout history deploy/X` | Histórico de revisões |
| `kubectl rollout undo deploy/X` | Rollback |
| `kubectl rollout pause deploy/X` | Pausa um rollout em andamento |
| `kubectl rollout resume deploy/X` | Despausa |
| `kubectl describe deploy X` | Detalhes + eventos |
| `kubectl delete deploy X` | Remove Deployment (e RS e Pods em cascata) |

## 💡 Detalhes que valem ouro

- **Pod com hash no nome** = nasceu de um ReplicaSet/Deployment. Pod sem hash = "pet" criado na mão (evite).
- **`kubectl edit deploy X`** abre o YAML pra editar ao vivo. Útil pra debug, ruim pra prod (não fica versionado).
- **`--record` foi deprecado.** Use anotações ou um sistema GitOps pra rastrear quem mudou o quê.
- **Rolling update só dispara se o `template` mudar.** Mudar só o `replicas` não cria revisão nova.
- **Readiness probe é amigo do rolling update.** Sem ela, o K8s acha que o Pod novo já tá pronto antes da app subir, e te deixa com downtime "invisível". (Módulo de probes vem aí.)
- **`kubectl rollout status` retorna exit code != 0 se falhar** — perfeito pra CI/CD detectar deploy quebrado.

## 🚦 Próximos passos
1. Suba o cluster do Módulo 1 (`kind create cluster --name estudo` se não tiver)
2. Veja `pratica/comandos.sh` — passo a passo guiado
3. Encare o `desafio/` — Deployment + rolling update + rollback simulando bug

## ✅ Auto-verificação
- [ ] Sei explicar por que Deployment > Pod solto
- [ ] Entendo a cadeia Deployment → ReplicaSet → Pod
- [ ] Consigo fazer rolling update com `kubectl set image`
- [ ] Sei fazer rollback com `kubectl rollout undo`
- [ ] Entendo `maxUnavailable` vs `maxSurge`
- [ ] Sei a diferença RollingUpdate vs Recreate

Próximo módulo: **Services** — expor seu Deployment pro mundo (ou pra outros Pods).
