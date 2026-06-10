# Módulo 10 — Componentes e Templates

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Criar um componente Angular do zero (`ng generate component`)
- Entender o decorator `@Component` e suas opções
- Usar **interpolation**, **property binding**, **event binding** e **two-way binding**
- Comunicar componentes com `@Input()` e `@Output()`
- Usar o novo control flow (`@if`, `@for`) e a sintaxe antiga (`*ngIf`, `*ngFor`)
- Aplicar pipes built-in (`uppercase`, `currency`, `date`, `slice`)

## 🧱 O que é um componente?
No Angular, **componente** é a unidade básica da UI. Cada pedaço da tela (header, card, botão, formulário) costuma ser um componente. Um componente é a junção de **três coisas**:

1. **Classe TypeScript** — a lógica e o estado
2. **Template HTML** — a estrutura visual
3. **Estilos CSS** — a aparência

E tudo isso fica **encapsulado** num decorator chamado `@Component`.

## ⚙️ Criando um componente
A CLI do Angular faz o trabalho chato:

```bash
ng generate component pokemon-card
# ou abreviado:
ng g c pokemon-card
```

Isso cria 4 arquivos (em projetos não-standalone) ou só 3 (standalone):
```
pokemon-card/
├── pokemon-card.component.ts      ← classe + decorator
├── pokemon-card.component.html    ← template
├── pokemon-card.component.css     ← estilos
└── pokemon-card.component.spec.ts ← testes (opcional)
```

## 🎨 O decorator @Component
É o "carimbo" que transforma uma classe TS num componente Angular:

```typescript
import { Component } from '@angular/core';

@Component({
    selector: 'app-pokemon-card',
    standalone: true,
    templateUrl: './pokemon-card.component.html',
    styleUrls: ['./pokemon-card.component.css']
})
export class PokemonCardComponent {
    // lógica aqui
}
```

### As 4 opções essenciais
- **`selector`**: o nome da tag HTML que vai representar esse componente. Use `app-` como prefixo pra evitar conflito com tags nativas.
- **`standalone`**: `true` significa que o componente não precisa de NgModule (padrão moderno desde Angular 17+).
- **`templateUrl`** *(ou `template`)*: aponta pro HTML em arquivo separado. Use `template: '<h1>oi</h1>'` pra inline (só pra coisas pequenas).
- **`styleUrls`** *(ou `styles`)*: aponta pros arquivos CSS. Use `styles: ['h1 { color: red }']` pra inline.

**Regra prática**: arquivo separado pra qualquer coisa que passe de 5 linhas.

## 🏷️ Selector = tag custom
Depois de criar o componente com `selector: 'app-pokemon-card'`, você o usa em qualquer template assim:

```html
<app-pokemon-card></app-pokemon-card>
```

É como inventar uma tag HTML nova. O Angular substitui isso pelo template do componente em runtime.

## 🔥 Os 4 tipos de binding
Toda a "mágica" do Angular tá em entender as **4 formas de conectar a classe ao template**:

### 1. Interpolation — `{{ }}` (classe → template, texto)
Mostra valores como **texto**:

```html
<h1>Olá, {{ nome }}!</h1>
<p>{{ 2 + 2 }}</p>
<p>{{ pokemon.name.toUpperCase() }}</p>
```

Funciona pra qualquer expressão que vire string.

### 2. Property binding — `[propriedade]` (classe → template, atributo)
Liga uma propriedade da classe a um **atributo HTML**:

```html
<img [src]="pokemon.imageUrl" [alt]="pokemon.name">
<button [disabled]="carregando">Enviar</button>
<div [class.ativo]="estaAtivo">Card</div>
```

**Diferença pra interpolation**: `[src]="url"` passa o valor da variável `url`. Sem colchetes (`src="url"`) passa a string literal `"url"`.

### 3. Event binding — `(evento)` (template → classe)
Escuta eventos do DOM e chama método da classe:

```html
<button (click)="favoritar()">⭐</button>
<input (input)="aoDigitar($event)">
<form (submit)="salvar()">...</form>
```

O `$event` é o objeto do evento (mouse, keyboard, etc.).

### 4. Two-way binding — `[(ngModel)]` (template ↔ classe)
"Banana in a box" `[()]`: combina property + event num único atalho. Muito usado em formulários:

```html
<input [(ngModel)]="nome">
<p>Você digitou: {{ nome }}</p>
```

**⚠️ Requer importar `FormsModule`** no componente:

```typescript
import { FormsModule } from '@angular/forms';

@Component({
    standalone: true,
    imports: [FormsModule],
    // ...
})
```

Sem isso, dá erro: `Can't bind to 'ngModel' since it isn't a known property of 'input'`.

## 📥 @Input() — receber dados do pai
Pra um componente filho receber dados de um pai, use `@Input()`:

```typescript
import { Component, Input } from '@angular/core';

@Component({ /* ... */ })
export class PokemonCardComponent {
    @Input() pokemon!: { id: number; name: string; types: string[] };
    @Input() destaque: boolean = false;
}
```

No pai, você passa via property binding:

```html
<app-pokemon-card [pokemon]="meuPokemon" [destaque]="true"></app-pokemon-card>
```

O `!` no `@Input() pokemon!:` é o **definite assignment assertion** — você promete ao TS que o valor vai chegar (pelo pai), apesar de não ter inicializador.

