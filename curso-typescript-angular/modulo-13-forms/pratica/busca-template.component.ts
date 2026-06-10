// Pratica — Template-driven Form
// Form simples com um único campo de busca usando [(ngModel)].
// Repare como TODA a lógica está no template — o .ts só guarda o valor.
// Bom pra forms pequenos. Para qualquer coisa maior, prefira Reactive.

import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-busca-template',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './busca-template.component.html',
})
export class BuscaTemplateComponent {
  // [(ngModel)] faz o two-way binding com essa propriedade
  termoBusca = '';

  buscar() {
    if (!this.termoBusca.trim()) {
      console.warn('digite alguma coisa pra buscar');
      return;
    }
    console.log('buscando (template-driven):', this.termoBusca);
  }

  limpar() {
    this.termoBusca = '';
  }
}
