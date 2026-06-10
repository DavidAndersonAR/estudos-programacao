# Módulo 13 — Forms

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Diferenciar **Template-driven Forms** de **Reactive Forms** e saber quando usar cada um
- Montar um form reactive com `FormGroup`, `FormControl` e `FormBuilder`
- Aplicar **validators built-in** (required, minLength, email, pattern) e escrever um validator customizado
- Exibir mensagens de erro no template usando o estado do controle (`touched`, `dirty`, `invalid`)
- Tratar o `submit` de forma segura
- Saber o que é um `FormArray` (e quando vai precisar dele)

## 🧐 Por que forms merecem um módulo inteiro?
Form é onde o usuário **fala com o app**: busca, login, cadastro, filtro, checkout. Se o form for chato, lento ou cheio de bugs, o app inteiro parece ruim. Angular leva forms a sério a ponto de oferecer **duas abordagens completas** — você precisa saber as duas pra não escolher errado.

## ⚖️ Template-driven vs Reactive

### Template-driven (FormsModule)
- Lógica **no HTML**, com `[(ngModel)]` (two-way binding)
- Angular cria os controles automaticamente baseado nas diretivas do template
- Bom pra forms **simples**: um campo de busca, um login com 2 campos
- Validação por **atributos HTML** (`required`, `minlength`, `pattern`)
- Difícil testar (precisa do DOM)

```html
<input [(ngModel)]="termo" name="termo" required minlength="2">
```

### Reactive (ReactiveFormsModule)
- Lógica **no TypeScript**, controles instanciados com código
- Você controla tudo: criação, valor, validação, eventos
- Bom pra forms **reais**: cadastro, filtro avançado, wizard, qualquer coisa com lógica dinâmica
- Validação programática, valida sem precisar do template
- Testável sem DOM, fácil de manipular em runtime

```typescript
this.form = new FormGroup({
  termo: new FormControl('', [Validators.required, Validators.minLength(2)])
});
```

### 🏆 Recomendação
**Use Reactive Forms.** Template-driven é tentador pela simplicidade inicial, mas qualquer form que cresça vira espaguete. Reactive escala, testa melhor e é o padrão da comunidade pra Angular profissional. Template-driven só pra protótipo descartável ou form de 1 campo.

## 🧱 Anatomia de um Reactive Form

### Os 3 blocos
- **`FormControl`** — um campo individual (input, select, checkbox). Tem valor, estado e validadores.
- **`FormGroup`** — um conjunto de controles agrupados (ex: um form inteiro, ou uma seção como "endereço").
- **`FormArray`** — uma **lista dinâmica** de controles (ex: adicionar N telefones, N tags, N itens de um pedido).

### `FormBuilder` — açúcar pra não digitar tanto

```typescript
// Sem FormBuilder
this.form = new FormGroup({
  nome: new FormControl('', [Validators.required]),
  email: new FormControl('', [Validators.required, Validators.email])
});

// Com FormBuilder (preferido)
constructor(private fb: FormBuilder) {}

this.form = this.fb.group({
  nome: ['', [Validators.required]],
  email: ['', [Validators.required, Validators.email]]
});
```

Menos verboso, mesma coisa.

## 🛡️ Validators

### Built-in
Angular já vem com vários prontos em `Validators`:
- `Validators.required` — campo obrigatório
- `Validators.minLength(n)` / `maxLength(n)` — tamanho mínimo/máximo
- `Validators.min(n)` / `max(n)` — valor numérico mínimo/máximo
- `Validators.email` — formato de email
- `Validators.pattern(regex)` — bate com regex
- `Validators.requiredTrue` — útil pra checkbox "aceito os termos"

### Combinando
Passe um **array** de validators:
```typescript
nome: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(50)]]
```

### Validator customizado
Um validator é só uma função: recebe o controle, retorna `null` se válido ou um objeto de erro se inválido.

```typescript
function semEspacos(control: AbstractControl): ValidationErrors | null {
  const valor = control.value as string;
  if (valor && valor.includes(' ')) {
    return { semEspacos: true }; // erro
  }
  return null; // ok
}

// Uso:
username: ['', [Validators.required, semEspacos]]
```

No template você acessa via `form.get('username')?.errors?.['semEspacos']`.

## 🎨 Exibindo erros no template

Cada controle tem **estado**:
- `touched` — usuário já interagiu (perdeu foco)
- `dirty` — valor foi alterado
- `pristine` — nunca foi alterado
- `valid` / `invalid` — passa nos validators
- `errors` — objeto com os erros ativos (ou `null`)

Regra de ouro: **só mostrar erro depois que o usuário interagiu**. Senão o form abre vermelho e fica feio.

```html
<input formControlName="email">

@if (form.get('email')?.invalid && form.get('email')?.touched) {
  <div class="erro">
    @if (form.get('email')?.errors?.['required']) {
      <span>Email é obrigatório</span>
    }
    @if (form.get('email')?.errors?.['email']) {
      <span>Email em formato inválido</span>
    }
  </div>
}
```

## 📨 Tratando o submit

```html
<form [formGroup]="form" (ngSubmit)="onSubmit()">
  <!-- campos -->
  <button type="submit" [disabled]="form.invalid">Enviar</button>
</form>
```

```typescript
onSubmit() {
  if (this.form.invalid) {
    this.form.markAllAsTouched(); // força mostrar erros
    return;
  }
  const dados = this.form.value;
  console.log('enviando:', dados);
}
```

Dois cuidados:
1. **Desabilite o botão** se o form for inválido — feedback visual imediato.
2. **`markAllAsTouched()`** no submit garante que erros apareçam mesmo em campos que o usuário nem tocou.

## 🔁 FormArray — listas dinâmicas

Quando o número de campos **não é fixo** (usuário pode adicionar/remover), use `FormArray`.

```typescript
this.form = this.fb.group({
  nome: [''],
  telefones: this.fb.array([
    this.fb.control('') // começa com 1
  ])
});

get telefones(): FormArray {
  return this.form.get('telefones') as FormArray;
}

adicionarTelefone() {
  this.telefones.push(this.fb.control('', Validators.required));
}

removerTelefone(i: number) {
  this.telefones.removeAt(i);
}
```

No template, você itera com `@for` e usa `[formControlName]="i"` dentro de uma div com `formArrayName="telefones"`.

Não vamos praticar `FormArray` neste módulo — fica de menção pra você saber que existe quando precisar.

## 🚦 Próximos passos
1. Abra `pratica/` — compare o form template-driven (1 campo) com o reactive (3 campos + validação).
2. Encare o **desafio**: form de filtros do Pokedex com `@Output` emitindo a cada mudança válida.

## ✅ Auto-verificação
- [ ] Sei explicar quando usar Template-driven e quando usar Reactive
- [ ] Sei montar um `FormGroup` com `FormBuilder` e aplicar validators
- [ ] Sei escrever um validator customizado
- [ ] Sei exibir erros condicionalmente baseado em `touched`/`invalid`
- [ ] Sei o que é `FormArray` e quando usar

Próximo módulo: **HTTP & Observables** — falando com a API.
