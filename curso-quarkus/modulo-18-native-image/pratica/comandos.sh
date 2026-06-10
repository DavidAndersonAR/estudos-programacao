#!/usr/bin/env bash
# Comandos da pratica do Modulo 18 - Native Image
set -e

# 1) Build JVM (rapido, ~10s)
./mvnw package -DskipTests

# 2) Build nativo via container (lento, 1-3 min; nao precisa GraalVM local)
./mvnw package -Pnative -Dquarkus.native.container-build=true -DskipTests

# 3) Rodar o jar (JVM) e medir startup
echo "=== Startup JVM ==="
time java -jar target/quarkus-app/quarkus-run.jar &
JVM_PID=$!
sleep 4
kill $JVM_PID

# 4) Rodar o binario nativo e medir startup
echo "=== Startup Native ==="
time ./target/*-runner &
NAT_PID=$!
sleep 2
kill $NAT_PID

# 5) Comparar tamanhos
echo "=== Tamanhos ==="
du -h target/quarkus-app/quarkus-run.jar
du -h target/*-runner

# 6) (opcional) Empacotar em Docker
# docker build -f Dockerfile.native -t demo-native .
# docker run -i --rm -p 8080:8080 demo-native
