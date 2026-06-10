# Módulo 20 — Administração: Backup, Roles, Replicação

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Fazer backup lógico com `pg_dump` (4 formatos) e `pg_dumpall`
- Restaurar com `psql` ou `pg_restore`
- Entender backup físico (`pg_basebackup`), WAL e PITR
- Criar roles, grupos e GRANT/REVOKE de privilégios
- Saber o que é streaming replication e logical replication
- Monitorar o banco com `pg_stat_*` e ferramentas externas

## 🧭 Por que esse módulo é o mais importante de produção
Você pode saber escrever a query mais bonita do mundo: se o banco cair sem backup, sua empresa fecha. Esse módulo é o "boring stuff" que separa quem sabe SQL de quem sabe **rodar Postgres em produção**.

Três pilares de DBA:
1. **Backup**: dá pra restaurar o estado em caso de pane.
2. **Acesso (roles)**: cada serviço/pessoa só vê o que pode ver.
3. **Disponibilidade (replicação)**: se o primário cai, tem outro.

## 💾 Backup lógico — `pg_dump`
`pg_dump` exporta um **banco** (não o cluster inteiro) em formato que dá pra restaurar. Tem 4 formatos:

| Formato | Flag | Como restaurar | Quando usar |
|---|---|---|---|
| Plain SQL | `-Fp` (padrão) | `psql -f arquivo.sql` | Pequeno, legível, debug |
| Custom | `-Fc` | `pg_restore` | **Padrão de produção** — compactado, restauração paralela |
| Directory | `-Fd` | `pg_restore` | Como custom, mas vários arquivos (dá pra paralelizar dump também) |
| Tar | `-Ft` | `pg_restore` | Raramente usado, sem compressão |

Exemplos:
```bash
# Plain SQL (texto)
pg_dump -U postgres -d loja > loja.sql

# Custom (recomendado)
pg_dump -U postgres -Fc -d loja -f loja.dump

# Directory com 4 jobs em paralelo
pg_dump -U postgres -Fd -j 4 -d loja -f loja_dir/

# Só schema (sem dados)
pg_dump -U postgres -s -Fc -d loja -f loja_schema.dump

# Só dados (sem schema)
pg_dump -U postgres -a -Fc -d loja -f loja_dados.dump
```

No nosso Docker:
```bash
docker exec pg-curso pg_dump -U postgres -Fc -d loja -f /tmp/loja.dump
docker cp pg-curso:/tmp/loja.dump ./backups/loja.dump
```

## 🌐 `pg_dumpall` — o cluster inteiro
`pg_dump` ignora **roles, tablespaces e configuração global**. Para um backup completo do cluster:
```bash
pg_dumpall -U postgres > cluster.sql
```
Truque comum: usar `pg_dumpall --globals-only` pra pegar só roles/permissões, e `pg_dump -Fc` pra cada banco. Restauração mais flexível.

## ♻️ Restaurar
Depende do formato:
```bash
# Plain SQL: o psql lê direto
psql -U postgres -d loja_restaurada -f loja.sql

# Custom/directory/tar: pg_restore
pg_restore -U postgres -d loja_restaurada loja.dump

# Restauração paralela (custom ou dir)
pg_restore -U postgres -d loja_restaurada -j 4 loja.dump

# Listar conteúdo do dump (não restaura)
pg_restore -l loja.dump
```
**Importante**: o banco de destino precisa existir. Crie antes com `CREATE DATABASE loja_restaurada;`.

## 🗄️ Backup físico — `pg_basebackup`
Backup lógico é "rode esses comandos SQL pra rebuilder". Backup **físico** é cópia dos **arquivos do disco** do Postgres. Vantagens:
- Muito mais rápido pra bancos grandes (TB).
- Base para **replicação** e **PITR**.

```bash
pg_basebackup -U replicator -D /backup/base -Fp -P -R
```
- Tira uma cópia consistente dos arquivos enquanto o banco está rodando.
- Não dá pra restaurar uma tabela só (é tudo ou nada).
- Dá pra usar pra criar uma standby (com `-R`, já escreve a config de replicação).

## 📒 WAL e PITR (Point-in-Time Recovery)
Cada `INSERT/UPDATE/DELETE` é primeiro gravado no **WAL** (Write-Ahead Log) — arquivo de log binário em `pg_wal/`. Depois é aplicado nas tabelas.

Isso permite:
- **Crash recovery**: se o servidor cai, no boot ele aplica o WAL pendente.
- **Replicação**: o standby recebe o WAL e aplica nele também.
- **PITR**: arquivar o WAL contínuo, combinar com `pg_basebackup`, e restaurar até **qualquer momento no tempo**.

Fluxo de PITR (visão geral):
1. Tirar `pg_basebackup` periodicamente (ex: 1x por dia).
2. Arquivar WAL contínuo (via `archive_command` no `postgresql.conf`).
3. Em desastre: restaurar o basebackup, configurar `recovery_target_time = '2026-06-09 14:30:00'`, e o Postgres replay o WAL até aquele instante.

PITR é cobrado por ferramentas como **pgBackRest**, **Barman**, **WAL-G**. Em produção, **use uma dessas** em vez de scripts caseiros.

## 👥 Roles e privilégios
Em Postgres, **usuário e grupo são a mesma coisa**: ambos são `ROLE`. Diferença é só ter `LOGIN` ou não.

