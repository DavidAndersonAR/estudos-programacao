package com.exemplo.nativeimg;

import io.quarkus.runtime.annotations.RegisterForReflection;

// Classe lida via reflection (ex.: deserialização de JSON externo).
// Sem @RegisterForReflection o GraalVM removeria os campos no build.
@RegisterForReflection
public class ConfiguracaoExterna {

    public String chave;
    public String valor;
    public boolean ativo;

    public ConfiguracaoExterna() {
    }

    public ConfiguracaoExterna(String chave, String valor, boolean ativo) {
        this.chave = chave;
        this.valor = valor;
        this.ativo = ativo;
    }

    @Override
    public String toString() {
        return "ConfiguracaoExterna{chave='" + chave + "', valor='" + valor + "', ativo=" + ativo + "}";
    }
}
