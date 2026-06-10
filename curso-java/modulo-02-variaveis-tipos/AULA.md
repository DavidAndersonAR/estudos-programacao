# Módulo 02 — Variáveis e Tipos

> Corresponde às aulas do Java10x: *Variáveis e tipagem de dados*, *Dados primitivos e o erro de 50 milhões*.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Declarar variáveis usando os tipos primitivos do Java
- Diferenciar tipos primitivos de tipos referência (objetos)
- Usar `var` (inferência de tipo, Java 10+) sem abusar
- Entender conversão implícita (widening) e casting explícito
- Saber por que **nunca** usar `float`/`double` pra dinheiro
- Criar constantes com `final`

## 🧱 Tipagem forte e estática
Java é **fortemente tipado** e **estaticamente tipado**:
- **Estático**: o tipo é decidido em tempo de compilação (não muda em runtime).
- **Forte**: o compilador não deixa você somar laranja com maçã sem você mandar explicitamente.

Isso é o oposto de Python/JavaScript. O custo é digitar mais; o ganho é o compilador pegar bug por você.

## 🧬 Os 8 tipos primitivos
Primitivos guardam o valor "cru" na memória — sem objeto envolvido. São rápidos e leves.

### Inteiros
| Tipo | Tamanho | Faixa | Quando usar |
|---|---|---|---|
| `byte` | 8 bits | -128 a 127 | raro: I/O binário, economia de memória |
| `short` | 16 bits | -32.768 a 32.767 | raro |
| `int` | 32 bits | ~-2,1 bi a ~2,1 bi | **padrão pra inteiros** |
| `long` | 64 bits | ~-9 quintilhões a ~9 quintilhões | IDs grandes, timestamps em ms |

```java
int idade = 30;
long populacaoMundial = 8_100_000_000L; // sufixo L é obrigatório em long
```

> Dica: `_` em literais numéricos é só visual (Java 7+). Ajuda a ler `1_000_000`.

### Decimais (ponto flutuante)
| Tipo | Tamanho | Precisão | Quando usar |
|---|---|---|---|
| `float` | 32 bits | ~7 dígitos | raro |
| `double` | 64 bits | ~15 dígitos | **padrão pra decimais** |

```java
double altura = 1.75;
float pi = 3.14f; // sufixo f é obrigatório em float
```

### Caractere e booleano
| Tipo | Tamanho | Valores |
|---|---|---|
| `char` | 16 bits (Unicode) | um único caractere: `'A'`, `'ç'`, `'9'` |
| `boolean` | 1 bit (lógico) | `true` ou `false` |

```java
char inicial = 'D';      // aspas SIMPLES, sempre
boolean ativo = true;
```

## 🧶 Tipos referência (objetos)
Diferente dos primitivos, esses são **objetos** — guardam uma referência (ponteiro) pra um lugar na memória (heap).

### `String`
Não é primitivo, mas tem tratamento especial no Java (pode usar literal entre aspas duplas).

```java
String nome = "David";
int tamanho = nome.length();          // 5
String maiusculo = nome.toUpperCase(); // "DAVID"
String pedaco = nome.substring(0, 2);  // "Da"
```

### Wrappers: `Integer`, `Double`, `Boolean`, etc
Cada primitivo tem uma versão "objeto". Útil em coleções (`List<Integer>` funciona, `List<int>` não).

```java
int a = 10;              // primitivo
Integer b = 10;          // wrapper (objeto)
Integer nulo = null;     // wrappers aceitam null; primitivos NÃO
```

Java faz **autoboxing** (primitivo → wrapper) e **unboxing** (wrapper → primitivo) automaticamente, mas cuidado: `null` em unboxing explode (`NullPointerException`).

## 📝 Declaração de variáveis

Sintaxe básica: `tipo nome = valor;`

```java
int idade = 30;
double salario = 4500.75;
String nome = "Maria";
boolean ativo = true;
```

Você pode declarar sem atribuir, mas precisa atribuir antes de usar:
```java
int x;
x = 10;
System.out.println(x);
```

## 🪄 `var` — inferência de tipo (Java 10+)
Desde o Java 10, dá pra deixar o compilador inferir o tipo:

```java
var idade = 30;          // o compilador entende que é int
var nome = "David";      // String
var lista = new java.util.ArrayList<String>(); // ArrayList<String>
```

