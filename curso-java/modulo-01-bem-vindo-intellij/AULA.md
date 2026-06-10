# Módulo 01 — Bem-vindo + IntelliJ

> Corresponde às aulas do Java10x: *Bem vindo ao bar*, *Escolhendo a IDE*, *Como configurar seus atalhos*, *Principais shortcuts*.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Verificar se o JDK está instalado e em qual versão
- Entender por que o IntelliJ IDEA é a IDE padrão do mundo Java
- Escrever, compilar e rodar seu primeiro programa Java
- Reconhecer a estrutura mínima de um arquivo `.java`

## ☕ O que é Java (resumo de elevador)
Java nasceu em 1995, criado pela Sun (hoje Oracle). A promessa: **"Write Once, Run Anywhere"** — escreve uma vez, roda em qualquer máquina que tenha a JVM (Java Virtual Machine).

Pontos fortes:
- **Robusto**: tipagem forte, tratamento explícito de erros
- **Maduro**: ecossistema gigante (Spring, Hibernate, Maven, etc)
- **Multiplataforma**: mesmo código roda em Windows, Linux, Mac, Android
- **Forte no mercado**: bancos, e-commerce, fintechs, backend em geral

Quem usa: Itaú, Bradesco, Nubank, iFood, Netflix, Amazon, LinkedIn.

## 🧰 JDK, JRE e JVM (entender essa sopa de letras)
- **JVM** (Java Virtual Machine): o "motor" que roda código Java
- **JRE** (Java Runtime Environment): JVM + bibliotecas pra rodar programas
- **JDK** (Java Development Kit): JRE + ferramentas pra desenvolver (`javac`, `jar`, etc)

Você precisa do **JDK** pra programar. Você já tem JDK 21 instalado (LTS, suporte até 2031).

Verifique no terminal:
```bash
java --version
javac --version
```

## 💻 Escolhendo a IDE
**IntelliJ IDEA Community** (gratuita). Por que não VS Code?

VS Code é ótimo pra muita coisa, mas no Java o IntelliJ é absurdamente melhor:
- Refactoring inteligente (renomear classe em todo o projeto, extrair método, etc)
- Autocomplete que entende contexto
- Integração nativa com Maven/Gradle
- Debugger excepcional
- Inspeções de código que pegam bugs antes de rodar

Baixe em: https://www.jetbrains.com/idea/download/ (escolha **Community Edition** — gratuita).

## 🧱 Anatomia de um programa Java

```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Olá, Java!");
    }
}
```

Pedaço por pedaço:

### `public class Main`
Tudo em Java vive dentro de uma **classe**. O nome do arquivo (`Main.java`) **precisa bater** com o nome da classe pública.

### `public static void main(String[] args)`
Esse é o ponto de partida do programa. Decora essa assinatura — vai escrever muitas vezes:
- `public`: visível pra JVM rodar
- `static`: pode rodar sem precisar criar um objeto
- `void`: não retorna nada
- `main`: nome obrigatório
- `String[] args`: argumentos da linha de comando

### `System.out.println("Olá, Java!");`
Imprime no console com quebra de linha (`println` = print line).
- `System.out` é o objeto de saída padrão
- `;` no fim **é obrigatório** (diferente de Go)

## ▶️ Como rodar

### Forma 1: arquivo único (JDK 11+, jeito moderno)
```bash
java Main.java
```
Pronto. A JVM compila e roda numa tacada.

### Forma 2: compilar e rodar separado (clássico)
```bash
javac Main.java   # gera Main.class
java Main         # roda
```

### No IntelliJ
- Botão verde de "play" ao lado do método `main`
- Ou atalho `Shift+F10` (Windows/Linux), `Ctrl+R` (Mac)

## ⌨️ Shortcuts essenciais do IntelliJ
Sem eles você programa devagar. Decora aos poucos.

| Atalho (Windows/Linux) | O que faz |
|---|---|
| `psvm` + Tab | Gera o `public static void main(...)` |
| `sout` + Tab | Gera `System.out.println()` |
| `Ctrl+Espaço` | Autocomplete |
| `Ctrl+Alt+L` | Formata o código |
| `Shift+F10` | Roda o programa |
| `Shift+F6` | Renomear (variável, método, classe — refactor) |
| `Ctrl+Shift+F` | Buscar em todos os arquivos |
| `Ctrl+/` | Comenta/descomenta linha |
| `Alt+Enter` | Sugestão rápida (acende a lâmpada) |

## 💡 Pegadinhas que valem ouro
- **Ponto-e-vírgula é obrigatório**: esqueceu → erro de compilação.
- **Maiúsculas importam**: `String` ≠ `string`. `Main` ≠ `main`.
- **Arquivo precisa bater com a classe pública**: classe `Pessoa` ⇒ arquivo `Pessoa.java`.
- **Pacote vai na primeira linha** (vamos ver depois): `package com.empresa.app;`
- **Uma classe pública por arquivo**.

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** e rode.
2. Modifique alguma coisa (texto, número), rode de novo.
3. Encare o **desafio**: cartão de visitas.
4. Quando estiver confortável, vá pro Módulo 02.

## ✅ Auto-verificação
- [ ] Sei a diferença entre JDK, JRE e JVM
- [ ] Sei por que escolher IntelliJ pra Java
- [ ] Consigo escrever um Hello World do zero (sem olhar)
- [ ] Sei rodar com `java Main.java` (forma moderna)
- [ ] Conheço pelo menos 5 shortcuts do IntelliJ

Próximo módulo: **Variáveis e Tipos** — armazenar dados na memória.
