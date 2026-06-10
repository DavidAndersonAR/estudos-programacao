package com.exemplo.cotacao;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ThreadLocalRandom;

@ApplicationScoped
public class CotacaoService {

    // Simula uma chamada externa lenta (~300ms) sem bloquear thread.
    // .delayIt() agenda no scheduler reativo — nada de Thread.sleep aqui.
    public Uni<Cotacao> buscar(String moeda) {
        double valor = 4.50 + ThreadLocalRandom.current().nextDouble(-0.20, 0.20);
        Cotacao c = new Cotacao(moeda, Math.round(valor * 100.0) / 100.0, Instant.now());
        return Uni.createFrom().item(c)
                .onItem().delayIt().by(Duration.ofMillis(300));
    }
}
