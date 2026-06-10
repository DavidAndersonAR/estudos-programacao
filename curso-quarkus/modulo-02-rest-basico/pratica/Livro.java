package com.exemplo;

public class Livro {

    public Long id;
    public String titulo;
    public String autor;

    public Livro() {
    }

    public Livro(Long id, String titulo, String autor) {
        this.id = id;
        this.titulo = titulo;
        this.autor = autor;
    }
}
