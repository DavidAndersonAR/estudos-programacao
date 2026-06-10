# Desafio — Cache de CEP com invalidação por admin

## Cenário

Sua API consulta CEPs em um provedor externo (ViaCEP, por exemplo). A consulta é lenta (300–800ms) e a maioria dos CEPs nunca muda. Mas, vez ou outra, um admin corrige um endereço no painel interno e precisa que a aplicação devolva o valor atualizado imediatamente.

## O que fazer

1. Crie `CepService` com um método `buscar(String cep)` que:
   - Simule a chamada externa com `Thread.sleep(500)`.
   - Devolva um `record EnderecoDTO(String cep, String logradouro, String cidade, String uf)`.
   - Esteja anotado com `@CacheResult(cacheName = "cep")`.

2. Crie um método `atualizar(String cep, EnderecoDTO novo)` que:
   - Anotado com `@CacheInvalidate(cacheName = "cep")`, força a próxima leitura a buscar fresco.
   - (Em produção gravaria no banco; aqui pode só logar.)

3. Crie um método `limparTudo()` com `@CacheInvalidateAll(cacheName = "cep")`.

4. Configure no `application.properties`:
   - TTL de 1 hora.
   - Tamanho máximo de 10.000 entradas.

5. Exponha endpoints REST:
   - `GET  /cep/{cep}` — busca (cacheado).
   - `POST /cep/{cep}` (apenas admin, simulado) — atualiza e invalida.
   - `DELETE /cep` — limpa todo o cache.

## Bônus

- Cacheie também um método `buscarPorBairro(@CacheKey String cidade, @CacheKey String bairro, String idioma)` mostrando que `idioma` fica de fora da chave.
- Acrescente uma rota `GET /cep/{cep}/teste-performance` que chama o serviço 5 vezes e devolve os tempos.

## Critérios de aceite

- Segunda chamada ao mesmo CEP retorna em < 50ms.
- Após `POST /cep/{cep}`, a próxima chamada `GET` leva ~500ms (cache invalidado).
- Após `DELETE /cep`, todas as chaves somem.
- `@CacheKey` usado corretamente no bônus.
