package com.exemplo.saudacao;

import io.quarkus.grpc.GrpcService;
import io.smallrye.mutiny.Multi;
import io.smallrye.mutiny.Uni;

import java.time.Duration;

// 'Saudacao' eh a interface Mutiny gerada a partir do .proto
// (fica em target/generated-sources/grpc/ depois do build)
@GrpcService
public class SaudacaoGrpcService implements Saudacao {

    @Override
    public Uni<OlaReply> dizerOla(OlaRequest req) {
        String msg = "Olá, " + req.getNome() + "!";
        return Uni.createFrom().item(
                OlaReply.newBuilder().setMensagem(msg).build()
        );
    }

    @Override
    public Multi<OlaReply> dizerOlaStream(OlaRequest req) {
        return Multi.createFrom().items("Olá", "Tudo bem", "Bem-vindo", "Tchau")
                .onItem().call(i -> Uni.createFrom().nullItem().onItem().delayIt().by(Duration.ofMillis(300)))
                .map(prefixo -> OlaReply.newBuilder()
                        .setMensagem(prefixo + ", " + req.getNome())
                        .build());
    }
}
