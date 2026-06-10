# Desafio — Pokedex 100% Standalone com tudo do Angular moderno

## 🎯 Missão
Construir uma **Pokedex de verdade** usando **apenas** recursos modernos do Angular (17/18): standalone, router com view transitions, `@defer`, `@let`. Sem `NgModule`, sem `RouterModule.forRoot`, sem `HttpClientModule`.

## 📋 Requisitos
1. **`app.config.ts`** com `provideRouter(routes, withViewTransitions())` e `provideHttpClient()`.
2. **`app.routes.ts`** com duas rotas:
    - `/` → lista de pokémons
    - `/pokemon/:id` → detalhes do pokémon (carregada via `loadComponent`)
3. **3 componentes standalone**:
    - `PokemonListaComponent` — grid de cards com `routerLink` para o detalhe
    - `PokemonDetalheComponent` — usa `@let` no template e adia o painel de stats com `@defer (on interaction)`
    - `PokemonStatsPesadoComponent` — o painel "pesado" deferido
4. **Animação automática** entre lista e detalhe via View Transitions API (já vem do `withViewTransitions()`).
5. **`@let`** em pelo menos 2 lugares pra encurtar templates.

## ✅ Critérios de aceite
- [ ] `bootstrapApplication` em vez de `AppModule`
- [ ] Nenhum arquivo com `@NgModule`
- [ ] Lista renderiza eager (chega no bundle inicial)
- [ ] Detalhe é lazy (`loadComponent`)
- [ ] Stats pesado é deferido por `on interaction` (botão "Ver stats")
- [ ] View transitions ativas (testa no Chrome 111+)
- [ ] `@let` aparece nos templates de pelo menos 2 componentes

## 🚦 Como rodar
1. `ng new pokedex-moderna --standalone --routing --style=css --ssr=false`
2. Copia o conteúdo deste `desafio/` por cima da pasta `src/app/`.
3. `ng serve` e abre `http://localhost:4200`.

## 💡 Dicas
- Pra ver a view transition: use Chrome ou Edge, clica num card e veja o cross-fade.
- Pra ver o `@defer`: abre DevTools > Network > JS. O chunk do `stats-pesado` só desce quando você clica em **Ver stats**.
- `track` no `@for` é obrigatório — use `pokemon.id`.

A solução completa está em todos os `.ts`/`.html` desta pasta, com **comentários explicando cada decisão**.
