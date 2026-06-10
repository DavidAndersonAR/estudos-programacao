// 🎯 DESAFIO DO MÓDULO 10 — Pokédex Mini Completa
//
// Objetivo:
// Construa uma mini Pokédex que renderize 8 pokémons em cards estilizados,
// cada card com imagem real (sprite oficial), gradiente CSS por tipo,
// e um botão de favorito que muda de ícone quando clicado.
//
// Requisitos:
// 1. PokemonCardComponent (em pokemon-card.component.ts):
//    - @Input pokemon: { id, name, types: string[] }
//    - @Input favoritado: boolean
//    - @Output favorito: EventEmitter<number>
//    - Imagem usando: https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png
//    - Aplicar classe CSS dinâmica baseada no primeiro tipo
// 2. AppComponent (este arquivo):
//    - Lista de 8 pokémons hardcoded (a lista já está abaixo)
//    - Estado: Set<number> de ids favoritados
//    - Método toggleFavorito(id) que adiciona/remove do Set
//    - Renderizar cards passando [favoritado] = ids.has(p.id)
//    - Estilo CSS no styles[] com gradiente por classe (type-fire, type-water etc.)
//
// 💡 Dicas:
//   - new Set<number>() + set.has(id) + set.add(id) / set.delete(id)
//   - Use linear-gradient nas classes .type-fire, .type-water etc.
//   - Sprite PokeAPI: ids 1, 4, 7, 25, 39, 54, 94, 133 ficam bons (Bulba, Char, Squirt, Pika, Jiggly, Psyduck, Gengar, Eevee)
//
// Rode com `ng serve` no projeto Angular.

import { Component } from '@angular/core';
import { Pokemon, PokemonCardComponent } from './pokemon-card.component';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [PokemonCardComponent],
    templateUrl: './app.component.html',
    styles: [`
        /* TODO: adicione gradientes por tipo (.type-fire, .type-water, etc.) */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            padding: 1rem;
        }
    `]
})
export class AppComponent {
    // 8 pokémons hardcoded — não mexa, use como entrada
    pokemons: Pokemon[] = [
        { id:   1, name: 'Bulbasaur',  types: ['grass', 'poison'] },
        { id:   4, name: 'Charmander', types: ['fire'] },
        { id:   7, name: 'Squirtle',   types: ['water'] },
        { id:  25, name: 'Pikachu',    types: ['electric'] },
        { id:  39, name: 'Jigglypuff', types: ['normal', 'fairy'] },
        { id:  54, name: 'Psyduck',    types: ['water'] },
        { id:  94, name: 'Gengar',     types: ['ghost', 'poison'] },
        { id: 133, name: 'Eevee',      types: ['normal'] }
    ];

    // TODO: declare um Set<number> pra guardar os ids favoritados
    // favoritos = new Set<number>();

    // TODO: método que recebe um id e alterna no Set
    // toggleFavorito(id: number): void { ... }

    // TODO: método auxiliar pra checar se um id está favoritado
    // estaFavoritado(id: number): boolean { ... }
}

// ============================
// SOLUÇÃO DE REFERÊNCIA (descomente pra conferir)
// ============================

/*
import { Component } from '@angular/core';
import { Pokemon, PokemonCardComponent } from './pokemon-card.component';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [PokemonCardComponent],
    templateUrl: './app.component.html',
    styles: [`
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 1rem;
            padding: 1rem;
            font-family: system-ui, sans-serif;
        }

        // Estilo base dos cards (será aplicado no pokemon-card via :host ou classe global)
        ::ng-deep .card {
            border-radius: 12px;
            padding: 1rem;
            color: #fff;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        ::ng-deep .sprite { width: 96px; height: 96px; image-rendering: pixelated; }
        ::ng-deep .badges { display: flex; gap: 0.4rem; justify-content: center; margin: 0.5rem 0; }
        ::ng-deep .badge {
            background: rgba(255,255,255,0.25);
            padding: 0.2rem 0.6rem;
            border-radius: 999px;
            font-size: 0.75rem;
        }
        ::ng-deep .fav {
            background: rgba(0,0,0,0.25);
            color: #fff;
            border: none;
            padding: 0.4rem 0.8rem;
            border-radius: 8px;
            cursor: pointer;
        }

        // Gradientes por tipo
        ::ng-deep .type-fire     { background: linear-gradient(135deg, #ff7e5f, #feb47b); }
        ::ng-deep .type-water    { background: linear-gradient(135deg, #2193b0, #6dd5ed); }
        ::ng-deep .type-grass    { background: linear-gradient(135deg, #56ab2f, #a8e063); }
        ::ng-deep .type-electric { background: linear-gradient(135deg, #f7971e, #ffd200); color: #333; }
        ::ng-deep .type-ghost    { background: linear-gradient(135deg, #5614b0, #dbd65c); }
        ::ng-deep .type-normal   { background: linear-gradient(135deg, #757f9a, #d7dde8); color: #333; }
    `]
})
export class AppComponent {
    pokemons: Pokemon[] = [
        { id:   1, name: 'Bulbasaur',  types: ['grass', 'poison'] },
        { id:   4, name: 'Charmander', types: ['fire'] },
        { id:   7, name: 'Squirtle',   types: ['water'] },
        { id:  25, name: 'Pikachu',    types: ['electric'] },
        { id:  39, name: 'Jigglypuff', types: ['normal', 'fairy'] },
        { id:  54, name: 'Psyduck',    types: ['water'] },
        { id:  94, name: 'Gengar',     types: ['ghost', 'poison'] },
        { id: 133, name: 'Eevee',      types: ['normal'] }
    ];

    favoritos = new Set<number>();

    toggleFavorito(id: number): void {
        if (this.favoritos.has(id)) {
            this.favoritos.delete(id);
        } else {
            this.favoritos.add(id);
        }
    }

    estaFavoritado(id: number): boolean {
        return this.favoritos.has(id);
    }
}
*/
