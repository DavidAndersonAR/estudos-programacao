package com.exemplo.usuarios;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

import org.jboss.resteasy.reactive.RestPath;
import org.jboss.resteasy.reactive.RestQuery;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.groups.ConvertGroup;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import java.util.Set;

@Path("/usuarios")
@ApplicationScoped
public class UsuarioResource {

    private final List<UsuarioDTO> banco = new ArrayList<>();
    private final AtomicLong seq = new AtomicLong();

    // Validator pra uso programático
    @jakarta.inject.Inject
    Validator validator;

    @GET
    public List<UsuarioDTO> listar(
            @RestQuery @NotNull @Min(1) Integer pagina) {
        return banco;
    }

    @POST
    public Response criar(@Valid @ConvertGroup(to = Grupos.Criar.class) UsuarioDTO dto) {
        dto.id = seq.incrementAndGet();
        banco.add(dto);
        return Response.status(201).entity(dto).build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@RestPath Long id,
                              @Valid @ConvertGroup(to = Grupos.Atualizar.class) UsuarioDTO dto) {
        dto.id = id;
        return Response.ok(dto).build();
    }

    // Exemplo de validação programática (sem @Valid no parâmetro)
    @POST
    @Path("/manual")
    public Response criarManual(UsuarioDTO dto) {
        Set<ConstraintViolation<UsuarioDTO>> erros =
                validator.validate(dto, Grupos.Criar.class);
        if (!erros.isEmpty()) {
            throw new ConstraintViolationException(erros);
        }
        dto.id = seq.incrementAndGet();
        banco.add(dto);
        return Response.status(201).entity(dto).build();
    }
}
