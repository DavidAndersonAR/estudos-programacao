package com.exemplo.cep;

import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.rest.client.inject.RestClient;

@ApplicationScoped
public class EnderecoService {

    // Atenção: é @RestClient, NÃO @Inject.
    @RestClient
    ViaCepClient viaCep;

    public Endereco porCep(String cep) {
        String limpo = cep.replaceAll("\\D", "");
        if (limpo.length() != 8) {
            throw new IllegalArgumentException("CEP precisa ter 8 dígitos");
        }
        return viaCep.buscar(limpo);
    }
}
