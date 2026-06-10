// app.component.ts
// Componente que consome o PokemonService via inject() (Angular 14+).
//
// Note: NÃO precisamos declarar PokemonService em providers — como ele usa
// providedIn: 'root', o Angular já sabe entregar a instância singleton.

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokemonService } from './pokemon.service';
import { Pokemon } from './pokemon.model';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [CommonModule],
    template: `
        <h1>Pokédex (mock)</h1>

        <ul>
            <li *ngFor="let p of pokemons">
                <strong>#{{ p.id }}</strong> — {{ p.name }}
                <em>({{ p.types.join(', ') }})</em>
            </li>
        </ul>

        <p>Total: {{ pokemons.length }} pokémons</p>
    `,
})
export class AppComponent {
    // Forma moderna: inject() ao invés de constructor injection.
    // Equivalente antigo seria: constructor(private pokemonService: PokemonService) {}
    private pokemonService = inject(PokemonService);

    pokemons: Pokemon[] = this.pokemonService.listar();
}
