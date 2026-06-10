# Módulo 16 — Signals

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar **o que é um Signal** e por que ele mudou o jogo no Angular
- Criar signals com `signal(valor)` e ler/escrever com `()`, `.set()` e `.update()`
- Derivar estado com `computed()` e disparar efeitos colaterais com `effect()`
- Usar `toSignal()` e `toObservable()` pra conversar com **RxJS** (interop)
- Compartilhar estado entre componentes via **service com signals**
- Usar **`input()` signal** e **`output()` signal** (Angular 17.3+) nos componentes
- Comparar Signals com `BehaviorSubject` e saber **quando usar cada um**

## 🧐 O que é um Signal?
Um **Signal** é um **valor reativo encapsulado**: você guarda algo dentro dele, e qualquer parte do app que **lê** esse valor passa a "saber" quando ele muda — sem precisar de `Subject`, `Observable`, `Subscription`, nem `ngOnDestroy`.

Pense num Signal como uma "**caixa que avisa**":
- Você lê com `caixa()` — sintaxe de função.
- Você muda com `caixa.set(novo)` ou `caixa.update(fn)`.
- Quem dependia desse valor (template, `computed`, `effect`) **reage automaticamente**.

Foi introduzido em **Angular 16** (preview) e estabilizado em **Angular 17**. É a base do **futuro sem `Zone.js`** — o famoso "zoneless".

Por que isso importa?
- **Granularidade**: só re-renderiza o que **realmente** depende daquele signal. Antes, o Angular checava a árvore inteira.
- **Performance**: bundle menor (sem Zone), atualizações mais rápidas.
- **Mental model mais simples**: estado é um valor — não um stream de eventos.
- **Menos boilerplate**: cabou o `subscribe`/`unsubscribe` pra estado interno.

## 🆚 Antes vs depois (mental model)

```typescript
// Antes — com BehaviorSubject (RxJS)
import { BehaviorSubject } from 'rxjs';

export class ContadorService {
    private _total$ = new BehaviorSubject<number>(0);
    total$ = this._total$.asObservable();

    incrementar() {
        this._total$.next(this._total$.value + 1);
    }
}

// No componente precisava: async pipe OU subscribe + unsubscribe manual.
```

```typescript
// Depois — com Signal (Angular 16+)
import { signal } from '@angular/core';

export class ContadorService {
    total = signal(0);

    incrementar() {
        this.total.update(v => v + 1);
    }
}

// No template: {{ total() }} — só isso. Reativo de graça.
```

Menos código, menos conceitos, mesmo resultado (e mais rápido).

## 🧪 Criando um Signal: `signal(valor)`

```typescript
import { signal } from '@angular/core';

const nome = signal('David');     // Signal<string>
const idade = signal(30);          // Signal<number>
const lista = signal<string[]>([]); // Signal<string[]>
```

O tipo é **inferido** do valor inicial. Pra tipos genéricos vazios (`[]`, `null`), anote explicitamente.

## 📖 Lendo: `signal()` — chame como função

```typescript
console.log(nome());   // "David"
console.log(idade());  // 30
```

**Atenção**: `nome` é o signal (a caixa); `nome()` é o **valor** dentro dele. Esquecer os parênteses é o erro #1 do iniciante.

No template é igual:
```html
<p>Olá, {{ nome() }}!</p>
<p>Idade: {{ idade() }}</p>
```

## ✏️ Escrevendo: `.set()` e `.update()`

### `.set(novoValor)` — substitui direto
```typescript
nome.set('Maria');
idade.set(31);
```

### `.update(fn)` — calcula com base no anterior
```typescript
idade.update(v => v + 1);            // incrementa
lista.update(arr => [...arr, 'novo']); // adiciona item
```

> ⚠️ Sempre **crie um novo array/objeto** em `.update()`. Signals comparam por **referência** — se você mutar (`arr.push(...)`) e devolver o mesmo array, o Angular não vê mudança e **não atualiza a tela**.

```typescript
// 👎 ERRADO — mutação silenciosa
lista.update(arr => { arr.push('x'); return arr; });

// 👍 CERTO — novo array
lista.update(arr => [...arr, 'x']);
```

## 🧮 `computed()` — valor derivado, com cache automático
Um `computed` é um signal **calculado a partir de outros signals**. Sempre que uma dependência muda, ele **recalcula**. Se ninguém leu, ele **nem executa** (lazy + cache).

```typescript
import { signal, computed } from '@angular/core';

const preco = signal(10);
const quantidade = signal(3);

const total = computed(() => preco() * quantidade());

console.log(total()); // 30
preco.set(20);
console.log(total()); // 60 — recalculado sozinho
```

Vantagens:
- **Cache**: lê 10 vezes seguidas? Calcula 1 vez só.
- **Detecção automática**: o Angular percebe quais signals você leu lá dentro — não precisa declarar nada.
- **Composição**: um `computed` pode depender de outro `computed`.

Use sempre que precisar de um valor "que depende de outros valores". Substitui `getter` reativo.

## 💥 `effect()` — efeitos colaterais reativos
Um `effect` roda **sempre que algum signal lido dentro dele muda**. Serve pra "fazer algo" quando o estado muda — logar, salvar no localStorage, chamar uma API, etc.

