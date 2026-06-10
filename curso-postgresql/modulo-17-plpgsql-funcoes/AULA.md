# Módulo 17 — PL/pgSQL: Funções e Procedures

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que é PL/pgSQL e por que ele existe
- Criar **funções** com `CREATE FUNCTION` (com `RETURNS`)
- Criar **procedures** com `CREATE PROCEDURE` (Postgres 11+) e chamá-las via `CALL`
- Usar parâmetros (`IN`, `OUT`, `INOUT`, `VARIADIC`)
- Declarar variáveis (`DECLARE`) e controlar fluxo (`IF`, `CASE`, `LOOP`, `FOR`, `WHILE`)
- Retornar valores simples, conjuntos (`RETURN QUERY`, `RETURN NEXT`) e tabelas (`RETURNS TABLE`)
- Tratar erros com `EXCEPTION` e levantar erros com `RAISE`

## 🤔 Por que PL/pgSQL?
SQL puro é declarativo: você descreve **o quê** quer, não **como**. Em 95% dos casos isso basta. Mas às vezes você precisa de:

- **Lógica condicional** complexa (regras de negócio com vários `IF`)
- **Loops** (processar lote a lote, iterar sobre cursores)
- **Variáveis** locais para guardar resultados intermediários
- **Tratamento de erro** (try/catch)
- **Triggers** (que vão ver no próximo módulo)

Para isso o Postgres oferece **linguagens procedurais**. A mais usada é **PL/pgSQL** (Procedural Language / PostgreSQL), que é tipo SQL com `IF`, `LOOP`, variáveis e exceção. Parecida com PL/SQL do Oracle.

> 💡 Outras linguagens disponíveis (precisam de extensão): `plpython3u`, `plperl`, `pltcl`, `plv8` (JavaScript). E tem o `LANGUAGE SQL` puro, sem fluxo de controle mas eficiente para wrappers.

## 🧱 CREATE FUNCTION — anatomia
```sql
CREATE OR REPLACE FUNCTION nome_funcao(param1 tipo, param2 tipo)
RETURNS tipo_retorno
LANGUAGE plpgsql
AS $$
DECLARE
    variavel tipo;
BEGIN
    -- lógica aqui
    RETURN expressao;
END;
$$;
```

Quebra do que importa:
- `CREATE OR REPLACE` — cria ou substitui se já existir (cuidado: a assinatura tem que bater).
- `RETURNS tipo` — pode ser `int`, `text`, `numeric`, `void`, `TABLE(...)`, `SETOF tipo`, `RECORD`.
- `LANGUAGE plpgsql` — diz qual linguagem está dentro do bloco.
- `$$ ... $$` — *dollar quoting*. É como uma aspas simples gigante que não conflita com aspas internas. Você pode usar `$func$ ... $func$` para nomear.

### Exemplo mínimo
```sql
CREATE OR REPLACE FUNCTION saudacao(nome TEXT) RETURNS TEXT
LANGUAGE plpgsql AS $$
BEGIN
    RETURN 'Olá, ' || nome || '!';
END;
$$;

SELECT saudacao('Ana');  -- "Olá, Ana!"
```

## 🎛️ Parâmetros: IN, OUT, INOUT, VARIADIC
- `IN` (padrão) — entrada apenas. Você não precisa escrever `IN`, é o default.
- `OUT` — saída. Permite retornar múltiplos valores sem precisar de `RETURNS TABLE`.
- `INOUT` — entrada e saída. Você passa um valor e ele volta modificado.
- `VARIADIC` — array de tamanho variável, igual `*args` do Python.

```sql
CREATE OR REPLACE FUNCTION divmod(a INT, b INT, OUT quociente INT, OUT resto INT)
LANGUAGE plpgsql AS $$
BEGIN
    quociente := a / b;
    resto := a % b;
END;
$$;

SELECT * FROM divmod(17, 5);  -- quociente=3, resto=2

CREATE OR REPLACE FUNCTION soma_tudo(VARIADIC nums INT[]) RETURNS INT
LANGUAGE plpgsql AS $$
DECLARE
    total INT := 0;
    n INT;
BEGIN
    FOREACH n IN ARRAY nums LOOP
        total := total + n;
    END LOOP;
    RETURN total;
END;
$$;

SELECT soma_tudo(1, 2, 3, 4, 5);  -- 15
```

