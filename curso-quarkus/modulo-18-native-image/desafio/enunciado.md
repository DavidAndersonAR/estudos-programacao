# Desafio — Módulo 18: Native Image

## Objetivo

Pegar uma API REST simples (pode ser um CRUD de qualquer módulo anterior), gerar a imagem nativa, empacotar em Docker e comparar com a versão JVM.

## Tarefas

1. **Preparar o projeto**
   - Use um projeto Quarkus existente com pelo menos 1 endpoint REST (`GET /produtos`, por exemplo).
   - Garanta que todos os DTOs usados em serialização JSON estão anotados ou descobertos automaticamente.

2. **Adicionar `@RegisterForReflection`**
   - Crie uma classe `Configuracao` que será lida via reflection (ex.: por um leitor de JSON externo).
   - Anote-a com `@RegisterForReflection`.

3. **Build nativo via container**
   - Rode: `./mvnw package -Pnative -Dquarkus.native.container-build=true -DskipTests`
   - Confirme que `target/*-runner` foi gerado.

4. **Medir startup**
   - Meça o tempo de startup do jar JVM e do binário nativo com `time`.
   - Anote os dois valores.

5. **Empacotar em Docker**
   - Escreva um `Dockerfile.native` multi-stage (builder + ubi-minimal).
   - Construa: `docker build -f Dockerfile.native -t meu-app-native .`
   - Rode: `docker run --rm -p 8080:8080 meu-app-native`
   - Teste com `curl http://localhost:8080/produtos`.

6. **Comparar**
   - Tamanho do jar vs binário nativo vs imagem Docker.
   - Tempo de startup.
   - RAM usada (`docker stats`).

## Critérios de aceitação

- [ ] Binário `target/*-runner` gerado com sucesso.
- [ ] `@RegisterForReflection` em pelo menos uma classe.
- [ ] Container Docker subindo e respondendo no `curl`.
- [ ] Tabela comparativa JVM x Native preenchida (startup, RAM, tamanho).

## Dica

Se o build falhar com `ClassNotFoundException` em runtime, adicione a classe ao `@RegisterForReflection` ou aos hints de recurso no `application.properties`.
