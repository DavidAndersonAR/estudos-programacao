// solucao-loading.interceptor.ts
// Incrementa contador no início, decrementa no FIM (sucesso OU erro).
//
// `finalize` é o operador certo aqui — `tap` só roda em sucesso,
// `catchError` só em erro. `finalize` roda nos dois (e em unsubscribe).

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { finalize } from 'rxjs';
import { LoadingService } from './solucao-loading.service';

export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  const loading = inject(LoadingService);

  loading.start();

  return next(req).pipe(
    finalize(() => loading.stop())
  );
};
