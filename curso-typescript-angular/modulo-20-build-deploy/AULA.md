# Módulo 20 — Build, Deploy e Boas Práticas

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Rodar `ng build` e entender o que sai em `dist/`
- Reconhecer **lazy chunks** no output do build
- Inspecionar o tamanho do seu bundle com **source-map-explorer**
- Separar configuração por ambiente com **environment files**
- Aplicar as 4 boas práticas de performance que mais importam
- Decidir entre app **estática (SPA)**, **PWA** ou **SSR**
- Publicar sua Pokedex em uma das opções gratuitas (Vercel, Netlify, GitHub Pages, Cloudflare Pages, Firebase Hosting)

## 🧐 Por que esse módulo importa
Até aqui você rodou tudo com `ng serve` — modo dev, hot reload, bundle gigante, source maps ligados. Isso **não vai pra produção**. Pra produção a gente quer:
- Código **minificado** (sem espaço, nomes curtos)
- **Tree-shaking** (joga fora o que não é usado)
- **AOT compilation** (Angular já compila templates em build, não em runtime)
- **Hash no nome dos arquivos** (cache busting — força o navegador a baixar a versão nova)

O `ng build` faz tudo isso com **um comando**.

---

## 🏗️ `ng build` — anatomia
A partir do **Angular 17**, `ng build` já roda em **modo production por padrão**. Não precisa mais do `--prod`.

```bash
ng build
```

Output típico:
```
Initial chunk files | Names         |  Raw size | Estimated transfer size
main-XYZABC.js      | main          | 245.30 kB |        78.12 kB
polyfills-XYZABC.js | polyfills     |  33.15 kB |        10.74 kB
styles-XYZABC.css   | styles        |   6.41 kB |         1.85 kB

Lazy chunk files    | Names         |  Raw size | Estimated transfer size
chunk-ABCDEF.js     | detail-page   |  12.50 kB |         4.20 kB
```

### O que acabou de acontecer?
- **Initial chunks**: o que vem no primeiro carregamento. Quanto menor, mais rápido o primeiro paint.
- **Lazy chunks**: arquivos baixados **só quando necessário** (geralmente uma rota lazy).
- **Estimated transfer size**: o tamanho **depois do gzip/brotli** no servidor — é o que o usuário realmente baixa.

### Pasta `dist/`
```
dist/
└── pokedex/
    └── browser/
        ├── index.html
        ├── main-XYZ.js
        ├── polyfills-XYZ.js
        ├── styles-XYZ.css
        ├── assets/
        └── favicon.ico
```

O que você sobe pro servidor é o conteúdo de `dist/pokedex/browser/`. Só isso.

---

## 🪓 Lazy chunks automáticos com rotas lazy
Você já viu rotas lazy no módulo 12. Lembrando:

```typescript
// app.routes.ts
export const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'pokemon/:id',
    loadComponent: () => import('./detail/detail.component').then(m => m.DetailComponent)
  }
];
```

O `loadComponent` faz o Angular CLI **dividir o bundle automaticamente**. O `detail.component.ts` (e tudo que ele importa) vira um chunk separado, baixado **só quando o usuário clica numa Pokemon**.

**Resultado prático**: a Pokedex carrega rápido na home, e a tela de detalhe só é baixada na hora.

> 💡 Regra de ouro: **toda rota que não é a inicial deveria ser lazy**.

---

## 🔬 Bundle analyzer com `source-map-explorer`
Seu bundle tá grande e você não sabe por quê? Use o **source-map-explorer**.

### Passo 1 — Build com source maps
```bash
ng build --source-map
```

### Passo 2 — Instale o analisador
```bash
npm install -g source-map-explorer
```

### Passo 3 — Rode
```bash
source-map-explorer dist/pokedex/browser/*.js
```

Abre um **mapa visual** no navegador — cada quadrado é uma dependência, o tamanho dele é o peso no bundle. Você vê na hora se importou alguma lib gigante por engano (tipo `lodash` inteiro em vez de só `lodash/debounce`).

