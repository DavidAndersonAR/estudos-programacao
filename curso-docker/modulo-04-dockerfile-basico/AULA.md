# Módulo 04 — Dockerfile Básico

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é um **Dockerfile** e por que existe
- Conhecer as instruções essenciais: **FROM**, **WORKDIR**, **COPY**, **RUN**, **CMD**, **ENTRYPOINT**, **EXPOSE**, **LABEL**
- Saber a diferença entre **COPY** e **ADD** (e por que preferir COPY)
- Entender quando usar **CMD** vs **ENTRYPOINT**
- Construir sua primeira imagem custom (Node.js servindo HTTP)

## 📜 O que é um Dockerfile?

Dockerfile é uma **receita de bolo** — um arquivo de texto com a sequência de passos pra construir uma imagem Docker. Cada linha é uma instrução, e o Docker executa de cima pra baixo gerando uma camada (layer) por instrução.

```
Dockerfile (receita) → docker build → Imagem (template) → docker run → Container (instância)
```

Até agora a gente **usou** imagens prontas (Módulos 01-03). Aqui é onde você começa a **criar as suas**.

Regras básicas:
- Nome do arquivo é literalmente `Dockerfile` (sem extensão, D maiúsculo)
- Fica na raiz do contexto de build (geralmente a pasta do projeto)
- Comentários começam com `#`
- Instruções por convenção em **MAIÚSCULAS** (não é obrigatório, mas é padrão)

## 🧱 Instruções essenciais

### `FROM` — a imagem base

**Toda imagem parte de outra.** A primeira instrução (quase sempre) é o `FROM`.

```dockerfile
FROM node:lts-alpine
```

- `node` é a imagem oficial do Node.js no Docker Hub
- `lts-alpine` é a tag (versão LTS rodando em cima do Alpine — distro Linux minimalista, ~5MB)

Pode usar `FROM scratch` pra começar do **nada absoluto** (imagem vazia), mas isso é caso avançado.

💡 **Sempre pin a versão.** Evite `FROM node` (que vira `node:latest`) em produção — quebra do nada quando o `latest` mudar.

### `WORKDIR` — diretório de trabalho

Define o diretório dentro do container onde os próximos comandos vão rodar. Se não existir, ele cria.

```dockerfile
WORKDIR /app
```

A partir daqui, qualquer `COPY`, `RUN`, `CMD` roda como se você estivesse em `/app`. É o `cd` do Dockerfile — só que persistente.

❌ Evite: `RUN cd /app && ...` — não funciona como você espera (cada RUN é uma shell nova).
✅ Use: `WORKDIR /app` antes.

### `COPY` — copia arquivos do host pro container

```dockerfile
COPY app.js .
COPY package.json package-lock.json ./
COPY src/ ./src/
```

- Primeiro argumento(s): caminho(s) **no host** (relativo ao contexto de build)
- Último argumento: caminho **dentro da imagem** (relativo ao WORKDIR)
- O `.` significa "pasta atual do WORKDIR"

### `COPY` vs `ADD` — prefira COPY

`ADD` faz tudo que `COPY` faz, **mais** duas coisas:
1. Baixa URL: `ADD https://exemplo.com/arquivo.tar.gz /tmp/`
2. Extrai tar automaticamente: `ADD codigo.tar.gz /app/`

Parece útil — mas é **fonte de bugs**:
- Comportamento "mágico" implícito (extrair tar) pode te pegar desprevenido
- Download via ADD não tem cache inteligente nem checksum

**Regra**: use `COPY` sempre. Pra baixar URL, use `RUN curl ...` ou `RUN wget ...` (fica explícito).

### `RUN` — executa comando **no build**

Roda comandos durante a construção da imagem. O resultado vira parte da imagem.

```dockerfile
RUN npm install
RUN apt-get update && apt-get install -y curl
```

Cada `RUN` vira uma **camada**. Por isso a gente encadeia comandos relacionados com `&&` (Módulo 06 vai aprofundar).

### `CMD` — comando default quando o container roda

Define o comando padrão executado quando o container inicia.

```dockerfile
CMD ["node", "app.js"]
```

- **Forma exec** (JSON array): `CMD ["executavel", "arg1", "arg2"]` ← **preferida**
- **Forma shell**: `CMD node app.js` (roda dentro de `/bin/sh -c` — pega sinais errado)

Pode ser **sobrescrito** na linha de comando:
```bash
docker run minha-imagem echo "outro comando"  # ignora o CMD do Dockerfile
```

Só pode ter **um** `CMD` por Dockerfile (se tiver vários, só o último vale).

### `ENTRYPOINT` — comando **sempre** executado

Parecido com `CMD`, mas **não pode ser sobrescrito** facilmente. Argumentos passados no `docker run` viram args do ENTRYPOINT.

```dockerfile
ENTRYPOINT ["python", "app.py"]
```

