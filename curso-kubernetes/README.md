# Curso de Kubernetes — do Básico ao Avançado

> Mesmo padrão dos outros cursos. 20 módulos progressivos, do primeiro `kubectl get pods` até cluster de produção com GitOps. Vamos usar **kind** (Kubernetes in Docker) — leve, rápido e roda 100% local com o Docker que você já tem.

## Estrutura

Cada módulo tem 3 arquivos:
1. **AULA.md** — teoria condensada com exemplos
2. **pratica/** — manifests YAML (Pod, Deployment, Service, etc) + comandos
3. **desafio/** — miniprojeto com TODOs e solução comentada

## Ementa

### Fase 1 — Fundamentos
- **01 — Bem-vindo + Setup** — instalar kind, primeiro cluster, `kubectl`, primeiro Pod. 🎯 *Cluster local funcionando*
- **02 — Pods** — criar, listar, describe, logs, exec, delete, lifecycle. 🎯 *Multi-container pod*
- **03 — Manifests YAML** — anatomia, apiVersion/kind/metadata/spec, `apply` vs `create`, `dry-run`. 🎯 *Pod via YAML do zero*
- **04 — ReplicaSets e Deployments** — pra que cada um serve, rolling updates, rollback. 🎯 *App escalável com 3 réplicas*
- **05 — Services** — ClusterIP, NodePort, LoadBalancer, ExternalName, selectors. 🎯 *Expor app por dentro e por fora*

### Fase 2 — Workloads e Config
- **06 — Namespaces** — isolamento lógico, kubectl contexts. 🎯 *Múltiplos ambientes*
- **07 — ConfigMaps e Secrets** — separar config do código, env vs file mount. 🎯 *App configurável*
- **08 — Volumes e PVC** — emptyDir, hostPath, PV, PVC, StorageClass. 🎯 *App com dados persistentes*
- **09 — StatefulSets** — workloads com estado (BD, fila), identidade estável. 🎯 *PostgreSQL no K8s*
- **10 — DaemonSets, Jobs, CronJobs** — quando usar cada. 🎯 *Agendar backup com CronJob*

### Fase 3 — Networking e Acesso
- **11 — Ingress** — Ingress Controller (nginx), regras host/path, TLS. 🎯 *Roteamento por subdomínio*
- **12 — Network Policies** — restringir tráfego pod-a-pod. 🎯 *Banco só acessível pela API*
- **13 — RBAC e Service Accounts** — Roles, RoleBindings, ClusterRoles. 🎯 *Service Account com permissão mínima*

### Fase 4 — Produção e Avançado
- **14 — Health Probes** — liveness, readiness, startup probe. 🎯 *App self-healing*
- **15 — Resources e Autoscaling** — requests/limits, HPA, VPA, Cluster Autoscaler. 🎯 *App que escala com carga*
- **16 — Helm** — package manager, charts, templating, values. 🎯 *Chart próprio*
- **17 — Observability** — logs (kubectl logs, stern), metrics (kubectl top), events. 🎯 *Diagnosticar pod com problema*
- **18 — Rolling Updates e Estratégias** — RollingUpdate, Recreate, Blue/Green, Canary com Argo Rollouts. 🎯 *Deploy zero-downtime*
- **19 — Operators e CRDs** — extending Kubernetes, exemplos (cert-manager, Prometheus Operator). 🎯 *Usar um operator pronto*
- **20 — Produção: Cluster Management, Segurança, GitOps** — Pod Security Standards, Pod Disruption Budgets, Argo CD/Flux. 🎯 *Checklist de produção*

## Pré-requisitos
- **Docker** (você tem 29.4 ✅) — `kind` roda K8s em containers Docker
- **kubectl 1.30+** (você tem 1.34 ✅)
- **kind** (instalamos no Módulo 01)
- Editor com YAML highlight (VS Code com extensão Kubernetes recomendada)

## Como rodar os exemplos
Cada módulo tem:
- `pratica/*.yaml` — manifests prontos pra aplicar com `kubectl apply -f arquivo.yaml`
- `pratica/comandos.sh` — sequência completa do exercício

## Material de apoio
- Docs oficiais: https://kubernetes.io/docs
- kind: https://kind.sigs.k8s.io
- kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- Helm: https://helm.sh
- Argo CD (GitOps): https://argo-cd.readthedocs.io
- Killercoda (labs grátis): https://killercoda.com/kubernetes

Bom estudo!
