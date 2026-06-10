package com.exemplo.cache;

import io.quarkus.cache.CacheInvalidate;
import io.quarkus.cache.CacheInvalidateAll;
import io.quarkus.cache.CacheKey;
import io.quarkus.cache.CacheResult;
import jakarta.enterprise.context.ApplicationScoped;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.concurrent.ThreadLocalRandom;

@ApplicationScoped
public class CotacaoService {

    // Simula chamada cara: 1.5s de latência
    @CacheResult(cacheName = "cotacao")
    public BigDecimal cotacaoAtual(String moeda) {
        dormir(1500);
        return BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(4.0, 6.0))
                .setScale(4, BigDecimal.ROUND_HALF_UP);
    }

    // Exemplo com múltiplos parâmetros: só "moeda" e "data" compõem a chave.
    // "formatoSaida" é decorativo e fica de fora.
    @CacheResult(cacheName = "cotacao-historica")
    public BigDecimal cotacaoHistorica(@CacheKey String moeda,
                                       @CacheKey LocalDateTime data,
                                       String formatoSaida) {
        dormir(2000);
        return BigDecimal.valueOf(ThreadLocalRandom.current().nextDouble(3.5, 7.0))
                .setScale(4, BigDecimal.ROUND_HALF_UP);
    }

    @CacheInvalidate(cacheName = "cotacao")
    public void invalidar(String moeda) {
    }

    @CacheInvalidateAll(cacheName = "cotacao")
    public void invalidarTudo() {
    }

    private void dormir(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
