package com.exemplo.cep;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/cep")
@Produces(MediaType.APPLICATION_JSON)
public class CepResource {

    @Inject
    EnderecoService service;

    @GET
    @Path("/{cep}")
    public Response buscar(@PathParam("cep") String cep) {
        try {
            Endereco e = service.porCep(cep);
            if (e == null || e.cep() == null) {
                return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"erro\":\"CEP não encontrado\"}")
                    .build();
            }
            return Response.ok(e).build();
        } catch (IllegalArgumentException ex) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("{\"erro\":\"" + ex.getMessage() + "\"}")
                .build();
        }
    }
}
