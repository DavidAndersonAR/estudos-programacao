# Módulo 01 — Bem-vindo + Setup

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Subir um Postgres usando Docker em 30 segundos
- Entrar no `psql` e rodar comandos básicos
- Carregar o schema do projeto (loja e-commerce)
- Fazer seu primeiro `SELECT`

## 🐘 O que é PostgreSQL?
PostgreSQL (ou só "Postgres") é um banco de dados relacional **open source**, gratuito, maduro (vai pra 30 anos em 2026) e **extremamente poderoso**. É o queridinho da galera dev moderna porque:

- **Padrão SQL**: segue a ISO de SQL como ninguém. O que você aprende aqui vale em qualquer banco SQL.
- **Tipos avançados**: JSON, arrays, UUID, range types, geometria, dá pra tudo.
- **Confiável**: ACID, MVCC, replicação, backup. Bancos grandes confiam nele.
- **Extensível**: PostGIS pra geo, TimescaleDB pra séries temporais, pgvector pra IA, etc.

Quem usa: Instagram, Reddit, Spotify, Apple (parte da iCloud), Twitch, GitHub.

Diferença pra MySQL? Em uma linha: Postgres é mais **rigoroso** (mais features, mais tipos, mais conformidade SQL) e melhor pra consultas complexas. MySQL é mais simples e historicamente mais rápido em casos simples, mas Postgres alcançou e ultrapassou em muitos aspectos.

## 🚀 Subindo o Postgres com Docker
```bash
docker run -d --name pg-curso \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=loja \
  -p 5432:5432 \
  postgres:16
```

Quebra do que isso faz:
- `-d` = detached (roda em background)
- `--name pg-curso` = nome do container
- `-e POSTGRES_PASSWORD=postgres` = senha do usuário `postgres`
- `-e POSTGRES_DB=loja` = cria o banco `loja` automaticamente
- `-p 5432:5432` = expõe a porta do container na máquina
- `postgres:16` = imagem (Postgres versão 16)

Verifique:
```bash
docker ps
# Deve aparecer pg-curso rodando
```

## 🖥️ Entrando no psql
`psql` é o cliente oficial de linha de comando. Acessa o banco direto:

```bash
docker exec -it pg-curso psql -U postgres -d loja
```

Você vai ver:
```
loja=#
```

Esse é o prompt. Comandos importantes:

| Comando | O que faz |
|---|---|
| `\l` | lista bancos |
| `\c nome_banco` | conecta em outro banco |
| `\dt` | lista tabelas |
| `\d tabela` | descreve estrutura da tabela |
| `\du` | lista usuários (roles) |
| `\?` | ajuda dos comandos `\` |
| `\h SELECT` | ajuda de um comando SQL |
| `\q` | sai do psql |

E para SQL: tudo termina com `;`. Pode quebrar em várias linhas.

## 📋 Carregando o schema
O arquivo `pratica/schema.sql` cria as tabelas. O `pratica/seed.sql` insere dados de exemplo. Carregue ambos:

```bash
# Da pasta raiz do curso (Estudo Go):
docker cp curso-postgresql/modulo-01-bem-vindo-setup/pratica/schema.sql pg-curso:/tmp/
docker cp curso-postgresql/modulo-01-bem-vindo-setup/pratica/seed.sql pg-curso:/tmp/

docker exec -it pg-curso psql -U postgres -d loja -f /tmp/schema.sql
docker exec -it pg-curso psql -U postgres -d loja -f /tmp/seed.sql
```

## 🧱 O modelo da loja

Vamos trabalhar com 5 tabelas:

```
categorias        clientes
   │                  │
   ↓                  ↓
produtos  ──→  itens_pedido  ←──  pedidos
```

- **categorias**: id, nome
- **produtos**: id, nome, preço, estoque, categoria_id
- **clientes**: id, nome, email, cidade, data_cadastro
- **pedidos**: id, cliente_id, data, status (pendente/pago/enviado/cancelado)
- **itens_pedido**: pedido_id, produto_id, quantidade, preço_unitário

Esse schema vai te acompanhar nos 20 módulos. Vamos crescer ele com índices, constraints, particionamento, etc.

## 🎬 Seu primeiro SELECT
Dentro do psql, depois de carregar schema + seed:

```sql
SELECT * FROM categorias;
SELECT count(*) FROM produtos;
SELECT nome, preco FROM produtos LIMIT 5;
```

Você deve ver as categorias, contagem de produtos e 5 produtos.

## 💡 Dicas de quem programa Postgres há tempo
- **SQL não é case-sensitive** em comandos: `SELECT` = `select`. Mas é **convenção** escrever palavras-chave em MAIÚSCULA e nomes em minúscula.
- **String é com aspas simples**: `'texto'`. Aspas duplas é pra identificador (nome de coluna): `"colunaQueTemEspaço"`.
- **NULL não é zero, nem string vazia**. NULL = "não sei". Usar `IS NULL` / `IS NOT NULL`, nunca `= NULL`.
- **Postgres é estrito com tipos**: não vai converter int pra string sozinho como MySQL faz.
- **Toda transação implícita**: se não escrever `BEGIN`, cada comando é uma transação isolada. Vamos ver no módulo 15.

## 🚦 Próximos passos
1. Rode o setup (Docker + carregar schema/seed)
2. Abra `pratica/queries.sql` e rode cada query
3. Faça o `desafio`: explorar o banco respondendo perguntas
4. Vá pro Módulo 02 — SELECT pra valer

## ✅ Auto-verificação
- [ ] Tenho Postgres rodando no Docker
- [ ] Sei entrar e sair do psql
- [ ] Sei pelo menos 4 comandos `\` do psql
- [ ] Consegui rodar `SELECT * FROM categorias`

Próximo módulo: **SELECT básico** — filtros, ordenação, limites e seleção.
