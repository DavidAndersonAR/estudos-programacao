// ============================================================
// DESAFIO — Módulo 14: PokedexService completo
// ============================================================
//
// ENUNCIADO:
// Crie um service `PokedexService` que conversa com a PokeAPI
// (https://pokeapi.co/api/v2) e expõe três métodos:
//
//   1. listar(page = 1, perPage = 20)
//      → busca uma página de pokémons.
//      → INTERNO: converte page/perPage em limit/offset
//        (ex: page=2, perPage=20 → offset=20).
//
//   2. buscarPorId(id: number)
//      → detalhe de um pokémon por ID.
//
//   3. buscarPorNome(nome: string)
//      → a PokeAPI aceita nome no mesmo endpoint que ID.
//      → Normalize: lowercase e trim antes de mandar.
//
// REQUISITOS:
// - Use `inject(HttpClient)` (sem constructor).
// - Use `HttpParams` no listar (não concatene string!).
// - Trate erro com `catchError`. Em caso de erro, devolva o
//   objeto:  { status: 'erro', msg: '...' }
//   (em caso de sucesso, devolva:  { status: 'ok', dados: ... })
// - Defina o tipo de retorno como `Observable<Resultado<T>>`.
//
// DICA: use o tipo `Resultado<T>` como union discriminada:
//   type Resultado<T> =
//     | { status: 'ok'; dados: T }
//     | { status: 'erro'; msg: string };
//
// Escreva sua solução abaixo. A solução comentada está no fim.
// ============================================================

// TODO 1: importe Injectable, inject, HttpClient, HttpParams,
//         Observable, catchError, of, map.

// TODO 2: defina o tipo Resultado<T>.

// TODO 3: defina as interfaces Pokemon e PokemonListResponse
//         (ou importe do model do projeto).

// TODO 4: crie a classe PokedexService com @Injectable({ providedIn: 'root' }).

// TODO 5: implemente listar(page, perPage):
//         - calcule offset = (page - 1) * perPage
//         - monte HttpParams
//         - faça http.get → .pipe(map(...), catchError(...))

// TODO 6: implemente buscarPorId(id).

// TODO 7: implemente buscarPorNome(nome).
//         - normalize: nome.trim().toLowerCase()



















// ============================================================
// SOLUÇÃO COMENTADA
// ============================================================
/*
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, catchError, of, map } from 'rxjs';

// Union discriminada — TS força você a checar `status` antes
// de acessar `dados` ou `msg`. Vira erro de compilação se esquecer.
export type Resultado<T> =
  | { status: 'ok'; dados: T }
  | { status: 'erro'; msg: string };

export interface Pokemon {
  id: number;
  name: string;
  sprites: { front_default: string };
  types: { slot: number; type: { name: string } }[];
}

export interface PokemonListResponse {
  count: number;
  next: string | null;
  previous: string | null;
  results: { name: string; url: string }[];
}

@Injectable({ providedIn: 'root' })
export class PokedexService {
  private http = inject(HttpClient);
  private readonly base = 'https://pokeapi.co/api/v2';

  // ---- LISTAR ----
  listar(page: number = 1, perPage: number = 20): Observable<Resultado<PokemonListResponse>> {
    // PokeAPI usa offset/limit. Convertemos a partir de page/perPage
    // (mais intuitivo pra quem chama o service).
    const offset = (page - 1) * perPage;

    const params = new HttpParams()
      .set('limit', perPage)
      .set('offset', offset);

    return this.http.get<PokemonListResponse>(`${this.base}/pokemon`, { params }).pipe(
      // sucesso: embrulha em { status: 'ok', dados }
      map(dados => ({ status: 'ok', dados }) as Resultado<PokemonListResponse>),
      // erro: vira { status: 'erro', msg }
      catchError(err => of({
        status: 'erro' as const,
        msg: `Falha ao listar pokémons: ${err.message ?? 'erro desconhecido'}`
      }))
    );
  }

  // ---- BUSCAR POR ID ----
  buscarPorId(id: number): Observable<Resultado<Pokemon>> {
    return this.http.get<Pokemon>(`${this.base}/pokemon/${id}`).pipe(
      map(dados => ({ status: 'ok', dados }) as Resultado<Pokemon>),
      catchError(err => of({
        status: 'erro' as const,
        msg: err.status === 404
          ? `Pokémon com id ${id} não encontrado.`
          : `Erro ao buscar pokémon: ${err.message}`
      }))
    );
  }

  // ---- BUSCAR POR NOME ----
  buscarPorNome(nome: string): Observable<Resultado<Pokemon>> {
    const nomeNormalizado = nome.trim().toLowerCase();

    if (!nomeNormalizado) {
      // short-circuit: nem chama a API se o nome veio vazio
      return of({ status: 'erro', msg: 'Informe um nome.' });
    }

    return this.http.get<Pokemon>(`${this.base}/pokemon/${nomeNormalizado}`).pipe(
      map(dados => ({ status: 'ok', dados }) as Resultado<Pokemon>),
      catchError(err => of({
        status: 'erro' as const,
        msg: err.status === 404
          ? `Nenhum pokémon chamado "${nome}".`
          : `Erro ao buscar: ${err.message}`
      }))
    );
  }
}

// ---- POR QUE Resultado<T> EM VEZ DE LANÇAR EXCEÇÃO? ----
// Em apps reais, "erro" não é exceção — é um estado da tela.
// Devolver { status: 'erro', msg } força o componente a tratar
// os dois casos no template (loading / ok / erro), em vez de
// pensar que "vai dar tudo certo" e esquecer do caminho infeliz.
*/
