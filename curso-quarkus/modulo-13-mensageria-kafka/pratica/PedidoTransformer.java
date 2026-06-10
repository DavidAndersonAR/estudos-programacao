package com.exemplo.pedidos;

import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.eclipse.microprofile.reactive.messaging.Outgoing;

import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PedidoTransformer {

    // Lê de "pedidos", marca como processado, e republica em "pedidos-processados"
    @Incoming("pedidos-in")
    @Outgoing("pedidos-processados-out")
    public Pedido processar(Pedido p) {
        Log.infof("Transformando pedido %d", p.id());
        return p.marcarProcessado();
    }
}
