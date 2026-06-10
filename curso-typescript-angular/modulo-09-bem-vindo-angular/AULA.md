# Módulo 09 — Bem-vindo ao Angular

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Explicar em uma frase o que é Angular e por que escolhê-lo
- Instalar o Angular CLI e criar um projeto novo do zero
- Reconhecer a estrutura de pastas de um app Angular moderno
- Rodar o app com `ng serve` e ver o hot reload em ação
- Entender a anatomia de um componente standalone
- Diferenciar a abordagem antiga (NgModule) da nova (Standalone)

## 🧐 O que é Angular?
Angular é um **framework front-end opinionado, completo e mantido pela Google**. Diferente de bibliotecas como React, ele já vem com **tudo embutido**: roteamento, formulários, HTTP, injeção de dependência, testes, CLI. Você não precisa escolher 15 pacotes pra montar uma stack — o time da Google já escolheu por você.

Por que isso importa?
- **Padrão único**: todo app Angular se parece. Você troca de projeto e se acha rápido.
- **Escala bem**: foi pensado pra apps grandes, com muitos times trabalhando juntos.
- **TypeScript 100%**: tipagem forte do início ao fim — por isso passamos 8 módulos em TS antes.
- **Atualização constante**: nova major version a cada 6 meses, mas com migração assistida pelo CLI.

Quem usa: Google (Gmail, YouTube TV, Google Cloud Console), Microsoft (Office Web), Forbes, Deutsche Bank, e a maior parte do mercado **enterprise**.

## 🆚 Angular vs React vs Vue (resumo honesto)
- **React**: biblioteca, você monta sua stack. Mais flexível, mais decisões.
- **Vue**: meio-termo, curva suave, comunidade grande.
- **Angular**: framework completo, mais opinião, mais cerimônia. Vence em **apps corporativos grandes** e **times grandes**.

Não existe "melhor" — existe **encaixe**. Pra esse curso, Angular.

## ⚙️ Angular CLI — a ferramenta que faz tudo
O **Angular CLI** é o canivete suíço do Angular. Cria projetos, gera componentes, roda o servidor de dev, builda pra produção, faz update entre versões.

### Instalação (global, uma vez na vida)
```bash
npm install -g @angular/cli
```

Confere a versão:
```bash
ng version
```

## 🚀 Criando seu primeiro projeto

```bash
ng new pokedex --standalone --routing --style=css
```

O que cada flag faz:
- `pokedex` → nome da pasta e do projeto
- `--standalone` → usa a arquitetura nova (sem NgModule). **Padrão a partir do Angular 17.**
- `--routing` → já cria o arquivo de rotas e configura o roteador
- `--style=css` → CSS puro (alternativas: scss, sass, less)

O CLI vai perguntar sobre SSR — pra esse curso responda **No** (mais simples no início).

## 📁 Estrutura de pastas (o que importa)

```
pokedex/
├── src/
│   ├── app/
│   │   ├── app.component.ts       ← componente raiz (lógica)
│   │   ├── app.component.html     ← template (HTML)
│   │   ├── app.component.css      ← estilos do componente
│   │   ├── app.component.spec.ts  ← testes
│   │   ├── app.config.ts          ← config global (providers)
│   │   └── app.routes.ts          ← definição de rotas
│   ├── main.ts                    ← ponto de entrada — sobe o app
│   ├── index.html                 ← HTML único da SPA
│   └── styles.css                 ← estilos globais
├── angular.json                   ← config do CLI
├── package.json
└── tsconfig.json
```

**Conceito-chave**: Angular é uma **SPA** (Single Page Application). Existe **um único `index.html`**. Tudo o que você vê na tela é injetado dinamicamente dentro de `<app-root></app-root>`.

## ▶️ Rodando o app
Dentro da pasta do projeto:
```bash
cd pokedex
ng serve
```

Abre no navegador: **http://localhost:4200**

### Hot reload
Salvou um arquivo? O navegador recarrega sozinho, em **milissegundos**. Sem F5, sem nada. Mudança visual instantânea.

## 🧱 Anatomia de um componente standalone

