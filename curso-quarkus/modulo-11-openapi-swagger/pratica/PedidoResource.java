package com.exemplo.pedidos;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.parameters.RequestBody;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

@Path("/pedidos")
@Tag(name = "Pedidos", description = "Operações para gerenciar pedidos da loja")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PedidoResource {

    private final List<Pedido> pedidos = new ArrayList<>();
    private final AtomicLong sequencia = new AtomicLong(1);

    public PedidoResource() {
        pedidos.add(new Pedido(sequencia.getAndIncrement(), "Maria Silva", new BigDecimal("199.90"), "PAGO"));
        pedidos.add(new Pedido(sequencia.getAndIncrement(), "João Souza", new BigDecimal("49.50"), "PENDENTE"));
    }

    @GET
    @Operation(
        summary = "Lista todos os pedidos",
        description = "Retorna a lista completa de pedidos cadastrados, sem paginação."
    )
    @APIResponse(
        responseCode = "200",
        description = "Lista retornada com sucesso",
        content = @Content(schema = @Schema(implementation = Pedido.class, type = org.eclipse.microprofile.openapi.annotations.enums.SchemaType.ARRAY))
    )
    public List<Pedido> listar() {
        return pedidos;
    }

    @GET
    @Path("/{id}")
    @Operation(
        summary = "Busca pedido por ID",
        description = "Retorna o pedido completo ou 404 se não existir."
    )
    @APIResponses({
        @APIResponse(responseCode = "200", description = "Pedido encontrado",
            content = @Content(schema = @Schema(implementation = Pedido.class))),
        @APIResponse(responseCode = "404", description = "Pedido não localizado"),
        @APIResponse(responseCode = "500", description = "Erro interno inesperado")
    })
    public Response buscar(
        @Parameter(description = "ID do pedido", example = "1", required = true)
        @PathParam("id") Long id) {

        Optional<Pedido> achado = pedidos.stream().filter(p -> p.id.equals(id)).findFirst();
        return achado.map(p -> Response.ok(p).build())
                     .orElse(Response.status(Response.Status.NOT_FOUND).build());
    }

    @POST
    @Operation(summary = "Cria um novo pedido", description = "Gera ID e data automaticamente.")
    @APIResponses({
        @APIResponse(responseCode = "201", description = "Pedido criado",
            content = @Content(schema = @Schema(implementation = Pedido.class))),
        @APIResponse(responseCode = "400", description = "Payload inválido")
    })
    public Response criar(
        @RequestBody(description = "Dados do pedido a ser criado", required = true,
            content = @Content(schema = @Schema(implementation = Pedido.class)))
        Pedido novo) {

        novo.id = sequencia.getAndIncrement();
        if (novo.status == null) novo.status = "PENDENTE";
        pedidos.add(novo);
        return Response.status(Response.Status.CREATED).entity(novo).build();
    }

    @DELETE
    @Path("/{id}")
    @Operation(summary = "Cancela um pedido", description = "Remove o pedido do sistema.")
    @APIResponses({
        @APIResponse(responseCode = "204", description = "Pedido removido com sucesso"),
        @APIResponse(responseCode = "404", description = "Pedido não localizado")
    })
    public Response cancelar(
        @Parameter(description = "ID do pedido a cancelar", example = "1", required = true)
        @PathParam("id") Long id) {

        boolean removido = pedidos.removeIf(p -> p.id.equals(id));
        return removido
            ? Response.noContent().build()
            : Response.status(Response.Status.NOT_FOUND).build();
    }
}
