// ============================================================
// PRÁTICA — Módulo 14: AppComponent usando o service + async pipe
// ============================================================
//
// COMO USAR:
// 1. Garanta que copiou:
//      - app.config.ts            → src/app/app.config.ts
//      - pokemon.model.ts         → src/app/pokemon.model.ts
//      - pokemon-api.service.ts   → src/app/pokemon-api.service.ts
// 2. Copie este por cima de       src/app/app.component.ts
// 3. Copie app.component.html por cima de src/app/app.component.html
// 4. Rode `ng serve` e abra http://localhost:4200
//
// PONTOS DE ESTUDO:
// - Não usamos `subscribe()`. Guardamos o Observable e deixamos o
//   `async pipe` no HTML cuidar do resto (subscribe + unsubscribe).
// - Sem `ngOnInit`. Sem propriedade `pokemon: Pokemon | null`.
//   O fluxo fica declarativo: "essa variável É o stream".
// - Convenção: nome do Observable termina com `$`  →  pokemon$
// ============================================================

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';   // pra liberar o `async` pipe

import { PokemonApiService } from './pokemon-api.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  private api = inject(PokemonApiService);

  // Observable do pokémon de id=1 (bulbasaur).
  // Nada é disparado aqui — o request só sai quando o template
  // faz subscribe via `| async`.
  pokemon$ = this.api.getById(1);
}