---

## 🌎 Environment files — config por ambiente
**Problema**: a URL da API em dev é `http://localhost:3000`, em produção é `https://api.pokedex.com`. Como trocar sem mexer no código toda vez?

**Resposta**: `environment.ts` + `environment.prod.ts`.

### Estrutura
```
src/
└── environments/
    ├── environment.ts          ← dev (padrão)
    └── environment.prod.ts     ← produção
```

### Conteúdo
```typescript
// environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000',
  enableLogs: true
};
```

```typescript
// environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://pokeapi.co/api/v2',
  enableLogs: false
};
```

### Como usar
```typescript
import { environment } from '../environments/environment';

const url = `${environment.apiUrl}/pokemon`;
if (environment.enableLogs) console.log('Buscando:', url);
```

Você importa **sempre** o `environment.ts`. Quando você roda `ng build`, o Angular **troca o arquivo** automaticamente pelo `environment.prod.ts` via **file replacements** no `angular.json`:

```json
// angular.json
"configurations": {
  "production": {
    "fileReplacements": [{
      "replace": "src/environments/environment.ts",
      "with": "src/environments/environment.prod.ts"
    }]
  }
}
```

> ⚠️ **Nunca coloque segredos** (API keys privadas, senhas) em environment files. Eles **vão pro bundle** e qualquer pessoa que abrir o DevTools vê. Pra segredos: backend.

---

## ⚡ Performance — as 4 boas práticas que mais importam

### 1. `ChangeDetectionStrategy.OnPush`
Por padrão Angular **re-renderiza tudo** sempre que algo muda. Com `OnPush`, ele só re-renderiza um componente quando:
- Um `@Input()` muda (referência nova)
- Um evento é disparado dentro dele
- Um observable assinado com `async` pipe emite

```typescript
import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-pokemon-card',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,  // ← aqui
  templateUrl: './pokemon-card.component.html'
})
export class PokemonCardComponent {}
```

Em listas grandes, isso é **ordem de magnitude** mais rápido.

### 2. `trackBy` em `@for`
Sem `trackBy`, quando a lista muda o Angular recria **todos** os elementos do DOM. Com `trackBy`, ele reaproveita o que não mudou.

```html
<!-- ❌ Sem trackBy — re-renderiza tudo -->
@for (pokemon of pokemons; track $index) {
  <app-pokemon-card [pokemon]="pokemon" />
}

<!-- ✅ Com trackBy por ID — reaproveita -->
@for (pokemon of pokemons; track pokemon.id) {
  <app-pokemon-card [pokemon]="pokemon" />
}
```

> 💡 Na nova sintaxe `@for` (Angular 17+), o `track` é **obrigatório**. Sempre use uma chave única (geralmente `id`), não `$index`.

### 3. `async` pipe em vez de `.subscribe()`
Em vez de assinar manualmente, deixa o template assinar. **Sem leak, sem unsubscribe manual.**

```typescript
// ❌ Trabalhoso, vaza memória se esquecer do unsubscribe
ngOnInit() {
  this.pokeService.list().subscribe(list => this.pokemons = list);
}
```

```typescript
// ✅ Limpo, async pipe cuida de tudo
pokemons$ = this.pokeService.list();
```

```html
@if (pokemons$ | async; as pokemons) {
  @for (p of pokemons; track p.id) {
    <app-pokemon-card [pokemon]="p" />
  }
}
```

### 4. Lazy load (já vimos acima)
Toda rota não-inicial deveria ser lazy. Repete porque é a otimização mais alta de impacto.

---

## 📱 PWA (Progressive Web App) — opcional
PWA = seu app web ganha **ícone na home**, funciona **offline** (cache) e pode receber **push notifications**.

```bash
ng add @angular/pwa
```

