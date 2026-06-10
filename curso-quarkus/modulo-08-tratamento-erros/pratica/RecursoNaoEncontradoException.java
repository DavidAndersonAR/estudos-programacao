package com.exemplo.erros;

/**
 * Lançada quando o recurso pedido não existe. Vira 404.
 */
public class RecursoNaoEncontradoException extends RuntimeException {

    private final String recurso;
    private final Object id;

    public RecursoNaoEncontradoException(String recurso, Object id) {
        super(recurso + " com id " + id + " não encontrado");
        this.recurso = recurso;
        this.id = id;
    }

    public String getRecurso() {
        return recurso;
    }

    public Object getId() {
        return id;
    }
}
