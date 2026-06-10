// app.routes.ts — definição de rotas da aplicação (standalone Angular 17+)
//
// Conceitos demonstrados:
// - Rota raiz '' com componente eager (importação normal)
// - Rota com parâmetro ':id' (ex: /pokemons/25)
// - Rota lazy via loadComponent (só baixa o JS quando acessada)
// - Wildcard '**' para 404 (SEMPRE por último)

import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home.component';
import { ListaPokemonsComponent } from './pages/lista-pokemons.component';

export const routes: Routes = [
  // '' → Home (página inicial). pathMatch 'full' garante que só case com URL vazia exata.
  { path: '', component: HomeComponent, pathMatch: 'full' },

  // Lista de pokémons — rota normal (eager). É leve, vale carregar logo.
  { path: 'pokemons', component: ListaPokemonsComponent },

  // Detalhe — lazy! Só baixa o componente quando o usuário clicar em algum pokémon.
  // ':id' vira um parâmetro lido com ActivatedRoute.snapshot.paramMap.get('id').
  {
    path: 'pokemons/:id',
    loadComponent: () =>
      import('./pages/detalhe-pokemon.component').then(
        m => m.DetalhePokemonComponent
      ),
  },

  // Wildcard — qualquer URL não reconhecida cai aqui. SEMPRE por último.
  {
    path: '**',
    loadComponent: () =>
      import('./pages/not-found.component').then(m => m.NotFoundComponent),
  },
];