Esse comando:
- Cria um `manifest.webmanifest` (ícones, nome, cor)
- Gera um **service worker** que cacheia assets e respostas HTTP
- Configura o `index.html`

Faz sentido pra Pokedex? **Sim** — uma vez carregada, funciona sem internet. Bom item pra portfólio.

---

## 🖥️ SSR (Server-Side Rendering) — opcional
**SPA padrão**: o navegador baixa um HTML vazio + JS gigante, e o JS monta a página.
**SSR**: o servidor renderiza o HTML pronto e manda. Página aparece **na hora**, depois o JS "hidrata" (vira interativa).

Por que importa:
- **SEO**: Google indexa muito melhor
- **First paint mais rápido** (importante em 4G/celular fraco)
- Custa um servidor Node rodando (não dá pra hospedar como estático)

```bash
ng add @angular/ssr
```

Pra Pokedex de estudo? Pula. Pra um e-commerce ou blog? Vale muito.

---

## 🚀 Deploy — onde publicar (de graça)

Como Angular gera **HTML + JS + CSS estáticos**, dá pra hospedar em qualquer **CDN estática gratuita**. Comparativo rápido:

| Plataforma          | Free tier               | CLI deploy             | Fácil de usar |
|---------------------|-------------------------|------------------------|---------------|
| **Vercel**          | Generoso                | `vercel`               | ⭐⭐⭐⭐⭐         |
| **Netlify**         | Generoso                | `netlify deploy`       | ⭐⭐⭐⭐⭐         |
| **Cloudflare Pages**| Generosíssimo           | `wrangler pages`       | ⭐⭐⭐⭐          |
| **GitHub Pages**    | Ilimitado (repos públicos) | `ng deploy`         | ⭐⭐⭐           |
| **Firebase Hosting**| 10 GB                   | `firebase deploy`      | ⭐⭐⭐           |

### `ng deploy` com GitHub Pages
```bash
ng add angular-cli-ghpages
ng deploy --base-href=/pokedex/
```

O `--base-href` é **importante**: GitHub Pages serve em `seu-usuario.github.io/pokedex/`, e o Angular precisa saber o subdiretório pra montar URLs certas.

### Configuração crítica: SPA fallback
Toda SPA precisa que **qualquer URL retorne `index.html`**. Por quê? Você acessa `/pokemon/25` direto pelo link — o servidor não conhece essa rota, ela só existe no Angular Router. Então o servidor precisa devolver o `index.html`, deixar o Angular ler a URL e renderizar a tela certa.

- **Vercel/Netlify/Cloudflare**: já fazem isso por padrão (ou com um arquivo `_redirects` / `vercel.json`).
- **GitHub Pages**: precisa de um truque (`404.html` igual ao `index.html`).
- **Firebase**: você configura no `firebase.json` com `"rewrites": [{ "source": "**", "destination": "/index.html" }]`.

Vamos ver tudo passo a passo no **desafio**.

---

## 🚦 Próximos passos
1. **Pratica/**: faça o build de produção da sua Pokedex, inspecione o `dist/`, rode o source-map-explorer.
2. **Desafio/**: publique sua Pokedex em **uma das três** opções (Vercel, Netlify ou GitHub Pages). Compartilhe a URL com alguém.
3. Adicione um pipeline básico de CI/CD com GitHub Actions — toda vez que você dá push, faz deploy.

## ✅ Auto-verificação
- [ ] Sei rodar `ng build` e identificar initial chunks vs lazy chunks
- [ ] Sei inspecionar o bundle com source-map-explorer
- [ ] Sei separar config dev/prod com environment files
- [ ] Aplico OnPush + trackBy + async pipe nos meus componentes
- [ ] Conheço pelo menos duas opções de deploy gratuito
- [ ] Sei o que é SPA fallback e por que ele é necessário

🎓 **Parabéns** — esse é o último módulo do curso. Sua Pokedex está no ar, indexada, otimizada, com pipeline de deploy. Você terminou o curso. 🎉
