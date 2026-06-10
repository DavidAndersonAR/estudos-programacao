# Módulo 05 — Services

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar **por que** Pod IP não serve pra rede de verdade
- Diferenciar **ClusterIP**, **NodePort**, **LoadBalancer** e **ExternalName**
- Conectar Service a Pods via **selectors** (labels)
- Usar **DNS interno** do K8s pra fazer pods conversarem
- Entender **endpoints** e o que é **headless service**

## 🤔 O problema: pods são gado, não pets

No módulo anterior você viu que um Deployment cria/recria pods conforme precisa. Cada pod tem um IP — mas:
- Pod morreu? Sobe outro com **IP diferente**.
- Escalou de 2 pra 10 réplicas? **10 IPs novos**.
- Rolling update? **Todos os IPs mudam**.

Se o seu frontend tinha o IP do pod backend hardcoded, ele quebra a cada deploy. Pod IP é **efêmero** (vida curta) — não dá pra confiar.

Resumo: **não fale com Pods diretamente. Fale com um Service.**

## 🧱 O que é um Service

Service é uma **abstração estável** na frente de um conjunto de Pods. Ele entrega:

1. **IP fixo** (ClusterIP) — não muda enquanto o Service existir.
2. **Nome DNS** — `meu-svc.default.svc.cluster.local`. Outros pods só chamam pelo nome.
3. **Load balancing básico** — distribui requisições entre os pods que casam com o selector (round-robin por padrão).
4. **Service discovery** — não precisa de Consul/Eureka pra microsserviços se acharem dentro do cluster.

```
                    [ Service: api-svc ]   ← IP fixo: 10.96.42.7
                            │                 nome DNS: api-svc
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
          Pod api-1     Pod api-2     Pod api-3
          IP: 10.244.0.5  10.244.0.6   10.244.0.7   (efêmeros — não importa)
```

Quem decide quais pods entram no Service? **Labels + selector**.

## 🏷️ Selectors: o casamento Service ↔ Pods

O Service tem um campo `selector`. Ele pega TODOS os Pods do namespace cujos labels casam com esse selector.

```yaml
# Pods (criados via Deployment) com label app=api
metadata:
  labels:
    app: api

# Service que pega esses pods
spec:
  selector:
    app: api    # casa com qualquer pod que tenha app=api
```

Não tem hierarquia rígida tipo "Service dono de Pods". É um **filtro dinâmico**: pod novo entrou com `app=api` → automaticamente entra no Service. Pod morreu → sai. Tudo via labels.

## 🚪 Os 4 tipos de Service

### 1. ClusterIP (default)
**Só acessível de dentro do cluster.** Ganha um IP da rede interna do K8s.
Pra que serve: comunicação **pod-a-pod** (frontend → backend, backend → cache, etc).
É o tipo mais comum.

```yaml
spec:
  type: ClusterIP   # pode omitir, é o default
  selector:
    app: api
  ports:
    - port: 80          # porta DO SERVICE
      targetPort: 8080  # porta DO POD (onde a app escuta)
```

### 2. NodePort
**Abre uma porta no IP de TODOS os Nodes do cluster.** Faixa: **30000-32767**.
Qualquer um que conseguir falar com um Node naquela porta atinge o Service.

Pra que serve: expor pro mundo externo de forma simples (mas crua — sem TLS, sem path routing).

```yaml
spec:
  type: NodePort
  selector:
    app: api
  ports:
    - port: 80         # porta do Service interno
      targetPort: 8080 # porta do pod
      nodePort: 30080  # porta no Node (opcional — K8s aloca uma se omitir)
```

Acessa em: `http://IP_DE_QUALQUER_NODE:30080`.

⚠️ **No `kind`** o node é um container Docker — a porta não é exposta no host automaticamente. Você precisa configurar `extraPortMappings` no kind, OU usar `kubectl port-forward`. A prática vai usar port-forward (mais simples).

### 3. LoadBalancer
**Provisiona um load balancer real do cloud provider** (AWS ELB, GCP LB, Azure LB). Ganha um IP público externo de verdade.

```yaml
spec:
  type: LoadBalancer
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 8080
```

Em cluster local (`kind`/`minikube`) fica `Pending` pra sempre — não tem cloud pra provisionar. Em produção é o caminho normal pra expor um serviço HTTP simples.

### 4. ExternalName
**Não tem selector nem proxy.** É só um **CNAME DNS** apontando pra um host fora do cluster.

```yaml
spec:
  type: ExternalName
  externalName: db.producao.empresa.com
```

Pra que serve: deixar uma app interna chamar `meu-db-externo.default.svc.cluster.local` em vez do hostname real. Útil pra migrar pra cloud sem mudar código.

