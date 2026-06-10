// desafio/busca-pokemons.component.ts
//
// ===========================================================================
// 🎯 DESAFIO — Busca de Pokémons com RxJS
// ===========================================================================
// Construa um campo de busca que consulta a PokeAPI em tempo real, com:
//   1. debounceTime(400) — só busca quando o usuário parar de digitar
//   2. distinctUntilChanged() — não refaz busca se digitou o mesmo termo
//   3. switchMap() — cancela request antiga quando o usuário digita de novo
//   4. catchError() — mostra mensagem amigável em vez de quebrar a tela
//   5. loading enquanto a request está pendente
//
// Use HttpClient (via PokedexService) e Subject (ou BehaviorSubject) pra
// receber os termos digitados.
//
// 💡 Lembre-se: no app.config.ts adicione provideHttpClient() em providers.
// ===========================================================================
//
// ----------------------- 📝 TODOs -----------------------
// [ ] TODO 1: crie um Subject<string> chamado `termo$`
// [ ] TODO 2: no ngOnInit, monte o pipeline `resultados$`:
//             debounceTime(400) → distinctUntilChanged()
//             → tap(() => loading=true) → switchMap(service.buscar)
//             → tap(() => loading=false) → catchError(...)
// [ ] TODO 3: crie `aoDigitar(valor)` que faz `this.termo$.next(valor)`
// [ ] TODO 4: no HTML, use `| async` pra renderizar `resultados$`
// [ ] TODO 5: mostre "Carregando..." quando `loading` for true
// [ ] TODO 6: mostre mensagem de erro quando `erro` não for vazio
// ---------------------------------------------------------

import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { Observable, Subject, of } from 'rxjs';
import {
  catchError,
  debounceTime,
  distinctUntilChanged,
  switchMap,
  tap
} from 'rxjs/operators';
import { Pokemon, PokedexService } from './pokedex.service';

@Component({
  selector: 'app-busca-pokemons',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './busca-pokemons.component.html'
})
export class BuscaPokemonsComponent implements OnInit {
  private service = inject(PokedexService);

  // Subject que recebe cada termo digitado
  private termo$ = new Subject<string>();

  resultados$!: Observable<Pokemon[]>;
  loading = false;
  erro = '';

  ngOnInit() {
    this.resultados$ = this.termo$.pipe(
      debounceTime(400),                       // 1. espera digitação parar
      distinctUntilChanged(),                  // 2. ignora termos repetidos
      tap(() => {                              // 3. ativa loading
        this.loading = true;
        this.erro = '';
      }),
      switchMap(termo =>                       // 4. cancela busca antiga
        this.service.buscar(termo).pipe(
          catchError(err => {                  // 5. trata erro sem matar o stream
            console.error('Erro na PokeAPI:', err);
            this.erro = 'Não consegui buscar agora. Tente de novo.';
            return of([] as Pokemon[]);
          })
        )
      ),
      tap(() => this.loading = false)          // 6. desliga loading
    );
  }

  aoDigitar(valor: string) {
    this.termo$.next(valor);
  }
}

/* ===========================================================================
   ✅ SOLUÇÃO COMENTADA — o que está acontecendo
   ===========================================================================

   1. `termo$` é um Subject — funciona como uma "ponte" entre o evento de
      input do template e o pipeline reativo. Toda vez que o usuário digita,
      chamamos `termo$.next(valor)`.

   2. `debounceTime(400)` é o que segura a mão: só deixa o valor passar se
      o usuário ficar 400ms sem digitar nada. Evita disparar uma request
      a cada tecla.

   3. `distinctUntilChanged()` compara com o termo anterior. Se o usuário
      digitou "pika" e apagou+redigitou "pika" rapidinho, o `debounceTime`
      deixa passar mas o `distinctUntilChanged` barra — economiza request.

   4. `tap(...)` é usado pra efeitos colaterais (ativar loading, limpar erro).
      Não altera o valor que flui no stream.

   5. `switchMap` é a peça mais importante aqui: ele **cancela** a request
      anterior se o usuário digitar algo novo antes da resposta chegar.
      Imagine: usuário digita "char" (busca dispara), 50ms depois digita
      "charm" (cancela "char" e busca "charm"). Sem switchMap, você poderia
      receber "char" depois de "charm" e mostrar resultado errado!

   6. `catchError` precisa estar **dentro** do switchMap, em volta da chamada
      ao service. Se estivesse fora, qualquer erro **completaria** o stream
      principal e o componente pararia de reagir a novas digitações.

   7. No template, `resultados$ | async` faz subscribe/unsubscribe automático.
      Zero risco de memory leak.

   8. PokedexService.buscar() limita a 10 resultados e usa forkJoin pra
      buscar os detalhes (com a imagem) em paralelo.

   ===========================================================================
*/
