package com.exemplo.usuarios;

import java.time.LocalDate;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Null;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class UsuarioDTO {

    // Null na criação, obrigatório na atualização (grupos)
    @Null(groups = Grupos.Criar.class)
    @NotNull(groups = Grupos.Atualizar.class)
    public Long id;

    @NotBlank
    @Size(min = 3, max = 60)
    public String nome;

    @NotBlank
    @Email
    public String email;

    @NotNull
    @Min(18)
    @Max(120)
    public Integer idade;

    @NotBlank
    @CPF
    public String cpf;

    @NotBlank
    @Pattern(regexp = "\\(\\d{2}\\) \\d{4,5}-\\d{4}",
             message = "telefone deve estar no formato (11) 91234-5678")
    public String telefone;

    @Past
    public LocalDate nascimento;
}
