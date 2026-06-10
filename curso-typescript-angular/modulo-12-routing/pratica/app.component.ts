// app.component.ts — componente raiz com navbar e <router-outlet />
//
// O <router-outlet /> é o "buraco" onde o Angular injeta o componente
// correspondente à rota atual. Sem ele, nenhuma rota aparece na tela.

import { Component } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  // Importamos RouterOutlet (pra ter o <router-outlet />) e RouterLink
  // (pra usar a diretiva routerLink nos <a>).
  imports: [RouterOutlet, RouterLink],
  template: `
    <nav style="padding: 12px; background: #eee; display: flex; gap: 16px;">
      <a routerLink="/">Home</a>
      <a routerLink="/pokemons">Pokémons</a>
    </nav>

    <main style="padding: 16px;">
      <!-- Aqui o Angular injeta o componente da rota atual -->
      <router-outlet />
    </main>
  `,
})
export class AppComponent {}
