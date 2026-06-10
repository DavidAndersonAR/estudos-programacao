# Módulo 11 — Collections

> Corresponde às aulas do Java10x (Nível Intermediário): *List - Um array com super poderes*, *Stack - O último a entrar é o primeiro a sair*, *Queue - Estrutura de dados*, *LinkedList x ArrayList*, *LinkedList - Explicação teórica*, *HashSet - Você vai usar 99% das vezes*, *LinkedHashSet x TreeSet*.

## 🎯 Objetivos
Ao fim deste módulo você vai conseguir:
- Entender a hierarquia `Collection` do Java (List, Set, Queue, Map)
- Escolher entre `ArrayList` e `LinkedList` com critério (e saber por quê)
- Usar `Stack` (LIFO) e `Queue` (FIFO) sem confundir os nomes dos métodos
- Eliminar duplicatas com `Set` e escolher a implementação certa (`HashSet`, `LinkedHashSet`, `TreeSet`)
- Associar chave→valor com `Map` (`HashMap`, `LinkedHashMap`, `TreeMap`)
- Iterar coleções de várias formas (for-each, `Iterator`, `entrySet`)
- Diferenciar coleções **mutáveis** de **imutáveis** (`List.of` vs `new ArrayList<>`)

> **Analogia Naruto pra fixar:** pensa em Konoha. Os ninjas são uma **List** (entram em ordem, podem se repetir nas missões). As aldeias são um **Set** (cada aldeia é única). A fila de missões no balcão da Tsunade é uma **Queue** (a primeira que chegou é a primeira atendida). A pilha de pergaminhos proibidos é uma **Stack** (o último de cima é o primeiro a ser pego). E o ficheiro do Iruka, que liga nome → ninja, é um **Map**.

---

## 🌳 1. A hierarquia (visão de mapa)

```
            Iterable
                │
            Collection
       ┌────────┼────────┐
      List     Set     Queue
       │        │         │
   ArrayList  HashSet   LinkedList
   LinkedList TreeSet   ArrayDeque
              LinkedHashSet  PriorityQueue

   Stack  (extends Vector — sequência ordenada, mas usada como LIFO)

     Map  (não herda de Collection!)
      │
   HashMap
   TreeMap
   LinkedHashMap
```

Pontos pra decorar:
- **`Map` NÃO é `Collection`.** Vive num galho separado porque guarda pares chave→valor, não elementos avulsos. Por isso usa `put()` e não `add()`.
- **`Queue` é uma interface** — você nunca instancia `Queue` direto. Usa `LinkedList`, `ArrayDeque` ou `PriorityQueue` por trás.
- **`Stack` existe** desde o Java 1.0 e funciona, mas em código moderno o pessoal prefere `ArrayDeque` no lugar (mais rápido). Vamos usar `Stack` aqui porque é o nome que cai na aula do Java10x e em entrevista.

---

## 📋 2. List — sequência ordenada, aceita duplicatas

Mantém **ordem de inserção**. Aceita itens repetidos. Acesso por índice.

```java
List<String> ninjas = new ArrayList<>();
ninjas.add("Naruto");
ninjas.add("Sasuke");
ninjas.add("Sakura");
ninjas.add("Naruto");                  // pode repetir
System.out.println(ninjas.get(0));     // Naruto
System.out.println(ninjas.size());     // 4
ninjas.remove("Sasuke");               // remove por valor
ninjas.remove(0);                      // remove por índice
boolean tem = ninjas.contains("Sakura"); // true
```

### 2.1 `ArrayList` vs `LinkedList` (a pergunta clássica de entrevista)

Esses dois implementam `List`, mas a estrutura interna é completamente diferente:

- **`ArrayList`** é um **array dinâmico**. Por baixo dos panos tem um array que cresce quando enche. Acesso por índice é instantâneo (calcula a posição direto). Inserir no meio é caro porque precisa deslocar todo mundo pra direita.
- **`LinkedList`** é uma **lista encadeada de nós**. Cada nó guarda o valor + uma referência pro próximo (e pro anterior, porque é duplamente encadeada). Acesso por índice é lento (tem que percorrer nó por nó). Mas inserir no começo, no fim ou no meio (se você já tem o nó) é instantâneo — só rearranja os ponteiros.

