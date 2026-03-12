-- seed_sleeping_pads_canonical.sql

-- ─────────────────────────────────────────
-- CATEGORIES
-- ─────────────────────────────────────────

INSERT INTO category (slug, name, description, parent_category)
SELECT
  'sleeping-gear',
  'Sleeping Gear',
  'Sleep systems and related overnight camping gear.',
  NULL
WHERE NOT EXISTS (
  SELECT 1 FROM category WHERE slug = 'sleeping-gear' AND is_deleted = FALSE
);

INSERT INTO category (slug, name, description, parent_category)
SELECT
  'sleeping-pads',
  'Sleeping Pads',
  'Inflatable, self-inflating, and foam sleeping pads for insulation and comfort.',
  c.id
FROM category c
WHERE c.slug = 'sleeping-gear'
  AND c.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM category WHERE slug = 'sleeping-pads' AND is_deleted = FALSE
  );

-- ─────────────────────────────────────────
-- ATTRIBUTES
-- ─────────────────────────────────────────

INSERT INTO attribute (slug, name, description, type, number_unit)
SELECT * FROM (
  VALUES
    ('weight_g', 'Weight', 'Total trail weight of the sleeping pad variant in grams.', 'number'::attribute_type, 'weight_g'::number_unit),
    ('r_value', 'R-Value', 'Thermal resistance of the sleeping pad.', 'number'::attribute_type, 'float'::number_unit),
    ('thickness_mm', 'Thickness', 'Maximum inflated thickness of the sleeping pad in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('length_mm', 'Length', 'Usable sleeping pad length in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('width_mm', 'Width', 'Maximum sleeping pad width in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('shoulder_width_mm', 'Shoulder Width', 'Sleeping pad width at the shoulder area in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('hip_width_mm', 'Hip Width', 'Sleeping pad width at the hip area in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('ankle_width_mm', 'Ankle Width', 'Sleeping pad width at the ankle or foot area in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('packed_volume_ml', 'Packed Volume', 'Packed volume of the sleeping pad in millilitres.', 'number'::attribute_type, 'volume_ml'::number_unit),
    ('packed_length_mm', 'Packed Length', 'Packed cylindrical or folded length in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('packed_diameter_mm', 'Packed Diameter', 'Packed cylindrical diameter in millimetres.', 'number'::attribute_type, 'length_mm'::number_unit),
    ('baffle_count', 'Baffle Count', 'Number of major baffles if explicitly specified.', 'number'::attribute_type, 'int'::number_unit),

    ('astm_tested', 'ASTM Tested', 'Whether the published R-value is explicitly ASTM tested.', 'bool'::attribute_type, 'NA'::number_unit),
    ('pump_included', 'Pump Included', 'Whether a pump sack or separate inflation aid is included.', 'bool'::attribute_type, 'NA'::number_unit),
    ('integrated_pump', 'Integrated Pump', 'Whether the pad has a built-in pump mechanism.', 'bool'::attribute_type, 'NA'::number_unit),
    ('included_stuff_sack', 'Stuff Sack Included', 'Whether a stuff sack or storage sack is included.', 'bool'::attribute_type, 'NA'::number_unit),
    ('repair_kit_included', 'Repair Kit Included', 'Whether a repair kit is included.', 'bool'::attribute_type, 'NA'::number_unit),
    ('can_link_two_pads', 'Linkable', 'Whether the pad is explicitly designed to connect to another pad.', 'bool'::attribute_type, 'NA'::number_unit),
    ('reversible_sleep_surface', 'Reversible Sleep Surface', 'Whether the sleeping surface is designed to be reversible.', 'bool'::attribute_type, 'NA'::number_unit),

    ('pad_type', 'Pad Type', 'Primary construction type of the sleeping pad.', 'enum_list'::attribute_type, 'NA'::number_unit),
    ('insulation_type', 'Insulation Type', 'Primary insulation approach used by the pad.', 'enum_list'::attribute_type, 'NA'::number_unit),
    ('shape', 'Shape', 'Outline shape of the sleeping pad.', 'enum_list'::attribute_type, 'NA'::number_unit),
    ('intended_season_rating', 'Season Rating', 'Intended season use based on brand positioning or warmth claims.', 'enum_list'::attribute_type, 'NA'::number_unit),
    ('size_class', 'Size Class', 'Canonical normalized size bucket for the variant.', 'enum_list'::attribute_type, 'NA'::number_unit),
    ('sex_specific_design', 'Sex-Specific Design', 'Whether the product is marketed as men''s, women''s, or unisex.', 'enum_list'::attribute_type, 'NA'::number_unit),

    ('fabric_material_text', 'Fabric Material', 'Raw normalized text describing face fabric materials.', 'string'::attribute_type, 'NA'::number_unit),
    ('top_fabric_denier_text', 'Top Fabric Denier', 'Raw top fabric denier specification.', 'string'::attribute_type, 'NA'::number_unit),
    ('bottom_fabric_denier_text', 'Bottom Fabric Denier', 'Raw bottom fabric denier specification.', 'string'::attribute_type, 'NA'::number_unit),
    ('valve_type_text', 'Valve Type', 'Raw text describing valve construction.', 'string'::attribute_type, 'NA'::number_unit),
    ('notes_text', 'Notes', 'Catch-all notes field for unusual but useful pad details.', 'string'::attribute_type, 'NA'::number_unit)
) AS v(slug, name, description, type, number_unit)
WHERE NOT EXISTS (
  SELECT 1 FROM attribute a WHERE a.slug = v.slug AND a.is_deleted = FALSE
);

-- ─────────────────────────────────────────
-- ENUM ATTRIBUTE VALUES
-- ─────────────────────────────────────────

INSERT INTO enum_attribute_vals (attribute, slug, name, display_order)
SELECT a.id, v.slug, v.name, v.display_order
FROM attribute a
JOIN (
  VALUES
    ('pad_type', 'air-pad', 'Air Pad', 1),
    ('pad_type', 'self-inflating-pad', 'Self-Inflating Pad', 2),
    ('pad_type', 'closed-cell-foam-pad', 'Closed-Cell Foam Pad', 3),
    ('pad_type', 'hybrid-pad', 'Hybrid Pad', 4),

    ('insulation_type', 'uninsulated', 'Uninsulated', 1),
    ('insulation_type', 'synthetic-insulation', 'Synthetic Insulation', 2),
    ('insulation_type', 'reflective-film', 'Reflective Film', 3),
    ('insulation_type', 'down-insulation', 'Down Insulation', 4),
    ('insulation_type', 'foam-core', 'Foam Core', 5),
    ('insulation_type', 'hybrid-insulation', 'Hybrid Insulation', 6),

    ('shape', 'rectangular', 'Rectangular', 1),
    ('shape', 'mummy', 'Mummy', 2),
    ('shape', 'tapered-rectangular', 'Tapered Rectangular', 3),
    ('shape', 'torso', 'Torso', 4),
    ('shape', 'other', 'Other', 5),

    ('intended_season_rating', 'summer', 'Summer', 1),
    ('intended_season_rating', 'three-season', 'Three-Season', 2),
    ('intended_season_rating', 'winter', 'Winter', 3),
    ('intended_season_rating', 'expedition', 'Expedition', 4),

    ('size_class', 'torso', 'Torso', 1),
    ('size_class', 'regular', 'Regular', 2),
    ('size_class', 'regular-wide', 'Regular Wide', 3),
    ('size_class', 'long', 'Long', 4),
    ('size_class', 'long-wide', 'Long Wide', 5),
    ('size_class', 'double', 'Double', 6),
    ('size_class', 'other', 'Other', 7),

    ('sex_specific_design', 'unisex', 'Unisex', 1),
    ('sex_specific_design', 'mens', 'Mens', 2),
    ('sex_specific_design', 'womens', 'Womens', 3)
) AS v(attribute_slug, slug, name, display_order)
  ON a.slug = v.attribute_slug
WHERE NOT EXISTS (
  SELECT 1
  FROM enum_attribute_vals e
  WHERE e.attribute = a.id
    AND e.slug = v.slug
    AND e.is_deleted = FALSE
);

-- ─────────────────────────────────────────
-- CATEGORY ATTRIBUTE MAPPINGS
-- ─────────────────────────────────────────

INSERT INTO category_attribute (category, attribute, priority)
SELECT c.id, a.id, m.priority
FROM category c
JOIN (
  VALUES
    ('weight_g', 100),
    ('r_value', 99),
    ('thickness_mm', 98),
    ('length_mm', 97),
    ('width_mm', 96),
    ('packed_volume_ml', 95),
    ('pad_type', 94),
    ('insulation_type', 93),
    ('shape', 92),
    ('astm_tested', 90),
    ('size_class', 85),
    ('pump_included', 80),
    ('integrated_pump', 79),
    ('intended_season_rating', 70),
    ('packed_length_mm', 55),
    ('packed_diameter_mm', 54),
    ('included_stuff_sack', 50),
    ('repair_kit_included', 49),
    ('fabric_material_text', 40),
    ('top_fabric_denier_text', 35),
    ('bottom_fabric_denier_text', 34),
    ('valve_type_text', 33),
    ('sex_specific_design', 30),
    ('can_link_two_pads', 25),
    ('baffle_count', 20),
    ('reversible_sleep_surface', 10),
    ('notes_text', 1),

    ('shoulder_width_mm', 91),
    ('hip_width_mm', 89),
    ('ankle_width_mm', 88)
) AS m(attribute_slug, priority)
  ON TRUE
JOIN attribute a
  ON a.slug = m.attribute_slug
WHERE c.slug = 'sleeping-pads'
  AND c.is_deleted = FALSE
  AND a.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1
    FROM category_attribute ca
    WHERE ca.category = c.id
      AND ca.attribute = a.id
      AND ca.is_deleted = FALSE
  );

-- ─────────────────────────────────────────
-- EXAMPLE DATA
-- ─────────────────────────────────────────

-- Helper functions (idempotent)
CREATE OR REPLACE FUNCTION sp_attr(attr_slug TEXT) RETURNS BIGINT AS $$
  SELECT ca.id FROM category_attribute ca
  JOIN category c ON c.id = ca.category
  JOIN attribute a ON a.id = ca.attribute
  WHERE c.slug = 'sleeping-pads' AND a.slug = attr_slug
    AND ca.is_deleted = FALSE;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION sp_enum(attr_slug TEXT, val_slug TEXT) RETURNS BIGINT AS $$
  SELECT e.id FROM enum_attribute_vals e
  JOIN attribute a ON a.id = e.attribute
  WHERE a.slug = attr_slug AND e.slug = val_slug
    AND e.is_deleted = FALSE;
$$ LANGUAGE SQL;

-- Brand
INSERT INTO brand (slug, name, country)
SELECT 'ex-gear', 'EX Gear', 'US'
WHERE NOT EXISTS (SELECT 1 FROM brand WHERE slug = 'ex-gear' AND is_deleted = FALSE);

-- ─────────────────────────────────────────
-- [EX] AirFlite UL  (ultralight uninsulated air pad)
-- ─────────────────────────────────────────

INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision)
SELECT
  'ex-airflite-ul', '[EX] AirFlite UL',
  (SELECT id FROM brand WHERE slug = 'ex-gear'),
  (SELECT id FROM category WHERE slug = 'sleeping-pads'),
  'public', '2024-01-01', 'year'
WHERE NOT EXISTS (
  SELECT 1 FROM product p
  JOIN brand b ON b.id = p.brand
  WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND p.is_deleted = FALSE
);

INSERT INTO product_variant (product, slug, name, is_default)
SELECT p.id, v.slug, v.name, v.is_default
FROM product p
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  ('regular', 'Regular', TRUE),
  ('long',    'Long',    FALSE)
) AS v(slug, name, is_default) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND p.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant pv
    WHERE pv.product = p.id AND pv.slug = v.slug AND pv.is_deleted = FALSE
  );

