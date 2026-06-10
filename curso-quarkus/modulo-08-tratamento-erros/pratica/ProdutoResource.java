package com.exemplo.erros;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import org.jboss.resteasy.reactive.RestPath;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Path("/produtos")
public class ProdutoResource {

    private final Map<Long, Produto> banco = new ConcurrentHashMap<>(Map.of(
            1L, new Produto(1L, "Caneta", 5.0),
            2L, new Produto(2L, "Caderno", 25.0)
    ));

    @GET
    @Path("/{id}")
    public Produto buscar(@RestPath Long id) {
        Produto p = banco.get(id);
        if (p == null) {
            throw new RecursoNaoEncontradoException("Produto", id);
        }
        return p;
    }

    @POST
    public Produto criar(@Valid Produto novo) {
        long id = banco.size() + 1L;
        novo.id = id;
        banco.put(id, novo);
        return novo;
    }

    /** Endpoint só pra testar o catch-all (500). */
    @GET
    @Path("/boom")
    public Produto boom() {
        throw new IllegalStateException("estourei de propósito");
    }

    public static class Produto {
        public Long id;

        @NotBlank(message = "não pode ser vazio")
        public String nome;

        @Positive(message = "deve ser maior que 0")
        public Double preco;

        public Produto() {
        }

        public Produto(Long id, String nome, Double preco) {
            this.id = id;
            this.nome = nome;
            this.preco = preco;
        }
    }
}
