// ============================================================
// DESAFIO — Módulo 16: App que consome PokedexStateService
// ============================================================
//
// ENUNCIADO:
// Monte o AppComponent que usa o PokedexStateService:
//   - Carrega uma lista de pokémons de exemplo no ngOnInit
//   - Tem um <input> ligado a `definirFiltro`
//   - Mostra `pokemonsFiltrados` via @for usando o sub-componente PokemonCard
//   - Tem um botão "favoritar" em cada card que chama toggleFavorito
//   - Mostra a contagem de favoritos no topo
//
// O PokemonCard usa `input()` signal (Angular 17.3+) pra receber
// o pokémon do pai e `output()` signal pra emitir o "favoritar".
//
// COMO USAR:
// 1. Cole este arquivo em  src/app/app.component.ts
// 2. Cole app.component.html em  src/app/app.component.html
// 3. Cole pokedex-state.service.ts em  src/app/state/
// 4. ng serve
//
// COMECE AQUI ⬇️
// ============================================================

import { Component, OnInit, inject, input, output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { PokedexStateService, Pokemon } from './state/pokedex-state.service';

// -------------------------------------------------------------
// Sub-componente: PokemonCard
// Demonstra `input()` e `output()` signal (Angular 17.3+).
// -------------------------------------------------------------
@Component({
  selector: 'app-pokemon-card',
  standalone: true,
  imports: [],
  template: `
    <article style="border:1px solid #ddd; padding:12px; border-radius:8px; min-width:160px;">
      <h3 style="margin:0;">{{ pokemon().nome }}</h3>
      <small>#{{ pokemon().id }} — {{ pokemon().tipo }}</small>
      <br>
      <button (click)="favoritar.emit(pokemon().id)">
        {{ favorito() ? '★ favorito' : '☆ favoritar' }}
      </button>
    </article>
  `
})
export class PokemonCardComponent {
  // TODO 1: declare `pokemon` como input.required<Pokemon>()
  // TODO 2: declare `favorito` como input<boolean>(false)
  // TODO 3: declare `favoritar` como output<number>()
  pokemon = input.required<Pokemon>();
  favorito = input<boolean>(false);
  favoritar = output<number>();
}

// -------------------------------------------------------------
// Componente raiz: AppComponent
// -------------------------------------------------------------
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [FormsModule, PokemonCardComponent],
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {
  // inject() — forma moderna de receber dependências (Angular 14+).
  // Expõe o service direto no template como `state.xxx()`.
  state = inject(PokedexStateService);

  ngOnInit(): void {
    // TODO 4: chame state.setPokemons(...) com uma lista de exemplo.
    this.state.setPokemons([
      { id: 1,  nome: 'Bulbasaur',  tipo: 'grass'    },
      { id: 4,  nome: 'Charmander', tipo: 'fire'     },
      { id: 7,  nome: 'Squirtle',   tipo: 'water'    },
      { id: 25, nome: 'Pikachu',    tipo: 'electric' },
      { id: 39, nome: 'Jigglypuff', tipo: 'fairy'    }
    ]);
  }

  // Helper pro template — diz se um ID está nos favoritos.
  // É um método normal: o template chama toda hora, mas como ele lê
  // o signal `favoritos`, o Angular sabe quando re-checar.
  ehFavorito(id: number): boolean {
    return this.state.favoritos().includes(id);
  }

  // TODO 5: implemente onFiltroChange(texto) que chama state.definirFiltro.
  onFiltroChange(texto: string): void {
    this.state.definirFiltro(texto);
  }
}

/* ============================================================
   ✅ SOLUÇÃO COMENTADA — diferenças vs. o template acima:

   - PokemonCardComponent já está resolvido em cima como referência;
     repare como `input.required<Pokemon>()` torna o tipo obrigatório
     em compile-time: o pai DEVE passar [pokemon]="...".

   - O sub-componente NÃO precisa saber que existe um service global.
     Ele recebe `pokemon` e `favorito` via input, emite `favoritar`
     via output. Esse desacoplamento permite reusá-lo em qualquer tela.

   - No AppComponent, `state` é injetado e exposto público de propósito
     pra simplificar o template. Em apps maiores, prefira métodos
     dedicados (ex.: `vm = computed(() => ({ ... }))`).

   - `ehFavorito` é uma função normal — mas como ela LÊ `favoritos()`
     (um signal), o template re-executa quando o signal muda. Não
     precisa de computed pra coisas triviais.

   - Para um componente totalmente reativo, daria pra trocar o ngModel
     por (input)="onFiltroChange($any($event.target).value)" — mas com
     FormsModule + ngModel fica mais legível pra quem está aprendendo.

   ============================================================ */
