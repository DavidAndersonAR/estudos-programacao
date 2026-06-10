// Módulo 10 — Componentes e Templates
// Prática: componente PokemonCard (standalone) com @Input e @Output.
//
// Conceitos demonstrados:
// - Decorator @Component com standalone
// - @Input() pra receber dados do pai
// - @Output() com EventEmitter pra avisar o pai
// - Tipagem do objeto Pokemon via interface

import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

// Interface descrevendo a "forma" de um Pokémon
export interface Pokemon {
    id: number;
    name: string;
    types: string[];
}

@Component({
    selector: 'app-pokemon-card',
    standalone: true,
    imports: [CommonModule], // necessário pra usar pipes built-in
    templateUrl: './pokemon-card.component.html'
})
export class PokemonCardComponent {
    // ⬇️ @Input: recebe o pokémon do componente pai
    // O `!` é o "definite assignment" — promete que o pai vai passar.
    @Input() pokemon!: Pokemon;

    // ⬇️ @Output: emite eventos pro pai (no caso, o id do favoritado)
    @Output() favorito = new EventEmitter<number>();

    // Método chamado pelo (click) no template
    aoFavoritar(): void {
        this.favorito.emit(this.pokemon.id);
    }
}