-- Regular variant attributes
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),          310.0),
  (sp_attr('r_value'),             0.5),
  (sp_attr('thickness_mm'),       60.0),
  (sp_attr('length_mm'),        1830.0),
  (sp_attr('width_mm'),          510.0),
  (sp_attr('packed_volume_ml'),  510.0),
  (sp_attr('packed_length_mm'),  230.0),
  (sp_attr('packed_diameter_mm'), 90.0),
  (sp_attr('baffle_count'),       25.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('astm_tested'),       FALSE),
  (sp_attr('pump_included'),     TRUE),
  (sp_attr('integrated_pump'),   FALSE),
  (sp_attr('included_stuff_sack'), TRUE),
  (sp_attr('repair_kit_included'), TRUE)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),              sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),       sp_enum('insulation_type', 'uninsulated')),
  (sp_attr('shape'),                 sp_enum('shape', 'mummy')),
  (sp_attr('intended_season_rating'),sp_enum('intended_season_rating', 'three-season')),
  (sp_attr('size_class'),            sp_enum('size_class', 'regular')),
  (sp_attr('sex_specific_design'),   sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('fabric_material_text'),    '20D ripstop nylon / TPU laminate'),
  (sp_attr('top_fabric_denier_text'),  '20D'),
  (sp_attr('bottom_fabric_denier_text'), '20D'),
  (sp_attr('valve_type_text'),         'Dual flat valve')
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- Long variant attributes
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),          390.0),
  (sp_attr('r_value'),             0.5),
  (sp_attr('thickness_mm'),       60.0),
  (sp_attr('length_mm'),        1960.0),
  (sp_attr('width_mm'),          530.0),
  (sp_attr('packed_volume_ml'),  640.0),
  (sp_attr('packed_length_mm'),  250.0),
  (sp_attr('packed_diameter_mm'), 95.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND pv.slug = 'long'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),              sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),       sp_enum('insulation_type', 'uninsulated')),
  (sp_attr('shape'),                 sp_enum('shape', 'mummy')),
  (sp_attr('intended_season_rating'),sp_enum('intended_season_rating', 'three-season')),
  (sp_attr('size_class'),            sp_enum('size_class', 'long')),
  (sp_attr('sex_specific_design'),   sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-airflite-ul' AND pv.slug = 'long'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- ─────────────────────────────────────────
-- [EX] WarmSleep Pro  (insulated winter air pad)
-- ─────────────────────────────────────────

INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision)
SELECT
  'ex-warmsleep-pro', '[EX] WarmSleep Pro',
  (SELECT id FROM brand WHERE slug = 'ex-gear'),
  (SELECT id FROM category WHERE slug = 'sleeping-pads'),
  'public', '2023-01-01', 'year'
