// ============================================================
// DESAFIO — Módulo 09: Tela inicial do Pokedex
// ============================================================
//
// Este é o INÍCIO do projeto-fio do curso: a Pokedex.
// Vamos construir essa mesma app, módulo por módulo, até o fim.
//
// COMO USAR:
// 1. Crie o projeto Angular (uma vez):
//      npm install -g @angular/cli
//      ng new pokedex --standalone --routing --style=css
//      cd pokedex
//
// 2. Copie os TRÊS arquivos desta pasta por cima dos
//    arquivos correspondentes em  src/app/  :
//      - app.component.ts
//      - app.component.html
//      - app.component.css
//
// 3. Rode:
//      ng serve
//    Abra http://localhost:4200 e veja a capa do Pokedex.
//
// DESAFIO EXTRA (sem mexer em código novo ainda):
//   - Troque o texto do subtítulo
//   - Mude as cores do CSS pra um tema diferente (ex.: azul de Squirtle)
//   - Adicione um <p> com seu nome como "criador"
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
  // Dados da tela — vindos da classe, exibidos via interpolação no HTML.
  title = 'Pokedex';
  subtitulo = '150 pokémons originais';
  textoBotao = 'Começar';
}
