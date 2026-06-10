// ============================================================================
// DESAFIO — pokemon-lista.component.ts
// ----------------------------------------------------------------------------
// SOLUÇÃO. Grid de pokémons, cada um vira um link pra rota /pokemon/:id.
// 100% standalone. Usa @let pra encurtar o template.
// ============================================================================

import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

// Tipo simples — em projeto real moraria em um models/pokemon.model.ts
export interface PokemonResumo {
    id: number;
    nome: string;
    tipos: string[];
    cor: string;
}

// Dados in-memory pra não depender de API nesse exemplo.
const POKEMONS: PokemonResumo[] = [
    { id: 1,  nome: 'bulbasaur',  tipos: ['grass', 'poison'], cor: '#78c850' },
    { id: 4,  nome: 'charmander', tipos: ['fire'],            cor: '#f08030' },
    { id: 7,  nome: 'squirtle',   tipos: ['water'],           cor: '#6890f0' },
    { id: 25, nome: 'pikachu',    tipos: ['electric'],        cor: '#f8d030' },
    { id: 39, nome: 'jigglypuff', tipos: ['fairy', 'normal'], cor: '#ee99ac' },
    { id: 94, nome: 'gengar',     tipos: ['ghost', 'poison'], cor: '#705898' },
];

@Component({
    selector: 'app-pokemon-lista',
    standalone: true,
    imports: [CommonModule, RouterLink],
    templateUrl: './pokemon-lista.component.html',
    styles: [`
        :host { display: block; }
        h2 { margin-top: 0; }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 16px;
        }
        .card {
            display: block; padding: 16px; border-radius: 12px;
            color: #fff; text-decoration: none; text-transform: capitalize;
            transition: transform .15s; cursor: pointer;
        }
        .card:hover { transform: translateY(-2px); }
        .card .id { display: block; font-size: 12px; opacity: .8; }
        .card .nome { font-size: 18px; font-weight: 600; }
        .card .tipos { font-size: 13px; margin-top: 4px; opacity: .9; }
    `]
})
export class PokemonListaComponent {
    pokemons = POKEMONS;
}
