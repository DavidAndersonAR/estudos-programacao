# Módulo 15 — Transações e ACID

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que cada letra do **ACID** significa (e por que importa)
- Usar `BEGIN`, `COMMIT`, `ROLLBACK` e `SAVEPOINT` com confiança
- Escolher o **nível de isolamento** certo pra cada caso
- Entender por que o Postgres não trava leituras (MVCC)
- Usar `SELECT ... FOR UPDATE` pra evitar **race conditions** (essencial pro desafio: transferência entre saldos)
- Diagnosticar **deadlocks** e identificar as 3 anomalias clássicas

## 🧱 ACID — o pacto que um banco sério faz com você
Toda vez que você manda uma transação, o Postgres promete 4 coisas. Se ele não cumprir, o banco é "brinquedo".

### A — Atomicidade
**Tudo ou nada.** A transação inteira roda, ou nenhuma alteração aparece. Se cair luz no meio do `UPDATE`, o Postgres desfaz tudo na hora que voltar (via WAL).

Exemplo clássico: transferência bancária. Debitar de A e creditar em B precisa ser atômico. Senão, dinheiro some.

### C — Consistência
**Constraints sempre valem.** Se uma CHECK, FK ou UNIQUE seria violada no fim da transação, ela é abortada inteira. O banco nunca termina num estado "meio quebrado".

### I — Isolamento
**Transações concorrentes parecem rodar uma de cada vez.** Você escolhe o nível de "ilusão" (veremos abaixo). Quanto maior o isolamento, mais seguro — e mais lento.

### D — Durabilidade
**Depois do COMMIT, é pra sempre.** Se a luz cair 1 microssegundo depois, no boot o dado ainda tá lá. Postgres usa o **WAL** (Write-Ahead Log): grava no log antes da tabela. Crash? Relê o log no startup.

## 🎬 BEGIN / COMMIT / ROLLBACK
O básico do controle manual:

```sql
BEGIN;                              -- abre a transação
UPDATE produtos SET estoque = estoque - 1 WHERE id = 10;
UPDATE pedidos  SET status = 'pago' WHERE id = 99;
COMMIT;                             -- confirma tudo
```

Se algo der errado no meio:
```sql
BEGIN;
UPDATE produtos SET estoque = estoque - 1 WHERE id = 10;
-- "epa, tô fazendo besteira"
ROLLBACK;                           -- desfaz tudo
```

`COMMIT` materializa. `ROLLBACK` joga fora. Sem mistério.

## ⚡ Autocommit — o "modo padrão" do psql
No psql (e na maioria dos drivers), **cada comando solto é uma transação implícita**:

```sql
UPDATE produtos SET preco = 99 WHERE id = 1;
-- equivale a:  BEGIN; UPDATE ...; COMMIT;
```

Por isso você não precisa escrever `BEGIN` toda hora. Só escreve quando quer **agrupar várias operações** num único "tudo ou nada".

Detalhe importante: se um comando dentro de um `BEGIN` falhar, o Postgres marca a transação como **abortada** e **rejeita tudo** até você dar `ROLLBACK`. Vai ver isso no prompt:
```
loja=!#
```
O `!` significa "tô abortada, preciso de ROLLBACK".

## 🔖 SAVEPOINT — checkpoint dentro da transação
Quer poder desfazer **só uma parte** sem perder o resto? Usa SAVEPOINT:

```sql
BEGIN;
INSERT INTO pedidos (cliente_id) VALUES (1) RETURNING id;     -- digamos id = 50
SAVEPOINT antes_dos_itens;

INSERT INTO itens_pedido VALUES (50, 1, 2, 99.90);
INSERT INTO itens_pedido VALUES (50, 999, 1, 50.00);          -- 999 não existe → erro

ROLLBACK TO SAVEPOINT antes_dos_itens;                        -- desfaz só os inserts dos itens
INSERT INTO itens_pedido VALUES (50, 2, 1, 50.00);            -- tenta de novo
COMMIT;
```

O `RELEASE SAVEPOINT nome` descarta o ponto (não desfaz nada, só limpa o marcador).

Útil em scripts longos, ORMs e procedures onde você quer recuperar de erros pontuais.

## 🔒 Níveis de Isolamento
Aqui é onde mora a polêmica. O padrão SQL define 4:

| Nível | Dirty read | Non-repeatable | Phantom | Postgres |
|---|---|---|---|---|
| READ UNCOMMITTED | possível | possível | possível | **não existe** (trata como READ COMMITTED) |
| READ COMMITTED | não | possível | possível | **default** |
| REPEATABLE READ | não | não | possível (no padrão) / não (no Postgres) | suportado |
| SERIALIZABLE | não | não | não | suportado (via SSI) |

