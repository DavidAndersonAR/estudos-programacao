package com.exemplo.cache;

import jakarta.inject.Inject;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Path("/cotacao")
@Produces(MediaType.APPLICATION_JSON)
public class CotacaoResource {

    @Inject
    CotacaoService service;

    @GET
    @Path("/{moeda}")
    public BigDecimal atual(@PathParam("moeda") String moeda) {
        return service.cotacaoAtual(moeda);
    }

    @GET
    @Path("/{moeda}/historica")
    public BigDecimal historica(@PathParam("moeda") String moeda) {
        return service.cotacaoHistorica(moeda, LocalDateTime.now().withNano(0), "json");
    }

    @DELETE
    @Path("/{moeda}")
    public void invalidar(@PathParam("moeda") String moeda) {
        service.invalidar(moeda);
    }

    @DELETE
    public void invalidarTudo() {
        service.invalidarTudo();
    }
}
