package com.exemplo;

import io.smallrye.config.ConfigMapping;
import io.smallrye.config.WithDefault;

import java.util.Optional;

@ConfigMapping(prefix = "app")
public interface AppConfig {

    Email email();

    @WithDefault("100")
    int limiteRequisicoes();

    Feature feature();

    interface Email {
        String remetente();
        String assuntoPadrao();
        Optional<String> copiaOculta();
    }

    interface Feature {
        @WithDefault("false")
        boolean beta();
    }
}
