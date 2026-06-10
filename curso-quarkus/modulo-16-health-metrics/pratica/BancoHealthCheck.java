package com.exemplo.observabilidade;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;

import io.agroal.api.AgroalDataSource;

import java.sql.Connection;

@Readiness
@ApplicationScoped
public class BancoHealthCheck implements HealthCheck {

    @Inject
    AgroalDataSource dataSource;

    @Override
    public HealthCheckResponse call() {
        try (Connection conn = dataSource.getConnection()) {
            boolean ok = conn.isValid(2);
            return HealthCheckResponse.named("Banco")
                    .status(ok)
                    .withData("url", conn.getMetaData().getURL())
                    .build();
        } catch (Exception e) {
            return HealthCheckResponse.named("Banco")
                    .down()
                    .withData("erro", e.getMessage())
                    .build();
        }
    }
}
