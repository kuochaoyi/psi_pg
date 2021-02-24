-- 進貨明細按日期排序
SELECT
  psi_p_logs.order_id,
  psi_p_logs.product_id,
  psi_p_stock.product_no,
  psi_p_logs.quantity
FROM
  psi_p_logs,
  psi_p_stock
WHERE
  psi_p_logs.product_id = psi_p_stock.uuid_id
  AND psi_p_logs.deleted_at IS NULL
ORDER BY
  psi_p_logs.order_id DESC;

