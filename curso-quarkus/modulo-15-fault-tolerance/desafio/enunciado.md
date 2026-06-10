# Desafio — Proteger 3 chamadas externas

Você tem um serviço de e-commerce que chama 3 APIs externas com perfis diferentes. Cada uma precisa de uma combinação específica de fault tolerance.

## Cenários

### 1. `PrecoService` — API de preço (rápida e crítica)

- Tempo médio: 100ms, máximo aceitável: 500ms
- Falha esporadicamente (rede)
- Cliente espera resposta: **não pode** falhar — sempre retornar preço (último preço conhecido como fallback)

**Use**: `@Timeout`, `@Retry`, `@Fallback`

### 2. `EstoqueService` — API de estoque (instável)

- Tempo médio: 200ms
- Quando começa a falhar, falha em sequência por minutos
- Não adianta martelar: precisa parar de chamar quando estiver ruim
- Se não conseguir consultar, assumir "indisponível"

**Use**: `@CircuitBreaker`, `@Fallback`, `@Timeout`

### 3. `RecomendacaoService` — API de recomendação (cara em CPU)

- Cada chamada é cara, máximo 10 simultâneas
- Se passar do limite, melhor retornar lista vazia que enfileirar muito
- Não tem retry — se falhou, falhou

**Use**: `@Bulkhead`, `@Fallback`

## Entregáveis

Crie 3 classes de serviço e um `CheckoutResource` com endpoint `GET /checkout/{produtoId}` que junta as 3 informações em um único JSON.

Cada serviço externo pode ser uma classe `Client` simulada (igual o `ServicoExternoClient` da prática), com comportamento aleatório que cubra os cenários de falha.

## Critérios

- Cada serviço usa as anotações certas pro seu perfil
- Métodos de fallback têm mesma assinatura
- O endpoint sempre responde — nenhuma falha de serviço externo derruba o checkout
- Use `requestVolumeThreshold`, `failureRatio` e `delay` adequados no circuit breaker do estoque
- Bulkhead da recomendação usa modo semáforo (síncrono)

## Dica

Teste batendo no endpoint com `for i in $(seq 1 50); do curl ...; done` e veja se em algum momento o circuito abre, o bulkhead rejeita, ou o timeout estoura. Os logs e `/q/metrics` mostram tudo.