WHERE NOT EXISTS (
  SELECT 1 FROM product p
  JOIN brand b ON b.id = p.brand
  WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND p.is_deleted = FALSE
);

INSERT INTO product_variant (product, slug, name, is_default)
SELECT p.id, v.slug, v.name, v.is_default
FROM product p
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  ('regular',       'Regular',       TRUE),
  ('regular-wide',  'Regular Wide',  FALSE),
  ('long',          'Long',          FALSE)
) AS v(slug, name, is_default) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND p.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant pv
    WHERE pv.product = p.id AND pv.slug = v.slug AND pv.is_deleted = FALSE
  );

-- Regular
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           480.0),
  (sp_attr('r_value'),              6.0),
  (sp_attr('thickness_mm'),        100.0),
  (sp_attr('length_mm'),          1830.0),
  (sp_attr('width_mm'),            510.0),
  (sp_attr('packed_volume_ml'),    890.0),
  (sp_attr('packed_length_mm'),    250.0),
  (sp_attr('packed_diameter_mm'),  100.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('astm_tested'),         TRUE),
  (sp_attr('pump_included'),       TRUE),
  (sp_attr('integrated_pump'),     FALSE),
  (sp_attr('included_stuff_sack'), TRUE),
  (sp_attr('repair_kit_included'), TRUE)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'synthetic-insulation')),
  (sp_attr('shape'),                  sp_enum('shape', 'mummy')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'winter')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('fabric_material_text'),     '30D ripstop nylon / TPU'),
  (sp_attr('top_fabric_denier_text'),   '30D'),
  (sp_attr('bottom_fabric_denier_text'),'30D'),
  (sp_attr('valve_type_text'),          'WingLock')
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- Regular Wide
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           570.0),
  (sp_attr('r_value'),              6.0),
  (sp_attr('thickness_mm'),        100.0),
  (sp_attr('length_mm'),          1830.0),
  (sp_attr('width_mm'),            640.0),
  (sp_attr('packed_volume_ml'),   1100.0),
  (sp_attr('packed_length_mm'),    265.0),
  (sp_attr('packed_diameter_mm'),  110.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'regular-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'synthetic-insulation')),
  (sp_attr('shape'),                  sp_enum('shape', 'rectangular')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'winter')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular-wide')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'regular-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- Long
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           590.0),
  (sp_attr('r_value'),              6.0),
  (sp_attr('thickness_mm'),        100.0),
  (sp_attr('length_mm'),          1960.0),
  (sp_attr('width_mm'),            510.0),
  (sp_attr('packed_volume_ml'),   1050.0),
  (sp_attr('packed_length_mm'),    265.0),
  (sp_attr('packed_diameter_mm'),  105.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'long'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'synthetic-insulation')),
  (sp_attr('shape'),                  sp_enum('shape', 'mummy')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'winter')),
  (sp_attr('size_class'),             sp_enum('size_class', 'long')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-warmsleep-pro' AND pv.slug = 'long'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- ─────────────────────────────────────────
-- [EX] FoamLite Classic  (closed-cell foam)
-- ─────────────────────────────────────────

INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision)
SELECT
  'ex-foamlite-classic', '[EX] FoamLite Classic',
  (SELECT id FROM brand WHERE slug = 'ex-gear'),
  (SELECT id FROM category WHERE slug = 'sleeping-pads'),
  'public', '2020-01-01', 'year'
