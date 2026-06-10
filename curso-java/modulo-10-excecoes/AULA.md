# Módulo 10 — Exceções

> Corresponde ao Nível Intermediário do Java10x.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender a hierarquia de `Throwable`, `Error` e `Exception`
- Diferenciar **checked** (verificadas) de **unchecked** (não verificadas)
- Usar `try/catch/finally`, multi-catch e `try-with-resources`
- Lançar exceções com `throw` e declarar com `throws`
- Criar suas próprias exceções (custom exceptions)
- Evitar o anti-padrão de "engolir exceção"

## 🌪️ O que é uma exceção (resumo de elevador)
Exceção é um **evento anormal** que interrompe o fluxo normal do programa. Em vez de o programa quebrar com um erro críptico, Java empacota o problema em um objeto e "joga" (lança) pra cima — quem chamou o código tem a chance de **capturar** e tratar.

Pense num restaurante: o garçom anota seu pedido (fluxo normal). Se a cozinha não tem o ingrediente, ele **não finge que tá tudo bem** — ele volta e te avisa. Você decide: pede outra coisa (trata) ou vai embora (propaga).

Sem exceções, você precisaria checar código de erro em todo retorno (estilo C, Go). Com exceções, o "caminho feliz" fica limpo e o tratamento de erro fica separado.

## 🌳 Hierarquia de `Throwable`

```
Throwable
├── Error                  (erros graves da JVM — não tratar!)
│   ├── OutOfMemoryError
│   └── StackOverflowError
└── Exception              (erros recuperáveis — tratar)
    ├── IOException        (checked)
    ├── SQLException       (checked)
    └── RuntimeException   (unchecked — bug do programador)
        ├── NullPointerException
        ├── ArithmeticException
        ├── ArrayIndexOutOfBoundsException
        └── NumberFormatException
```

Regra prática:
- **`Error`** → problema grave da JVM (memória esgotada, stack estourada). **Não capture.**
- **`Exception` checked** → o compilador **obriga** você a tratar ou declarar (`throws`). Ex.: ler arquivo, abrir conexão.
- **`RuntimeException` (unchecked)** → erro de lógica/bug. O compilador **não obriga**, mas você ainda pode capturar.

## ✅ Checked vs Unchecked

### Checked (verificada) — o compilador te força
```java
import java.io.FileReader;
import java.io.IOException;

public class LeArquivo {
    public static void main(String[] args) throws IOException {
        // FileReader pode lançar IOException — checked.
        // OBRIGATÓRIO: declarar com `throws` ou envolver em try/catch.
        FileReader fr = new FileReader("dados.txt");
        fr.close();
    }
}
```

### Unchecked (não verificada) — compilador deixa passar
```java
public class Divide {
    public static void main(String[] args) {
        int x = 10 / 0; // ArithmeticException em tempo de execução
        // Compila sem reclamar. Quebra ao rodar.
    }
}
```

| Tipo | Compilador obriga? | Origem típica |
|---|---|---|
| Checked | Sim (`throws` ou `try/catch`) | Recursos externos (arquivo, rede, banco) |
| Unchecked (`RuntimeException`) | Não | Bug de lógica (índice errado, null, divisão por zero) |

## 🪤 `try / catch / finally`

```java
try {
    // código que pode lançar exceção
    int[] nums = {1, 2, 3};
    System.out.println(nums[10]);
} catch (ArrayIndexOutOfBoundsException e) {
    // tratamento — só executa se a exceção do tipo acima for lançada
    System.out.println("Índice fora do array: " + e.getMessage());
} finally {
    // SEMPRE executa — com ou sem exceção, com ou sem return
    System.out.println("Limpeza final aqui.");
}
```

- **`try`**: bloco "perigoso" que pode lançar.
- **`catch`**: pega a exceção. Pode ter vários `catch`, do mais específico pro mais genérico.
- **`finally`**: roda sempre. Útil pra fechar recursos (arquivo, conexão).

## 🎣 Multi-catch — pegar vários tipos no mesmo bloco

Antes do Java 7 você precisava de um `catch` pra cada tipo. Hoje dá pra agrupar com `|`:

```java
try {
    operacaoArriscada();
} catch (IOException | SQLException e) {
    // mesmo tratamento pra IO ou SQL
    System.err.println("Erro de I/O ou banco: " + e.getMessage());
}
```

Regra: os tipos não podem ser parentes (um não pode herdar do outro).

