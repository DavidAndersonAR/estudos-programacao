// pokemon.service.ts — mesmo service do pratica/, reutilizado aqui.
// (Em projeto real, ficaria num lugar compartilhado.)

import { Injectable } from '@angular/core';

export interface Pokemon {
  id: number;
  nome: string;
  tipo: string;
  hp: number;
}

@Injectable({ providedIn: 'root' })
export class PokemonService {
  private pokemons: Pokemon[] = [
    { id: 1, nome: 'Bulbasaur', tipo: 'Planta', hp: 45 },
    { id: 4, nome: 'Charmander', tipo: 'Fogo', hp: 39 },
    { id: 7, nome: 'Squirtle', tipo: 'Água', hp: 44 },
    { id: 25, nome: 'Pikachu', tipo: 'Elétrico', hp: 35 },
    { id: 39, nome: 'Jigglypuff', tipo: 'Fada', hp: 115 },
    { id: 133, nome: 'Eevee', tipo: 'Normal', hp: 55 },
  ];

  listar(): Pokemon[] {
    return this.pokemons;
  }

  buscarPorId(id: number): Pokemon | undefined {
    return this.pokemons.find(p => p.id === id);
  }
}
