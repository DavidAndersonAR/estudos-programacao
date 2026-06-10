// solucao-auth.service.ts
// Mesma base da prática, mas pronta pra combinar com loading + error.

import { Injectable, signal, computed } from '@angular/core';

export interface User {
  id: number;
  nome: string;
  email: string;
  token: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly _usuarioLogado = signal<User | null>(null);

  readonly usuarioLogado = this._usuarioLogado.asReadonly();
  readonly estaLogado = computed(() => this._usuarioLogado() !== null);

  login(email: string, senha: string): boolean {
    if (senha !== '123456') return false;

    this._usuarioLogado.set({
      id: 1,
      nome: email.split('@')[0],
      email,
      token: btoa(`${email}:${Date.now()}`),
    });
    return true;
  }

  logout(): void {
    this._usuarioLogado.set(null);
  }
}
