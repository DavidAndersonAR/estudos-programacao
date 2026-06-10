// favoritos-store.service.ts
// Store global de favoritos — service singleton com signals + persistência.
//
// Padrão deste arquivo:
//   1. signal privada (_favoritos)  → única que sofre mutação
//   2. exposição readonly             → componentes só leem
//   3. computed (total)               → derivado, recalcula sozinho
//   4. métodos públicos               → única porta de entrada pra escrita
//   5. effect()                       → persiste em localStorage a cada mudança

import { Injectable, signal, computed, effect } from '@angular/core';

const STORAGE_KEY = 'favoritos:v1';

@Injectable({ providedIn: 'root' })
export class FavoritosStoreService {

    // ----- ESTADO -----------------------------------------------------------

    // signal privada — armazena os IDs dos pokémons favoritados.
    // Inicializa lendo o localStorage (ou [] se nunca foi salvo).
    private readonly _favoritos = signal<number[]>(this.carregarInicial());

    // Exposição readonly — componentes leem isso, mas não conseguem chamar .set()
    readonly favoritos = this._favoritos.asReadonly();

    // ----- DERIVADOS (COMPUTED) ---------------------------------------------

    // Quantos favoritos existem agora. Recalcula automaticamente.
    readonly total = computed(() => this._favoritos().length);

    // Existe favorito? Útil pra mostrar "lista vazia" na UI.
    readonly vazio = computed(() => this._favoritos().length === 0);

    // ----- CONSTRUCTOR (efeito de persistência) -----------------------------

    constructor() {
        // effect() roda toda vez que uma signal lida lá dentro mudar.
        // Como lemos this._favoritos(), ele dispara em cada add/remove/limpar.
        effect(() => {
            const ids = this._favoritos();
            localStorage.setItem(STORAGE_KEY, JSON.stringify(ids));
        });
    }

    // ----- MÉTODOS PÚBLICOS (mutação controlada) ----------------------------

    // Adiciona um ID. Se já existe, não duplica.
    adicionar(id: number): void {
        this._favoritos.update(atuais =>
            atuais.includes(id) ? atuais : [...atuais, id]
        );
    }

    // Remove um ID. Se não existe, ignora.
    remover(id: number): void {
        this._favoritos.update(atuais => atuais.filter(i => i !== id));
    }

    // Alterna: se está, remove; se não está, adiciona.
    // Padrão útil pro botão "estrelinha" dos cards.
    toggle(id: number): void {
        this._favoritos.update(atuais =>
            atuais.includes(id)
                ? atuais.filter(i => i !== id)
                : [...atuais, id]
        );
    }

    // Limpa tudo.
    limpar(): void {
        this._favoritos.set([]);
    }

    // Helper: checa se um ID está favoritado (útil em templates).
    ehFavorito(id: number): boolean {
        return this._favoritos().includes(id);
    }

    // ----- PRIVADO ----------------------------------------------------------

    // Lê o localStorage com defesa contra dados corrompidos.
    private carregarInicial(): number[] {
        try {
            const raw = localStorage.getItem(STORAGE_KEY);
            if (!raw) return [];
            const parsed = JSON.parse(raw);
            return Array.isArray(parsed) ? parsed : [];
        } catch {
            // localStorage quebrado ou JSON inválido → começa do zero
            return [];
        }
    }
}
