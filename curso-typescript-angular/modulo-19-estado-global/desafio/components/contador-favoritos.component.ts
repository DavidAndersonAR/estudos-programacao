// =============================================================================
// DESAFIO — ContadorFavoritosComponent
// =============================================================================
//
// Componente MINÚSCULO — única responsabilidade: mostrar o badge "★ N" no
// header. Existe pra provar que mesmo componentes pequenos e isolados
// reagem em tempo real ao mesmo estado global.
//
// Compare com a alternativa de prop drilling: o AppComponent precisaria
// receber o total, passar pro HeaderComponent, que passaria pro
// ContadorComponent. Aqui, basta injetar a store.
//
// TODOs:
//   1. Injete a store.
//   2. No template, mostre "★ {{ store.totalFavoritos() }}".
//   3. (Opcional) destaque visual quando totalFavoritos() > 0.
//
// =============================================================================

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokedexStore } from '../pokedex-store.service';

@Component({
    selector: 'app-contador-favoritos',
    standalone: true,
    imports: [CommonModule],
    template: `
        <!-- TODO: implemente o template -->
        <span>★ ?</span>
    `,
})
export class ContadorFavoritosComponent {
    readonly store = inject(PokedexStore);
}


// =============================================================================
// SOLUÇÃO
// =============================================================================
/*
import { Component, inject, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PokedexStore } from '../pokedex-store.service';

@Component({
    selector: 'app-contador-favoritos',
    standalone: true,
    imports: [CommonModule],
    template: `
        <span
            [style.background]="ativo() ? '#ffd54f' : '#eee'"
            [style.padding]="'4px 8px'"
            [style.borderRadius]="'12px'"
            [style.fontWeight]="ativo() ? 'bold' : 'normal'">
            ★ {{ store.totalFavoritos() }}
        </span>
    `,
})
export class ContadorFavoritosComponent {
    readonly store = inject(PokedexStore);

    // Computed local que deriva da signal do store — tudo reativo.
    readonly ativo = computed(() => this.store.totalFavoritos() > 0);
}
*/
