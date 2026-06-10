package com.exemplo;

import jakarta.inject.Inject;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import org.jboss.resteasy.reactive.RestPath;

import java.util.List;

@Path("/produtos")
public class ProdutoResource {

    @Inject
    ProdutoService service;

    @GET
    public List<Produto> listar() {
        return service.listar();
    }

    @GET
    @Path("/{id}")
    public Response buscar(@RestPath Long id) {
        return service.buscar(id)
                .map(p -> Response.ok(p).build())
                .orElse(Response.status(404).build());
    }

    @POST
    public Response criar(Produto novo) {
        try {
            Produto salvo = service.criar(novo);
            return Response.status(201).entity(salvo).build();
        } catch (IllegalArgumentException e) {
            return Response.status(400).entity(e.getMessage()).build();
        }
    }

    @DELETE
    @Path("/{id}")
    public Response deletar(@RestPath Long id) {
        return service.deletar(id)
                ? Response.noContent().build()
                : Response.status(404).build();
    }
}