## 🧹 `try-with-resources` — fecha sozinho

Recursos como `Scanner`, `FileReader`, `Connection` precisam ser **fechados** depois de usar (senão vazam memória/file descriptor). O `try-with-resources` faz isso automaticamente:

```java
import java.util.Scanner;

public class Exemplo {
    public static void main(String[] args) {
        try (Scanner sc = new Scanner(System.in)) {
            System.out.print("Nome: ");
            String nome = sc.nextLine();
            System.out.println("Olá, " + nome);
        } // sc.close() é chamado automaticamente aqui, mesmo se der exceção
    }
}
```

Funciona com qualquer classe que implemente `AutoCloseable` (que é praticamente todo recurso da biblioteca padrão).

## 🚀 `throw` vs `throws` (não confunda!)

- **`throw`** (verbo): **lança** uma exceção agora.
- **`throws`** (substantivo, na assinatura): **declara** que o método pode lançar.

```java
// declara que pode lançar IOException (checked)
public static void leArquivo(String caminho) throws IOException {
    if (caminho == null) {
        // lança agora
        throw new IllegalArgumentException("caminho não pode ser null");
    }
    // ... leitura aqui
}
```

## 🏗️ Criando sua própria exceção

Quando os tipos prontos não descrevem bem seu erro de negócio, **crie o seu**:

```java
// Exceção de negócio — geralmente extende RuntimeException
public class SaldoInsuficienteException extends RuntimeException {
    public SaldoInsuficienteException(String mensagem) {
        super(mensagem);
    }
}

public class Conta {
    private double saldo = 100.0;

    public void sacar(double valor) {
        if (valor > saldo) {
            throw new SaldoInsuficienteException(
                "Saldo de " + saldo + " insuficiente para sacar " + valor
            );
        }
        saldo -= valor;
    }
}
```

Por que `RuntimeException` e não `Exception`?
- **`Exception`** (checked) → força quem chama a tratar. Bom pra erros recuperáveis de recursos externos.
- **`RuntimeException`** (unchecked) → não polui assinaturas. Bom pra erros de validação/negócio.

A comunidade Java moderna prefere **unchecked** pra quase tudo (Spring, Hibernate, etc).

## 🙈 Anti-padrão: engolir exceção

**NUNCA faça isto:**

```java
try {
    arriscado();
} catch (Exception e) {
    // 🙈 silêncio total — você nunca vai descobrir o que deu errado
}
```

Engolir exceção esconde bugs e transforma debug em pesadelo. Pelo menos:

```java
try {
    arriscado();
} catch (Exception e) {
    e.printStackTrace(); // mínimo: log o stack trace
    // ou: throw new RuntimeException("Falha em arriscado()", e);
}
```

**Encadear** (`new RuntimeException(msg, e)`) preserva a causa original — essencial pra debug.

## 💡 Pegadinhas que valem ouro
- **Ordem dos `catch` importa**: do mais específico pro mais genérico. `catch (Exception e)` no topo "rouba" todos os outros.
- **`finally` executa mesmo com `return` no `try`** — útil pra fechar recursos.
- **Não use exceção como controle de fluxo** (ex.: lançar pra "sair de um loop"). É caro e confuso.
- **`NullPointerException` é o erro nº 1 do Java** — sempre desconfie de objetos que vieram "de fora".
- **`e.getMessage()`** dá a mensagem; **`e.printStackTrace()`** dá o caminho completo até onde quebrou.
- **Não capture `Throwable` nem `Error`** — você não vai consertar `OutOfMemoryError` com `catch`.

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode os exercícios.
2. Force erros de propósito: divida por zero, acesse índice inválido, passe texto onde se espera número.
3. Encare o **desafio**: validador robusto de cadastro.
4. Quando estiver confortável, vá pro Módulo 11.

## ✅ Auto-verificação
- [ ] Sei a diferença entre `Error`, `Exception` e `RuntimeException`
- [ ] Sei o que é checked vs unchecked e quando o compilador me obriga
- [ ] Uso `try/catch/finally` com a ordem correta
- [ ] Sei usar multi-catch (`catch (A | B e)`)
- [ ] Uso `try-with-resources` pra fechar `Scanner`/arquivos
- [ ] Sei a diferença entre `throw` e `throws`
- [ ] Crio minha própria exceção estendendo `RuntimeException`
- [ ] Nunca engulo exceção (sempre logo ou repropago)

Próximo módulo: **Collections** — listas, sets, maps e iteração.
