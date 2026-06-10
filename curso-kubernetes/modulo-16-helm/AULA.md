# Módulo 16 — Helm (Package Manager do Kubernetes)

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é Helm e por que ele existe
- Instalar o Helm no Windows
- Entender o que é um **Chart** e como ele é estruturado
- Usar templating Go + Sprig nos manifestos
- Instalar/atualizar/desinstalar releases com `helm install`, `helm upgrade`, `helm rollback`
- Adicionar repositórios públicos e instalar apps prontos (Prometheus, Nginx, etc)
- Criar seu **próprio chart do zero**

## 📦 Por que Helm existe?

Imagina instalar **Prometheus** no seu cluster manualmente. Você precisaria escrever:
- Deployment, Service, ConfigMap, ServiceAccount, ClusterRole, ClusterRoleBinding, PVC, Secret, Ingress...
- Uns **20 a 40 manifestos YAML**.
- E ainda customizar imagem, recursos, número de réplicas, storage, retenção etc.

Com Helm vira **um comando**:

```bash
helm install prometheus prometheus-community/prometheus
```

Helm é o **"apt/yum/npm" do Kubernetes**:
- **Empacota** N manifestos em um único artefato (chart).
- **Versiona** (cada release tem um número).
- **Parametriza** (mesmo chart serve pra dev/staging/prod, mudando só os values).
- **Rollback fácil** (`helm rollback nome 3` volta pra revisão 3).

## 🛠️ Instalação (Windows)

```powershell
winget install Helm.Helm
```

Verificar:
```bash
helm version
```

No Linux/Mac é `brew install helm` ou script oficial. O resto do módulo é igual em qualquer SO.

## 🧱 O que é um Chart?

Um **Chart** é um **pacote Helm**: uma pasta com 3 coisas principais.

```
meuapp/
├── Chart.yaml          # metadados (nome, versão, descrição)
├── values.yaml         # valores DEFAULT que alimentam os templates
├── .helmignore         # arquivos a ignorar (tipo .gitignore)
├── charts/             # dependências (sub-charts)
└── templates/          # manifestos K8s com placeholders {{ ... }}
    ├── deployment.yaml
    ├── service.yaml
    ├── _helpers.tpl    # funções/helpers reutilizáveis
    └── NOTES.txt       # mensagem mostrada após instalar
```

### Chart.yaml — quem você é
```yaml
apiVersion: v2
name: meuapp
description: Meu primeiro chart
type: application
version: 0.1.0        # versão DO CHART
appVersion: "1.16.0"  # versão DA APLICAÇÃO empacotada
```

### values.yaml — variáveis default
```yaml
replicaCount: 2
image:
  repository: nginx
  tag: alpine
service:
  port: 80
```

### templates/deployment.yaml — manifesto parametrizado
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
      - name: app
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

Quando você roda `helm install`, o Helm **renderiza** os templates substituindo `{{ .Values.x }}` pelo conteúdo do `values.yaml` (ou do que você passar).

---

## 🧠 Templating: Go template + Sprig

Helm usa **Go template** (a mesma engine que você já viu se mexe com Go) + a biblioteca **Sprig** (mais de 100 funções extras).

### Sintaxe básica

```yaml
# Acesso a valores
image: {{ .Values.image.repository }}

# Built-in (info da release)
name: {{ .Release.Name }}        # nome da release
namespace: {{ .Release.Namespace }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}

# Default se o valor não existir
tag: {{ .Values.image.tag | default "latest" }}

# Aspas obrigatórias em strings
tag: "{{ .Values.image.tag }}"
# ou
tag: {{ .Values.image.tag | quote }}

# Condicional
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
# ...
{{- end }}

# Loop
{{- range .Values.envs }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}

# Indentação (essencial em YAML!)
{{- toYaml .Values.resources | nindent 12 }}
```

O `-` antes do `}}` ou depois do `{{` **come o whitespace**, importante pra não estourar a indentação YAML.

### Helpers (_helpers.tpl)

Funções reutilizáveis. Convenção:

```yaml
{{/* Nome completo: release + chart */}}
{{- define "meuapp.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

Uso:
```yaml
metadata:
  name: {{ include "meuapp.fullname" . }}
```

---

## 🚀 Comandos essenciais

### Instalar
```bash
helm install minha-release ./meuapp
# minha-release = nome que você dá à instalação
# ./meuapp     = caminho pro chart (ou nome num repo)
```

### Upgrade + install combinado (idempotente — o melhor pro dia a dia)
```bash
helm upgrade --install minha-release ./meuapp
# Se não existir, instala. Se existir, faz upgrade. Perfeito pra CI/CD.
```

### Override de values
```bash
# Com arquivo
helm install minha-release ./meuapp -f values-prod.yaml

# Com flag direta
helm install minha-release ./meuapp --set replicaCount=5 --set image.tag=v2

