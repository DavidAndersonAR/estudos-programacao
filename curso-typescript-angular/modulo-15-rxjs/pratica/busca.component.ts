// pratica/busca.component.ts
// Pipeline clássico de busca:
//   input -> Subject -> debounceTime -> distinctUntilChanged -> switchMap -> API mockada
//
// A "API mockada" devolve um Observable que simula latência de rede com `of(...).pipe(delay(...))`.

import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { Observable, Subject, of } from 'rxjs';
import {
  debounceTime,
  delay,
  distinctUntilChanged,
  switchMap,
  tap
} from 'rxjs/operators';

@Component({
  selector: 'app-busca',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './busca.component.html'
})
export class BuscaComponent implements OnInit {
  // Subject que recebe cada tecla digitada
  private termo$ = new Subject<string>();

  // Observable público que o template consome com | async
  resultados$!: Observable<string[]>;

  // Flag de "está buscando" só pra dar feedback visual
  buscando = false;

  // Base de dados fake
  private base = [
    'Angular', 'RxJS', 'TypeScript', 'JavaScript',
    'React', 'Vue', 'Svelte', 'Node', 'NestJS', 'Deno'
  ];

  ngOnInit() {
    this.resultados$ = this.termo$.pipe(
      debounceTime(300),              // espera 300ms de silêncio
      distinctUntilChanged(),         // ignora se digitou o mesmo termo
      tap(() => this.buscando = true),
      switchMap(termo => this.apiMock(termo)),
      tap(() => this.buscando = false)
    );
  }

  // Chamado pelo template a cada `(input)`
  aoDigitar(valor: string) {
    this.termo$.next(valor);
  }

  // Simula uma chamada HTTP que demora 400ms e devolve um array filtrado
  private apiMock(termo: string): Observable<string[]> {
    const t = termo.trim().toLowerCase();
    const filtrados = t
      ? this.base.filter(item => item.toLowerCase().includes(t))
      : [];
    return of(filtrados).pipe(delay(400));
  }
}
