// auth.guard.ts — functional guard (padrão Angular 14.2+)
//
// CanActivateFn = (route, state) => boolean | UrlTree | Observable<...> | Promise<...>
// Retornar UrlTree é melhor que chamar router.navigate() — o router faz o redirect
// como parte da resolução da rota (sem flicker, sem race condition).

import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.estaLogado()) {
    return true; // libera o acesso
  }

  // Bloqueia e redireciona pra /login.
  // Passamos a URL original como queryParam pra voltar depois do login.
  return router.createUrlTree(['/login'], {
    queryParams: { redirect: state.url },
  });
};
