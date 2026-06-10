# Módulo 06 — Namespaces

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que namespace **é** (isolamento lógico) e o que **não é** (isolamento físico)
- Criar, listar e deletar namespaces
- Rodar comandos `kubectl` em namespace específico (e mudar o default)
- Limitar recursos com **ResourceQuota** e **LimitRange**
- Acessar serviços entre namespaces via DNS
- Saber quais objetos são namespaced e quais são cluster-wide

## 🧠 O que é Namespace?

Namespace é uma **divisão lógica do cluster**. Pense como "pastas" pra organizar objetos.

> ⚠️ **Atenção — não é isolamento físico!**
> Pods do namespace `dev` e do `prod` podem estar **no mesmo node**, **compartilhando CPU, RAM e rede**. Namespace **não** é VM, não é container, não é firewall. É só um agrupamento lógico de nomes + escopo de permissões + escopo de quotas.

Pra **isolamento real** (segurança/rede) você precisa de:
- **NetworkPolicy** (firewall entre pods)
- **RBAC** (quem pode mexer no quê)
- **ResourceQuota** (limite de consumo)
- Em casos extremos: cluster separado mesmo.

## 🤔 Pra que serve então?

- **Organização**: separar times (`time-a`, `time-b`), ambientes (`dev`, `staging`, `prod`), produtos.
- **Evitar colisão de nomes**: dois pods chamados `api` podem coexistir em ns diferentes.
- **Aplicar quotas**: limitar quanto cada time pode consumir.
- **Aplicar políticas**: RBAC e NetworkPolicy ficam mais fáceis com escopo bem definido.
- **Limpeza fácil**: `kubectl delete ns dev` apaga **TUDO** que tava dentro.

## 📂 Os namespaces que já vêm no cluster

```bash
kubectl get ns
```

Você vai ver pelo menos 4:

| Namespace | Pra que serve |
|---|---|
| `default` | Onde tudo cai se você não disser o ns |
| `kube-system` | Componentes do K8s (CoreDNS, kube-proxy, scheduler) — **não mexa** |
| `kube-public` | Coisas legíveis por qualquer um, mesmo sem autenticação (raro usar) |
| `kube-node-lease` | Heartbeat dos nodes (interno do K8s, ignore) |

## 🛠️ Criar e deletar

**Imperativo:**
```bash
kubectl create namespace dev
kubectl delete namespace dev   # apaga TUDO dentro — cuidado!
```

**Declarativo (preferido):**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

```bash
kubectl apply -f ns.yaml
```

## 🎯 Usar namespace nos comandos

Por padrão tudo cai em `default`. Pra mirar outro:

```bash
kubectl get pods -n dev
kubectl apply -f deploy.yaml -n staging
kubectl logs meu-pod -n prod
```

E pra ver **todos os namespaces de uma vez**:
```bash
kubectl get pods -A
# ou
kubectl get pods --all-namespaces
```

## 🔧 Mudar o namespace default (sem digitar `-n` toda hora)

Isso muda o ns padrão **do seu kubectl**, do contexto atual:

```bash
kubectl config set-context --current --namespace=dev

# Confere
kubectl config view --minify | grep namespace:
```

Agora `kubectl get pods` (sem `-n`) lista os pods de `dev`.

> 💡 Existe o utilitário **`kubens`** (do projeto `kubectx`) que faz isso de forma interativa. Vale instalar.

## 📊 ResourceQuota — limitar consumo por namespace

Você cria uma quota e o K8s **rejeita** qualquer criação que ultrapasse:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-dev
  namespace: dev
spec:
  hard:
    pods: "5"                  # no máximo 5 pods
    requests.cpu: "2"          # soma dos requests ≤ 2 CPUs
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
```

Se alguém tentar criar o 6º pod → erro `exceeded quota`.

> ⚠️ Quando existe ResourceQuota com `requests.cpu`/`requests.memory`, **todo pod precisa declarar requests/limits**. Senão é rejeitado. Por isso normalmente vem junto com LimitRange.

## 📏 LimitRange — defaults pra quem esqueceu

Define valores **padrão** de request/limit pra pods do namespace:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: defaults-dev
  namespace: dev
spec:
  limits:
  - default:                   # vai virar o "limit" se o pod não declarar
      cpu: 500m
      memory: 512Mi
    defaultRequest:            # vira o "request" se o pod não declarar
      cpu: 100m
      memory: 128Mi
    type: Container
```

