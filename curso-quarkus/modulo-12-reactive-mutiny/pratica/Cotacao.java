package com.exemplo.cotacao;

import java.time.Instant;

public record Cotacao(String moeda, double valor, Instant em) {}
