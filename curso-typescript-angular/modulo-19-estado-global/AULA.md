# Módulo 19 — Estado Global

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é **estado global** e quando ele resolve um problema real
- Reconhecer e evitar **prop drilling** (passar `@Input` em cascata)
- Implementar um **Service singleton com signals** (a abordagem recomendada hoje)
- Persistir estado em **localStorage** com `effect()`
- Aplicar o **padrão Repository** pra isolar o "como guardar" do "o quê guardar"
- Saber **quando** usar Service+Signals, **quando** considerar NgRx ou NgRx SignalStore

## 🧐 O que é "estado global"?
**Estado** é qualquer dado que muda durante o uso do app: lista de favoritos, usuário logado, tema escuro/claro, carrinho de compras, filtros aplicados.

Cada componente pode ter o **seu próprio estado** (estado local — uma `signal` dentro da classe). Mas alguns dados precisam ser **vistos e editados por vários componentes ao mesmo tempo**:

- Um ícone no header mostra **quantos favoritos** existem.
- Uma página `/favoritos` mostra **a lista** completa.
- Cada card de pokémon tem um botão de **estrela** que adiciona/remove.

Esses três pontos da UI precisam **enxergar a mesma fonte da verdade**. Isso é **estado global**.

## 😩 O problema: prop drilling
Sem uma fonte global, a única saída é passar dados via `@Input/@Output` de pai pra filho, filho pra neto, neto pra bisneto. Isso é **prop drilling**:

```
AppComponent ──@Input──> HeaderComponent ──@Input──> ContadorComponent
     │
     └──@Input──> ListaComponent ──@Input──> CardComponent ──@Output──> ...
```

Problemas:
- Componentes do meio recebem props que **não usam**, só pra repassar.
- Refatorar dói: mexeu numa coisa, quebrou três caminhos.
- Não escala: 10 componentes profundos viram pesadelo.

A saída: **um lugar único que todos consultam diretamente**.

## 🧰 Abordagens em Angular — panorama

### 1. **Service singleton com Signals** (recomendado pra apps pequenas/médias)
Um service `@Injectable({ providedIn: 'root' })` que guarda `signal`s. Qualquer componente faz `inject()` e lê/escreve. Reatividade automática (mudou a signal → toda UI que lê reflete).

- ✅ Zero dependências externas (já vem com Angular 16+)
- ✅ Curva de aprendizado quase nula (você já sabe service + signal)
- ✅ Encaixa em **80% dos casos reais**
- ❌ Sem time-travel debugging nem padrão estrito de mutação

### 2. **NgRx** (Redux para Angular — apps grandes)
Biblioteca terceira (`@ngrx/store`). Estado **imutável** numa **store** única, modificado por **actions** despachadas, transformadas por **reducers**, com efeitos colaterais (HTTP, etc.) em **effects**.

```
Componente → dispatch(action) → reducer → novo estado → componente reage
                                  └─→ effects → API → dispatch(action de sucesso)
```

- ✅ Padrão rígido, ótimo pra **times grandes** (10+ devs)
- ✅ Ferramentas top: Redux DevTools, time-travel, replay
- ❌ **Muito boilerplate** (actions, reducers, effects, selectors)
- ❌ Curva de aprendizado alta — overkill em app pequeno

Use quando: app **muito grande**, fluxos complexos de side effects, time já familiarizado com Redux.

### 3. **NgRx SignalStore** (a alternativa moderna — Angular 17+)
Mesma família do NgRx, mas **construída sobre signals**. Sem actions/reducers — você declara `state`, `computed`, `methods` numa única função fluente.

```typescript
export const FavoritosStore = signalStore(
    { providedIn: 'root' },
    withState({ ids: [] as number[] }),
    withComputed(({ ids }) => ({ total: computed(() => ids().length) })),
    withMethods((store) => ({
        adicionar(id: number) { /* ... */ },
    }))
);
```

- ✅ Combina padrão de store com simplicidade de signals
- ✅ Boilerplate **muito menor** que NgRx clássico
- ✅ Boa escolha intermediária quando o service caseiro fica grande demais
- ❌ Ainda assim é uma dependência a mais

### 📊 Comparativo rápido

| Cenário | Escolha |
|---|---|
| App pessoal, MVP, protótipo | **Service + Signal** |
| App médio (até ~50 componentes) | **Service + Signal** |
| App grande com fluxos complexos, time grande | **NgRx SignalStore** ou **NgRx clássico** |
| Já tem cultura Redux, precisa de time-travel | **NgRx clássico** |

**Neste módulo a gente foca no padrão 1** — porque é o que cobre a maioria dos casos e ensina os fundamentos que servem pros outros dois.

## 🏗️ Service singleton com Signals — a receita

```typescript
import { Injectable, signal, computed } from '@angular/core';

@Injectable({ providedIn: 'root' }) // 👈 1 instância pra app inteira
export class CarrinhoService {

    // 1. Estado privado (só o service mexe direto)
    private readonly _itens = signal<Item[]>([]);

    // 2. Exposição read-only — componentes leem, mas não mutam
    readonly itens = this._itens.asReadonly();

    // 3. Derivados (computed) — recalculam sozinhos
    readonly total = computed(() => this._itens().length);
    readonly valor = computed(() =>
        this._itens().reduce((soma, i) => soma + i.preco, 0)
    );

    // 4. Métodos — única porta de entrada pra mudar o estado
    adicionar(item: Item): void {
        this._itens.update(arr => [...arr, item]);
    }

    remover(id: number): void {
        this._itens.update(arr => arr.filter(i => i.id !== id));
    }
}
```

