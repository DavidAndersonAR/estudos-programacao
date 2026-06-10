// home.component.ts — página inicial simples com link pra lista.

import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-home',
  standalone: true,
  // Precisamos importar RouterLink pra usar a diretiva no template.
  imports: [RouterLink],
  template: `
    <h1>Pokédex</h1>
    <p>Bem-vindo! Confira sua lista de pokémons:</p>

    <!-- routerLink="/pokemons" navega SEM recarregar a página.
         Nunca use <a href="/pokemons"> em SPA — quebra o SPA. -->
    <a routerLink="/pokemons">Ver pokémons →</a>
  `,
})
export class HomeComponent {}
