# Desafio — API de Tarefas com 3 Roles

Você vai construir uma API de **tarefas** com controle de acesso por papel. Sem banco: pode usar `List` em memória.

## Roles

| Role | O que pode |
|---|---|
| `user` | Ver suas próprias tarefas, criar, marcar como concluída |
| `admin` | Tudo do user **+** ver tarefas de todos, deletar qualquer uma |
| `auditor` | **Só leitura** de todas as tarefas + endpoint de log |

## Endpoints obrigatórios

| Método | Path | Roles | O que faz |
|---|---|---|---|
| POST | `/login` | público | Recebe `{usuario, senha}`, devolve JWT |
| GET | `/tarefas/minhas` | `user`, `admin` | Tarefas do usuário do token |
| POST | `/tarefas` | `user`, `admin` | Cria tarefa (dono = `upn` do token) |
| PATCH | `/tarefas/{id}/concluir` | `user`, `admin` | Só o dono OU admin pode concluir |
| GET | `/tarefas` | `admin`, `auditor` | Lista TODAS as tarefas |
| DELETE | `/tarefas/{id}` | `admin` | Apaga qualquer tarefa |
| GET | `/auditoria/log` | `auditor` | Lista de ações registradas |

## Usuários fixos (login hardcoded só pra demo)

| Usuário | Senha | Groups |
|---|---|---|
| `alice` | `123` | `user` |
| `bob` | `123` | `user`, `admin` |
| `carol` | `123` | `auditor` |

## Regras de negócio

1. Tarefa = `{id, titulo, dono, concluida}`
2. `dono` vem do `upn` do JWT, nunca do body
3. Em `/tarefas/{id}/concluir`: se o user NÃO é admin e NÃO é dono → `403`
4. Cada criação/conclusão/exclusão adiciona uma entrada no log de auditoria com `{timestamp, usuario, acao, tarefaId}`
5. Token expira em **30 minutos**

## Critérios de aceitação

- [ ] `alice` consegue criar uma tarefa e vê só a dela em `/tarefas/minhas`
- [ ] `alice` tenta concluir tarefa de `bob` → `403`
- [ ] `bob` (admin) consegue concluir tarefa de `alice`
- [ ] `bob` consegue deletar
- [ ] `carol` consegue listar tudo mas NÃO consegue criar/deletar (`403`)
- [ ] `carol` vê o log de auditoria
- [ ] Sem token → `401` em qualquer endpoint protegido

## Dicas

- Pra checar "é dono ou admin" dentro do método: injete `JsonWebToken` e cheque `jwt.getGroups().contains("admin")`
- `@RolesAllowed({"admin", "auditor"})` aceita múltiplas roles
- O log de auditoria pode ser um `@ApplicationScoped` service com `List<LogEntry>`
- Use `Duration.ofMinutes(30)` no `.expiresIn()`

## Quando travar

Os arquivos `*.solucao` neste diretório têm uma implementação de referência. Tente fechar tudo antes de espiar.
