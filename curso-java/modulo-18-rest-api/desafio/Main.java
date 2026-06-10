// 🎯 DESAFIO DO MÓDULO 18 — CRUD de Tarefas em Memória
//
// Objetivo:
// Construir uma API REST COMPLETA pra gerenciar tarefas, sem banco de dados —
// guardando tudo num Map em memória (o "banco" some quando reinicia o app).
//
// Endpoints obrigatórios:
//
//   GET    /api/tarefas         → lista todas
//   GET    /api/tarefas/{id}    → busca uma (404 se não existe)
//   POST   /api/tarefas         → cria nova (201 Created)
//   PUT    /api/tarefas/{id}    → atualiza inteira (404 se não existe)
//   DELETE /api/tarefas/{id}    → remove (204 No Content; 404 se não existe)
//
// Modelo:
//   record Tarefa(Long id, String titulo, boolean feita)
//
// Requisitos:
// 1. Use um Map<Long, Tarefa> como "banco" (ConcurrentHashMap é o ideal).
// 2. Use AtomicLong pra gerar IDs únicos.
// 3. O cliente NÃO envia o id no POST — você gera. Devolva 201 + recurso criado.
// 4. PUT recebe os dados e SUBSTITUI a tarefa inteira (mantendo o id da URL).
// 5. DELETE devolve 204 sem body se ok, 404 se id não existe.
// 6. Use DTOs separados pra entrada e saída (boa prática).
//
// =====================================================================
// COMO MONTAR O PROJETO SPRING
// =====================================================================
//
//   1. https://start.spring.io → Maven, Java 21, Spring Boot 3.x
//   2. Dependência: "Spring Web"
//   3. Cole as classes da SOLUÇÃO num pacote tipo com.exemplo.tarefas
//   4. Rode a @SpringBootApplication — sobe em http://localhost:8080
//
// =====================================================================
// TESTES COM curl (depois de subir)
// =====================================================================
//
// # listar (vazio no começo)
// curl http://localhost:8080/api/tarefas
//
// # criar
// curl -X POST http://localhost:8080/api/tarefas \
//      -H "Content-Type: application/json" \
//      -d "{\"titulo\":\"estudar Spring\"}"
//
// # criar outra
// curl -X POST http://localhost:8080/api/tarefas \
//      -H "Content-Type: application/json" \
//      -d "{\"titulo\":\"fazer café\"}"
//
// # listar (agora com 2)
// curl http://localhost:8080/api/tarefas
//
// # buscar por id
// curl http://localhost:8080/api/tarefas/1
//
// # buscar id inexistente (404)
// curl -i http://localhost:8080/api/tarefas/999
//
// # atualizar (marcar como feita)
// curl -X PUT http://localhost:8080/api/tarefas/1 \
//      -H "Content-Type: application/json" \
//      -d "{\"titulo\":\"estudar Spring\",\"feita\":true}"
//
// # remover
// curl -i -X DELETE http://localhost:8080/api/tarefas/1
//
// # tentar remover de novo (404)
// curl -i -X DELETE http://localhost:8080/api/tarefas/1
//
// =====================================================================
// 💡 DICAS
// =====================================================================
// - `ResponseEntity.notFound().build()` → 404 vazio
// - `ResponseEntity.noContent().build()` → 204 vazio
// - `ResponseEntity.status(HttpStatus.CREATED).body(x)` → 201 + body
// - `Optional.ofNullable(map.get(id))` ajuda a tratar id inexistente elegantemente
// - DTO de criação só com `titulo` — id é gerado pelo servidor, `feita` começa false
//
// =====================================================================
// 🧱 ESQUELETO PRA VOCÊ COMPLETAR (cole num projeto Spring)
// =====================================================================
/*
package com.exemplo.tarefas;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

public record Tarefa(Long id, String titulo, boolean feita) {}
public record CriarTarefaDTO(String titulo) {}
public record AtualizarTarefaDTO(String titulo, boolean feita) {}

@RestController
@RequestMapping("/api/tarefas")
public class TarefaController {

    private final Map<Long, Tarefa> banco = new ConcurrentHashMap<>();
    private final AtomicLong proximoId = new AtomicLong(1);

    // TODO: GET listar todas
    // TODO: GET por id (404 se não existe)
    // TODO: POST criar (201 Created)
    // TODO: PUT atualizar (404 se não existe)
    // TODO: DELETE remover (204 ok, 404 se não existe)
}
*/

