package com.exemplo;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.util.Map;

@Path("/status")
public class StatusResource {

    @Inject
    AppConfig config;

    @Inject
    EmailService email;

    @ConfigProperty(name = "quarkus.profile", defaultValue = "prod")
    String profileAtivo;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Map<String, Object> status() {
        return Map.of(
                "profile", profileAtivo,
                "remetente", config.email().remetente(),
                "assuntoPadrao", config.email().assuntoPadrao(),
                "copiaOculta", config.email().copiaOculta().orElse(null),
                "limiteRequisicoes", config.limiteRequisicoes(),
                "betaAtivo", config.feature().beta()
        );
    }

    @GET
    @Path("/teste-envio")
    @Produces(MediaType.TEXT_PLAIN)
    public String testeEnvio() {
        return email.enviar("cliente@destino.com", "Olá!");
    }
}
