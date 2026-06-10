package com.exemplo;

// Record — DTO imutável em 1 linha. Funciona como entidade em memória aqui.
public record Produto(Long id, String nome, Double preco) {
}
