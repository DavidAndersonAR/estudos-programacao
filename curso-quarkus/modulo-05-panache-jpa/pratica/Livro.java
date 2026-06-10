package org.acme.livraria;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import java.math.BigDecimal;

@Entity
public class Livro extends PanacheEntity {

    public String titulo;
    public Integer ano;
    public BigDecimal preco;

    // ManyToOne: este lado é o "dono" da relação (tem a FK autor_id).
    @ManyToOne
    public Autor autor;
}
