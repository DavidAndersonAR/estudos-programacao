/*
 * DESAFIO — Módulo 12 (Routing)
 * ================================================================
 * Sua missão: turbinar a Pokédex do pratica/ com mais rotas e polimento.
 *
 * Requisitos:
 *  1. Rota '' → redireciona pra '/pokemons' (use redirectTo + pathMatch).
 *  2. Rota '/pokemons' → lista em formato de CARDS (não <ul>).
 *  3. Rota '/pokemons/:id' (lazy) → detalhe com botão "← Voltar".
 *  4. Rota '/favoritos' (lazy) → placeholder "em construção".
 *  5. Rota '**' → 404.
 *  6. Navbar com routerLinkActive destacando a rota atual.
 *
 * Tente fazer sozinho. A solução está comentada no fim de cada arquivo.
 */

import { Routes } from '@angular/router';

// TODO: importe os componentes eager (Home não existe mais — vamos redirecionar).
// TODO: declare e exporte `routes` com as 5 rotas acima.

export const routes: Routes = [
  // ... preencha aqui ...
];

/* ----------------------------------------------------------------
 * SOLUÇÃO (descomente pra ver depois de tentar)
 * ----------------------------------------------------------------

import { ListaPokemonsComponent } from './pages/lista-pokemons.component';

export const routes: Routes = [
  // Redirect raiz → /pokemons. pathMatch 'full' é OBRIGATÓRIO aqui,
  // senão TODA URL seria redirecionada (porque '' casa com qualquer prefixo).
  { path: '', redirectTo: '/pokemons', pathMatch: 'full' },

  { path: 'pokemons', component: ListaPokemonsComponent },

  {
    path: 'pokemons/:id',
    loadComponent: () =>
      import('./pages/detalhe-pokemon.component').then(m => m.DetalhePokemonComponent),
  },

  {
    path: 'favoritos',
    loadComponent: () =>
      import('./pages/favoritos.component').then(m => m.FavoritosComponent),
  },

  {
    path: '**',
    loadComponent: () =>
      import('./pages/not-found.component').then(m => m.NotFoundComponent),
  },
];

 * ---------------------------------------------------------------- */
