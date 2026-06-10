# Módulo 14 — HTTP e Observables

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Habilitar o `HttpClient` no app com `provideHttpClient()`
- Fazer chamadas **GET, POST, PUT, DELETE** para uma API real
- Entender o que é um **Observable** e por que ele é diferente de uma Promise
- Consumir Observable de duas formas: `subscribe()` e **`async pipe`** (e saber qual usar quando)
- Passar query params com `HttpParams` e headers com `HttpHeaders`
- Tratar erros HTTP com `catchError`
- Reconhecer os principais **status codes** (200, 201, 404, 500…)
- Conectar nossa **Pokedex** à **PokeAPI** de verdade

## 🌐 Por que isso importa?
Até agora a Pokedex usou dados estáticos no service (mock). App de verdade conversa com **back-end** via HTTP. Angular já vem com `HttpClient` embutido — sem `axios`, sem `fetch` manual. E o retorno não é uma Promise: é um **Observable**, o tipo nativo do mundo Angular/RxJS.

A boa notícia: pra 90% dos casos você usa o Observable como se fosse uma Promise meio turbinada. A diferença ganha sentido com o tempo (cancelar request, retry, debounce, combinar fluxos — tudo isso é trivial com Observable).

---

## 1. Ligando o HttpClient — `provideHttpClient()`

Antes de fazer qualquer request, o app precisa **saber** que vai usar o HttpClient. No Angular standalone, isso vai no `app.config.ts`:

```typescript
// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';

import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient()   // ← liga o HttpClient pra todo o app
  ]
};
```

Sem essa linha, qualquer service que injetar `HttpClient` quebra com erro estranho. **Coloca primeiro, esquece depois.**

---

## 2. Service que consome API — o padrão

```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class PokemonApiService {
  private http = inject(HttpClient);       // injeção moderna (Angular 14+)
  private base = 'https://pokeapi.co/api/v2';

  getById(id: number): Observable<Pokemon> {
    return this.http.get<Pokemon>(`${this.base}/pokemon/${id}`);
  }
}
```

Três coisas pra notar:
1. `inject(HttpClient)` substitui o construtor — fica mais limpo.
2. `http.get<Pokemon>(...)` é **genérico**: você diz o tipo que espera de volta, e tudo no resto do código fica tipado.
3. O retorno é `Observable<Pokemon>` — não `Promise<Pokemon>`.

---

## 3. Os 4 métodos básicos

```typescript
// GET — buscar dados
this.http.get<Pokemon>('https://pokeapi.co/api/v2/pokemon/1');

// POST — criar novo recurso (envia body)
this.http.post<Pokemon>('/api/pokemons', { nome: 'Mewtwo' });

// PUT — atualizar recurso inteiro
this.http.put<Pokemon>('/api/pokemons/150', { nome: 'Mewtwo', hp: 200 });

// DELETE — remover
this.http.delete<void>('/api/pokemons/150');
```

**PokeAPI é só leitura** — só vamos usar GET. Mas saber o resto vale pra qualquer back-end seu.

---

## 4. Observable vs Promise — a diferença prática

| Característica | Promise | Observable |
|---|---|---|
| Quantos valores? | **Um só** (resolve uma vez) | **Zero, um ou vários** ao longo do tempo |
| Quando executa? | Na hora que é criada (**eager**) | Só quando alguém faz `subscribe` (**lazy / cold**) |
| Dá pra cancelar? | Não | Sim (`unsubscribe()`) |
| API nativa? | JS puro | Vem da biblioteca **RxJS** |

**Tradução prática:** o `http.get(...)` **não dispara o request** sozinho. Ele só **descreve** o request. O request só sai quando você dá `subscribe` (ou usa `async pipe`, que faz subscribe por baixo).

```typescript
const req$ = this.http.get('/api/pokemon/1');  // 🟡 nada aconteceu ainda
req$.subscribe(data => console.log(data));      // 🟢 agora sim, request sai
```

> 💡 **Convenção**: nomes de Observable terminam com `$` (cifrão). É opcional, mas ajuda a bater o olho e saber "isso é stream".

---

## 5. Consumindo: `subscribe()` vs `async pipe`

### Forma 1 — `subscribe()` (clássica, evite quando puder)

```typescript
export class PokemonComponent implements OnInit {
  pokemon?: Pokemon;

  ngOnInit() {
    this.api.getById(1).subscribe(p => this.pokemon = p);
  }
}
```

Funciona, mas você precisa:
- Guardar o resultado numa propriedade
- Tratar erro manualmente
- Cuidar pra não vazar memória (unsubscribe no destroy)

### Forma 2 — `async pipe` (recomendada)

```typescript
export class PokemonComponent {
  pokemon$ = this.api.getById(1);   // só guarda o Observable
}
```

```html
<!-- O pipe `async` faz subscribe automático e cancela quando o componente morre -->
@if (pokemon$ | async; as p) {
  <h1>{{ p.name }}</h1>
} @else {
  <p>Carregando…</p>
}
```

**Por que preferir async pipe?**
- Zero código de gerência
- Sem vazamento de memória (Angular limpa pra você)
- Já tem loading "de graça" com `@else`
- Funciona perfeito com `OnPush` change detection