// =====================================================================
// ✅ SOLUÇÃO DE REFERÊNCIA (descomente num projeto Spring pra rodar)
// =====================================================================
/*
package com.exemplo.tarefas;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

// ===== Model interno =====
record Tarefa(Long id, String titulo, boolean feita) {}

// ===== DTOs =====
// Entrada de criação: cliente só manda o título.
record CriarTarefaDTO(String titulo) {}

// Entrada de atualização: cliente manda título e estado.
record AtualizarTarefaDTO(String titulo, boolean feita) {}

// (Aqui o DTO de saída é o próprio record Tarefa — em um app real,
// teria um TarefaResponseDTO separado.)

@RestController
@RequestMapping("/api/tarefas")
public class TarefaController {

    // "Banco" em memória — thread-safe.
    private final Map<Long, Tarefa> banco = new ConcurrentHashMap<>();
    private final AtomicLong proximoId = new AtomicLong(1);

    // ---------- LISTAR ----------
    // GET /api/tarefas
    @GetMapping
    public List<Tarefa> listar() {
        return new ArrayList<>(banco.values());
    }

    // ---------- BUSCAR POR ID ----------
    // GET /api/tarefas/{id}  →  200 ou 404
    @GetMapping("/{id}")
    public ResponseEntity<Tarefa> buscar(@PathVariable Long id) {
        Tarefa t = banco.get(id);
        if (t == null) {
            return ResponseEntity.notFound().build(); // 404
        }
        return ResponseEntity.ok(t); // 200 + body
    }

    // ---------- CRIAR ----------
    // POST /api/tarefas  →  201 Created + body
    @PostMapping
    public ResponseEntity<Tarefa> criar(@RequestBody CriarTarefaDTO dto) {
        Long id = proximoId.getAndIncrement();
        Tarefa nova = new Tarefa(id, dto.titulo(), false);
        banco.put(id, nova);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .header("Location", "/api/tarefas/" + id)
                .body(nova);
    }

    // ---------- ATUALIZAR ----------
    // PUT /api/tarefas/{id}  →  200 ou 404
    @PutMapping("/{id}")
    public ResponseEntity<Tarefa> atualizar(
            @PathVariable Long id,
            @RequestBody AtualizarTarefaDTO dto) {

        if (!banco.containsKey(id)) {
            return ResponseEntity.notFound().build();
        }
        Tarefa atualizada = new Tarefa(id, dto.titulo(), dto.feita());
        banco.put(id, atualizada);
        return ResponseEntity.ok(atualizada);
    }

    // ---------- REMOVER ----------
    // DELETE /api/tarefas/{id}  →  204 ou 404
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> remover(@PathVariable Long id) {
        Tarefa removida = banco.remove(id);
        if (removida == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build(); // 204
    }
}

// Classe principal — sobe o servidor.
@org.springframework.boot.autoconfigure.SpringBootApplication
class TarefasApplication {
    public static void main(String[] args) {
        org.springframework.boot.SpringApplication.run(TarefasApplication.class, args);
    }
}
*/

// =====================================================================
// Este Main.java só imprime instruções — o código real está nos comentários.
// =====================================================================

public class Main {
    public static void main(String[] args) {
        System.out.println("=== Módulo 18 — Desafio: CRUD de Tarefas ===");
        System.out.println();
        System.out.println("Implemente o TarefaController num projeto Spring Boot real.");
        System.out.println("O ESQUELETO e a SOLUÇÃO completa estão nos comentários acima.");
        System.out.println();
        System.out.println("Passos:");
        System.out.println("  1. Gere um projeto em https://start.spring.io (Spring Web)");
        System.out.println("  2. Cole o código da solução (ou tente o seu) no projeto");
        System.out.println("  3. Rode a @SpringBootApplication");
        System.out.println("  4. Teste com os comandos curl listados nos comentários");
        System.out.println();
        System.out.println("Endpoints a implementar:");
        System.out.println("  GET    /api/tarefas        → listar");
        System.out.println("  GET    /api/tarefas/{id}   → buscar (404 se não acha)");
        System.out.println("  POST   /api/tarefas        → criar (201 Created)");
        System.out.println("  PUT    /api/tarefas/{id}   → atualizar");
        System.out.println("  DELETE /api/tarefas/{id}   → remover (204 No Content)");
    }
}
