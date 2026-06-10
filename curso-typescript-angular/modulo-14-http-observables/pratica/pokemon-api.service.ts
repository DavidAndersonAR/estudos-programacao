// ============================================================
// PRÁTICA — Módulo 14: PokemonApiService
// ============================================================
//
// Service que conversa com a PokeAPI de verdade.
//
// COMO USAR:
// 1. Copie este arquivo para  src/app/pokemon-api.service.ts
// 2. Copie também pokemon.model.ts (os tipos).
// 3. Importe no seu componente:
//      private api = inject(PokemonApiService);
//
// PONTOS DE ESTUDO:
// - `providedIn: 'root'`  → singleton global, não precisa de provider manual
// - `inject(HttpClient)`  → injeção moderna (sem constructor)
// - retorno `Observable<T>` → não dispara o request até alguém dar subscribe
// - genérico `http.get<Pokemon>` → resposta já vem tipada
// ============================================================

import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

import { Pokemon, PokemonListResponse } from './pokemon.model';

@Injectable({ providedIn: 'root' })
export class PokemonApiService {
  private http = inject(HttpClient);
  private readonly base = 'https://pokeapi.co/api/v2';

  /**
   * Busca detalhes de UM pokémon por ID (ou nome — a API aceita os dois).
   * Exemplo: getById(1) → bulbasaur
   */
  getById(id: number | string): Observable<Pokemon> {
    return this.http.get<Pokemon>(`${this.base}/pokemon/${id}`);
  }

  /**
   * Lista pokémons paginados.
   * - limit  → quantos por página (padrão 20)
   * - offset → quantos pular (página 2 com limit=20 → offset=20)
   *
   * Usamos HttpParams em vez de concatenar string. Vantagem:
   * o Angular escapa caracteres especiais sozinho e fica mais legível.
   */
  listar(limit: number = 20, offset: number = 0): Observable<PokemonListResponse> {
    const params = new HttpParams()
      .set('limit', limit)
      .set('offset', offset);

    return this.http.get<PokemonListResponse>(`${this.base}/pokemon`, { params });
  }
}
