// ============================================================
// PRÁTICA — Módulo 16: Carrinho com signal de array + effect
// ============================================================
//
// COMO USAR:
// 1. Crie  src/app/carrinho/  e copie estes dois arquivos.
// 2. Use no AppComponent:
//      imports: [CarrinhoComponent]
//      <app-carrinho />
// 3. Rode  ng serve, adicione itens e abra o console (F12) —
//    veja o `effect` logando a cada mudança.
//
// PONTOS-CHAVE:
//   - signal<Item[]>([]) — anotamos o tipo porque [] sozinho não infere
//   - .update(arr => [...arr, novo]) — SEMPRE criar novo array (não mutar)
//   - computed para `total` (deriva de `itens`)
//   - effect roda automaticamente sempre que `itens` muda
// ============================================================

import { Component, signal, computed, effect } from '@angular/core';

interface Item {
  nome: string;
  preco: number;
}

@Component({
  selector: 'app-carrinho',
  standalone: true,
  imports: [],
  templateUrl: './carrinho.component.html'
})
export class CarrinhoComponent {
  // Signal de array — note a tipagem explícita.
  itens = signal<Item[]>([]);

  // computed: soma de todos os preços. Recalcula sozinho.
  total = computed(() =>
    this.itens().reduce((soma, item) => soma + item.preco, 0)
  );

  // computed também serve pra valores simples — aqui o tamanho da lista.
  quantidade = computed(() => this.itens().length);

  constructor() {
    // effect roda 1x ao ser criado e DEPOIS sempre que algum signal
    // lido dentro dele muda. Aqui dependemos de `itens`, então a cada
    // adição/remoção esse log dispara.
    effect(() => {
      console.log('[carrinho] mudou:', this.itens(), 'total:', this.total());
    });
  }

  // Adiciona um item exemplo (em app real viria de um formulário).
  adicionar(nome: string, preco: number): void {
    // Spread cria NOVO array — signal só detecta mudança por referência.
    this.itens.update(arr => [...arr, { nome, preco }]);
  }

  // Remove pelo índice — filter já devolve novo array.
  remover(indice: number): void {
    this.itens.update(arr => arr.filter((_, i) => i !== indice));
  }

  limpar(): void {
    this.itens.set([]);
  }
}
