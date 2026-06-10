// ============================================================================
// PRATICA — app.config.ts
// ----------------------------------------------------------------------------
// Configuração 100% standalone do app. Substitui o antigo AppModule.
// Aqui registramos providers globais: router (com view transitions) e
// HttpClient. Tudo é tree-shakable.
// ============================================================================

import { ApplicationConfig } from '@angular/core';
import { provideRouter, withViewTransitions } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';

// Como essa prática é "single page", o array de rotas é vazio — mas o
// provideRouter ainda é incluído pra mostrar a forma canônica de configurar
// o Router moderno.
import { Routes } from '@angular/router';
const routes: Routes = [];

export const appConfig: ApplicationConfig = {
    providers: [
        // 👉 Router moderno (standalone). Substitui RouterModule.forRoot(routes).
        //    withViewTransitions() liga a View Transitions API do navegador —
        //    cada navegação ganha um cross-fade automático (em browsers que
        //    suportam; nos outros, degrada silenciosamente).
        provideRouter(routes, withViewTransitions()),

        // 👉 HttpClient moderno. Substitui HttpClientModule.
        //    Aqui você poderia encadear withInterceptors([...]) se quisesse.
        provideHttpClient(),
    ]
};

// No main.ts você usaria assim:
//
//   import { bootstrapApplication } from '@angular/platform-browser';
//   import { AppComponent } from './app.component';
//   import { appConfig } from './app.config';
//
//   bootstrapApplication(AppComponent, appConfig);
//
// Não tem mais AppModule. Não tem mais platformBrowserDynamic.
