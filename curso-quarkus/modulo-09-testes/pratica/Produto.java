package com.exemplo;

public class Produto {
    public Long id;
    public String nome;
    public Double preco;

    public Produto() {}

    public Produto(Long id, String nome, Double preco) {
        this.id = id;
        this.nome = nome;
        this.preco = preco;
    }
}
