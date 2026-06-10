// =============================================================================
// DESAFIO — PokedexStore completa (estado global com signals)
// =============================================================================
//
// Crie um store singleton que reúna TODO o estado da Pokédex num único lugar:
//
//   ESTADO (signals privadas):
//     - pokemons      : Pokemon[]      → cache da listagem (vazio no início)
//     - favoritos     : number[]       → IDs marcados como favoritos
//     - ultimoVisto   : number | null  → ID do último pokémon aberto em detalhe
//     - filtroBusca   : string         → texto digitado no campo de busca
//
//   EXPOSIÇÃO READONLY (asReadonly):
//     - pokemons, favoritos, ultimoVisto, filtroBusca
//
//   COMPUTED (derivados):
//     - totalFavoritos : número de favoritos
//     - pokemonsFiltrados : aplica o filtro de busca por nome (case-insensitive)
//     - listaFavoritos    : lista os objetos Pokemon dos IDs favoritados
//     - temUltimoVisto    : boolean (ultimoVisto !== null)
//
//   MÉTODOS:
//     - definirPokemons(lista: Pokemon[])     → preenche o cache
//     - toggleFavorito(id: number)            → adiciona/remove
//     - limparFavoritos()                     → zera a lista
//     - registrarVisita(id: number)           → atualiza ultimoVisto
//     - setFiltroBusca(texto: string)         → atualiza o filtro
//     - ehFavorito(id: number): boolean       → helper
//
//   PERSISTÊNCIA (effect):
//     - apenas FAVORITOS e ULTIMO VISTO vão pro localStorage
//     - o cache de pokemons e o filtro de busca NÃO são persistidos
//       (cache se recarrega, e filtro de busca é estado de tela)
//
// Use os três componentes na pasta components/ pra testar.
//
// =============================================================================

import { Injectable, signal, computed, effect } from '@angular/core';

export interface Pokemon {
    id: number;
    nome: string;
    tipos: string[];
}

const KEY_FAVORITOS = 'pokedex:favoritos:v1';
const KEY_ULTIMO    = 'pokedex:ultimoVisto:v1';

@Injectable({ providedIn: 'root' })
export class PokedexStore {

    // TODO 1: declare as 4 signals privadas (pokemons, favoritos, ultimoVisto, filtroBusca)
    //         As 2 persistidas devem ser inicializadas a partir do localStorage.
    private readonly _pokemons    = signal<Pokemon[]>([]);
    private readonly _favoritos   = signal<number[]>([]);
    private readonly _ultimoVisto = signal<number | null>(null);
    private readonly _filtroBusca = signal<string>('');

    // TODO 2: exponha versões readonly de tudo.
    readonly pokemons    = this._pokemons.asReadonly();
    readonly favoritos   = this._favoritos.asReadonly();
    readonly ultimoVisto = this._ultimoVisto.asReadonly();
    readonly filtroBusca = this._filtroBusca.asReadonly();

    // TODO 3: declare os 4 computed listados acima.
    readonly totalFavoritos    = computed(() => 0);
    readonly pokemonsFiltrados = computed<Pokemon[]>(() => []);
    readonly listaFavoritos    = computed<Pokemon[]>(() => []);
    readonly temUltimoVisto    = computed(() => false);

    constructor() {
        // TODO 4: implemente dois effects — um pra persistir favoritos,
        //         outro pra persistir ultimoVisto.
    }

    // TODO 5: implemente os métodos públicos.
    definirPokemons(lista: Pokemon[]): void { /* ... */ }
    toggleFavorito(id: number): void        { /* ... */ }
    limparFavoritos(): void                 { /* ... */ }
    registrarVisita(id: number): void       { /* ... */ }
    setFiltroBusca(texto: string): void     { /* ... */ }
    ehFavorito(id: number): boolean         { return false; }
}


// =============================================================================
// SOLUÇÃO (descomente após tentar resolver sozinho)
// =============================================================================
/*
import { Injectable, signal, computed, effect } from '@angular/core';

export interface Pokemon {
    id: number;
    nome: string;
    tipos: string[];
}

const KEY_FAVORITOS = 'pokedex:favoritos:v1';
const KEY_ULTIMO    = 'pokedex:ultimoVisto:v1';

@Injectable({ providedIn: 'root' })
export class PokedexStore {

    // ---- ESTADO --------------------------------------------------------
    private readonly _pokemons    = signal<Pokemon[]>([]);
    private readonly _favoritos   = signal<number[]>(this.lerFavoritos());
    private readonly _ultimoVisto = signal<number | null>(this.lerUltimoVisto());
    private readonly _filtroBusca = signal<string>('');

    // ---- READONLY ------------------------------------------------------
    readonly pokemons    = this._pokemons.asReadonly();
    readonly favoritos   = this._favoritos.asReadonly();
    readonly ultimoVisto = this._ultimoVisto.asReadonly();
    readonly filtroBusca = this._filtroBusca.asReadonly();

    // ---- COMPUTED ------------------------------------------------------
    readonly totalFavoritos = computed(() => this._favoritos().length);

    readonly pokemonsFiltrados = computed<Pokemon[]>(() => {
        const termo = this._filtroBusca().trim().toLowerCase();
        const lista = this._pokemons();
        if (!termo) return lista;
        return lista.filter(p => p.nome.toLowerCase().includes(termo));
    });

    readonly listaFavoritos = computed<Pokemon[]>(() => {
        const ids = new Set(this._favoritos());
        return this._pokemons().filter(p => ids.has(p.id));
    });

    readonly temUltimoVisto = computed(() => this._ultimoVisto() !== null);

    // ---- CONSTRUCTOR (persistência) -----------------------------------
    constructor() {
        effect(() => {
            localStorage.setItem(KEY_FAVORITOS, JSON.stringify(this._favoritos()));
        });
        effect(() => {
            const u = this._ultimoVisto();
            if (u === null) localStorage.removeItem(KEY_ULTIMO);
            else            localStorage.setItem(KEY_ULTIMO, String(u));
        });
    }

    // ---- MÉTODOS -------------------------------------------------------
    definirPokemons(lista: Pokemon[]): void {
        this._pokemons.set(lista);
    }

    toggleFavorito(id: number): void {
        this._favoritos.update(atuais =>
            atuais.includes(id)
                ? atuais.filter(i => i !== id)
                : [...atuais, id]
        );
    }

    limparFavoritos(): void {
        this._favoritos.set([]);
    }

    registrarVisita(id: number): void {
        this._ultimoVisto.set(id);
    }

    setFiltroBusca(texto: string): void {
        this._filtroBusca.set(texto);
    }

    ehFavorito(id: number): boolean {
        return this._favoritos().includes(id);
    }

    // ---- PRIVADOS (carga inicial) -------------------------------------
    private lerFavoritos(): number[] {
        try {
            const raw = localStorage.getItem(KEY_FAVORITOS);
            const parsed = raw ? JSON.parse(raw) : [];
            return Array.isArray(parsed) ? parsed : [];
        } catch {
            return [];
        }
    }

    private lerUltimoVisto(): number | null {
        const raw = localStorage.getItem(KEY_ULTIMO);
        if (!raw) return null;
        const n = Number(raw);
        return Number.isFinite(n) ? n : null;
    }
}
*/
