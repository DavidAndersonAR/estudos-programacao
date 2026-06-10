// ============================================================================
// DESAFIO — app.component.ts
// ----------------------------------------------------------------------------
// Componente raiz. Standalone, importa RouterOutlet e RouterLink direto.
// Sem AppModule.
// ============================================================================

import { Component } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [RouterOutlet, RouterLink],
    templateUrl: './app.component.html',
    styles: [`
        :host {
            display: block; min-height: 100vh;
            font-family: system-ui, sans-serif;
            background: #f5f7fa;
        }
        header {
            background: linear-gradient(90deg, #ef5350, #c62828);
            color: #fff; padding: 16px 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,.1);
        }
        header h1 { margin: 0; font-size: 20px; }
        header a { color: #fff; text-decoration: none; }
        main { max-width: 960px; margin: 0 auto; padding: 24px; }

        /* 👇 Customização da View Transitions API.
              Vale a pena reforçar: o navegador faz cross-fade SOZINHO,
              só por causa do withViewTransitions() no app.config.ts.
              O CSS abaixo só ajusta a duração. */
        ::view-transition-old(root),
        ::view-transition-new(root) {
            animation-duration: 350ms;
        }
    `]
})
export class AppComponent {}
