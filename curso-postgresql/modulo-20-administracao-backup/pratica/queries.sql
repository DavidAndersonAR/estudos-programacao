-- =============================================
-- Módulo 20 — Administração: Backup, Roles, Replicação
-- Prática: roles, GRANT/REVOKE, monitoramento + comandos shell em -- SHELL:
-- Pré-requisito: estar conectado como superusuário (postgres) no banco loja
-- =============================================

-- Exercício 1: ver as roles existentes
SELECT rolname, rolsuper, rolcanlogin, rolcreatedb, rolcreaterole
FROM pg_roles
ORDER BY rolname;

-- Exercício 2: criar role de aplicação (com LOGIN — vira um "usuário")
CREATE ROLE loja_app LOGIN PASSWORD 'senha_app_123';

-- Exercício 3: criar role de leitura (sem LOGIN — é só um "grupo")
CREATE ROLE leitor;

-- Exercício 4: dar privilégios pra role leitor
GRANT CONNECT ON DATABASE loja TO leitor;
GRANT USAGE ON SCHEMA public TO leitor;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO leitor;

-- Exercício 5: e pras tabelas que ainda nem existem? (default privileges)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO leitor;

-- Exercício 6: dar GRANT em coluna específica (só nome e preco)
CREATE ROLE vendas_externo LOGIN PASSWORD 'externo_123';
GRANT USAGE ON SCHEMA public TO vendas_externo;
GRANT SELECT (nome, preco) ON produtos TO vendas_externo;

-- Exercício 7: criar role app com herança (loja_app vira "leitor" + escrita)
GRANT leitor TO loja_app;  -- agora loja_app herda os SELECTs
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO loja_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO loja_app;  -- pras chaves seriais

-- Exercício 8: REVOKE — tirar privilégio
REVOKE DELETE ON pedidos FROM loja_app;  -- pedidos não pode ser apagado

-- Exercício 9: ver privilégios em tabela (information_schema)
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('loja_app', 'leitor', 'vendas_externo')
ORDER BY grantee, table_name, privilege_type;

-- Exercício 10: ver de qual role você é membro
SELECT r.rolname AS role, m.rolname AS membro_de
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.member
JOIN pg_roles m ON m.oid = am.roleid
WHERE r.rolname = 'loja_app';

-- Exercício 11: search_path — onde o Postgres procura objetos sem prefixo
SHOW search_path;
SET search_path TO public;

-- Exercício 12: monitoramento — quem está conectado agora?
SELECT pid, usename, datname, client_addr, state, query_start, left(query, 60) AS query
FROM pg_stat_activity
WHERE datname = 'loja'
ORDER BY query_start DESC;

-- Exercício 13: estatísticas das tabelas — uso de índice vs seq scan
SELECT relname,
       seq_scan,
       idx_scan,
       n_live_tup,
       n_dead_tup,
       last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- Exercício 14: saúde do banco (commits, rollbacks, deadlocks, cache hit)
SELECT datname,
       xact_commit,
       xact_rollback,
       blks_hit,
       blks_read,
       deadlocks,
       round(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS cache_hit_pct
FROM pg_stat_database
WHERE datname = 'loja';

-- Exercício 15: tamanho dos objetos
SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS tamanho
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Exercício 16: matar conexão zumbi (em emergência)
-- SELECT pg_terminate_backend(12345);  -- pid vem de pg_stat_activity

-- Exercício 17: limpeza — apagar as roles que criamos (idempotente)
-- Tem que tirar os privilégios antes de DROP ROLE
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM leitor, loja_app, vendas_externo;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM loja_app;
REVOKE ALL ON SCHEMA public FROM leitor, loja_app, vendas_externo;
REVOKE ALL ON DATABASE loja FROM leitor;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON TABLES FROM leitor;
DROP ROLE IF EXISTS loja_app;
DROP ROLE IF EXISTS vendas_externo;
DROP ROLE IF EXISTS leitor;

-- =============================================
-- COMANDOS SHELL (rodam no terminal, NÃO no psql)
-- =============================================

-- SHELL: docker exec pg-curso pg_dump -U postgres -Fc -d loja -f /tmp/loja.dump
-- SHELL: docker cp pg-curso:/tmp/loja.dump ./backups/loja_$(date +%Y%m%d).dump

-- SHELL: docker exec pg-curso pg_dump -U postgres -Fp -d loja > backups/loja.sql

-- SHELL: docker exec pg-curso pg_dump -U postgres -Fd -j 4 -d loja -f /tmp/loja_dir

-- SHELL: docker exec pg-curso pg_dumpall -U postgres --globals-only -f /tmp/globals.sql

-- SHELL: docker exec pg-curso pg_restore -U postgres -d loja_nova -j 4 /tmp/loja.dump

-- SHELL: docker exec pg-curso pg_restore -l /tmp/loja.dump  # listar conteúdo

-- SHELL: docker exec pg-curso psql -U postgres -d loja_nova -f /tmp/loja.sql

-- SHELL: docker exec pg-curso pg_basebackup -U replicator -D /tmp/base -Fp -P -R  # backup físico
