# Módulo 03 — Tipos de Dados

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escolher o tipo numérico certo pra cada caso (e nunca mais usar float pra dinheiro)
- Decidir entre `char`, `varchar(n)` e `text` sem dor de cabeça
- Trabalhar com data/hora respeitando timezone
- Usar UUID, ENUM, arrays e ter noção de range types
- Fazer cast (`::`) entre tipos com segurança

## 🧮 Tipos numéricos
Postgres tem **muito tipo numérico**. A escolha depende de **faixa**, **precisão** e **uso**.

| Tipo | Tamanho | Faixa | Quando usar |
|---|---|---|---|
| `smallint` | 2 bytes | -32.768 a 32.767 | IDs pequenos, idade, ano |
| `integer` (`int`) | 4 bytes | ~ ±2,1 bilhões | IDs comuns, contagens |
| `bigint` | 8 bytes | ~ ±9 quintilhões | IDs gigantes, valores grandes |
| `numeric(p,s)` | variável | exato | **dinheiro**, precisão fiscal |
| `real` | 4 bytes | ~6 dígitos | aproximado, científico |
| `double precision` | 8 bytes | ~15 dígitos | aproximado, científico |
| `money` | 8 bytes | depende do locale | **evite** — preso ao locale |

### O drama do float
**Nunca** use `real` ou `double precision` pra dinheiro. Por quê?
```sql
SELECT 0.1::real + 0.2::real;     -- 0.3000000119209...
SELECT 0.1::numeric + 0.2::numeric; -- 0.3 (exato)
```
Float é binário e não representa decimais exatamente. Em finanças isso vira centavos perdidos e auditor irritado. Pra dinheiro: **sempre `numeric(p,s)`**, ex.: `numeric(12,2)` (12 dígitos no total, 2 depois da vírgula).

### E o tipo `money`?
Existe, mas tem armadilha: depende da configuração regional do servidor (`lc_monetary`). Mude o locale, muda a interpretação. A galera evita. Use `numeric`.

## 📝 Tipos de texto
São três:

| Tipo | Limite | Características |
|---|---|---|
| `char(n)` | tamanho fixo | preenche com espaço — **quase ninguém usa** |
| `varchar(n)` | até n chars | valida tamanho |
| `text` | ilimitado | mais usado no Postgres |

**Diferença pro MySQL**: no Postgres, `text` e `varchar` têm o **mesmo desempenho**. Não tem penalidade. A convenção moderna é:
- Use `text` quando não precisa de limite
- Use `varchar(n)` só quando a regra de negócio exige limite (ex.: CPF tem 11 chars)
- Esqueça `char(n)` na maioria dos casos

```sql
nome      text NOT NULL,
cpf       varchar(11),
descricao text
```

## 📅 Tipos de data e hora
Aqui mora muita confusão. Vamos resolver.

| Tipo | O que guarda | Exemplo |
|---|---|---|
| `date` | só data | `2026-06-09` |
| `time` | só hora (sem TZ) | `14:30:00` |
| `timestamp` | data + hora **sem** timezone | `2026-06-09 14:30:00` |
| `timestamptz` | data + hora **com** timezone | `2026-06-09 14:30:00-03` |
| `interval` | duração | `'3 days 4 hours'` |

### Timezone: a regra de ouro
- **Use `timestamptz` por padrão.** Sempre. Quase em qualquer cenário com horário real.
- `timestamp` (sem TZ) só pra coisas locais abstratas ("o evento começa às 19h, em qualquer fuso").
- O Postgres internamente guarda `timestamptz` em **UTC**. Na hora de mostrar, converte pro fuso da sessão (`SHOW TIMEZONE;`).

```sql
SELECT now();                                 -- agora com TZ
SELECT current_date;                          -- só a data
SELECT now() + interval '7 days';             -- daqui a 7 dias
SELECT '2026-12-25'::date - current_date;     -- dias até Natal
```

## ✅ Boolean
Simples e direto: `true`, `false`, `null`.
```sql
ativo boolean DEFAULT true
```
Aceita também `'t'`/`'f'`, `'yes'`/`'no'`, `1`/`0` na entrada — mas guarda como boolean.

## 🆔 UUID
ID único universal, 128 bits. Bom quando:
- Você precisa gerar ID **fora** do banco (em microserviços, no cliente)
- Não quer expor a sequência (IDs incrementais entregam volume do negócio)
- Vai fundir bancos diferentes