## 🌐 DNS interno: o nome do Service vira hostname

K8s roda um CoreDNS dentro do cluster. Toda vez que você cria um Service, ele ganha um nome:

```
<svc-name>.<namespace>.svc.cluster.local
```

Exemplo: Service `api-svc` no namespace `default` → `api-svc.default.svc.cluster.local`.

Mas de dentro do mesmo namespace você só precisa do nome curto: **`api-svc`** funciona. Os outros sufixos o resolver completa.

```bash
# De dentro de um pod no namespace default:
curl http://api-svc/status         # funciona — DNS resolve pro ClusterIP
curl http://api-svc.outro-ns/      # se o svc estiver em outro namespace
```

**É isso que torna microsserviços simples no K8s.** Sem Consul, sem registrar/desregistrar nada. Subiu Service, virou DNS.

## 🔍 Endpoints: por baixo do capô

O Service não fala diretamente com os Pods — ele tem um objeto associado chamado **Endpoints** (ou EndpointSlice nas versões mais novas), que é a lista de IPs:porta que casam com o selector.

```bash
kubectl get endpoints
# NAME       ENDPOINTS                                  AGE
# api-svc    10.244.0.5:8080,10.244.0.6:8080            2m
```

Quando um pod morre, o controlador do Endpoints atualiza a lista. O `kube-proxy` em cada node usa essa lista pra balancear o tráfego (via iptables ou IPVS).

Endpoints vazio = Service não tem pra onde mandar request. Bug clássico: **selector errado** ou **app não tá Ready**. Sempre cheque `kubectl get endpoints` quando o Service "não funciona".

## 👻 Headless Service

E se você NÃO quiser load balancing? Quer falar com cada pod individualmente (ex: bancos de dados em cluster, replicação)?

Setar `clusterIP: None`:

```yaml
spec:
  clusterIP: None
  selector:
    app: postgres
```

O DNS então **retorna direto os IPs dos pods** (um registro A por pod), em vez de um único ClusterIP. Combinado com **StatefulSets** (módulo 09) dá pra acessar `pod-0.postgres-svc`, `pod-1.postgres-svc`, etc.

Não usa no dia a dia de app web — é coisa de stateful workload.

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl get svc` | Lista services |
| `kubectl get svc -o wide` | Mostra selector também |
| `kubectl describe svc NOME` | Detalhes (endpoints inclusos) |
| `kubectl get endpoints` | Lista os IPs por trás de cada svc |
| `kubectl get endpoints NOME` | Endpoints de um svc específico |
| `kubectl expose deploy NOME --port=80` | Cria service rápido (imperativo) |
| `kubectl port-forward svc/NOME 8080:80` | Mapeia svc pra localhost (debug) |
| `kubectl run tmp --rm -it --image=curlimages/curl -- sh` | Pod descartável pra testar DNS |

## 💡 Detalhes que valem ouro

- **`port` vs `targetPort` vs `nodePort`** — confunde todo mundo no começo:
  - `port`: porta DO Service (na rede interna do cluster).
  - `targetPort`: porta DO Pod (onde a app de fato escuta).
  - `nodePort`: porta no host do Node (só em NodePort/LoadBalancer).
- **Service não enxerga pods de outro cluster.** Selector é por namespace + labels — fim.
- **Sem `selector` = Service "manual"** — você precisa criar Endpoints na mão. Útil pra expor algo fora do cluster como se fosse um Service.
- **`kube-proxy` não é um proxy reverso L7.** Ele faz NAT em nível de iptables. Pra path routing/HTTPS use Ingress (módulo 11).
- **Round-robin não é garantido** — depende do modo do kube-proxy (iptables faz probabilístico, IPVS faz round-robin real).
- **Imperativo rápido**: `kubectl expose deployment minha-api --port=80 --target-port=8080` cria um ClusterIP na hora.

## 🚦 Próximos passos
1. Leia `pratica/deployment.yaml`, `service-clusterip.yaml` e `service-nodeport.yaml`
2. Rode `pratica/comandos.sh` linha a linha
3. Entre num pod e teste o DNS interno
4. Encare o `desafio/` — outro pod consumindo o Service por nome

## ✅ Auto-verificação
- [ ] Sei explicar por que não dá pra confiar em Pod IP
- [ ] Sei a diferença ClusterIP / NodePort / LoadBalancer / ExternalName
- [ ] Sei o que é selector e como Service casa com Pods
- [ ] Sei o nome DNS completo de um Service
- [ ] Sei o que checar quando `kubectl get endpoints` volta vazio

Próximo módulo: **Namespaces** — dividindo o cluster.
