# Módulo 18 — Standalone e Modern Angular

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar por que **Standalone** virou o padrão do Angular 17+ e o que isso elimina do mundo NgModule
- Configurar uma aplicação 100% standalone com `bootstrapApplication` e `app.config.ts`
- Usar **`@defer { ... }`** com triggers `on idle`, `on viewport`, `on hover`, `on interaction` e blocos `@loading`, `@placeholder`, `@error`
- Declarar variáveis no template com **`@let`** (Angular 18)
- Ativar **View Transitions API** no router com `withViewTransitions()`
- Habilitar **Hydration** pra SSR com `provideClientHydration()`
- Entender o que é **CSS isolation** (`encapsulation`) e quando trocar o modo

## 🧐 O contexto: por que "Modern Angular"?
Entre Angular 14 e 18, o time da Google reescreveu a forma como você monta uma aplicação. O objetivo era simples: **menos cerimônia, mais performance, curva mais suave**. Esse módulo é o passeio pelos recursos que **definem o Angular hoje** — coisas que tutoriais antigos não têm e que recrutador moderno vai cobrar.

Os 5 pilares que vamos ver:
1. **Standalone Components** (v14, padrão v17)
2. **`@defer`** — lazy loading declarativo no template (v17)
3. **`@let`** — variáveis no template (v18)
4. **View Transitions API** — animação automática entre rotas (v17)
5. **Hydration** + **CSS isolation** — refinos de produção

## 🆚 Mundo NgModule (legado) vs Standalone (atual)

### Antes — NgModule (Angular 2 até 16)
Cada componente, diretiva ou pipe precisava ser **declarado** dentro de um `@NgModule`. Os módulos importavam outros módulos. Boilerplate em todo lugar.

```typescript
// app.module.ts (LEGADO — não use mais)
@NgModule({
  declarations: [AppComponent, PokemonCardComponent],
  imports: [BrowserModule, FormsModule, HttpClientModule, RouterModule.forRoot(routes)],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {}
```

Problemas:
- 3 conceitos sobrepostos: módulo, componente, declaração
- Cada feature nova exigia criar ou alterar um módulo
- Tree-shaking pior (módulo arrasta o que não usa)
- Curva alta pra quem vinha de React/Vue

### Agora — Standalone (Angular 17+ é o padrão)
**Nada de `@NgModule`**. Cada componente é autossuficiente e declara seus próprios `imports`:

```typescript
// pokemon-card.component.ts
@Component({
  selector: 'app-pokemon-card',
  standalone: true,                          // 👈 a única novidade técnica
  imports: [CommonModule, RouterLink],       // 👈 importa direto o que usa
  templateUrl: './pokemon-card.component.html'
})
export class PokemonCardComponent {}
```

E o "módulo raiz" some também — vira o `app.config.ts`:

```typescript
// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),
  ]
};
```

E o bootstrap no `main.ts`:

```typescript
// main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig);
```

**Resumo da mudança mental:**
- `declarations` → não existe mais. Use diretamente.
- `imports` do módulo → `imports` do `@Component`.
- `providers` do módulo → `providers` no `app.config.ts` (ou no próprio componente).
- `RouterModule.forRoot(routes)` → `provideRouter(routes)`.
- `HttpClientModule` → `provideHttpClient()`.

> 💡 **Standalone não é "obrigatório"** — você ainda pode usar NgModule. Mas todo código novo deve ser standalone. Os próprios `ng generate component` já criam standalone por padrão desde a v17.

## 💤 `@defer { ... }` — lazy loading no template
Antes, lazy loading só funcionava por **rota** (`loadComponent`). Com `@defer`, qualquer pedaço do template pode ser **adiado** — só baixa quando precisar.

### Sintaxe básica
```html
@defer {
  <app-pokemon-detalhes-pesado />
}
```

Por padrão (sem trigger), o bloco carrega **quando o Angular acha que tá ocioso**. Mas o poder real tá nos **triggers**.

### Os 4 triggers principais

#### `on idle` (padrão se você não passar nada)
Carrega quando o navegador estiver ocioso (`requestIdleCallback`). Ótimo pra coisas "logo abaixo da dobra":

```html
@defer (on idle) {
  <app-grafico-estatisticas />
}
```

