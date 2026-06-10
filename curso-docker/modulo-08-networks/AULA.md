# Módulo 08 — Networks

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar os principais **drivers de network** do Docker
- Diferenciar **default bridge** de **user-defined bridge** (e por que essa diferença é ESSENCIAL)
- Fazer dois containers conversarem **pelo nome** (sem IP)
- Usar `docker network create / ls / inspect / connect / disconnect / rm / prune`
- Entender quando usar `-p` (port mapping) e quando NÃO precisa

## 🌐 Por que existe Docker network?

Cada container é um **processo isolado**. Por padrão, ele NÃO enxerga a rede do host nem a dos outros containers — a não ser que você os coloque na mesma rede Docker.

Pense assim: cada network Docker é um "switch virtual". Containers plugados no mesmo switch se enxergam; containers em switches diferentes não.

```
Host (sua máquina)
 └── Docker
      ├── network: loja-net   ──► [postgres] [adminer] [nginx]   ← conversam
      └── network: outra-net  ──► [redis] [api]                  ← conversam
                                  (loja-net e outra-net NÃO se enxergam)
```

## 🧱 Drivers de network (os 5 principais)

### 1. `bridge` (default)
- **Driver padrão** quando você cria uma rede sem dizer nada.
- Cada container ganha um IP privado tipo `172.17.0.X`.
- **Isolado da rede do host** — pra acessar de fora precisa de `-p`.
- Existe uma rede `bridge` pronta de fábrica (a "**default bridge**") — mas você NÃO deveria usar ela (veja abaixo).

### 2. `host`
- Container **compartilha a stack de rede do host**, sem isolamento.
- `-p` não funciona (e nem precisa) — se o container escuta na 80, o host escuta na 80.
- Mais rápido (sem NAT), porém perigoso: zero isolamento, conflito de porta direto.
- Útil em casos pontuais (monitoramento de rede, performance crítica). No Docker Desktop (Mac/Windows) tem comportamento limitado — funciona melhor no Linux.

### 3. `none`
- Container **sem rede nenhuma**. Só tem o `loopback` (127.0.0.1).
- Usa quando o container não precisa falar com o mundo (job batch isolado, processamento local).

### 4. `overlay`
- Multi-host. Liga containers rodando em **máquinas diferentes** (clusters Docker Swarm).
- Pré-requisito de Swarm ou Kubernetes-like.
- Vamos só citar aqui — é assunto de orquestração.

### 5. `macvlan`
- Dá ao container um **MAC address próprio** na rede física do host.
- Container aparece como se fosse uma máquina de verdade na LAN (com IP da sua rede de casa/empresa).
- Casos raros: integração com sistemas legados que esperam descobrir o serviço na LAN.

## ⚠️ Default bridge vs User-defined bridge — A DIFERENÇA QUE IMPORTA

A rede `bridge` que vem de fábrica e uma rede que você cria com `docker network create` são AMBAS do driver `bridge` — mas se comportam diferente:

| Comportamento | Default `bridge` | User-defined bridge |
|---|---|---|
| **DNS interno por nome** | ❌ Não tem | ✅ TEM — containers se acham pelo nome |
| **Isolamento** | Tudo no mesmo "saco" | Cada rede é sua bolha |
| **Conexão dinâmica** | `--link` (deprecado, não use) | `docker network connect` |
| **Recomendado?** | NUNCA | SIM, sempre |

Tradução prática: na default bridge, pra um container falar com outro, você precisa do **IP**. Em user-defined, fala pelo **nome do container**. Isso muda o jogo:

```bash
# Na default bridge — feio e frágil:
docker exec app ping 172.17.0.3      # e se o IP mudar? quebra.

# Na user-defined — limpo:
docker exec app ping postgres        # Docker resolve pra IP automaticamente
```

**Regra de ouro**: sempre crie uma rede user-defined pro seu projeto. É 1 comando a mais e te dá DNS de graça.

## 🔧 Comandos essenciais

```bash
# Listar redes existentes
docker network ls

# Criar rede (driver bridge é o default)
docker network create loja-net
docker network create --driver bridge minha-net  # explícito

# Ver detalhes (qual driver, quais containers, qual subnet)
docker network inspect loja-net

# Rodar container já na rede
docker run -d --name postgres --network loja-net postgres:16

# Conectar/desconectar container existente
docker network connect loja-net meu-container
docker network disconnect loja-net meu-container

# Remover (precisa estar sem containers)
docker network rm loja-net

# Limpar TODAS as redes não usadas (cuidado)
docker network prune -f
```