```typescript
import { signal, effect } from '@angular/core';

const tema = signal<'claro' | 'escuro'>('claro');

effect(() => {
    console.log('Tema mudou pra:', tema());
    document.body.className = tema();
});

tema.set('escuro'); // dispara o effect
```

Regras de ouro:
- **Não mude signals dentro de effect** (loop infinito). Se precisar, use a flag `allowSignalWrites: true` ou repense.
- **Effects rodam em injection context** — declare no constructor ou em campos da classe, não dentro de métodos.
- **Cleanup**: o effect retorna função pra limpar (ex.: cancelar timer).

```typescript
effect((onCleanup) => {
    const id = setInterval(() => console.log('tick', contador()), 1000);
    onCleanup(() => clearInterval(id));
});
```

## 🔄 Interop com RxJS: `toSignal()` e `toObservable()`
O Angular vai **continuar** usando RxJS em HTTP, formulários, router. A ponte entre os dois mundos é fácil:

### `toSignal(observable$)` — Observable → Signal
```typescript
import { toSignal } from '@angular/core/rxjs-interop';
import { interval } from 'rxjs';

// Cria um signal que recebe os valores do observable
contador = toSignal(interval(1000), { initialValue: 0 });

// No template:  {{ contador() }}  — reativo, sem subscribe.
```

`toSignal` cuida do unsubscribe automaticamente quando o componente morre.

### `toObservable(signal)` — Signal → Observable
```typescript
import { toObservable } from '@angular/core/rxjs-interop';

filtro = signal('');
filtro$ = toObservable(this.filtro); // pode aplicar debounce, switchMap, etc.
```

Útil quando você quer combinar signals com operadores RxJS (debounce em busca, por exemplo).

## 🏢 Signals em Services — estado compartilhado
A **maior vantagem prática**: estado global do app vira super simples.

```typescript
import { Injectable, signal, computed } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class CarrinhoService {
    private _itens = signal<Item[]>([]);

    // expor read-only (mantém encapsulamento)
    itens = this._itens.asReadonly();
    total = computed(() => this._itens().reduce((s, i) => s + i.preco, 0));

    adicionar(item: Item) {
        this._itens.update(arr => [...arr, item]);
    }
}
```

Qualquer componente injeta o service e usa `carrinho.itens()` / `carrinho.total()`. Reage sozinho. Sem subscribe, sem `async pipe`, sem `ngOnDestroy`.

## 📥 `input()` signal — Angular 17.3+
A nova forma de receber dados de um componente pai. Substitui o `@Input()`.

```typescript
// Antes
@Input() nome!: string;
@Input() idade = 0;

// Agora (Angular 17.3+)
import { input } from '@angular/core';

nome = input.required<string>();   // obrigatório
idade = input(0);                   // com default
```

No template do componente:
```html
<p>Nome: {{ nome() }}</p>  <!-- lê como signal -->
```

Vantagens:
- **É um signal de verdade**: dá pra usar em `computed` e `effect`.
- **Tipagem mais explícita** (`.required`).
- **Sem decorator** — só import e função.

## 📤 `output()` signal — Angular 17.3+
Mesma ideia pro EventEmitter.

```typescript
// Antes
@Output() salvar = new EventEmitter<string>();
this.salvar.emit('texto');

// Agora
import { output } from '@angular/core';

salvar = output<string>();
this.salvar.emit('texto');
```

Mesma API de uso (`.emit`), mas sem o peso do `EventEmitter` (que é um Subject RxJS por baixo).

## 🆚 Signal vs BehaviorSubject — quando usar qual

| Cenário | Use Signal | Use BehaviorSubject |
|---------|------------|---------------------|
| Estado simples (contador, flag, lista) | ✅ | ❌ |
| Estado compartilhado em service | ✅ (mais simples) | só se precisar de operadores |
| Stream de eventos (cliques, debounce, http) | ❌ | ✅ |
| Combinar/transformar com operadores RxJS | converta com `toObservable` | ✅ |
| Integração com template | ✅ nativo | precisa `async` pipe |

Regra prática: **estado é signal, eventos são observable**.

## ⚡ Por que Signals vão substituir Zone.js
Hoje o Angular detecta mudanças usando **Zone.js** — uma biblioteca que "patcha" todas as APIs assíncronas pra avisar o framework. Funciona, mas custa caro e checa o componente inteiro a cada evento.

Com Signals, o Angular sabe **exatamente** quais expressões do template dependem de quais signals — e atualiza **só elas**. Daqui pra frente:
- Angular 18+: opção **zoneless** estável.
- Bundle menor, menos memória, render mais rápido.
- Você ainda pode misturar Zone + Signals durante a transição.

## 🚦 Próximos passos
1. Abra `pratica/contador.component.ts` — signal + computed básico.
2. Veja `pratica/carrinho.component.ts` — signal de array + effect.
3. Encare o **desafio**: `PokedexStateService` com signals para a Pokedex.

## ✅ Auto-verificação
- [ ] Sei criar um signal e ler/escrever nele
- [ ] Entendo a diferença entre `.set()` e `.update()`
- [ ] Sei quando usar `computed()` em vez de método/getter
- [ ] Sei o que `effect()` faz e quando NÃO usar
- [ ] Sei converter entre Signal e Observable
- [ ] Sei usar `input()` e `output()` signal
- [ ] Sei explicar quando preferir Signal vs BehaviorSubject

Próximo módulo: **Guards e Interceptors** — proteger rotas e interceptar requisições HTTP.
