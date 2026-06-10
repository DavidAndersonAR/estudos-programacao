// ============================================================================
// PRATICA — pokemon-detalhes-pesado.component.ts
// ----------------------------------------------------------------------------
// Esse é o componente "pesado" que vai ser carregado via @defer no card.
// Em produção, imagine que ele importa uma lib de gráficos (Chart.js),
// faz cálculo intensivo de stats, renderiza imagens grandes, etc.
// Aqui simulamos com um setTimeout no constructor pra você "ver" o tempo
// de carga.
// ============================================================================

import { Component, Input } from '@angular/core';

@Component({
    selector: 'app-pokemon-detalhes-pesado',
    standalone: true,                    // 👈 obrigatório pra ser deferível
    imports: [],
    template: `
        <div class="bloco-pesado">
            <h4>📊 Detalhes pesados de {{ nome }}</h4>
            <ul>
                <li>HP simulado: {{ hp }}</li>
                <li>Ataque simulado: {{ ataque }}</li>
                <li>Defesa simulada: {{ defesa }}</li>
            </ul>
            <p class="rodape">
                ⏱️ Esse componente só baixou e renderizou quando entrou na tela
                (graças ao <code>&#64;defer (on viewport)</code> no pai).
            </p>
        </div>
    `,
    styles: [`
        .bloco-pesado {
            border: 2px dashed #4a90e2;
            background: #eef5ff;
            padding: 12px 16px;
            border-radius: 8px;
            margin-top: 12px;
            font-family: system-ui, sans-serif;
        }
        h4 { margin: 0 0 8px; color: #1a4f9c; }
        ul { margin: 0; padding-left: 20px; }
        .rodape { font-size: 12px; color: #555; margin-top: 8px; }
        code { background: #fff; padding: 1px 5px; border-radius: 4px; }
    `]
})
export class PokemonDetalhesPesadoComponent {
    @Input() nome = 'Pokémon';

    // Stats fake gerados na criação — só pra ter algo visível.
    hp = Math.floor(Math.random() * 100) + 50;
    ataque = Math.floor(Math.random() * 100) + 50;
    defesa = Math.floor(Math.random() * 100) + 50;

    constructor() {
        // Simulação de trabalho pesado no boot do componente.
        // Em produção isso seria, por exemplo, montar um gráfico via Chart.js.
        console.log('[detalhes-pesado] Componente foi instanciado (via @defer)');
    }
}
