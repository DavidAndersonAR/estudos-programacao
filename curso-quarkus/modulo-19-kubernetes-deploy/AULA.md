# Módulo 19 — Deploy do Quarkus no Kubernetes

## 🎯 Objetivos

- Gerar manifests do Kubernetes automaticamente a partir do projeto Quarkus.
- Construir a imagem Docker no `mvn package` sem escrever `Dockerfile` à mão.
- Fazer deploy num cluster `kind` com um único comando.
- Ler `ConfigMap` direto do cluster com `quarkus-kubernetes-config`.
- Customizar `replicas`, `resources`, `env` e portas via `application.properties`.

---

## 1. As três extensões que mudam tudo

Você já sabe `kubectl`, `Deployment`, `Service`, `ConfigMap`. Agora a ideia é deixar o Quarkus gerar e aplicar isso sozinho.

```bash
./mvnw quarkus:add-extension -Dextensions="kubernetes,container-image-docker,kubernetes-config,smallrye-health"
```

| Extensão | O que faz |
|---|---|
| `quarkus-kubernetes` | Gera `kubernetes.yml` (Deployment + Service) em `target/kubernetes/` no build |
| `quarkus-container-image-docker` | Constrói a imagem Docker durante `mvn package` |
| `quarkus-kubernetes-config` | Lê `ConfigMap` e `Secret` do cluster como se fosse `application.properties` |
| `quarkus-smallrye-health` | Habilita `/q/health/live` e `/q/health/ready` — usados nas probes |

---

## 2. Build + push + apply num comando

Com as extensões instaladas:

```bash
./mvnw package -Dquarkus.kubernetes.deploy=true
```

O que acontece nessa ordem:

1. Quarkus compila o JAR.
2. `container-image-docker` constrói a imagem (usa o Docker local).
3. `kubernetes` gera `target/kubernetes/kubernetes.yml`.
4. `quarkus.kubernetes.deploy=true` aplica o YAML no cluster apontado pelo `kubectl` atual.

Sem `deploy=true`, o build só gera os arquivos — útil pra inspecionar antes de aplicar.

---

## 3. Customização via properties

Tudo configurável sem editar YAML:

```properties
quarkus.container-image.group=davidlab
quarkus.container-image.name=produtos-api
quarkus.container-image.tag=1.0

quarkus.kubernetes.replicas=3
quarkus.kubernetes.image-pull-policy=IfNotPresent
quarkus.kubernetes.ports.http.host-port=8080

quarkus.kubernetes.resources.requests.memory=128Mi
quarkus.kubernetes.resources.requests.cpu=100m
quarkus.kubernetes.resources.limits.memory=256Mi
quarkus.kubernetes.resources.limits.cpu=500m

quarkus.kubernetes.env.vars.LOG_LEVEL=INFO
```

Roda `./mvnw package` e abre `target/kubernetes/kubernetes.yml` — o Quarkus já colocou tudo no lugar certo.

---

## 4. Probes geradas automaticamente

Quando `smallrye-health` está no classpath, o Quarkus injeta `livenessProbe` e `readinessProbe` apontando pros endpoints `/q/health/live` e `/q/health/ready`. Nada pra configurar.

Quer mudar timings?

```properties
quarkus.kubernetes.liveness-probe.initial-delay=10s
quarkus.kubernetes.readiness-probe.period=5s
```

---

## 5. Lendo ConfigMap do cluster

`quarkus-kubernetes-config` permite que o app puxe configuração direto de um `ConfigMap`:

```properties
quarkus.kubernetes-config.enabled=true
quarkus.kubernetes-config.config-maps=app-config
```

Com isso, qualquer chave no `ConfigMap` `app-config` vira uma propriedade — `@ConfigProperty(name = "minha.chave")` funciona sem nada extra.

Para `Secret`:

```properties
quarkus.kubernetes-config.secrets=app-secret
quarkus.kubernetes-config.secrets.enabled=true
```

---

## 6. Service e Ingress

Por padrão o Quarkus gera um `Service` do tipo `ClusterIP`. Para expor:

```properties
quarkus.kubernetes.service-type=NodePort
quarkus.kubernetes.ingress.expose=true
quarkus.kubernetes.ingress.host=produtos.local
```

---

## 7. Deploy no kind

Como o `kind` roda em containers, ele não enxerga imagens do Docker local. Precisa carregar manualmente:

```bash
./mvnw package
kind load docker-image davidlab/produtos-api:1.0
kubectl apply -f target/kubernetes/kubernetes.yml
kubectl get pods
kubectl port-forward svc/produtos-api 8080:80
```

Combine `image-pull-policy=IfNotPresent` (ou `Never`) para o cluster não tentar puxar do Docker Hub.

---

## 💡 Detalhes

- **Não quer Docker?** Troque por `quarkus-container-image-jib` — constrói imagem sem Dockerfile nem daemon do Docker.
- **OpenShift?** Existe `quarkus-openshift` que gera `DeploymentConfig` e `Route` no lugar.
- **Minikube?** Use `eval $(minikube docker-env)` antes do build pra a imagem já cair no daemon do cluster.
- O arquivo gerado em `target/kubernetes/kubernetes.yml` é versionável — commitar ele dá uma referência clara do que vai pro cluster.
- Renomeie o app com `quarkus.kubernetes.name=outro-nome` se não quiser herdar do `artifactId`.

---

## 🚦 Próximos passos

- Módulo 20: GraphQL e gRPC com Quarkus.
- Experimente `quarkus-kubernetes-client` se precisar conversar com a API do K8s a partir do app.
- Leia sobre `quarkus.kubernetes.annotations` e `quarkus.kubernetes.labels` para integrar com Istio, Prometheus, etc.

---

## ✅ Auto-verificação

- [ ] Sei a diferença entre `container-image-docker` e `container-image-jib`.
- [ ] Consigo gerar `kubernetes.yml` sem aplicar no cluster.
- [ ] Sei aplicar build + deploy num comando só.
- [ ] Customizo `replicas` e `resources` via `application.properties`.
- [ ] Carrego a imagem no `kind` antes do `kubectl apply`.
- [ ] Leio valores de um `ConfigMap` externo com `quarkus-kubernetes-config`.
- [ ] As probes do Health Check aparecem no Deployment gerado.
