package com.exemplo.observabilidade;

import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Tags;

@ApplicationScoped
public class MetricasCustomizadas {

    @Inject
    MeterRegistry registry;

    @Inject
    FilaPedidos fila;

    @PostConstruct
    void registrar() {
        // Gauge: lê o tamanho da fila toda vez que o /q/metrics é raspado
        registry.gauge("pedidos.fila.pendentes",
                Tags.of("regiao", "sudeste"),
                fila,
                FilaPedidos::tamanho);

        // Gauge de memória livre da JVM (extra, só pra ilustrar)
        registry.gauge("app.memoria.livre_mb",
                Runtime.getRuntime(),
                rt -> rt.freeMemory() / (1024.0 * 1024.0));
    }
}