**Padrão importante**: `_itens` é privado, `itens` é `asReadonly()`. Assim, **fora do service** ninguém faz `service.itens.set(...)` — só sobra usar os **métodos**. Isso é o equivalente "leve" das actions do NgRx.

## 💾 Persistência: localStorage com `effect()`
Estado em memória **some quando o usuário fecha a aba**. Pra sobreviver, salve em `localStorage` (chave-valor no navegador).

```typescript
import { Injectable, signal, effect } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class TemaService {

    // 1. Lê o valor inicial do localStorage (ou usa default)
    private readonly _tema = signal<'claro' | 'escuro'>(
        (localStorage.getItem('tema') as 'claro' | 'escuro') ?? 'claro'
    );

    readonly tema = this._tema.asReadonly();

    constructor() {
        // 2. effect() roda sempre que a signal muda
        effect(() => {
            localStorage.setItem('tema', this._tema());
        });
    }

    alternar(): void {
        this._tema.update(t => t === 'claro' ? 'escuro' : 'claro');
    }
}
```

O `effect()` é um **observador automático**: ele lê `this._tema()` dentro da função, então sempre que essa signal mudar, ele roda de novo. Persistência **declarativa**, sem precisar lembrar de chamar `salvar()` manualmente.

> ⚠️ **Detalhe**: `localStorage` só guarda **strings**. Pra objetos/arrays use `JSON.stringify` ao salvar e `JSON.parse` ao ler.

## 🗄️ Padrão Repository (bônus de arquitetura)
À medida que o service cresce, fica feio misturar **lógica de estado** com **lógica de armazenamento**. O padrão **Repository** isola o "como salvar" num objeto à parte:

```typescript
// repositorio puro: só sabe ler/gravar
class FavoritosRepository {
    private readonly KEY = 'favoritos';

    ler(): number[] {
        const raw = localStorage.getItem(this.KEY);
        return raw ? JSON.parse(raw) : [];
    }

    gravar(ids: number[]): void {
        localStorage.setItem(this.KEY, JSON.stringify(ids));
    }
}
```

Vantagens: amanhã se você trocar `localStorage` por `IndexedDB`, `sessionStorage` ou uma API HTTP, só muda o repositório — o service nem percebe.

Pra este módulo, vamos manter as duas coisas no mesmo service por simplicidade (`effect()` cuidando da persistência). Mas guarde o conceito.

## 🆚 localStorage vs sessionStorage

| | `localStorage` | `sessionStorage` |
|---|---|---|
| Persiste após fechar aba? | **Sim** | Não — some ao fechar |
| Compartilhado entre abas? | Sim (mesma origem) | Não (cada aba é isolada) |
| Limite típico | ~5–10 MB | ~5–10 MB |
| Uso comum | Preferências, favoritos | Carrinho temporário, filtros de sessão |

API é idêntica: `getItem`, `setItem`, `removeItem`, `clear`.

## 🧪 Como vários componentes "compartilham" o estado
Como o service é **singleton**, basta cada componente fazer `inject()` — todos recebem **a mesma instância**, com **as mesmas signals**.

```typescript
// HeaderComponent
private store = inject(FavoritosStore);
total = this.store.total;  // ← computed reativo

// PaginaFavoritosComponent
private store = inject(FavoritosStore);
lista = this.store.favoritos;  // ← mesma fonte da verdade

// CardComponent
private store = inject(FavoritosStore);
toggle(id: number) { this.store.toggle(id); }
```

Mudou em qualquer lugar → **todos refletem na hora**. É essa a mágica.

## ⚠️ Armadilhas comuns

1. **Mutar direto o array da signal** — `_itens().push(x)` **não dispara** reatividade. Use `update` com array novo: `_itens.update(arr => [...arr, x])`.
2. **Esquecer `asReadonly()`** — componentes ganham permissão de bagunçar o estado sem passar pelos métodos.
3. **`effect()` em lugar errado** — só pode ser criado dentro de **contexto de injeção** (constructor, factory, ou passando `{ injector }` explícito).
4. **JSON.parse sem tratar erro** — se o localStorage tem lixo, quebra. Use try/catch ou validação.
5. **Persistir tudo** — não jogue dados sensíveis (token, senha) no localStorage. Pra isso use outras estratégias.

## 🚦 Próximos passos
1. Abra `pratica/favoritos-store.service.ts` — veja signal + computed + effect persistindo em localStorage.
2. Veja `pratica/app.component.ts` — três regiões da UI reagindo à mesma store.
3. Encare o **desafio**: store completa de Pokédex (cache, favoritos, último visto, filtro de busca) consumida por três componentes diferentes.

## ✅ Auto-verificação
- [ ] Sei explicar o que é prop drilling e por que dói
- [ ] Sei criar um service singleton com signal privada e exposição readonly
- [ ] Sei usar `computed` pra derivar valores
- [ ] Sei persistir estado em localStorage via `effect()`
- [ ] Sei quando escolher Service+Signal vs NgRx vs SignalStore
- [ ] Conheço o padrão Repository (em alto nível)

Próximo módulo: **Build e Deploy** — empacotar a Pokédex e publicar online.
