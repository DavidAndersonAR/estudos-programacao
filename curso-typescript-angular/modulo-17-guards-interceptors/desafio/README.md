# Desafio Módulo 17 — Auth Simulada + Loading Global

## 🎯 Enunciado
Construa um mini-app Angular que combina **tudo** do módulo:

1. **AuthService** com signal `usuarioLogado` e métodos `login()` / `logout()`.
2. **`/login`** com formulário simples (email + senha). Senha mágica: `123456`.
3. **`/favoritos`** protegida por `authGuard` (CanActivateFn). Sem login, redireciona pra `/login` mantendo o `?redirect`.
4. **`authInterceptor`** que adiciona `Authorization: Bearer <token>` em todo request.
5. **`loadingInterceptor`** que mantém um **contador de requests em andamento** (signal `loadingCount`). Usa `finalize` pra garantir decremento mesmo em erro.
6. **`errorInterceptor`** que captura **HTTP 401**, desloga o usuário e redireciona pra `/login`.
7. **`<app-loading>`** que mostra um overlay enquanto `loadingCount > 0`.
8. **`AppComponent`** com nav (Home / Favoritos / Login-Logout) + `<router-outlet>` + `<app-loading>`.

## ✅ Critérios de aceite
- [ ] Acessar `/favoritos` deslogado redireciona pra `/login?redirect=/favoritos`
- [ ] Após login bem-sucedido, volta pra `/favoritos` automaticamente
- [ ] Tab Network mostra header `Authorization: Bearer ...` nas requests autenticadas
- [ ] Overlay de loading aparece durante request e some sozinho (mesmo se der erro)
- [ ] Resposta 401 do servidor desloga o usuário automaticamente
- [ ] Tudo é functional (sem classes de guard/interceptor)
- [ ] AuthService usa `signal()`, não `BehaviorSubject`

## 🛠️ TODOs (sugestão de ordem)
1. `auth.service.ts` — signal de user, login/logout.
2. `loading.service.ts` — signal `loadingCount`, métodos `start()` / `stop()`.
3. `auth.guard.ts` — CanActivateFn com redirect via `createUrlTree`.
4. `auth.interceptor.ts` — adiciona Bearer token.
5. `loading.interceptor.ts` — start/stop com finalize.
6. `error.interceptor.ts` — catchError pra 401.
7. `login.component.ts` — form com email/senha, lê `?redirect` do queryParam.
8. `favoritos.component.ts` — tela protegida, exibe `usuarioLogado()`.
9. `loading.component.ts` — overlay condicional via `@if`.
10. `app.routes.ts` + `app.config.ts` — registra rotas e os 3 interceptors.
11. `app.component.ts` — nav + outlet + loading.

## 💡 Dicas
- Use `inject()` dentro dos guards/interceptors — eles não têm constructor.
- A **ordem** dos interceptors em `withInterceptors([])` importa:
  `[authInterceptor, loadingInterceptor, errorInterceptor]` é uma boa.
- `finalize` no `loading.interceptor` é **crítico**: sem ele, request com erro deixa o spinner girando pra sempre.
- Pra testar 401 sem backend, faça um botão que chama um endpoint inexistente — vai dar 404 (troque a checagem temporariamente pra `err.status >= 400` se quiser ver o flow).

## 📁 Arquivos da solução (já comentados)
Todos prefixados com `solucao-`. Leia, copie pro seu projeto Angular em `src/app/`, ajuste imports e rode.
