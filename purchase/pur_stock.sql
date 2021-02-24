-- 減少庫存量
CREATE OR REPLACE FUNCTION p_quantity_minus (prouduct_id uuid, quantity int)
  RETURNS void
  AS $$
DECLARE
  q int := 0;
BEGIN
  SELECT
    INTO q psi_p_stock.quantity
  FROM
    psi_p_stock
  WHERE
    prouduct_id = psi_p_stock.uuid_id;
  q = q - quantity;
  UPDATE
    psi_p_stock
  SET
    quantity = q,
    updated_at = now()
  WHERE
    prouduct_id = psi_p_stock.uuid_id;
END;
$$
LANGUAGE plpgsql;

-- SELECT public.quantity_add('01159a58-eb2e-40e1-8f70-119b9a249c7a'::uuid, 50);
-- 增加庫存量
CREATE OR REPLACE FUNCTION p_quantity_add (prouduct_id uuid, quantity int)
  RETURNS void
  AS $$
DECLARE
  q int := 0;
BEGIN
  SELECT
    INTO q psi_p_stock.quantity
  FROM
    psi_p_stock
  WHERE
    prouduct_id = psi_p_stock.uuid_id;
  q = q + quantity;
  UPDATE
    psi_p_stock
  SET
    quantity = q,
    updated_at = now()
  WHERE
    prouduct_id = psi_p_stock.uuid_id;
END;
$$
LANGUAGE plpgsql;

-- SELECT public.quantity_add('01159a58-eb2e-40e1-8f70-119b9a249c7a'::uuid, 50);
