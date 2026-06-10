// solucao-login.component.ts
// Formulário simples (template-driven com ngModel).
// Lê ?redirect= do queryParam pra mandar de volta após login.

import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from './solucao-auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule],
  template: `
    <section class="login">
      <h2>Entrar</h2>

      <form (submit)="entrar($event)">
        <label>
          Email
          <input type="email" name="email" [(ngModel)]="email" required />
        </label>

        <label>
          Senha (dica: 123456)
          <input type="password" name="senha" [(ngModel)]="senha" required />
        </label>

        <button type="submit">Entrar</button>
      </form>

      @if (erro()) {
        <p class="erro">Email ou senha inválidos.</p>
      }
    </section>
  `,
  styles: [`
    .login { max-width: 320px; margin: 2rem auto; display: grid; gap: 1rem; }
    label { display: grid; gap: .25rem; }
    .erro { color: crimson; }
  `],
})
export class LoginComponent {
  private auth = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  email = '';
  senha = '';
  // signal pra mostrar erro reativamente sem zone.js change detection extra
  erro = signal(false);

  entrar(event: Event): void {
    event.preventDefault();
    const ok = this.auth.login(this.email, this.senha);

    if (!ok) {
      this.erro.set(true);
      return;
    }

    // Volta pra rota original (?redirect) ou pra home.
    const redirect = this.route.snapshot.queryParamMap.get('redirect') ?? '/';
    this.router.navigateByUrl(redirect);
  }
}
