package com.exemplo.saudacao;

import io.quarkus.grpc.GrpcClient;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.jboss.resteasy.reactive.RestStreamElementType;

// Endpoint REST que chama o servico gRPC internamente.
// Util pra ver o gRPC em pe sem precisar de grpcurl o tempo todo.
@Path("/saudacao")
public class SaudacaoResource {

    @GrpcClient("saudacao")
    Saudacao client;

    @GET
    @Path("/{nome}")
    @Produces(MediaType.TEXT_PLAIN)
    public Uni<String> ola(@PathParam("nome") String nome) {
        return client.dizerOla(OlaRequest.newBuilder().setNome(nome).build())
                .map(OlaReply::getMensagem);
    }

    @GET
    @Path("/stream/{nome}")
    @Produces(MediaType.SERVER_SENT_EVENTS)
    @RestStreamElementType(MediaType.TEXT_PLAIN)
    public Multi<String> olaStream(@PathParam("nome") String nome) {
        return client.dizerOlaStream(OlaRequest.newBuilder().setNome(nome).build())
                .map(OlaReply::getMensagem);
    }
}
