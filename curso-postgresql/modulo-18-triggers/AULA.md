# Módulo 18 — Triggers

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é um trigger e quando faz sentido usar
- Criar trigger functions com `RETURNS TRIGGER`
- Usar `BEFORE` vs `AFTER`, `FOR EACH ROW` vs `FOR EACH STATEMENT`
- Manipular `NEW` e `OLD` pra ler/alterar valores
- Filtrar disparos com `WHEN` e identificar a operação com `TG_OP`
- Aplicar triggers em casos clássicos: auditoria, `updated_at`, validação, soft-delete

## ⚡ O que é um trigger?
Trigger é uma **função que dispara automaticamente** quando uma operação acontece numa tabela (INSERT, UPDATE, DELETE ou TRUNCATE). Você define **uma vez** e o Postgres executa **sempre que** o evento acontece — sem o app precisar saber.

A analogia: é uma **câmera de segurança no banco**. Toda vez que mexe na tabela, o trigger é acionado e faz algo no fundo.

No Postgres, trigger é coisa de **duas peças**:
1. Uma **trigger function** (função PL/pgSQL que retorna `TRIGGER`)
2. Um **CREATE TRIGGER** que liga a função a uma tabela + evento

## 🧱 Anatomia básica
```sql
-- 1) A função
CREATE OR REPLACE FUNCTION minha_funcao()
RETURNS TRIGGER AS $$
BEGIN
    -- lógica aqui
    RETURN NEW;  -- ou OLD, ou NULL
END;
$$ LANGUAGE plpgsql;

-- 2) O trigger
CREATE TRIGGER meu_trigger
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION minha_funcao();
```

Quebra:
- `BEFORE INSERT` = quando dispara (antes do INSERT)
- `ON clientes` = em qual tabela
- `FOR EACH ROW` = uma vez por linha afetada
- `EXECUTE FUNCTION` = chama a função

## ⏱️ BEFORE vs AFTER
| Momento | Quando roda | Pode mudar `NEW`? | Caso típico |
|---|---|---|---|
| `BEFORE` | **antes** da operação acontecer | **Sim** — mudanças entram na linha gravada | normalizar dados, validar, abortar |
| `AFTER` | **depois** da operação acontecer | Não (linha já foi gravada) | auditoria, log, side-effects |

Regra prática:
- Quer **interferir na linha**? `BEFORE`.
- Quer **reagir ao fato**? `AFTER`.

## 🔁 FOR EACH ROW vs FOR EACH STATEMENT
| Escopo | Dispara quantas vezes |
|---|---|
| `FOR EACH ROW` | uma vez **por linha** afetada |
| `FOR EACH STATEMENT` | uma vez **por comando**, mesmo que mexa em 1000 linhas |

90% dos triggers do mundo real são `FOR EACH ROW`, porque precisam de `NEW`/`OLD`. `STATEMENT` é útil pra auditoria agregada ("alguém rodou um UPDATE em pedidos").

## 📡 Eventos
- `INSERT` — linha nova chegando
- `UPDATE` — linha mudando (pode filtrar coluna: `UPDATE OF status`)
- `DELETE` — linha saindo
- `TRUNCATE` — tabela inteira sendo limpa (só `FOR EACH STATEMENT`)

Pode combinar:
```sql
CREATE TRIGGER tg_audit
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH ROW EXECUTE FUNCTION auditar();
```

## 🔮 Variáveis especiais: NEW e OLD
Dentro da trigger function, o Postgres te entrega:

| Variável | INSERT | UPDATE | DELETE |
|---|---|---|---|
| `NEW` | linha nova | linha **depois** | NULL |
| `OLD` | NULL | linha **antes** | linha que vai sair |

Exemplos:
```sql
-- BEFORE INSERT: forçar email lowercase
NEW.email := LOWER(NEW.email);
RETURN NEW;

-- AFTER UPDATE: comparar antes/depois
IF OLD.status <> NEW.status THEN
    -- status mudou, loga
END IF;
```

## 🎯 TG_OP — qual operação disparou?
Quando o trigger cobre vários eventos, use `TG_OP` pra saber qual foi:
```sql
IF TG_OP = 'INSERT' THEN
    -- ...
ELSIF TG_OP = 'UPDATE' THEN
    -- ...
ELSIF TG_OP = 'DELETE' THEN
    RETURN OLD;
END IF;
```

