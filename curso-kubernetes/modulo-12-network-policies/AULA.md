# Módulo 12 — Network Policies

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que K8s **por padrão é totalmente aberto** entre pods
- Escrever uma **NetworkPolicy** com `podSelector`, `policyTypes`, `ingress` e `egress`
- Implementar **default-deny** e abrir buracos cirúrgicos
- Saber por que `kind` puro **não basta** — precisa de Calico/Cilium

## 🔓 O default do K8s é assustador

Sobe um cluster vazio, joga 3 pods (frontend, api, banco). Por padrão:

```
frontend  ──✅──> api
frontend  ──✅──> banco    ← OPS
api       ──✅──> banco
qualquer  ──✅──> qualquer
```

**Qualquer pod fala com qualquer pod**, em qualquer namespace. O frontend pode atacar o banco direto, pulando a API. Isso é por design (simplicidade), mas em produção é um **buraco de segurança**.

**NetworkPolicy** é o firewall L3/L4 do K8s — você define quem pode falar com quem, na camada de pod.

## ⚠️ Pré-requisito: CNI que suporte NetworkPolicy

NetworkPolicy é um **objeto da API**, mas quem **aplica de verdade é o CNI** (plugin de rede). Se seu CNI não suporta, você cria a policy e **K8s aceita o YAML em silêncio — sem efeito nenhum**.

| CNI | Suporta NetworkPolicy? |
|---|---|
| Calico | ✅ Sim (referência) |
| Cilium | ✅ Sim (ainda mais avançado — L7) |
| kindnet (default do kind) | ❌ **NÃO** |
| Flannel | ❌ Não (sozinho) |
| AWS VPC CNI | ⚠️ Parcial |

**No kind**: precisa criar cluster sem CNI default e instalar Calico. Veja `pratica/setup.sh`.

## 📐 Anatomia de uma NetworkPolicy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-pode-falar-com-db
  namespace: app
spec:
  podSelector:               # 1. A QUEM essa policy se aplica
    matchLabels:
      tier: db
  policyTypes:               # 2. Que direções a policy controla
    - Ingress
  ingress:                   # 3. Regras de entrada
    - from:
        - podSelector:
            matchLabels:
              tier: api
      ports:
        - protocol: TCP
          port: 5432
```

Tradução: **"Pods com label `tier=db` só aceitam tráfego de entrada vindo de pods com label `tier=api` na porta TCP 5432. Tudo mais é bloqueado."**

### 1. `podSelector` — A QUEM se aplica
Define **quais pods** a policy governa. `podSelector: {}` = todos os pods do namespace.

### 2. `policyTypes`
- `Ingress` → controla tráfego **entrando** nos pods selecionados
- `Egress` → controla tráfego **saindo** dos pods selecionados
- Pode ter os dois: `[Ingress, Egress]`

### 3. `ingress.from` / `egress.to`
Cada item é um "origens permitidas" (ou destinos). Três tipos de seletor:

```yaml
ingress:
  - from:
      - podSelector:          # pods do MESMO namespace com label X
          matchLabels: {tier: api}
      - namespaceSelector:    # pods de QUALQUER namespace com label Y
          matchLabels: {env: prod}
      - ipBlock:              # range de IPs (útil pra tráfego externo)
          cidr: 10.0.0.0/24
          except: [10.0.0.5/32]
```

## 🛡️ Default-deny: o padrão correto

A receita pra um namespace seguro:

```yaml
# Bloqueia TUDO que entra em qualquer pod do namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}            # todos os pods
  policyTypes: [Ingress]
  # sem ingress: → nada é permitido
```

Depois disso, **nada entra em pod nenhum**. Aí você adiciona policies específicas pra abrir o que precisa. É **whitelist** (lista do que é permitido), não blacklist.

**Importante**: policies **somam** (OR lógico). Se 3 policies se aplicam ao mesmo pod, basta UMA delas permitir pra liberar.

## ⚠️ Pegadinhas que matam

### 1. Policy só vê pods do mesmo namespace
`podSelector` em `from:` cobre **só o namespace da policy**. Pra permitir de outro NS:

```yaml
- namespaceSelector:
    matchLabels: {name: outro-ns}
  podSelector:
    matchLabels: {tier: api}
```

Sem o `namespaceSelector`, pods de outro namespace **nem aparecem** na regra.

### 2. DNS no Egress
Se você fechar egress, **lembra do DNS** (porta 53 UDP pro kube-dns no namespace `kube-system`). Sem isso, nada resolve nome — `curl api` quebra.

```yaml
egress:
  - to:
      - namespaceSelector:
          matchLabels: {kubernetes.io/metadata.name: kube-system}
    ports:
      - protocol: UDP
        port: 53
```

### 3. NetworkPolicy ≠ Service
Service continua roteando. NetworkPolicy só **bloqueia o pacote** se a regra não permitir. Você acessa via Service, o CNI inspeciona o pacote no pod alvo, e cai.

### 4. Sem CNI compatível, é placebo
Aplicou policy, testou, "funcionou"... mas o CNI ignorou. **Sempre teste o bloqueio** — não confie no `kubectl apply` retornar OK.

## 📋 Comandos cheat sheet

| Comando | O que faz |
|---|---|
| `kubectl get networkpolicy` (ou `netpol`) | Lista policies do namespace |
| `kubectl describe netpol NOME` | Detalhes (selector, regras) |
| `kubectl apply -f netpol.yaml` | Cria/atualiza policy |
| `kubectl delete netpol NOME` | Remove policy |
| `kubectl exec POD -- nc -zv HOST PORTA` | Testa conexão TCP (tem que dar timeout se bloqueado) |
| `kubectl exec POD -- wget -qO- --timeout=3 URL` | Testa HTTP rápido |

## 💡 Detalhes que valem ouro
- **Default é allow** — você precisa adicionar policies pra fechar. Postura segura: comece com default-deny em todo namespace.
- **Aplica por pod, não por service**. O selector mira labels do pod.
- **Não filtra L7** (não conhece HTTP path/header). Pra L7 use Cilium ou um service mesh (Istio, Linkerd).
- **Teste sempre o caminho negativo**: o que era pra bloquear realmente bloqueia? Connection refused é diferente de timeout — policy bloqueada dá **timeout**, porta fechada dá **refused**.
- **Egress é menos usado que Ingress**, mas crítico pra compliance (impedir um pod comprometido de chamar a internet).

## 🚦 Próximos passos
1. Veja `pratica/setup.sh` (instala Calico no kind)
2. `pratica/apps.yaml` — sobe frontend, api, db
3. `pratica/netpol.yaml` — fecha tudo, só api→db libera
4. `pratica/comandos.sh` — roteiro de teste
5. Encare o desafio (3 tiers — web/api/db)

## ✅ Auto-verificação
- [ ] Sei que K8s default é "tudo aberto"
- [ ] Sei diferenciar `podSelector` (a quem se aplica) de `from.podSelector` (origens permitidas)
- [ ] Lembro que CNI tem que suportar (kind precisa de Calico)
- [ ] Sei escrever default-deny + abrir buracos cirúrgicos
- [ ] Lembro do DNS quando fecho egress

Próximo módulo: **Resource Limits & QoS** — CPU, memória, e por que seu pod tá sendo morto.
