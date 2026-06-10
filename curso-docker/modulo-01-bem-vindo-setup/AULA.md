# Módulo 01 — Bem-vindo + Setup

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que Docker resolve
- Verificar que sua instalação está funcional
- Rodar seu primeiro container (`hello-world`)
- Diferenciar **imagem** de **container**

## 🐳 O que é Docker (e o que ele resolve)?

Docker resolve o problema **"funciona na minha máquina"**. Ele empacota sua aplicação + tudo que ela precisa pra rodar (sistema, bibliotecas, configs) num pacote chamado **imagem**. Em qualquer máquina com Docker, esse pacote roda igualzinho.

Antes do Docker:
- Deploy = configurar servidor manualmente (instalar Node, Python, libs, banco...)
- Subir nova versão = rezar pra não quebrar
- Dois apps diferentes na mesma máquina = conflito de versões

Com Docker:
- Empacota tudo na imagem
- Roda em qualquer lugar (Linux, Mac, Windows, cloud)
- Apps isolados (cada um na sua "caixinha")

Quem usa: literalmente todo mundo. Netflix, Spotify, Uber, sua startup favorita, sua empresa também provavelmente.

## 🧱 Os 3 conceitos principais

### 1. Imagem (Image)
Um **template congelado**: sistema + app + libs + tudo. É só leitura.

Pense numa imagem como uma classe em OO — molde.

### 2. Container
Uma **instância rodando** de uma imagem. É a "execução" do template.

Container = objeto. Você pode ter vários containers da mesma imagem.

### 3. Registry
**Repositório de imagens**. Docker Hub é o público mais conhecido (como GitHub mas pra imagens).

```
Dockerfile → docker build → Imagem → docker run → Container
                              ↓
                         docker push
                              ↓
                          Registry
```

## ⚙️ Verificando sua instalação

```bash
docker --version
docker info
```

Você já tem **Docker 29.4** e **Compose v5.1** rodando (eu verifiquei). Bora pro primeiro container.

## 🏃 Primeiro container: hello-world

```bash
docker run hello-world
```

O que acontece nos bastidores:
1. Docker procura a imagem `hello-world` localmente — não acha
2. Baixa do Docker Hub
3. Cria um container a partir dela
4. Executa
5. Mostra a saída
6. Container termina (mas continua existindo, parado)

Verifique:
```bash
docker ps          # containers rodando — vazio agora
docker ps -a       # todos os containers, incluindo parados
docker images      # imagens baixadas — vai aparecer hello-world
```

## 🎯 Comandos básicos cheat sheet

| Comando | O que faz |
|---|---|
| `docker run IMAGEM` | Roda um container novo a partir de uma imagem |
| `docker ps` | Lista containers RODANDO |
| `docker ps -a` | Lista TODOS os containers |
| `docker images` | Lista imagens locais |
| `docker pull IMAGEM` | Baixa uma imagem do registry |
| `docker rm CONTAINER` | Remove container (precisa estar parado) |
| `docker rmi IMAGEM` | Remove imagem |
| `docker stop CONTAINER` | Para um container que está rodando |
| `docker start CONTAINER` | Inicia um container parado |
| `docker logs CONTAINER` | Mostra os logs |

Use os primeiros caracteres do ID — Docker autocompletа: `docker stop ab3` para de um container que começa com `ab3`.

## 💡 Detalhes que economizam tempo
- **Sempre tem uma tag**: `nginx` na verdade é `nginx:latest`. Em produção, NUNCA use `latest` — escolha versão fixa (`nginx:1.27`).
- **Container == processo isolado**: quando o processo principal termina, o container para.
- **Stateless por padrão**: tudo que você grava DENTRO do container some quando ele é removido (a não ser que use volumes — Módulo 07).
- **Layers**: imagens são feitas de camadas empilhadas. Camadas que não mudam são reaproveitadas no cache (Módulo 06).
- **Não confundir Docker (engine) com Docker Desktop**: Docker Desktop é o app GUI pra Mac/Windows; por baixo roda o Docker Engine.

## 🚦 Próximos passos
1. Rode `docker run hello-world` no seu terminal
2. Veja `docker images` e `docker ps -a`
3. Faça o desafio: rodar 3 imagens diferentes
4. Vá pro Módulo 02 — onde a gente começa a *brincar* com containers

## ✅ Auto-verificação
- [ ] Sei a diferença entre imagem e container em uma frase
- [ ] Sei o que é um registry
- [ ] Consegui rodar `hello-world`
- [ ] Sei pelo menos 5 comandos da cheat sheet

Próximo módulo: **Primeiro Container** — pra valer dessa vez.
