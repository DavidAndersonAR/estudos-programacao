# Módulo 11 — Services e Dependency Injection

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é um **Service** e por que separar lógica da UI
- Criar um service com `@Injectable({ providedIn: 'root' })`
- Injetar dependências de **duas formas**: constructor injection e `inject()`
- Entender o escopo de providers (root, component, lazy module)
- Saber o que são **DI tokens** (panorama)

## 🧐 O que é um Service?
Um **Service** é uma classe TypeScript com uma responsabilidade bem definida — buscar dados, fazer cálculos, logar, autenticar — **fora** dos componentes.

Por que separar?
- **Componente cuida da UI** (template, eventos, estado de tela).
- **Service cuida da lógica** (dados, regras, integrações).
- **Reuso**: o mesmo service pode ser injetado em 10 componentes diferentes.
- **Testabilidade**: testar lógica pura é mais fácil que testar componente inteiro.

Regra prática: se a função **não mexe com o DOM nem com `@Input/@Output`**, ela provavelmente pertence a um service.

## 🏷️ O decorator `@Injectable`
Marca uma classe como **injetável** pelo sistema de DI do Angular:

```typescript
import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class LogService {
    log(msg: string): void {
        console.log('[LOG]', msg);
    }
}
```

Sem `@Injectable`, o Angular não sabe como criar instâncias dessa classe.

## 🌳 `providedIn: 'root'` — singleton de app
A configuração mais comum. Significa:
- O Angular cria **uma única instância** desse service para a aplicação inteira.
- Qualquer componente que pedir, recebe **a mesma instância**.
- É **tree-shakable**: se ninguém injeta, o service nem entra no bundle.

```typescript
@Injectable({ providedIn: 'root' }) // 👈 singleton global
export class PokemonService { /* ... */ }
```

Outros escopos (vamos ver mais tarde):
- `providedIn: 'platform'` — compartilhado entre múltiplas apps Angular na mesma página.
- `providedIn: 'any'` — uma instância por lazy module.
- Declarado em `providers: []` do componente — **nova instância** por componente.

## 🛠️ Criando com a CLI
```bash
ng generate service pokemon
# ou abreviado:
ng g s pokemon
```

Isso gera `pokemon.service.ts` já com `@Injectable({ providedIn: 'root' })` e um `.spec.ts` de teste.

## 💉 Dependency Injection — o que é?
**DI** é um padrão: em vez de a classe criar suas dependências, **alguém entrega prontas**. No Angular, esse "alguém" é o **Injector**.

Sem DI (ruim):
```typescript
class HomeComponent {
    private pokemons = new PokemonService(); // 👎 acoplado, difícil de testar
}
```

Com DI (Angular):
```typescript
class HomeComponent {
    constructor(private pokemons: PokemonService) {} // 👍 Angular entrega
}
```

Você só **declara o que precisa**. O Angular olha o tipo, busca a instância no injector, e passa.

## 🧪 Forma 1 — Constructor injection (clássica)
```typescript
import { Component } from '@angular/core';
import { PokemonService } from './pokemon.service';

@Component({ /* ... */ })
export class HomeComponent {
    constructor(private pokemons: PokemonService) {}

    listar() {
        return this.pokemons.listar();
    }
}
```

O `private` faz o TS automaticamente criar a propriedade `this.pokemons`.

## ⚡ Forma 2 — `inject()` (Angular 14+, moderna)
```typescript
import { Component, inject } from '@angular/core';
import { PokemonService } from './pokemon.service';

@Component({ /* ... */ })
export class HomeComponent {
    private pokemons = inject(PokemonService); // 👈 sem constructor

    listar() {
        return this.pokemons.listar();
    }
}
```

Vantagens do `inject()`:
- Funciona fora de constructor (em factories, guards funcionais, route resolvers).
- Compõe melhor com herança.
- Padrão recomendado em projetos novos (standalone components, Angular 17+).

**Você pode usar as duas.** Vamos preferir `inject()` daqui pra frente.

## 🗺️ Escopo de providers — visual

```
┌──────────────────────────────────────────────┐
│  providedIn: 'root'  →  1 instância p/ app   │
└──────────────────────────────────────────────┘
┌──────────────────────────────────────────────┐
│  providers: [] no componente                 │
│   → 1 instância por componente               │
└──────────────────────────────────────────────┘
┌──────────────────────────────────────────────┐
│  providers: [] em lazy module                │
│   → 1 instância por lazy module              │
└──────────────────────────────────────────────┘
```

Quase sempre você quer `'root'`. Use providers locais quando precisar de **estado isolado por componente** (raro no início).

## 🎫 DI tokens — intro
Até aqui, injetamos **classes** (o token é a própria classe). Mas o injector aceita qualquer token:

```typescript
import { InjectionToken } from '@angular/core';

export const API_URL = new InjectionToken<string>('API_URL');

// no bootstrap:
{ provide: API_URL, useValue: 'https://pokeapi.co/api/v2' }

// no service:
private apiUrl = inject(API_URL);
```

Útil pra injetar **valores de configuração** (URLs, flags) sem precisar criar uma classe.

Vamos aprofundar nos módulos de HTTP e arquitetura.

## 🚦 Próximos passos
1. Abra `pratica/pokemon.service.ts` — entenda o `@Injectable`.
2. Veja `pratica/app.component.ts` — observe o `inject()` em ação.
3. Encare o **desafio**: PokemonService completo com `listar`, `buscarPorId` e `filtrarPorTipo`.

## ✅ Auto-verificação
- [ ] Sei explicar pra que serve um Service
- [ ] Sei o que faz `@Injectable({ providedIn: 'root' })`
- [ ] Sei injetar um service de duas formas (constructor e `inject()`)
- [ ] Sei a diferença entre singleton de app e provider por componente
- [ ] Tenho uma noção do que é um DI token

Próximo módulo: **Routing** — navegação entre páginas no Angular.
