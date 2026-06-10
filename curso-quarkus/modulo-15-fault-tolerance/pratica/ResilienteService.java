package com.exemplo.faulttolerance;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.faulttolerance.CircuitBreaker;
import org.eclipse.microprofile.faulttolerance.Fallback;
import org.eclipse.microprofile.faulttolerance.Retry;
import org.eclipse.microprofile.faulttolerance.Timeout;
import org.jboss.logging.Logger;

import java.time.temporal.ChronoUnit;

@ApplicationScoped
public class ResilienteService {

    private static final Logger LOG = Logger.getLogger(ResilienteService.class);

    @Inject
    ServicoExternoClient client;

    @Retry(maxRetries = 3, delay = 300, delayUnit = ChronoUnit.MILLIS)
    @Timeout(value = 2, unit = ChronoUnit.SECONDS)
    @CircuitBreaker(
        requestVolumeThreshold = 4,
        failureRatio = 0.5,
        delay = 5000,
        successThreshold = 2
    )
    @Fallback(fallbackMethod = "buscarFallback")
    public String buscarComResiliencia(String id) {
        LOG.infof("Chamando servico externo para id=%s", id);
        return client.buscar(id);
    }

    // Mesma assinatura do método protegido
    public String buscarFallback(String id) {
        LOG.warnf("Fallback acionado para id=%s", id);
        return "{\"id\":\"" + id + "\",\"origem\":\"cache-fallback\"}";
    }
}
