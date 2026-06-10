# Módulo 03 — Manifests YAML

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever um manifest YAML de Pod **do zero**, sem copiar
- Entender a estrutura **apiVersion / kind / metadata / spec** que TODO recurso K8s tem
- Usar `kubectl explain` pra descobrir campos sem decorar
- Diferenciar `kubectl apply` (declarativo) de `kubectl create` (imperativo)
- Gerar YAML a partir de comandos imperativos com `--dry-run=client -o yaml`
- Colocar vários recursos no mesmo arquivo com `---`

## 📜 Por que YAML?

Até agora você criou pods com `kubectl run` (imperativo — "faça isso AGORA"). Funciona pra brincar, mas em produção tudo é **declarativo**:

> "Aqui está o estado desejado em um arquivo. Kubernetes, vire-se pra chegar lá."

Vantagens do YAML:
- **Versionado no git**: histórico, code review, rollback.
- **Reproduzível**: o mesmo arquivo gera o mesmo recurso em dev, staging e prod.
- **Idempotente**: rodar `apply` 10 vezes dá o mesmo resultado de rodar 1 vez.
- **GitOps**: ferramentas como ArgoCD/Flux leem YAML do git e aplicam no cluster sozinhas.

## 🧱 A estrutura que TODO manifest tem

Sem exceção. Pod, Service, Deployment, Secret, CRD da NASA — todos seguem:

```yaml
apiVersion: v1        # qual versão da API do K8s usar
kind: Pod             # que tipo de recurso é
metadata:             # quem é esse recurso (nome, labels, namespace)
  name: meu-pod
spec:                 # o que ele deve ser (varia por kind)
  containers:
    - name: app
      image: nginx:alpine
```

### 1. `apiVersion`
Qual grupo+versão da API K8s define esse recurso.
- `v1` — recursos core antigos (Pod, Service, ConfigMap, Secret, Namespace).
- `apps/v1` — Deployments, ReplicaSets, StatefulSets, DaemonSets.
- `networking.k8s.io/v1` — Ingress, NetworkPolicy.
- `batch/v1` — Jobs, CronJobs.

Não decora — usa `kubectl explain` (veja abaixo).

### 2. `kind`
O tipo do recurso. **Singular, PascalCase**: `Pod`, `Service`, `Deployment`, `ConfigMap`.

### 3. `metadata`
Identidade do recurso. Campos comuns:
- `name`: obrigatório, único dentro do namespace.
- `namespace`: opcional (default = `default`).
- `labels`: pares chave/valor pra **selecionar** o recurso depois.
- `annotations`: metadados livres — quem fez deploy, link do PR, etc.

```yaml
metadata:
  name: web
  namespace: producao
  labels:
    app: loja
    tier: frontend
    env: prod
  annotations:
    descricao: "Pod da home do site"
    deployado-por: "david@empresa.com"
```

### 4. `spec`
**O conteúdo varia por tipo de recurso**. Pra Pod: lista de containers, volumes, restartPolicy, etc. Pra Service: ports, selector. Pra Deployment: replicas, template, strategy.

É aqui que você precisa de `kubectl explain` — nunca decora os campos todos.

## 📐 Sintaxe YAML em 5 regras

YAML é "JSON sem chaves, com indentação que importa".

**1. Indentação só com espaços (nunca TAB)** — 2 espaços é o padrão K8s.

**2. Listas usam `-`** (com espaço depois):
```yaml
containers:
  - name: app
    image: nginx
  - name: sidecar
    image: busybox
```

**3. Objetos são chave + dois pontos + valor**:
```yaml
metadata:
  name: web
```

**4. Strings normalmente NÃO precisam de aspas**:
```yaml
name: meu-pod        # ok
image: nginx:alpine  # ok (o : tá no meio, sem ambiguidade)
```
Use aspas quando o valor pode ser interpretado como outro tipo:
```yaml
versao: "1.20"       # sem aspas viraria número 1.20
ativo: "true"        # sem aspas viraria boolean
porta: "8080"        # depende — alguns campos exigem número, outros string
```

**5. Comentário começa com `#`** — comente bastante, código YAML envelhece.

## 🔍 `kubectl explain` — sua bússola

A pergunta "que campos esse recurso tem?" se responde com `kubectl explain RECURSO[.CAMPO]`:

```bash
# Top-level do Pod
kubectl explain Pod

# Tudo que vai dentro de spec
kubectl explain Pod.spec

# Tudo que vai dentro de cada container
kubectl explain Pod.spec.containers

# Recursão completa (sai grande, joga num arquivo)
kubectl explain Pod --recursive > pod-fields.txt

# Funciona com QUALQUER recurso
kubectl explain Deployment.spec.strategy
kubectl explain Service.spec.ports
```

Isso é o **antídoto pra decoreba**. Esqueceu se é `restartPolicy` ou `restart_policy`? `kubectl explain Pod.spec` te diz.

## 🆚 `apply` vs `create`

Os dois aplicam YAML, mas diferentes:

| | `kubectl apply -f` | `kubectl create -f` |
|---|---|---|
| Existe ainda? | Cria | Cria |
| Já existe? | **Atualiza** (faz merge) | **ERRO** "already exists" |
| Idempotente? | ✅ Sim | ❌ Não |
| Modo recomendado? | ✅ Sim | Raramente |
| Guarda último config | ✅ (annotation) | ❌ |

