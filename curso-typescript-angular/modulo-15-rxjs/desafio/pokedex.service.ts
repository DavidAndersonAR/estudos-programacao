// desafio/pokedex.service.ts
// Service que conversa com a PokeAPI (https://pokeapi.co).
//
// Importante: no app.config.ts você precisa registrar o HttpClient com:
//   provideHttpClient()
// dentro do array `providers`.

import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, forkJoin, of } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';

export interface Pokemon {
  nome: string;
  imagem: string;
}

interface ListaResposta {
  results: { name: string; url: string }[];
}

interface DetalheResposta {
  name: string;
  sprites: { front_default: string };
}

@Injectable({ providedIn: 'root' })
export class PokedexService {
  private http = inject(HttpClient);
  private base = 'https://pokeapi.co/api/v2';

  /**
   * Busca pokémons cujo nome contém `termo`.
   * Estratégia: a PokeAPI não tem endpoint de busca por substring,
   * então pegamos os 151 primeiros e filtramos no cliente.
   * Depois, pra cada match, buscamos os detalhes em paralelo com forkJoin.
   */
  buscar(termo: string): Observable<Pokemon[]> {
    const t = termo.trim().toLowerCase();
    if (!t) return of([]); // termo vazio → lista vazia, sem chamar API

    return this.http
      .get<ListaResposta>(`${this.base}/pokemon?limit=151`)
      .pipe(
        // 1. Filtra os que batem com o termo
        map(resp => resp.results.filter(p => p.name.includes(t))),
        // 2. Pra cada match, dispara um GET de detalhes
        switchMap(matches => {
          if (matches.length === 0) return of([] as Pokemon[]);
          const detalhes$ = matches
            .slice(0, 10) // limita a 10 resultados pra não estourar
            .map(p => this.http.get<DetalheResposta>(p.url));
          // forkJoin: espera todos os GETs e devolve array final
          return forkJoin(detalhes$).pipe(
            map(lista => lista.map(d => ({
              nome: d.name,
              imagem: d.sprites.front_default
            })))
          );
        })
      );
  }
}
