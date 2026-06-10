# Módulo 15 — RxJS Essencial

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que é RxJS e por que ele existe no Angular
- Diferenciar **Observable**, **Subject** e **BehaviorSubject**
- Usar os operators mais comuns: `map`, `filter`, `tap`, `take`, `debounceTime`, `distinctUntilChanged`, `switchMap`, `catchError`, `combineLatest`, `forkJoin`
- Entender a diferença entre `switchMap`, `mergeMap`, `concatMap` e `exhaustMap`
- Criar Observables do zero com `of`, `from`, `fromEvent`
- Evitar memory leak fazendo `unsubscribe` ou usando `async` pipe

## 🧐 O que é RxJS?
**RxJS** (Reactive Extensions for JavaScript) é a **biblioteca reativa** que o Angular usa por baixo dos panos pra tratar **fluxos de dados ao longo do tempo** — coisas que chegam aos poucos: respostas HTTP, cliques, teclas digitadas, eventos de WebSocket, timers.

A peça central chama-se **Observable**: pense num **vídeo no YouTube em vez de uma foto**. A foto é um valor único (uma `Promise`). O vídeo é uma sequência de quadros (um `Observable`) — você se inscreve (**subscribe**), recebe quadro por quadro, e descadastra quando sair.

Por que isso importa em Angular?
- `HttpClient` retorna `Observable` (você já viu no Módulo 14)
- Formulários reativos (`valueChanges`) emitem `Observable`
- Eventos de roteador (`router.events`) emitem `Observable`
- Praticamente toda API do Angular que envolve "algo que muda ao longo do tempo" usa RxJS

Em uma frase: **RxJS é o jeito Angular de tratar dados assíncronos e eventos como streams compostáveis.**

## 📦 Observable — o coração de tudo
Um Observable é uma **fonte de valores** que você consome inscrevendo-se nele.

```typescript
import { Observable } from 'rxjs';

const numeros$ = new Observable<number>(subscriber => {
  subscriber.next(1);   // emite 1
  subscriber.next(2);   // emite 2
  subscriber.next(3);   // emite 3
  subscriber.complete(); // fim do stream
});

numeros$.subscribe({
  next: valor => console.log('Recebi:', valor),
  error: erro => console.error('Erro:', erro),
  complete: () => console.log('Acabou!')
});
// Recebi: 1 / Recebi: 2 / Recebi: 3 / Acabou!
```

> 💡 **Convenção**: variáveis que guardam Observables terminam com `$` (ex: `pokemons$`). Não é obrigatório, mas é o padrão da comunidade Angular.

### Criando Observables prontos
Quase nunca você cria com `new Observable(...)`. Usa os **factories**:

```typescript
import { of, from, fromEvent, interval } from 'rxjs';

of(1, 2, 3);                            // emite 1, 2, 3 e completa
from([10, 20, 30]);                     // emite cada item do array
from(fetch('/api/users'));              // converte Promise em Observable
fromEvent(document, 'click');           // emite cada clique no documento
interval(1000);                         // emite 0, 1, 2... a cada 1s (nunca completa)
```

---

## 🛠️ Operators — transformando streams
**Operators** são funções puras que pegam um Observable e devolvem outro. Você os encadeia com `.pipe(...)`.

```typescript
import { from } from 'rxjs';
import { map, filter } from 'rxjs/operators';

from([1, 2, 3, 4, 5]).pipe(
  map(n => n * 2),       // 2, 4, 6, 8, 10
  filter(n => n > 4)     // 6, 8, 10
).subscribe(console.log);
```

### Os operators que você vai usar todo dia

| Operator | Pra que serve |
|----------|---------------|
| `map(fn)` | transforma cada valor (igual `array.map`) |
| `filter(fn)` | deixa passar só os que satisfazem condição |
| `tap(fn)` | "espia" o valor sem alterar — ótimo pra debug (`tap(v => console.log(v))`) |
| `take(n)` | pega só os primeiros `n` valores e completa |
| `debounceTime(ms)` | espera silêncio de `ms` antes de emitir — clássico de busca |
| `distinctUntilChanged()` | ignora se o valor é igual ao anterior |
| `catchError(fn)` | captura erros do stream e retorna outro Observable |
| `combineLatest([a$, b$])` | combina o último valor de cada stream em uma tupla |
| `forkJoin([a$, b$])` | espera **todos** completarem e devolve tupla final (tipo `Promise.all`) |

### A família dos `*Map` (flattening operators)
São operators que recebem um valor e **devolvem outro Observable** — útil pra encadear chamadas HTTP. Diferem no comportamento quando chega um valor novo enquanto o anterior ainda está processando:

| Operator | Comportamento | Quando usar |
|----------|---------------|-------------|
| `switchMap` | **Cancela** o anterior e troca pelo novo | Buscas com debounce (só interessa a última digitação) |
| `mergeMap` | **Mantém todos** em paralelo | Disparar várias requests independentes ao mesmo tempo |
| `concatMap` | **Enfileira** — só começa o próximo quando o anterior termina | Operações que precisam de ordem (salvar em sequência) |
| `exhaustMap` | **Ignora novos** enquanto o atual não termina | Login: ignorar cliques no botão se já tá processando |

