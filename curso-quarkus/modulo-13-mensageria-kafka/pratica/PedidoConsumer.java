package com.exemplo.pedidos;

import org.eclipse.microprofile.reactive.messaging.Incoming;

import io.quarkus.logging.Log;
import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class PedidoConsumer {

    @Incoming("pedidos-processados-in")
    public void consumir(Pedido p) {
        Log.infof(">>> Consumer recebeu: id=%d item='%s' qtd=%d", p.id(), p.item(), p.quantidade());
    }
}
