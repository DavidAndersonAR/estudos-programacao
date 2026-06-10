-- =============================================
-- Módulo 20 — DESAFIO: Backup e Restore + Roles de App
-- Cenário: você assumiu o Postgres da loja em produção.
-- Precisa: separar acessos por papel, fazer backup,
-- restaurar em outro banco e montar auditoria de conexões.
-- =============================================

-- TODO 1: criar 3 roles com papéis diferentes
--   a) loja_admin: LOGIN, faz tudo (CREATEDB, CREATEROLE)
--   b) loja_app  : LOGIN, lê e escreve nas tabelas do schema public
--   c) loja_ro   : LOGIN, só LEITURA em public (relatórios)
-- Use senhas: 'admin_123', 'app_123', 'ro_123'

-- TODO 2: para a role loja_app, garantir USAGE nas sequências
--   (senão INSERT em tabela com SERIAL/IDENTITY quebra)

-- TODO 3: criar default privileges pra que TABELAS NOVAS
--   já nasçam com SELECT pra loja_ro

-- TODO 4: revogar do PUBLIC qualquer acesso ao schema public
--   (boa prática — por padrão PUBLIC tem CREATE em public)

-- TODO 5: rodar o backup lógico no formato CUSTOM (-Fc)
--   (comente o comando shell com -- SHELL:)

-- TODO 6: comandos shell pra:
--   a) criar banco loja_restaurada
--   b) restaurar o dump em loja_restaurada com 4 jobs em paralelo

-- TODO 7: montar query de AUDITORIA — quem está conectado AGORA
--   mostrando: pid, usuário, banco, IP cliente, estado, há quanto tempo,
--   e a query atual (se houver). Filtrar conexões idle longas.

-- TODO 8: query que lista privilégios efetivos da role loja_app
--   nas tabelas do schema public

-- TODO 9: limpeza idempotente (REVOKE + DROP ROLE)
--   pras 3 roles criadas


-- =============================================
-- SOLUÇÃO
-- =============================================

-- 1) Roles
CREATE ROLE loja_admin LOGIN PASSWORD 'admin_123' CREATEDB CREATEROLE;
CREATE ROLE loja_app   LOGIN PASSWORD 'app_123';
CREATE ROLE loja_ro    LOGIN PASSWORD 'ro_123';

-- Acesso básico ao banco e ao schema
GRANT CONNECT ON DATABASE loja TO loja_admin, loja_app, loja_ro;
GRANT USAGE   ON SCHEMA public TO loja_admin, loja_app, loja_ro;

-- loja_admin: dono lógico — pode tudo nas tabelas/sequências
GRANT ALL ON ALL TABLES    IN SCHEMA public TO loja_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO loja_admin;

-- loja_app: CRUD nas tabelas
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO loja_app;

-- loja_ro: só leitura
GRANT SELECT ON ALL TABLES IN SCHEMA public TO loja_ro;

-- 2) Sequências pra loja_app (SERIAL/IDENTITY)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO loja_app;

-- 3) Default privileges — tabelas FUTURAS já nascem visíveis pra loja_ro
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO loja_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO loja_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO loja_app;

-- 4) Tirar o acesso solto que PUBLIC tem por padrão no schema public
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- 5) Backup lógico (formato custom)
-- SHELL: docker exec pg-curso pg_dump -U postgres -Fc -d loja -f /tmp/loja_prod.dump
-- SHELL: docker cp pg-curso:/tmp/loja_prod.dump ./backups/loja_prod_$(date +%Y%m%d_%H%M).dump

-- 6) Criar banco vazio e restaurar
-- SHELL: docker exec pg-curso psql -U postgres -c "CREATE DATABASE loja_restaurada OWNER loja_admin;"
-- SHELL: docker exec pg-curso pg_restore -U postgres -d loja_restaurada -j 4 /tmp/loja_prod.dump
-- SHELL: docker exec pg-curso psql -U postgres -d loja_restaurada -c "SELECT count(*) FROM produtos;"  -- sanity check

-- 7) Auditoria — quem está conectado agora
SELECT pid,
       usename                                          AS usuario,
       datname                                          AS banco,
       client_addr                                      AS ip,
       state                                            AS estado,
       now() - backend_start                            AS tempo_conexao,
       now() - state_change                             AS tempo_neste_estado,
       left(query, 80)                                  AS query_atual
FROM pg_stat_activity
WHERE datname = 'loja'
  AND pid <> pg_backend_pid()                            -- ignora a própria conexão
  AND (state <> 'idle' OR now() - state_change < interval '10 minutes')
ORDER BY backend_start;

-- 8) Privilégios efetivos da loja_app
SELECT table_name,
       string_agg(privilege_type, ', ' ORDER BY privilege_type) AS privilegios
FROM information_schema.role_table_grants
WHERE grantee = 'loja_app'
  AND table_schema = 'public'
GROUP BY table_name
ORDER BY table_name;

-- 9) Limpeza idempotente
-- Tem que tirar default privileges, depois privilégios atuais, depois DROP
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON TABLES FROM loja_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM loja_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE USAGE, SELECT ON SEQUENCES FROM loja_app;

REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM loja_admin, loja_app, loja_ro;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM loja_admin, loja_app;
REVOKE ALL ON SCHEMA public                  FROM loja_admin, loja_app, loja_ro;
REVOKE ALL ON DATABASE loja                  FROM loja_admin, loja_app, loja_ro;

DROP ROLE IF EXISTS loja_admin;
DROP ROLE IF EXISTS loja_app;
DROP ROLE IF EXISTS loja_ro;
