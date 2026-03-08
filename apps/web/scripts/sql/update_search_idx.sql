-- scripts/sql/update_search_idx.sql

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Clear existing rows
TRUNCATE TABLE "product_variant_search_index";

INSERT INTO "product_variant_search_index" (
  variant_id,
  product_id,
  category,
  visibility,
  owner_user_id,
  product_name,
  variant_name,
  brand_name,
  weight_g,
  packed_volume_l,
  sleeping_pad_r_value,
  search_tsv
)
SELECT
  pv.id                                   AS variant_id,
  p.id                                    AS product_id,
  p.category                              AS category,
  p.visibility                            AS visibility,
  p.owner_user_id                         AS owner_user_id,
  p.name                                  AS product_name,
  pv.variant_name                         AS variant_name,
  b.name                                  AS brand_name,
  pv.weight_g                             AS weight_g,
  pv.packed_volume_l                      AS packed_volume_l,
  sp.sleeping_pad_r_value                 AS sleeping_pad_r_value,

  to_tsvector(
    'simple',
    unaccent(
      coalesce(b.name, '') || ' ' ||
      coalesce(p.name, '') || ' ' ||
      coalesce(pv.variant_name, '')
    )
  )                                       AS search_tsv

FROM "product_variant" pv
JOIN "product" p ON p.id = pv.product_id
LEFT JOIN "brand" b ON b.id = p.brand_id
LEFT JOIN "product_variant_sleeping_pad_detail" sp
  ON sp.product_variant_id = pv.id;

