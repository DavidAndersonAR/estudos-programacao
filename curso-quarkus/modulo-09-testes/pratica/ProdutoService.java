package com.exemplo;

import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@ApplicationScoped
public class ProdutoService {

    private final Map<Long, Produto> produtos = new ConcurrentHashMap<>();
    private final AtomicLong seq = new AtomicLong(0);

    @ConfigProperty(name = "app.seed", defaultValue = "true")
    boolean popularInicial;

    @PostConstruct
    void iniciar() {
        if (popularInicial) {
            criar(new Produto(null, "Caneta", 5.0));
            criar(new Produto(null, "Caderno", 25.0));
        }
    }

    public List<Produto> listar() {
        return List.copyOf(produtos.values());
    }

    public Optional<Produto> buscar(Long id) {
        return Optional.ofNullable(produtos.get(id));
    }

    public Produto criar(Produto novo) {
        if (novo.preco == null || novo.preco < 0) {
            throw new IllegalArgumentException("preço inválido");
        }
        novo.id = seq.incrementAndGet();
        produtos.put(novo.id, novo);
        return novo;
    }

    public boolean deletar(Long id) {
        return produtos.remove(id) != null;
    }
}