| Operação | ArrayList | LinkedList |
|---|---|---|
| Acesso por índice (`get(i)`) | 🚀 O(1) — instantâneo | 🐢 O(n) — percorre nó por nó |
| Inserção no fim (`add`) | 🚀 O(1) amortizado | 🚀 O(1) |
| Inserção no começo | 🐢 O(n) — desloca tudo | 🚀 O(1) |
| Inserção/remoção no meio | 🐢 O(n) — desloca elementos | 🚀 O(1) se já tem o nó |
| Uso de memória | Compacto (array interno) | Maior (cada nó guarda 2 ponteiros) |
| Cache de CPU | 🚀 Excelente (contíguo) | 🐢 Ruim (nós espalhados) |

**Regra prática (vale ouro):**
- Vai **ler muito por índice** ou iterar do começo ao fim? → `ArrayList` (99% dos casos).
- Vai **inserir/remover no começo** com frequência? → `LinkedList`.
- Na dúvida → `ArrayList`. É a escolha default da galera Java, e na prática o cache de CPU faz ele ganhar até em casos onde a teoria diria "LinkedList".

> **Naruto explica:** `ArrayList` é tipo a fila de ninjas no Exame Chunin — todos enfileirados num estádio. Achar o ninja da posição 47 é instantâneo (você olha a posição 47). Mas pra enfiar alguém entre o 10 e o 11, todo mundo da posição 11 pra frente tem que andar um lugar pra trás. Já a `LinkedList` é tipo uma corrente de transformação Kage Bunshin — cada clone segura o próximo. Pra meter um clone novo na corrente, você só ajusta as duas mãos vizinhas. Mas pra achar o clone número 47, você tem que perguntar de um em um.

### 2.2 LinkedList — explicação teórica (o que é um nó)

Cada elemento de uma `LinkedList` é embrulhado num **nó** (`Node`) que tem três coisas:

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│ Naruto   │      │ Sasuke   │      │ Sakura   │
│ prev: ── │ ───→ │ prev: ←─ │ ←──→ │ prev: ←─ │
│ next: ─→ │ ←──  │ next: ─→ │      │ next: → ⊥│
└──────────┘      └──────────┘      └──────────┘
```

A `LinkedList` em Java é **duplamente encadeada** — cada nó aponta pro próximo E pro anterior. Por isso ela implementa também a interface `Deque` (fila de duas pontas) — dá pra adicionar e remover de qualquer lado em O(1).

```java
LinkedList<String> time = new LinkedList<>();
time.add("Naruto");           // [Naruto]
time.addFirst("Kakashi");     // [Kakashi, Naruto] — adiciona no começo, O(1)
time.addLast("Sakura");       // [Kakashi, Naruto, Sakura] — adiciona no fim, O(1)
time.removeFirst();           // [Naruto, Sakura]
```

---

## 🔁 3. Iteração — for-each e Iterator

A forma mais usada é o **for-each**:

```java
List<String> ninjas = List.of("Naruto", "Sasuke", "Sakura");
for (String n : ninjas) {
    System.out.println(n);
}
```

Funciona em qualquer coisa que implemente `Iterable` — `List`, `Set`, `Queue`, e os `values()` / `keySet()` de um `Map`.

### 3.1 Iterator — pra quando precisa remover durante a iteração

Se você tentar remover de uma `List` enquanto faz `for-each`, vai estourar `ConcurrentModificationException`. A saída é usar `Iterator` explicitamente:

```java
List<String> ninjas = new ArrayList<>(List.of("Naruto", "Sasuke", "Itachi", "Sakura"));
Iterator<String> it = ninjas.iterator();
while (it.hasNext()) {
    String n = it.next();
    if (n.startsWith("I")) {     // remove os "I*" (Itachi)
        it.remove();             // ✅ remove com segurança
    }
}
System.out.println(ninjas);      // [Naruto, Sasuke, Sakura]
```

`Iterator` tem três métodos: `hasNext()`, `next()` e `remove()`. Só isso.

---

## 📚 4. Stack — LIFO (Last In, First Out)

**Pilha**. O último a entrar é o primeiro a sair. Pensa numa **pilha de pergaminhos** na mesa da Tsunade — você empilha em cima, e quando vai pegar, pega o de cima primeiro (o último que você colocou).

Os quatro métodos que importam:

| Método | O que faz |
|---|---|
| `push(x)` | Empilha `x` no topo |
| `pop()` | Remove e retorna o topo |
| `peek()` | Vê o topo SEM remover |
| `isEmpty()` | A pilha está vazia? |

```java
Stack<String> pergaminhos = new Stack<>();
pergaminhos.push("Rasengan");
pergaminhos.push("Chidori");
pergaminhos.push("Kamui");