```typescript
// app.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',           // como o componente é chamado no HTML
  standalone: true,               // não precisa de NgModule
  imports: [],                    // outros componentes/diretivas que esse usa
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'pokedex';
}
```

Três peças:
1. **Decorator `@Component`** — metadados que dizem ao Angular "isso é um componente".
2. **Classe** — a lógica (propriedades, métodos).
3. **Template + Estilos** — HTML e CSS associados (arquivos separados ou inline).

E o template usa **interpolação** com `{{ }}` pra mostrar valores da classe:
```html
<h1>{{ title }}</h1>  <!-- vira: <h1>pokedex</h1> -->
```

## 🆕 Standalone vs NgModule — qual a diferença?

### Antes (NgModule — legacy, ainda funciona)
Cada componente precisava ser **declarado** num módulo (`@NgModule`). Mais arquivos, mais boilerplate, mais conceitos.

```typescript
@NgModule({
  declarations: [AppComponent, OutroComponent],
  imports: [BrowserModule, FormsModule],
  bootstrap: [AppComponent]
})
export class AppModule {}
```

### Agora (Standalone — desde Angular 14, padrão desde 17)
Cada componente é **autossuficiente**. Importa só o que precisa. Sem módulo intermediário.

```typescript
@Component({
  selector: 'app-pokemon',
  standalone: true,
  imports: [CommonModule, FormsModule],  // imports direto aqui
  templateUrl: './pokemon.component.html'
})
export class PokemonComponent {}
```

**Por que mudaram?**
- Menos arquivo, menos confusão
- Mais explícito: cada componente diz exatamente o que usa
- Tree-shaking melhor (bundle menor)
- Curva de aprendizado mais suave pra quem vem de React/Vue

Neste curso vamos **sempre usar standalone**. Se você ver tutoriais antigos com NgModule, agora sabe o porquê.

## 🛠️ Comandos do CLI que você vai usar todo dia
```bash
ng serve                              # roda em dev (porta 4200)
ng build                              # build de produção (gera /dist)
ng generate component nome-componente # gera componente novo
ng generate service nome-servico      # gera service
ng test                               # roda testes unitários
```

Atalho: `ng g c nome` é o mesmo que `ng generate component nome`.

## 🎬 O projeto-fio: Pokedex
A partir deste módulo, vamos construir **um único app do começo ao fim**: uma **Pokedex** que lista, busca e mostra detalhes dos 150 pokémons originais.

Cada módulo daqui pra frente adiciona uma camada nova:
- **Mód 09** (agora): tela inicial estática
- **Mód 10**: componente de card de pokémon
- **Mód 11**: service que retorna a lista
- **Mód 12**: rotas pra tela de detalhe
- ... até deploy no Mód 20.

Ao final, você tem uma app real no portfólio.

## 🚦 Próximos passos
1. **Instale o CLI**: `npm install -g @angular/cli`
2. **Crie o projeto**: `ng new pokedex --standalone --routing --style=css`
3. **Rode**: `cd pokedex && ng serve`
4. **Abra a `pratica/`** deste módulo: copie `app.component.ts` e `app.component.html` por cima dos arquivos gerados em `src/app/`. Salve, veja o "Olá Angular" aparecer.
5. **Encare o desafio**: copie os arquivos de `desafio/` e veja a tela inicial do Pokedex tomando forma.

> ⚠️ **Por que pasta `pratica/` e `desafio/` em vez de projeto pronto?**
> Angular precisa de um projeto criado pelo CLI (gera centenas de arquivos de config). Os arquivos aqui são **exemplos prontos pra copiar** dentro do seu projeto recém-criado, na pasta `src/app/`.

## ✅ Auto-verificação
- [ ] Sei explicar o que é Angular e quem mantém
- [ ] Instalei o `@angular/cli` e rodei `ng new`
- [ ] Reconheço os arquivos principais em `src/app/`
- [ ] Rodei `ng serve` e vi a página em `localhost:4200`
- [ ] Entendo o que é um componente standalone
- [ ] Sei a diferença entre standalone e NgModule

Próximo módulo: **Componentes e Templates** — interpolação, binding, diretivas estruturais (`*ngFor`, `*ngIf`) e o primeiro card de pokémon.
