/**
 * DESAFIO — Filtros de Pokémons
 *
 * Construa um componente reactive form que sirva como BARRA DE FILTROS
 * pra uma listagem de pokémons. Requisitos:
 *
 *  1. Campos:
 *     - busca: texto livre, MÍNIMO 2 caracteres (quando preenchido).
 *     - tipo: select com opções: 'todos', 'fogo', 'agua', 'grama', 'eletrico', 'psiquico'.
 *     - apenasFavoritos: checkbox booleano (começa false).
 *
 *  2. Botão "Limpar" volta o form pros valores iniciais.
 *
 *  3. @Output() filtrosMudaram — EMITE o objeto de filtros toda vez
 *     que o form muda E está válido. Use form.valueChanges.
 *
 *  4. Mostre erros (touched + invalid) no campo de busca.
 *
 *  5. Integre no app.component.ts: ao receber filtrosMudaram, dê console.log
 *     e mostre os filtros atuais na tela.
 *
 * Dicas:
 *  - FormBuilder pra montar o group.
 *  - form.valueChanges é um Observable — assine no ngOnInit.
 *  - Pra evitar emit com form inválido, cheque this.form.valid antes de emitir.
 *  - reset() volta pros valores que você passar como parâmetro.
 */

import { Component, EventEmitter, OnInit, Output, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

// TODO 1: defina o tipo dos filtros que vão ser emitidos
// (você pode descomentar a interface abaixo)

// export interface FiltrosPokemon {
//   busca: string;
//   tipo: string;
//   apenasFavoritos: boolean;
// }

@Component({
  selector: 'app-filtros-pokemons',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './filtros-pokemons.component.html',
})
export class FiltrosPokemonsComponent implements OnInit {
  private fb = inject(FormBuilder);

  // TODO 2: declare o @Output() filtrosMudaram
  // @Output() filtrosMudaram = new EventEmitter<FiltrosPokemon>();

  tipos = ['todos', 'fogo', 'agua', 'grama', 'eletrico', 'psiquico'];

  // TODO 3: monte o FormGroup com os 3 campos + validators
  form = this.fb.group({
    // busca: ['', [Validators.minLength(2)]],
    // tipo: ['todos'],
    // apenasFavoritos: [false],
  });

  ngOnInit(): void {
    // TODO 4: assine form.valueChanges e emita filtrosMudaram quando válido
    // this.form.valueChanges.subscribe(() => {
    //   if (this.form.valid) {
    //     this.filtrosMudaram.emit(this.form.value as FiltrosPokemon);
    //   }
    // });
  }

  limpar() {
    // TODO 5: reset pros valores iniciais
    // this.form.reset({ busca: '', tipo: 'todos', apenasFavoritos: false });
  }
}

/* ============================================================
 * 💡 SOLUÇÃO (descomente pra ver depois de tentar)
 * ============================================================
 *
 * import { Component, EventEmitter, OnInit, Output, inject } from '@angular/core';
 * import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
 *
 * export interface FiltrosPokemon {
 *   busca: string;
 *   tipo: string;
 *   apenasFavoritos: boolean;
 * }
 *
 * @Component({
 *   selector: 'app-filtros-pokemons',
 *   standalone: true,
 *   imports: [ReactiveFormsModule],
 *   templateUrl: './filtros-pokemons.component.html',
 * })
 * export class FiltrosPokemonsComponent implements OnInit {
 *   private fb = inject(FormBuilder);
 *
 *   @Output() filtrosMudaram = new EventEmitter<FiltrosPokemon>();
 *
 *   tipos = ['todos', 'fogo', 'agua', 'grama', 'eletrico', 'psiquico'];
 *
 *   form = this.fb.group({
 *     busca: ['', [Validators.minLength(2)]],
 *     tipo: ['todos', Validators.required],
 *     apenasFavoritos: [false],
 *   });
 *
 *   ngOnInit(): void {
 *     this.form.valueChanges.subscribe(() => {
 *       if (this.form.valid) {
 *         this.filtrosMudaram.emit(this.form.value as FiltrosPokemon);
 *       }
 *     });
 *   }
 *
 *   limpar() {
 *     this.form.reset({ busca: '', tipo: 'todos', apenasFavoritos: false });
 *   }
 * }
 *
 * ➡️ Por que valueChanges e não (ngSubmit)?
 *    Filtros costumam reagir EM TEMPO REAL — usuário digita, lista atualiza.
 *    Submit é pra forms que mandam pra API (cadastro, checkout).
 *
 * ➡️ Por que checar form.valid antes de emitir?
 *    Se a busca tem 1 caractere só, o filtro tá "quebrado" — não vale propagar.
 *
 * ➡️ Cuidado: Validators.minLength NÃO considera string vazia como erro.
 *    Ou seja, busca vazia + outros filtros = válido. Que é exatamente o
 *    comportamento esperado (filtrar só por tipo, sem busca).
 * ============================================================
 */
