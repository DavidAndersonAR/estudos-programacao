// Pratica — App raiz
// Demonstra os 2 componentes lado a lado pra você comparar as abordagens.

import { Component } from '@angular/core';
import { BuscaTemplateComponent } from './busca-template.component';
import { BuscaReactiveComponent } from './busca-reactive.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [BuscaTemplateComponent, BuscaReactiveComponent],
  template: `
    <h1>Módulo 13 — Forms (prática)</h1>
    <p>Compare as duas abordagens. Abra o console pra ver os submits.</p>

    <div class="grid">
      <app-busca-template />
      <app-busca-reactive />
    </div>
  `,
  styles: [`
    h1 { font-family: sans-serif; }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1rem;
    }
    :host ::ng-deep .card {
      border: 1px solid #ccc;
      padding: 1rem;
      border-radius: 8px;
      font-family: sans-serif;
    }
    :host ::ng-deep label { display: block; margin-top: .5rem; }
    :host ::ng-deep input, :host ::ng-deep select { width: 100%; padding: .4rem; }
    :host ::ng-deep .erro { color: crimson; font-size: .85rem; }
    :host ::ng-deep .acoes { margin-top: .8rem; display: flex; gap: .5rem; }
    :host ::ng-deep .debug { font-size: .8rem; color: #666; }
  `],
})
export class AppComponent {}