Detalhe útil: um container pode estar em **VÁRIAS redes ao mesmo tempo**. Útil pra um gateway/proxy que precisa falar com frontend e backend separados.

## 📡 Comunicação container ↔ container

Cenário clássico: API quer falar com Postgres.

```bash
docker network create app-net

# Postgres NÃO precisa de -p, ninguém de fora vai falar com ele direto
docker run -d --name db --network app-net \
  -e POSTGRES_PASSWORD=secret postgres:16

# API conecta usando o NOME do container como hostname
docker run -d --name api --network app-net \
  -e DATABASE_URL=postgres://postgres:secret@db:5432/postgres \
  -p 3000:3000 minha-api
```

O que está acontecendo:
- `db` e `api` estão na mesma rede `app-net` → se enxergam.
- A API resolve `db` (o nome) pro IP interno do container Postgres via DNS interno.
- Só a API tem `-p 3000:3000` — porque só ela precisa ser acessada do host.
- O banco fica **invisível pro mundo de fora**. Mais seguro.

## 🚪 Port mapping (`-p`) vs comunicação interna

Confusão comum: "preciso de `-p` pros containers conversarem?". **NÃO.**

| Quando precisa | Quando não precisa |
|---|---|
| Acessar o container **de fora do Docker** (do navegador, do `psql` do seu PC, etc) | Container A falar com container B na mesma rede |

```
[seu navegador] ──► host:8080 ──► -p 8080:80 ──► [nginx container]
                                                       │
                                                       ▼  (mesma rede, sem -p)
                                                  [api container]
                                                       │
                                                       ▼  (mesma rede, sem -p)
                                                  [postgres container]
```

Tradução: o Postgres da imagem oficial expõe a porta `5432` internamente. Containers da mesma rede já conseguem falar nela. `-p 5432:5432` só serve pra você acessar do `psql` do host.

## 💡 Detalhes que economizam tempo
- **DNS interno só funciona em user-defined networks** — na default bridge, não rola.
- **Nomes de container = hostnames**. `--name api` vira o hostname `api` dentro da rede.
- **Aliases**: `--network-alias` dá nomes extras ao container na rede (útil pra blue-green).
- **Subnet conflitando com a rede de casa**? Docker pode pegar `192.168.0.0/16` e quebrar sua VPN. Crie com `--subnet` próprio se isso acontecer.
- **Não use `localhost` dentro do container pra falar com outro container** — `localhost` é o próprio container. Use o nome do outro.
- **`docker compose` cria uma user-defined network automaticamente** pra cada projeto (vamos ver no Módulo 09).

## 🎯 Cheat sheet

| Comando | O que faz |
|---|---|
| `docker network ls` | Lista redes |
| `docker network create NOME` | Cria rede (bridge user-defined) |
| `docker network inspect NOME` | Vê detalhes + containers conectados |
| `docker network connect NET CONT` | Conecta container existente a uma rede |
| `docker network disconnect NET CONT` | Desconecta |
| `docker network rm NOME` | Remove (rede precisa estar sem containers) |
| `docker network prune` | Remove todas as redes não usadas |
| `docker run --network NOME ...` | Roda já na rede |
| `docker run --network host ...` | Sem isolamento de rede (Linux) |
| `docker run --network none ...` | Sem rede |

## 🚦 Próximos passos
1. Faça a prática: bridge custom, postgres + alpine, ping pelo nome
2. Faça o desafio: 3 containers (postgres + adminer + nginx) em rede custom
3. Vá pro Módulo 09 — Docker Compose, onde tudo isso vira YAML declarativo

## ✅ Auto-verificação
- [ ] Sei os 5 drivers e quando usar cada um
- [ ] Sei a diferença entre default bridge e user-defined bridge
- [ ] Consigo fazer dois containers conversarem pelo nome
- [ ] Sei quando precisa de `-p` e quando não precisa
- [ ] Sei conectar/desconectar containers de uma rede em runtime

Próximo módulo: **Docker Compose** — chega de digitar 20 flags toda vez.
