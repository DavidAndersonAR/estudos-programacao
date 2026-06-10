/*
 * DESAFIO — not-found.component.ts
 * Página 404 com link de volta. Acionada pelo wildcard '**'.
 */

import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [RouterLink],
  template: `
    <div style="text-align: center; padding: 64px 16px;">
      <h1 style="font-size: 6em; margin: 0; color: #ef4444;">404</h1>
      <p>Essa página fugiu pra Pokébola errada.</p>
      <a routerLink="/pokemons">← Voltar pra Pokédex</a>
    </div>
  `,
})
export class NotFoundComponent {}