#### `on viewport` — quando entrar na tela
Usa `IntersectionObserver`. Perfeito pra imagens, gráficos ou cards que tão lá embaixo:

```html
@defer (on viewport) {
  <app-pokemon-detalhes-pesado />
}
```

#### `on hover` — quando o mouse passa por cima
Útil pra tooltips, previews:

```html
<button #botao>Ver detalhes</button>
@defer (on hover(trigger: botao)) {
  <app-card-preview />
}
```

#### `on interaction` — quando o usuário clica ou toca
Carrega só depois da primeira interação. Excelente pra modais, painéis:

```html
@defer (on interaction) {
  <app-painel-avancado />
}
```

> Existem outros: `on timer(3s)`, `on immediate`, `when condicao` (booleana), e dá pra combinar com `prefetch on hover` pra **baixar** antes mas **renderizar** depois.

### Os 3 blocos auxiliares

```html
@defer (on viewport) {
  <app-pokemon-detalhes-pesado />
} @placeholder (minimum 500ms) {
  <p>Em breve…</p>
} @loading (after 200ms; minimum 1s) {
  <p>Carregando detalhes pesados…</p>
} @error {
  <p>❌ Falhou em carregar o componente.</p>
}
```

- **`@placeholder`** — o que aparece **antes** do trigger disparar (ex: skeleton).
- **`@loading`** — enquanto o JS do componente tá baixando. `after 200ms` evita "flash" se vier rápido.
- **`@error`** — se o `import()` falhou (rede caiu, etc.).

> ⚠️ O componente referenciado dentro do `@defer` precisa ser **standalone** e **só** ser usado dentro de blocos `@defer`. Se você usar o mesmo componente fora também, o Angular avisa em compile-time que o defer não vai "deferir nada" (já tá no bundle inicial).

## 🪶 `@let` — variáveis no template (Angular 18)
Até a v17, pra "guardar" um valor calculado no template você precisava de `*ngIf="expr as nome"`, getters na classe, ou pipes esquisitos. A v18 trouxe `@let`:

```html
@let nomeFormatado = pokemon.name | titlecase;
@let totalTipos = pokemon.types.length;

<h2>{{ nomeFormatado }}</h2>
<p>Tem {{ totalTipos }} tipo(s).</p>

@if (totalTipos > 1) {
  <span>Pokémon multi-tipo!</span>
}
```

Regras:
- Escopo é o **bloco** onde foi declarado (igual `let` do JS).
- É **read-only** — não dá pra reatribuir (`@let x = 1; x = 2` ❌).
- Reage ao change detection — se `pokemon.name` muda, `nomeFormatado` recalcula.

Casos de uso típicos:
- Encurtar expressões longas usadas várias vezes no template
- Substituir getters bobos na classe
- Deixar o template mais legível sem poluir a classe

## ✨ View Transitions API — `withViewTransitions()`
A **View Transitions API** é uma feature do navegador (Chrome 111+, Safari 18+) que faz **animação automática** entre dois estados da página. O Angular Router se integra com ela em uma linha:

```typescript
// app.config.ts
import { provideRouter, withViewTransitions } from '@angular/router';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes, withViewTransitions()),
  ]
};
```

Pronto. Cada navegação entre rotas vira uma **transição suave** (fade cruzado por padrão). Sem instalar nada, sem `@HostBinding`, sem GSAP.

Em navegadores que não suportam, **funciona normal** — degradação silenciosa. Dá pra customizar via CSS:

```css
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 400ms;
}
```

> 💡 Pra animar **um elemento específico** entre páginas (ex: a imagem do card vira a imagem grande na tela de detalhe), basta dar o mesmo `view-transition-name` no CSS dos dois.

## 💧 Hydration — `provideClientHydration()`
Quando seu app usa **SSR** (Server-Side Rendering), o servidor manda HTML pronto e o navegador "revive" essa árvore com a JS do Angular. Esse processo é a **hidratação**.

Sem hydration, o Angular **destruía** o DOM do servidor e renderizava de novo — flicker visível, péssimo pra performance e SEO.

Com hydration:

```typescript
// app.config.ts
import { provideClientHydration } from '@angular/platform-browser';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideClientHydration(),    // 👈 reaproveita o DOM do SSR
  ]
};
```

