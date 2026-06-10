package com.exemplo;

import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import org.jboss.resteasy.reactive.RestPath;
import org.jboss.resteasy.reactive.RestQuery;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Path("/livros")
public class LivroResource {

    private final Map<Long, Livro> livros = new ConcurrentHashMap<>();
    private final AtomicLong sequencia = new AtomicLong(0);

    public LivroResource() {
        criarInterno(new Livro(null, "O Hobbit", "Tolkien"));
        criarInterno(new Livro(null, "O Senhor dos Anéis", "Tolkien"));
        criarInterno(new Livro(null, "Fundação", "Asimov"));
    }

    @GET
    public List<Livro> listar(@RestQuery String autor) {
        if (autor == null || autor.isBlank()) {
            return List.copyOf(livros.values());
        }
        return livros.values().stream()
                .filter(l -> autor.equalsIgnoreCase(l.autor))
                .collect(Collectors.toList());
    }

    @GET
    @Path("/{id}")
    public Response buscar(@RestPath Long id) {
        Livro encontrado = livros.get(id);
        if (encontrado == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(encontrado).build();
    }

    @POST
    public Response criar(Livro novo) {
        Livro salvo = criarInterno(novo);
        return Response.status(Response.Status.CREATED)
                .entity(salvo)
                .header("Location", "/livros/" + salvo.id)
                .build();
    }

    @PUT
    @Path("/{id}")
    public Response atualizar(@RestPath Long id, Livro dados) {
        if (!livros.containsKey(id)) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        dados.id = id;
        livros.put(id, dados);
        return Response.ok(dados).build();
    }

    @DELETE
    @Path("/{id}")
    public Response remover(@RestPath Long id) {
        Livro removido = livros.remove(id);
        if (removido == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.noContent().build();
    }

    private Livro criarInterno(Livro l) {
        l.id = sequencia.incrementAndGet();
        livros.put(l.id, l);
        return l;
    }
}
