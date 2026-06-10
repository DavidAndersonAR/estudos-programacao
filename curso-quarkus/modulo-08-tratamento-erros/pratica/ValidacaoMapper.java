package com.exemplo.erros;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Path;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

import java.util.List;

@Provider
public class ValidacaoMapper implements ExceptionMapper<ConstraintViolationException> {

    @Override
    public Response toResponse(ConstraintViolationException ex) {
        List<ProblemDetail.CampoErro> erros = ex.getConstraintViolations().stream()
                .map(this::toCampoErro)
                .toList();

        ProblemDetail body = ProblemDetail.de(
                "Validação falhou",
                422,
                "Um ou mais campos estão inválidos",
                "VALIDACAO"
        );
        body.errors = erros;

        return Response.status(422)
                .type("application/problem+json")
                .entity(body)
                .build();
    }

    /** Pega só o nome do último nó do path (ex.: "criar.produto.nome" → "nome"). */
    private ProblemDetail.CampoErro toCampoErro(ConstraintViolation<?> v) {
        String campo = "?";
        for (Path.Node node : v.getPropertyPath()) {
            campo = node.getName();
        }
        return new ProblemDetail.CampoErro(campo, v.getMessage());
    }
}
