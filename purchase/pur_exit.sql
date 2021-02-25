-- 進貨退出
CREATE TABLE psi_p_exit (
    uuid_id uuid NOT NULL DEFAULT gen_random_uuid (),
    order_id varchar,
    product_id uuid, -- FK: psi_p_stock.uuid_id
    quantity integer,
    unit_price numeric,
    --
    created_date date DEFAULT CURRENT_DATE,
    created_at timestamp with time zone DEFAULT now(), -- type: timestampz
    deleted_at timestamp with time zone,
    PRIMARY KEY (uuid_id))
-- 單號+1, 2020.02.14.+001
CREATE OR REPLACE FUNCTION p_exit_order_no_new ()
    RETURNS text
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
        psi_p_exit
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

-- 新增進貨單退出明細記錄
-- input: product_id, quantity, unit_price
CREATE OR REPLACE FUNCTION p_exit_new (IN in_array text[])
    RETURNS text
    AS $$
DECLARE
    t text[];
    pno_new text;
    t1 uuid;
    t2 integer;
BEGIN
    SELECT
        INTO pno_new p_exit_order_no_new ();
    FOREACH t SLICE 1 IN ARRAY in_array LOOP
        -- raise notice 't: %', t[1];
        -- raise notice 'b: %, %', t[1], t[2];
        t1 = t[1]::uuid;
        t2 = t[2]::integer;
        INSERT INTO psi_p_exit (order_id, product_id, quantity, unit_price)
        -- VALUES (t[1], t2, t3, t[4]::numeric);
            VALUES (pno_new, t1, t2, t[3]::numeric);
        -- INSERT INTO psi_p_logs (order_id, quantity)
        -- VALUES (t[2], t[3]::integer);
        PERFORM
            p_quantity_minus (t1, t2);
    END LOOP;
    RETURN pno_new;
END;
$$
LANGUAGE plpgsql;

-- TODO: exception.
-- SELECT p_exit_new('{
--     {bcd16bb9-1f72-47af-90af-2e8ce2cf0668, 999, 10000},
--     {444d77a1-cb11-4444-a82c-dd71645f4858, 999, 10000}
--     }');
-- 作廢進貨退出
-- 作廢(整張單, 單號不得重用.)
-- 作廢單
CREATE OR REPLACE FUNCTION p_exit_invalid (order_no text)
    RETURNS integer
    AS $$
DECLARE
    r psi_p_exit % ROWTYPE;
    n RECORD;
    -- IS NULL
BEGIN
    -- order_no: No match or deleted.
    SELECT
        * INTO n
    FROM
        psi_p_exit
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
            psi_p_exit
        WHERE
            order_id = order_no
            AND deleted_at IS NULL)
        LOOP
            PERFORM
                p_quantity_add (r.product_id, r.quantity);
        END LOOP;
    UPDATE
        psi_p_exit
    SET
        deleted_at = now()
    WHERE
        order_id = order_no;
    RETURN 1;
END;
$$
LANGUAGE plpgsql;