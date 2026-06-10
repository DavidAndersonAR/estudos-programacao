# Módulo 11 — Ingress

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que `NodePort`/`LoadBalancer` não escala pra dezenas de serviços
- Entender a diferença entre **Ingress** (objeto) e **Ingress Controller** (programa)
- Escrever um Ingress que roteia por **host** e por **path**
- Saber o que é **IngressClass**, **path type** e onde TLS entra
- Subir um `kind` com Ingress funcionando localmente

## 🚪 O problema: 1 LB por Service não escala

Lembra do Módulo 5 (Services)?
- `NodePort`: cada Service abre uma porta `30000-32767` em **todos os nodes**. Funciona, mas é feio (porta alta) e limitado.
- `LoadBalancer`: na cloud (AWS/GCP), cada Service desse tipo **provisiona um Load Balancer de verdade**. Custa dinheiro, demora pra subir, e... 1 LB pra cada microserviço? Empresa com 50 serviços = 50 LBs = 💸💸💸.

E pior: tudo bate em **L4 (TCP/IP)**. Não dá pra fazer "se a URL começa com `/api`, manda pro Service A; se for `/static`, pro B" — isso é **HTTP (L7)**.

## 🧭 A solução: Ingress

**Ingress** é um **roteador L7** (HTTP/HTTPS) dentro do cluster. Uma **única porta de entrada** (e idealmente um único LB na frente) que olha o request HTTP e decide:

- "Host = `api.minha.com`? Manda pro Service `api`."
- "Path começa com `/static`? Manda pro Service `static-files`."
- "É HTTPS? Faz terminação TLS aqui e encaminha HTTP pra dentro."

```
                Internet
                   │
                   ▼
        ┌──────────────────┐
        │  LB (1 só)       │
        └────────┬─────────┘
                 ▼
        ┌──────────────────┐
        │ Ingress Controller │   (nginx/traefik rodando como Pod)
        └────────┬─────────┘
        roteia por host/path
         ┌───────┼────────┐
         ▼       ▼        ▼
       svc-api svc-web svc-admin
```

## 🧩 Ingress ≠ Ingress Controller

Detalhe que confunde todo mundo:

| | |
|---|---|
| **Ingress** (objeto YAML) | Só descreve as **regras** — "host X vai pro service Y". É um manifesto. |
| **Ingress Controller** (Pod) | É o **programa de verdade** que lê esses objetos e implementa as regras (geralmente um nginx ou traefik). |

Sem Controller instalado, criar um `Ingress` **não faz nada**. K8s não vem com controller embutido — você escolhe e instala um:
- **ingress-nginx** (o mais usado — mantido pela comunidade K8s)
- **Traefik** (popular em Docker/K8s pequenos)
- **HAProxy Ingress**
- **Contour** (baseado em Envoy)
- **AWS ALB Ingress** (na AWS — usa ALB de verdade)

## 🏷️ IngressClass: qual controller usa esse Ingress?

Você pode ter **vários controllers** no mesmo cluster (ex: nginx pra apps internos, ALB pra externos). O `IngressClass` diz qual controller deve pegar cada Ingress:

```yaml
spec:
  ingressClassName: nginx
```

Ou via annotation legacy: `kubernetes.io/ingress.class: nginx` (ainda funciona mas é o jeito antigo).

## 📝 Anatomia de um Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-ingress
spec:
  ingressClassName: nginx       # qual controller usa
  rules:
  - host: app.exemplo.com       # filtra por Host header
    http:
      paths:
      - path: /                 # filtra por path
        pathType: Prefix
        backend:
          service:
            name: meu-svc       # qual Service recebe
            port:
              number: 80
```

Tradução: "request chegou com Host `app.exemplo.com` e path começando com `/`? Manda pro Service `meu-svc` na porta 80."

## 🛣️ pathType: a pegadinha

Existem **3 tipos** de path matching. Quase todo mundo erra a primeira vez:

| pathType | O que faz | Exemplo |
|---|---|---|
| **Prefix** | Match por prefixo (segmento) | `/foo` casa com `/foo`, `/foo/`, `/foo/bar` mas NÃO com `/foobar` |
| **Exact** | Match exato | `/foo` casa **só** com `/foo` |
| **ImplementationSpecific** | Depende do controller (regex etc) | nginx aceita regex em algumas configs |

**Use `Prefix`** em 99% dos casos. `Exact` só pra path super específico (ex: `/healthz`).

## 🌐 Host: roteamento por nome

```yaml
rules:
- host: api.exemplo.com   # vai pro svc api
  http: ...