System.out.println(pergaminhos.peek());  // Kamui (só espia)
System.out.println(pergaminhos.pop());   // Kamui (remove e retorna)
System.out.println(pergaminhos.pop());   // Chidori
System.out.println(pergaminhos.isEmpty()); // false (ainda tem Rasengan)
```

### Quando usar Stack na vida real
- **Desfazer (Ctrl+Z)** num editor — cada ação empilhada; o "desfazer" tira a do topo.
- **Histórico de navegação** do navegador — quando você dá "voltar", sai a última URL que entrou.
- **Pilha de chamadas de função** — toda linguagem usa stack pra controlar o que volta pra onde.
- **Parsing de expressões** — checar se `({[ ]})` está balanceado.

> ⚠️ Em código moderno muita gente prefere `Deque<String> pilha = new ArrayDeque<>()` no lugar de `Stack`, porque `Stack` herda de `Vector` (sincronizado, mais lento). Mas pra estudar e pra entrevista, `Stack` é o nome que aparece.

---

## 🚉 5. Queue — FIFO (First In, First Out)

**Fila**. O primeiro a entrar é o primeiro a sair. Pensa na **fila no balcão de missões** de Konoha — quem chegou primeiro é atendido primeiro.

Os métodos vêm em dois sabores: os que **estouram exceção** se a fila estiver cheia/vazia, e os que **retornam `null`/`false`**. Os do segundo grupo são os preferidos.

| O que quero | Versão que estoura | Versão segura |
|---|---|---|
| Adicionar no fim | `add(x)` | `offer(x)` (retorna `false` se cheia) |
| Remover do começo | `remove()` | `poll()` (retorna `null` se vazia) |
| Ver o começo SEM remover | `element()` | `peek()` (retorna `null` se vazia) |

### Implementações principais

| Implementação | Característica | Quando usar |
|---|---|---|
| `LinkedList` | Implementa `Queue` e `Deque` | Fila simples FIFO |
| `ArrayDeque` | Mais rápida que `LinkedList` na prática | Fila de duas pontas, melhor escolha geral |
| `PriorityQueue` | Ordena por prioridade (não é FIFO puro!) | Quando o "mais importante" sai primeiro |

```java
Queue<String> filaDeMissoes = new LinkedList<>();
filaDeMissoes.offer("Capturar Tora (gata da esposa do daimyo)");
filaDeMissoes.offer("Escoltar o Tazuna até o País das Ondas");
filaDeMissoes.offer("Recuperar o pergaminho roubado");

System.out.println(filaDeMissoes.peek());  // Capturar Tora (só espia)
System.out.println(filaDeMissoes.poll());  // Capturar Tora (remove e retorna)
System.out.println(filaDeMissoes.poll());  // Escoltar o Tazuna
System.out.println(filaDeMissoes.size());  // 1
```

### PriorityQueue — a fila que não respeita ordem de chegada

```java
PriorityQueue<Integer> ranks = new PriorityQueue<>();
ranks.offer(3);   // Rank C
ranks.offer(1);   // Rank S (mais urgente)
ranks.offer(2);   // Rank B

