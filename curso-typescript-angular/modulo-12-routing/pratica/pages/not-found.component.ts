// not-found.component.ts — página 404 simples.
// Acionada pelo wildcard '**' em app.routes.ts.

import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-not-found',
  standalone: true,
  imports: [RouterLink],
  template: `
    <h2>404 — Página não encontrada</h2>
    <p>A URL que você acessou não existe.</p>
    <a routerLink="/">Voltar pra Home</a>
  `,
})
export class NotFoundComponent {}
