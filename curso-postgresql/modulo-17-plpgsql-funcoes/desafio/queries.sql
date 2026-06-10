-- =============================================
-- Módulo 17 — Desafio: Cálculo de Frete + Desconto + Pagamento
-- Você é o backend de uma loja. Implemente as 3 rotinas abaixo.
-- =============================================

-- =====================================================================
-- TODO 1 — calcular_frete(estado CHAR(2), peso_kg NUMERIC) RETURNS NUMERIC
--
-- Regras de negócio:
--   - SP ou RJ: R$ 15,00
--   - Sul (PR, SC, RS): R$ 20,00
--   - Restante do Sudeste (MG, ES): R$ 25,00
--   - Qualquer outro estado: R$ 35,00
--   - Adicional: para cada quilo ACIMA de 5kg, soma R$ 5,00
--     (ex.: peso 7kg em SP => 15 + (7-5)*5 = R$ 25,00)
--   - Se peso for nulo ou <= 0, lançar EXCEPTION
--   - Se estado for nulo ou não tiver 2 chars, lançar EXCEPTION
--
-- Dica: use CASE WHEN para o estado, IF para o peso adicional.
-- =====================================================================

-- TODO 2 — aplicar_desconto(pedido_id INT, percentual NUMERIC) RETURNS NUMERIC
--
-- Regras:
--   - percentual deve estar entre 0 e 50 (inclusive). Senão, EXCEPTION.
--   - O pedido precisa existir e estar com status = 'pendente'. Senão, EXCEPTION.
--   - Calcular o subtotal do pedido (sum quantidade * preco_unitario em itens_pedido)
--   - Aplicar o desconto sobre cada item (UPDATE preco_unitario)
--   - Retornar o novo total já com desconto
--
-- Dica: GET DIAGNOSTICS pra contar linhas, RAISE NOTICE pra debug.

-- TODO 3 — PROCEDURE processar_pagamento(pedido_id INT)
--
-- Regras:
--   - Pedido tem que existir e estar em 'pendente'. Senão, EXCEPTION.
--   - Verificar estoque de TODOS os itens antes de qualquer mudança.
--     Se algum item não tem estoque suficiente, EXCEPTION e nada muda.
--   - Se tudo ok: baixar estoque de cada produto e mudar status pra 'pago'.
--   - Usar transação (procedure permite COMMIT/ROLLBACK).
--
-- Dica: percorra os itens com FOR ... IN SELECT ... LOOP duas vezes
--       (uma só pra validar, outra pra aplicar). Ou use uma CTE.

-- =====================================================================
-- TESTES (descomente depois que implementar)
-- =====================================================================
-- SELECT calcular_frete('SP', 3);     -- 15.00
-- SELECT calcular_frete('SP', 7);     -- 25.00 (15 + 2*5)
-- SELECT calcular_frete('PR', 4);     -- 20.00
-- SELECT calcular_frete('MG', 6);     -- 30.00 (25 + 1*5)
-- SELECT calcular_frete('BA', 10);    -- 60.00 (35 + 5*5)
-- SELECT calcular_frete('SP', 0);     -- erro
-- SELECT calcular_frete(NULL, 5);     -- erro

-- SELECT aplicar_desconto(1, 10);     -- aplica 10% no pedido 1
-- SELECT aplicar_desconto(1, 80);     -- erro: passa de 50

-- CALL processar_pagamento(1);        -- vê o status mudar e o estoque cair
-- CALL processar_pagamento(1);        -- segunda vez: erro (não está pendente)


-- =====================================================================
-- ============== SOLUÇÃO (não espia antes de tentar!) =================
-- =====================================================================

