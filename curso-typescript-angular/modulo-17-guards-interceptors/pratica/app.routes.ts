// app.routes.ts — definição das rotas
//
// canActivate recebe um array de CanActivateFn.
// Se qualquer um retornar false (ou UrlTree), a rota é bloqueada.

import { Routes } from '@angular/router';
import { authGuard } from './auth.guard';

// Componentes hipotéticos — substitua pelos seus.
// (Em projeto real, normalmente são lazy: loadComponent: () => import(...))
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './login/login.component';
import { FavoritosComponent } from './favoritos/favoritos.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'login', component: LoginComponent },

  // Rota protegida — só entra se authGuard retornar true.
  // Se não logado, o guard redireciona pra /login com ?redirect=/favoritos.
  {
    path: 'favoritos',
    component: FavoritosComponent,
    canActivate: [authGuard],
  },

  // Wildcard sempre por último.
  { path: '**', redirectTo: '' },
];
