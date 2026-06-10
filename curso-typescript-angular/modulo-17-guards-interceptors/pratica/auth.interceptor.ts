// auth.interceptor.ts — functional interceptor (padrão Angular 15+)
//
// HttpInterceptorFn = (req, next) => Observable<HttpEvent<unknown>>
// req é IMUTÁVEL — pra mudar, sempre clone() antes.

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const user = auth.usuarioLogado();

  // Sem usuário logado, passa o request sem mexer.
  if (!user) {
    return next(req);
  }

  // Clona adicionando o header Authorization.
  // setHeaders mescla com headers existentes (não substitui).
  const reqAutenticado = req.clone({
    setHeaders: {
      Authorization: `Bearer ${user.token}`,
    },
  });

  return next(reqAutenticado);
};
