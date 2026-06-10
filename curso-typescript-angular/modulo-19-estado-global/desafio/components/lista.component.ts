// =============================================================================
// DESAFIO — ListaComponent
// =============================================================================
//
// Componente que mostra a LISTA filtrada de pokémons e permite:
//   - digitar no campo de busca (atualiza store.filtroBusca via setFiltroBusca)
//   - clicar num botão "★" pra alternar favorito
//   - clicar no nome pra registrar visita (registrarVisita)
//
// O componente NÃO tem estado próprio. Tudo vem da store.
// Outros componentes (favoritos.component, contador-favoritos.component)
// reagem automaticamente — porque consomem as mesmas signals.
//
// TODOs:
//   1. Injete PokedexStore.
//   2. No ngOnInit (ou direto na propriedade), chame store.definirPokemons
//      com uma lista mockada de pelo menos 5 pokémons.
//   3. Implemente o template com:
//      - <input> bindado a store.filtroBusca (use (input) + setFiltroBusca)
//      - *ngFor sobre store.pokemonsFiltrados()
//      - botão por linha que chama store.toggleFavorito(p.id)
//      - clique no nome chama store.registrarVisita(p.id)
//   4. Mostre visualmente quais já são favoritos (★ vs ☆).
//
// =============================================================================

import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokedexStore, Pokemon } from '../pokedex-store.service';

@Component({
    selector: 'app-lista',
    standalone: true,
    imports: [CommonModule],
    template: `
        <!-- TODO: implemente o template -->
        <p>Lista (não implementada)</p>
    `,
})
export class ListaComponent implements OnInit {
    // TODO 1: injete a store
    readonly store = inject(PokedexStore);

    ngOnInit(): void {
        // TODO 2: alimente o cache com dados mockados
    }

    // TODO 3+4: métodos auxiliares
}


// =============================================================================
// SOLUÇÃO
// =============================================================================
/*
import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokedexStore, Pokemon } from '../pokedex-store.service';

@Component({
    selector: 'app-lista',
    standalone: true,
    imports: [CommonModule],
    template: `
        <section style="padding: 12px; border: 1px solid #ddd;">
            <h2>Catálogo</h2>

            <input
                type="text"
                placeholder="Buscar por nome..."
                [value]="store.filtroBusca()"
                (input)="onBusca($event)"
            />

            <p>
                Mostrando <strong>{{ store.pokemonsFiltrados().length }}</strong>
                de {{ store.pokemons().length }}
            </p>

            <ul>
                <li *ngFor="let p of store.pokemonsFiltrados()">
                    <button (click)="store.toggleFavorito(p.id)">
                        {{ store.ehFavorito(p.id) ? '★' : '☆' }}
                    </button>
                    <a href="javascript:void(0)" (click)="store.registrarVisita(p.id)">
                        #{{ p.id }} — {{ p.nome }}
                    </a>
                    <em>({{ p.tipos.join(', ') }})</em>
                </li>
            </ul>
        </section>
    `,
})
export class ListaComponent implements OnInit {
    readonly store = inject(PokedexStore);

    ngOnInit(): void {
        const mock: Pokemon[] = [
            { id: 1,  nome: 'Bulbasaur',  tipos: ['grass', 'poison'] },
            { id: 4,  nome: 'Charmander', tipos: ['fire'] },
            { id: 7,  nome: 'Squirtle',   tipos: ['water'] },
            { id: 25, nome: 'Pikachu',    tipos: ['electric'] },
            { id: 39, nome: 'Jigglypuff', tipos: ['normal', 'fairy'] },
            { id: 94, nome: 'Gengar',     tipos: ['ghost', 'poison'] },
        ];
        this.store.definirPokemons(mock);
    }

    onBusca(evt: Event): void {
        const valor = (evt.target as HTMLInputElement).value;
        this.store.setFiltroBusca(valor);
    }
}
*/
