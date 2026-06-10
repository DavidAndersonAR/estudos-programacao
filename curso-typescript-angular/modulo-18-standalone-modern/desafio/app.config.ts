// ============================================================================
// DESAFIO — app.config.ts
// ----------------------------------------------------------------------------
// SOLUÇÃO. Veja ENUNCIADO.md pra entender os requisitos.
//
// Aqui está a configuração 100% standalone:
//   - provideRouter(routes, withViewTransitions())  → router + animação grátis
//   - provideHttpClient()                           → HTTP moderno
//
// Sem AppModule, sem RouterModule.forRoot, sem HttpClientModule.
// Tudo tree-shakable, tudo explícito.
// ============================================================================

import { ApplicationConfig } from '@angular/core';
import { provideRouter, withViewTransitions } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';

import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
    providers: [
        // 👉 Router com View Transitions API embutida.
        //    Cada navegação entre rotas vira um cross-fade automático
        //    (Chrome/Edge 111+, Safari 18+). Em browsers sem suporte,
        //    degrada silenciosamente — sem animação, mas funciona.
        //
        //    Pra customizar a animação, basta CSS:
        //    ::view-transition-old(root), ::view-transition-new(root) { ... }
        provideRouter(routes, withViewTransitions()),

        // 👉 HttpClient moderno (tree-shakable).
        //    Mesmo que esse desafio use dados in-memory, deixamos o provider
        //    aqui porque toda Pokedex real consome a PokéAPI.
        provideHttpClient(),
    ]
};

// TODO (se você for além):
//   - Adicione provideClientHydration() se ativar SSR via `ng add @angular/ssr`.
//   - Encadeie interceptors em provideHttpClient(withInterceptors([...])).
