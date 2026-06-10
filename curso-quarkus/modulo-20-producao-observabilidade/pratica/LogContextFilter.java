package com.exemplo.observabilidade;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.MDC;

import java.util.UUID;

/**
 * Adiciona requestId no MDC em toda request. O traceId/spanId do OpenTelemetry
 * ja entram automaticamente no MDC quando a extensao quarkus-opentelemetry esta ativa.
 *
 * Como ele eh @Provider, o JAX-RS registra sozinho. Nada mais a fazer.
 */
@Provider
public class LogContextFilter implements ContainerRequestFilter, ContainerResponseFilter {

    public static final String REQUEST_ID_HEADER = "X-Request-Id";
    public static final String MDC_REQUEST_ID = "requestId";

    @Override
    public void filter(ContainerRequestContext ctx) {
        String requestId = ctx.getHeaderString(REQUEST_ID_HEADER);
        if (requestId == null || requestId.isBlank()) {
            requestId = UUID.randomUUID().toString();
        }
        MDC.put(MDC_REQUEST_ID, requestId);
        ctx.setProperty(MDC_REQUEST_ID, requestId);
    }

    @Override
    public void filter(ContainerRequestContext req, ContainerResponseContext res) {
        Object requestId = req.getProperty(MDC_REQUEST_ID);
        if (requestId != null) {
            res.getHeaders().putSingle(REQUEST_ID_HEADER, requestId.toString());
        }
        // sempre limpa pra nao vazar pra proxima request da mesma thread
        MDC.remove(MDC_REQUEST_ID);
    }
}
