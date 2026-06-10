package com.exemplo.observabilidade;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import io.micrometer.core.annotation.Counted;
import io.micrometer.core.annotation.Timed;
import io.micrometer.core.instrument.MeterRegistry;

import java.math.BigDecimal;
import java.util.concurrent.ThreadLocalRandom;

@Path("/pedidos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PedidoMetricsResource {

    @Inject
    MeterRegistry registry;

    @Inject
    FilaPedidos fila;

    @POST
    @Counted(value = "pedidos.criados", description = "Total de pedidos criados via API")
    @Timed(value = "pedidos.tempo_criacao", description = "Tempo pra criar um pedido", histogram = true)
    public Response criar(PedidoDTO novo) throws InterruptedException {
        Thread.sleep(ThreadLocalRandom.current().nextLong(20, 80));

        fila.adicionar(novo);

        registry.summary("pedido.valor", "moeda", "BRL")
                .record(novo.valor.doubleValue());

        registry.counter("pedidos.por_status", "status", novo.status == null ? "PENDENTE" : novo.status)
                .increment();

        return Response.status(Response.Status.CREATED).entity(novo).build();
    }

    @GET
    @Path("/processar-proximo")
    @Timed(value = "pedidos.tempo_processamento")
    public Response processarProximo() {
        PedidoDTO p = fila.consumir();
        if (p == null) {
            registry.counter("pedidos.fila_vazia").increment();
            return Response.status(Response.Status.NO_CONTENT).build();
        }
        return Response.ok(p).build();
    }

    public static class PedidoDTO {
        public String cliente;
        public BigDecimal valor;
        public String status;
    }
}
