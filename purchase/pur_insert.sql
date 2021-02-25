-- 單號+1 20200214001
CREATE OR REPLACE FUNCTION p_order_no_new ()
    RETURNS text
    LANGUAGE 'plpgsql'
    AS $$
DECLARE
    perfix_data text;
    v text;
    i int8;
BEGIN
    SELECT
        INTO perfix_data to_char(CURRENT_DATE, 'YYYYMMDD');
    -- RAISE NOTICE '1 %', perfix_data;
    SELECT
        INTO v max(order_id)
    FROM
        psi_p_logs
    WHERE
        order_id LIKE perfix_data || '%';
    IF v IS NULL THEN
        v = to_char(CURRENT_DATE, 'YYYYMMDD001');
        -- RAISE NOTICE '2 %', v;
        RETURN v;
        -- RAISE NOTICE '{order_no, %}', v;
        -- v = '{order_no, ' || v || '}';
        --RAISE NOTICE 'v %', v;
        -- RETURN json_object(v::text[]);
    END IF;
    i = v::int8 + 1;
    v = i::text;
    -- v = '{order_no, ' || v || '}';
    -- RAISE NOTICE 'v %', v;
    -- RETURN json_object(v::text[]);
    RETURN v;
END;
$$
LANGUAGE plpgsql;

-- 新增進貨單記錄
CREATE OR REPLACE FUNCTION p_insert (IN in_array text[])
    RETURNS text
    AS $$
DECLARE
    t text[];
    pno_new text;
    t1 uuid;
    t2 integer;
BEGIN
    SELECT
        INTO pno_new p_order_no_new ();
    FOREACH t SLICE 1 IN ARRAY in_array LOOP
        -- raise notice 't: %', t[1];
        -- raise notice 'b: %, %', t[1], t[2];
        t1 = t[1]::uuid;
        t2 = t[2]::integer;
        INSERT INTO psi_p_logs (order_id, product_id, quantity, unit_price)
        -- VALUES (t[1], t2, t3, t[4]::numeric);
            VALUES (pno_new, t1, t2, t[3]::numeric);
        -- INSERT INTO psi_p_logs (order_id, quantity)
        -- VALUES (t[2], t[3]::integer);
        PERFORM
            p_quantity_add (t1, t2);
    END LOOP;
    RETURN pno_new;
END;
$$
LANGUAGE plpgsql;

-- TODO: exception.
/*
SELECT p_insert('{
 {bcd16bb9-1f72-47af-90af-2e8ce2cf0668, 15, 300},
 {444d77a1-cb11-4444-a82c-dd71645f4858, 30, 100}
 }');

SELECT p_stock_insert('{
 {9f6734f6-5806-4973-8baf-f2282b52da83, 15, 300},
 {5f3d2e0d-3cc8-41e1-a17a-803c4975b0d3, 30, 100}
 }');

SELECT sync_insert_stock('{{a,b,c},{d,e,f},{g,h,i}}');

SELECT public.sync_insert_stock('{
 {20210215003, 9f6734f6-5806-4973-8baf-f2282b52da83, 15, 300},
 {20210215003, 5f3d2e0d-3cc8-41e1-a17a-803c4975b0d3, 30, 100}
 }');
 */

 
-- 作廢(整張單, 單號不得重用.)
-- 作廢單
CREATE OR REPLACE FUNCTION p_invalid (order_no text)
    RETURNS integer
    AS $$
DECLARE
    r psi_p_logs % ROWTYPE;
    n RECORD;
    -- IS NULL
BEGIN
    -- order_no: No match or deleted.
    SELECT
        * INTO n
    FROM
        psi_p_logs
    WHERE
        order_id = order_no
        AND deleted_at IS NULL;
    IF n IS NULL THEN
        RETURN 0;
    END IF;
    FOR r IN (
        SELECT
            *
        FROM
            psi_p_logs
        WHERE
            order_id = order_no
            AND deleted_at IS NULL)
        LOOP
            PERFORM
                p_quantity_minus (r.product_id, r.quantity);
        END LOOP;
    UPDATE
        psi_p_logs
    SET
        deleted_at = now()
    WHERE
        order_id = order_no;
    RETURN 1;
END;
$$
LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION p_invalid(order_no text)
--     RETURNS void AS $$
-- DECLARE
--     c CURSOR;
--     r psi_p_logs%ROWTYPE;
-- BEGIN
--     OPEN curs FOR SELECT * FROM psi_p_logs WHERE order_id = order_no;
--     FETCH curs INTO r;
--         SELECT p_quantity_minus(r.product_id, r.quantity);
--         -- SELECT prouduct_id, quantity INTO r.prouduct_id, r.quantity FROM psi_p_logs WHERE order_no = order_id
--         -- SELECT product_id, quantity INTO r FROM psi_p_logs WHERE order_no = order_id
--     --CLOSE curs;
--     UPDATE psi_p_logs SET deleted_at = now() FROM psi_p_logs WHERE order_id = order_no;
--     -- RETURN 1;
-- END;
-- $$ LANGUAGE plpgsql;
