/*
 * DESAFIO — lista-pokemons.component.ts
 * Lista de pokémons em formato de CARDS (não <ul>).
 *
 * Requisitos:
 *  - @for sobre service.listar()
 *  - Cada card é um link clicável pra /pokemons/:id
 *  - Visual: grid de cards com borda, padding, hover
 */

import { Component, inject } from '@angular/core';
// TODO: importar RouterLink
import { PokemonService } from '../services/pokemon.service';

@Component({
  selector: 'app-lista-pokemons',
  standalone: true,
  imports: [/* TODO */],
  template: `
    <h2>Pokémons</h2>
    <!-- TODO: grid de cards com routerLink dinâmico -->
  `,
  styles: [`
    /* TODO: .grid, .card */
  `],
})
export class ListaPokemonsComponent {
  private service = inject(PokemonService);
  pokemons = this.service.listar();
}

/* ----------------------------------------------------------------
 * SOLUÇÃO
 * ----------------------------------------------------------------

import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { PokemonService } from '../services/pokemon.service';

@Component({
  selector: 'app-lista-pokemons',
  standalone: true,
  imports: [RouterLink],
  template: `
    <h2>Pokémons</h2>

    <div class="grid">
      @for (poke of pokemons; track poke.id) {
        <a [routerLink]="['/pokemons', poke.id]" class="card">
          <span class="id">#{{ poke.id }}</span>
          <h3>{{ poke.nome }}</h3>
          <small>{{ poke.tipo }}</small>
        </a>
      }
    </div>
  `,
  styles: [`
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 16px;
      margin-top: 16px;
    }
    .card {
      display: block;
      padding: 16px;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      text-decoration: none;
      color: inherit;
      transition: transform 0.15s, box-shadow 0.15s;
    }
    .card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .id { color: #9ca3af; font-size: 0.85em; }
    h3 { margin: 4px 0; }
    small { color: #6b7280; }
  `],
})
export class ListaPokemonsComponent {
  private service = inject(PokemonService);
  pokemons = this.service.listar();
}

 * ---------------------------------------------------------------- */
