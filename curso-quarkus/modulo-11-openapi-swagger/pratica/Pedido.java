package com.exemplo.pedidos;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(description = "Pedido feito por um cliente na loja")
public class Pedido {

    @Schema(description = "Identificador único do pedido", example = "42", readOnly = true)
    public Long id;

    @Schema(description = "Nome do cliente", example = "Maria Silva", required = true)
    public String cliente;

    @Schema(description = "Valor total em reais", example = "199.90", required = true, minimum = "0.01")
    public BigDecimal valor;

    @Schema(description = "Status atual", example = "PENDENTE",
            enumeration = {"PENDENTE", "PAGO", "ENVIADO", "ENTREGUE", "CANCELADO"})
    public String status;

    @Schema(description = "Data de criação do pedido", example = "2026-06-10T14:30:00", readOnly = true)
    public LocalDateTime criadoEm;

    public Pedido() {}

    public Pedido(Long id, String cliente, BigDecimal valor, String status) {
        this.id = id;
        this.cliente = cliente;
        this.valor = valor;
        this.status = status;
        this.criadoEm = LocalDateTime.now();
    }
}
