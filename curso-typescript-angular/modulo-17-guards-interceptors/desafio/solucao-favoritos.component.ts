// solucao-favoritos.component.ts
// Tela protegida pelo authGuard. Mostra usuário logado e faz um fetch
// pra demonstrar interceptor (auth header + loading spinner).

import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AuthService } from './solucao-auth.service';

@Component({
  selector: 'app-favoritos',
  standalone: true,
  template: `
    <section>
      <h2>Favoritos de {{ auth.usuarioLogado()?.nome }}</h2>
      <button (click)="carregar()">Carregar favoritos</button>
      <button (click)="testar401()">Testar 401 (logout automático)</button>

      @if (dados) {
        <pre>{{ dados | json }}</pre>
      }
    </section>
  `,
})
export class FavoritosComponent {
  protected auth = inject(AuthService);
  private http = inject(HttpClient);

  dados: unknown = null;

  carregar(): void {
    // O authInterceptor adiciona o Bearer token automaticamente.
    // O loadingInterceptor mostra o overlay enquanto isso.
    this.http.get('https://jsonplaceholder.typicode.com/todos?_limit=3')
      .subscribe((res) => (this.dados = res));
  }

  testar401(): void {
    // Endpoint que responde 401 — o errorInterceptor vai deslogar.
    this.http.get('https://httpstat.us/401').subscribe({
      error: () => console.log('errorInterceptor cuidou do 401'),
    });
  }
}
