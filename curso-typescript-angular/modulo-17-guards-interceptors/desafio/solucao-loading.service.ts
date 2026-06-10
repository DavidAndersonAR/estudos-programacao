// solucao-loading.service.ts
// Contador de requests em andamento. O overlay liga sempre que > 0.
//
// Por que contador e não boolean?
// - Múltiplos requests podem rodar em paralelo.
// - Se um terminar antes do outro e a gente usasse boolean, o overlay sumia
//   enquanto outro request ainda está no ar.
// - Com contador, o overlay só desliga quando TODOS terminaram.

import { Injectable, signal, computed } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class LoadingService {
  private readonly _loadingCount = signal(0);

  readonly loadingCount = this._loadingCount.asReadonly();
  readonly carregando = computed(() => this._loadingCount() > 0);

  start(): void {
    this._loadingCount.update((n) => n + 1);
  }

  stop(): void {
    // Math.max defensivo: se algum dia o stop() rodar sem start() correspondente,
    // não deixamos o contador ir negativo (overlay nunca mais ligaria certo).
    this._loadingCount.update((n) => Math.max(0, n - 1));
  }
}
