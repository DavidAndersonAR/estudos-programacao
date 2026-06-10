// =============================================================================
// DESAFIO — FavoritosComponent
// =============================================================================
//
// Componente que mostra APENAS os pokémons favoritados, além do "último visto".
//
// Reatividade: este componente compartilha a MESMA instância de PokedexStore
// com o ListaComponent. Marcou favorito lá, aparece aqui automaticamente.
//
// TODOs:
//   1. Injete a store.
//   2. No template, mostre:
//      - listaFavoritos() em <ul>
//      - botão "remover" por item (toggleFavorito)
//      - botão "Limpar tudo" (limparFavoritos), desabilitado se vazio
//      - se temUltimoVisto(): mostre o ID em ultimoVisto()
//
// =============================================================================

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokedexStore } from '../pokedex-store.service';

@Component({
    selector: 'app-favoritos',
    standalone: true,
    imports: [CommonModule],
    template: `
        <!-- TODO: implemente o template -->
        <p>Favoritos (não implementado)</p>
    `,
})
export class FavoritosComponent {
    readonly store = inject(PokedexStore);
}


// =============================================================================
// SOLUÇÃO
// =============================================================================
/*
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokedexStore } from '../pokedex-store.service';

@Component({
    selector: 'app-favoritos',
    standalone: true,
    imports: [CommonModule],
    template: `
        <section style="padding: 12px; background: #fff8e1; border: 1px solid #ddd;">
            <h2>Favoritos ({{ store.totalFavoritos() }})</h2>

            <p *ngIf="store.totalFavoritos() === 0">
                Nenhum favorito ainda. Marque um ★ na lista ao lado.
            </p>

            <ul *ngIf="store.totalFavoritos() > 0">
                <li *ngFor="let p of store.listaFavoritos()">
                    #{{ p.id }} — {{ p.nome }}
                    <button (click)="store.toggleFavorito(p.id)">remover</button>
                </li>
            </ul>

            <button
                (click)="store.limparFavoritos()"
                [disabled]="store.totalFavoritos() === 0">
                Limpar tudo
            </button>

            <hr />

            <p *ngIf="store.temUltimoVisto()">
                👁 Último visto: <strong>#{{ store.ultimoVisto() }}</strong>
            </p>
            <p *ngIf="!store.temUltimoVisto()">
                <em>Clique no nome de um pokémon na lista pra registrar visita.</em>
            </p>
        </section>
    `,
})
export class FavoritosComponent {
    readonly store = inject(PokedexStore);
}
*/
