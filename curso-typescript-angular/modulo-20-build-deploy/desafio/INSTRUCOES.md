# Desafio — Pokedex publicada

## 🎯 Enunciado
Sua Pokedex está pronta. Agora vamos **colocar ela no ar de graça**, num endereço que você pode mandar pra qualquer pessoa, e configurar um **pipeline de CI/CD** que faz redeploy automático toda vez que você dá `git push`.

O desafio tem 4 partes:

1. **Build de produção** (revisão rápida)
2. **Escolher uma das 3 opções de deploy** e publicar (Vercel, Netlify ou GitHub Pages)
3. **Configurar SPA fallback** (pra rotas diretas funcionarem)
4. **Pipeline com GitHub Actions** que builda + faz deploy a cada push em `main`

Ao fim você deve ter uma URL pública funcionando, e qualquer alteração no `main` deve reimplantar o app sozinho.

---

## 🛠️ Pré-requisitos
- Pokedex commitada num repositório do **GitHub** (público de preferência — facilita tudo)
- Node 20+ instalado
- Conta gratuita em **uma** dessas: Vercel, Netlify, GitHub (esse último você já tem)

---

# 📦 Parte 1 — Build de produção (revisão)

```bash
ng build
```

Conferir que `dist/pokedex/browser/` foi gerado. Se não foi, ajuste o nome do projeto (em `angular.json`, na chave `projects.<nome>`).

---

# 🚀 Parte 2 — Escolha sua opção de deploy

Faça **uma** das três abaixo. Se quiser fazer mais de uma, ótimo (cada plataforma vira uma URL — bom pra portfólio).

---

## Opção A — Vercel (a mais fácil)

