package com.exemplo.observabilidade;

import io.opentelemetry.instrumentation.annotations.WithSpan;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.jboss.logging.Logger;
import org.jboss.logging.MDC;

import java.math.BigDecimal;
import java.util.Map;

@Path("/pedidos")
@Produces(MediaType.APPLICATION_JSON)
public class PedidoResource {

    private static final Logger log = Logger.getLogger(PedidoResource.class);

    @Inject
    FretService fret;

    @POST
    @WithSpan("criar-pedido")
    public Response criar(Map<String, Object> payload) {
        Long clienteId = ((Number) payload.get("clienteId")).longValue();
        MDC.put("clienteId", clienteId.toString());

        log.info("recebido pedido para criacao");

        BigDecimal frete = fret.calcular(clienteId);
        log.infof("frete calculado: %s", frete);

        // ...persistencia omitida pra focar em observabilidade...

        log.info("pedido criado");
        MDC.remove("clienteId");
        return Response.status(Response.Status.CREATED)
                .entity(Map.of("frete", frete))
                .build();
    }

    @GET
    @Path("/{id}")
    @WithSpan("buscar-pedido")
    public Response buscar(@PathParam("id") Long id) {
        MDC.put("pedidoId", id.toString());
        log.info("buscando pedido");
        try {
            // banco etc
            return Response.ok(Map.of("id", id, "status", "PAGO")).build();
        } finally {
            MDC.remove("pedidoId");
        }
    }
}

// ===== Servico auxiliar com span customizado =====
@jakarta.enterprise.context.ApplicationScoped
class FretService {

    private static final Logger log = Logger.getLogger(FretService.class);

    @WithSpan("calcular-frete")
    public BigDecimal calcular(Long clienteId) {
        log.debugf("calculando frete para cliente %d", clienteId);
        return new BigDecimal("19.90");
    }
}
