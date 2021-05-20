-- 進貨退回
CREATE TABLE public.psi_p_exit
(
    uuid_id uuid NOT NULL DEFAULT gen_random_uuid(),
    order_id character varying COLLATE pg_catalog."default",
    product_id uuid,
    quantity integer,
    unit_price numeric,
    created_date date DEFAULT CURRENT_DATE,
    created_at timestamp with time zone DEFAULT now(),
    deleted_at timestamp with time zone,
    CONSTRAINT psi_p_exit_pkey PRIMARY KEY (uuid_id)
)

-- 進貨
CREATE TABLE public.psi_p_logs
(
    uuid_id uuid NOT NULL DEFAULT gen_random_uuid(),
    order_id character varying COLLATE pg_catalog."default",
    product_id uuid,
    quantity integer,
    unit_price numeric,
    created_date date DEFAULT CURRENT_DATE,
    created_at timestamp with time zone DEFAULT now(),
    deleted_at timestamp with time zone,
    CONSTRAINT psi_p_logs_pkey PRIMARY KEY (uuid_id)
)

-- 進貨庫存
CREATE TABLE public.psi_p_stock
(
    uuid_id uuid NOT NULL DEFAULT gen_random_uuid(),
    product_no character varying COLLATE pg_catalog."default",
    quantity integer,
    created_date date DEFAULT CURRENT_DATE,
    created_at timestamp with time zone DEFAULT now(),
    deleted_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT psi_p_stock_pkey PRIMARY KEY (uuid_id)
)
