// Pratica — Reactive Form
// Mesmo objetivo do template-driven, mas agora com 3 campos e validação programática.
// Toda a estrutura do form vive no TypeScript — o template só conecta.
// Esse é o padrão recomendado pra forms reais.

import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'app-busca-reactive',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './busca-reactive.component.html',
})
export class BuscaReactiveComponent {
  // FormBuilder é syntactic sugar pra criar FormGroup/FormControl sem ficar instanciando classes.
  private fb = inject(FormBuilder);

  // Definimos o form INTEIRO aqui, com valores iniciais e validators.
  form = this.fb.group({
    busca: ['', [Validators.required, Validators.minLength(2)]],
    tipo: ['todos', [Validators.required]],
    ordenarPor: ['nome', [Validators.required]],
  });

  // Opções pros selects — em um app real viriam de um service/API.
  tipos = ['todos', 'fogo', 'agua', 'grama', 'eletrico', 'psiquico'];
  ordenacoes = [
    { valor: 'nome', label: 'Nome (A-Z)' },
    { valor: 'numero', label: 'Número' },
    { valor: 'altura', label: 'Altura' },
  ];

  onSubmit() {
    // Sempre cheque .invalid antes de processar — botão disabled não é garantia
    // (usuário pode disparar via Enter, ou alguém pode remover o disabled via devtools).
    if (this.form.invalid) {
      this.form.markAllAsTouched(); // força mostrar erros
      return;
    }
    console.log('buscando (reactive):', this.form.value);
  }

  limpar() {
    // reset() volta pros valores iniciais e marca como pristine/untouched
    this.form.reset({ busca: '', tipo: 'todos', ordenarPor: 'nome' });
  }
}
