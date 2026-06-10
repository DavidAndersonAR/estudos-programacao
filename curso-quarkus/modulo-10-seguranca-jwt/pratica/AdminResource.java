package com.exemplo.seguranca;

import jakarta.annotation.security.RolesAllowed;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/admin")
@Produces(MediaType.APPLICATION_JSON)
public class AdminResource {

    @GET
    @Path("/painel")
    @RolesAllowed("admin")
    public String painel() {
        return "{\"msg\":\"voce eh admin\"}";
    }

    @GET
    @Path("/relatorio")
    @RolesAllowed({"admin", "auditor"})
    public String relatorio() {
        return "{\"msg\":\"relatorio sensivel\"}";
    }
}
