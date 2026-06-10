# Módulo 13 — RBAC e Service Accounts

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diferenciar **Authentication** (quem é você) de **Authorization** (o que você pode fazer)
- Criar **ServiceAccount** para dar identidade a pods/apps
- Escrever **Role** e **RoleBinding** com permissão mínima (princípio do menor privilégio)
- Diferenciar **Role** (namespaced) de **ClusterRole** (cluster-wide)
- Testar permissões com `kubectl auth can-i`

## 🔐 Authentication vs Authorization

São duas etapas separadas, em ordem, sempre que algo bate no API Server:

1. **Authentication (AuthN)** — "quem está chamando?" K8s identifica o cliente. Pode ser um **usuário humano** (via certificado, OIDC, token estático) ou uma **ServiceAccount** (token montado em pod).
2. **Authorization (AuthZ)** — "esse cara pode fazer isso?" Depois de saber quem é, o K8s decide se a ação é permitida. O módulo padrão é **RBAC** (Role-Based Access Control).

```
Request → [AuthN: quem é?] → [AuthZ: pode?] → [Admission: validações extras] → executa
```

Se a AuthN falha: `Unauthorized` (401). Se a AuthZ falha: `Forbidden` (403).

> Importante: usuários humanos **não são objetos no cluster**. K8s não tem `kubectl create user`. Já ServiceAccounts **são** objetos — você cria com YAML, vivem dentro de um namespace.

---

## 👤 ServiceAccount (SA) — identidade pra apps

Toda vez que um **pod** precisa falar com o API Server (ex.: um operator que lista deployments, um app que cria configmaps, Prometheus que descobre alvos), ele usa uma **ServiceAccount**.

- Toda namespace ganha uma SA chamada `default` automaticamente.
- Se você não definir `serviceAccountName` no pod, ele usa a `default`.
- A SA `default` **não tem permissão nenhuma** por padrão — é só uma identidade.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ler-pods
  namespace: dev
```

Quando um pod usa essa SA, o K8s monta um **token JWT** dentro do container, em:
```
/var/run/secrets/kubernetes.io/serviceaccount/
├── token          # JWT pra autenticar
├── ca.crt         # certificado pra confiar no API Server
└── namespace      # namespace atual
```

A app dentro do pod lê esse token e usa como Bearer Token nas chamadas pra `https://kubernetes.default.svc`.

---

## 📜 Role — permissões num namespace

**Role** é uma lista de regras (`rules`) dizendo "quem tiver esse papel pode fazer X com Y". **Vive dentro de um namespace** — só vale ali.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: leitor-pods
  namespace: dev
rules:
- apiGroups: [""]              # "" = core API (pods, services, configmaps, secrets...)
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

### Anatomia de uma `rule`
| Campo | O que é | Exemplos |
|---|---|---|
| `apiGroups` | Grupo da API. `""` é o core. | `""`, `apps`, `batch`, `networking.k8s.io` |
| `resources` | Que recurso. Sempre plural. | `pods`, `deployments`, `secrets`, `services` |
| `verbs` | Que ações. | `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`, `deletecollection` |

> Dica pra achar o `apiGroup` certo: `kubectl api-resources` mostra recurso → apiGroup.

### Os 8 verbos padrão
- **get** — pegar 1 item por nome
- **list** — listar vários
- **watch** — assistir mudanças em stream (usado por controllers)
- **create** — criar
- **update** — substituir o objeto inteiro
- **patch** — alterar partes (o que `kubectl edit` faz)
- **delete** — apagar 1
- **deletecollection** — apagar vários de uma vez

> Quem tem `patch` em deployments pode mudar imagem, número de réplicas, env vars... mas **não** apaga (sem `delete`).

---

## 🌍 ClusterRole — permissões em todo o cluster

Mesma estrutura da Role, mas **sem namespace** — vale no cluster inteiro. Usada pra:
- Recursos **cluster-scoped** (nodes, namespaces, PVs, ClusterRoles)
- Dar a mesma permissão em **vários namespaces** sem duplicar Roles
- Permissões pra `kubectl get nodes`, `kubectl get ns`, etc.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: leitor-nodes
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

---

## 🔗 RoleBinding e ClusterRoleBinding — quem ganha o quê

Role/ClusterRole **só descrevem permissões**. Não fazem efeito sozinhas. Pra ativar, você **liga (bind)** a um **subject** (usuário, grupo ou SA).

### RoleBinding (dentro de um namespace)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ler-pods-dev
  namespace: dev
subjects:                              # quem
- kind: ServiceAccount
  name: ler-pods
  namespace: dev
roleRef:                               # qual papel
  kind: Role
  name: leitor-pods
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRoleBinding (vale no cluster todo)
Mesma cara, só que `kind: ClusterRoleBinding` e referencia uma `ClusterRole`.

### Matriz quem-liga-com-quem
| Binding | Liga a... | Escopo da permissão |
|---|---|---|
| RoleBinding → Role | Role no mesmo ns | Só nesse namespace |
| RoleBinding → ClusterRole | ClusterRole | **Só nesse namespace** (truque útil pra reutilizar ClusterRole) |
| ClusterRoleBinding → ClusterRole | ClusterRole | Cluster inteiro |

