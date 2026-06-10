package com.exemplo.pedidos;

import java.time.Instant;
import java.util.concurrent.atomic.AtomicLong;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import io.quarkus.logging.Log;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;

@Path("/pedidos")
public class PedidoProducer {

    private static final AtomicLong SEQ = new AtomicLong(1);

    @Channel("pedidos-out")
    Emitter<Pedido> emitter;

    @POST
    public Response criar(Pedido entrada) {
        var p = new Pedido(SEQ.getAndIncrement(), entrada.item(), entrada.quantidade(), Instant.now());
        emitter.send(p);
        Log.infof("Publicado no Kafka: %s", p);
        return Response.accepted(p).build();
    }
}
