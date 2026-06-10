// solucao-app.config.ts
// Junta tudo: rotas + os 3 interceptors funcionais.
//
// Ordem dos interceptors (request vai de cima pra baixo):
// 1. authInterceptor      → adiciona Bearer
// 2. loadingInterceptor   → liga overlay
// 3. errorInterceptor     → captura 401 (na resposta, sobe de baixo pra cima)

import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { routes } from './solucao-app.routes';
import { authInterceptor } from './solucao-auth.interceptor';
import { loadingInterceptor } from './solucao-loading.interceptor';
import { errorInterceptor } from './solucao-error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(
      withInterceptors([
        authInterceptor,
        loadingInterceptor,
        errorInterceptor,
      ])
    ),
  ],
};