O Angular **reaproveita** os nós que o servidor já criou. Resultado: zero flicker, First Contentful Paint mais rápido, listeners conectados onde já estava renderizado.

> ℹ️ Hydration só faz sentido se você ativou SSR no `ng new` (ou via `ng add @angular/ssr`). Em SPA pura, não muda nada — mas também não atrapalha.

## 🎨 CSS Isolation — `encapsulation`
Por padrão, **CSS de componente não vaza pra fora**. Isso é **ViewEncapsulation.Emulated** — o Angular adiciona atributos únicos (`_ngcontent-xyz`) nos elementos e prefixa as regras CSS.

```typescript
import { Component, ViewEncapsulation } from '@angular/core';

@Component({
  selector: 'app-card',
  standalone: true,
  encapsulation: ViewEncapsulation.Emulated,  // 👈 padrão
  styles: [`h1 { color: red; }`],              // só afeta h1 DESSE componente
  template: `<h1>oi</h1>`
})
```

Os 3 modos:
| Modo | O que faz | Quando usar |
|------|-----------|-------------|
| **`Emulated`** *(padrão)* | Escopa CSS via atributos. Não usa Shadow DOM real, só emula. | 99% dos casos. |
| **`None`** | Estilos vazam pra **toda a aplicação**. | Estilos globais (cuidado!). |
| **`ShadowDom`** | Usa Shadow DOM nativo do navegador — isolamento total. | Web components, libs que precisam não ser afetadas. |

**Conceito-chave**: o `:host` seleciona o **próprio elemento** do componente:

```css
:host {
  display: block;
  border: 1px solid #ccc;
}

:host(.destaque) {
  border-color: gold;
}
```

E o `::ng-deep` (deprecated mas ainda funciona) força um estilo a vazar pra filhos. **Evite** — use classes globais em `styles.css` se precisar.

## 🧠 Mental model rápido

```
┌────────────────────────────────────────────────────┐
│  Standalone  =  componente autossuficiente         │
│  @defer      =  lazy load no meio do template      │
│  @let        =  let do JS, mas no HTML             │
│  View Trans. =  animação grátis entre rotas        │
│  Hydration   =  SSR sem flicker                    │
│  Encapsulat. =  CSS isolado por padrão             │
└────────────────────────────────────────────────────┘
```

## 🆚 Tabela resumo: Angular antigo vs moderno

| Conceito | Antigo (até v16) | Moderno (v17+) |
|----------|------------------|----------------|
| Bootstrap | `AppModule` + `platformBrowserDynamic` | `bootstrapApplication(AppComponent, appConfig)` |
| Componente | declarado em `NgModule` | `standalone: true` + `imports: []` |
| Router | `RouterModule.forRoot(routes)` | `provideRouter(routes)` |
| HTTP | `HttpClientModule` | `provideHttpClient()` |
| Lazy de componente | só por rota | `@defer` em qualquer ponto do template |
| Variável no template | getter na classe / `*ngIf as` | `@let` |
| Transição entre rotas | bibliotecas externas | `withViewTransitions()` |
| SSR sem flicker | hack | `provideClientHydration()` |

## 🚦 Próximos passos
1. **Pratica**: Pokedex 100% standalone com `app.config.ts` + um card que carrega um componente "pesado" só quando entra na tela (`@defer (on viewport)`).
2. **Desafio**: Pokedex completa com rotas, view transitions, `@defer` num painel de stats, `@let` simplificando templates.

## ✅ Auto-verificação
- [ ] Sei explicar por que standalone substituiu NgModule
- [ ] Sei montar um `app.config.ts` com `provideRouter` + `provideHttpClient`
- [ ] Sei os 4 triggers principais do `@defer` e quando usar cada um
- [ ] Sei os 3 blocos auxiliares (`@placeholder`, `@loading`, `@error`)
- [ ] Sei usar `@let` pra encurtar templates
- [ ] Sei o que `withViewTransitions()` faz e onde plugar
- [ ] Sei a diferença entre os 3 modos de `encapsulation`

Próximo módulo: **Estado Global** — como compartilhar dados entre componentes irmãos sem virar bagunça (services com signals, NgRx, etc.).
