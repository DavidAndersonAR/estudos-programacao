// ============================================================================
// DESAFIO — pokemon-stats-pesado.component.ts
// ----------------------------------------------------------------------------
// SOLUÇÃO. O painel "pesado" carregado via @defer (on interaction).
// Em produção, imagine que esse componente importa uma lib de charts
// (Chart.js, ApexCharts, D3...) — algo que pesa 100kb+. Aqui simulamos
// com cálculos fake e uma barra de stat renderizada com CSS.
// ============================================================================

import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

interface Stat {
    nome: string;
    valor: number;
}

@Component({
    selector: 'app-pokemon-stats-pesado',
    standalone: true,
    imports: [CommonModule],
    template: `
        <section class="painel">
            <h3>Stats de {{ nome | titlecase }}</h3>

            <!-- @let evita repetir o cálculo de soma. -->
            @let total = totalStats;
            <p>Total: <strong>{{ total }}</strong></p>

            @for (s of stats; track s.nome) {
                <div class="linha">
                    <span class="label">{{ s.nome }}</span>
                    <div class="barra">
                        <div class="preenchimento"
                             [style.width.%]="(s.valor / 200) * 100">
                        </div>
                    </div>
                    <span class="valor">{{ s.valor }}</span>
                </div>
            }

            <p class="rodape">
                ✅ Esse componente só baixou (chunk próprio) e renderizou
                depois que você clicou em <code>Ver stats</code>.
            </p>
        </section>
    `,
    styles: [`
        .painel {
            margin-top: 16px; padding: 20px; background: #fff;
            border-radius: 12px; border: 1px solid #e0e0e0;
            box-shadow: 0 2px 8px rgba(0,0,0,.05);
        }
        h3 { margin: 0 0 12px; }
        .linha {
            display: grid; grid-template-columns: 80px 1fr 40px;
            gap: 12px; align-items: center; margin-bottom: 8px;
        }
        .label { text-transform: capitalize; font-size: 14px; color: #555; }
        .barra { height: 14px; background: #eee; border-radius: 7px; overflow: hidden; }
        .preenchimento {
            height: 100%;
            background: linear-gradient(90deg, #4caf50, #8bc34a);
        }
        .valor { text-align: right; font-weight: 600; font-size: 14px; }
        .rodape {
            margin-top: 12px; font-size: 12px; color: #777;
            background: #f7f7f7; padding: 8px; border-radius: 6px;
        }
        code { background: #fff; padding: 1px 5px; border-radius: 4px; }
    `]
})
export class PokemonStatsPesadoComponent {
    @Input() nome = 'Pokémon';

    // Stats fake. Em produção viriam de uma API ou cálculo.
    stats: Stat[] = [
        { nome: 'hp',          valor: this.rand() },
        { nome: 'attack',      valor: this.rand() },
        { nome: 'defense',     valor: this.rand() },
        { nome: 'sp. attack',  valor: this.rand() },
        { nome: 'sp. defense', valor: this.rand() },
        { nome: 'speed',       valor: this.rand() },
    ];

    // Usado dentro do @let no template.
    get totalStats(): number {
        return this.stats.reduce((acc, s) => acc + s.valor, 0);
    }

    constructor() {
        console.log('[stats-pesado] chunk baixado e componente instanciado');
    }

    private rand(): number {
        return Math.floor(Math.random() * 150) + 30;
    }
}
