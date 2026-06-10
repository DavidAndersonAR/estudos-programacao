package org.acme.livraria;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// PanacheEntity ja traz um "id" Long autogerado.
// Campos publicos: Panache gera getters/setters em build-time.
@Entity
public class Autor extends PanacheEntity {

    public String nome;
    public LocalDate nascimento;

    @OneToMany(mappedBy = "autor", cascade = CascadeType.ALL)
    public List<Livro> livros = new ArrayList<>();

    // --- queries fluentes como metodos de dominio (opcional, mas fica legivel) ---

    public static Autor porNome(String nome) {
        return find("nome", nome).firstResult();
    }

    public static List<Autor> nascidosApos(LocalDate data) {
        return list("nascimento > ?1", data);
    }
}
