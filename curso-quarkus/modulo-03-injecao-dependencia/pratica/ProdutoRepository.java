package com.exemplo;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

import jakarta.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class ProdutoRepository {

    // ConcurrentHashMap porque CDI Application beans são compartilhados entre threads
    // (cada request HTTP é atendida numa thread do pool).
    private final Map<Long, Produto> dados = new ConcurrentHashMap<>();
    private final AtomicLong seq = new AtomicLong(0);

    public List<Produto> listar() {
        return List.copyOf(dados.values());
    }

    public Optional<Produto> buscar(Long id) {
        return Optional.ofNullable(dados.get(id));
    }

    public Produto salvar(Produto p) {
        Long id = p.id() != null ? p.id() : seq.incrementAndGet();
        Produto persistido = new Produto(id, p.nome(), p.preco());
        dados.put(id, persistido);
        return persistido;
    }

    public boolean remover(Long id) {
        return dados.remove(id) != null;
    }

    public long contar() {
        return dados.size();
    }
}
