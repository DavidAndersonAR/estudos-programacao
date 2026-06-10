# Checklist de produção — Quarkus

Marque cada item:
- `[x]` OK
- `[ ]` faltando (escreva uma linha do gap)
- `[~]` parcial (escreva o que falta)
- `[N/A]` não se aplica (justifique)

---

## Banco / Persistência

- [ ] **1. Schema generation = `validate`** em prod (nunca `drop`/`update`).
- [ ] **2. Migrações versionadas** com Flyway ou Liquibase, no repo.
- [ ] **3. Backup automatizado e restore testado** em ambiente de homologação.

## Secrets / Config

- [ ] **4. Nenhum secret no properties versionado** (senha, token, chave privada).
- [ ] **5. Chaves JWT** (pública/privada) vindo de secret manager ou volume.
- [ ] **6. Configs sensíveis via env vars** (`${VAR}` no properties).

## Segurança da API

- [ ] **7. RBAC ativo** (`@RolesAllowed`) nos endpoints sensíveis.
- [ ] **8. Swagger/OpenAPI off em prod**, ou atrás de auth.
- [ ] **9. CORS restrito** a origens conhecidas.
- [ ] **10. Rate limiting / Fault tolerance** nos endpoints expostos.

## Runtime / Kubernetes

- [ ] **11. Resources `requests` e `limits`** (CPU e memória) definidos.
- [ ] **12. Probes**: liveness, readiness e startup apontando para `/q/health/*`.
- [ ] **13. Mais de 1 réplica** + `PodDisruptionBudget`.
- [ ] **14. HPA configurado** (CPU ou métrica custom).
- [ ] **15. `terminationGracePeriodSeconds` > `quarkus.shutdown.timeout`**.

## Observabilidade

- [ ] **16. Logs em JSON** com `traceId` e `requestId`.
- [ ] **17. Métricas Prometheus** expostas e com scrape configurado.
- [ ] **18. Traces OTLP** saindo para Tempo/Jaeger.
- [ ] **19. Dashboards e alertas básicos** (latência p95, erro %, saturação).

## Entrega / Operação

- [ ] **20. CI/CD com testes** obrigatórios antes do deploy.
- [ ] **21. Native build avaliado** (opcional; pra cold start crítico).
- [ ] **22. Runbook mínimo** documentado (alerta X → ação Y, onde olhar).

---

## Plano de ação

### P0 (bloqueante — não sobe sem isso)
- ...

### P1 (próxima sprint)
- ...

### P2 (bom ter)
- ...

---

## Melhorias implementadas neste desafio
1. ...
2. ...
3. ...
