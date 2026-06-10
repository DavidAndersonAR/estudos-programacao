// lista-pokemons.component.ts — lista todos os pokémons (do PokemonService).
// Cada item é um link pra /pokemons/:id usando a forma com array dinâmico.

import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
// Assumindo um service do módulo 11. Se você ainda não tem, troque por um array fake.
import { PokemonService } from '../services/pokemon.service';

@Component({
  selector: 'app-lista-pokemons',
  standalone: true,
  imports: [RouterLink],
  template: `
    <h2>Pokémons</h2>

    <ul>
      @for (poke of pokemons; track poke.id) {
        <li>
          <!-- Forma dinâmica do routerLink: array com partes da URL.
               O Angular monta '/pokemons/' + poke.id pra você. -->
          <a [routerLink]="['/pokemons', poke.id]">
            #{{ poke.id }} — {{ poke.nome }}
          </a>
        </li>
      }
    </ul>
  `,
})
export class ListaPokemonsComponent {
  // inject() é a forma moderna de injetar dependências (Angular 14+).
  private service = inject(PokemonService);
  pokemons = this.service.listar();
}
