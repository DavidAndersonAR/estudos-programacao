# Prática — Build de produção e auditoria de bundle

## 🎯 O que você vai fazer
1. Gerar o build de produção da sua Pokedex
2. Explorar o `dist/`
3. Inspecionar o bundle com **source-map-explorer**
4. Rodar um checklist de performance nos seus componentes

Sem código novo — só ferramentas em cima do que você já fez.

---

## 1. Build de produção

Dentro da pasta do seu projeto (`pokedex/`):
```bash
ng build
```

A partir do Angular 17, **production é o padrão** — sem precisar `--configuration production`.

### O que observar no output
Você vai ver algo como:
```
Initial chunk files | Names         |  Raw size | Estimated transfer size
main-XYZ.js         | main          | 245.30 kB |        78.12 kB
polyfills-XYZ.js    | polyfills     |  33.15 kB |        10.74 kB
styles-XYZ.css      | styles        |   6.41 kB |         1.85 kB

Lazy chunk files    | Names         |  Raw size | Estimated transfer size
chunk-ABC.js        | detail        |  12.50 kB |         4.20 kB
```

**Checklist de leitura**:
- [ ] Vejo `Initial chunk files` (o que carrega no primeiro paint)
- [ ] Vejo `Lazy chunk files` (rotas que carregam sob demanda) — **se você usou `loadComponent` nas rotas**
- [ ] O `main` está abaixo de **500 kB** raw? (Se não, hora de investigar)
- [ ] Os nomes têm **hash** (`main-XYZABC.js`) — isso é cache busting

---

## 2. Servir o build localmente (teste antes de subir)

```bash
npx http-server dist/pokedex/browser -p 8080
```

Abra `http://localhost:8080`. Esse é o app **exatamente como ficaria em produção** — sem hot reload, sem source maps inline, sem ferramenta de dev.

> 💡 Se a rota direta `localhost:8080/pokemon/25` quebrar com 404, é o **problema de SPA fallback**. No servidor real, isso será resolvido com config de rewrite (veremos no desafio).

---

## 3. Bundle analyzer — `source-map-explorer`

### Passo 1 — build com source maps
```bash
ng build --source-map
```

### Passo 2 — instale (uma vez na vida)
```bash
npm install -g source-map-explorer
```

### Passo 3 — analise
```bash
source-map-explorer dist/pokedex/browser/*.js
```

Abre um mapa interativo no navegador. **Cada bloquinho = uma dependência**. Quanto maior o bloco, mais peso ela tem no bundle.

### O que procurar
- [ ] Tem alguma lib **gigante e desconhecida**? (ex.: `moment.js`, `lodash` inteiro) → trocar por alternativa menor
- [ ] Tem código seu **muito maior que o esperado**? → talvez você esteja importando um service inteiro num componente lazy, perdendo o ganho de lazy loading
- [ ] Tem **duplicação**? (mesma dependência em dois chunks) → revisar imports

---

## 4. Environment file — checklist
Crie / revise:
```
src/environments/
├── environment.ts        ← dev
└── environment.prod.ts   ← produção
```

Use o `environment.example.ts` desta pasta como referência.

Confira no `angular.json`:
```json
"configurations": {
  "production": {
    "fileReplacements": [{
      "replace": "src/environments/environment.ts",
      "with": "src/environments/environment.prod.ts"
    }]
  }
}
```

Sem isso, o `environment.prod.ts` **nunca entra no build**.

---

## 5. Checklist de performance — passe nos seus componentes

### `ChangeDetectionStrategy.OnPush`
```typescript
@Component({
  ...,
  changeDetection: ChangeDetectionStrategy.OnPush
})
```
- [ ] Aplicado em **todos** os componentes "filhos" (cards, itens de lista, etc.)
- [ ] Componentes raiz / containers podem ficar com a default

### `trackBy` em `@for`
```html
@for (p of pokemons; track p.id) { ... }
```
- [ ] Toda lista usa `track` com uma chave **única e estável** (`id`, não `$index`)

### `async` pipe em vez de `.subscribe()`
```html
@if (pokemons$ | async; as pokemons) { ... }
```
- [ ] Componentes que consomem observable usam `async` no template
- [ ] Não tem `.subscribe()` solto sem `takeUntilDestroyed` ou unsubscribe

### Lazy routes
```typescript
{ path: 'pokemon/:id',
  loadComponent: () => import('./detail/detail.component').then(m => m.DetailComponent)
}
```
- [ ] Toda rota **não-inicial** carrega via `loadComponent` (ou `loadChildren`)

---

## 6. Resultado esperado
Ao fim desta prática você tem:
- Pasta `dist/pokedex/browser/` populada
- Print / lista dos chunks (initial + lazy)
- Mapa do source-map-explorer aberto, sabendo onde está o peso
- Checklist de performance todo verde

Próximo: **desafio** — colocar essa Pokedex no ar.
