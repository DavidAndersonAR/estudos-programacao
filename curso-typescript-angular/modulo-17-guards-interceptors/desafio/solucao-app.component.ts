// solucao-app.component.ts
// Casca do app: nav (com login/logout reativo), router-outlet e overlay.

import { Component, inject } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';
import { AuthService } from './solucao-auth.service';
import { LoadingComponent } from './solucao-loading.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterLink, RouterOutlet, LoadingComponent],
  template: `
    <nav>
      <a routerLink="/">Home</a>
      <a routerLink="/favoritos">Favoritos</a>

      @if (auth.estaLogado()) {
        <span>Olá, {{ auth.usuarioLogado()?.nome }}</span>
        <button (click)="auth.logout()">Sair</button>
      } @else {
        <a routerLink="/login">Entrar</a>
      }
    </nav>

    <main>
      <router-outlet />
    </main>

    <!-- Overlay global escuta o LoadingService via signal. -->
    <app-loading />
  `,
  styles: [`
    nav { display: flex; gap: 1rem; padding: 1rem; border-bottom: 1px solid #ddd; align-items: center; }
    nav span { margin-left: auto; }
    main { padding: 1rem; }
  `],
})
export class AppComponent {
  protected auth = inject(AuthService);
}
