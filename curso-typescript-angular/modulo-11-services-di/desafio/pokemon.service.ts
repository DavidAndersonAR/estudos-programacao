// =============================================================================
// DESAFIO — PokemonService completo
// =============================================================================
//
// Crie um PokemonService com providedIn: 'root' que ofereça:
//
//   1. listar(): Pokemon[]                        → todos os pokémons
//   2. buscarPorId(id: number): Pokemon | undefined
//   3. filtrarPorTipo(tipo: string): Pokemon[]   → todos que contêm o tipo
//
// Dados: array mockado com 10 pokémons. Cada um tem { id, name, types[] }.
//
// Regras:
//   - O array de pokémons deve ser PRIVADO (encapsulamento).
//   - Os métodos devem ser pequenos e fáceis de testar.
//   - filtrarPorTipo deve ser case-insensitive ('FIRE' === 'fire').
//
// Use o AppComponent (em app.component.ts) para testar todos os métodos.
//
// =============================================================================

import { Injectable } from '@angular/core';

export interface Pokemon {
    id: number;
    name: string;
    types: string[];
}

@Injectable({ providedIn: 'root' })
export class PokemonService {

    // TODO 1: declare aqui um array privado readonly com 10 pokémons mockados.
    //         Use IDs reais e tipos coerentes. Sugestões:
    //         Bulbasaur, Charmander, Squirtle, Caterpie, Pidgey,
    //         Pikachu, Sandshrew, Clefairy, Vulpix, Jigglypuff
    private readonly pokemons: Pokemon[] = [];

    // TODO 2: implemente listar() retornando todos os pokémons.
    listar(): Pokemon[] {
        return [];
    }

    // TODO 3: implemente buscarPorId — retorne undefined se não achar.
    buscarPorId(id: number): Pokemon | undefined {
        return undefined;
    }

    // TODO 4: implemente filtrarPorTipo — case-insensitive.
    filtrarPorTipo(tipo: string): Pokemon[] {
        return [];
    }
}


// =============================================================================
// SOLUÇÃO (descomente após tentar resolver sozinho)
// =============================================================================
/*
import { Injectable } from '@angular/core';

export interface Pokemon {
    id: number;
    name: string;
    types: string[];
}

@Injectable({ providedIn: 'root' })
export class PokemonService {

    private readonly pokemons: Pokemon[] = [
        { id: 1,  name: 'Bulbasaur',   types: ['grass', 'poison'] },
        { id: 4,  name: 'Charmander',  types: ['fire'] },
        { id: 7,  name: 'Squirtle',    types: ['water'] },
        { id: 10, name: 'Caterpie',    types: ['bug'] },
        { id: 16, name: 'Pidgey',      types: ['normal', 'flying'] },
        { id: 25, name: 'Pikachu',     types: ['electric'] },
        { id: 27, name: 'Sandshrew',   types: ['ground'] },
        { id: 35, name: 'Clefairy',    types: ['fairy'] },
        { id: 37, name: 'Vulpix',      types: ['fire'] },
        { id: 39, name: 'Jigglypuff',  types: ['normal', 'fairy'] },
    ];

    listar(): Pokemon[] {
        return this.pokemons;
    }

    buscarPorId(id: number): Pokemon | undefined {
        return this.pokemons.find(p => p.id === id);
    }

    filtrarPorTipo(tipo: string): Pokemon[] {
        const alvo = tipo.toLowerCase();
        return this.pokemons.filter(p =>
            p.types.some(t => t.toLowerCase() === alvo)
        );
    }
}
*/
