# Módulo 02 — Pods

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é Pod e por que ele existe (em vez de "container solto")
- Entender o ciclo de vida de um Pod
- Criar Pods via YAML (modo declarativo)
- Rodar **multi-container pods** (app + sidecar) com volume compartilhado
- Usar **init containers** pra preparar coisas antes do container principal subir
- Inspecionar, debugar e expor um Pod com `kubectl`

## 🧱 Pod: a menor unidade do K8s

Você **não roda container no K8s**. Você roda **Pod**, que é um envelope em volta de 1+ containers.

Por que esse envelope existe?
- Containers de um mesmo Pod **compartilham rede** (mesmo IP, mesmas portas — falam entre si por `localhost`).
- Compartilham **volumes** (arquivos visíveis pros dois).
- Sobem e morrem **juntos** — são agendados no mesmo node.

Regra prática: **1 container por Pod**, salvo quando há um motivo forte pra ter mais (sidecar, init, ambassador).

## 🔄 Ciclo de vida do Pod

```
Pending  → Running  → Succeeded   (rodou e terminou OK)
                  ↘  Failed       (rodou e terminou com erro)
                  ↘  Unknown      (kubelet não respondeu)
```

- **Pending**: criado, mas algum container ainda não subiu (puxando imagem, esperando volume, etc).
- **Running**: pelo menos 1 container rodando.
- **Succeeded**: todos terminaram com exit 0 e **não vão reiniciar**.
- **Failed**: todos terminaram, **pelo menos um** com falha.

Você vê o estado em `kubectl get pod NOME` na coluna `STATUS`.

### `restartPolicy`
Define o que fazer quando um container do Pod morre:
- **Always** (default): reinicia sempre. Usado em apps long-running (web server, daemon).
- **OnFailure**: reinicia só se sair com erro (exit != 0). Bom pra jobs que podem falhar e quer retry.
- **Never**: nunca reinicia. Bom pra jobs one-shot.

> ⚠️ `restartPolicy` é do **Pod inteiro**, vale pra todos os containers dele.

## 👥 Multi-container Pods

Um Pod pode ter vários containers. Eles:
- Compartilham **a mesma rede** (cada um vê o outro em `localhost:PORTA`)
- Podem compartilhar **volumes** (`emptyDir`, `hostPath`, etc)
- Sobem juntos, morrem juntos, são agendados juntos

### Pattern: Sidecar
Container "auxiliar" rodando ao lado do principal pra adicionar funcionalidade **sem mexer no código**.

Exemplos reais:
- **Log shipper**: app escreve log em arquivo, sidecar lê e manda pra Elasticsearch/Loki.
- **Proxy/Service mesh**: Envoy/Istio injeta um sidecar que intercepta todo tráfego (mTLS, retry, telemetria).
- **Config reloader**: sidecar observa um ConfigMap e dá `SIGHUP` no app quando muda.

### Pattern: Ambassador
Sidecar que **representa o mundo externo** pro app — o app fala com `localhost`, o ambassador resolve a complexidade.

Exemplo: app fala com `localhost:6379` (Redis), mas o ambassador faz sharding entre 5 Redis reais.

### Pattern: Adapter
Sidecar que **normaliza saída** do app pro mundo externo. App expõe métricas no formato X, adapter converte pra Prometheus.

## 🚀 Init Containers

Containers que rodam **ANTES** dos containers principais. Cada um precisa **terminar com sucesso** antes do próximo começar. Só quando todos terminam é que os `containers` normais sobem.

Pra que servem:
- Esperar um serviço dependente ficar pronto (`wait-for-db`).
- Baixar/gerar arquivos de config.
- Rodar migrations.
- Setar permissões em volumes.

Características:
- Rodam **em sequência**, um por vez.
- Se um falhar, o Pod fica em `Init:Error` e reinicia (conforme `restartPolicy`).
- Aparecem com nome próprio em `kubectl describe`.

```yaml
spec:
  initContainers:
    - name: setup
      image: busybox
      command: ["sh", "-c", "echo pronto > /data/config.txt"]
  containers:
    - name: app
      image: nginx
```

## 🔍 Debug essencial

```bash
kubectl get pods                          # lista
kubectl get pod NOME -o wide              # mostra IP, node
kubectl get pod NOME -o yaml              # YAML completo (estado real)
kubectl describe pod NOME                 # eventos + status dos containers
kubectl logs NOME                         # logs (se só tem 1 container)
kubectl logs NOME -c CONTAINER            # logs de container específico
kubectl logs NOME -c CONTAINER --previous # logs da execução anterior (depois de crash)
kubectl exec -it NOME -- sh               # shell no container default
kubectl exec -it NOME -c CONTAINER -- sh  # shell num container específico
kubectl port-forward NOME 8080:80         # porta local → porta do pod
```

> 💡 Em multi-container Pod, **sempre** passe `-c NOME_DO_CONTAINER` em `logs` e `exec`. Sem `-c`, vai dar erro pedindo pra você escolher.

## 📋 Anatomia de um Pod YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meu-pod
  labels:
    app: web
spec:
  restartPolicy: Always
  containers:
    - name: nginx
      image: nginx:alpine
      ports:
        - containerPort: 80
      volumeMounts:
        - name: dados
          mountPath: /usr/share/nginx/html
  volumes:
    - name: dados
      emptyDir: {}
```

Partes-chave:
- **`apiVersion` + `kind`**: tipo do recurso (Pod, Deployment, Service...).
- **`metadata`**: nome, labels, namespace.
- **`spec`**: o que você quer.
- **`containers[].image`**: imagem Docker.
- **`volumes`** + **`volumeMounts`**: define volumes no Pod e monta dentro do container.

## 💡 Detalhes que valem ouro
- **Pods são efêmeros**. Quando morrem, **não voltam sozinhos** com o mesmo nome/IP. Por isso na vida real você usa **Deployment** (próximos módulos), nunca Pod cru.
- **emptyDir** vive enquanto o Pod vive. Pod morreu → dados perdidos. Pra persistir use PersistentVolume.
- **`localhost` entre containers do mesmo Pod**: app na porta 8080 e sidecar na 9090 se acham por `localhost:8080` / `localhost:9090`. Não precisa de Service.
- **Init container ≠ sidecar**. Init roda **antes e termina**. Sidecar roda **junto e fica vivo**.
- **`kubectl describe` é o melhor amigo do debug** — mostra eventos (imagem não baixou, crashloop, OOMKilled...).
- **CrashLoopBackOff** = container tá morrendo e reiniciando em loop. O K8s espera cada vez mais entre tentativas (backoff exponencial).

## 🎮 Mão na massa
1. Rode `pratica/comandos.sh` linha a linha.
2. Brinque com `kubectl describe` em todos os pods que criar.
3. Encare o desafio em `desafio/`.

## ✅ Auto-verificação
- [ ] Sei o que é Pod e por que ele existe
- [ ] Sei os estados do ciclo de vida
- [ ] Consigo escrever um YAML de Pod do zero
- [ ] Consigo rodar Pod com 2 containers e fazer eles se enxergarem
- [ ] Sei usar `-c` em `logs` e `exec`
- [ ] Sei pra que serve init container

Próximo módulo: **Deployments** — pods que se auto-curam e escalam.
