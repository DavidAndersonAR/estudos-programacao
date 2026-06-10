// ============================================================
// PRÁTICA — Módulo 14: tipos da PokeAPI
// ============================================================
//
// A resposta real da PokeAPI tem DEZENAS de campos. Aqui tipamos
// só o que vamos usar — não precisa modelar o que não consome.
// Isso é uma boa prática: tipos enxutos, código limpo.
//
// Copie este arquivo para  src/app/pokemon.model.ts
// ============================================================

// ---------- Detalhe de um pokémon (/pokemon/{id}) ----------

export interface Pokemon {
  id: number;
  name: string;
  height: number;          // em decímetros (sim, decímetros)
  weight: number;          // em hectogramas
  sprites: PokemonSprites;
  types: PokemonTypeSlot[];
}

export interface PokemonSprites {
  front_default: string;   // URL da imagem principal
}

export interface PokemonTypeSlot {
  slot: number;
  type: { name: string; url: string };
}

// ---------- Lista de pokémons (/pokemon?limit=&offset=) ----------

export interface PokemonListResponse {
  count: number;                  // total no banco (~1300)
  next: string | null;            // URL da próxima página (ou null)
  previous: string | null;        // URL da página anterior
  results: PokemonListItem[];
}

export interface PokemonListItem {
  name: string;
  url: string;                    // ex: "https://pokeapi.co/api/v2/pokemon/1/"
}
