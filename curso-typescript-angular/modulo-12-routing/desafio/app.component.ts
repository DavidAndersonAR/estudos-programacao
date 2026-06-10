/*
 * DESAFIO — app.component.ts
 * Navbar com routerLinkActive (destaque na rota atual) + <router-outlet />.
 *
 * Dica: routerLinkActive recebe o nome de uma classe CSS que é aplicada
 * quando a rota do link bate com a URL atual.
 *
 * Para o link "Home" (que aponta pra '/' mas redireciona pra '/pokemons'),
 * use [routerLinkActiveOptions]="{ exact: true }" pra não acender em qualquer URL.
 */

import { Component } from '@angular/core';
// TODO: importe RouterOutlet, RouterLink e RouterLinkActive

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [/* TODO */],
  template: `
    <!-- TODO: navbar com 3 links (Pokémons, Favoritos) usando routerLinkActive -->
    <!-- TODO: <router-outlet /> -->
  `,
  styles: [`
    /* TODO: classe .ativo com cor diferente / negrito */
  `],
})
export class AppComponent {}

/* ----------------------------------------------------------------
 * SOLUÇÃO
 * ----------------------------------------------------------------

import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <nav>
      <a routerLink="/pokemons" routerLinkActive="ativo">Pokémons</a>
      <a routerLink="/favoritos" routerLinkActive="ativo">Favoritos</a>
    </nav>

    <main>
      <router-outlet />
    </main>
  `,
  styles: [`
    nav {
      display: flex;
      gap: 16px;
      padding: 12px 20px;
      background: #1f2937;
      color: white;
    }
    nav a {
      color: #cbd5e1;
      text-decoration: none;
      padding: 6px 12px;
      border-radius: 6px;
      transition: background 0.2s;
    }
    nav a:hover { background: #374151; }
    nav a.ativo {
      background: #3b82f6;
      color: white;
      font-weight: bold;
    }
    main { padding: 24px; }
  `],
})
export class AppComponent {}

 * ---------------------------------------------------------------- */
