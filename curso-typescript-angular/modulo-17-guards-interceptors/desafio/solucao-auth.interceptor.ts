// solucao-auth.interceptor.ts
// Adiciona Bearer token em todo request quando há usuário logado.

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './solucao-auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const user = inject(AuthService).usuarioLogado();

  if (!user) return next(req);

  return next(
    req.clone({
      setHeaders: { Authorization: `Bearer ${user.token}` },
    })
  );
};
