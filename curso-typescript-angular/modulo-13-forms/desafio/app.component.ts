// DESAFIO — App raiz
// Integra o FiltrosPokemonsComponent e reage ao @Output filtrosMudaram.

import { Component } from '@angular/core';
import { FiltrosPokemonsComponent } from './filtros-pokemons.component';

// Mesmo tipo declarado no componente de filtros (em projeto real, exporte de um arquivo só)
interface FiltrosPokemon {
  busca: string;
  tipo: string;
  apenasFavoritos: boolean;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [FiltrosPokemonsComponent],
  template: `
    <h1>Módulo 13 — Desafio: Filtros do Pokedex</h1>

    <!-- Escuta o @Output e chama aoMudarFiltros -->
    <app-filtros-pokemons (filtrosMudaram)="aoMudarFiltros($event)" />

    <section class="resultado">
      <h3>Filtros atuais</h3>
      @if (filtros) {
        <pre>{{ filtros | json }}</pre>
      } @else {
        <p><em>Nenhum filtro emitido ainda — interaja com o form.</em></p>
      }
    </section>
  `,
  styles: [`
    :host { font-family: sans-serif; display: block; max-width: 600px; margin: 1rem; }
    pre { background: #f4f4f4; padding: .6rem; border-radius: 6px; }
    :host ::ng-deep .filtros { border: 1px solid #ccc; padding: 1rem; border-radius: 8px; }
    :host ::ng-deep label { display: block; margin-top: .5rem; }
    :host ::ng-deep input[type=text], :host ::ng-deep select { width: 100%; padding: .4rem; }
    :host ::ng-deep .check { display: flex; gap: .4rem; align-items: center; }
    :host ::ng-deep .erro { color: crimson; font-size: .85rem; }
    :host ::ng-deep .acoes { margin-top: .8rem; }
  `],
})
export class AppComponent {
  filtros: FiltrosPokemon | null = null;

  aoMudarFiltros(f: FiltrosPokemon) {
    this.filtros = f;
    console.log('filtros emitidos:', f);
    // Em um app real, aqui chamaria o service:
    // this.pokemonService.listar(f).subscribe(...)
  }
}