# Combinando (precedência: --set > -f > values.yaml default)
helm install x ./meuapp -f values-prod.yaml --set replicaCount=10
```

### Listar e inspecionar
```bash
helm list                                # releases no namespace atual
helm list -A                             # todos namespaces
helm status minha-release                # status detalhado
helm get values minha-release            # values atualmente em uso
helm get manifest minha-release          # YAML que foi aplicado no cluster
```

### Histórico e rollback
```bash
helm history minha-release               # lista revisões
helm rollback minha-release 2            # volta pra revisão 2
helm rollback minha-release              # volta pra anterior
```

### Desinstalar
```bash
helm uninstall minha-release             # remove tudo
helm uninstall minha-release --keep-history  # mantém histórico
```

### Renderizar localmente (sem aplicar)
```bash
helm template minha-release ./meuapp     # vê o YAML que seria aplicado
helm install minha-release ./meuapp --dry-run --debug
```

---

## 🌐 Repositórios

Charts prontos vêm de repositórios. Exemplos famosos:

```bash
# Adicionar
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Atualizar índice
helm repo update

# Procurar
helm search repo nginx
helm search repo prometheus

# Instalar do repo
helm install meu-nginx bitnami/nginx
helm install meu-prom prometheus-community/prometheus
```

### Ver os values default do chart antes de instalar
```bash
helm show values bitnami/nginx > nginx-defaults.yaml
# Edita o que quiser e instala com -f
```

---

## 🏗️ Criar um chart do zero

### Modo rápido (scaffold completo)
```bash
helm create meuapp
```
Cria pasta com **um exemplo completo** (deployment, service, ingress, hpa, serviceaccount, helpers, NOTES). Bom pra ver tudo que dá pra fazer — mas verboso.

### Modo manual (o que você vai fazer na prática)
Cria só o que precisa: `Chart.yaml`, `values.yaml`, `templates/deployment.yaml`, `templates/service.yaml`. Mais simples, mais didático.

### Validar
```bash
helm lint ./meuapp                       # verifica erros
helm template ./meuapp                   # renderiza
helm install teste ./meuapp --dry-run    # simulação
```

---

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `helm version` | Versão do Helm |
| `helm create NOME` | Cria scaffold de chart |
| `helm lint ./chart` | Valida o chart |
| `helm template ./chart` | Renderiza templates localmente |
| `helm install REL ./chart` | Instala release |
| `helm upgrade --install REL ./chart` | Instala ou atualiza (idempotente) |
| `helm upgrade REL ./chart --set k=v` | Upgrade com override |
| `helm list` | Lista releases |
| `helm status REL` | Status da release |
| `helm history REL` | Histórico de revisões |
| `helm rollback REL N` | Volta pra revisão N |
| `helm uninstall REL` | Remove release |
| `helm repo add NOME URL` | Adiciona repositório |
| `helm repo update` | Atualiza índice de repos |
| `helm search repo TERMO` | Busca em repos adicionados |
| `helm search hub TERMO` | Busca no Artifact Hub público |
| `helm show values CHART` | Mostra values default |
| `helm get values REL` | Values usados na release |
| `helm get manifest REL` | YAML aplicado |

---

## 💡 Detalhes que valem ouro

- **`helm upgrade --install` é seu amigo**. Sempre. Em pipeline de CI/CD nunca use `helm install` puro — você quer idempotência.
- **Versione `Chart.yaml` em todo upgrade**. Sem mudar `version`, repos com cache (ArgoCD, ChartMuseum) podem ignorar suas mudanças.
- **Não comite `values-prod.yaml` com secrets**. Use `helm secrets` (plugin) ou Sealed Secrets ou External Secrets Operator.
- **`.Release.Name` vs `.Chart.Name`**: `Release` é o **nome da instalação** (varia por instância), `Chart` é o **nome do chart** (fixo). Pra `prom-dev` e `prom-prod` instalados do mesmo chart `prometheus`, `.Release.Name` é diferente, `.Chart.Name` é igual.
- **Templates ficam em `templates/`, helpers em `_helpers.tpl`**. Arquivos começados com `_` **não viram manifesto** — servem só como biblioteca.
- **NOTES.txt** é renderizado e mostrado após `helm install`. Use pra dar instruções (URL de acesso, comandos pra testar).
- **Helm 3 não tem mais Tiller** (server-side). Tudo roda do cliente — releases são guardadas como Secrets no namespace.
- **Pra subcharts/dependências**, declare em `Chart.yaml > dependencies` e rode `helm dependency update`.

---

## 🚦 Próximos passos

1. Instale o Helm: `winget install Helm.Helm`
2. Adicione um repo público: `helm repo add bitnami https://charts.bitnami.com/bitnami`
3. Veja a prática em `pratica/` (chart `meuapp` criado do zero)
4. Encare o desafio (chart com Deployment + Service + ConfigMap + Ingress condicional)

## ✅ Auto-verificação

- [ ] Sei explicar Chart x Release x Revision
- [ ] Consigo escrever um template com `{{ .Values.x }}`
- [ ] Sei a diferença `install` x `upgrade --install`
- [ ] Sei sobrescrever values com `-f` e `--set`
- [ ] Já fiz rollback com `helm rollback`
- [ ] Entendi quando usar condicionais (`{{ if }}`) em template

Próximo módulo: **Observability** — Prometheus + Grafana (e olha quem você vai instalar com Helm).
