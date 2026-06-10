package com.exemplo.seguranca;

import io.smallrye.jwt.build.Jwt;
import jakarta.annotation.security.PermitAll;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.time.Duration;
import java.util.Set;

@Path("/login")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.TEXT_PLAIN)
public class LoginResource {

    public record Credenciais(String usuario, String senha) {}

    @POST
    @PermitAll
    public Response login(Credenciais c) {
        Set<String> grupos = autentica(c);
        if (grupos == null) {
            return Response.status(401).entity("credenciais invalidas").build();
        }
        String token = Jwt.issuer("https://meusite.dev")
                          .upn(c.usuario())
                          .groups(grupos)
                          .claim("email", c.usuario() + "@meusite.dev")
                          .expiresIn(Duration.ofHours(1))
                          .sign();
        return Response.ok(token).build();
    }

    // Demo only. Em producao: banco + hash (BCrypt/Argon2).
    private Set<String> autentica(Credenciais c) {
        if ("david".equals(c.usuario()) && "123".equals(c.senha())) {
            return Set.of("user", "admin");
        }
        if ("maria".equals(c.usuario()) && "123".equals(c.senha())) {
            return Set.of("user");
        }
        return null;
    }
}