```typescript
// Exemplo clássico: campo de busca
input$.pipe(
  debounceTime(300),
  distinctUntilChanged(),
  switchMap(termo => http.get(`/api?q=${termo}`)) // cancela busca antiga
).subscribe(resultado => this.lista = resultado);
```

---

## 📢 Subject vs BehaviorSubject — Observables que você controla
Um **Subject** é um Observable que **também** é um observer — você pode chamar `.next()` nele de fora. Serve pra fazer **broadcast** de eventos: um componente chama `.next()`, vários outros se inscrevem e recebem.

```typescript
import { Subject } from 'rxjs';

const notificacoes$ = new Subject<string>();

notificacoes$.subscribe(msg => console.log('A:', msg));
notificacoes$.next('Olá');           // A: Olá
notificacoes$.subscribe(msg => console.log('B:', msg));
notificacoes$.next('Mundo');         // A: Mundo / B: Mundo
// B NÃO recebeu "Olá" porque se inscreveu depois
```

### BehaviorSubject — mesma coisa, mas guarda o último valor
**Diferença-chave**: precisa de **valor inicial** e **toda nova inscrição recebe o último valor imediatamente**.

```typescript
import { BehaviorSubject } from 'rxjs';

const usuario$ = new BehaviorSubject<string>('anônimo');
usuario$.subscribe(u => console.log('A:', u));   // A: anônimo
usuario$.next('David');                          // A: David
usuario$.subscribe(u => console.log('B:', u));   // B: David  ← recebeu o último valor!
```

**Quando usar cada um?**
- `Subject` → eventos pontuais (clique, notificação, "salvou com sucesso")
- `BehaviorSubject` → **estado** que tem valor atual (usuário logado, tema, carrinho)

---

## ⚠️ Memory leak — sempre dê unsubscribe
Toda vez que você faz `.subscribe(...)`, está alocando memória. Se o componente sumir da tela e você não cancelar, a inscrição continua **viva pra sempre** — isso é **memory leak**.

### Forma 1 — `unsubscribe` no `ngOnDestroy`
```typescript
import { Subscription } from 'rxjs';

export class MeuComponent implements OnDestroy {
  private sub?: Subscription;

  ngOnInit() {
    this.sub = this.servico.dados$.subscribe(d => this.dados = d);
  }

  ngOnDestroy() {
    this.sub?.unsubscribe();
  }
}
```

### Forma 2 — `async` pipe no template (preferida!)
O `async` pipe **se inscreve e desinscreve sozinho** quando o componente entra e sai da tela.

```typescript
// no .ts
pokemons$ = this.servico.listar();   // só guarda o Observable, não dá subscribe
```

```html
<!-- no .html -->
<div *ngFor="let p of pokemons$ | async">
  {{ p.nome }}
</div>
```

Zero risco de leak, menos código. **É a forma idiomática em Angular moderno.**

### Forma 3 — operator `take(1)` ou `takeUntilDestroyed()` (Angular 16+)
Quando você só quer o primeiro valor e acabou, use `take(1)` — ele completa sozinho.

```typescript
this.servico.dados$.pipe(take(1)).subscribe(d => console.log(d));
```

---

## 🧱 Tudo junto — exemplo real de busca
```typescript
import { Subject } from 'rxjs';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs/operators';

private termo$ = new Subject<string>();

ngOnInit() {
  this.resultados$ = this.termo$.pipe(
    debounceTime(300),              // espera digitação parar
    distinctUntilChanged(),         // ignora se digitou igual ao anterior
    switchMap(t => this.api.buscar(t))  // cancela busca antiga, faz nova
  );
}

aoDigitar(valor: string) {
  this.termo$.next(valor);
}
```

```html
<input (input)="aoDigitar($any($event.target).value)" />
<ul>
  <li *ngFor="let r of resultados$ | async">{{ r.nome }}</li>
</ul>
```

5 linhas de operator resolvem o que em código imperativo daria 40 linhas com `setTimeout`, flags de "tá buscando", cancelamento manual de request anterior, etc. **Essa é a beleza do RxJS.**

---

## 🚦 Próximos passos
1. Abra `pratica/rxjs-exemplos.component.ts` — brinque com `of`, `from`, `fromEvent` e os operators básicos.
2. Estude `pratica/busca.component.ts` — o pipeline `debounceTime + distinctUntilChanged + switchMap` em ação.
3. Encare o **desafio**: busca real na **PokeAPI** com loading e tratamento de erro.

## ✅ Auto-verificação
- [ ] Sei explicar o que é um Observable em uma frase
- [ ] Diferencio `Subject` de `BehaviorSubject`
- [ ] Sei pra que serve cada um: `map`, `filter`, `debounceTime`, `distinctUntilChanged`, `switchMap`
- [ ] Sei a diferença entre `switchMap`, `mergeMap`, `concatMap` e `exhaustMap`
- [ ] Sei evitar memory leak (async pipe ou unsubscribe)
- [ ] Consigo montar um pipeline de busca com debounce do zero

Próximo módulo: **Signals** — a nova primitiva reativa do Angular 17+ que convive com RxJS e simplifica estado local.
