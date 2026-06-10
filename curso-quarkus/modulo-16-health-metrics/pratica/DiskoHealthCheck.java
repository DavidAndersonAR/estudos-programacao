package com.exemplo.observabilidade;

import jakarta.enterprise.context.ApplicationScoped;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;

import java.io.File;

@Liveness
@ApplicationScoped
public class DiskoHealthCheck implements HealthCheck {

    private static final long LIMITE_MINIMO_BYTES = 100L * 1024 * 1024; // 100 MB

    @Override
    public HealthCheckResponse call() {
        File raiz = new File("/");
        long livre = raiz.getUsableSpace();
        boolean saudavel = livre > LIMITE_MINIMO_BYTES;

        return HealthCheckResponse.named("Disco")
                .status(saudavel)
                .withData("livre_mb", livre / (1024 * 1024))
                .withData("limite_mb", LIMITE_MINIMO_BYTES / (1024 * 1024))
                .build();
    }
}
