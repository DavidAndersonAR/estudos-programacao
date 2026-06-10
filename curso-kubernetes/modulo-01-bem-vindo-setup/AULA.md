# Módulo 01 — Bem-vindo + Setup

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que Kubernetes resolve
- Instalar `kind` e subir um cluster local
- Diferenciar **Node**, **Pod** e **Container**
- Rodar seu primeiro Pod

## ☸️ O que é Kubernetes (e o que ele resolve)?

Docker resolveu "como rodar um container". Kubernetes resolve **"como rodar 1000 containers em 50 máquinas, com auto-reinício, auto-escalonamento, deploy sem downtime, balanceamento de carga, etc"**.

Kubernetes é um **orquestrador** — ele cuida do ciclo de vida dos containers em escala:
- **Self-healing**: container morreu? Sobe outro. Node caiu? Move workload pra outro.
- **Scaling**: tráfego dobrou? Sobe mais réplicas. Diminuiu? Reduz.
- **Service discovery**: containers se acham por nome, sem se importar com IP.
- **Rolling updates**: deploy de nova versão sem derrubar a antiga.
- **Declarativo**: você descreve o estado desejado, K8s cuida de chegar lá.

Quem usa: literalmente toda big tech. Google (criou), Amazon, Netflix, Uber, Spotify, Itaú, Nubank, etc.

## 🧱 Os 3 conceitos essenciais

### 1. Node
Uma **máquina** (física ou VM) no cluster. Onde os containers rodam.

### 2. Pod
A **menor unidade** do K8s. Um pod tem 1 ou mais containers que **compartilham rede e storage**. Geralmente é 1 container por pod, mas patterns como sidecar usam vários.

### 3. Container
Container Docker (ou similar) rodando dentro de um Pod.

```
Cluster
 ├─ Node 1
 │   ├─ Pod A (1 container)
 │   └─ Pod B (2 containers — app + sidecar)
 └─ Node 2
     └─ Pod C (1 container)
```

## 🛠️ Componentes do cluster (visão rápida)

**Control plane** (cérebro):
- **API Server**: porta de entrada, recebe todos os comandos
- **etcd**: banco de dados do cluster (todo o estado fica aqui)
- **Scheduler**: decide em qual node cada pod vai rodar
- **Controller Manager**: garante que o estado real bate com o desejado

**Nodes** (workers):
- **kubelet**: agente em cada node — fala com API Server, gerencia pods
- **kube-proxy**: rede dos pods
- **Container runtime**: Docker, containerd, CRI-O

Você não precisa saber tudo isso de cor agora. Só saber que existe.

## 🚀 Setup: kind (Kubernetes in Docker)

`kind` roda um cluster K8s **dentro de containers Docker**. Perfeito pra estudar — não precisa de VM nem cloud.

### Instalar via winget (Windows)
```powershell
winget install Kubernetes.kind
```

Verificar:
```bash
kind version
```

### Criar primeiro cluster
```bash
kind create cluster --name estudo
```

Demora ~30s na primeira vez (baixa imagem do K8s). Depois é instantâneo.

Cluster criado. O `kubectl` já foi configurado pra apontar pra ele.

```bash
kubectl cluster-info
kubectl get nodes
```

## 🎮 Primeiro Pod

```bash
# Cria pod rodando nginx
kubectl run meu-nginx --image=nginx

# Lista pods
kubectl get pods

# Detalhes
kubectl describe pod meu-nginx

# Logs
kubectl logs meu-nginx

# Entrar dentro do pod
kubectl exec -it meu-nginx -- sh

# Deletar
kubectl delete pod meu-nginx
```

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl cluster-info` | Info do cluster atual |
| `kubectl get nodes` | Lista nodes |
| `kubectl get pods` | Lista pods (do namespace default) |
| `kubectl get pods -A` | Pods de TODOS os namespaces |
| `kubectl describe pod NOME` | Detalhes completos |
| `kubectl logs NOME` | Logs do container |
| `kubectl logs -f NOME` | Logs em tempo real |
| `kubectl exec -it NOME -- sh` | Entra no container |
| `kubectl delete pod NOME` | Remove pod |
| `kubectl apply -f arquivo.yaml` | Aplica manifest YAML (modo declarativo) |
| `kubectl run NOME --image=X` | Cria pod rápido (imperativo) |
| `kubectl config current-context` | Qual cluster você tá usando |

## 💡 Detalhes que valem ouro
- **Declarativo > imperativo**: prefira YAML + `kubectl apply -f` em vez de `kubectl run`. YAML versionado no git = infraestrutura como código.
- **`kubectl` é case-sensitive**. `pod` ≠ `Pod`. Recursos usam plural em comandos (`pods`, `services`) mas singular em YAML (`Pod`, `Service`).
- **Tudo é objeto da API**: pod, deployment, service, secret... cada um tem `kubectl get/describe/edit/delete`.
- **Setup um alias** se digitar `kubectl` 100x/dia te irrita: `alias k=kubectl`.
- **Contexts**: você pode ter vários clusters (dev, staging, prod) e alternar com `kubectl config use-context NOME`.

## 🚦 Próximos passos
1. Instale o `kind` (`winget install Kubernetes.kind`)
2. Crie o cluster (`kind create cluster --name estudo`)
3. Rode `kubectl get nodes`
4. Veja `pratica/comandos.sh`
5. Encare o desafio

## ✅ Auto-verificação
- [ ] Sei a diferença Node / Pod / Container
- [ ] kind instalado e cluster rodando
- [ ] `kubectl get nodes` mostra meu node
- [ ] Sei rodar pod com `kubectl run`

Próximo módulo: **Pods** — pra valer.