### 1. Crie conta
Acesse [vercel.com](https://vercel.com) e faça login com a conta do GitHub.

### 2. Importe o repo
- Clique em **"Add New Project"**
- Escolha seu repositório `pokedex`
- A Vercel detecta Angular automaticamente. Confirme:
  - **Framework Preset**: Angular
  - **Build Command**: `ng build` (ou `npm run build`)
  - **Output Directory**: `dist/pokedex/browser`
- Clique em **Deploy**

Em ~1 minuto sua app está no ar em `https://pokedex-xxx.vercel.app`.

### 3. SPA fallback — já vem pronto
A Vercel detecta SPA e configura rewrite por padrão. Se quiser ser explícito, crie um `vercel.json` na raiz:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### 4. Auto-deploy
**Pronto, já tem.** Cada `git push origin main` dispara um novo deploy. Pull requests viram **previews** (URLs separadas pra testar antes de mergear). Bonito demais.

---

## Opção B — Netlify

### 1. Crie conta
[netlify.com](https://netlify.com) → login com GitHub.

### 2. Importe o repo
- **"Add new site" → "Import an existing project"**
- Escolha o GitHub e seu repositório
- Configurações de build:
  - **Build command**: `ng build`
  - **Publish directory**: `dist/pokedex/browser`
- **Deploy**

Em segundos: `https://nome-aleatorio.netlify.app`. Dá pra mudar o subdomínio nas configs do site.

### 3. SPA fallback — crie um `_redirects`
Na raiz do projeto, crie o arquivo `src/_redirects` (ou `public/_redirects`, dependendo da versão do CLI) com:

```
/*    /index.html   200
```

Depois adicione esse arquivo como asset no `angular.json`:
```json
"assets": [
  "src/favicon.ico",
  "src/assets",
  "src/_redirects"
]
```

Build de novo, redeploy automático.

### 4. Auto-deploy
**Já tem.** Cada push em `main` redeploya.

---

## Opção C — GitHub Pages

### 1. Instale o plugin
```bash
ng add angular-cli-ghpages
```

### 2. Faça o deploy
```bash
ng deploy --base-href=/pokedex/
```

**Atenção ao `--base-href`**: GitHub Pages vai servir em `https://seu-usuario.github.io/pokedex/`. Sem o `--base-href`, os links dos assets quebram (procuram em `/`).

O comando vai:
- Buildar com o base-href ajustado
- Criar/atualizar a branch `gh-pages` com o conteúdo de `dist/`
- Dar push pro GitHub

### 3. Ative o GitHub Pages
No repo, **Settings → Pages**:
- **Source**: Deploy from a branch
- **Branch**: `gh-pages`, pasta `/ (root)`
- Save

URL: `https://seu-usuario.github.io/pokedex/`

### 4. SPA fallback — o truque do `404.html`
GitHub Pages não tem config de rewrite. O truque:
- Quando o servidor não acha a rota, ele serve o arquivo `404.html`
- Se o `404.html` for **idêntico ao `index.html`**, o Angular boota normalmente

No `angular.json` do seu projeto:
```json
"build": {
  "options": {
    "outputPath": "dist/pokedex",
    "index": {
      "input": "src/index.html",
      "output": "index.html"
    }
  }
}
```

Adicione um script no `package.json` que copia o `index.html` pra `404.html` depois do build:
```json
"scripts": {
  "build": "ng build && cp dist/pokedex/browser/index.html dist/pokedex/browser/404.html"
}
```

(No Windows use `copy` em vez de `cp`, ou instale `shx`: `npm i -D shx` e use `shx cp ...` — funciona cross-platform.)

---

# 🔁 Parte 3 — SPA fallback (resumo das 3 opções)

| Plataforma   | Como faz                                                 |
|--------------|----------------------------------------------------------|
| Vercel       | Automático (ou `vercel.json` explícito)                  |
| Netlify      | Arquivo `_redirects` com `/*  /index.html  200`          |
| GitHub Pages | Copia `index.html` → `404.html`                          |
| Firebase     | `firebase.json` com `rewrites` apontando pra `/index.html` |
| Cloudflare   | `_redirects` (igual Netlify) ou Page Rule                |

**Por que isso é necessário?** Você abre direto `https://app.com/pokemon/25`. O servidor não conhece essa rota (ela existe só dentro do Angular Router). Sem fallback, devolve **404**. Com fallback, devolve o `index.html`, o Angular boota, lê a URL e renderiza a tela certa.

---

# 🤖 Parte 4 — CI/CD com GitHub Actions

Vamos automatizar o deploy: **toda vez que você dá push em `main`, o GitHub builda seu app e publica**.

### Estrutura
Na raiz do seu repo, crie:
```
.github/
└── workflows/
    └── deploy.yml
```

> 💡 Tem um exemplo completo deste arquivo em `desafio/.github/workflows/deploy.yml` — copie ele pra raiz do seu repo (não pra dentro do `desafio/`).

### O que o workflow faz
1. Dispara em todo push em `main`
2. Sobe um Ubuntu, instala Node 20
3. `npm ci` (install determinístico)
4. `ng build`
5. Faz deploy pro GitHub Pages (ou pra Vercel/Netlify via CLI, se preferir)

### Pra Vercel/Netlify — alternativa mais simples
Se você escolheu Vercel ou Netlify na **Parte 2**, a integração nativa **já cuida do CI/CD**. Você não precisa do GitHub Actions. Cada push já redeploya.

O GitHub Actions vale a pena se:
- Você escolheu **GitHub Pages**
- Você quer rodar **testes/lint** antes de deployar
- Você quer **mais controle** do pipeline

### Variáveis sensíveis
Tokens, chaves de API, segredos: **nunca commite**. Vão em **Settings → Secrets and variables → Actions** do repo, e o workflow acessa com `${{ secrets.NOME }}`.

---

# ✅ Critérios de conclusão
- [ ] App publicada em URL pública
- [ ] Acessar URL direta `/pokemon/25` funciona (SPA fallback OK)
- [ ] Push em `main` dispara novo deploy automaticamente
- [ ] Você compartilhou a URL com alguém e pediu feedback 😄

---

# 🧠 Solução comentada — o que esperar dando certo

## Sinais de sucesso
- **Vercel/Netlify**: dashboard mostra build verde, log termina com "Deploy ready". URL final responde 200.
- **GitHub Pages**: aba **Actions** verde, aba **Settings → Pages** mostra "Your site is live at https://...".
- DevTools → Network: o `main-XXX.js` é baixado com `Content-Encoding: gzip` ou `br` (brotli). Significa que o CDN comprimiu — bom sinal.

## Bugs comuns e como resolver

### "Tela branca, console mostra 404 em main.js"
**Causa**: `--base-href` errado. Você publicou em subdiretório (`/pokedex/`) sem ajustar.
**Fix**: rebuild com `ng build --base-href=/pokedex/` (ajuste o nome).

### "Home funciona, mas /pokemon/25 dá 404"
**Causa**: faltou o SPA fallback.
**Fix**: ver tabela na **Parte 3**.

### "Imagem / asset não aparece"
**Causa**: caminho absoluto começando com `/` num app servido em subdiretório.
**Fix**: use caminhos relativos (`assets/img.png`, sem barra inicial) ou ajuste o `--base-href`.

### "GitHub Actions falhou em `npm ci`"
**Causa**: `package-lock.json` desatualizado ou ausente.
**Fix**: rode `npm install` localmente, commite o `package-lock.json` atualizado.

### "Bundle gigante (acima de 1 MB)"
**Causa**: importou alguma lib enorme (`moment`, `lodash` inteiro, ícones todos).
**Fix**: rode o `source-map-explorer` (visto na **prática**), identifique o culpado, troque por alternativa menor (`date-fns` em vez de `moment`; `lodash-es/debounce` em vez de `lodash` todo).

---

🎓 **Parabéns!** Sua Pokedex está no ar, com pipeline automatizado, otimizada e auditada. Você acabou o curso. Esse projeto vale ouro no portfólio — link no GitHub, link na URL pública, README contando o que você aprendeu. Boa jornada! 🚀
