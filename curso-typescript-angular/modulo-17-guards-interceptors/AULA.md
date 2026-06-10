# Módulo 17 — Guards e Interceptors

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender o que são **Guards** e quando usar cada tipo
- Escrever **functional guards** (padrão Angular 14.2+) no lugar de class guards
- Proteger rotas com `CanActivateFn`, `CanMatchFn`, `CanDeactivateFn` e `ResolveFn`
- Entender o que é um **HTTP Interceptor** e por que ele é o lugar certo pra lógica transversal
- Escrever **functional interceptors** (Angular 15+) registrados em `provideHttpClient(withInterceptors([...]))`
- Implementar 4 casos de uso clássicos: token de auth, logging, loading global e tratamento de 401

## 🧐 Guards — o porteiro da rota
Um **Guard** é uma função que o router chama **antes** de ativar (ou sair de) uma rota. Ele retorna `true` (deixa passar), `false` (bloqueia) ou um `UrlTree` (redireciona).

Sem Guard:
```
Usuário clica /favoritos → router renderiza /favoritos → componente percebe que não tem login → faz redirect manual
```

Com Guard:
```
Usuário clica /favoritos → guard pergunta "tá logado?" → se não, redireciona já — componente nem carrega
```

A diferença é que o **guard roda antes**. O componente protegido nunca instancia se o guard barrar. Mais rápido, mais limpo, sem flash de tela errada.

## 🆕 Functional Guards (padrão moderno)
Antes (Angular ≤ 14.1), guards eram **classes** que implementavam `CanActivate`. Muito boilerplate. Desde **Angular 14.2** (e **deprecated as classes em 15.2+**), o padrão são **funções**:

```typescript
import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.usuarioLogado()) {
    return true;
  }
  // redireciona pra login, guardando pra onde queria ir
  return router.createUrlTree(['/login'], {
    queryParams: { redirect: state.url }
  });
};
```

Observe:
- É só uma **arrow function** com tipo `CanActivateFn`.
- Usa **`inject()`** (o mesmo do constructor injection) pra pegar services.
- Retorna `boolean | UrlTree | Observable<...> | Promise<...>`.

E aplica na rota assim:
```typescript
{ path: 'favoritos', component: FavoritosComponent, canActivate: [authGuard] }
```

## 📚 Os 4 tipos de guard

| Tipo | Quando dispara | Caso de uso |
|------|----------------|-------------|
| `CanActivateFn` | Antes de entrar na rota | Auth, role-based access |
| `CanMatchFn` | Antes de **carregar** o módulo lazy | Bloquear o download do bundle (mais cedo que `CanActivate`) |
| `CanDeactivateFn` | Antes de **sair** da rota | "Tem alterações não salvas, sair mesmo?" |
| `ResolveFn` | Antes de ativar, busca dados | Pré-carregar pokémon antes da tela abrir |

### `CanDeactivateFn` — exemplo
```typescript
export const formDirtyGuard: CanDeactivateFn<FormComponent> = (component) => {
  return component.form.pristine || confirm('Sair sem salvar?');
};
```

### `ResolveFn` — exemplo
```typescript
export const pokemonResolver: ResolveFn<Pokemon> = (route) => {
  const id = route.paramMap.get('id')!;
  return inject(PokemonService).getById(+id);
};
```

E no componente, em vez de buscar no `ngOnInit`, você pega pronto:
```typescript
ngOnInit() {
  this.pokemon = this.route.snapshot.data['pokemon'];
}
```

## 🧐 HTTP Interceptors — o middleware do HttpClient
Um **Interceptor** é um middleware que intercepta **toda requisição HTTP** que sai do app e **toda resposta** que volta. Lugar perfeito pra lógica que se repete:

- Adicionar header `Authorization: Bearer <token>` em todo request
- Logar quanto tempo cada request demorou
- Mostrar/esconder spinner global (loading)
- Tratar 401 globalmente (deslogar e mandar pra /login)
- Adicionar `X-Request-Id` pra rastreabilidade

Sem interceptor: você teria que repetir esse código em **cada** chamada de service. Com interceptor: escreve uma vez, roda sempre.

## 🆕 Functional Interceptors (Angular 15+)
Mesma evolução dos guards: antes eram classes, agora são funções.

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const user = auth.usuarioLogado();

  // se não tem usuário, deixa passar sem mexer
  if (!user) return next(req);

  // clona o request adicionando o header (HttpRequest é imutável)
  const reqAutenticado = req.clone({
    setHeaders: { Authorization: `Bearer ${user.token}` }
  });

  return next(reqAutenticado);
};
```

Pontos-chave:
- `req` é **imutável** — sempre `clone()` antes de modificar.
- `next(req)` continua a cadeia. Pode encadear vários interceptors.
- Retorna `Observable<HttpEvent<unknown>>`.

### Registro no `app.config.ts`
```typescript
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor, loadingInterceptor, errorInterceptor])
    )
  ]
};
```

**A ordem importa**: rodam de cima pra baixo na requisição e de baixo pra cima na resposta.

## 🔥 Casos de uso clássicos

### 1. Loading global
Service com signal `loadingCount`. Interceptor incrementa no início, decrementa no `finalize`:

```typescript
export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  const loading = inject(LoadingService);
  loading.start();
  return next(req).pipe(finalize(() => loading.stop()));
};
```

`finalize` roda em **sucesso e erro**, garantindo que o contador volta a zero.

### 2. Tratamento global de 401
```typescript
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      if (err.status === 401) {
        auth.logout();
        router.navigate(['/login']);
      }
      return throwError(() => err);
    })
  );
};
```

### 3. Logging
```typescript
export const logInterceptor: HttpInterceptorFn = (req, next) => {
  const inicio = Date.now();
  return next(req).pipe(
    tap({ finalize: () => console.log(`${req.method} ${req.url} — ${Date.now() - inicio}ms`) })
  );
};
```

## 🆚 Guard vs Interceptor — não confunda
- **Guard**: protege **rota** (componente / lazy chunk).
- **Interceptor**: intercepta **requisição HTTP**.

Pode usar os dois juntos: guard barra acesso à tela; interceptor garante que, se a tela carregar e fizer um fetch, o token vai junto.

## 🚦 Próximos passos
1. Abra `pratica/` e leia cada um dos 5 arquivos — eles formam o mini-app de auth.
2. Cole no seu projeto Pokedex, registre no `app.config.ts` e teste:
   - Vá em `/favoritos` deslogado → deve mandar pra `/login`
   - Faça login → deve voltar pra `/favoritos`
   - Veja no DevTools → Network que o header `Authorization` aparece
3. Encare o **desafio**: combina tudo — login, guard, interceptor de auth, loading global e tratamento de 401.

## ✅ Auto-verificação
- [ ] Sei diferenciar guard de interceptor
- [ ] Sei escrever um `CanActivateFn` que redireciona com `UrlTree`
- [ ] Sei usar `inject()` dentro de uma functional guard/interceptor
- [ ] Sei registrar interceptors via `withInterceptors([])`
- [ ] Sei usar `req.clone({ setHeaders })` pra adicionar header
- [ ] Sei usar `finalize` pra contar requests em andamento

Próximo módulo: **Standalone Modern** — defer blocks, control flow novo (`@if`, `@for`, `@switch`) e o que mudou no Angular 17+.
