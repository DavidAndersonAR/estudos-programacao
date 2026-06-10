// ============================================================================
// PRATICA — pokemon-card.component.ts
// ----------------------------------------------------------------------------
// Card standalone que importa o detalhes-pesado APENAS dentro do bloco
// @defer (on viewport). Isso significa: o JS do detalhes-pesado só baixa
// quando o card entra na viewport do usuário.
//
// Demonstra:
//   - standalone: true + imports: [...]
//   - @defer com trigger "on viewport"
//   - @placeholder e @loading
//   - @let pra simplificar o template
// ============================================================================

import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokemonDetalhesPesadoComponent } from './pokemon-detalhes-pesado.component';

@Component({
    selector: 'app-pokemon-card',
    standalone: true,
    imports: [
        CommonModule,
        // ⚠️ O componente pesado precisa estar nos imports do componente que
        //    o usa dentro de um @defer. O bundler vê o import dinâmico que o
        //    @defer gera e separa em chunk próprio.
        PokemonDetalhesPesadoComponent
    ],
    templateUrl: './pokemon-card.component.html',
    styles: [`
        :host {
            display: block;
            border: 1px solid #ddd;
            border-radius: 12px;
            padding: 16px;
            margin: 16px 0;
            font-family: system-ui, sans-serif;
            background: #fff;
        }
        h3 { margin: 0 0 8px; text-transform: capitalize; }
        .id { color: #888; font-size: 14px; }
        .placeholder {
            padding: 12px;
            background: #f7f7f7;
            border-radius: 8px;
            color: #999;
            font-style: italic;
            margin-top: 12px;
        }
        .loading {
            padding: 12px;
            background: #fffbea;
            border-radius: 8px;
            color: #8a6d3b;
            margin-top: 12px;
        }
    `]
})
export class PokemonCardComponent {
    @Input() pokemon!: { id: number; nome: string; tipos: string[] };
}
