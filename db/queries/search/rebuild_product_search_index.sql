-- ─────────────────────────────────────────
-- REBUILD SEARCH PROJECTION TABLE
-- Periodic rebuild job
-- ─────────────────────────────────────────

TRUNCATE TABLE search_product_variant;

INSERT INTO search_product_variant (
    variant_id,
    product_id,
    product_name,
    variant_name,
    brand_id,
    brand_name,
    primary_category_id,
    category_ids,
    number_attrs,
    bool_attrs,
    enum_attrs,
    string_attrs
)
SELECT
    pv.id AS variant_id,
    p.id AS product_id,
    p.name AS product_name,
    pv.name AS variant_name,
    b.id AS brand_id,
    b.name AS brand_name,
    p.primary_category AS primary_category_id,

    -- categories including primary + secondary
    (
        SELECT ARRAY_AGG(DISTINCT pc.category)
        FROM product_category pc
        WHERE pc.product = p.id
        AND pc.is_deleted = FALSE
    ) AS category_ids,

    -- NUMBER ATTRIBUTES
    (
        SELECT COALESCE(jsonb_object_agg(attr_id::text, val), '{}'::jsonb)
        FROM (
            SELECT
                ca.attribute AS attr_id,
                COALESCE(pvav.number_value, pav.number_value) AS val
            FROM category_attribute ca
            LEFT JOIN product_attribute_value pav
                ON pav.category_attribute = ca.id
                AND pav.product = p.id
                AND pav.is_deleted = FALSE
            LEFT JOIN product_variant_attribute_value pvav
                ON pvav.category_attribute = ca.id
                AND pvav.product_variant = pv.id
                AND pvav.is_deleted = FALSE
            JOIN attribute a ON a.id = ca.attribute
            WHERE a.type = 'number'
            AND COALESCE(pvav.number_value, pav.number_value) IS NOT NULL
        ) t
    ) AS number_attrs,

    -- BOOL ATTRIBUTES
    (
        SELECT COALESCE(jsonb_object_agg(attr_id::text, val), '{}'::jsonb)
        FROM (
            SELECT
                ca.attribute AS attr_id,
                COALESCE(pvav.bool_value, pav.bool_value) AS val
            FROM category_attribute ca
            LEFT JOIN product_attribute_value pav
                ON pav.category_attribute = ca.id
                AND pav.product = p.id
                AND pav.is_deleted = FALSE
            LEFT JOIN product_variant_attribute_value pvav
                ON pvav.category_attribute = ca.id
                AND pvav.product_variant = pv.id
                AND pvav.is_deleted = FALSE
            JOIN attribute a ON a.id = ca.attribute
            WHERE a.type = 'bool'
            AND COALESCE(pvav.bool_value, pav.bool_value) IS NOT NULL
        ) t
    ) AS bool_attrs,

    -- ENUM ATTRIBUTES
    (
        SELECT COALESCE(jsonb_object_agg(attr_id::text, val), '{}'::jsonb)
        FROM (
            SELECT
                ca.attribute AS attr_id,
                COALESCE(pvav.enum_value, pav.enum_value) AS val
            FROM category_attribute ca
            LEFT JOIN product_attribute_value pav
                ON pav.category_attribute = ca.id
                AND pav.product = p.id
                AND pav.is_deleted = FALSE
            LEFT JOIN product_variant_attribute_value pvav
                ON pvav.category_attribute = ca.id
                AND pvav.product_variant = pv.id
                AND pvav.is_deleted = FALSE
            JOIN attribute a ON a.id = ca.attribute
            WHERE a.type = 'enum_list'
            AND COALESCE(pvav.enum_value, pav.enum_value) IS NOT NULL
        ) t
    ) AS enum_attrs,

    -- STRING ATTRIBUTES
    (
        SELECT COALESCE(jsonb_object_agg(attr_id::text, val), '{}'::jsonb)
        FROM (
            SELECT
                ca.attribute AS attr_id,
                COALESCE(pvav.string_value, pav.string_value) AS val
            FROM category_attribute ca
            LEFT JOIN product_attribute_value pav
                ON pav.category_attribute = ca.id
                AND pav.product = p.id
                AND pav.is_deleted = FALSE
            LEFT JOIN product_variant_attribute_value pvav
                ON pvav.category_attribute = ca.id
                AND pvav.product_variant = pv.id
                AND pvav.is_deleted = FALSE
            JOIN attribute a ON a.id = ca.attribute
            WHERE a.type = 'string'
            AND COALESCE(pvav.string_value, pav.string_value) IS NOT NULL
        ) t
    ) AS string_attrs

FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
WHERE
    pv.is_deleted = FALSE
    AND p.is_deleted = FALSE
    AND p.visibility = 'public';