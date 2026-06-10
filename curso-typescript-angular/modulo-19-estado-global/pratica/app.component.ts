// app.component.ts
// Demonstra reatividade global: três regiões da MESMA tela leem/mutam o mesmo
// store. Clicou num botão de uma região, as outras refletem na hora.
//
// Tudo aqui consome FavoritosStoreService via inject() — como ele é
// providedIn: 'root', as três "regiões" recebem a mesma instância.

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FavoritosStoreService } from './favoritos-store.service';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './app.component.html',
})
export class AppComponent {

    // Lista mockada — em um app real viria de um service de Pokémon.
    readonly catalogo = [
        { id: 1,  nome: 'Bulbasaur'  },
        { id: 4,  nome: 'Charmander' },
        { id: 7,  nome: 'Squirtle'   },
        { id: 25, nome: 'Pikachu'    },
        { id: 39, nome: 'Jigglypuff' },
    ];

    // Store global injetada — mesma instância em qualquer componente do app.
    readonly store = inject(FavoritosStoreService);

    // Métodos do template — apenas redirecionam para a store.
    // (poderiam chamar this.store.* direto no template, mas assim fica mais claro)
    toggle(id: number): void {
        this.store.toggle(id);
    }

    limpar(): void {
        this.store.limpar();
    }
}
