/*
 * DESAFIO — detalhe-pokemon.component.ts
 * Detalhe do pokémon com botão "← Voltar".
 *
 * Requisitos:
 *  - Lê :id da rota (ActivatedRoute.snapshot.paramMap)
 *  - Mostra todos os campos do pokémon
 *  - Botão "← Voltar" usa Location.back() OU routerLink="/pokemons"
 *  - Se id inválido (pokemon undefined), mostra mensagem
 */

import { Component, inject } from '@angular/core';
// TODO: importe ActivatedRoute, RouterLink
// TODO (opção avançada): importe Location de '@angular/common'
import { PokemonService } from '../services/pokemon.service';

@Component({
  selector: 'app-detalhe-pokemon',
  standalone: true,
  imports: [/* TODO */],
  template: `
    <!-- TODO: card com detalhes e botão voltar -->
  `,
})
export class DetalhePokemonComponent {
  // TODO: injetar ActivatedRoute e PokemonService
  // TODO: ler id, buscar pokémon
  // TODO (opção avançada): método voltar() chamando Location.back()
}

/* ----------------------------------------------------------------
 * SOLUÇÃO
 * ----------------------------------------------------------------

import { Component, inject } from '@angular/core';
import { Location } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { PokemonService } from '../services/pokemon.service';

@Component({
  selector: 'app-detalhe-pokemon',
  standalone: true,
  imports: [RouterLink],
  template: `
    @if (pokemon) {
      <button (click)="voltar()">← Voltar</button>

      <article class="card">
        <header>
          <span class="id">#{{ pokemon.id }}</span>
          <h2>{{ pokemon.nome }}</h2>
        </header>
        <dl>
          <dt>Tipo</dt><dd>{{ pokemon.tipo }}</dd>
          <dt>HP</dt><dd>{{ pokemon.hp }}</dd>
        </dl>
      </article>
    } @else {
      <p>Pokémon não encontrado.</p>
      <a routerLink="/pokemons">← Voltar pra lista</a>
    }
  `,
  styles: [`
    button {
      background: none; border: 1px solid #cbd5e1;
      padding: 6px 12px; border-radius: 6px; cursor: pointer;
      margin-bottom: 16px;
    }
    button:hover { background: #f1f5f9; }
    .card {
      max-width: 400px; padding: 24px;
      border: 1px solid #e5e7eb; border-radius: 12px;
    }
    .id { color: #9ca3af; font-size: 0.9em; }
    h2 { margin: 4px 0 16px; }
    dl { display: grid; grid-template-columns: 80px 1fr; gap: 8px 16px; margin: 0; }
    dt { font-weight: bold; color: #6b7280; }
    dd { margin: 0; }
  `],
})
export class DetalhePokemonComponent {
  private route = inject(ActivatedRoute);
  private service = inject(PokemonService);
  // Location é um service do @angular/common que dá acesso ao histórico do navegador.
  // back() = mesma coisa que o botão "voltar" do browser.
  private location = inject(Location);

  private id = Number(this.route.snapshot.paramMap.get('id')!);
  pokemon = this.service.buscarPorId(this.id);

  voltar() {
    this.location.back();
  }
}

 * ---------------------------------------------------------------- */
