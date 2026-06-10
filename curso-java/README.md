# Curso de Java — Batismo de Java (versão escrita)

> Curso paralelo ao **Batismo de Java** (java10x.dev), no mesmo formato do [curso de Go](../curso/README.md) que fizemos juntos. Como você não tem tempo de assistir as 38h59m de vídeos, esse curso entrega o **mesmo conteúdo em formato escrito**, com teoria curta, exemplos comentados e miniprojeto por módulo.

## ⚠️ Honestidade primeiro
Eu **não consegui assistir aos vídeos** do Java10x (o firewall corporativo bloqueou o acesso depois das primeiras páginas). Mas consegui mapear:
- A **estrutura completa** do curso (149 aulas em 5 módulos + 3 desafios técnicos)
- Os **títulos e ordem** das aulas do Nível Iniciante
- A **proposta** de cada módulo principal

Esse curso paralelo cobre os **mesmos temas** que o Java10x cobre, com Java moderno (JDK 21), didática estruturada e miniprojetos práticos. Se quiser ver o vídeo de um tema específico do Java10x, cada módulo aqui aponta quais aulas originais ele corresponde.

## Como usar

Cada módulo tem **três arquivos**:
1. **AULA.md** — teoria condensada com exemplos comentados. Leia primeiro.
2. **pratica/Main.java** — exercícios resolvidos com explicação.
3. **desafio/Main.java** — miniprojeto que junta tudo.

### Rodar (JDK 21 suporta arquivo único)
```bash
# Direto, sem compilar:
java curso-java/modulo-01-bem-vindo-intellij/pratica/Main.java

# Ou compilar e rodar:
cd curso-java/modulo-01-bem-vindo-intellij/pratica
javac Main.java && java Main
```

### Metodologia
- **Concreto antes do abstrato**: começa com código rodando, depois explica.
- **Prática ativa**: você escreve código em todo módulo.
- **Miniprojetos variados**: cada módulo tem um projeto temático.
- **Aproveitar o que você já sabe**: paralelos com Go quando útil.

## Ementa

### Fase 1 — Fundamentos
- **01 — Bem-vindo + IntelliJ**: JDK, IDE, primeiro programa, shortcuts essenciais. 🎯 *Hello World personalizado*
- **02 — Variáveis e Tipos**: primitivos (int, double, char, boolean), tipos referência, conversão. 🎯 *Calculadora de IMC*
- **03 — Condicionais**: if/else, switch, switch expression, ternário. 🎯 *Classificador de notas*
- **04 — Loops e Scanner**: for, while, do-while, leitura do teclado. 🎯 *Jogo de adivinhação*
- **05 — Arrays**: 1D, 2D, memória, garbage collector. 🎯 *Cadastro de ninjas em array*

### Fase 2 — Orientação a Objetos
- **06 — Classes e Objetos**: definir classe, campos, métodos. 🎯 *Sistema de personagens*
- **07 — Encapsulamento**: getters/setters, construtores, this. 🎯 *Conta bancária*
- **08 — Herança e Polimorfismo**: extends, super, sobrescrita. 🎯 *Hierarquia de funcionários*
- **09 — Abstração e Interfaces**: abstract class, interface, default methods. 🎯 *Notificações multi-canal*
- **10 — Exceções**: try/catch/finally, throw, throws, checked vs unchecked. 🎯 *Validador robusto*

### Fase 3 — Java Moderno
- **11 — Collections**: List, Set, Map, ArrayList, HashMap. 🎯 *Estatísticas de pedidos*
- **12 — Generics**: type parameters, bounded types. 🎯 *Caixa genérica reutilizável*
- **13 — Lambdas e Functional Interfaces**: Function, Predicate, Consumer. 🎯 *Filtros configuráveis*
- **14 — Streams API**: filter, map, reduce, collect. 🎯 *Análise de vendas*
- **15 — Java Moderno**: Optional, Records, sealed, pattern matching, switch expressions. 🎯 *Modelo refatorado*

### Fase 4 — Spring Boot e Aplicações Reais
- **16 — Maven e Estrutura de Projetos**: pom.xml, dependências, fases. 🎯 *Setup de projeto*
- **17 — Spring Boot Hello**: bootstrap via start.spring.io, application.properties. 🎯 *Primeira app Spring*
- **18 — REST API**: Controllers, DTOs, request/response. 🎯 *CRUD de tarefas em memória*
- **19 — JPA + Banco H2**: Entity, Repository, queries. 🎯 *Cadastro de ninjas com persistência*
- **20 — Validações, Exceções, Swagger**: @Valid, ControllerAdvice, OpenAPI. 🎯 *API completa documentada*

## Mapeamento com o Java10x

| Meu módulo | Aulas Java10x correspondentes |
|---|---|
| 01-02 | Nível Iniciante (Bem-vindo, IDE, atalhos, Variáveis, Primitivos) |
| 03-04 | Nível Iniciante (Condicionais, Switch, Ternários, Loops, Scanners) |
| 05 | Nível Iniciante (Arrays + GC + Multidimensionais + Desafios) |
| 06-10 | Nível Intermediário |
| 11-15 | Nível Intermediário (final) + Avançado (Streams) |
| 16-18 | Cadastro de Ninjas (SpringBoot + SQL) |
| 19 | Cadastro de Ninjas (JPA, H2, Migrations) |
| 20 | Desafio Itaú (Swagger) + Desafio Specifications (Exceptions) |

## Pré-requisitos
- **JDK 21** (já está instalado no seu ambiente, verifiquei)
- IDE recomendada: **IntelliJ IDEA Community** (gratuita, melhor experiência Java)

## Material de apoio
- Documentação oficial: https://docs.oracle.com/en/java/javase/21/
- Spring Boot: https://spring.io/projects/spring-boot
- Tutorial Spring: https://spring.io/guides

Bom estudo!