**Regra de ouro**: use `apply` sempre. `create` só pra coisas one-shot tipo Jobs ou pra gerar YAML com `--dry-run`.

```bash
kubectl apply -f pod.yaml   # cria ou atualiza
kubectl apply -f pod.yaml   # rodar de novo: idempotente, sem erro
```

## 🛠️ `--dry-run=client -o yaml` — o atalho mais útil do K8s

Esqueci como é a estrutura de um Pod? Em vez de procurar no Google:

```bash
kubectl run web --image=nginx:alpine --dry-run=client -o yaml
```

Isso **não cria** o pod — só **imprime o YAML** que seria criado. Salva, edita, aplica:

```bash
kubectl run web --image=nginx:alpine --dry-run=client -o yaml > pod.yaml
# edita pod.yaml à vontade
kubectl apply -f pod.yaml
```

Funciona com tudo: `kubectl create deployment`, `kubectl create service`, `kubectl create configmap`...

## 📦 Multi-doc YAML — vários recursos num arquivo

Use `---` (três traços, em linha própria) pra separar documentos no mesmo arquivo:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app
      image: nginx:alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: cache
spec:
  containers:
    - name: cache
      image: redis:7-alpine
```

`kubectl apply -f arquivo.yaml` aplica os dois. Bom pra agrupar recursos relacionados (Deployment + Service + ConfigMap de um mesmo app).

## 🏷️ Labels e Annotations — não confunda

Os dois são `chave: valor` em `metadata`, mas:

**Labels** — usadas pra **selecionar** recursos. Curtas, padronizadas.
```yaml
labels:
  app: loja
  tier: frontend
  env: prod
```
```bash
kubectl get pods -l app=loja          # filtra por label
kubectl get pods -l env=prod,tier=frontend
```
Services usam labels pra achar Pods. Deployments usam labels pra "adotar" ReplicaSets. **Labels viram seletores.**

**Annotations** — metadado livre, **não** usado pra seleção. Pode ser longo.
```yaml
annotations:
  kubernetes.io/change-cause: "Upgrade pra nginx 1.27"
  link-pr: "https://github.com/org/repo/pull/123"
  responsavel: "time-infra@empresa.com"
```

Regra mnemônica: **label = pra máquina filtrar, annotation = pra humano ler**.

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl apply -f arq.yaml` | Aplica manifest (cria ou atualiza) |
| `kubectl apply -f .` | Aplica TODOS os .yaml do diretório atual |
| `kubectl apply -f https://...` | Aplica direto de URL |
| `kubectl delete -f arq.yaml` | Remove tudo que tá no arquivo |
| `kubectl create -f arq.yaml` | Cria (erro se já existe) |
| `kubectl explain Pod` | Mostra campos do Pod |
| `kubectl explain Pod.spec.containers` | Vai fundo num campo |
| `kubectl explain Pod --recursive` | Árvore completa de campos |
| `kubectl run X --image=Y --dry-run=client -o yaml` | Gera YAML sem criar |
| `kubectl get pod X -o yaml` | Exporta YAML do que tá rodando |
| `kubectl diff -f arq.yaml` | O que mudaria se eu aplicasse? |

## 💡 Detalhes que valem ouro
- **`kubectl explain` é offline-friendly**: lê da API do seu cluster, não precisa de internet.
- **Aspas em `"true"`/`"false"`/`"1.20"`**: K8s costuma exigir string quando o campo é string. Se rodar `apply` e der erro tipo "cannot unmarshal bool into string", coloca aspas.
- **`kubectl apply -f .` é seu amigo**: aplica todos os YAMLs de uma pasta. Bom pra projetos com muitos arquivos.
- **Padrão de labels recomendado** (`app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/version`, `app.kubernetes.io/component`, `app.kubernetes.io/part-of`, `app.kubernetes.io/managed-by`) — não precisa usar tudo, mas conheça.
- **`kubectl get X -o yaml` vem cheio de lixo** (status, managedFields, resourceVersion). Pra extrair YAML "limpo" pra versionar, geralmente é melhor escrever do zero ou usar `--dry-run=client`.
- **`metadata.generateName`** em vez de `name`: K8s gera nome único com sufixo aleatório. Útil pra Jobs.

## 🚦 Próximos passos
1. Garante que seu cluster tá no ar (`kubectl get nodes`)
2. Faça `pratica/pod.yaml` e `multi.yaml` — rode `pratica/comandos.sh`
3. Encare o `desafio/pod.yaml`
4. Brinque com `kubectl explain` até sentir que sabe achar QUALQUER campo

## ✅ Auto-verificação
- [ ] Sei explicar os 4 campos top-level de qualquer manifest
- [ ] Escrevo um Pod básico sem olhar exemplo
- [ ] Uso `kubectl explain` pra descobrir campos
- [ ] Sei diferença `apply` vs `create`
- [ ] Sei gerar YAML com `--dry-run=client -o yaml`
- [ ] Sei juntar vários recursos com `---`
- [ ] Sei diferença labels vs annotations

Próximo módulo: **ReplicaSets e Deployments** — finalmente parando de criar pod na mão.
