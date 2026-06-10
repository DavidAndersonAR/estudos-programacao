// detalhe-pokemon.component.ts — lê :id da rota e mostra detalhes.
//
// Conceito-chave: ActivatedRoute permite ler parâmetros da URL atual.
// Usamos snapshot.paramMap.get() porque o componente não é reutilizado
// entre IDs diferentes (cada navegação cria uma instância nova).

import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { PokemonService } from '../services/pokemon.service';

@Component({
  selector: 'app-detalhe-pokemon',
  standalone: true,
  template: `
    @if (pokemon) {
      <h2>#{{ pokemon.id }} — {{ pokemon.nome }}</h2>
      <p><strong>Tipo:</strong> {{ pokemon.tipo }}</p>
      <p><strong>HP:</strong> {{ pokemon.hp }}</p>
    } @else {
      <p>Pokémon não encontrado.</p>
    }
  `,
})
export class DetalhePokemonComponent {
  private route = inject(ActivatedRoute);
  private service = inject(PokemonService);

  // snapshot = leitura única no momento em que o componente é criado.
  // paramMap.get('id') retorna string | null — convertemos pra number.
  // O '!' diz ao TS "confia, eu sei que tem id aqui" (a rota exige ':id').
  private id = Number(this.route.snapshot.paramMap.get('id')!);

  pokemon = this.service.buscarPorId(this.id);
}
