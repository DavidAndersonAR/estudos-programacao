package com.exemplo.cep;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.annotation.ClientHeaderParam;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

// Interface declarativa: Quarkus gera a implementação HTTP.
// configKey liga essa interface ao bloco `quarkus.rest-client.viacep.*` no application.properties.
@Path("/ws")
@RegisterRestClient(configKey = "viacep")
@Produces(MediaType.APPLICATION_JSON)
@ClientHeaderParam(name = "User-Agent", value = "curso-quarkus/1.0")
public interface ViaCepClient {

    @GET
    @Path("/{cep}/json")
    Endereco buscar(@PathParam("cep") String cep);
}
