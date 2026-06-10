// ============================================================
// PRÁTICA — Módulo 16: Contador com Signals
// ============================================================
//
// COMO USAR:
// 1. Dentro do seu projeto Angular (criado nos módulos anteriores),
//    crie a pasta  src/app/contador/  e copie ESTES dois arquivos:
//      - contador.component.ts
//      - contador.component.html
//
// 2. Importe e use o componente no AppComponent:
//      imports: [ContadorComponent]
//      <app-contador />
//
// 3. Rode  ng serve  e veja o contador funcionando.
//
// O QUE PRESTAR ATENÇÃO:
//   - `total` é um Signal<number>: lê com total(), escreve com .set/.update
//   - `dobro` é um computed: NUNCA você atribui valor nele, ele se calcula
//     sozinho a cada mudança em total
//   - No template usamos {{ total() }} e {{ dobro() }} — sempre com ()
// ============================================================

import { Component, signal, computed } from '@angular/core';

@Component({
  selector: 'app-contador',
  standalone: true,
  imports: [],
  templateUrl: './contador.component.html'
})
export class ContadorComponent {
  // Signal "fonte de verdade" — o número atual do contador.
  // signal(0) cria um Signal<number> com valor inicial 0.
  total = signal(0);

  // computed: valor DERIVADO. Sempre que `total` muda, `dobro` recalcula.
  // Não precisamos chamar nada manualmente — o Angular detecta a dependência.
  dobro = computed(() => this.total() * 2);

  // .update(fn) recebe o valor atual e retorna o novo. Bom pra incremento.
  incrementar(): void {
    this.total.update(v => v + 1);
  }

  decrementar(): void {
    this.total.update(v => v - 1);
  }

  // .set(novoValor) substitui o valor direto. Bom pra "voltar pro zero".
  resetar(): void {
    this.total.set(0);
  }
}
