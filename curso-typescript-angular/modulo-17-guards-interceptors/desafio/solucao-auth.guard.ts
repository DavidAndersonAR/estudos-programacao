// solucao-auth.guard.ts
// CanActivateFn: usa createUrlTree pra redirecionar com queryParam de retorno.

import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from './solucao-auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.estaLogado()) return true;

  return router.createUrlTree(['/login'], {
    queryParams: { redirect: state.url },
  });
};
