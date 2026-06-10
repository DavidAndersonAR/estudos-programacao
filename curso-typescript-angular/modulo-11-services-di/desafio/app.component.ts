// =============================================================================
// DESAFIO — AppComponent que demonstra TODOS os métodos do PokemonService
// =============================================================================
//
// Sua UI deve:
//   - Mostrar a lista completa (listar())
//   - Ter um <input type="number"> + botão pra buscar por ID (buscarPorId)
//   - Ter um <input type="text"> + botão pra filtrar por tipo (filtrarPorTipo)
//   - Exibir mensagens claras quando não achar nada
//
// Use inject() — sem constructor.
//
// =============================================================================

import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Pokemon, PokemonService } from './pokemon.service';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [CommonModule, FormsModule],
    templateUrl: './app.component.html',
})
export class AppComponent {
    // TODO 1: injete o PokemonService usando inject().
    private pokemonService!: PokemonService;

    // TODO 2: inicialize a lista chamando listar().
    todos: Pokemon[] = [];

    // Estado da busca por ID
    idBusca: number | null = null;
    encontrado: Pokemon | undefined = undefined;
    buscouId = false;

    // Estado do filtro por tipo
    tipoBusca = '';
    filtrados: Pokemon[] = [];
    filtrou = false;

    // TODO 3: implemente buscar() — chama buscarPorId e marca buscouId = true.
    buscar(): void {
        // sua lógica aqui
    }

    // TODO 4: implemente filtrar() — chama filtrarPorTipo e marca filtrou = true.
    filtrar(): void {
        // sua lógica aqui
    }
}


// =============================================================================
// SOLUÇÃO (descomente após tentar resolver sozinho)
// =============================================================================
/*
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Pokemon, PokemonService } from './pokemon.service';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [CommonModule, FormsModule],
    templateUrl: './app.component.html',
})
export class AppComponent {
    private pokemonService = inject(PokemonService);

    todos: Pokemon[] = this.pokemonService.listar();

    idBusca: number | null = null;
    encontrado: Pokemon | undefined = undefined;
    buscouId = false;

    tipoBusca = '';
    filtrados: Pokemon[] = [];
    filtrou = false;

    buscar(): void {
        if (this.idBusca == null) return;
        this.encontrado = this.pokemonService.buscarPorId(this.idBusca);
        this.buscouId = true;
    }

    filtrar(): void {
        const tipo = this.tipoBusca.trim();
        if (!tipo) return;
        this.filtrados = this.pokemonService.filtrarPorTipo(tipo);
        this.filtrou = true;
    }
}
*/
