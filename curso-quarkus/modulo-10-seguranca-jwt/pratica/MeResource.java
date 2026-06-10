package com.exemplo.seguranca;

import io.quarkus.security.Authenticated;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.jwt.JsonWebToken;
import java.util.Map;

@Path("/me")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class MeResource {

    @Inject JsonWebToken jwt;

    @GET
    public Map<String, Object> eu() {
        return Map.of(
            "usuario", jwt.getName(),
            "issuer", jwt.getIssuer(),
            "grupos", jwt.getGroups(),
            "expira", jwt.getExpirationTime(),
            "email", jwt.getClaim("email")
        );
    }
}