## 📤 @Output() — enviar eventos pro pai
O caminho contrário: o filho avisa o pai que algo aconteceu, com `@Output()` + `EventEmitter`:

```typescript
import { Component, Output, EventEmitter } from '@angular/core';

@Component({ /* ... */ })
export class PokemonCardComponent {
    @Output() favorito = new EventEmitter<number>();

    aoFavoritar(id: number): void {
        this.favorito.emit(id);
    }
}
```

No pai, escuta com event binding:

```html
<app-pokemon-card (favorito)="quandoFavoritar($event)"></app-pokemon-card>
```

O `$event` aqui é o valor emitido pelo `emit()` (no caso, o `id: number`).

**Resumo da comunicação**:
- Pai → filho: `@Input()` + `[prop]="valor"`
- Filho → pai: `@Output()` + `(evento)="metodo($event)"`

## 🔀 Novo control flow (Angular 17+)
Desde a v17, o Angular tem **sintaxe nova** pra condicionais e loops, integrada na linguagem do template. É mais limpa e mais rápida.

### @if / @else
```html
@if (pokemon.types.length > 0) {
    <p>Tem tipos!</p>
} @else if (pokemon.id < 100) {
    <p>Pokémon antigo sem tipo.</p>
} @else {
    <p>Sem tipos.</p>
}
```

### @for (sempre com `track`)
```html
@for (tipo of pokemon.types; track tipo) {
    <span class="type">{{ tipo }}</span>
} @empty {
    <p>Sem tipos.</p>
}
```

O `track` diz ao Angular como identificar cada item (pra otimizar re-renderização). Use o ID quando tiver, ou o próprio valor pra strings/numbers.

### @switch
```html
@switch (pokemon.types[0]) {
    @case ('fire')  { <p>🔥</p> }
    @case ('water') { <p>💧</p> }
    @default        { <p>❓</p> }
}
```

## 📜 Sintaxe antiga: *ngIf / *ngFor
Antes da v17 (e ainda funcional), usava-se **diretivas estruturais** com asterisco:

```html
<p *ngIf="pokemon.types.length > 0">Tem tipos!</p>

<span *ngFor="let tipo of pokemon.types; trackBy: trackByName">
    {{ tipo }}
</span>
```

Pra usar `*ngIf` e `*ngFor` em componente standalone, importe `CommonModule`:

```typescript
import { CommonModule } from '@angular/common';

@Component({
    standalone: true,
    imports: [CommonModule],
    // ...
})
```

**Qual usar?** Pra código novo, **sempre `@if`/`@for`**. A sintaxe antiga você vai encontrar em projetos legados.

## 🚿 Pipes built-in
Pipes transformam valores **no template** com a sintaxe `valor | pipe`:

```html
<!-- uppercase / lowercase / titlecase -->
<p>{{ pokemon.name | uppercase }}</p>          <!-- BULBASAUR -->
<p>{{ pokemon.name | lowercase }}</p>          <!-- bulbasaur -->
<p>{{ pokemon.name | titlecase }}</p>          <!-- Bulbasaur -->

<!-- currency -->
<p>{{ 9.9 | currency:'BRL' }}</p>              <!-- R$9.90 -->

<!-- date -->
<p>{{ hoje | date:'dd/MM/yyyy' }}</p>          <!-- 09/06/2026 -->

<!-- slice — pega pedaço de string/array -->
<p>{{ pokemon.name | slice:0:3 }}</p>          <!-- Bul -->

<!-- número decimal -->
<p>{{ 3.14159 | number:'1.0-2' }}</p>          <!-- 3.14 -->

<!-- json — ótimo pra debugar -->
<pre>{{ pokemon | json }}</pre>
```

Pipes podem ser **encadeados**:
```html
<p>{{ pokemon.name | slice:0:3 | uppercase }}</p>  <!-- BUL -->
```

Pra usar pipes em standalone, normalmente já vêm no `CommonModule`, mas alguns (como `uppercase`, `slice`) podem ser importados isolados:
```typescript
import { UpperCasePipe, SlicePipe } from '@angular/common';
```

## 🧠 Mental model rápido
```
┌──────────────────────────────────────────────┐
│ COMPONENTE = Classe TS + Template HTML + CSS │
└──────────────────────────────────────────────┘

  Classe ──[interpolation {{}} / property [x]]──► Template
  Classe ◄──────[event binding (x)]──────────── Template
  Classe ◄─────[two-way [(ngModel)]]───────────► Template

  Pai ──[@Input + [prop]]──► Filho
  Pai ◄──[@Output + (evt)]── Filho
```

## 🚦 Próximos passos
1. Abra a `pratica/` e estude o `PokemonCard` simples — entenda cada binding.
2. Encare o **desafio**: card completo com imagem, gradiente por tipo, favorito persistido.

## ✅ Auto-verificação
- [ ] Sei os 4 tipos de binding e quando usar cada um
- [ ] Sei diferença entre `@Input` e `@Output`
- [ ] Sei usar `@if`/`@for` (novo) e `*ngIf`/`*ngFor` (antigo)
- [ ] Sei aplicar pipes e encadear vários
- [ ] Sei o que `standalone: true` muda

Próximo módulo: **Services e Dependency Injection** — onde sai a lógica que não pertence ao componente.
