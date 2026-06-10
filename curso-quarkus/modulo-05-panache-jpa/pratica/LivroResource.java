package org.acme.livraria;

import io.quarkus.panache.common.Page;
import io.quarkus.panache.common.Sort;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.Response;
import org.jboss.resteasy.reactive.RestPath;
import org.jboss.resteasy.reactive.RestQuery;
import java.math.BigDecimal;
import java.net.URI;
import java.util.List;

@Path("/livros")
public class LivroResource {

    @Inject
    LivroRepository repo;

    // GET /livros?pagina=0&tamanho=10&autor=1
    @GET
    public List<Livro> listar(@RestQuery @DefaultValue("0") int pagina,
                              @RestQuery @DefaultValue("20") int tamanho,
                              @RestQuery Long autor) {
        if (autor != null) {
            return repo.doAutor(autor);
        }
        return Livro.findAll(Sort.by("titulo"))
                .page(Page.of(pagina, tamanho))
                .list();
    }

    @GET
    @Path("/{id}")
    public Livro buscar(@RestPath Long id) {
        Livro l = Livro.findById(id);
        if (l == null) throw new NotFoundException();
        return l;
    }

    // count e demonstra query simples
    @GET
    @Path("/contagem")
    public long contar(@RestQuery String titulo) {
        if (titulo == null) return Livro.count();
        return Livro.count("titulo like ?1", titulo + "%");
    }

    @POST
    @Transactional
    public Response criar(Livro novo) {
        // Resolve autor pelo id (se veio so o id no payload).
        if (novo.autor != null && novo.autor.id != null) {
            novo.autor = Autor.findById(novo.autor.id);
        }
        novo.persist();
        return Response.created(URI.create("/livros/" + novo.id)).entity(novo).build();
    }

    @PUT
    @Path("/{id}")
    @Transactional
    public Livro atualizar(@RestPath Long id, Livro dados) {
        Livro existente = Livro.findById(id);
        if (existente == null) throw new NotFoundException();
        existente.titulo = dados.titulo;
        existente.ano = dados.ano;
        existente.preco = dados.preco;
        return existente; // dirty checking: o Hibernate dispara o UPDATE no commit.
    }

    @DELETE
    @Path("/{id}")
    @Transactional
    public Response remover(@RestPath Long id) {
        boolean apagou = Livro.deleteById(id);
        return apagou ? Response.noContent().build() : Response.status(404).build();
    }

    // Update em massa: aumenta preco dos livros de um autor.
    @POST
    @Path("/reajuste")
    @Transactional
    public long reajustar(@RestQuery Long autor, @RestQuery BigDecimal fator) {
        return repo.aplicarReajuste(autor, fator);
    }
}
