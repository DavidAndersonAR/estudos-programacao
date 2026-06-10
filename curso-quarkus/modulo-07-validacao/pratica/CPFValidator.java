package com.exemplo.usuarios;

import java.util.regex.Pattern;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class CPFValidator implements ConstraintValidator<CPF, String> {

    private static final Pattern FORMATO = Pattern.compile("\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}");

    @Override
    public boolean isValid(String valor, ConstraintValidatorContext ctx) {
        // null fica a cargo de @NotNull/@NotBlank
        if (valor == null) return true;
        return FORMATO.matcher(valor).matches();
    }
}
