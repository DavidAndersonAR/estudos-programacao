// pokemon.model.ts
// Modelo de dados do Pokémon usado pelo PokemonService e pelo AppComponent.

export interface Pokemon {
    id: number;
    name: string;
    types: string[];
}
