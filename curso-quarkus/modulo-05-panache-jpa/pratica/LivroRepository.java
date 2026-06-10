package org.acme.livraria;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.math.BigDecimal;
import java.util.List;

// Alternativa ao active record: separa entidade de queries.
// Ja ganha findById, listAll, persist, count, delete...
@ApplicationScoped
public class LivroRepository implements PanacheRepository<Livro> {

    public List<Livro> doAutor(Long autorId) {
        return list("autor.id", autorId);
    }

    public List<Livro> maisCarosQue(BigDecimal preco, int pagina, int tamanho) {
        return find("preco > ?1", Sort.by("preco").descending(), preco)
                .page(Page.of(pagina, tamanho))
                .list();
    }

    public long aplicarReajuste(Long autorId, BigDecimal fator) {
        // UPDATE em massa — precisa estar dentro de @Transactional no chamador.
        return update("preco = preco * ?1 where autor.id = ?2", fator, autorId);
    }
}