## 📦 DECLARE — variáveis locais
Tudo dentro do bloco `DECLARE ... BEGIN ... END` é local à função:

```sql
DECLARE
    contador      INT := 0;       -- com valor inicial
    nome_completo TEXT;            -- só declarada
    preco         produtos.preco%TYPE;  -- "mesmo tipo da coluna preco"
    linha         produtos%ROWTYPE;     -- linha inteira da tabela
```

Atribuição usa `:=` (ou `=`, mas `:=` é o tradicional e mais legível).

## 🔀 Controle de fluxo

### IF / ELSIF / ELSE
```sql
IF preco < 50 THEN
    categoria := 'barato';
ELSIF preco < 200 THEN
    categoria := 'medio';
ELSE
    categoria := 'caro';
END IF;
```

### CASE (duas formas)
```sql
-- Forma com valor:
CASE estado
    WHEN 'SP' THEN frete := 15;
    WHEN 'RJ' THEN frete := 15;
    ELSE frete := 30;
END CASE;

-- Forma com condição (mais flexível):
CASE
    WHEN peso < 1 THEN preco := 10;
    WHEN peso < 5 THEN preco := 20;
    ELSE preco := 50;
END CASE;
```

### LOOP, FOR, WHILE, FOREACH
```sql
-- LOOP genérico (precisa de EXIT)
LOOP
    i := i + 1;
    EXIT WHEN i > 10;
END LOOP;

-- FOR com range numérico
FOR i IN 1..10 LOOP
    total := total + i;
END LOOP;

-- FOR percorrendo resultado de uma query
FOR linha IN SELECT id, nome FROM produtos WHERE estoque > 0 LOOP
    RAISE NOTICE 'Produto: %', linha.nome;
END LOOP;

-- WHILE
WHILE saldo > 0 LOOP
    saldo := saldo - 100;
END LOOP;

-- FOREACH em array
FOREACH x IN ARRAY meu_array LOOP
    ...
END LOOP;
```

`CONTINUE` pula pra próxima iteração, `EXIT` sai do loop. Pode rotular loops aninhados: `<<externo>> LOOP ... EXIT externo WHEN ...;`.

## 🔙 RETURN — três jeitos
Depende do que a função retorna:

| Tipo da função | Como retornar |
|---|---|
| `RETURNS int/text/numeric` | `RETURN valor;` |
| `RETURNS SETOF tipo` | `RETURN NEXT linha;` várias vezes, `RETURN;` no fim |
| `RETURNS TABLE(col1, col2)` | `RETURN QUERY SELECT ...;` ou `RETURN NEXT` |

```sql
-- Retornando uma tabela
CREATE OR REPLACE FUNCTION produtos_caros(limite NUMERIC)
RETURNS TABLE(nome TEXT, preco NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT p.nome::TEXT, p.preco
        FROM produtos p
        WHERE p.preco > limite;
END;
$$;

SELECT * FROM produtos_caros(100);
```

> ⚠️ Cuidado com **ambiguidade** de nomes: se a coluna da tabela e o parâmetro se chamam igual, o Postgres pode reclamar. Solução: qualifique com alias (`p.nome`) ou renomeie o parâmetro.

## 🚨 EXCEPTION — tratamento de erros

```sql
CREATE OR REPLACE FUNCTION divisao_segura(a NUMERIC, b NUMERIC) RETURNS NUMERIC
LANGUAGE plpgsql AS $$
BEGIN
    RETURN a / b;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Tentativa de dividir % por zero', a;
        RETURN NULL;
END;
$$;
```

Lançar erro manualmente:
```sql
RAISE EXCEPTION 'Saldo insuficiente: tinha %, tentou tirar %', saldo, valor
    USING ERRCODE = '22023';
```