```sql
CREATE TABLE usuarios (
  id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL
);

SELECT gen_random_uuid();
-- 7b3d9c4e-2a8f-4d1b-9c5e-6a7f8b9c0d1e
```
`gen_random_uuid()` veio nativa no Postgres 13+. Em versões anteriores precisava da extensão `pgcrypto`.

## 🎭 ENUM
Tipo enumerado: lista fixa de valores possíveis. Já usamos no Módulo 1 (`status_pedido`).

```sql
CREATE TYPE prioridade AS ENUM ('baixa', 'media', 'alta', 'critica');

CREATE TABLE tarefas (
  id   serial PRIMARY KEY,
  nivel prioridade NOT NULL DEFAULT 'media'
);
```

Vantagens: validação automática, ordenação na ordem declarada, economia de espaço. Cuidado: **alterar enum** (adicionar valor) é fácil (`ALTER TYPE ... ADD VALUE`), mas **remover** é chato. Pense bem antes.

## 📦 Arrays
Postgres tem arrays nativos. Qualquer tipo vira array botando `[]`.

```sql
CREATE TABLE produtos (
  id    serial PRIMARY KEY,
  nome  text,
  tags  text[]     -- array de texto
);

INSERT INTO produtos (nome, tags)
VALUES ('Camiseta', ARRAY['verao', 'algodao', 'unissex']);

SELECT nome, tags[1] FROM produtos;          -- primeiro elemento (1-based!)
SELECT nome FROM produtos WHERE 'algodao' = ANY(tags);
SELECT unnest(tags) FROM produtos;           -- expande array em linhas
```

Array é prático mas **não substitui tabela relacional**. Use pra valores curtos, sem necessidade de join. Pra muitos-para-muitos sério: tabela de junção.

## 📏 Range types (visão geral)
Postgres tem tipos pra **intervalos**: `int4range`, `numrange`, `tsrange`, `tstzrange`, `daterange`.

```sql
SELECT '[2026-01-01,2026-12-31]'::daterange;
SELECT '[10,20)'::int4range @> 15;   -- 15 está no range? true
```

Útil pra: reservas (datas), faixas de preço, períodos de validade. Com índice GiST dá pra perguntar "tem reserva sobrepondo esse intervalo?" rapidíssimo. Vamos ver fundo num módulo futuro.

## 🔄 Conversão de tipos (cast)
Postgres é **estrito**. Não converte automático como MySQL. Você converte com `::`.

```sql
SELECT '42'::integer;                  -- texto vira int
SELECT 42::text;                       -- int vira texto
SELECT '2026-06-09'::date;             -- texto vira date
SELECT current_date::text;             -- date vira texto
SELECT 'true'::boolean;
SELECT '7b3d9c4e-2a8f-4d1b-9c5e-6a7f8b9c0d1e'::uuid;
```

Forma alternativa: `CAST(valor AS tipo)`. Mesma coisa, mais verboso.

## 💡 Dicas de quem já errou
- **`numeric` pra dinheiro. Sempre.** Float é proibido em contabilidade.
- **`text` é o padrão** moderno pra strings. `varchar(n)` só se tiver regra de tamanho real.
- **`timestamptz` por padrão.** `timestamp` sem TZ é dor de cabeça garantida.
- **UUID não substitui int** sempre — gasta mais espaço, ordena pior. Use quando faz sentido.
- **Array é tentação**: bom pra tags simples; ruim pra relacionamentos sérios.
- **`::` é seu amigo** — quando o Postgres reclama de tipo, é cast na cara.

## 🚦 Próximos passos
1. Rode `pratica/queries.sql` e veja conversões, datas e arrays funcionando
2. Faça o `desafio`: construir um **Validador de Dados de Cadastro**
3. Vá pro Módulo 04 — DDL: criando tabelas pra valer

## ✅ Auto-verificação
- [ ] Sei por que `numeric` é melhor que `float` pra dinheiro
- [ ] Sei a diferença entre `timestamp` e `timestamptz`
- [ ] Sei gerar um UUID com `gen_random_uuid()`
- [ ] Sei criar um ENUM e um array
- [ ] Sei converter tipo com `::`

Próximo módulo: **DDL — criando suas próprias tabelas** com constraints e defaults.
