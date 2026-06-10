// ============================================================
// PRÁTICA — Módulo 09: Hello Angular
// ============================================================
//
// COMO USAR:
// 1. Crie um projeto Angular novo (uma vez):
//      npm install -g @angular/cli
//      ng new hello-angular --standalone --routing --style=css
//      cd hello-angular
//
// 2. Copie ESTE arquivo por cima de  src/app/app.component.ts
//    Copie o app.component.html por cima de  src/app/app.component.html
//
// 3. Rode:
//      ng serve
//    Abra http://localhost:4200 e veja o "Olá, Angular!".
//
// 4. Brinque: mude o valor de `title` e salve. O navegador
//    atualiza sozinho graças ao hot reload.
// ============================================================

import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  // `title` é uma propriedade da classe.
  // No template usamos {{ title }} pra mostrar o valor — isso se chama
  // INTERPOLAÇÃO. É a forma mais simples de jogar dado da classe na tela.
  title = 'hello-angular';
}
