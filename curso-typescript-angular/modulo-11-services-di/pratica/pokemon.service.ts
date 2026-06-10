// pokemon.service.ts
// Service simples com dados mockados — singleton de app via providedIn: 'root'.
//
// Como seria gerado pela CLI:
//   ng generate service pokemon
//
// O @Injectable diz ao Angular: "essa classe é injetável".
// O providedIn: 'root' garante 1 única instância pra app inteira (tree-shakable).

import { Injectable } from '@angular/core';
import { Pokemon } from './pokemon.model';

@Injectable({ providedIn: 'root' })
export class PokemonService {

    // Dados mockados — no mundo real viriam de uma API (módulo 14).
    private readonly pokemons: Pokemon[] = [
        { id: 1, name: 'Bulbasaur',  types: ['grass', 'poison'] },
        { id: 4, name: 'Charmander', types: ['fire'] },
        { id: 7, name: 'Squirtle',   types: ['water'] },
        { id: 25, name: 'Pikachu',   types: ['electric'] },
        { id: 39, name: 'Jigglypuff', types: ['normal', 'fairy'] },
    ];

    listar(): Pokemon[] {
        return this.pokemons;
    }
}