Outras variáveis úteis: `TG_TABLE_NAME`, `TG_WHEN` (`BEFORE`/`AFTER`), `TG_LEVEL` (`ROW`/`STATEMENT`).

## 🚪 Cláusula WHEN — disparo condicional
Filtra **antes** da função rodar (mais barato que `IF` dentro):
```sql
CREATE TRIGGER tg_log_status
AFTER UPDATE ON pedidos
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION logar_mudanca_status();
```

`IS DISTINCT FROM` é o operador certo aqui — trata NULL com sanidade (NULL = NULL retorna NULL com `<>`, mas `IS DISTINCT FROM` retorna `FALSE`).

## 🧠 O que a função tem que retornar?
| Momento | O que retornar |
|---|---|
| `BEFORE` ROW INSERT/UPDATE | `NEW` (ou NULL pra cancelar) |
| `BEFORE` ROW DELETE | `OLD` (ou NULL pra cancelar) |
| `AFTER` ROW (qualquer) | valor é ignorado, mas convenção é `NEW`/`OLD` |
| `STATEMENT` | sempre `NULL` |

Retornar `NULL` num `BEFORE` **cancela a operação** pra aquela linha — útil pra validação ("não deixa deletar pedido entregue").

## 🛠️ Casos clássicos

### 1) Updated_at automático
```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_updated_at
BEFORE UPDATE ON produtos
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### 2) Auditoria
Grava em outra tabela o que mudou, quando, por quem. Padrão guardar `NEW` e `OLD` como `jsonb` (`to_jsonb(NEW)`).

### 3) Validação
`BEFORE` que faz `RAISE EXCEPTION` se a regra for violada — força no banco, não confia no app.

### 4) Sincronização / cache
`AFTER UPDATE` que atualiza coluna derivada em outra tabela (ex.: total do pedido a partir dos itens).

## 🗂️ Gerenciando triggers
```sql
-- Listar triggers de uma tabela
\d pedidos

-- Via catálogo (mais flexível)
SELECT tgname, tgrelid::regclass AS tabela, tgenabled
FROM pg_trigger
WHERE NOT tgisinternal;

-- Desabilitar temporariamente (útil em migrações)
ALTER TABLE pedidos DISABLE TRIGGER tg_audit;
ALTER TABLE pedidos ENABLE TRIGGER tg_audit;

-- Remover
DROP TRIGGER tg_audit ON pedidos;
```

## ⚠️ Cuidados (sério)
Trigger é **lâmina afiada**. Mal usado vira pesadelo:

- **Lógica escondida**: dev novo no time não sabe que existe — debug vira caça ao tesouro. **Documente.**
- **Performance**: trigger `FOR EACH ROW` num INSERT de 1 milhão de linhas roda 1 milhão de vezes. Pense em `STATEMENT` ou COPY sem trigger.
- **Cascata**: trigger que dispara trigger que dispara trigger… recursão silenciosa. Postgres tem proteção (`pg_trigger_depth()`), mas cuidado.
- **Erro fatal**: `RAISE EXCEPTION` num trigger **aborta a transação inteira** — às vezes é o que você quer (validação), às vezes não (log que falha derrubando o pedido).
- **Não use pra lógica de negócio complexa**: regra "se cliente premium, dar 10% desconto" no app, não no trigger. Use trigger pra **consistência de dados**.

Regra geral: trigger é bom pra **auditoria, integridade e automações invisíveis** (timestamps, normalização). Tudo que vira "código de negócio" fica fora.

## ✅ Auto-verificação
- [ ] Sei a diferença entre BEFORE e AFTER e quando usar cada um
- [ ] Sei o que tem em NEW e OLD em cada tipo de operação
- [ ] Sei usar TG_OP pra um trigger cobrir INSERT/UPDATE/DELETE juntos
- [ ] Sei retornar NULL num BEFORE pra cancelar a operação
- [ ] Sei listar e remover triggers
- [ ] Entendi por que trigger é faca de dois gumes

Próximo módulo: **Views & Materialized Views** — quando consulta vira tabela virtual.
