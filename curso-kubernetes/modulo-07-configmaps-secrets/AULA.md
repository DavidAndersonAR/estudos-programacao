# Módulo 07 — ConfigMaps e Secrets

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Separar **configuração** de **imagem de container**
- Criar **ConfigMap** (imperativo e declarativo)
- Criar **Secret** e entender por que base64 **não é** criptografia
- Consumir config em pods de 3 formas: **env vars**, **volume**, **args**
- Saber quando precisa reiniciar o pod e quando o K8s atualiza sozinho

## 🧠 O problema que isso resolve

Você tem uma imagem `meu-app:1.0`. Em **dev** ela conecta no banco `db-dev`, em **prod** no `db-prod`. E em prod existe uma senha que **não pode** ir pro Git.

Soluções ruins:
- Hardcode no Dockerfile → uma imagem por ambiente (péssimo)
- ENV no `docker run` → some quando o pod morre, ninguém versiona

Solução K8s:
- **ConfigMap**: guarda configuração **não-sensível** (URLs, flags, arquivos `.conf`)
- **Secret**: guarda configuração **sensível** (senhas, tokens, certificados TLS)

Mesma imagem, configs diferentes por ambiente. Imagem fica **imutável**.

## 📦 ConfigMap

Um par chave-valor (ou arquivo inteiro) guardado no etcd e exposto ao pod.

### 1. Criar imperativo (rápido pra testes)

```bash
# De literais (key=value)
kubectl create configmap meu-cm \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=FEATURE_FLAG=true

# De um arquivo (a chave vira o nome do arquivo)
kubectl create configmap nginx-cm --from-file=nginx.conf

# De um arquivo .env (cada linha vira uma chave)
kubectl create configmap env-cm --from-env-file=.env
```

### 2. Criar declarativo (YAML — o jeito certo)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: debug
  FEATURE_FLAG: "true"          # YAML: bool precisa virar string
  app.properties: |             # arquivo inteiro como valor
    server.port=8080
    cache.ttl=300
```

`kubectl apply -f cm.yaml` e pronto.

```bash
kubectl get cm
kubectl describe cm app-config
kubectl get cm app-config -o yaml
```

## 🔐 Secret

Igualzinho ao ConfigMap, **mas** com um detalhe:

> ⚠️ Secret **NÃO é criptografado**. É só **base64** — ofuscação, não segurança.

Qualquer pessoa com `kubectl get secret -o yaml` decodifica em 1 segundo. O ganho real do Secret é:
- Os valores **não aparecem** em `kubectl describe` (só "<bytes>")
- Pode ser criptografado em repouso (no etcd) se você ligar `EncryptionConfiguration`
- RBAC pode bloquear `get secret` separado de `get configmap`
- Tipos especiais (TLS, dockerconfigjson) que o K8s entende

Para produção de verdade use:
- **Sealed Secrets** (Bitnami) — você commita o secret **criptografado** no Git
- **External Secrets Operator** — busca de Vault, AWS Secrets Manager, GCP, etc.
- **SOPS** — mesma ideia, formato de arquivo

### Tipos de Secret

| Type | Para quê |
|---|---|
| `Opaque` (default) | Qualquer dado genérico (senha, token, API key) |
| `kubernetes.io/tls` | Certificado TLS — exige chaves `tls.crt` e `tls.key` |
| `kubernetes.io/dockerconfigjson` | Credencial de registry privado |
| `kubernetes.io/service-account-token` | Token de ServiceAccount (gerado automaticamente) |
| `kubernetes.io/basic-auth` | Usuário+senha (chaves `username`, `password`) |
| `kubernetes.io/ssh-auth` | Chave SSH privada |

### Criar imperativo

```bash
# Opaque (default)
kubectl create secret generic db-secret \
  --from-literal=DB_PASSWORD='s3nh@123'

# TLS
kubectl create secret tls meu-tls \
  --cert=server.crt --key=server.key

# Registry privado
kubectl create secret docker-registry meu-reg \
  --docker-server=registry.empresa.com \
  --docker-username=user \
  --docker-password=pass
```

### Criar declarativo

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_PASSWORD: czNuaEAxMjM=   # base64 de "s3nh@123"
```

Para gerar o base64:
```bash
echo -n 's3nh@123' | base64
# czNuaEAxMjM=
```

Ou use `stringData` (o K8s codifica pra você):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:                    # texto puro — o cluster codifica
  DB_PASSWORD: s3nh@123
