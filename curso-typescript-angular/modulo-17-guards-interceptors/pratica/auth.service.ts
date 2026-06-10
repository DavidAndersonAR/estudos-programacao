// auth.service.ts — service de autenticação simulada com Signals
//
// Por que signal e não BehaviorSubject?
// - Reativo de forma síncrona (sem subscribe).
// - Integração nativa com o template (lê só com `auth.usuarioLogado()`).
// - Padrão moderno do Angular 17+.

import { Injectable, signal, computed } from '@angular/core';

export interface User {
  id: number;
  nome: string;
  email: string;
  token: string; // token simulado, em app real vem do backend
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  // signal privado pra escrita controlada
  private readonly _usuarioLogado = signal<User | null>(null);

  // signal readonly exposto pra componentes (não dá pra reescrever de fora)
  readonly usuarioLogado = this._usuarioLogado.asReadonly();

  // computed: derivado automático — recalcula sempre que usuarioLogado muda
  readonly estaLogado = computed(() => this._usuarioLogado() !== null);

  /**
   * Login simulado. Em app real seria HttpClient.post('/auth/login', ...).
   * Aceita qualquer email com senha "123456" — só pra demonstrar fluxo.
   */
  login(email: string, senha: string): boolean {
    if (senha !== '123456') return false;

    const user: User = {
      id: 1,
      nome: email.split('@')[0],
      email,
      // token fake — em produção vem assinado pelo backend (JWT)
      token: btoa(`${email}:${Date.now()}`),
    };

    this._usuarioLogado.set(user);
    return true;
  }

  logout(): void {
    this._usuarioLogado.set(null);
  }
}
