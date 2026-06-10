package com.exemplo;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class EmailService {

    // Exemplo de @ConfigProperty solto (alternativa ao @ConfigMapping)
    @ConfigProperty(name = "app.email.assunto-padrao", defaultValue = "Sem assunto")
    String assuntoFallback;

    // E aqui injetando o mapping tipado — forma preferida
    @Inject
    AppConfig config;

    public String enviar(String destinatario, String corpo) {
        var remetente = config.email().remetente();
        var assunto = config.email().assuntoPadrao();
        var bcc = config.email().copiaOculta().orElse("(sem cópia)");

        // Aqui seria a integração real (SMTP, SES, etc).
        return String.format(
                "DE: %s | PARA: %s | BCC: %s | ASSUNTO: %s | CORPO: %s",
                remetente, destinatario, bcc, assunto, corpo);
    }
}
