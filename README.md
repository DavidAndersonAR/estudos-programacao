# Estudos de Programação

> Material de estudo estruturado em cursos modulares, sempre em português, com teoria curta + prática constante + miniprojetos por módulo.

## Cursos disponíveis

| Curso | Foco | Módulos | Caminho |
|---|---|---|---|
| 🐹 **Go** | Linguagem Go do zero ao avançado | 18 | [`curso/`](curso/) |
| ☕ **Java** | Java moderno (JDK 21), do básico até Spring Boot | 20 | [`curso-java/`](curso-java/) |
| 🅰️ **TypeScript + Angular** | TS standalone + Angular 17+ + projeto Pokedex | 20 | [`curso-typescript-angular/`](curso-typescript-angular/) |
| 🐘 **PostgreSQL** | SQL e admin do básico até particionamento/replicação | 20 | [`curso-postgresql/`](curso-postgresql/) |
| 🐳 **Docker + Kubernetes** | Em breve | — | `curso-docker-kubernetes/` |
| 🚀 **Quarkus** | Em breve | — | `curso-quarkus/` |

Cada curso tem seu próprio `README.md` com a ementa completa e instruções de setup.

## Conteúdo extra (Go)
Antes dos cursos estruturados, o repo guarda também o material original de estudo de Go:
- [`aulas/`](aulas/) — notas teóricas sobre cada seção da spec de Go (tipos, expressões, statements, etc) + tópicos avançados (generics, channels, context, sync, io.Reader/Writer)
- [`execicios/`](execicios/) — exercícios práticos básicos e avançados

## Metodologia

Cada **módulo** de cada curso tem 3 arquivos principais:
1. **`AULA.md`** — teoria condensada com exemplos comentados (15-20 min de leitura)
2. **`pratica/`** — exercícios resolvidos para estudar e tentar reescrever do zero
3. **`desafio/`** — miniprojeto temático: enunciado + TODOs + solução comentada no fim

Como passar por um módulo:
1. Ler `AULA.md` uma vez
2. Rodar e estudar a `pratica/`
3. Tentar reescrever a `pratica/` sem olhar
4. Encarar o `desafio/` sem olhar a solução
5. Comparar com a solução de referência

## Como rodar

Cada curso tem instruções específicas no seu README. Resumo:

- **Go**: `go run ./curso/modulo-01-bem-vindo/pratica`
- **Java**: `java curso-java/modulo-01-bem-vindo-intellij/pratica/Main.java`
- **TypeScript**: `npx tsx curso-typescript-angular/modulo-01-bem-vindo-typescript/pratica/main.ts`
- **Angular**: criar projeto com `ng new` e copiar componentes do módulo correspondente
- **PostgreSQL**: subir Postgres via Docker, carregar schema e seed do Módulo 01

## Sobre

Cursos criados com auxílio de IA para acelerar o aprendizado e ter referência sempre à mão.

Bom estudo!
