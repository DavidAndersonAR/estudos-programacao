package com.exemplo.faulttolerance;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.Random;

@ApplicationScoped
public class ServicoExternoClient {

    private final Random random = new Random();

    // Simula serviço externo flaky: 60% falha, 20% lento, 20% ok
    public String buscar(String id) {
        int sorteio = random.nextInt(100);

        if (sorteio < 60) {
            throw new RuntimeException("Serviço externo indisponível");
        }

        if (sorteio < 80) {
            try {
                Thread.sleep(3000); // mais lento que timeout
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return "{\"id\":\"" + id + "\",\"origem\":\"servico-lento\"}";
        }

        return "{\"id\":\"" + id + "\",\"origem\":\"servico-externo\"}";
    }
}
