package com.exemplo.faulttolerance;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/status")
@Produces(MediaType.APPLICATION_JSON)
public class StatusResource {

    @Inject
    ResilienteService service;

    @GET
    @Path("/{id}")
    public String status(@PathParam("id") String id) {
        return service.buscarComResiliencia(id);
    }
}
