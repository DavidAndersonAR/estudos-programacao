# Módulo 14 — Health Probes

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diferenciar **liveness**, **readiness** e **startup** probes
- Escolher entre `httpGet`, `tcpSocket` e `exec`
- Ajustar timings (`initialDelaySeconds`, `periodSeconds`, etc) sem chutar
- Configurar self-healing pra apps lentas pra subir
- Evitar o anti-pattern clássico: liveness derrubando seu cluster inteiro

## 🩺 O que é uma probe?

Probe (sonda) é um **check periódico** que o kubelet faz dentro do container pra responder uma de três perguntas:

1. *"Esse container está vivo?"* — **livenessProbe**
2. *"Esse container está pronto pra receber tráfego?"* — **readinessProbe**
3. *"Esse container já terminou de subir?"* — **startupProbe**

Cada probe tem **ação diferente** quando falha. É isso que muda tudo.

## 💔 livenessProbe — "tá vivo?"

Se falhar várias vezes seguidas, K8s **mata e reinicia** o container.

**Pra quê serve:** detectar **deadlocks**, threads travadas, app rodando mas não respondendo. Coisa que `process is running` não pega.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3
```

**Regra de ouro:** liveness deve checar **só o processo local**. Nunca chamar banco, fila ou serviço externo.

## 🚦 readinessProbe — "pronto pra receber tráfego?"

Se falhar, K8s **remove o pod do Service Endpoints** — o tráfego para de chegar nele. **Mas o pod continua vivo** (não reinicia).

**Pra quê serve:** app aquecendo cache, aguardando conexão com BD, processando job pesado e não querendo mais request. Quando voltar a passar, K8s **devolve** o pod ao pool.

```yaml
readinessProbe:
  httpGet:
    path: /readyz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 2
```

Aqui sim pode checar dependências externas (BD, cache) — porque falhar **não mata o pod**, só tira ele do balanceador.

## 🐢 startupProbe — "já terminou de subir?"

Pra apps **lentas pra inicializar** (Java Spring, Rails com muitas migrations, ML model carregando 2GB de peso).

Enquanto o startup não passar, **liveness e readiness ficam desabilitadas**. Quando passa uma vez, K8s desliga a startup e ativa as outras duas.

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 8080
  periodSeconds: 5
  failureThreshold: 30   # 30 × 5s = 150s de tolerância pra subir
```

**Sem startupProbe**, você teria que botar `initialDelaySeconds: 150` na liveness — e perderia 150s de reação rápida pra deadlock depois que a app já estava no ar. Com startup você tem o melhor dos dois mundos.

## 🔍 Os 3 tipos de check

### 1. httpGet
Faz GET no path/porta. **Sucesso = status 200–399.**

```yaml
httpGet:
  path: /healthz
  port: 8080
  httpHeaders:
    - name: X-Probe
      value: kubelet
```

Mais comum pra web apps.

### 2. tcpSocket
Tenta abrir TCP na porta. **Sucesso = handshake ok.**

```yaml
tcpSocket:
  port: 5432
```

Bom pra BDs, brokers (Postgres, Redis, Kafka) — coisa que não fala HTTP.

### 3. exec
Roda um comando dentro do container. **Sucesso = exit code 0.**

```yaml
exec:
  command:
    - cat
    - /tmp/healthy
```

Útil pra workers, jobs, ou checks customizados (rodar script de healthcheck).

## ⏱️ Os 5 parâmetros de timing

| Campo | O que significa | Default |
|---|---|---|
| `initialDelaySeconds` | Espera tantos segundos **depois do container iniciar** antes da 1ª probe | 0 |
| `periodSeconds` | Intervalo entre probes | 10 |
| `timeoutSeconds` | Tempo máx esperando resposta | 1 |
| `successThreshold` | Quantos sucessos seguidos pra considerar saudável (liveness é fixo em 1) | 1 |
| `failureThreshold` | Quantas falhas seguidas pra agir (reiniciar / remover do service) | 3 |

**Exemplo de leitura:** `periodSeconds: 10` + `failureThreshold: 3` = K8s espera **30 segundos** de falha antes de matar o container.

## ⚠️ Anti-pattern: cascading failure

Cenário **real e doloroso**:

1. App tem liveness em `/healthz` que **consulta o banco**
2. BD fica lento por 1 min (manutenção, pico de query)
3. `/healthz` começa a dar timeout em todos os pods
4. K8s **reinicia todos** — em cascata
5. Stampede de pods reiniciando bate o BD mais ainda
6. Outage de 30 min

**Regra:** **liveness checa só você mesmo**. Readiness sim pode checar deps externas — porque o pior cenário é o pod sair do load balancer (e voltar quando estabilizar), não morrer.

## 📋 Cheat sheet

```yaml
# Padrão sólido pra app web Go/Node/Python rápida
livenessProbe:
  httpGet: { path: /healthz, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet: { path: /readyz, port: 8080 }
  initialDelaySeconds: 2
  periodSeconds: 5
  failureThreshold: 2

# Adicione startupProbe se app demora >10s pra subir:
startupProbe:
  httpGet: { path: /healthz, port: 8080 }
  periodSeconds: 5
  failureThreshold: 30
```

## 💡 Detalhes que valem ouro
- **Liveness sem readiness é ruim**: pod fica recebendo tráfego enquanto reinicia → erros pro cliente.
- **Readiness sem liveness é aceitável**: pod travado fica fora do pool até alguém perceber.
- **Endpoints separados**: NÃO use `/health` pra tudo. Faça `/healthz` (só ping interno) e `/readyz` (pode checar deps). Salva sua vida.
- **Não exponha `/healthz` pelo Ingress**: é interno do cluster. Senão vira vetor de DoS.
- **kubectl describe pod NOME** mostra falhas de probe na seção `Events` — primeiro lugar pra olhar quando pod fica reiniciando.
- **Probe pesada = problema**: probe que demora 800ms a cada 5s consome CPU à toa. Mantenha barato.
- **`successThreshold` da liveness é sempre 1** — não tente mudar, K8s rejeita.

## 🚦 Próximos passos
1. Estude `AULA.md` (você está aqui)
2. Rode `pratica/comandos.sh` — veja pod ficando Ready e sendo curado
3. Encare o desafio (app crashuda + lenta pra subir)
4. Reflita: qual probe sua app real precisa?

## ✅ Auto-verificação
- [ ] Sei a diferença liveness × readiness × startup
- [ ] Sei quando usar `httpGet`, `tcpSocket` e `exec`
- [ ] Consigo calcular tempo até K8s reagir (period × failureThreshold)
- [ ] Sei por que NÃO checar BD na liveness
- [ ] Configurei probe num deployment real

Próximo módulo: **Resource limits & QoS** — CPU/memória, OOMKilled e classes de qualidade de serviço.
