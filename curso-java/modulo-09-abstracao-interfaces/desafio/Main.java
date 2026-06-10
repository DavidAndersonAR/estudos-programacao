// 🎯 DESAFIO DO MÓDULO 09 — Notificações Multi-canal (com abstração reforçada)
//
// Cenário:
// Você está construindo o sistema de avisos de um app. Cada usuário pode
// receber a mesma mensagem por VÁRIOS canais: e-mail, SMS, push. O sistema
// precisa funcionar com QUALQUER canal — inclusive canais novos que aparecerem
// no futuro (WhatsApp, Telegram, Slack...).
//
// Neste desafio você vai exercitar AS DUAS ferramentas de abstração:
//   - CLASSE ABSTRATA `Notificador`: tem estado/comportamento compartilhado
//     (todos sabem registrar log com timestamp).
//   - INTERFACES `Persistivel` e `ConfiguravelComRetry`: capacidades OPCIONAIS
//     que só alguns canais têm.
//
// 📋 Tarefas:
//
// 1. Crie uma CLASSE ABSTRATA `Notificador`:
//      - método ABSTRATO  void enviar(String msg)
//      - método CONCRETO  void log(String msg)  → imprime "[LOG <timestamp>] <msg>"
//        (use System.currentTimeMillis() ou java.time.LocalDateTime.now())
//
// 2. Crie a INTERFACE `Persistivel`:
//      - void salvarHistorico(String msg)  (cada implementação guarda do seu jeito)
//
// 3. Crie a INTERFACE `ConfiguravelComRetry`:
//      - int  getMaxTentativas()
//      - default void enviarComRetry(String msg)  → tenta enviar até maxTentativas
//                                                    (pra usar isso, a classe vai
//                                                    precisar SER um Notificador
//                                                    também — combine as duas)
//
// 4. Implemente três canais concretos:
//      - EmailNotificador       (extends Notificador, implements Persistivel)
//      - SmsNotificador         (extends Notificador, implements ConfiguravelComRetry)
//      - PushNotificador        (extends Notificador)
//
// 5. Faça um método estático:
//        static void notificarTodos(List<Notificador> canais, String msg)
//    que percorre a lista e chama enviar(msg) em cada um, e DEPOIS chama log(msg).
//
// 6. No main: monte uma lista com os três canais, dispare uma mensagem só, e
//    demonstre o uso das interfaces (instanceof) em pelo menos um caso.
//
// 💡 Dicas:
//   - import java.util.List;  java.util.ArrayList;  java.time.LocalDateTime;
//   - List.of(a, b, c) cria uma lista pronta (imutável) em Java moderno.
//   - Use `instanceof Persistivel p` (pattern matching, Java 16+) ou cast clássico.

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Main {

    // ============================
    // SUA SOLUÇÃO ABAIXO
    // ============================

    // TODO: classe abstrata Notificador (com enviar abstrato e log concreto)
    // TODO: interface Persistivel
    // TODO: interface ConfiguravelComRetry (com default enviarComRetry)
    // TODO: EmailNotificador, SmsNotificador, PushNotificador
    // TODO: notificarTodos(...)

    public static void main(String[] args) {
        // TODO: monte a lista, dispare uma mensagem, demonstre instanceof.
        System.out.println("(implemente seu sistema de notificações aqui)");
    }


    // ============================
    // SOLUÇÃO DE REFERÊNCIA (descomente para conferir)
    // ============================

    /*
    // CLASSE ABSTRATA — tem ESTADO e COMPORTAMENTO compartilhado.
    // Todo canal sabe registrar log; só o "como enviar" muda por subclasse.
    static abstract class Notificador {
        // Método ABSTRATO — toda subclasse é OBRIGADA a implementar.
        public abstract void enviar(String msg);

        // Método CONCRETO — código compartilhado pra todas as filhas.
        // É a vantagem de classe abstrata sobre interface (até Java 8).
        public void log(String msg) {
            System.out.println("[LOG " + LocalDateTime.now() + "] " + msg);
        }
    }

    // INTERFACE — capacidade OPCIONAL.
    // Nem todo canal precisa persistir histórico; só os que implementarem.
    interface Persistivel {
        void salvarHistorico(String msg);
    }

    // INTERFACE com DEFAULT method.
    // Quem assina ganha enviarComRetry de graça — mas precisa também
    // estender Notificador pra ter o método enviar(...) que será chamado.
    interface ConfiguravelComRetry {
        int getMaxTentativas();

        default void enviarComRetry(String msg) {
            // Esse default só faz sentido se quem implementa também for Notificador.
            // É um padrão comum: "interface mixin" que assume outra capacidade.
            if (!(this instanceof Notificador n)) {
                throw new IllegalStateException("ConfiguravelComRetry exige ser também Notificador");
            }
            int max = getMaxTentativas();
            for (int tentativa = 1; tentativa <= max; tentativa++) {
                System.out.println("(tentativa " + tentativa + "/" + max + ")");
                n.enviar(msg);
            }
        }
    }

    // Canal 1: E-mail — é Notificador E Persistivel (guarda histórico).
    static class EmailNotificador extends Notificador implements Persistivel {
        private String email;
        private List<String> historico = new ArrayList<>();

        public EmailNotificador(String email) { this.email = email; }

        @Override
        public void enviar(String msg) {
            System.out.println("[EMAIL] para " + email + " -> " + msg);
        }

        @Override
        public void salvarHistorico(String msg) {
            historico.add(msg);
            System.out.println("  (histórico de " + email + " agora tem " + historico.size() + " mensagens)");
        }
    }

    // Canal 2: SMS — é Notificador E ConfiguravelComRetry (tenta de novo se falhar).
    static class SmsNotificador extends Notificador implements ConfiguravelComRetry {
        private String telefone;

        public SmsNotificador(String telefone) { this.telefone = telefone; }

        @Override
        public void enviar(String msg) {
            System.out.println("[SMS] para " + telefone + " -> " + msg);
        }

        @Override
        public int getMaxTentativas() { return 3; }
    }

    // Canal 3: Push — só Notificador, sem capacidades extras.
    static class PushNotificador extends Notificador {
        private String deviceId;

        public PushNotificador(String deviceId) { this.deviceId = deviceId; }

        @Override
        public void enviar(String msg) {
            System.out.println("[PUSH] device " + deviceId + " -> " + msg);
        }
    }

    // O coração do sistema: dispara em todos os canais sem saber quem são.
    // Trabalha em cima da ABSTRAÇÃO (Notificador), não das implementações.
    static void notificarTodos(List<Notificador> canais, String msg) {
        for (Notificador n : canais) {
            n.enviar(msg);
            n.log(msg);    // todo Notificador herda log() da classe abstrata
        }
    }

    public static void main(String[] args) {
        EmailNotificador email = new EmailNotificador("david@email.com");
        SmsNotificador   sms   = new SmsNotificador("+5511999990000");
        PushNotificador  push  = new PushNotificador("device-ABC-123");

        List<Notificador> canais = List.of(email, sms, push);

        System.out.println("--- Aviso normal (enviar + log pra todos) ---");
        notificarTodos(canais, "Sua entrega chegou!");

        System.out.println("\n--- Persistivel: só quem implementa salva histórico ---");
        for (Notificador n : canais) {
            if (n instanceof Persistivel p) {       // pattern matching (Java 16+)
                p.salvarHistorico("Sua entrega chegou!");
            }
        }

        System.out.println("\n--- ConfiguravelComRetry: SMS tenta 3 vezes ---");
        if (sms instanceof ConfiguravelComRetry cr) {
            cr.enviarComRetry("Código de verificação: 4242");
        }

        // Vantagem da combinação abstract + interfaces:
        // - O CÓDIGO COMUM (log com timestamp) fica na classe abstrata, sem duplicação.
        // - As CAPACIDADES OPCIONAIS (Persistivel, ConfiguravelComRetry) ficam em
        //   interfaces — cada canal pluga o que precisar.
        // - Amanhã aparece WhatsAppNotificador: extends Notificador, pluga as
        //   interfaces que fizerem sentido. notificarTodos NÃO MUDA UMA LINHA.
    }
    */
}
