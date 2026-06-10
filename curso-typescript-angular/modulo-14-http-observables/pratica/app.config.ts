// ============================================================
// PRÁTICA — Módulo 14: app.config.ts (habilitando HttpClient)
// ============================================================
//
// COMO USAR:
// 1. Copie este arquivo por cima de  src/app/app.config.ts
//    do seu projeto Pokedex.
//
// 2. Sem `provideHttpClient()` aqui, qualquer service que
//    injetar HttpClient quebra com erro:
//    "No provider for _HttpClient!"
//
// 3. provideHttpClient() é o suficiente. Se um dia precisar
//    interceptors (módulo 17), passa como argumento:
//      provideHttpClient(withInterceptors([...]))
// ============================================================

import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';

import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient()   // ← liga o HttpClient pra todo o app
  ]
};