WHERE NOT EXISTS (
  SELECT 1 FROM product p
  JOIN brand b ON b.id = p.brand
  WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND p.is_deleted = FALSE
);

INSERT INTO product_variant (product, slug, name, is_default)
SELECT p.id, v.slug, v.name, v.is_default
FROM product p
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  ('regular', 'Regular', TRUE),
  ('small',   'Small',   FALSE)
) AS v(slug, name, is_default) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND p.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant pv
    WHERE pv.product = p.id AND pv.slug = v.slug AND pv.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),    410.0),
  (sp_attr('r_value'),       2.0),
  (sp_attr('thickness_mm'), 20.0),
  (sp_attr('length_mm'),  1830.0),
  (sp_attr('width_mm'),    510.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('astm_tested'),         FALSE),
  (sp_attr('pump_included'),       FALSE),
  (sp_attr('integrated_pump'),     FALSE),
  (sp_attr('included_stuff_sack'), FALSE),
  (sp_attr('repair_kit_included'), FALSE)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'closed-cell-foam-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'foam-core')),
  (sp_attr('shape'),                  sp_enum('shape', 'rectangular')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'three-season')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- Small
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),    280.0),
  (sp_attr('r_value'),       2.0),
  (sp_attr('thickness_mm'), 20.0),
  (sp_attr('length_mm'),  1520.0),
  (sp_attr('width_mm'),    510.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND pv.slug = 'small'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'closed-cell-foam-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'foam-core')),
  (sp_attr('shape'),                  sp_enum('shape', 'rectangular')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'three-season')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-foamlite-classic' AND pv.slug = 'small'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- ─────────────────────────────────────────
-- [EX] SelfRest Comfort  (self-inflating foam core)
-- ─────────────────────────────────────────

INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision)
SELECT
  'ex-selfrest-comfort', '[EX] SelfRest Comfort',
  (SELECT id FROM brand WHERE slug = 'ex-gear'),
  (SELECT id FROM category WHERE slug = 'sleeping-pads'),
  'public', '2022-06-01', 'month'
