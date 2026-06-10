# Módulo 13 — Multi-stage Builds

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que builds single-stage geram imagens **gordas**
- Escrever um Dockerfile com múltiplos `FROM` (stages)
- Usar `AS nome` pra nomear stage e `COPY --from=stage` pra pegar artefato
- Compilar uma app Go e empacotá-la numa imagem de **~12MB** (scratch)
- Parar em um stage intermediário com `docker build --target`

## 🐷 O problema: imagem final carregando todo o toolchain

Imagine que você escreveu uma app em Go. O Dockerfile ingênuo seria:

```dockerfile
FROM golang:1.23
WORKDIR /app
COPY . .
RUN go build -o servidor
CMD ["./servidor"]
```

Funciona. Mas a imagem final tem **mais de 800MB**. Por quê?
Porque `golang:1.23` inclui o **compilador**, o **linker**, o **GOPATH**, **git**, headers, libs de build... tudo que você só precisa **durante o build**. Em produção, você só precisa do binário final (poucos MB).

Mesmo problema em outras stacks:
- **Node**: o `node_modules` de dev + ferramentas de build (webpack, babel, typescript) entram na imagem se você não cuidar.
- **Java**: o **JDK** (Java Development Kit, com compilador) é gigante; em produção basta o **JRE** (Java Runtime Environment).
- **Rust/C++**: idem — toolchain inteiro vai junto.

Resultado: imagens grandes = deploy lento, registry caro, superfície de ataque maior (mais binários no container = mais CVEs possíveis), startup mais lento.

## 💡 A solução: Multi-stage Builds

A ideia é simples e elegante: **um único Dockerfile pode ter vários `FROM`**. Cada `FROM` começa um novo **stage** (estágio). Você compila no stage "pesado" e **copia só o artefato final** pra um stage "leve".

```dockerfile
# --- Stage 1: build (pesado) ---
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o servidor

# --- Stage 2: runtime (leve) ---
FROM alpine:3.20
COPY --from=builder /app/servidor /servidor
CMD ["/servidor"]
```

O que cada coisa significa:
- `FROM golang:1.23-alpine AS builder` — começa um stage e dá nome `builder`.
- `FROM alpine:3.20` — começa **outro** stage, do zero. O que ficou no stage anterior **não vai pra imagem final** (a não ser que você copie explicitamente).
- `COPY --from=builder /app/servidor /servidor` — **traz o binário** do stage `builder` pra cá.
- **A imagem final é só o ÚLTIMO stage.** O resto é descartado.

## 🧱 Anatomia de um stage

Um stage = um `FROM` + as instruções abaixo dele até o próximo `FROM` (ou fim do arquivo).

```dockerfile
FROM nodeImagemGrande AS build   # stage 0 (nome: build)
RUN ...                          # roda dentro do stage 0
RUN ...

FROM nginx:alpine                # stage 1 (sem nome — pode chamar por índice: --from=1)
COPY --from=build /app/dist /usr/share/nginx/html
```

Você pode ter **quantos stages quiser**. Padrões comuns:
- 2 stages: build + runtime (o caso mais comum).
- 3 stages: deps (instala dependências) + build (compila) + runtime. Maximiza cache.
- N stages: testes em paralelo, lint, scan de segurança... (avançado).

## 🐹 Exemplo clássico: Go → scratch

`scratch` é a imagem **vazia** do Docker — literalmente 0 bytes. Funciona com Go porque Go gera **binário estático** (não depende de libc do sistema), desde que você compile com `CGO_ENABLED=0`.

```dockerfile
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o servidor

FROM scratch
COPY --from=builder /app/servidor /servidor
EXPOSE 8080
CMD ["/servidor"]
```

Resultado: imagem com **só o binário** dentro. Tamanho típico: **10–15MB**. Sem shell, sem `ls`, sem nada — só o que você colocou.

## 🟢 Exemplo clássico: Node → nginx

Pra SPA (React/Vue/Angular), o padrão é compilar com Node e servir os arquivos estáticos com nginx:

```dockerfile
# Stage 1: build
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build       # gera /app/dist

# Stage 2: runtime
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
```

Imagem final: **~25MB** (só nginx + os arquivos estáticos). Sem Node, sem `node_modules`, sem nada de build.

## ☕ Exemplo clássico: Java → JRE

```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:21-jre-alpine
COPY --from=build /app/target/app.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
```

Sai um JDK + Maven gigante (~600MB) → entra uma imagem com só JRE (~180MB).

## 🎯 `--target`: parar em um stage intermediário

Útil em dev/CI:
```bash
docker build --target builder -t minha-app:dev .
```
Constrói **só até** o stage `builder`. Casos de uso:
- Imagem de desenvolvimento (com toolchain) vs imagem de produção (slim) **no mesmo Dockerfile**.
- Rodar testes num stage intermediário.
- Debug — entrar no container do stage com toolchain pra investigar.

## 🪄 Truques úteis

**1. Copiar de uma imagem externa** (não só de stages seus):
```dockerfile
COPY --from=nginx:alpine /etc/nginx/nginx.conf /etc/nginx/nginx.conf
```
Sim, `--from=` aceita o nome de **qualquer imagem**, não só stages locais.

**2. Reaproveitar stages**:
```dockerfile
FROM golang:alpine AS base
WORKDIR /app
COPY . .

FROM base AS test
RUN go test ./...

FROM base AS build
RUN go build -o app

FROM scratch
COPY --from=build /app/app /app
```
Aqui `test` e `build` partem do mesmo `base`. Cache compartilhado.

**3. Stages com nomes descritivos** ajudam a documentar:
```dockerfile
FROM ... AS deps
FROM ... AS test
FROM ... AS build
FROM ... AS runtime
```

## 💡 Detalhes que economizam tempo
- **Ordem dos stages importa pro cache**: copie `go.mod`/`package.json` ANTES do código-fonte (Módulo 06 — camadas e cache).
- **`COPY --from=` aceita índice**: `COPY --from=0 ...` pega do stage 0, mas é frágil — prefira nomes.
- **Stage não usado não vai pra imagem final**, mas **é construído**. Pra pular, use `--target`.
- **Multi-stage não muda o tempo de build na primeira vez** — economiza no resultado final, não no build. O ganho de tempo vem do cache de camadas (Módulo 06) + BuildKit (Módulo 20).
- **Scratch não tem `/tmp`, nem certificados SSL**. Se a app faz HTTPS, copie os certs: `COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/`.
- **Alpine vs scratch**: scratch é menor mas mais difícil de debugar (sem shell). Alpine (~5MB) dá um meio-termo confortável.

## 🚦 Próximos passos
1. Faça a **prática**: compile um servidor Go e veja a imagem caindo de ~800MB pra ~12MB.
2. Faça o **desafio**: monte um Dockerfile multi-stage pra Node + nginx.
3. Vá pro **Módulo 14 — Otimização de Imagem**, onde a gente combina multi-stage com `.dockerignore`, escolha de base image e outras técnicas.

## ✅ Auto-verificação
- [ ] Explico em uma frase o que multi-stage build resolve
- [ ] Sei usar `FROM ... AS nome` e `COPY --from=nome`
- [ ] Sei que a imagem final é só o ÚLTIMO stage
- [ ] Consegui derrubar uma imagem Go pra ~12MB
- [ ] Sei pra que serve `docker build --target`

Próximo módulo: **Otimização de Imagem** — vamos espremer cada KB que sobrou.
