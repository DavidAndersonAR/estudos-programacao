package com.exemplo;

import java.util.List;
import java.util.Optional;

import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

@ApplicationScoped
public class ProdutoService {

    private final ProdutoRepository repo;

    @Inject
    public ProdutoService(ProdutoRepository repo) {
        this.repo = repo;
    }

    @PostConstruct
    void aoIniciar() {
        // Roda na 1ª chamada de método (lazy em @ApplicationScoped).
        // Útil pra seed inicial em apps de exemplo.
        if (repo.contar() == 0) {
            repo.salvar(new Produto(null, "Caneta", 4.50));
            repo.salvar(new Produto(null, "Caderno", 18.90));
        }
    }

    public List<Produto> listarTodos() {
        return repo.listar();
    }

    public Optional<Produto> buscarPorId(Long id) {
        return repo.buscar(id);
    }

    public Produto criar(Produto novo) {
        if (novo.nome() == null || novo.nome().isBlank()) {
            throw new IllegalArgumentException("nome obrigatório");
        }
        if (novo.preco() == null || novo.preco() < 0) {
            throw new IllegalArgumentException("preço inválido");
        }
        return repo.salvar(novo);
    }

    public boolean remover(Long id) {
        return repo.remover(id);
    }
}
