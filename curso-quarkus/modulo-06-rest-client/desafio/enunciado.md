# Desafio — Posts de um usuário (JSONPlaceholder)

## 🎯 Missão

Criar um endpoint `GET /usuarios/{id}/posts` que devolva os posts de um usuário consumindo a API pública [JSONPlaceholder](https://jsonplaceholder.typicode.com/).

## 📡 API externa

Base URL: `https://jsonplaceholder.typicode.com`

Endpoints úteis:
- `GET /users/{id}` → dados do usuário
- `GET /posts?userId={id}` → posts daquele usuário

Exemplo de resposta de `/posts?userId=1`:
```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident...",
    "body": "quia et suscipit\nsuscipit recusandae..."
  }
]
```

## ✅ Requisitos

1. **Extensão**: `quarkus-rest-client-jackson` instalada.
2. **Uma única interface** `JsonPlaceholderClient` com **dois métodos** (`buscarUsuario`, `listarPosts`).
3. Use `configKey = "jsonplaceholder"` e configure URL base + timeouts em `application.properties`.
4. Crie `Post` e `Usuario` como `record`.
5. Crie `PostService` que injeta o client com `@RestClient` e expõe:
   ```java
   PostsDoUsuario buscar(long userId)
   ```
   Onde `PostsDoUsuario` é um record que junta `Usuario nome` (só o nome) + `List<Post> posts`.
6. Endpoint `GET /usuarios/{id}/posts` devolve `PostsDoUsuario` em JSON.
7. Se o usuário não existir (404 do JSONPlaceholder), seu endpoint responde **404** com `{"erro":"Usuário não encontrado"}`.
8. Use `@QueryParam` no método `listarPosts` (não concatene query string na mão).

## 🧪 Como testar

```bash
curl -s http://localhost:8080/usuarios/1/posts | jq '.nome, (.posts | length)'
# "Leanne Graham"
# 10

curl -i http://localhost:8080/usuarios/999/posts
# HTTP/1.1 404 Not Found
```

## 💡 Dicas

- O método de listar posts retorna `List<Post>` direto — o Jackson lida com a deserialização do array.
- Pra tratar o 404 do JSONPlaceholder limpo, capture `WebApplicationException` (ou `ClientWebApplicationException`) no service e cheque `e.getResponse().getStatus()`.
- Quer ousar mais? Devolva `Uni<PostsDoUsuario>` e use `Uni.combine().all().unis(...)` pra fazer as duas chamadas em **paralelo**. (Vamos cobrir Mutiny no Módulo 10 — sem stress se preferir sync agora.)

## 🚦 Critérios de aceite

- [ ] `GET /usuarios/1/posts` devolve nome do usuário + lista de posts
- [ ] `GET /usuarios/999/posts` devolve 404 com JSON de erro
- [ ] Nenhum `HttpClient` ou `URL` na mão — só interface declarativa
- [ ] URL base só aparece no `application.properties`, nunca no código Java

Solução completa nos arquivos `.solucao` desta pasta.