Combinação clássica: **LimitRange** preenche defaults + **ResourceQuota** impede estouro.

## 🌐 DNS entre namespaces

Service no mesmo ns: `meu-svc`
Service em outro ns: `meu-svc.outro-ns`
FQDN completo: `meu-svc.outro-ns.svc.cluster.local`

Exemplo: pod em `dev` quer falar com `api` que tá em `staging`:
```bash
curl http://api.staging.svc.cluster.local:8080
# ou só:
curl http://api.staging:8080
```

## 🚫 O que NÃO é namespaced (é cluster-wide)

Alguns objetos vivem fora de qualquer namespace — são do cluster inteiro:

| Cluster-wide | Por quê |
|---|---|
| `Node` | É máquina, não tem dono lógico |
| `PersistentVolume` (PV) | Volume é do cluster; só o **claim** (PVC) é namespaced |
| `Namespace` | Óbvio — ele é o próprio escopo |
| `ClusterRole` / `ClusterRoleBinding` | RBAC com escopo de cluster |
| `StorageClass` | Configuração global de storage |
| `CustomResourceDefinition` (CRD) | Define tipos novos pro cluster todo |

Pra ver tudo:
```bash
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
```

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl get ns` | Lista namespaces |
| `kubectl create ns NOME` | Cria ns |
| `kubectl delete ns NOME` | **Apaga ns e TUDO dentro** |
| `kubectl get pods -n dev` | Pods do ns `dev` |
| `kubectl get pods -A` | Pods de **todos** os ns |
| `kubectl config set-context --current --namespace=dev` | Muda ns default |
| `kubectl config view --minify \| grep namespace` | Ver ns default atual |
| `kubectl get resourcequota -n dev` | Lista quotas do ns |
| `kubectl describe quota quota-dev -n dev` | Ver consumo vs limite |
| `kubectl api-resources --namespaced=false` | O que é cluster-wide |

## 💡 Detalhes que valem ouro

- **Namespace não isola rede por padrão.** Um pod em `dev` consegue falar com um pod em `prod` se souber o IP/DNS. Quer bloquear? NetworkPolicy.
- **`kubectl delete ns X` é destruidor de mundos.** Vai junto: pods, services, secrets, configmaps, deployments, PVCs… **não tem undo**. Em prod, pense duas vezes.
- **Mudou de contexto?** O ns default volta pro do novo contexto. Sempre confirme com `kubectl config view --minify`.
- **Quota conta com `Pending` também.** Se 4 pods estão Running e 1 Pending, o 6º vai falhar mesmo com 1 vaga "livre" aparente.
- **Não dá pra namespacear "por baixo" de outro ns.** Não existe ns aninhado. É lista plana.
- **Boa prática:** um ns por ambiente (dev/staging/prod) OU um ns por time/produto. Misturar os dois (ex: `time-a-dev`) também é comum em clusters grandes.

## 🚦 Próximos passos

1. Leia esta aula
2. Rode `pratica/comandos.sh` linha a linha — crie os 3 ambientes e veja a quota bloqueando
3. Encare o desafio: `desafio/comandos.sh`

## ✅ Auto-verificação
- [ ] Entendo que namespace é **lógico**, não físico
- [ ] Sei criar, deletar e mudar o ns default
- [ ] Sei que `kubectl get pods -A` mostra tudo
- [ ] Sei pra que serve ResourceQuota e LimitRange
- [ ] Sei chamar service de outro ns por DNS (`svc.ns.svc.cluster.local`)
- [ ] Sei que Node/PV/ClusterRole **não** são namespaced

Próximo módulo: **ConfigMaps & Secrets** — configurar app sem rebuildar imagem.