- host: web.exemplo.com   # vai pro svc web
  http: ...
```

Como o cluster sabe que `api.exemplo.com` aponta pra ele? **DNS** — você cria um registro A apontando o domínio pro IP do LB. Em estudo local, dá pra mockar via `/etc/hosts`:

```
127.0.0.1  app1.local.test app2.local.test
```

Sem host (`host:` omitido) = casa **qualquer host**, só filtra por path.

## 🔒 TLS (HTTPS)

```yaml
spec:
  tls:
  - hosts:
    - app.exemplo.com
    secretName: app-tls   # Secret tipo kubernetes.io/tls com cert + key
  rules:
  - host: app.exemplo.com
    http: ...
```

O Secret tem `tls.crt` e `tls.key`. Em produção quase ninguém cria à mão — usa **cert-manager** (Módulo 19-ish), que automatiza Let's Encrypt: você anota o Ingress e ele emite/renova o cert sozinho.

## 🐳 Ingress no kind (gotcha)

`kind` é cluster dentro de Docker. As portas 80/443 do Ingress Controller **não saem sozinhas** — você precisa expor explicitamente no momento de criar o cluster:

```yaml
# kind config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadm... # patches pra liberar porta 80/443
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
  - containerPort: 443
    hostPort: 443
```

Depois instala o controller, e ele escuta nessas portas. Sem isso, `curl localhost` não acha nada.

## 📋 Cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl get ingress` | Lista Ingresses |
| `kubectl describe ingress NOME` | Detalhes + regras + eventos |
| `kubectl get ingressclass` | Lista IngressClasses disponíveis |
| `kubectl get pods -n ingress-nginx` | Ver controller rodando |
| `kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller` | Logs do nginx controller |
| `curl -H "Host: app.exemplo.com" http://IP/` | Testar sem mexer no DNS |

## 💡 Detalhes que valem ouro

- **Ingress só funciona se tem Controller rodando**. 1ª coisa a checar quando "não tá funcionando".
- **Order matters**: regras são avaliadas — path mais específico ganha. `/api/v2` antes de `/api`.
- **Não use Ingress pra TCP/UDP cru** (banco, Redis exposto, etc) — Ingress é HTTP. Use Service `LoadBalancer` ou recursos específicos do controller (nginx tem `tcp-services` ConfigMap).
- **Multi-tenant**: namespaces diferentes podem ter Ingresses apontando pro mesmo host com paths diferentes — controller agrega tudo.
- **Annotations carregam config avançada**: rate-limit, redirect, CORS, body size... cada controller tem seu set (`nginx.ingress.kubernetes.io/...`).
- **Gateway API** é o **sucessor do Ingress** (ainda emergindo). Mesmo conceito, modelo mais expressivo. Por enquanto Ingress ainda domina.

## 🚦 Próximos passos

1. Veja `pratica/setup-kind.sh` — recriar cluster com portas expostas
2. Rode `pratica/ingress-controller.sh` — instalar nginx-ingress
3. Aplique `pratica/app1.yaml`, `app2.yaml`, `ingress.yaml`
4. Adicione hosts em `/etc/hosts` (ou `C:\Windows\System32\drivers\etc\hosts` no Windows)
5. Teste com `curl` — confirme roteamento por host
6. Encare o desafio (roteamento por path)

## ✅ Auto-verificação

- [ ] Entendo a diferença Ingress vs Ingress Controller
- [ ] Sei que IngressClass diz qual controller pega o objeto
- [ ] Sei a diferença entre `pathType: Prefix` e `Exact`
- [ ] Configurei o kind com `extraPortMappings`
- [ ] Roteei 2 apps por host diferentes no mesmo cluster
- [ ] Sei onde TLS entra (mesmo sem ter configurado ainda)

Próximo módulo: **Network Policies** — firewall dentro do cluster.