> RoleBinding apontando pra ClusterRole é o truque mais comum: você define a ClusterRole uma vez (ex.: "leitor de tudo") e dá pra times diferentes em namespaces diferentes via RoleBinding.

---

## 🧪 `kubectl auth can-i` — testando antes de quebrar

Comando salva-vidas pra debugar RBAC sem precisar virar o usuário:

```bash
# Eu mesmo posso?
kubectl auth can-i list pods
# yes | no

# Posso criar deployments no ns dev?
kubectl auth can-i create deployments -n dev

# E SE EU FOSSE essa SA, eu poderia?
kubectl auth can-i list pods --as=system:serviceaccount:dev:ler-pods -n dev

# Listar TUDO que essa SA pode fazer
kubectl auth can-i --list --as=system:serviceaccount:dev:ler-pods -n dev
```

Formato do "nome" de uma SA quando vira subject:
```
system:serviceaccount:<NAMESPACE>:<NOME-DA-SA>
```

---

## 🧰 Como o pod usa a SA na prática

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meu-app
  namespace: dev
spec:
  serviceAccountName: ler-pods       # <-- aqui
  containers:
  - name: app
    image: alpine
    command: ["sh", "-c", "sleep 3600"]
```

Dentro do container:
```bash
# Token, CA e namespace estão aqui:
ls /var/run/secrets/kubernetes.io/serviceaccount/

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Chama o API Server (DNS interno: kubernetes.default.svc)
curl --cacert $CA -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/dev/pods
```

Se a SA tem permissão: vem o JSON. Se não tem: 403 Forbidden.

> A partir do K8s 1.24, o token **não** é mais um Secret automático no namespace — é um token projetado, com expiração curta, montado direto pelo kubelet. Mais seguro, mas se você precisa de um token "longo" pra CI, cria manualmente: `kubectl create token NOME-SA --duration=1h`.

---

## 🛡️ Princípio do menor privilégio (least privilege)

Regra de ouro do RBAC: **dê só o necessário, nada além**.

- ❌ `verbs: ["*"]` em `resources: ["*"]` → você acabou de dar root no cluster.
- ❌ Usar `cluster-admin` pra qualquer coisa que não seja admin de cluster mesmo.
- ❌ Pod produtivo usando a SA `default` "porque dá".
- ✅ Uma SA por app, com Role que lista **só os verbos e recursos** que aquele app precisa.
- ✅ Começou? Cria com permissão zero, vai liberando o que faltar (descobre o que falta vendo 403 no log).

---

## 📋 Cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl create serviceaccount NOME` | Cria SA no ns atual |
| `kubectl get sa` | Lista SAs |
| `kubectl get role,rolebinding -n NS` | Roles e bindings do namespace |
| `kubectl get clusterrole,clusterrolebinding` | Versões cluster-wide |
| `kubectl describe rolebinding NOME -n NS` | Vê subjects + roleRef |
| `kubectl auth can-i VERBO RECURSO` | Eu posso? |
| `kubectl auth can-i VERBO RECURSO --as=USER` | E se eu fosse fulano? |
| `kubectl auth can-i --list --as=...` | Tudo que esse subject pode |
| `kubectl api-resources` | Recursos do cluster com apiGroup |
| `kubectl create token NOME-SA` | Gera token JWT manual da SA |

## 💡 Detalhes que valem ouro
- **Role é namespaced**. ClusterRole não. Erro clássico: criar Role em `default` e esperar que valha em `dev`.
- **`apiGroups: [""]`** (string vazia) é o **core**: pods, services, secrets, configmaps, nodes, namespaces.
- **`apps`** tem deployments, statefulsets, daemonsets, replicasets.
- **`get` ≠ `list`**: ter `get` deixa pegar 1 item por nome, mas não listar tudo. Muito UI precisa dos dois.
- **`watch` é o que controllers usam** pra reagir a mudanças. Operators sem `watch` viram polling.
- **`patch` é mais perigoso do que parece**: quem tem patch em pods pode trocar imagem, env, comando — basicamente RCE.
- **Quem cria RoleBinding precisa ter as permissões que está concedendo** (regra "privilege escalation prevention"). Você não pode dar o que não tem.
- **Aggregated ClusterRoles**: ClusterRoles com label especial são "somadas" automaticamente em outras (ex.: `view`, `edit`, `admin` built-in). Avançado, mas útil saber que existe.

## 🚦 Próximos passos
1. Leia o `AULA.md` todo
2. Rode `pratica/comandos.sh` linha a linha — você vai aplicar SA, Role, RoleBinding e ver `can-i` funcionando
3. Encare o `desafio` (SA "ci-bot" com permissão mínima)

## ✅ Auto-verificação
- [ ] Sei diferenciar AuthN de AuthZ
- [ ] Sei o que é ServiceAccount e por que `default` não basta em produção
- [ ] Sei a diferença Role x ClusterRole x RoleBinding x ClusterRoleBinding
- [ ] Sei escrever uma `rule` com apiGroups/resources/verbs
- [ ] Sei usar `kubectl auth can-i --as=...` pra testar

Próximo módulo: **Network Policies** — firewall entre pods.
