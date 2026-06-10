// ============================================================================
// DESAFIO — pokemon-detalhe.component.ts
// ----------------------------------------------------------------------------
// SOLUÇÃO. Página de detalhes do pokémon.
// Demonstra:
//   - loadComponent (essa rota é lazy — ver app.routes.ts)
//   - Leitura de :id via ActivatedRoute snapshot
//   - @let pra simplificar o template
//   - @defer (on interaction) pro painel pesado de stats
// ============================================================================

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { PokemonStatsPesadoComponent } from './pokemon-stats-pesado.component';
import { PokemonResumo } from './pokemon-lista.component';

// Mesma "base" da lista — em projeto real isso ia num service.
const POKEMONS: Record<string, PokemonResumo> = {
    '1':  { id: 1,  nome: 'bulbasaur',  tipos: ['grass', 'poison'], cor: '#78c850' },
    '4':  { id: 4,  nome: 'charmander', tipos: ['fire'],            cor: '#f08030' },
    '7':  { id: 7,  nome: 'squirtle',   tipos: ['water'],           cor: '#6890f0' },
    '25': { id: 25, nome: 'pikachu',    tipos: ['electric'],        cor: '#f8d030' },
    '39': { id: 39, nome: 'jigglypuff', tipos: ['fairy', 'normal'], cor: '#ee99ac' },
    '94': { id: 94, nome: 'gengar',     tipos: ['ghost', 'poison'], cor: '#705898' },
};

@Component({
    selector: 'app-pokemon-detalhe',
    standalone: true,
    imports: [
        CommonModule,
        RouterLink,
        // 👇 Importado pq é usado dentro de @defer. O bundler vai gerar
        //    um chunk próprio pra esse componente.
        PokemonStatsPesadoComponent
    ],
    templateUrl: './pokemon-detalhe.component.html',
    styles: [`
        :host { display: block; }
        .voltar { display: inline-block; margin-bottom: 16px; color: #c62828; }
        .hero {
            padding: 24px; border-radius: 12px; color: #fff;
            text-transform: capitalize; box-shadow: 0 4px 12px rgba(0,0,0,.1);
        }
        .hero h2 { margin: 0; font-size: 32px; }
        .hero p { margin: 4px 0 0; opacity: .9; }
        button.cta {
            margin-top: 16px; padding: 10px 18px; border-radius: 8px;
            border: none; background: #fff; color: #333; cursor: pointer;
            font-weight: 600;
        }
        button.cta:hover { background: #f0f0f0; }
        .placeholder, .loading {
            margin-top: 16px; padding: 12px; background: #f7f7f7;
            border-radius: 8px; color: #777; font-style: italic;
        }
    `]
})
export class PokemonDetalheComponent {
    private route = inject(ActivatedRoute);

    // 👉 Snapshot é o suficiente porque NÃO ficamos no mesmo componente
    //    ao trocar de pokémon (cada /pokemon/:id desmonta o anterior).
    private id = this.route.snapshot.paramMap.get('id') ?? '1';
    pokemon: PokemonResumo = POKEMONS[this.id] ?? POKEMONS['1'];
}
