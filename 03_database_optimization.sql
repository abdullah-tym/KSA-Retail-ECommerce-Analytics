CREATE OR REPLACE VIEW public.vw_executive_summary AS
SELECT 
    order_id,
    order_date,
    customer_id,
    segment,
    region,
    state,
    category,
    sub_category,
    sales AS sales_sar,
    profit AS profit_sar,
    quantity,
    CASE 
        WHEN sales > 0 THEN ROUND((profit / sales) * 100, 2)
        ELSE 0
    END AS profit_margin_percentage
FROM public.superstore2;

CREATE INDEX idx_superstore_order_date ON public.superstore2(order_date);
CREATE INDEX idx_superstore_region_state ON public.superstore2(region, state);

EXPLAIN ANALYZE 
SELECT * FROM public.superstore2 WHERE region = 'Central Province';