WHERE NOT EXISTS (
  SELECT 1 FROM product p
  JOIN brand b ON b.id = p.brand
  WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND p.is_deleted = FALSE
);

INSERT INTO product_variant (product, slug, name, is_default)
SELECT p.id, v.slug, v.name, v.is_default
FROM product p
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  ('regular',      'Regular',       TRUE),
  ('regular-wide', 'Regular Wide',  FALSE)
) AS v(slug, name, is_default) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND p.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant pv
    WHERE pv.product = p.id AND pv.slug = v.slug AND pv.is_deleted = FALSE
  );

-- Regular
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           680.0),
  (sp_attr('r_value'),              3.5),
  (sp_attr('thickness_mm'),         50.0),
  (sp_attr('length_mm'),          1830.0),
  (sp_attr('width_mm'),            510.0),
  (sp_attr('packed_volume_ml'),   2800.0),
  (sp_attr('packed_length_mm'),    460.0),
  (sp_attr('packed_diameter_mm'),   90.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('astm_tested'),         FALSE),
  (sp_attr('pump_included'),       FALSE),
  (sp_attr('integrated_pump'),     TRUE),
  (sp_attr('included_stuff_sack'), TRUE),
  (sp_attr('repair_kit_included'), FALSE)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'self-inflating-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'foam-core')),
  (sp_attr('shape'),                  sp_enum('shape', 'rectangular')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'three-season')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('fabric_material_text'),    '75D polyester / PU coated'),
  (sp_attr('top_fabric_denier_text'),  '75D'),
  (sp_attr('bottom_fabric_denier_text'), '75D'),
  (sp_attr('valve_type_text'),         'Twist valve')
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- Regular Wide
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           830.0),
  (sp_attr('r_value'),              3.5),
  (sp_attr('thickness_mm'),         50.0),
  (sp_attr('length_mm'),          1830.0),
  (sp_attr('width_mm'),            640.0),
  (sp_attr('packed_volume_ml'),   3500.0),
  (sp_attr('packed_length_mm'),    460.0),
  (sp_attr('packed_diameter_mm'),  100.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND pv.slug = 'regular-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'self-inflating-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'foam-core')),
  (sp_attr('shape'),                  sp_enum('shape', 'rectangular')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'three-season')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular-wide')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-selfrest-comfort' AND pv.slug = 'regular-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- ─────────────────────────────────────────
