package com.exemplo.cotacao;

import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

import java.time.Duration;

@Path("/cotacao")
public class CotacaoResource {

    @Inject
    CotacaoService service;

    // Endpoint reativo simples — retorna Uni<Cotacao>.
    // RESTEasy Reactive subscreve e devolve JSON quando o item chega.
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Uni<Cotacao> uma() {
        return service.buscar("USD");
    }

    @GET
    @Path("/{moeda}")
    @Produces(MediaType.APPLICATION_JSON)
    public Uni<Cotacao> porMoeda(@PathParam("moeda") String moeda) {
        return service.buscar(moeda.toUpperCase());
    }

    // SSE: emite uma cotação a cada 1 segundo, indefinidamente.
    // Teste com:  curl -N http://localhost:8080/cotacao/stream
    @GET
    @Path("/stream")
    @Produces(MediaType.SERVER_SENT_EVENTS)
    public Multi<Cotacao> stream() {
        return Multi.createFrom().ticks().every(Duration.ofSeconds(1))
                .onItem().transformToUniAndConcatenate(tick -> service.buscar("USD"));
    }
}
