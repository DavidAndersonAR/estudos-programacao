// solucao-loading.component.ts
// Overlay global, totalmente reativo via signal `carregando`.
// Sem subscribe, sem async pipe — só o signal sendo lido no template.

import { Component, inject } from '@angular/core';
import { LoadingService } from './solucao-loading.service';

@Component({
  selector: 'app-loading',
  standalone: true,
  template: `
    @if (loading.carregando()) {
      <div class="overlay" role="status" aria-live="polite">
        <div class="spinner"></div>
        <span>Carregando... ({{ loading.loadingCount() }})</span>
      </div>
    }
  `,
  styles: [`
    .overlay {
      position: fixed; inset: 0;
      background: rgba(0,0,0,.4);
      display: grid; place-items: center; gap: 1rem;
      color: white; z-index: 9999;
    }
    .spinner {
      width: 48px; height: 48px;
      border: 4px solid rgba(255,255,255,.3);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
  `],
})
export class LoadingComponent {
  // protected pra ficar visível no template inline.
  protected loading = inject(LoadingService);
}