System.out.println(ranks.poll());  // 1 — saiu o mais prioritário, não o primeiro!
System.out.println(ranks.poll());  // 2
```

---

## 🎯 6. Set — sem duplicatas

Coleção sem repetição. Se tentar adicionar um item igual, ele é simplesmente ignorado (`add` retorna `false`).

| Implementação | Ordem | Estrutura interna | Complexidade | Quando usar |
|---|---|---|---|---|
| `HashSet` | Nenhuma (caótica) | Tabela hash | O(1) add/remove/contains | Default — quando só importa "tem ou não tem" |
| `LinkedHashSet` | Ordem de inserção | Hash + lista duplamente encadeada | O(1) | Quando quer manter a ordem que você adicionou |
| `TreeSet` | Ordem natural (alfa/num) | Árvore vermelha-preta balanceada | O(log n) | Quando precisa do conjunto ordenado |

### 6.1 HashSet — você vai usar 99% das vezes

Por trás dos panos, `HashSet` é um `HashMap` onde as chaves são os elementos e os valores são um marcador interno. A operação é O(1) em média porque o `hashCode()` do objeto leva direto pro bucket onde ele estaria.

```java
Set<String> aldeias = new HashSet<>();
aldeias.add("Konoha");
aldeias.add("Suna");
aldeias.add("Konoha");              // ignorado — já existe
aldeias.add("Kiri");
System.out.println(aldeias.size());  // 3
System.out.println(aldeias.contains("Konoha")); // true (instantâneo)
```

> ⚠️ **A ordem do `HashSet` é caótica e PODE mudar** entre execuções, versões do Java, etc. Nunca confie na ordem de iteração de um `HashSet`. Se a ordem importa, escolha `LinkedHashSet` ou `TreeSet`.

**Truque clássico**: pra remover duplicatas de uma lista, passe ela por um `HashSet`:
```java
List<String> comDup = List.of("Naruto", "Sasuke", "Naruto", "Sakura", "Sasuke");
Set<String> semDup = new HashSet<>(comDup); // {Naruto, Sasuke, Sakura} (ordem indefinida)
```

### 6.2 LinkedHashSet vs TreeSet

A diferença é só na ordem. Os métodos são os mesmos.

```java
// LinkedHashSet — preserva ordem de INSERÇÃO
Set<String> linked = new LinkedHashSet<>();
linked.add("Naruto");
linked.add("Sasuke");
linked.add("Sakura");
System.out.println(linked); // [Naruto, Sasuke, Sakura] — na ordem que entrou
```

Por dentro, o `LinkedHashSet` é um `HashSet` (pra ser rápido) + uma lista duplamente encadeada por baixo (pra lembrar a ordem). Custo: um pouquinho mais de memória.

```java
// TreeSet — ordena automaticamente (ordem natural)
Set<String> tree = new TreeSet<>();
tree.add("Sakura");
tree.add("Naruto");
tree.add("Sasuke");
System.out.println(tree); // [Naruto, Sakura, Sasuke] — ordem alfabética!
```

Por dentro, o `TreeSet` é uma **árvore vermelha-preta** (red-black tree) — uma árvore binária balanceada. Toda operação é O(log n), e a iteração sai sempre em ordem.

**Resumo rápido:**
- Não me importo com ordem, só quero rápido → `HashSet`
- Quero a ordem em que adicionei → `LinkedHashSet`
- Quero ordenado alfabeticamente/numericamente → `TreeSet`

---

## 🗺️ 7. Map — chave → valor

A coleção que mais aparece no dia a dia. Pense em dicionário, JSON, índice de livro, ou no **ficheiro do Iruka** ligando nome do ninja → ficha dele.

| Implementação | Ordem | Quando usar |
|---|---|---|
| `HashMap` | Nenhuma | Default — rápido, sem precisar de ordem |
| `LinkedHashMap` | Ordem de inserção | Quando quer iterar na ordem que adicionou |
| `TreeMap` | Ordem natural da chave | Quando precisa das chaves ordenadas |

```java
Map<String, Integer> nivelChakra = new HashMap<>();
nivelChakra.put("Naruto", 9000);
nivelChakra.put("Sasuke", 8500);
nivelChakra.put("Sakura", 5000);
nivelChakra.put("Naruto", 9500); // sobrescreve — chaves são únicas

System.out.println(nivelChakra.get("Naruto"));         // 9500
System.out.println(nivelChakra.containsKey("Sakura")); // true
System.out.println(nivelChakra.size());                // 3
```

### 7.1 Iterando um Map
Três formas, em ordem de utilidade:

```java
// 1. entrySet — chave E valor de uma vez (preferido)
for (Map.Entry<String, Integer> e : nivelChakra.entrySet()) {
    System.out.println(e.getKey() + " = " + e.getValue());
}

// 2. keySet — só as chaves
for (String nome : nivelChakra.keySet()) {
    System.out.println(nome);
}

// 3. values — só os valores
for (int chakra : nivelChakra.values()) {
    System.out.println(chakra);
}
```

### 7.2 `getOrDefault` e `merge` — os melhores amigos do Map

```java
// getOrDefault: pega o valor, OU usa um padrão se a chave não existe.
int chakra = nivelChakra.getOrDefault("Kakashi", 0); // 0, porque Kakashi não tá no mapa

// merge: padrão "soma incremental" — clássico pra contar coisas.
Map<String, Integer> missoesPorNinja = new HashMap<>();
missoesPorNinja.merge("Naruto", 1, Integer::sum);  // {Naruto=1}
missoesPorNinja.merge("Naruto", 1, Integer::sum);  // {Naruto=2}
missoesPorNinja.merge("Sasuke", 1, Integer::sum);  // {Naruto=2, Sasuke=1}
```

---

## 🔧 8. Operações comuns (cola de bolso)

| Quero... | List | Set | Stack | Queue | Map |
|---|---|---|---|---|---|
| Adicionar | `add(x)` | `add(x)` | `push(x)` | `offer(x)` | `put(k, v)` |
| Remover (consumir) | `remove(x)` ou `remove(i)` | `remove(x)` | `pop()` | `poll()` | `remove(k)` |
| Ver sem remover | `get(i)` | (não tem) | `peek()` | `peek()` | `get(k)` |
| Tem? | `contains(x)` | `contains(x)` | `contains(x)` | `contains(x)` | `containsKey(k)` |
| Tamanho | `size()` | `size()` | `size()` | `size()` | `size()` |
| Vazia? | `isEmpty()` | `isEmpty()` | `isEmpty()` | `isEmpty()` | `isEmpty()` |
| Limpar | `clear()` | `clear()` | `clear()` | `clear()` | `clear()` |

---

## 🔀 9. Ordenando coleções

```java
List<Integer> ranks = new ArrayList<>(List.of(3, 1, 4, 1, 5, 9, 2, 6));