Como definir:
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- ...
COMMIT;
```

Ou na sessão inteira: `SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL ...`.

### READ COMMITTED (default)
Cada **comando** dentro da transação vê o snapshot do **instante em que começou**. Se outra transação fizer commit no meio, o próximo `SELECT` enxerga o novo valor. Bom pro dia a dia. Não previne non-repeatable read.

### REPEATABLE READ
A **transação inteira** vê o snapshot do **primeiro comando**. Dois `SELECT` no mesmo dado retornam o mesmo resultado, mesmo que outros commitem. No Postgres, também previne **phantom reads** (graças ao MVCC), o que vai além do que o padrão exige.

### SERIALIZABLE
O mais forte. Postgres usa **SSI** (Serializable Snapshot Isolation): deixa rodar com snapshot, mas detecta se o resultado seria diferente de uma execução serial. Se sim, **uma transação aborta com erro** `could not serialize access`. Você precisa **retry**. É a única forma de garantir 100% de correção em concorrência maluca — mas custa.

## 🌀 MVCC — leituras nunca travam escritas
**Multi-Version Concurrency Control.** Em vez de bloquear o registro pra alguém ler enquanto outro escreve, o Postgres mantém **versões** do mesmo registro. Cada transação enxerga a versão consistente com seu snapshot.

Resultado prático:
- `SELECT` **nunca** trava `UPDATE`/`DELETE`
- `UPDATE`/`DELETE` **nunca** travam `SELECT`
- Só conflito de verdade: dois `UPDATE` na **mesma linha** ao mesmo tempo

O custo: versões mortas (tuplas obsoletas) precisam ser limpas — é o trabalho do **VACUUM** (módulo de performance/manutenção).

## 🔐 Locks explícitos — quando você precisa "segurar" a linha
MVCC resolve leitura concorrente, mas às vezes você quer **garantir** que ninguém vai mudar uma linha enquanto você decide o que fazer com ela. É o caso do **desafio**: transferência entre saldos.

```sql
BEGIN;
SELECT saldo FROM contas WHERE id = 1 FOR UPDATE;   -- trava a linha
-- valida saldo, calcula, decide
UPDATE contas SET saldo = saldo - 100 WHERE id = 1;
COMMIT;
```

Modos principais:
| Cláusula | O que faz |
|---|---|
| `FOR UPDATE` | trava forte: outras transações esperam pra ler-pra-update ou alterar |
| `FOR NO KEY UPDATE` | versão mais leve do FOR UPDATE (usado pelo próprio Postgres em FKs) |
| `FOR SHARE` | trava fraca: várias transações podem ler-pra-share, mas ninguém altera |
| `FOR KEY SHARE` | ainda mais leve, usado em FKs |

Modificadores úteis:
- `NOWAIT` — em vez de esperar, dá erro na hora
- `SKIP LOCKED` — pula linhas travadas (ótimo pra fila de jobs!)

## 💀 Deadlock
Dois caras esperando o outro liberar o lock. Postgres detecta automaticamente (uns 1s depois) e **mata uma das transações** com:
```
ERROR: deadlock detected
```
Solução: sempre acessar linhas **na mesma ordem** (ex: na transferência, sempre travar a conta de menor id primeiro). Se acontecer mesmo assim, faz **retry** na aplicação.

## 👻 As 3 anomalias clássicas
1. **Dirty read** — você lê um dado que outra transação ainda **não comitou** (Postgres nunca permite).
2. **Non-repeatable read** — você lê a mesma linha duas vezes na mesma transação e vem **valor diferente** (alguém comitou um UPDATE no meio). Acontece em READ COMMITTED.
3. **Phantom read** — você roda o mesmo `SELECT ... WHERE x = 1` duas vezes e aparecem **novas linhas** (alguém INSERIU). Acontece em READ COMMITTED. Postgres bloqueia em REPEATABLE READ (vai além do padrão).

Tem mais uma moderna: **write skew** — duas transações leem o mesmo conjunto, decidem baseado nele e escrevem em linhas diferentes, violando uma invariante global. Só SERIALIZABLE pega.

## 💡 Dicas de quem programa Postgres há tempo
- **Transação não é refúgio.** Quanto mais tempo aberta, mais tuplas mortas, mais lock pendurado. Faz o trabalho e **comita rápido**.
- **Nunca abra transação esperando input humano.** "BEGIN; pergunta ao usuário; COMMIT" é receita pra desastre.
- **READ COMMITTED resolve 95% dos casos.** Só sobe pra REPEATABLE READ / SERIALIZABLE quando tiver um motivo concreto.
- **SERIALIZABLE exige retry.** Sua aplicação **tem que** tratar `serialization_failure` (SQLSTATE 40001) e tentar de novo.
- **Sempre teste com 2 sessões abertas.** Abre dois `psql` lado a lado. Cenário de concorrência só aparece assim.

## 🔍 Diagnóstico rápido
```sql
-- Locks atuais e quem está esperando quem
SELECT pid, locktype, relation::regclass, mode, granted
FROM pg_locks
WHERE NOT granted OR locktype = 'transactionid';

-- Quem tá conectado e o que tá rodando
SELECT pid, state, wait_event_type, wait_event, query
FROM pg_stat_activity
WHERE state <> 'idle';
```

## 🚦 Próximos passos
1. Abre `pratica/queries.sql` e roda cada bloco. Os de concorrência você abre 2 sessões.
2. Faz o `desafio`: **Transferência entre Saldos** (a função clássica de banco).
3. Próximo módulo: índices e performance.

## ✅ Auto-verificação
- [ ] Sei explicar A, C, I e D com exemplos
- [ ] Sei a diferença entre READ COMMITTED e REPEATABLE READ
- [ ] Sei pra que serve `SELECT ... FOR UPDATE`
- [ ] Sei o que é MVCC em uma frase
- [ ] Sei como inspecionar locks (`pg_locks` + `pg_stat_activity`)
- [ ] Implementei a transferência com lock e SAVEPOINT

Próximo módulo: **Índices e performance** — quando criar, quando NÃO criar, EXPLAIN ANALYZE.
