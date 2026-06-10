// ============================================================================
// PRATICA — app.component.ts
// ----------------------------------------------------------------------------
// Componente raiz, 100% standalone. Renderiza vários PokemonCards pra você
// ver na DevTools (aba Network) que os chunks do detalhes-pesado só descem
// quando cada card entra na viewport.
// ============================================================================

import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokemonCardComponent } from './components/pokemon-card.component';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [CommonModule, PokemonCardComponent],
    templateUrl: './app.component.html',
    styles: [`
        :host { display: block; max-width: 720px; margin: 0 auto; padding: 24px; }
        h1 { font-family: system-ui, sans-serif; }
        .dica {
            background: #f0f7ff; border-left: 4px solid #4a90e2;
            padding: 12px 16px; margin-bottom: 24px; border-radius: 6px;
        }
        .espaco { height: 80vh; } /* força scroll pra você ver o @defer agindo */
    `]
})
export class AppComponent {
    // Lista fake — 4 pokémons. Repare como os 2 últimos ficam escondidos
    // pela <div class="espaco"> ate você scrollar.
    pokemons = [
        { id: 1,  nome: 'bulbasaur',  tipos: ['grass', 'poison'] },
        { id: 4,  nome: 'charmander', tipos: ['fire'] },
        { id: 7,  nome: 'squirtle',   tipos: ['water'] },
        { id: 25, nome: 'pikachu',    tipos: ['electric'] },
    ];
}
