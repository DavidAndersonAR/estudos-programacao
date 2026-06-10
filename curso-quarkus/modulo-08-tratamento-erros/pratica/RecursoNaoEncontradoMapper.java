package com.exemplo.erros;

import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class RecursoNaoEncontradoMapper implements ExceptionMapper<RecursoNaoEncontradoException> {

    private static final String PROBLEM_JSON = "application/problem+json";

    @Override
    public Response toResponse(RecursoNaoEncontradoException ex) {
        ProblemDetail body = ProblemDetail.de(
                "Recurso não encontrado",
                404,
                ex.getMessage(),
                "RECURSO_NAO_ENCONTRADO"
        );
        return Response.status(404)
                .type(PROBLEM_JSON)
                .entity(body)
                .build();
    }
}