> 🔥 **Regra do curso**: sempre que der, **`async pipe`**. `subscribe` só quando precisa fazer side-effect (gravar em log, navegar, salvar em storage…).

---

## 6. `HttpParams` — query string tipada

Em vez de concatenar string feio (`?limit=20&offset=40`):

```typescript
import { HttpParams } from '@angular/common/http';

listar(limit: number, offset: number): Observable<ListaResp> {
  const params = new HttpParams()
    .set('limit', limit)
    .set('offset', offset);

  return this.http.get<ListaResp>(`${this.base}/pokemon`, { params });
}
```

Angular monta a URL final: `https://pokeapi.co/api/v2/pokemon?limit=20&offset=40`. Sem risco de escape errado, sem `&` esquecido.

---

## 7. `HttpHeaders` — cabeçalhos

Comum em APIs que pedem token de autenticação:

```typescript
import { HttpHeaders } from '@angular/common/http';

const headers = new HttpHeaders({
  Authorization: 'Bearer meu-token-aqui',
  'X-Custom-Header': 'valor'
});

this.http.get<Pokemon>(url, { headers });
```

PokeAPI é pública — não precisa. Mas você vai usar isso muito em apps reais (módulo 17 entra em **interceptors**, que automatizam headers).

---

## 8. Tratamento de erro — `catchError`

Request pode falhar: rede caiu, servidor 500, ID inexistente (404). Sem tratamento, o erro vira **exception não capturada**.

```typescript
import { catchError, of } from 'rxjs';

getById(id: number): Observable<Pokemon | null> {
  return this.http.get<Pokemon>(`${this.base}/pokemon/${id}`).pipe(
    catchError(err => {
      console.error('Falhou:', err);
      return of(null);   // devolve um Observable "vazio" pra não quebrar a tela
    })
  );
}
```

`pipe(...)` é como você encadeia **operadores RxJS** num Observable. `catchError` intercepta erro, e `of(x)` cria um Observable que emite `x` na hora. Módulo 15 mergulha em RxJS.

---

## 9. Status codes — o mínimo pra sobreviver

| Faixa | Significado | Exemplo |
|---|---|---|
| **2xx** | Sucesso | 200 OK, 201 Created |
| **3xx** | Redirecionamento | 301 Moved, 304 Not Modified |
| **4xx** | **Erro do cliente** | 400 Bad Request, 401 Unauthorized, 404 Not Found |
| **5xx** | **Erro do servidor** | 500 Internal Server Error, 503 Service Unavailable |

O Angular **automaticamente** trata 2xx como sucesso e 4xx/5xx como erro (vai pro `catchError`). Você raramente precisa olhar o número — mas saber a faixa ajuda a debugar.

---

## 10. PokeAPI — a API real do módulo

**Base URL:** `https://pokeapi.co/api/v2`

Endpoints úteis:
- `GET /pokemon/{id ou nome}` → detalhes de um pokémon
- `GET /pokemon?limit=20&offset=0` → lista paginada (nome + URL)

Sem autenticação, sem rate limit agressivo, sem CORS chato. **Perfeita pra estudar.**

Exemplo de resposta de `/pokemon/1`:
```json
{
  "id": 1,
  "name": "bulbasaur",
  "height": 7,
  "weight": 69,
  "sprites": { "front_default": "https://.../1.png" },
  "types": [{ "type": { "name": "grass" } }]
}
```

A resposta tem **dezenas de campos**. Você só tipa o que vai usar — tipar tudo é exagero.

---

## 🧱 Juntando tudo — fluxo da Pokedex

1. `app.config.ts` chama `provideHttpClient()`.
2. `pokemon-api.service.ts` injeta `HttpClient` e expõe `getById()` / `listar()`.
3. `pokemon.model.ts` define os tipos da resposta (interface).
4. `app.component.ts` guarda `pokemon$ = this.api.getById(1)`.
5. `app.component.html` usa `pokemon$ | async` pra mostrar.

Sem `subscribe()` no componente. Sem `OnInit`. **Limpo.**

---

## 🚦 Próximos passos
1. Abra `pratica/` — copie os arquivos para `src/app/` do seu projeto e rode `ng serve`.
2. Mude o ID hardcoded de `1` pra outro (`25` = pikachu, `150` = mewtwo) e veja a tela atualizar.
3. Encare o **desafio**: lista paginada com loading e tratamento de erro.

## ✅ Auto-verificação
- [ ] Sei o que `provideHttpClient()` faz e onde colocar
- [ ] Sei a diferença entre Observable e Promise (lazy vs eager)
- [ ] Sei por que `async pipe` é melhor que `subscribe()` na maioria dos casos
- [ ] Sei usar `HttpParams` em vez de concatenar query string
- [ ] Sei tratar erro com `catchError` + `of(...)`
- [ ] Conheço a faixa dos status codes 2xx/4xx/5xx

Próximo módulo: **RxJS** — operadores (`map`, `filter`, `switchMap`, `debounceTime`) e o que dá pra fazer quando você domina Observable.