-- ----- 1) calcular_frete -----
CREATE OR REPLACE FUNCTION calcular_frete(estado CHAR(2), peso_kg NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
    frete_base   NUMERIC;
    excedente_kg NUMERIC;
    estado_up    CHAR(2);
BEGIN
    -- Validações
    IF estado IS NULL OR length(trim(estado)) <> 2 THEN
        RAISE EXCEPTION 'Estado invalido: %', estado USING ERRCODE = '22023';
    END IF;
    IF peso_kg IS NULL OR peso_kg <= 0 THEN
        RAISE EXCEPTION 'Peso invalido: % (precisa ser > 0)', peso_kg USING ERRCODE = '22023';
    END IF;

    estado_up := upper(estado);

    -- Tarifa base por região
    CASE
        WHEN estado_up IN ('SP', 'RJ')             THEN frete_base := 15.00;
        WHEN estado_up IN ('PR', 'SC', 'RS')       THEN frete_base := 20.00;
        WHEN estado_up IN ('MG', 'ES')             THEN frete_base := 25.00;
        ELSE                                            frete_base := 35.00;
    END CASE;

    -- Excedente: R$5 por kg acima de 5kg
    IF peso_kg > 5 THEN
        excedente_kg := peso_kg - 5;
        frete_base := frete_base + (excedente_kg * 5.00);
    END IF;

    RETURN frete_base;
END;
$$;


-- ----- 2) aplicar_desconto -----
CREATE OR REPLACE FUNCTION aplicar_desconto(pedido_id INT, percentual NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql AS $$
DECLARE
    fator       NUMERIC;
    status_atual status_pedido;
    novo_total  NUMERIC;
BEGIN
    -- Valida percentual
    IF percentual IS NULL OR percentual < 0 OR percentual > 50 THEN
        RAISE EXCEPTION 'Percentual invalido: % (deve estar entre 0 e 50)', percentual
            USING ERRCODE = '22023';
    END IF;

    -- Valida existência e status
    SELECT p.status INTO status_atual
    FROM pedidos p
    WHERE p.id = pedido_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % nao encontrado', pedido_id USING ERRCODE = '02000';
    END IF;
    IF status_atual <> 'pendente' THEN
        RAISE EXCEPTION 'Pedido % nao esta pendente (status: %)', pedido_id, status_atual
            USING ERRCODE = '22023';
    END IF;

    fator := 1 - (percentual / 100.0);

    -- Aplica o desconto item a item
    UPDATE itens_pedido
    SET preco_unitario = round(preco_unitario * fator, 2)
    WHERE pedido_id = aplicar_desconto.pedido_id;
    -- ^ qualifiquei o parâmetro pra evitar conflito com a coluna

    -- Recalcula total
    SELECT COALESCE(sum(quantidade * preco_unitario), 0)
    INTO novo_total
    FROM itens_pedido
    WHERE itens_pedido.pedido_id = aplicar_desconto.pedido_id;

    RAISE NOTICE 'Desconto de %%% aplicado no pedido %. Novo total: R$ %',
        percentual, pedido_id, novo_total;

    RETURN novo_total;
END;
$$;


-- ----- 3) processar_pagamento (PROCEDURE) -----
CREATE OR REPLACE PROCEDURE processar_pagamento(pedido_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    status_atual status_pedido;
    item         RECORD;
    estoque_atual INT;
BEGIN
    -- Garante que o pedido existe e está pendente
    SELECT p.status INTO status_atual
    FROM pedidos p
    WHERE p.id = pedido_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pedido % nao encontrado', pedido_id USING ERRCODE = '02000';
    END IF;
    IF status_atual <> 'pendente' THEN
        RAISE EXCEPTION 'Pedido % nao esta pendente (status: %)', pedido_id, status_atual
            USING ERRCODE = '22023';
    END IF;

    -- 1ª passada: VALIDAR estoque sem alterar nada
    FOR item IN
        SELECT ip.produto_id, ip.quantidade, pr.nome, pr.estoque
        FROM itens_pedido ip
        JOIN produtos pr ON pr.id = ip.produto_id
        WHERE ip.pedido_id = processar_pagamento.pedido_id
    LOOP
        IF item.estoque < item.quantidade THEN
            RAISE EXCEPTION 'Estoque insuficiente para produto "%" (id=%): tem %, precisa %',
                item.nome, item.produto_id, item.estoque, item.quantidade
                USING ERRCODE = '23514';
        END IF;
    END LOOP;

    -- 2ª passada: BAIXAR estoque (já sabemos que dá)
    FOR item IN
        SELECT produto_id, quantidade
        FROM itens_pedido
        WHERE itens_pedido.pedido_id = processar_pagamento.pedido_id
    LOOP
        UPDATE produtos
        SET estoque = estoque - item.quantidade
        WHERE id = item.produto_id;
    END LOOP;

    -- Marca como pago
    UPDATE pedidos
    SET status = 'pago'
    WHERE id = pedido_id;

    COMMIT;  -- procedure pode confirmar a transação

    RAISE NOTICE 'Pedido % processado com sucesso', pedido_id;
END;
$$;
