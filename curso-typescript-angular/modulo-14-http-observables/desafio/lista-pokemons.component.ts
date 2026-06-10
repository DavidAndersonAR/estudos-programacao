// ============================================================
// DESAFIO — Módulo 14: ListaPokemonsComponent
// ============================================================
//
// ENUNCIADO:
// Crie um componente standalone `ListaPokemonsComponent` que:
//
//   1. Usa o `PokedexService.listar(page, perPage)`.
//   2. Mostra um estado de **loading** enquanto o request roda.
//   3. Mostra mensagem de **erro** se o status do resultado for 'erro'.
//   4. Mostra a **lista** quando der certo.
//   5. Tem botões "Anterior" e "Próxima" pra paginar.
//      - "Anterior" desabilitado na página 1
//      - "Próxima" desabilitado quando não tem next
//
// REQUISITOS:
// - Use `@if` / `@for` (control flow novo, sem *ngIf/*ngFor).
// - Use `async pipe` no template. NADA de `subscribe()` aqui.
// - Use signals (`signal`) pra controlar a página atual.
// - Quando a página muda, o Observable da lista é recriado
//   (use um `computed` ou um getter).
//
// DICA:
// Como o async pipe re-faz subscribe quando a referência muda,
// basta recriar `lista$` toda vez que `pagina` mudar. A forma
// mais simples é via `computed` retornando o Observable.
//
// Escreva sua solução abaixo. A solução comentada está no fim.
// ============================================================

// TODO 1: importe Component, signal, computed, inject + CommonModule + PokedexService.

// TODO 2: defina a classe ListaPokemonsComponent com @Component({...}).

// TODO 3: crie:
//   - `pagina = signal(1)`
//   - `perPage = 20`
//   - `lista$ = computed(() => this.pokedex.listar(this.pagina(), this.perPage))`
//     (sim, computed pode retornar um Observable — só calcula referência nova
//      quando o signal lido muda)

// TODO 4: métodos proxima() e anterior() atualizam o signal `pagina`.



















// ============================================================
// SOLUÇÃO COMENTADA
// ============================================================
/*
import { Component, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

import { PokedexService } from './pokedex.service';

@Component({
  selector: 'app-lista-pokemons',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './lista-pokemons.component.html'
})
export class ListaPokemonsComponent {
  private pokedex = inject(PokedexService);

  pagina = signal(1);
  perPage = 20;

  // `computed` reavalia toda vez que `pagina()` mudar.
  // Cada reavaliação retorna um Observable NOVO → async pipe refaz subscribe.
  // Detalhe: o request só sai aí, no momento do subscribe (cold!).
  lista$ = computed(() => this.pokedex.listar(this.pagina(), this.perPage));

  proxima() {
    this.pagina.update(p => p + 1);
  }

  anterior() {
    this.pagina.update(p => Math.max(1, p - 1));
  }
}

// ---- POR QUE signal + computed em vez de variável crua? ----
// Sem signal, Angular não saberia que precisa rebuscar quando você
// muda a página. Com signal + computed, a reatividade vira "de graça":
// o template reage, o async pipe troca o stream, request novo dispara.
// É o jeito moderno (Angular 17+) — vamos ver mais no módulo 16.
*/
