// 🎯 DESAFIO — PokemonCard completo
//
// Implemente o componente PokemonCard com:
//   - @Input pokemon: { id, name, types: string[] }
//   - @Input favoritado: boolean (controlado pelo pai)
//   - @Output favorito: EventEmitter<number> que emite o id
//   - Exibir IMAGEM do pokémon usando a URL:
//       https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png
//   - Botão favoritar que muda de ícone: ⭐ (favoritado) / ☆ (não)
//   - Aplicar uma classe CSS por tipo do primeiro elemento de `types`
//     (ex.: "type-fire", "type-water") pra o pai estilizar com gradient
//
// Use o template HTML separado.

import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface Pokemon {
    id: number;
    name: string;
    types: string[];
}

@Component({
    selector: 'app-pokemon-card',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './pokemon-card.component.html'
})
export class PokemonCardComponent {
    // TODO: declare os @Input e @Output aqui
    // @Input() pokemon!: Pokemon;
    // @Input() favoritado: boolean = false;
    // @Output() favorito = new EventEmitter<number>();

    // TODO: método que monta a URL da imagem a partir do id
    // imagemUrl(): string { ... }

    // TODO: método que retorna a classe CSS baseada no primeiro tipo
    // classeTipo(): string { ... }

    // TODO: método chamado pelo click do botão favoritar
    // aoFavoritar(): void { ... }
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
// ============================

/*
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface Pokemon {
    id: number;
    name: string;
    types: string[];
}

@Component({
    selector: 'app-pokemon-card',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './pokemon-card.component.html'
})
export class PokemonCardComponent {
    @Input() pokemon!: Pokemon;
    @Input() favoritado: boolean = false;
    @Output() favorito = new EventEmitter<number>();

    imagemUrl(): string {
        return `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${this.pokemon.id}.png`;
    }

    classeTipo(): string {
        const tipo = this.pokemon.types[0] ?? 'normal';
        return `type-${tipo}`;
    }

    aoFavoritar(): void {
        this.favorito.emit(this.pokemon.id);
    }
}
*/
