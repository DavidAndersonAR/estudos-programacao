// app.component — usa o PokemonCardComponent 3 vezes
// e escuta o evento (favorito) emitido pelo filho.

import { Component } from '@angular/core';
import { Pokemon, PokemonCardComponent } from './pokemon-card.component';

@Component({
    selector: 'app-root',
    standalone: true,
    // Importa o componente filho pra poder usar a tag <app-pokemon-card>
    imports: [PokemonCardComponent],
    templateUrl: './app.component.html'
})
export class AppComponent {
    // Lista hardcoded de 3 pokémons iniciais
    pokemons: Pokemon[] = [
        { id: 1, name: 'Bulbasaur',  types: ['grass', 'poison'] },
        { id: 4, name: 'Charmander', types: ['fire'] },
        { id: 7, name: 'Squirtle',   types: ['water'] }
    ];

    // Método chamado quando o filho emite o evento (favorito)
    quandoFavoritar(id: number): void {
        console.log('Pokémon favoritado, id =', id);
    }
}