A combinação clássica: **ENTRYPOINT + CMD**:
```dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--port=8080"]
```

Aí `docker run minha-imagem` roda `python app.py --port=8080`, e `docker run minha-imagem --port=9000` roda `python app.py --port=9000`. CMD vira o **default de argumentos**.

**Quando usar qual?**
- `CMD` → quando o usuário pode trocar livremente o comando (apps genéricos, dev containers)
- `ENTRYPOINT` → quando o container **é** um executável específico (CLIs, daemons fixos)

### `EXPOSE` — documenta a porta

```dockerfile
EXPOSE 3000
```

⚠️ **Não abre porta nenhuma.** Só **documenta** que a aplicação dentro escuta nessa porta. Pra publicar de verdade, você usa `-p` no `docker run` (Módulo 02).

Vale como dica pra quem usa sua imagem e pra ferramentas (Docker Compose lê esse valor).

### `LABEL` — metadata

Adiciona metadados key=value à imagem. Útil pra organização, automação, scanners.

```dockerfile
LABEL maintainer="david@exemplo.com"
LABEL version="1.0"
LABEL description="Servidor HTTP de teste em Node"
```

Você consulta com `docker inspect imagem`. Em times grandes vira padrão.

### Comentários

```dockerfile
# Isso é um comentário
FROM node:lts-alpine  # comentário inline também rola
```

## 🍳 Receita completa (preview da prática)

```dockerfile
# Imagem base oficial do Node, versão LTS no Alpine (leve)
FROM node:lts-alpine

# Diretório de trabalho dentro do container
WORKDIR /app

# Copia o código fonte
COPY app.js .

# Documenta a porta que o app escuta
EXPOSE 3000

# Comando default ao rodar o container
CMD ["node", "app.js"]
```

Build e run:
```bash
docker build -t meu-app .
docker run -p 3000:3000 --rm meu-app
```

O `.` no final do `build` é o **contexto** — a pasta que o Docker manda pro daemon. Tudo que vai ser COPY tem que estar dentro dela.

## 🎯 Cheat sheet — instruções

| Instrução | Pra que serve | Exemplo |
|---|---|---|
| `FROM` | Imagem base | `FROM node:lts-alpine` |
| `WORKDIR` | Diretório dentro do container | `WORKDIR /app` |
| `COPY` | Copia arquivos do host | `COPY app.js .` |
| `ADD` | Igual COPY + URL/tar (evite) | `ADD x.tar.gz /` |
| `RUN` | Executa no **build** | `RUN npm install` |
| `CMD` | Default na **execução** (sobrescrevível) | `CMD ["node", "app.js"]` |
| `ENTRYPOINT` | **Sempre** executa | `ENTRYPOINT ["python"]` |
| `EXPOSE` | Documenta porta (não abre!) | `EXPOSE 3000` |
| `LABEL` | Metadata key=value | `LABEL version="1.0"` |
| `ENV` | Variável de ambiente (Módulo 09) | `ENV NODE_ENV=production` |

## 💡 Detalhes que economizam tempo
- **Cada instrução = uma camada.** Quanto mais camadas, maior a imagem. Encadeie `RUN` relacionados com `&&` (Módulo 06).
- **Ordem importa pro cache.** Coisas que mudam pouco (deps) vêm primeiro; coisas que mudam toda hora (código) vêm depois. Vamos detalhar isso no Módulo 06.
- **Use `.dockerignore`** (irmão do `.gitignore`) pra não mandar `node_modules`, `.git`, logs etc. pro contexto de build. Acelera **muito**.
- **Forma exec (JSON array) > forma shell** em `CMD`/`ENTRYPOINT`. A forma shell envolve um `/bin/sh -c` que come sinais (Ctrl+C não para direito).
- **Não rode como root em produção.** Adicione `USER node` (ou similar) — vamos ver no Módulo 15 (segurança).
- **`COPY . .` é tentador mas perigoso** — copia *tudo*. Sem `.dockerignore`, vai junto `node_modules`, `.env`, segredos. Cuidado.

## 🚦 Próximos passos
1. Estude a prática e rode o build do servidor Node
2. Acesse `http://localhost:3000` e confirme a resposta
3. Encare o desafio: criar uma imagem **Python + Flask** do zero
4. Vá pro Módulo 05 — **build, tag e push** (publicar sua imagem)

## ✅ Auto-verificação
- [ ] Sei o que faz `FROM`, `WORKDIR`, `COPY`, `RUN`, `CMD`, `ENTRYPOINT`, `EXPOSE`, `LABEL`
- [ ] Sei a diferença entre `CMD` e `ENTRYPOINT`
- [ ] Sei por que prefiro `COPY` em vez de `ADD`
- [ ] Sei que `EXPOSE` **não** publica porta (precisa do `-p`)
- [ ] Construí e rodei minha primeira imagem custom

Próximo módulo: **Build, Tag e Push** — sua imagem no Docker Hub.
