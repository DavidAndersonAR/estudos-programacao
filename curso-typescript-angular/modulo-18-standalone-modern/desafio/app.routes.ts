// ============================================================================
// DESAFIO — app.routes.ts
// ----------------------------------------------------------------------------
// SOLUÇÃO. Duas rotas, padrão standalone moderno:
//   - "/"            → lista (eager, chega no bundle inicial)
//   - "/pokemon/:id" → detalhe (lazy via loadComponent)
//   - "**"           → wildcard, volta pra raiz
// ============================================================================

import { Routes } from '@angular/router';

import { PokemonListaComponent } from './components/pokemon-lista.component';

export const routes: Routes = [
    // 👉 Rota raiz: lista. Eager (a maioria dos usuários cai aqui primeiro).
    {
        path: '',
        component: PokemonListaComponent,
        title: 'Pokedex'   // 👈 atualiza o <title> do navegador automaticamente
    },

    // 👉 Rota de detalhe: LAZY. O componente só baixa quando o usuário clica
    //    num card. Esse é o equivalente "por rota" do que o @defer faz por
    //    pedaço de template.
    {
        path: 'pokemon/:id',
        loadComponent: () =>
            import('./components/pokemon-detalhe.component')
                .then(m => m.PokemonDetalheComponent),
        title: 'Detalhe do Pokémon'
    },

    // 👉 Wildcard SEMPRE por último — o Router para na primeira rota que casa.
    { path: '**', redirectTo: '' }
];

// TODO (se quiser ir além):
//   - Adicione um CanActivate fn pra rota de detalhe (ex: validar :id numérico).
//   - Adicione um <NotFoundComponent> em vez de redirecionar.
