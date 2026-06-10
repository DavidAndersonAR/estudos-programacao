# Módulo 12 — Routing

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar o que é **roteamento client-side** e por que SPA precisa dele
- Configurar rotas no formato **standalone (Angular 17+)** usando `app.routes.ts`
- Usar `<router-outlet />` e `routerLink` no template
- Ler **parâmetros de rota** (`/pokemon/:id`) com `ActivatedRoute`
- Carregar componentes em **lazy** com `loadComponent`
- Definir **rotas filho** (`children`), **redirect** e **wildcard `**`** (NotFound)
- Reconhecer a diferença entre o Router moderno (standalone) e o antigo (NgModule)

## 🧐 O que é roteamento client-side?
Numa SPA (Single Page Application), o navegador **não recarrega a página** quando você clica num link interno. Quem decide "qual componente mostrar agora" é o **Router do Angular** — ele lê a URL atual e renderiza o componente certo dentro de um espaço reservado no template.

Sem roteamento, sua aplicação é uma tela só. Com roteamento, ela vira um app de verdade: home, lista, detalhe, login, 404, etc.

A vantagem é a velocidade: nada é baixado do servidor de novo, só o que o Router precisa.

## 🧱 Os 3 ingredientes do Router

1. **`app.routes.ts`** — onde você declara "URL X mostra componente Y"
2. **`<router-outlet />`** — placeholder no template onde o componente da rota aparece
3. **`routerLink`** — diretiva para criar links que mudam a rota sem recarregar

```typescript
// app.routes.ts
import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home.component';

export const routes: Routes = [
  { path: '', component: HomeComponent },
];
```

```typescript
// app.component.ts
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink],
  template: `
    <nav>
      <a routerLink="/">Home</a>
      <a routerLink="/pokemons">Pokémons</a>
    </nav>
    <router-outlet />
  `,
})
export class AppComponent {}
```

`<router-outlet />` é o "buraco" onde o Angular injeta o componente da URL atual.

## 🚀 Bootstrap com `provideRouter`
No `main.ts` (ou `app.config.ts`) você registra o Router uma vez:

```typescript
// main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { AppComponent } from './app.component';
import { routes } from './app.routes';

bootstrapApplication(AppComponent, {
  providers: [provideRouter(routes)],
});
```

Pronto — toda a aplicação já sabe rotear.

## 🔗 `routerLink` vs `href`
**Nunca** use `<a href="/pokemons">` em SPA Angular — isso recarrega a página inteira. Use:

```html
<a routerLink="/pokemons">Pokémons</a>
<a [routerLink]="['/pokemons', poke.id]">Ver detalhes</a>
```

A segunda forma (com colchetes e array) serve quando partes da URL são dinâmicas.

## 🎯 Parâmetros de rota — `/pokemon/:id`
Os dois pontos marcam um parâmetro:

```typescript
{ path: 'pokemons/:id', component: DetalhePokemonComponent }
```

URL `/pokemons/25` casa com essa rota e `id` vale `"25"`.

### Lendo o parâmetro no componente

```typescript
import { ActivatedRoute } from '@angular/router';

export class DetalhePokemonComponent {
  private route = inject(ActivatedRoute);

  // Forma 1 — snapshot (mais simples, leitura única)
  id = this.route.snapshot.params['id'];

  // Forma 2 — paramMap (mesma coisa, com API melhor)
  id2 = this.route.snapshot.paramMap.get('id');
}
```

**Quando usar cada uma:**
- **`snapshot`** — quando o componente NÃO é reutilizado entre IDs (caso comum). Leitura única, simples.
- **`paramMap` como Observable** — quando o usuário pode trocar o ID sem sair do componente (ex: botão "próximo"). O componente continua vivo, então você precisa "escutar" mudanças:

```typescript
this.route.paramMap.subscribe(params => {
  this.id = params.get('id');
});
```

Por enquanto, **use snapshot** — é o suficiente em 90% dos casos.

## 💤 Rotas lazy — `loadComponent`
Por padrão, o Angular baixa **todo o JS da aplicação** na primeira visita. Com `loadComponent`, ele só baixa o componente quando a rota é acessada — melhor performance.

```typescript
{
  path: 'pokemons/:id',
  loadComponent: () =>
    import('./pages/detalhe-pokemon.component').then(m => m.DetalhePokemonComponent)
}
```

Sintaxe: função que retorna `import(...)` dinâmico. O bundler (Vite/esbuild) separa esse componente num arquivo próprio.

**Regra prática**: páginas grandes ou pouco usadas → lazy. Home e navbar → eager (importação normal).

## 🪆 Rotas filho — `children`
Quando uma página tem sub-rotas (ex: `/admin/usuarios`, `/admin/pedidos`), use `children`:

```typescript
{
  path: 'admin',
  component: AdminLayoutComponent,
  children: [
    { path: 'usuarios', component: UsuariosComponent },
    { path: 'pedidos', component: PedidosComponent },
  ]
}
```

O `AdminLayoutComponent` precisa ter seu próprio `<router-outlet />` dentro — é onde os filhos vão renderizar. Dá pra aninhar layouts assim quantas vezes precisar.

## ↪️ Redirect e wildcard `**`

```typescript
export const routes: Routes = [
  { path: '', redirectTo: '/pokemons', pathMatch: 'full' },
  { path: 'pokemons', component: ListaPokemonsComponent },
  { path: '**', component: NotFoundComponent },
];
```

- **`redirectTo`** — `/` manda direto pra `/pokemons`. O `pathMatch: 'full'` é obrigatório aqui (senão redireciona tudo).
- **`**`** — wildcard, casa com qualquer URL não reconhecida. **Sempre por último** — a ordem importa, o Router para na primeira que casar.

## 🆚 Angular moderno (standalone) vs antigo (NgModule)

| Antes (NgModule) | Agora (standalone, v17+) |
|------------------|--------------------------|
| `AppRoutingModule` com `@NgModule` | `app.routes.ts` exportando um array |
| `RouterModule.forRoot(routes)` | `provideRouter(routes)` em `main.ts` |
| Componentes declarados em `declarations` | Cada componente importa `RouterOutlet`/`RouterLink` direto |
| `loadChildren: () => import('...').then(m => m.AdminModule)` | `loadComponent: () => import('...').then(m => m.AdminComponent)` |

Você ainda vai encontrar muito código antigo por aí — saiba reconhecer, mas **escreva sempre standalone** em projetos novos.

## ✅ Auto-verificação
- [ ] Sei o que faz `<router-outlet />` e `routerLink`
- [ ] Sei declarar uma rota com parâmetro `:id` e ler com `snapshot.paramMap.get`
- [ ] Sei usar `loadComponent` pra rota lazy
- [ ] Sei pra que serve `pathMatch: 'full'` e o wildcard `**`
- [ ] Sei a diferença entre standalone e NgModule pro Router

## 🚦 Próximos passos
1. Abra `pratica/` — lista + detalhe de Pokémon, tudo já roteado.
2. Encare o **desafio**: mesma ideia, mais polido — cards, botão voltar, `routerLinkActive` na navbar.

Próximo módulo: **Forms** — formulários reativos e template-driven.