```sql
-- Role que loga (usuário)
CREATE ROLE loja_app LOGIN PASSWORD 'senha_forte';

-- Role que não loga (grupo)
CREATE ROLE leitor;

-- Dar privilégios
GRANT SELECT ON ALL TABLES IN SCHEMA public TO leitor;
GRANT leitor TO loja_app;  -- loja_app herda os privilégios de leitor
```

Privilégios comuns:

| Em | Privilégios |
|---|---|
| Banco | `CONNECT`, `CREATE`, `TEMP` |
| Schema | `USAGE`, `CREATE` |
| Tabela | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `REFERENCES`, `TRIGGER` |
| Coluna | `SELECT(col)`, `UPDATE(col)` |
| Função | `EXECUTE` |
| Sequência | `USAGE`, `SELECT`, `UPDATE` |

```sql
-- GRANT em diferentes níveis
GRANT CONNECT ON DATABASE loja TO loja_app;
GRANT USAGE ON SCHEMA public TO loja_app;
GRANT SELECT, INSERT, UPDATE ON TABLE produtos TO loja_app;
GRANT SELECT (nome, preco) ON produtos TO loja_app;  -- só essas colunas

-- REVOKE tira
REVOKE INSERT ON produtos FROM loja_app;

-- Tabelas futuras (default privileges)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO leitor;
```

`search_path` define em que schemas o Postgres procura objetos sem prefixo:
```sql
SHOW search_path;  -- padrão: "$user", public
SET search_path TO loja, public;
```

## 🔁 Replicação
### Streaming replication (física)
Primário envia o WAL pelo TCP pro standby continuamente. O standby aplica.
- **Read replica**: standby aceita leitura (`SELECT`), não escrita.
- **Failover**: se o primário cai, promove o standby.
- Replica o **cluster inteiro** (tudo ou nada).

Setup (visão geral):
1. No primário: `wal_level = replica`, criar role `replicator` com `REPLICATION`.
2. No standby: `pg_basebackup -R` apontando pro primário.
3. Subir o standby — ele já vai estar replicando.

### Logical replication (lógica)
Replica **tabela por tabela**, e funciona entre versões diferentes do Postgres (10+).

```sql
-- No primário (publisher):
CREATE PUBLICATION pub_produtos FOR TABLE produtos, categorias;

-- No subscriber:
CREATE SUBSCRIPTION sub_produtos
  CONNECTION 'host=primario port=5432 user=replicator dbname=loja'
  PUBLICATION pub_produtos;
```
Casos de uso: migração de versão sem downtime, replicar só algumas tabelas pra outro sistema (data warehouse), multi-region.

Diferenças:

| | Streaming | Logical |
|---|---|---|
| O que replica | Cluster inteiro (físico) | Tabelas escolhidas |
| Versões | Tem que ser igual | Pode ser diferente |
| Standby aceita escrita? | Não | Sim (em outras tabelas) |
| Latência | Mais baixa | Um pouco maior |

## 📈 Monitoramento
Tabelas/views internas (`pg_stat_*`) são ouro:

```sql
-- Quem está conectado e o que está rodando
SELECT pid, usename, datname, state, query, query_start
FROM pg_stat_activity
WHERE state != 'idle';

-- Estatísticas de tabelas (quantos seq_scan, idx_scan, mortos)
SELECT relname, seq_scan, idx_scan, n_live_tup, n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- Banco inteiro: hits, conflitos, deadlocks
SELECT datname, xact_commit, xact_rollback, blks_hit, blks_read, deadlocks
FROM pg_stat_database
WHERE datname = 'loja';

-- Replicação (rodar no primário)
SELECT client_addr, state, sync_state, replay_lag
FROM pg_stat_replication;
```

Ferramentas externas que crescem em cima disso:
- **pgBadger**: lê os logs do Postgres e gera relatórios HTML.
- **pgwatch2**: dashboard de métricas via Grafana.
- **pg_stat_statements**: extensão oficial que guarda estatísticas de cada query rodada — essencial em produção.

## 💡 Dicas de quem rodou Postgres em produção
- **Backup que não foi restaurado não é backup**. Teste a restauração periodicamente.
- **`-Fc` é o formato padrão** pra backup lógico. Plain SQL só pra coisa pequena/debug.
- **Roles por aplicação**, não usuário `postgres` em produção. Cada serviço com sua role e só os privilégios mínimos.
- **`pg_stat_statements` ativada desde o dia 1**. Senão você fica cego quando vier slow query.
- **PITR não é exagero**: a hora em que o estagiário rodar `DELETE` sem WHERE você vai agradecer.
- **Replicação ≠ backup**. Se você der `DROP TABLE` no primário, o standby também perde. Backup é outra coisa.

## 🚦 Próximos passos
1. Leia a `AULA.md`
2. Abra `pratica/queries.sql` — comandos de roles, GRANTs e monitoramento (shell commands em `-- SHELL:`)
3. Faça o `desafio/queries.sql` — backup e restore de produção + roles de app
4. **Pós-módulo**: este é o último — comemore! 🎉

## ✅ Auto-verificação
- [ ] Sei usar `pg_dump -Fc` e `pg_restore`
- [ ] Sei a diferença de backup lógico vs físico
- [ ] Sei o que é WAL e PITR (em linhas gerais)
- [ ] Sei criar role, grupo, dar GRANT/REVOKE
- [ ] Sei a diferença de streaming vs logical replication
- [ ] Sei consultar `pg_stat_activity` e `pg_stat_replication`

**Você terminou o curso de PostgreSQL.** Do `SELECT *` no Módulo 1 ao `pg_restore` agora: você sai daqui pronto pra rodar Postgres em produção. Bora pra próxima stack.
