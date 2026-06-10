package com.exemplo.erros;

import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

import java.util.UUID;

/**
 * Rede de segurança: pega qualquer exceção não tratada e devolve 500 sem vazar stack.
 * O stack vai SÓ pro log, junto com um traceId que aparece na resposta.
 */
@Provider
public class GenericExceptionMapper implements ExceptionMapper<Exception> {

    private static final Logger LOG = Logger.getLogger(GenericExceptionMapper.class);

    @Override
    public Response toResponse(Exception ex) {
        // Deixa o RESTEasy tratar WebApplicationException com seu status original
        if (ex instanceof WebApplicationException wae) {
            return wae.getResponse();
        }

        String traceId = UUID.randomUUID().toString();
        LOG.errorf(ex, "Erro inesperado [traceId=%s]", traceId);

        ProblemDetail body = ProblemDetail.de(
                "Erro interno",
                500,
                "Algo deu errado processando sua requisição. Use o traceId pra contatar o suporte.",
                "ERRO_INTERNO"
        );
        body.traceId = traceId;

        return Response.status(500)
                .type("application/problem+json")
                .entity(body)
                .build();
    }
}
