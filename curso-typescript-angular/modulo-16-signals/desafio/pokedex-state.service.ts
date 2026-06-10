// ============================================================
// DESAFIO — Módulo 16: Estado da Pokedex com Signals
// ============================================================
//
// ENUNCIADO:
// Crie um service GLOBAL que guarde o estado da Pokedex usando Signals.
// Esse service será injetado em qualquer componente que precise ler
// ou modificar a lista de pokémons, favoritos e o filtro atual.
//
// REQUISITOS:
//   1) Um signal `pokemons: Signal<Pokemon[]>` com a lista completa.
//   2) Um signal `favoritos: Signal<number[]>` com os IDs favoritados.
//   3) Um signal `filtroAtual: Signal<string>` com o texto do filtro.
//   4) Um computed `pokemonsFiltrados` que devolve apenas os pokémons
//      cujo nome contenha (case-insensitive) `filtroAtual`.
//   5) Métodos:
//        - setPokemons(lista): substitui a lista
//        - toggleFavorito(id): adiciona ou remove o ID dos favoritos
//        - definirFiltro(texto): atualiza o filtro
//
// COMO USAR:
// 1. Crie  src/app/state/  e copie este arquivo.
// 2. Crie  src/app/  com  app.component.ts/.html  do desafio.
// 3. ng serve  e teste no navegador.
//
// COMECE AQUI ⬇️
// ============================================================

import { Injectable, signal, computed } from '@angular/core';

export interface Pokemon {
  id: number;
  nome: string;
  tipo: string;
}

@Injectable({ providedIn: 'root' })
export class PokedexStateService {
  // TODO 1: crie o signal `pokemons` com tipo Pokemon[] e valor inicial [].
  // TODO 2: crie o signal `favoritos` com tipo number[] e valor inicial [].
  // TODO 3: crie o signal `filtroAtual` com tipo string e valor inicial ''.
  // TODO 4: crie o computed `pokemonsFiltrados` que filtra `pokemons`
  //         pelo nome contendo `filtroAtual` (case-insensitive).
  //         Dica: use .toLowerCase().includes()
  // TODO 5: implemente setPokemons, toggleFavorito e definirFiltro.
}

/* ============================================================
   ✅ SOLUÇÃO COMENTADA — descomente pra comparar com a sua.
   ============================================================

import { Injectable, signal, computed } from '@angular/core';

export interface Pokemon {
  id: number;
  nome: string;
  tipo: string;
}

@Injectable({ providedIn: 'root' })
export class PokedexStateService {
  // Signals "fonte de verdade".
  // Repare: deixei TODOS públicos pra simplificar o exemplo.
  // Em projeto real, costuma-se manter o signal "writable" privado
  // (com underline) e expor uma versão read-only via .asReadonly().
  pokemons = signal<Pokemon[]>([]);
  favoritos = signal<number[]>([]);
  filtroAtual = signal<string>('');

  // computed: deriva pokemons + filtroAtual.
  // Recalcula automaticamente quando QUALQUER um dos dois muda.
  // E ainda cacheia: se ninguém leu, nem executa.
  pokemonsFiltrados = computed(() => {
    const filtro = this.filtroAtual().toLowerCase().trim();
    if (!filtro) return this.pokemons();
    return this.pokemons().filter(p =>
      p.nome.toLowerCase().includes(filtro)
    );
  });

  // Bônus: outro computed dependendo de `favoritos` e `pokemons`.
  pokemonsFavoritos = computed(() =>
    this.pokemons().filter(p => this.favoritos().includes(p.id))
  );

  // .set substitui a lista inteira (uso típico após HTTP GET).
  setPokemons(lista: Pokemon[]): void {
    this.pokemons.set(lista);
  }

  // .update calcula com base no anterior — bom pra alternar (toggle).
  // SEMPRE retornamos um NOVO array — signals comparam por referência.
  toggleFavorito(id: number): void {
    this.favoritos.update(atual =>
      atual.includes(id)
        ? atual.filter(x => x !== id)     // já era favorito → tira
        : [...atual, id]                   // não era → adiciona
    );
  }

  definirFiltro(texto: string): void {
    this.filtroAtual.set(texto);
  }
}

   ============================================================ */