**Atenção**:
- `var` é **só pra variáveis locais** (dentro de método). Não funciona em campo de classe nem parâmetro.
- Precisa de inicialização na mesma linha (senão o compilador não tem como inferir).
- **Continua sendo estaticamente tipado** — o tipo é fixado na declaração, só você não escreveu.

Use `var` quando o tipo é óbvio pelo lado direito. Não use só por preguiça.

## 🔁 Conversão de tipos

### Widening (implícita, "sobe" automaticamente)
Quando o destino comporta o valor, Java converte sozinho:
```java
int i = 100;
long l = i;       // int → long, ok
double d = i;     // int → double, ok
```
Ordem: `byte → short → int → long → float → double`.

### Narrowing (casting explícito, você assume o risco)
Quando o destino pode perder informação, você **precisa** mandar:
```java
double pi = 3.14;
int truncado = (int) pi;  // 3 (perde a parte decimal)

long big = 10_000_000_000L;
int pequeno = (int) big;  // estouro silencioso, vira lixo
```

## 💸 O erro de 50 milhões (`float`/`double` em dinheiro)
Ponto flutuante (`float`/`double`) é **binário** — ele aproxima decimais. Pra contas científicas, ok. Pra dinheiro, **catastrófico**.

```java
double a = 0.1;
double b = 0.2;
System.out.println(a + b); // 0.30000000000000004
```

Multiplique isso por milhões de transações: você perde (ou ganha) dinheiro do nada.

**Solução**: use `BigDecimal` pra valores monetários.

```java
import java.math.BigDecimal;

BigDecimal preco = new BigDecimal("19.90");  // String no construtor, sempre
BigDecimal quantidade = new BigDecimal("3");
BigDecimal total = preco.multiply(quantidade); // 59.70 exato
```

> Regra de ouro: **dinheiro = BigDecimal**. Decora.

## 🔒 Constantes com `final`
Quer uma variável que não pode mudar depois de atribuída? Use `final`:

```java
final double PI = 3.14159;
final int MAX_TENTATIVAS = 3;
// MAX_TENTATIVAS = 5; // erro de compilação
```

Convenção: constantes em `MAIÚSCULAS_COM_UNDERSCORE`.

Quando combinado com `static` (em campo de classe), vira "constante global":
```java
public static final double TAXA_JUROS = 0.05;
```

## 🧪 Operadores básicos (preview)
Pra brincar com os tipos:

```java
int a = 10, b = 3;
System.out.println(a + b); // 13
System.out.println(a - b); // 7
System.out.println(a * b); // 30
System.out.println(a / b); // 3  (divisão inteira!)
System.out.println(a % b); // 1  (resto)

double c = 10.0, d = 3.0;
System.out.println(c / d); // 3.3333333333333335
```

> Pegadinha: `int / int = int`. Pra ter resultado decimal, pelo menos um lado precisa ser `double`.

## 💡 Pegadinhas que valem ouro
- **`int` é o padrão**. Só use `long` se precisar de números enormes (e lembre do sufixo `L`).
- **`double` é o padrão pra decimal** — mas **nunca pra dinheiro**.
- **`char` usa aspas simples**, `String` usa aspas duplas. Trocar dá erro.
- **`String` é imutável**: `nome.toUpperCase()` não muda `nome`, retorna uma string nova.
- **Compare String com `.equals()`**, não com `==`. (Vamos ver direito mais à frente.)
- **`var` não é dinâmico** — é açúcar pra "deixa o compilador escrever o tipo".

## 🚦 Próximos passos
1. Abra `pratica/Main.java`, rode, modifique valores e veja o que acontece.
2. Force erros de propósito: tente atribuir `double` a `int` sem casting, veja o compilador reclamar.
3. Encare o **desafio: Calculadora de IMC**.

## ✅ Auto-verificação
- [ ] Sei listar os 8 tipos primitivos e quando usar cada um
- [ ] Sei diferença entre primitivo e wrapper (Integer vs int)
- [ ] Sei quando usar `var` (e quando não usar)
- [ ] Entendo widening vs casting explícito
- [ ] **Nunca mais uso `double` pra dinheiro** — sempre `BigDecimal`
- [ ] Sei criar constantes com `final`

Próximo módulo: **Operadores e Expressões** — fazer contas e tomar decisões.