Níveis do `RAISE`:
- `DEBUG`, `LOG`, `INFO`, `NOTICE`, `WARNING` — só mensagem
- `EXCEPTION` — aborta a função e faz rollback no que foi modificado dentro dela

Códigos comuns para capturar: `division_by_zero`, `unique_violation`, `foreign_key_violation`, `no_data_found`, `OTHERS` (pega tudo).

## 🛠️ CREATE PROCEDURE (Postgres 11+)
Procedure é parecida com função, mas:
- **Não retorna valor** (sem `RETURNS`)
- É chamada com **`CALL`** em vez de `SELECT`
- Pode usar **`COMMIT`** e **`ROLLBACK`** dentro dela (funções não podem!)

```sql
CREATE OR REPLACE PROCEDURE limpar_pedidos_antigos(dias INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM pedidos
    WHERE data_pedido < NOW() - (dias || ' days')::INTERVAL
      AND status = 'cancelado';
    COMMIT;  -- só funciona em procedure!
END;
$$;

CALL limpar_pedidos_antigos(90);
```

Quando usar procedure vs função?
- **Função**: tem `RETURNS`, é chamada em `SELECT`, ideal para cálculos e consultas.
- **Procedure**: faz efeitos colaterais (escreve em várias tabelas, gerencia transação), chamada com `CALL`.

## ⚡ Trigger functions (próximo módulo)
Um caso especial de função: **trigger function** retorna `TRIGGER` e roda automaticamente em `INSERT`/`UPDATE`/`DELETE`. Vamos ver direito no **Módulo 18 — Triggers**. Por enquanto saiba que existe e que a função é escrita igual às que estamos vendo aqui.

```sql
-- Spoiler:
CREATE FUNCTION atualizar_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 🌐 Outras linguagens
Por curiosidade, você pode escrever funções em outras linguagens (precisa instalar a extensão):

```sql
-- SQL puro (sem fluxo de controle, mas inlinável e rápido)
CREATE FUNCTION dobro(n INT) RETURNS INT
LANGUAGE sql AS $$ SELECT n * 2 $$;

-- Python (depois de CREATE EXTENSION plpython3u)
CREATE FUNCTION normalizar(t TEXT) RETURNS TEXT
LANGUAGE plpython3u AS $$
    import unicodedata
    return unicodedata.normalize('NFKD', t).encode('ascii', 'ignore').decode()
$$;
```

PL/pgSQL é o pão-com-manteiga. SQL puro é ótimo para wrappers simples. Outras só quando precisa mesmo.

## 💡 Dicas de quem já apanhou
- **Sempre `CREATE OR REPLACE`** durante desenvolvimento. Senão você fica fazendo `DROP FUNCTION` direto.
- **Atenção à assinatura**: Postgres identifica funções pelo nome **+ tipos dos parâmetros**. Mudar tipo = função nova.
- **`RAISE NOTICE` é seu print de debug.** Use à vontade pra entender o que tá rolando dentro.
- **`%ROWTYPE` e `%TYPE`** poupam dor de cabeça: se a coluna mudar de tipo, sua função acompanha.
- **Função é transacional implicitamente**: tudo que ela faz roda dentro da transação chamadora. Procedure pode controlar a sua.
- **Evite lógica de negócio pesada no banco**, em geral. Mas validações, triggers e relatórios costumam morar bem aqui.

## 🚦 Próximos passos
1. Rode `pratica/queries.sql` e crie cada função
2. Faça o `desafio`: calcular frete + aplicar desconto + processar pagamento
3. Vá pro **Módulo 18 — Triggers** (vamos amarrar funções em eventos)

## ✅ Auto-verificação
- [ ] Sei a diferença entre `CREATE FUNCTION` e `CREATE PROCEDURE`
- [ ] Consigo criar uma função com `IF/ELSE` e parâmetros
- [ ] Sei retornar múltiplas linhas com `RETURNS TABLE` + `RETURN QUERY`
- [ ] Consigo capturar erros com `EXCEPTION WHEN division_by_zero`
- [ ] Sei chamar uma procedure com `CALL`

Próximo módulo: **Triggers** — funções que disparam sozinhas em eventos.
