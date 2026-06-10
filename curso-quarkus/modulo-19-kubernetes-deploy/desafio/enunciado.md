# Desafio do Módulo 19 — Deploy completo no kind

## Cenário

Você precisa subir uma API de **Pedidos** no cluster `kind` com:

1. **3 réplicas** rodando.
2. Configuração externa lida de um **ConfigMap** (`pedidos-config`) com a chave `pedidos.mensagem-padrao`.
3. **Secret** chamado `pedidos-secret` com a chave `db.password` lida pelo app.
4. **Ingress** expondo o app em `pedidos.local`.
5. Health checks ativos com probes geradas automaticamente.
6. Imagem com tag `davidlab/pedidos-api:1.0`, construída pelo próprio Quarkus (sem `Dockerfile`).

## Requisitos técnicos

- Use as extensões: `quarkus-kubernetes`, `quarkus-container-image-docker`, `quarkus-kubernetes-config`, `quarkus-smallrye-health`.
- Recursos: `requests` 128Mi/100m, `limits` 512Mi/500m.
- A imagem **não** pode ser puxada do registry externo (`image-pull-policy=Never` ou `IfNotPresent`).
- Tudo aplicado num cluster `kind` chamado `desafio`.

## Entregáveis

1. `application.properties` com toda a configuração.
2. `configmap.yaml` e `secret.yaml` criados antes do app subir.
3. Script `comandos.sh` que executa o fluxo do zero:
   - cria o cluster `kind`
   - aplica ConfigMap e Secret
   - faz build da imagem
   - carrega no kind
   - aplica os manifests gerados
   - verifica que as 3 réplicas estão `Ready`

## Critérios de aceitação

- `kubectl get pods` mostra 3 pods da API em `Running`.
- `kubectl get ingress` mostra a regra para `pedidos.local`.
- `curl -H "Host: pedidos.local" http://localhost/pedidos/mensagem` devolve o valor que está no ConfigMap.
- `kubectl describe deployment pedidos-api` mostra as probes `/q/health/live` e `/q/health/ready`.
- O endpoint que usa `db.password` consegue ler a senha do Secret.
