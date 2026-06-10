package com.exemplo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

// JUnit puro — sem @QuarkusTest, sem subir framework. Rápido.
class ProdutoServiceTest {

    private ProdutoService service;

    @BeforeEach
    void setUp() {
        service = new ProdutoService();
        service.popularInicial = false; // não popula no teste unit
    }

    @Test
    void criarDeveAtribuirIdEArmazenar() {
        Produto criado = service.criar(new Produto(null, "Lápis", 2.0));

        assertNotNull(criado.id);
        assertEquals("Lápis", criado.nome);
        assertEquals(1, service.listar().size());
    }

    @Test
    void criarComPrecoNegativoDeveLancar() {
        Produto invalido = new Produto(null, "X", -1.0);
        assertThrows(IllegalArgumentException.class, () -> service.criar(invalido));
    }

    @Test
    void buscarDeveRetornarEmptyQuandoNaoExiste() {
        Optional<Produto> resultado = service.buscar(99L);
        assertTrue(resultado.isEmpty());
    }

    @Test
    void deletarDeveRetornarFalseSeNaoExiste() {
        assertFalse(service.deletar(99L));
    }
}
