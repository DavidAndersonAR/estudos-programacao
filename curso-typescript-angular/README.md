# Curso de TypeScript + Angular

> Mesmo padrão dos cursos de [Go](../curso/README.md) e [Java](../curso-java/README.md): teoria curta, prática constante, miniprojeto por módulo. Ao final, você terá construído um **Pokedex completo em Angular** usando a [PokeAPI](https://pokeapi.co).

## Estrutura

20 módulos divididos em 4 fases:

### Fase 1 — TypeScript Fundamentos (módulos 1-8)
TS standalone. Cada módulo tem **miniprojeto variado** (calculadora, validador, jogo, etc).

### Fase 2 — Angular Fundamentos (módulos 9-13)
Componentes, templates, services, routing, forms. **Começamos o Pokedex** aqui.

### Fase 3 — Angular Real World (módulos 14-18)
HTTP, RxJS, Signals, Guards. **Pokedex ganha features de verdade**.

### Fase 4 — Projeto Final (módulos 19-20)
Estado global e deploy. **Pokedex profissional, pronto pra produção**.

## Como usar

Cada módulo tem **três arquivos**:
1. **AULA.md** — teoria condensada com exemplos.
2. **pratica/main.ts** (ou pasta com componente Angular) — exercícios resolvidos.
3. **desafio/main.ts** (ou pasta com solução) — miniprojeto.

### Rodar código TypeScript
A forma mais simples é usar `tsx` (executa TS direto, sem compilar separado):

```bash
npx tsx curso-typescript-angular/modulo-01-bem-vindo-typescript/pratica/main.ts
```

Da primeira vez baixa o `tsx`; depois fica em cache.

Alternativa: compilar e rodar:
```bash
npx tsc --target es2022 --module nodenext arquivo.ts && node arquivo.js
```

### Rodar Angular
Os módulos Angular mostram o código completo em comentários e arquivos exemplo. Pra rodar de verdade, você precisa criar um projeto Angular:

```bash
npm install -g @angular/cli@latest
ng new pokedex --standalone --routing --style=css
cd pokedex
ng serve
```

Cada módulo Angular tem `pratica/` e `desafio/` com **componentes prontos pra copiar** para `src/app/` do seu projeto.

## Ementa

### Fase 1 — TypeScript
- **01 — Bem-vindo ao TypeScript** — por que TS, setup, `tsc`, `tsx`. 🎯 *Hello world tipado*
- **02 — Tipos Básicos** — number/string/boolean/array/tuple/enum/any/unknown. 🎯 *Validador de formulário simples*
- **03 — Tipos Avançados** — union, intersection, literal, narrowing, type guards. 🎯 *Sistema de status com discriminated union*
- **04 — Interfaces e Type Aliases** — definir formatos, extends, optional/readonly. 🎯 *Modelagem de pedido*
- **05 — Funções em TS** — parâmetros opcionais/default/rest, overloads, this. 🎯 *Biblioteca de utilitários tipados*
- **06 — Classes em TS** — modificadores, abstract, implements, parameter properties. 🎯 *Sistema de personagens RPG*
- **07 — Generics** — type parameters, constraints, defaults. 🎯 *Container genérico reutilizável*
- **08 — Utility Types + Decorators** — Partial/Pick/Omit/Record/ReturnType + intro a decorators. 🎯 *Refatoração com utility types*

### Fase 2 — Angular Fundamentos
- **09 — Bem-vindo ao Angular** — CLI, estrutura, primeira app standalone. 🎯 *Tela inicial do Pokedex*
- **10 — Componentes e Templates** — input/output, control flow `@if`/`@for`, pipes. 🎯 *Card de Pokémon*
- **11 — Services e DI** — providers, injeção, escopo. 🎯 *Service de dados mockados*
- **12 — Routing** — rotas, params, lazy loading. 🎯 *Lista + detalhe do Pokémon*
- **13 — Forms** — template-driven e reactive, validações. 🎯 *Formulário de busca/filtros*

### Fase 3 — Angular Real World
- **14 — HTTP e Observables** — HttpClient, Observable, async pipe. 🎯 *Conectar Pokedex à PokeAPI*
- **15 — RxJS Essencial** — map/filter/switchMap/debounceTime/catchError. 🎯 *Busca com debounce*
- **16 — Signals** — signals, computed, effect (Angular 17+). 🎯 *Estado reativo com signals*
- **17 — Guards e Interceptors** — proteção de rotas, interceptors HTTP. 🎯 *Autenticação simulada + loading global*
- **18 — Standalone e Modern Angular** — sem NgModule, defer, view transitions. 🎯 *Pokedex 100% standalone*

### Fase 4 — Projeto Final
- **19 — Estado Global** — service singleton com signals, padrões de estado. 🎯 *Favoritos persistentes*
- **20 — Build, Deploy e Boas Práticas** — build de produção, lazy chunks, deploy estático. 🎯 *Pokedex publicado*

## Pré-requisitos
- **Node.js 20+** (você tem 22 ✅)
- **npm 10+** (você tem 10.9 ✅)
- VS Code com extensões Angular Language Service e ESLint recomendadas

## Material de apoio
- TypeScript handbook: https://www.typescriptlang.org/docs/handbook/intro.html
- Angular docs (sempre versão mais nova): https://angular.dev
- PokeAPI: https://pokeapi.co/docs/v2
- RxJS: https://rxjs.dev

Bom estudo!
