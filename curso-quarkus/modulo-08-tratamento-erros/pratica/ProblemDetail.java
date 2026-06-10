package com.exemplo.erros;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

/**
 * Payload de erro no formato RFC 7807 (application/problem+json).
 * Campos nulos são omitidos da serialização.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProblemDetail {

    public String type;
    public String title;
    public int status;
    public String detail;
    public String instance;

    // extensões nossas
    public String code;
    public String traceId;
    public List<CampoErro> errors;

    public ProblemDetail() {
    }

    public ProblemDetail(String title, int status, String detail) {
        this.title = title;
        this.status = status;
        this.detail = detail;
    }

    public static ProblemDetail de(String title, int status, String detail, String code) {
        ProblemDetail p = new ProblemDetail(title, status, detail);
        p.code = code;
        return p;
    }

    public static class CampoErro {
        public String campo;
        public String mensagem;

        public CampoErro() {
        }

        public CampoErro(String campo, String mensagem) {
            this.campo = campo;
            this.mensagem = mensagem;
        }
    }
}