```

## 🍽️ 3 formas de consumir config no Pod

### Forma 1: Env vars individuais (`env.valueFrom`)

```yaml
spec:
  containers:
  - name: app
    image: meu-app:1.0
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASSWORD
```

Bom quando você quer **renomear** a env var ou pegar só algumas chaves.

### Forma 2: Env vars em lote (`envFrom`)

```yaml
spec:
  containers:
  - name: app
    image: meu-app:1.0
    envFrom:
    - configMapRef:
        name: app-config       # TODAS as keys viram env vars
    - secretRef:
        name: db-secret
```

Bom quando você tem um ConfigMap "feito sob medida" pro app — todas as chaves já têm nome certo.

### Forma 3: Volume mount (cada chave vira um arquivo)

```yaml
spec:
  containers:
  - name: app
    image: meu-app:1.0
    volumeMounts:
    - name: config-vol
      mountPath: /etc/app       # vira /etc/app/LOG_LEVEL, /etc/app/app.properties...
      readOnly: true
  volumes:
  - name: config-vol
    configMap:
      name: app-config
```

Essencial para apps que **leem arquivo de config** (nginx, prometheus, postgres, etc.). Cada chave do ConfigMap vira **um arquivo** no mountPath.

### Forma 4 (rara): Args do comando

```yaml
command: ["/app"]
args: ["--log-level=$(LOG_LEVEL)"]
env:
- name: LOG_LEVEL
  valueFrom:
    configMapKeyRef: { name: app-config, key: LOG_LEVEL }
```

Só usado quando o app não lê env nem arquivo. Raro.

## 🔄 ConfigMap mudou — e os pods?

Detalhe **muito importante** que pega quem chega:

| Forma de consumo | Atualiza sozinho? |
|---|---|
| `env` / `envFrom` | ❌ **NÃO** — env var só é setada quando o pod sobe. Precisa `kubectl rollout restart` |
| Volume mount (subPath) | ❌ NÃO atualiza |
| Volume mount (normal) | ✅ SIM — o kubelet atualiza o arquivo (pode demorar ~1min) |

Mesmo com volume atualizando o arquivo, **o seu app** precisa reler o arquivo (hot-reload) — nginx faz com `nginx -s reload`, mas a maioria precisa restart.

Padrão prático: depois de `kubectl apply -f cm.yaml`, faça:
```bash
kubectl rollout restart deployment/meu-app
```

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl create cm NOME --from-literal=K=V` | Cria ConfigMap rápido |
| `kubectl create cm NOME --from-file=arquivo` | ConfigMap a partir de arquivo |
| `kubectl create secret generic NOME --from-literal=K=V` | Secret Opaque |
| `kubectl create secret tls NOME --cert=c --key=k` | Secret TLS |
| `kubectl get cm` / `kubectl get secret` | Lista |
| `kubectl describe cm NOME` | Mostra conteúdo (CM mostra tudo) |
| `kubectl describe secret NOME` | Mostra só tamanho (não vaza valor) |
| `kubectl get secret NOME -o jsonpath='{.data.X}' \| base64 -d` | Decodifica um valor |
| `kubectl rollout restart deploy NOME` | Reinicia pods pra pegar env nova |

## 💡 Detalhes que valem ouro

- **Valores no YAML do ConfigMap são SEMPRE string**. Se quer `true` ou `123`, ponha entre aspas pra evitar surpresa.
- Tamanho máximo de um ConfigMap/Secret: **1 MiB** (limite do etcd). Pra arquivos grandes, use volume real.
- **ConfigMap e Pod precisam estar no MESMO namespace**.
- `immutable: true` no ConfigMap/Secret melhora performance em cluster grande — mas você **não consegue editar**, só deletar e recriar.
- Pra debug rápido: `kubectl exec POD -- env | grep MINHA_VAR` ou `kubectl exec POD -- cat /etc/app/arquivo`.
- **Nunca commite Secret de verdade em YAML no Git**. Use Sealed Secrets, SOPS ou External Secrets.
- Em RBAC corporativo é comum dev poder ver ConfigMap mas **não** ver Secret. Separar bem ajuda.

## 🚦 Próximos passos
1. Suba o cluster (do módulo 1) — `kind create cluster --name estudo`
2. Rode `pratica/comandos.sh`
3. Encare o desafio (`desafio/`)

## ✅ Auto-verificação
- [ ] Sei criar ConfigMap imperativo e declarativo
- [ ] Sei a diferença entre `data` e `stringData` em Secret
- [ ] Sei que Secret **não** é criptografado (só base64)
- [ ] Sei consumir via `env`, `envFrom` e volume
- [ ] Sei que env **não** atualiza sozinha quando o CM muda

Próximo módulo: **Services** — expor o app pra fora do cluster.