-- [EX] DownDream Expedition  (down-insulated air pad)
-- ─────────────────────────────────────────

INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision)
SELECT
  'ex-downdream-exp', '[EX] DownDream Expedition',
  (SELECT id FROM brand WHERE slug = 'ex-gear'),
  (SELECT id FROM category WHERE slug = 'sleeping-pads'),
  'public', '2023-09-01', 'month'
WHERE NOT EXISTS (
  SELECT 1 FROM product p
  JOIN brand b ON b.id = p.brand
  WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND p.is_deleted = FALSE
);

INSERT INTO product_variant (product, slug, name, is_default)
SELECT p.id, v.slug, v.name, v.is_default
FROM product p
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  ('regular',      'Regular',       TRUE),
  ('long-wide',    'Long Wide',     FALSE)
) AS v(slug, name, is_default) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND p.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant pv
    WHERE pv.product = p.id AND pv.slug = v.slug AND pv.is_deleted = FALSE
  );

-- Regular
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           620.0),
  (sp_attr('r_value'),              9.5),
  (sp_attr('thickness_mm'),        130.0),
  (sp_attr('length_mm'),          1830.0),
  (sp_attr('width_mm'),            510.0),
  (sp_attr('packed_volume_ml'),   1200.0),
  (sp_attr('packed_length_mm'),    280.0),
  (sp_attr('packed_diameter_mm'),  115.0),
  (sp_attr('baffle_count'),         16.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('astm_tested'),         TRUE),
  (sp_attr('pump_included'),       TRUE),
  (sp_attr('integrated_pump'),     FALSE),
  (sp_attr('included_stuff_sack'), TRUE),
  (sp_attr('repair_kit_included'), TRUE),
  (sp_attr('can_link_two_pads'),   TRUE)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'down-insulation')),
  (sp_attr('shape'),                  sp_enum('shape', 'mummy')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'expedition')),
  (sp_attr('size_class'),             sp_enum('size_class', 'regular')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('fabric_material_text'),    '20D ripstop nylon / down-proof'),
  (sp_attr('top_fabric_denier_text'),  '20D'),
  (sp_attr('bottom_fabric_denier_text'), '20D'),
  (sp_attr('valve_type_text'),         'Twist flat valve'),
  (sp_attr('notes_text'),              'Linkable to second pad via integrated connector clips')
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'regular'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

-- Long Wide
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('weight_g'),           820.0),
  (sp_attr('r_value'),              9.5),
  (sp_attr('thickness_mm'),        130.0),
  (sp_attr('length_mm'),          1960.0),
  (sp_attr('width_mm'),            640.0),
  (sp_attr('packed_volume_ml'),   1650.0),
  (sp_attr('packed_length_mm'),    300.0),
  (sp_attr('packed_diameter_mm'),  130.0),
  (sp_attr('baffle_count'),         20.0)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'long-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('astm_tested'),         TRUE),
  (sp_attr('pump_included'),       TRUE),
  (sp_attr('integrated_pump'),     FALSE),
  (sp_attr('included_stuff_sack'), TRUE),
  (sp_attr('repair_kit_included'), TRUE),
  (sp_attr('can_link_two_pads'),   TRUE)
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'long-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value)
SELECT pv.id, ca_id, val
FROM product_variant pv
JOIN product p ON p.id = pv.product
JOIN brand b ON b.id = p.brand
JOIN (VALUES
  (sp_attr('pad_type'),               sp_enum('pad_type', 'air-pad')),
  (sp_attr('insulation_type'),        sp_enum('insulation_type', 'down-insulation')),
  (sp_attr('shape'),                  sp_enum('shape', 'rectangular')),
  (sp_attr('intended_season_rating'), sp_enum('intended_season_rating', 'expedition')),
  (sp_attr('size_class'),             sp_enum('size_class', 'long-wide')),
  (sp_attr('sex_specific_design'),    sp_enum('sex_specific_design', 'unisex'))
) AS v(ca_id, val) ON TRUE
WHERE b.slug = 'ex-gear' AND p.slug = 'ex-downdream-exp' AND pv.slug = 'long-wide'
  AND p.is_deleted = FALSE AND pv.is_deleted = FALSE
  AND NOT EXISTS (
    SELECT 1 FROM product_variant_attribute_value x
    WHERE x.product_variant = pv.id AND x.category_attribute = v.ca_id AND x.is_deleted = FALSE
  );