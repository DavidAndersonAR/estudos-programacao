# Módulo 09 — StatefulSets

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que **Deployment não serve** pra banco de dados
- Descrever as 4 garantias do **StatefulSet** (nome, DNS, ordem, storage)
- Entender o papel do **Headless Service** (clusterIP: None)
- Usar **volumeClaimTemplates** pra dar 1 PVC por réplica
- Subir um Postgres com identidade e storage estáveis

## 🤔 Por que Deployment não serve pra banco?

Deployment trata pods como **gado, não animal de estimação** (cattle, not pets). Pods são intercambiáveis:
- Nome aleatório: `nginx-7d8f9c-abcde`, `nginx-7d8f9c-xyz12`
- Sem identidade fixa — se um morre, o substituto tem nome novo
- Compartilham o mesmo volume (ou nenhum)
- Sobem/descem em paralelo, sem ordem garantida

**Pra app web stateless, isso é ótimo.** Pra banco de dados, é catastrófico:
- Postgres-primário e Postgres-replica **precisam saber quem é quem**
- O dado do pod 0 **não pode** ser igual ao do pod 1 (cada um tem seu disco)
- Replicação precisa de ordem: **primário sobe primeiro**, replicas depois
- Cliente precisa endereçar **um pod específico**, não "qualquer um do pool"

Pra isso existe o **StatefulSet**.

## 🧱 As 4 garantias do StatefulSet

### 1. Nome estável e previsível
Pods nomeados `<statefulset>-<ordinal>`, começando em 0:
```
postgres-0
postgres-1
postgres-2
```
Se `postgres-1` morrer, o substituto **vai se chamar `postgres-1` de novo**. Identidade preservada.

### 2. DNS estável (por pod)
Cada pod tem entrada DNS própria:
```
postgres-0.postgres-svc.default.svc.cluster.local
postgres-1.postgres-svc.default.svc.cluster.local
```
Sua app pode fazer `psql -h postgres-0.postgres-svc` e cair **sempre naquele pod**. Isso depende do **Headless Service** (próxima seção).

### 3. Ordem de start/stop
- **Subindo**: `postgres-0` precisa estar Ready antes do `postgres-1` começar. Depois `postgres-1` antes do `postgres-2`.
- **Descendo**: ordem inversa. Mata `postgres-2`, depois `postgres-1`, depois `postgres-0`.

Isso permite: primário sobe primeiro → replicas se conectam nele → tudo funciona.

### 4. Storage por réplica (volumeClaimTemplates)
Diferente do Deployment (que usaria 1 PVC compartilhado), o StatefulSet **cria 1 PVC pra cada pod**:
```
postgres-data-postgres-0  →  PV próprio
postgres-data-postgres-1  →  PV próprio
postgres-data-postgres-2  →  PV próprio
```
Se `postgres-1` morrer e for recriado, ele **monta o MESMO PVC de antes**. Dado preservado.

E se você deletar o StatefulSet? Os PVCs **NÃO são deletados** — segurança contra perda de dado. Limpe manualmente se quiser.

## 📡 Headless Service (clusterIP: None)

Service normal: tem IP virtual (ClusterIP), faz load balancing nos pods. Bom pra stateless.

**Headless Service**: não tem IP virtual (`clusterIP: None`). Em vez disso, o DNS resolve direto pros IPs dos pods individuais:
- `nslookup postgres-svc` → retorna IPs de TODOS os pods do set
- `nslookup postgres-0.postgres-svc` → retorna IP só do pod 0

É o que dá o "DNS estável por pod" do item 2. **StatefulSet precisa de Headless Service** pra DNS funcionar — declare no campo `serviceName`.

## 📄 Anatomia de um StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-svc     # 👈 nome do Headless Service
  replicas: 3
  selector:
    matchLabels: { app: postgres }
  template:
    metadata:
      labels: { app: postgres }
    spec:
      containers:
        - name: postgres
          image: postgres:16
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:          # 👈 template, NÃO um PVC só
    - metadata:
        name: data
      spec:
        accessModes: [ReadWriteOnce]
        resources:
          requests:
            storage: 1Gi
```

`volumeClaimTemplates` é o pulo do gato: o K8s **expande isso em 1 PVC por réplica**, com nome `data-postgres-0`, `data-postgres-1`, etc.

## 🎯 Casos de uso (quando usar StatefulSet)

| Sistema | Por que precisa de StatefulSet |
|---|---|
| **PostgreSQL / MySQL** | Primário tem identidade, replicas conectam nele por nome |
| **MongoDB (replica set)** | Membros do replica set se conhecem por hostname |
| **Cassandra** | Cada node guarda partição de dado, sem reembaralhar |
| **Kafka** | Brokers têm broker.id fixo, partições mapeadas |
| **Elasticsearch** | Nodes mantêm shards específicos |
| **etcd / Zookeeper** | Quorum precisa de identidade estável |

**Não use StatefulSet pra**: nginx, API REST stateless, worker de fila, batch job. Use Deployment.

## ⚖️ Deployment vs StatefulSet (resumo)

| Aspecto | Deployment | StatefulSet |
|---|---|---|
| Nome do pod | aleatório (`app-7d8-abc`) | ordinal (`app-0`, `app-1`) |
| DNS por pod | ❌ | ✅ (com headless svc) |
| Ordem start/stop | paralela | sequencial |
| Storage | 1 PVC compartilhado ou nenhum | 1 PVC por réplica |
| Substituição | qualquer node, identidade nova | mesmo nome, mesmo PVC |
| Service típico | ClusterIP normal | Headless (`clusterIP: None`) |
| Use case | apps stateless | bancos, filas, sistemas com estado |

## 💡 Detalhes que valem ouro
- **PVC sobrevive ao delete do StatefulSet**. Pra limpar geral: `kubectl delete pvc -l app=postgres`.
- **Scale down NÃO apaga PVC**. Você pode escalar 3→1 e voltar pra 3 sem perder dado.
- **`serviceName` no spec é obrigatório** e precisa bater com o nome do Headless Service. Se errar, DNS dos pods não funciona.
- **Headless Service também aceita `selector`** — é por isso que ele sabe quais pods listar no DNS.
- **`podManagementPolicy: Parallel`** desliga a ordem sequencial. Use só se sua app aguenta (Cassandra usa).
- **StatefulSet não rebalanceia carga** — quem distribui requests é a app cliente ou um proxy (PgBouncer pra Postgres, p.ex.).

## 🚦 Próximos passos
1. Faça `pratica/` — StatefulSet de nginx com 3 réplicas e nslookup nos pods
2. Encare o desafio: Postgres com volumeClaimTemplates + secret + psql client
3. Anote: qual é o nome DNS completo do pod 0?

## ✅ Auto-verificação
- [ ] Sei explicar em 1 frase por que Deployment não serve pra banco
- [ ] Lembro das 4 garantias do StatefulSet
- [ ] Sei o que é Headless Service e por que ele é necessário
- [ ] Entendo o que `volumeClaimTemplates` gera
- [ ] Sei a diferença prática entre os nomes de pod nos dois recursos

Próximo módulo: **Jobs e CronJobs** — workloads que terminam.
