// app.config.ts — configuração global do app
//
// É aqui que registramos:
// - O router (com as rotas)
// - O HttpClient (com os interceptors funcionais)
// - Outros providers globais

import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { routes } from './app.routes';
import { authInterceptor } from './auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),

    // withInterceptors aceita um array de HttpInterceptorFn.
    // A ordem importa: rodam de cima pra baixo no request,
    // e de baixo pra cima na response.
    provideHttpClient(
      withInterceptors([authInterceptor])
    ),
  ],
};
