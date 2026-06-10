package com.exemplo.pedidos;

import java.time.Instant;

// DTO de pedido — record serializado como JSON pelo ObjectMapperSerializer
public record Pedido(Long id, String item, Integer quantidade, Instant criadoEm) {

    public Pedido marcarProcessado() {
        return new Pedido(id, item + " [PROCESSADO]", quantidade, criadoEm);
    }
}
