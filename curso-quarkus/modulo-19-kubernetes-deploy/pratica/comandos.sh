#!/usr/bin/env bash
set -e

# 1. Criar cluster kind (se ainda nao tiver)
kind create cluster --name quarkus-lab

# 2. Aplicar ConfigMap antes do app (o app precisa dele no startup)
kubectl apply -f configmap.yaml

# 3. Adicionar extensoes (uma vez so)
./mvnw quarkus:add-extension -Dextensions="kubernetes,container-image-docker,kubernetes-config,smallrye-health"

# 4. Build + gera imagem + gera manifests (sem aplicar ainda)
./mvnw package -DskipTests

# 5. Ver o YAML gerado
cat target/kubernetes/kubernetes.yml

# 6. Carregar imagem no kind (kind nao enxerga o Docker local)
kind load docker-image davidlab/produtos-api:1.0 --name quarkus-lab

# 7. Aplicar manifests
kubectl apply -f target/kubernetes/kubernetes.yml

# 8. Acompanhar
kubectl get pods -w

# 9. Logs e port-forward
kubectl logs -l app.kubernetes.io/name=produtos-api --tail=50
kubectl port-forward svc/produtos-api 8080:80

# 10. Tudo num comando so (build + push + apply)
./mvnw package -Dquarkus.kubernetes.deploy=true -DskipTests
