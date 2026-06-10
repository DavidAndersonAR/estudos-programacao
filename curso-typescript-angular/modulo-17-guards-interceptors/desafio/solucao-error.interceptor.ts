// solucao-error.interceptor.ts
// Tratamento global de 401: desloga e manda pra /login.
// Outros erros são repassados pra quem fez a chamada lidar (throwError).

import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from './solucao-auth.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      if (err.status === 401) {
        auth.logout();
        router.navigate(['/login'], {
          queryParams: { redirect: router.url },
        });
      }
      // Repassa o erro pra quem assinou — não engolimos silenciosamente.
      return throwError(() => err);
    })
  );
};
