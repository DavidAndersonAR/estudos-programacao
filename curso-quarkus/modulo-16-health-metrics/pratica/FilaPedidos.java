package com.exemplo.observabilidade;

import jakarta.enterprise.context.ApplicationScoped;

import java.util.concurrent.ConcurrentLinkedQueue;

@ApplicationScoped
public class FilaPedidos {

    private final ConcurrentLinkedQueue<PedidoMetricsResource.PedidoDTO> fila = new ConcurrentLinkedQueue<>();

    public void adicionar(PedidoMetricsResource.PedidoDTO p) {
        fila.offer(p);
    }

    public PedidoMetricsResource.PedidoDTO consumir() {
        return fila.poll();
    }

    public int tamanho() {
        return fila.size();
    }
}
