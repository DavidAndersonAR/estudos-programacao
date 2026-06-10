# Módulo 17 — Cache no Quarkus

## 🎯 Objetivos

- Entender quando cache resolve problema e quando atrapalha.
- Usar a extensão `quarkus-cache` (Caffeine por padrão, em memória).
- Aplicar `@CacheResult`, `@CacheInvalidate`, `@CacheInvalidateAll` e `@CacheKey`.
- Configurar TTL e tamanho máximo via `application.properties`.
- Saber quando trocar Caffeine por Redis (`quarkus-redis-cache`).

---

## Padrões de cache

Antes de cair no código, vale entender dois padrões clássicos:

- **Cache-aside (lazy loading):** a aplicação consulta o cache primeiro. Se não tem (miss), busca na fonte real, grava no cache e devolve. É o que o `@CacheResult` faz por baixo dos panos.
- **Read-through:** o cache em si sabe como buscar quando dá miss. A aplicação só fala com o cache. Mais elegante, porém exige integração mais forte (geralmente com Redis + biblioteca cliente).

Para a maioria dos casos no Quarkus, cache-aside via anotação resolve.

---

## Caffeine vs Redis

| Característica       | Caffeine (default)             | Redis (`quarkus-redis-cache`)        |
|----------------------|--------------------------------|--------------------------------------|
| Localização          | Memória da JVM (local)         | Servidor externo (rede)              |
| Compartilhado entre instâncias? | Não                  | Sim                                  |
| Latência             | Nanosegundos                   | Sub-milissegundo (rede)              |
| Persistência         | Some quando o app reinicia     | Pode persistir conforme config Redis |
| Custo operacional    | Zero                           | Precisa subir e manter o Redis       |
| Uso ideal            | App single-node, hot data      | Vários pods, dados compartilhados    |

Regra prática: comece com Caffeine. Só migre para Redis quando você roda múltiplas instâncias e precisa que todas vejam o mesmo cache.

---

## Anotações principais

Adicione a extensão:

```bash
./mvnw quarkus:add-extension -Dextensions="cache"
```

### `@CacheResult`

Cacheia o retorno. Se a chave já existe, nem entra no método.

```java
@CacheResult(cacheName = "cotacao")
public BigDecimal cotacaoDolar(String moeda) {
    // chamada cara aqui
    return apiExterna.buscar(moeda);
}
```

### `@CacheInvalidate` e `@CacheInvalidateAll`

```java
@CacheInvalidate(cacheName = "cotacao")
public void atualizarManual(String moeda, BigDecimal valor) { ... }

@CacheInvalidateAll(cacheName = "cotacao")
public void resetar() { ... }
```

### `@CacheKey` — quando o método tem mais de um parâmetro

Por padrão, a chave é composta por **todos** os parâmetros. Se você quer escolher só alguns, marque com `@CacheKey`:

```java
@CacheResult(cacheName = "produto-detalhe")
public Produto buscar(@CacheKey Long id, String idiomaResposta) {
    // idiomaResposta entra na resposta, mas não muda o registro no banco
    return repo.findById(id);
}
```

Sem o `@CacheKey`, `idiomaResposta` viraria parte da chave e você teria entradas duplicadas para o mesmo produto.

---

## Configuração (TTL e tamanho)

Cada cache nomeado pode ser ajustado:

```properties
quarkus.cache.caffeine."cotacao".expire-after-write=30S
quarkus.cache.caffeine."cotacao".maximum-size=1000

quarkus.cache.caffeine."produto-cache".expire-after-write=10M
quarkus.cache.caffeine."produto-cache".initial-capacity=100
```

- `expire-after-write`: tempo desde a escrita.
- `expire-after-access`: tempo desde o último uso.
- `maximum-size`: número máximo de entradas (LRU evict).

---

## Invalidação: manual vs por TTL

- **Por TTL:** simples, sem código extra. Bom para dados que ficam "razoavelmente" atualizados (cotações, listas de configuração).
- **Manual (`@CacheInvalidate`):** quando você sabe exatamente em que momento o dado mudou (ex: admin atualizou produto, invalide a entrada daquele id).

Na prática, use os dois juntos: TTL como rede de segurança + invalidação manual para mudanças críticas.

---

## 💡 Detalhes que pegam

- **Cache devolve a mesma referência.** Se o método retorna um objeto mutável e você altera ele do lado do chamador, o próximo hit vê o objeto alterado. Cuidado com DTOs mutáveis; prefira `record` ou objetos imutáveis.
- **Não cacheie tudo.** Dados muito voláteis (saldo de conta, estoque em tempo real) ou write-heavy podem ficar errados rápido. Cache vira fonte de bug.
- **Atenção ao `@CacheKey` esquecido.** Sem ele, qualquer param "decorativo" (idioma, header de tracing) infla a chave.
- **`null` é cacheável.** Se o método pode devolver `null`, isso também fica no cache. Pode ser útil (negative caching) ou um problema, dependendo do caso.
- **Caffeine não é distribuído.** Em K8s com várias réplicas, cada pod tem seu próprio cache. Se você precisa consistência entre pods, vá de Redis.

---

## 🚦 Próximos passos

- Módulo 18: Observabilidade (Micrometer + Prometheus). Métricas de hit/miss de cache são o próximo passo lógico.
- Depois: segurança e autenticação (JWT/OIDC).

---

## ✅ Auto-verificação

1. Qual a diferença entre `@CacheInvalidate` e `@CacheInvalidateAll`?
2. Por que usar `@CacheKey` em um método com 3 parâmetros?
3. Quando trocar Caffeine por Redis?
4. Como configurar TTL de 10 minutos no cache chamado `produto-cache`?
5. Por que retornar objetos imutáveis (ou `record`) em métodos cacheados?
6. Cite dois cenários onde cache faz mais mal do que bem.
