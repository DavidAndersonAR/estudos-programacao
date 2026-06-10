-- =============================================
-- Módulo 17 — PL/pgSQL: Funções e Procedures
-- Prática: 7 funções + 1 procedure cobrindo o básico
-- Pré-requisito: schema + seed do Módulo 01 carregados
-- =============================================

-- ---------------------------------------------
-- Exercício 1: função mais simples possível
-- Soma dois inteiros e devolve o resultado.
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION somar(a INT, b INT) RETURNS INT
LANGUAGE plpgsql AS $$
BEGIN
    RETURN a + b;
END;
$$;

SELECT somar(10, 32) AS resultado;  -- 42


-- ---------------------------------------------
-- Exercício 2: função que retorna texto formatado
-- Mostra concatenação com || e uso de format()
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION saudar(nome TEXT, hora INT) RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    periodo TEXT;
BEGIN
    IF hora < 12 THEN
        periodo := 'Bom dia';
    ELSIF hora < 18 THEN
        periodo := 'Boa tarde';
    ELSE
        periodo := 'Boa noite';
    END IF;
    -- format() é tipo printf: %s = string, %I = identificador, %L = literal
    RETURN format('%s, %s! São %s horas.', periodo, nome, hora);
END;
$$;

SELECT saudar('Maria', 9);   -- Bom dia, Maria! São 9 horas.
SELECT saudar('João', 15);   -- Boa tarde, João! São 15 horas.
SELECT saudar('Ana', 22);    -- Boa noite, Ana! São 22 horas.


-- ---------------------------------------------
-- Exercício 3: IF/ELSIF classificando preço de produto
-- Mostra %TYPE (mesmo tipo da coluna) e várias condições
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION classificar_preco(preco produtos.preco%TYPE) RETURNS TEXT
LANGUAGE plpgsql AS $$
BEGIN
    IF preco IS NULL THEN
        RETURN 'sem preco';
    ELSIF preco < 50 THEN
        RETURN 'barato';
    ELSIF preco < 200 THEN
        RETURN 'medio';
    ELSIF preco < 1000 THEN
        RETURN 'caro';
    ELSE
        RETURN 'premium';
    END IF;
END;
$$;

-- Usando direto em uma query:
SELECT nome, preco, classificar_preco(preco) AS faixa
FROM produtos
ORDER BY preco
LIMIT 10;


-- ---------------------------------------------
-- Exercício 4: loop FOR somando de 1 até N
-- Mostra LOOP, DECLARE com valor inicial e RAISE NOTICE
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION somar_ate(n INT) RETURNS BIGINT
LANGUAGE plpgsql AS $$
DECLARE
    total  BIGINT := 0;
    i      INT;
BEGIN
    IF n < 1 THEN
        RAISE NOTICE 'n=% e menor que 1, retornando 0', n;
        RETURN 0;
    END IF;

    FOR i IN 1..n LOOP
        total := total + i;
    END LOOP;

    RAISE NOTICE 'Somei de 1 ate %, deu %', n, total;
    RETURN total;
END;
$$;

SELECT somar_ate(10);    -- 55
SELECT somar_ate(100);   -- 5050
SELECT somar_ate(0);     -- 0 + aviso


-- ---------------------------------------------
-- Exercício 5: EXCEPTION capturando divisão por zero
-- Mostra BEGIN..EXCEPTION..END e tratamento explícito
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION dividir_seguro(a NUMERIC, b NUMERIC) RETURNS NUMERIC
LANGUAGE plpgsql AS $$
BEGIN
    RETURN a / b;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Tentativa de dividir % por zero - retornando NULL', a;
        RETURN NULL;
    WHEN OTHERS THEN
        -- pega qualquer outro erro
        RAISE NOTICE 'Erro inesperado: %', SQLERRM;
        RETURN NULL;
END;
$$;

SELECT dividir_seguro(10, 2);  -- 5
SELECT dividir_seguro(10, 0);  -- NULL + aviso


-- ---------------------------------------------
-- Exercício 6: RETURNS TABLE — retornar várias linhas
-- Lista produtos caros acima de um valor com a categoria
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION produtos_acima_de(valor_minimo NUMERIC)
RETURNS TABLE(
    produto_nome    VARCHAR(200),
    preco           NUMERIC,
    categoria       VARCHAR(100)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- RETURN QUERY despeja o resultado todo de uma vez
    RETURN QUERY
        SELECT p.nome, p.preco, c.nome
        FROM produtos p
        LEFT JOIN categorias c ON c.id = p.categoria_id
        WHERE p.preco >= valor_minimo
        ORDER BY p.preco DESC;
END;
$$;

SELECT * FROM produtos_acima_de(100);


-- ---------------------------------------------
-- Exercício 7: função usando OUT (devolve 2 valores)
-- Mostra como ter "múltiplos retornos" sem TABLE
-- ---------------------------------------------
CREATE OR REPLACE FUNCTION resumo_produtos(
    OUT total INT,
    OUT preco_medio NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    SELECT count(*), avg(preco)
    INTO total, preco_medio
    FROM produtos;
END;
$$;

SELECT * FROM resumo_produtos();


-- ---------------------------------------------
-- Exercício 8: PROCEDURE — não retorna, chama com CALL
-- Repõe o estoque de produtos zerados com uma quantidade fixa
-- ---------------------------------------------
CREATE OR REPLACE PROCEDURE repor_estoque_zerados(quantidade INT)
LANGUAGE plpgsql AS $$
DECLARE
    afetados INT;
BEGIN
    IF quantidade <= 0 THEN
        RAISE EXCEPTION 'Quantidade deve ser positiva, recebi %', quantidade;
    END IF;

    UPDATE produtos
    SET estoque = quantidade
    WHERE estoque = 0;

    GET DIAGNOSTICS afetados = ROW_COUNT;
    RAISE NOTICE 'Reposto estoque de % produto(s)', afetados;
END;
$$;

-- Procedure se chama com CALL, não SELECT:
CALL repor_estoque_zerados(20);

-- Confere:
SELECT id, nome, estoque FROM produtos WHERE estoque = 20 LIMIT 5;
