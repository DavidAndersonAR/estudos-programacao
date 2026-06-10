// solucao-app.routes.ts
// Rotas com guard em /favoritos.

import { Routes } from '@angular/router';
import { authGuard } from './solucao-auth.guard';
import { LoginComponent } from './solucao-login.component';
import { FavoritosComponent } from './solucao-favoritos.component';

export const routes: Routes = [
  { path: '', redirectTo: 'favoritos', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  {
    path: 'favoritos',
    component: FavoritosComponent,
    canActivate: [authGuard],
  },
  { path: '**', redirectTo: 'favoritos' },
];
