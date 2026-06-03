ALTER TABLE public.superstore2 
    ALTER COLUMN sales TYPE NUMERIC USING sales::numeric,
    ALTER COLUMN profit TYPE NUMERIC USING profit::numeric,
    ALTER COLUMN discount TYPE NUMERIC USING discount::numeric,
    ALTER COLUMN quantity TYPE INT USING quantity::integer,
    ALTER COLUMN order_date TYPE DATE USING order_date::date,
    ALTER COLUMN ship_date TYPE DATE USING ship_date::date;

UPDATE public.superstore2
SET 
    country = 'Saudi Arabia',
    region = CASE 
        WHEN region = 'West' THEN 'Western Province'
        WHEN region = 'East' THEN 'Eastern Province'
        WHEN region = 'Central' THEN 'Central Province'
        ELSE 'Southern Province'
    END,
    state = CASE 
        WHEN state IN ('California', 'Washington', 'Oregon') THEN 'Makkah Province'
        WHEN state IN ('New York', 'Pennsylvania', 'Ohio') THEN 'Riyadh Province'
        WHEN state IN ('Texas', 'Illinois', 'Florida') THEN 'Eastern Province'
        ELSE 'Medina Province'
    END,
    sales = ROUND(sales * 3.75, 2),
    profit = ROUND(profit * 3.75, 2);
