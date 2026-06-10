// pratica/rxjs-exemplos.component.ts
// Exemplos básicos de RxJS: of, from, fromEvent + operators map/filter/tap.
// Copie pra src/app/ do seu projeto Angular, importe no AppComponent
// (ou registre como rota) e teste no navegador.

import { CommonModule } from '@angular/common';
import {
  AfterViewInit,
  Component,
  ElementRef,
  OnDestroy,
  ViewChild
} from '@angular/core';
import { from, fromEvent, Subscription } from 'rxjs';
import { filter, map, tap } from 'rxjs/operators';

@Component({
  selector: 'app-rxjs-exemplos',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './rxjs-exemplos.component.html'
})
export class RxjsExemplosComponent implements AfterViewInit, OnDestroy {
  // Resultados do exemplo 1 (from + map + filter)
  resultadosFrom: number[] = [];

  // Contador de cliques do exemplo 2 (fromEvent)
  cliques = 0;
  ultimaCoordenada = '';

  @ViewChild('botaoClick') botaoClick!: ElementRef<HTMLButtonElement>;
  private subFromEvent?: Subscription;

  // ------------------------------------------------------------------
  // Exemplo 1: from([...]) + map + filter
  // ------------------------------------------------------------------
  disparar() {
    this.resultadosFrom = []; // limpa a lista antes de rodar de novo

    from([1, 2, 3, 4, 5]).pipe(
      tap(n => console.log('valor original:', n)), // espia (debug)
      map(n => n * 2),       // 2, 4, 6, 8, 10
      filter(n => n > 4)     // 6, 8, 10
    ).subscribe({
      next: valor => this.resultadosFrom.push(valor),
      complete: () => console.log('Stream completou!')
    });
  }

  // ------------------------------------------------------------------
  // Exemplo 2: fromEvent — capturando clicks em um botão
  // ------------------------------------------------------------------
  ngAfterViewInit() {
    // fromEvent transforma qualquer EventTarget em Observable
    this.subFromEvent = fromEvent<MouseEvent>(
      this.botaoClick.nativeElement,
      'click'
    ).pipe(
      tap(() => this.cliques++),
      map(ev => `(${ev.clientX}, ${ev.clientY})`)
    ).subscribe(coord => this.ultimaCoordenada = coord);
  }

  ngOnDestroy() {
    // CRUCIAL: cancela a inscrição quando o componente é destruído
    // (senão, memory leak).
    this.subFromEvent?.unsubscribe();
  }
}