Collections.sort(ranks);                    // ordem natural: [1, 1, 2, 3, 4, 5, 6, 9]
Collections.reverse(ranks);                 // inverte: [9, 6, 5, 4, 3, 2, 1, 1]
Collections.sort(ranks, Comparator.reverseOrder()); // decrescente direto
```

Por critério customizado:
```java
List<String> ninjas = new ArrayList<>(List.of("Naruto", "Iruka", "Kakashi", "Shikamaru"));
ninjas.sort(Comparator.comparingInt(String::length));  // por tamanho do nome
// [Iruka, Naruto, Kakashi, Shikamaru]
```

---

## 🔁 10. Array ↔ List

```java
// Array -> List
String[] arr = {"Naruto", "Sasuke", "Sakura"};
List<String> lista1 = Arrays.asList(arr);                  // tamanho fixo
List<String> lista2 = new ArrayList<>(Arrays.asList(arr)); // mutável de verdade

// Literal -> List imutável (Java 9+)
List<String> imut = List.of("Naruto", "Sasuke");           // NÃO dá pra modificar

// List -> Array
String[] back = lista2.toArray(new String[0]);
```

---

## ⚠️ 11. `List.of` (imutável) vs `new ArrayList<>` (mutável)

Essa é a pegadinha que pega muita gente:

```java
List<String> imut = List.of("Naruto", "Sasuke");
imut.add("Sakura");   // 💥 UnsupportedOperationException em runtime!

List<String> mut = new ArrayList<>(List.of("Naruto", "Sasuke"));
mut.add("Sakura");    // ✅ funciona
```

- **`List.of(...)`**: lista **imutável**. Boa pra constantes.
- **`new ArrayList<>(...)`**: lista **mutável**. É a que você quer pra trabalhar.

Mesma coisa pra `Set.of()` e `Map.of()` — todas imutáveis.

---

## 💡 12. Pegadinhas que valem ouro
- `Map` **não herda** de `Collection` — não tem `.add()`, é `.put()`.
- `List.of()` é **imutável** — explode no runtime se tentar modificar.
- `HashSet` e `HashMap` não garantem ordem nenhuma — confiar nisso é bug certo.
- `ArrayList.remove(int)` remove por **índice**; `ArrayList.remove(Object)` por **valor**. Em `List<Integer>`, `lista.remove(1)` remove o índice 1, **não** o número 1. Pra remover o valor: `lista.remove((Integer) 1)`.
- `Queue.poll()` retorna `null` se vazia — não esquece de checar.
- `Stack.pop()` em pilha vazia **estoura** `EmptyStackException`. Confira com `isEmpty()` antes.
- Modificar uma coleção durante `for-each` lança `ConcurrentModificationException`. Use `Iterator.remove()`.
- `PriorityQueue` **não** itera em ordem de prioridade — só garante que `poll()` retorna o menor.

---

## 🚦 Próximos passos
1. Abra **`pratica/Main.java`** — 10 exercícios resolvidos, tema Naruto.
2. Troque `ArrayList` por `LinkedList` em algum exercício e sinta a diferença.
3. Encare o **desafio**: Sistema de Missões em Konoha.
4. Próximo módulo: **Generics e Streams** — manipular coleções no estilo funcional.

## ✅ Auto-verificação
- [ ] Sei a diferença entre List, Set, Queue, Stack e Map (e quando usar cada)
- [ ] Sei quando preferir `ArrayList` em vez de `LinkedList` (e por quê)
- [ ] Sei os 4 métodos do `Stack`: `push`, `pop`, `peek`, `isEmpty`
- [ ] Sei a diferença entre `add/offer`, `remove/poll`, `element/peek` em `Queue`
- [ ] Sei distinguir `HashSet`, `LinkedHashSet` e `TreeSet`
- [ ] Consigo iterar um `Map` com `entrySet`
- [ ] Não caio mais na armadilha do `List.of` imutável

Próximo módulo: **Generics e Streams** — turbinando o que você acabou de aprender.
