# Curso de Go — do Básico ao Avançado

> Curso estruturado para aprender Go de forma sólida, mesclando teoria curta com prática constante e miniprojetos por módulo.

## Como usar este curso

Cada módulo tem **três arquivos**:

1. **AULA.md** — teoria condensada com exemplos comentados. Leia primeiro.
2. **pratica/main.go** — exercícios resolvidos com explicação. Estude o código e tente reescrever sem olhar.
3. **desafio/main.go** — miniprojeto que junta tudo. Tente terminar sozinho antes de olhar a solução comentada no final.

### Metodologia
- **Concreto antes do abstrato**: começamos com código que funciona; só depois generalizamos.
- **Prática ativa**: você escreve código em todo módulo, não só lê.
- **Espiral**: conceitos antigos voltam em contextos novos — repetição com variação cria domínio.
- **Projetos por módulo**: cada módulo tem um miniprojeto diferente (calculadora, jogo, lista, scraper, API, etc).

### Ordem sugerida em cada módulo
1. Ler **AULA.md** uma vez (15-20 min)
2. Rodar `pratica/main.go` e ler com calma (20-30 min)
3. Tentar reescrever a `pratica` num arquivo separado, do zero
4. Encarar o **desafio** sem olhar a solução
5. Comparar com a solução comentada

## Ementa

### Fase 1 — Fundamentos
- **01 — Bem-vindo ao Go**: Hello World, ferramentas (`go run`, `go build`, `go fmt`). 🎯 *Projeto: cartão de visitas*
- **02 — Tipos e Variáveis**: tipos básicos, declarações, conversões. 🎯 *Projeto: calculadora de IMC*
- **03 — Controle de Fluxo**: if/else, switch, for. 🎯 *Projeto: jogo de adivinhação*
- **04 — Funções**: parâmetros, retornos múltiplos, closures, variádicos. 🎯 *Projeto: calculadora modular*
- **05 — Coleções**: arrays, slices, maps, range. 🎯 *Projeto: gerenciador de tarefas em memória*

### Fase 2 — Estruturação
- **06 — Structs e Métodos**: tipos compostos, métodos, receivers. 🎯 *Projeto: sistema bancário*
- **07 — Interfaces**: contratos, polimorfismo, type assertion. 🎯 *Projeto: sistema de notificações*
- **08 — Erros**: `error`, wrapping, panic/recover. 🎯 *Projeto: validador de cadastro*
- **09 — Ponteiros**: endereços, modificação por referência. 🎯 *Projeto: lista encadeada*
- **10 — Pacotes**: organização, exportação, módulos. 🎯 *Projeto: biblioteca de utilitários*

### Fase 3 — Aplicações
- **11 — Arquivos e I/O**: ler/escrever arquivos, `io.Reader`/`io.Writer`. 🎯 *Projeto: contador de palavras*
- **12 — Goroutines**: concorrência básica. 🎯 *Projeto: downloader paralelo simulado*
- **13 — Channels e Sync**: comunicação entre goroutines, `sync`. 🎯 *Projeto: pipeline de processamento*
- **14 — HTTP Cliente**: consumir APIs externas. 🎯 *Projeto: consultor de CEP*
- **15 — HTTP Servidor**: criar APIs próprias. 🎯 *Projeto: API de saudação*

### Fase 4 — Avançado
- **16 — JSON e Banco de Dados**: serialização, `database/sql`. 🎯 *Projeto: CRUD de tarefas com SQLite*
- **17 — Testes**: `testing`, table-driven tests, mocks. 🎯 *Projeto: testando o CRUD*
- **18 — Generics e Padrões Modernos**: type parameters, padrões idiomáticos. 🎯 *Projeto: biblioteca utilitária genérica*

## Pré-requisitos
- Go instalado (verifique com `go version` — recomendado 1.21+)
- Editor com suporte a Go (VS Code com extensão Go funciona bem)

## Material de apoio
- [aulas/](../aulas/) — referência teórica detalhada por tópico da spec
- [aulas/avancado/](../aulas/avancado/) — material avançado (generics, concorrência, context, etc)
- [execicios/](../execicios/) — banco de exercícios extras
- Spec oficial: https://go.dev/ref/spec

## Como rodar
Cada arquivo é uma pasta com seu próprio `main.go`:

```bash
go run ./curso/modulo-01-bem-vindo/pratica
go run ./curso/modulo-01-bem-vindo/desafio
```

Bom estudo!
