package com.exemplo;

import io.quarkus.test.junit.QuarkusTestProfile;

import java.util.Map;

// Profile alternativo: desliga o seed do ProdutoService.
// Use com: @QuarkusTest @TestProfile(BancoVazioProfile.class)
public class BancoVazioProfile implements QuarkusTestProfile {

    @Override
    public Map<String, String> getConfigOverrides() {
        return Map.of("app.seed", "false");
    }
}
