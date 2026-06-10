# Módulo 04 — Loops e Scanner

> Corresponde às aulas do Java10x: *Scanners e validação*, *Laços de repetição usando clones*.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Escrever o `for` clássico (init; condição; passo)
- Usar o `for-each` pra varrer arrays e coleções
- Decidir entre `while` e `do-while`
- Quebrar e pular iterações com `break` e `continue`
- Ler dados do teclado com `Scanner` sem deixar vazamento de recurso

## 🔁 `for` clássico
A forma mais antiga e mais usada. Três partes separadas por ponto-e-vírgula:

```java
for (int i = 0; i < 5; i++) {
    System.out.println("i = " + i);
}
```

Pedaço por pedaço:
- **`int i = 0`**: inicialização (roda uma vez, antes de tudo)
- **`i < 5`**: condição (testada antes de cada volta — se for `false`, sai)
- **`i++`**: passo (roda no fim de cada volta)

Vai imprimir `i = 0` até `i = 4`. Quando `i` vira `5`, a condição falha e o loop termina.

### `for` aninhado
Um `for` dentro do outro. Clássico pra matrizes, tabuada, etc:

```java
for (int i = 1; i <= 3; i++) {
    for (int j = 1; j <= 3; j++) {
        System.out.printf("%d x %d = %d%n", i, j, i * j);
    }
}
```

## 🔂 `for-each` (for melhorado)
Quando você só quer **visitar cada elemento** de um array/lista, sem se importar com índice:

```java
int[] numeros = {10, 20, 30, 40};

for (int n : numeros) {
    System.out.println(n);
}
```

Leia como: "para cada `int n` dentro de `numeros`". Mais curto, mais legível, **menos espaço pra bug de índice**.

Limitações:
- Não dá pra modificar o array por dentro do `for-each`
- Não tem acesso ao índice (se precisar, use o `for` clássico)

## ⏳ `while`
Repete **enquanto** a condição for verdadeira. Útil quando você **não sabe quantas voltas** vai dar:

```java
int contador = 0;
while (contador < 3) {
    System.out.println("Volta " + contador);
    contador++;
}
```

⚠️ Esqueceu de incrementar? **Loop infinito**. Erro clássico.

## 🔁 `do-while`
Igual ao `while`, mas a condição é testada **no fim**. Garante que o bloco roda **pelo menos uma vez**:

```java
int n;
do {
    n = (int) (Math.random() * 10);
    System.out.println("Sorteou: " + n);
} while (n != 7);
```

Útil pra menus e validações: você precisa **executar primeiro** (mostrar opção, pedir entrada) e depois decidir se continua.

## 🚪 `break` e `continue`
- **`break`**: sai do loop imediatamente
- **`continue`**: pula pro próximo ciclo (não executa o resto do bloco)

```java
for (int i = 0; i < 10; i++) {
    if (i == 5) break;       // para tudo quando chegar em 5
    if (i % 2 == 0) continue; // pula pares
    System.out.println(i);
}
// Imprime: 1, 3
```

## ⌨️ Lendo do teclado com `Scanner`
A classe `Scanner` mora em `java.util.Scanner`. Precisa importar **antes** da classe:

```java
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Seu nome: ");
        String nome = sc.nextLine();
        System.out.println("Olá, " + nome);
        sc.close(); // fecha o recurso
    }
}
```

### Métodos mais usados
| Método | Lê |
|---|---|
| `sc.nextInt()` | um `int` |
| `sc.nextDouble()` | um `double` |
| `sc.next()` | uma palavra (até o espaço) |
| `sc.nextLine()` | a linha inteira |
| `sc.hasNextInt()` | `true` se o próximo token é um int |

### A pegadinha do `nextInt()` + `nextLine()`
`nextInt()` lê o número **mas deixa o `\n` no buffer**. O `nextLine()` seguinte pega esse `\n` vazio e segue. Solução: chame `sc.nextLine()` extra pra "limpar":

```java
int idade = sc.nextInt();
sc.nextLine(); // descarta o \n pendente
String nome = sc.nextLine();
```

### Sempre feche o Scanner — try-with-resources
Esquecer de fechar = vazamento de recurso. O padrão moderno é **try-with-resources**:

```java
try (Scanner sc = new Scanner(System.in)) {
    System.out.print("Idade: ");
    int idade = sc.nextInt();
    System.out.println("Você tem " + idade + " anos");
} // fecha sozinho aqui, mesmo se der exceção
```

Funciona com qualquer classe que implementa `AutoCloseable`. **Esquece o `sc.close()` manual** — try-with-resources é mais seguro.

## ✅ Validação de entrada
Combine `while` + `hasNextInt()` pra não quebrar quando o usuário digitar besteira:

```java
try (Scanner sc = new Scanner(System.in)) {
    int n;
    while (true) {
        System.out.print("Digite um número: ");
        if (sc.hasNextInt()) {
            n = sc.nextInt();
            break;
        }
        System.out.println("Inválido. Tente de novo.");
        sc.next(); // descarta o lixo
    }
    System.out.println("Você digitou: " + n);
}
```

## 💡 Pegadinhas que valem ouro
- **Loop infinito**: sempre garanta que a condição vai virar `false` em algum momento.
- **Off-by-one**: `<` vs `<=` é a fonte mais comum de bug em iniciante. Pense bem no limite.
- **`==` em String não funciona**: use `equals()` (vamos ver no Módulo 05).
- **Scanner não fechado**: o IntelliJ vai te avisar — escute o aviso.
- **`nextInt()` depois `nextLine()`**: lembre do `\n` pendente.

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode cada exercício.
2. Mexa nas condições — quebre os loops de propósito pra entender.
3. Encare o **desafio**: Jogo de Adivinhação.
4. Vá pro Módulo 05.

## ✅ Auto-verificação
- [ ] Escrevo `for`, `while` e `do-while` sem olhar
- [ ] Sei quando usar `for-each` em vez do `for` clássico
- [ ] Sei a diferença entre `break` e `continue`
- [ ] Consigo ler `int` e `String` do teclado
- [ ] Uso `try-with-resources` no `Scanner`
- [ ] Sei lidar com a pegadinha do `nextInt()` + `nextLine()`

Próximo módulo: **Strings e Arrays** — manipular texto e listas de tamanho fixo.
