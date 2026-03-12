-- ================================================================================
-- SEED DATA FOR Summit Spec
-- ================================================================================
-- This file contains comprehensive sample data for the hiking gear catalog.
-- Run with: psql $DATABASE_URL -f db/scripts/seed_sample_data.sql

\echo '<1 Starting seed data insertion...'

-- Helper: look up a category_attribute id by category slug + attribute slug
CREATE OR REPLACE FUNCTION cat_attr(cat_slug TEXT, attr_slug TEXT) RETURNS BIGINT AS $$
  SELECT ca.id FROM category_attribute ca
  JOIN category c ON c.id = ca.category
  JOIN attribute a ON a.id = ca.attribute
  WHERE c.slug = cat_slug AND a.slug = attr_slug
    AND ca.is_deleted = FALSE;
$$ LANGUAGE SQL;

-- ================================================================================
-- USERS
-- ================================================================================
\echo '=d Inserting users...'

INSERT INTO "user" (username, email, password_hash) VALUES
('alice_hiker', 'alice@example.com', '$2b$12$WQwHgle1ICGafFJxv50ZKuoQ7utj2rHF7XmY46TVsxpLHVz0T/D6u'), -- password: password123
('bob_trails', 'bob@example.com', '$2b$12$WQwHgle1ICGafFJxv50ZKuoQ7utj2rHF7XmY46TVsxpLHVz0T/D6u'),
('charlie_alpine', 'charlie@example.com', '$2b$12$WQwHgle1ICGafFJxv50ZKuoQ7utj2rHF7XmY46TVsxpLHVz0T/D6u'),
('dana_ultra', 'dana@example.com', '$2b$12$WQwHgle1ICGafFJxv50ZKuoQ7utj2rHF7XmY46TVsxpLHVz0T/D6u'),
('erik_backpack', 'erik@example.com', '$2b$12$WQwHgle1ICGafFJxv50ZKuoQ7utj2rHF7XmY46TVsxpLHVz0T/D6u');

-- ================================================================================
-- ATTRIBUTES
-- ================================================================================
\echo '<�  Inserting attributes...'

INSERT INTO attribute (slug, name, description, type, number_unit) VALUES
-- Weight attributes
('weight', 'Weight', 'Total weight of the item', 'number', 'weight_g'),
('packed-weight', 'Packed Weight', 'Weight when packed', 'number', 'weight_g'),
('min-weight', 'Minimum Weight', 'Weight without optional accessories', 'number', 'weight_g'),

-- Dimension attributes
('length', 'Length', 'Overall length', 'number', 'length_mm'),
('width', 'Width', 'Overall width', 'number', 'length_mm'),
('thickness', 'Thickness', 'Thickness when inflated or in use', 'number', 'length_mm'),
('packed-length', 'Packed Length', 'Length when packed', 'number', 'length_mm'),
('packed-diameter', 'Packed Diameter', 'Diameter when packed', 'number', 'length_mm'),
('torso-length', 'Torso Length', 'Length of torso section for packs', 'number', 'length_mm'),

-- Volume attributes
('capacity', 'Capacity', 'Volume capacity', 'number', 'volume_ml'),
('packed-volume', 'Packed Volume', 'Volume when packed', 'number', 'volume_ml'),

-- Temperature ratings
('temp-rating', 'Temperature Rating', 'Comfort temperature rating in Celsius', 'number', 'temperature_c'),
('temp-limit', 'Temperature Limit', 'Lower limit temperature in Celsius', 'number', 'temperature_c'),
('r-value', 'R-Value', 'Thermal resistance value', 'number', 'float'),

-- Boolean attributes
('insulated', 'Insulated', 'Whether item has insulation', 'bool', 'NA'),
('waterproof', 'Waterproof', 'Whether item is waterproof', 'bool', 'NA'),
('ultralight', 'Ultralight', 'Designed for minimal weight', 'bool', 'NA'),
('women-specific', 'Women''s Specific', 'Designed specifically for women', 'bool', 'NA'),
('stuff-sack-included', 'Stuff Sack Included', 'Comes with stuff sack', 'bool', 'NA'),
('repair-kit-included', 'Repair Kit Included', 'Includes repair kit', 'bool', 'NA'),

-- Enum attributes
('material', 'Material', 'Primary material construction', 'enum_list', 'NA'),
('pad-type', 'Pad Type', 'Type of sleeping pad', 'enum_list', 'NA'),
('valve-type', 'Valve Type', 'Type of inflation valve', 'enum_list', 'NA'),
('pack-suspension', 'Pack Suspension', 'Type of pack suspension system', 'enum_list', 'NA'),
('frame-type', 'Frame Type', 'Type of pack frame', 'enum_list', 'NA'),
('insulation-type', 'Insulation Type', 'Type of insulation material', 'enum_list', 'NA'),
('color', 'Color', 'Available colors', 'enum_list', 'NA'),
('shape', 'Shape', 'Shape profile', 'enum_list', 'NA'),

-- String attributes
('recommended-use', 'Recommended Use', 'Suggested use cases', 'string', 'NA'),
('fabric', 'Fabric', 'Fabric specifications', 'string', 'NA'),
('warranty', 'Warranty', 'Warranty information', 'string', 'NA');

-- ================================================================================
-- ENUM ATTRIBUTE VALUES
-- ================================================================================
\echo '=� Inserting enum attribute values...'

-- Material enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'material'), 'nylon', 'Nylon', 1),
((SELECT id FROM attribute WHERE slug = 'material'), 'polyester', 'Polyester', 2),
((SELECT id FROM attribute WHERE slug = 'material'), 'tpu', 'TPU', 3),
((SELECT id FROM attribute WHERE slug = 'material'), 'ripstop-nylon', 'Ripstop Nylon', 4),
((SELECT id FROM attribute WHERE slug = 'material'), 'dyneema', 'Dyneema', 5),
((SELECT id FROM attribute WHERE slug = 'material'), 'silnylon', 'Silnylon', 6),
((SELECT id FROM attribute WHERE slug = 'material'), 'cordura', 'Cordura', 7);

-- Pad Type enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'pad-type'), 'air', 'Air', 1),
((SELECT id FROM attribute WHERE slug = 'pad-type'), 'self-inflating', 'Self-Inflating', 2),
((SELECT id FROM attribute WHERE slug = 'pad-type'), 'closed-cell-foam', 'Closed-Cell Foam', 3),
((SELECT id FROM attribute WHERE slug = 'pad-type'), 'hybrid', 'Hybrid', 4);

-- Valve Type enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'valve-type'), 'winglock', 'WingLock', 1),
((SELECT id FROM attribute WHERE slug = 'valve-type'), 'twist', 'Twist', 2),
((SELECT id FROM attribute WHERE slug = 'valve-type'), 'push-pull', 'Push-Pull', 3),
((SELECT id FROM attribute WHERE slug = 'valve-type'), 'flat', 'Flat', 4),
((SELECT id FROM attribute WHERE slug = 'valve-type'), 'double-lock', 'Double Lock', 5);

-- Pack Suspension enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'pack-suspension'), 'frameless', 'Frameless', 1),
((SELECT id FROM attribute WHERE slug = 'pack-suspension'), 'internal-frame', 'Internal Frame', 2),
((SELECT id FROM attribute WHERE slug = 'pack-suspension'), 'external-frame', 'External Frame', 3),
((SELECT id FROM attribute WHERE slug = 'pack-suspension'), 'hybrid', 'Hybrid', 4);

-- Frame Type enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'frame-type'), 'none', 'None', 1),
((SELECT id FROM attribute WHERE slug = 'frame-type'), 'aluminum', 'Aluminum', 2),
((SELECT id FROM attribute WHERE slug = 'frame-type'), 'carbon-fiber', 'Carbon Fiber', 3),
((SELECT id FROM attribute WHERE slug = 'frame-type'), 'plastic-frame-sheet', 'Plastic Frame Sheet', 4),
((SELECT id FROM attribute WHERE slug = 'frame-type'), 'wire-frame', 'Wire Frame', 5);

-- Insulation Type enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'insulation-type'), 'down-850', '850 Fill Down', 1),
((SELECT id FROM attribute WHERE slug = 'insulation-type'), 'down-900', '900 Fill Down', 2),
((SELECT id FROM attribute WHERE slug = 'insulation-type'), 'synthetic', 'Synthetic', 3),
((SELECT id FROM attribute WHERE slug = 'insulation-type'), 'primaloft', 'PrimaLoft', 4),
((SELECT id FROM attribute WHERE slug = 'insulation-type'), 'thermolite', 'Thermolite', 5),
((SELECT id FROM attribute WHERE slug = 'insulation-type'), 'none', 'None', 6);

-- Color enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'color'), 'orange', 'Orange', 1),
((SELECT id FROM attribute WHERE slug = 'color'), 'blue', 'Blue', 2),
((SELECT id FROM attribute WHERE slug = 'color'), 'green', 'Green', 3),
((SELECT id FROM attribute WHERE slug = 'color'), 'red', 'Red', 4),
((SELECT id FROM attribute WHERE slug = 'color'), 'yellow', 'Yellow', 5),
((SELECT id FROM attribute WHERE slug = 'color'), 'grey', 'Grey', 6),
((SELECT id FROM attribute WHERE slug = 'color'), 'black', 'Black', 7),
((SELECT id FROM attribute WHERE slug = 'color'), 'purple', 'Purple', 8);

-- Shape enum values
INSERT INTO enum_attribute_vals (attribute, slug, name, display_order) VALUES
((SELECT id FROM attribute WHERE slug = 'shape'), 'rectangular', 'Rectangular', 1),
((SELECT id FROM attribute WHERE slug = 'shape'), 'mummy', 'Mummy', 2),
((SELECT id FROM attribute WHERE slug = 'shape'), 'semi-rectangular', 'Semi-Rectangular', 3),
((SELECT id FROM attribute WHERE slug = 'shape'), 'tapered', 'Tapered', 4);

-- ================================================================================
-- BRANDS
-- ================================================================================
\echo '<� Inserting brands...'

INSERT INTO brand (slug, name, country) VALUES
('thermarest', 'Therm-a-Rest', 'US'),
('nemo', 'NEMO Equipment', 'US'),
('sea-to-summit', 'Sea to Summit', 'AU'),
('big-agnes', 'Big Agnes', 'US'),
('rei', 'REI Co-op', 'US'),
('exped', 'Exped', 'US'),
('klymit', 'Klymit', 'US'),
('enlightened-equipment', 'Enlightened Equipment', 'US'),
('zpacks', 'Zpacks', 'US'),
('gossamer-gear', 'Gossamer Gear', 'US'),
('hyperlite-mountain-gear', 'Hyperlite Mountain Gear', 'US'),
('osprey', 'Osprey', 'US'),
('gregory', 'Gregory', 'US'),
('granite-gear', 'Granite Gear', 'US'),
('western-mountaineering', 'Western Mountaineering', 'US'),
('feathered-friends', 'Feathered Friends', 'US'),
('msr', 'MSR', 'US');

-- ================================================================================
-- CATEGORIES
-- ================================================================================
\echo '=� Inserting categories...'

-- Parent categories (no parent_category)
INSERT INTO category (slug, name, description) VALUES
('sleep-system', 'Sleep System', 'Everything needed for a good night in the backcountry'),
('carry', 'Carry', 'Packs, bags, and storage for hauling gear'),
('shelter', 'Shelter', 'Tents, tarps, and bivouacs for protection from the elements');

-- Child categories referencing parent categories
INSERT INTO category (slug, name, description, parent_category) VALUES
('sleeping-pads', 'Sleeping Pads', 'Insulated and uninsulated sleeping pads for camping and backpacking',
 (SELECT id FROM category WHERE slug = 'sleep-system')),
('sleeping-bags', 'Sleeping Bags', 'Down and synthetic sleeping bags for various temperature ratings',
 (SELECT id FROM category WHERE slug = 'sleep-system')),
('quilts', 'Quilts', 'Ultralight quilts for backpacking',
 (SELECT id FROM category WHERE slug = 'sleep-system')),
('pillows', 'Pillows', 'Camping and backpacking pillows',
 (SELECT id FROM category WHERE slug = 'sleep-system')),
('backpacks', 'Backpacks', 'Hiking and backpacking packs in various capacities',
 (SELECT id FROM category WHERE slug = 'carry')),
('stuff-sacks', 'Stuff Sacks', 'Storage and organization bags',
 (SELECT id FROM category WHERE slug = 'carry')),
('tents', 'Tents', 'Backpacking tents and shelters',
 (SELECT id FROM category WHERE slug = 'shelter'));

-- ================================================================================
-- CATEGORY ATTRIBUTES
-- Inheritance rule: child categories cannot repeat attributes defined on a parent.
--   sleep-system → sleeping-pads, sleeping-bags, quilts, pillows
--   carry        → backpacks, stuff-sacks
--   shelter      → tents
-- ================================================================================

-- Parent: sleep-system
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'sleep-system'), id FROM attribute WHERE slug IN
  ('weight', 'ultralight', 'stuff-sack-included', 'repair-kit-included');

-- Parent: carry
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'carry'), id FROM attribute WHERE slug IN
  ('weight', 'capacity', 'ultralight', 'waterproof');

-- Parent: shelter
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'shelter'), id FROM attribute WHERE slug IN
  ('weight', 'packed-weight', 'packed-length', 'packed-diameter', 'waterproof', 'ultralight', 'repair-kit-included');

-- Child: sleeping-pads (parent: sleep-system — cannot repeat weight, ultralight, stuff-sack-included, repair-kit-included)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'sleeping-pads'), id FROM attribute WHERE slug IN
  ('length', 'width', 'thickness', 'r-value', 'temp-rating', 'temp-limit', 'insulated', 'pad-type', 'valve-type',
   'packed-length', 'packed-diameter', 'material', 'fabric', 'warranty', 'recommended-use', 'color', 'shape');

-- Child: sleeping-bags (parent: sleep-system)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'sleeping-bags'), id FROM attribute WHERE slug IN
  ('temp-rating', 'temp-limit', 'insulated', 'insulation-type', 'shape', 'women-specific',
   'fabric', 'warranty', 'recommended-use', 'color');

-- Child: quilts (parent: sleep-system)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'quilts'), id FROM attribute WHERE slug IN
  ('temp-rating', 'temp-limit', 'insulation-type', 'women-specific', 'fabric', 'warranty', 'recommended-use', 'color');

-- Child: pillows (parent: sleep-system)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'pillows'), id FROM attribute WHERE slug IN
  ('packed-volume', 'warranty', 'recommended-use', 'color');

-- Child: backpacks (parent: carry — cannot repeat weight, capacity, ultralight, waterproof)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'backpacks'), id FROM attribute WHERE slug IN
  ('pack-suspension', 'frame-type', 'material', 'torso-length', 'warranty', 'recommended-use', 'color');

-- Child: stuff-sacks (parent: carry)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'stuff-sacks'), id FROM attribute WHERE slug IN
  ('material', 'warranty', 'recommended-use', 'color');

-- Child: tents (parent: shelter — cannot repeat weight, packed-weight, packed-length, packed-diameter, waterproof, ultralight, repair-kit-included)
INSERT INTO category_attribute (category, attribute) SELECT
  (SELECT id FROM category WHERE slug = 'tents'), id FROM attribute WHERE slug IN
  ('material', 'fabric', 'warranty', 'recommended-use', 'color');

-- ================================================================================
-- PRODUCTS - THERM-A-REST SLEEPING PADS
-- ================================================================================
\echo '=�  Inserting Therm-a-Rest products...'

-- NeoAir XLite NXT
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('neoair-xlite-nxt', 'NeoAir XLite NXT',
 (SELECT id FROM brand WHERE slug = 'thermarest'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default, release_at, release_precision) VALUES
((SELECT id FROM product WHERE slug = 'neoair-xlite-nxt'), 'regular', 'Regular', true, '2022-01-01', 'year'),
((SELECT id FROM product WHERE slug = 'neoair-xlite-nxt'), 'regular-wide', 'Regular Wide', false, '2022-01-01', 'year'),
((SELECT id FROM product WHERE slug = 'neoair-xlite-nxt'), 'large', 'Large', false, '2022-01-01', 'year'),
((SELECT id FROM product WHERE slug = 'neoair-xlite-nxt'), 'small', 'Small', false, '2022-01-01', 'year');

-- NeoAir XTherm NXT
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('neoair-xtherm-nxt', 'NeoAir XTherm NXT',
 (SELECT id FROM brand WHERE slug = 'thermarest'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt'), 'regular-wide', 'Regular Wide', false),
((SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt'), 'large', 'Large', false),
((SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt'), 'max', 'Max', false);

-- NeoAir UberLite
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('neoair-uberlite', 'NeoAir UberLite',
 (SELECT id FROM brand WHERE slug = 'thermarest'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2019-03-01', 'month');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'neoair-uberlite'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'neoair-uberlite'), 'large', 'Large', false),
((SELECT id FROM product WHERE slug = 'neoair-uberlite'), 'small', 'Small', false);

-- ProLite Plus
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('prolite-plus', 'ProLite Plus',
 (SELECT id FROM brand WHERE slug = 'thermarest'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'prolite-plus'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'prolite-plus'), 'regular-wide', 'Regular Wide', false),
((SELECT id FROM product WHERE slug = 'prolite-plus'), 'large', 'Large', false);

-- Z Lite Sol
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('z-lite-sol', 'Z Lite Sol',
 (SELECT id FROM brand WHERE slug = 'thermarest'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2016-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'z-lite-sol'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'z-lite-sol'), 'small', 'Small', false);

-- ================================================================================
-- PRODUCTS - NEMO SLEEPING PADS
-- ================================================================================
\echo '=�  Inserting NEMO products...'

-- Tensor Insulated
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('tensor-insulated', 'Tensor Insulated',
 (SELECT id FROM brand WHERE slug = 'nemo'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'tensor-insulated'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'tensor-insulated'), 'regular-wide', 'Regular Wide', false),
((SELECT id FROM product WHERE slug = 'tensor-insulated'), 'long-wide', 'Long Wide', false);

-- Tensor All-Season
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('tensor-all-season', 'Tensor All-Season',
 (SELECT id FROM brand WHERE slug = 'nemo'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2023-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'tensor-all-season'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'tensor-all-season'), 'regular-wide', 'Regular Wide', false),
((SELECT id FROM product WHERE slug = 'tensor-all-season'), 'long-wide', 'Long Wide', false);

-- Switchback
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('switchback', 'Switchback',
 (SELECT id FROM brand WHERE slug = 'nemo'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2019-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'switchback'), 'regular', 'Regular', true);

-- ================================================================================
-- PRODUCTS - SEA TO SUMMIT SLEEPING PADS
-- ================================================================================
\echo '=�  Inserting Sea to Summit products...'

-- Ether Light XT Insulated
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('ether-light-xt-insulated', 'Ether Light XT Insulated',
 (SELECT id FROM brand WHERE slug = 'sea-to-summit'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'ether-light-xt-insulated'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'ether-light-xt-insulated'), 'regular-wide', 'Regular Wide', false),
((SELECT id FROM product WHERE slug = 'ether-light-xt-insulated'), 'large', 'Large', false);

-- Ultralight Insulated
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('ultralight-insulated', 'Ultralight Insulated',
 (SELECT id FROM brand WHERE slug = 'sea-to-summit'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'ultralight-insulated'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'ultralight-insulated'), 'large', 'Large', false);

-- ================================================================================
-- PRODUCTS - BIG AGNES SLEEPING PADS
-- ================================================================================
\echo '=�  Inserting Big Agnes products...'

-- Rapide SL Insulated
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('rapide-sl-insulated', 'Rapide SL Insulated',
 (SELECT id FROM brand WHERE slug = 'big-agnes'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'rapide-sl-insulated'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'rapide-sl-insulated'), 'long', 'Long', false),
((SELECT id FROM product WHERE slug = 'rapide-sl-insulated'), 'regular-wide', 'Regular Wide', false);

-- ================================================================================
-- VARIANT ATTRIBUTES - NEOAIR XLITE NXT
-- ================================================================================
\echo '�  Inserting NeoAir XLite NXT attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 340),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 4.5),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'packed-length'), 230),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'packed-diameter'), 100);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleep-system', 'stuff-sack-included'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleep-system', 'repair-kit-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'air')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'valve-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'valve-type') AND slug = 'winglock')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'orange')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'shape'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'shape') AND slug = 'mummy'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'fabric'), '30D ripstop nylon with Triangular Core Matrix'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'warranty'), 'Limited Lifetime'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'recommended-use'), 'Three-season backpacking, ultralight camping');

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 425),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 4.5);

-- Large variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 430),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'width'), 635),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'r-value'), 4.5);

-- Small variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'small'),
 cat_attr('sleep-system', 'weight'), 230),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'small'),
 cat_attr('sleeping-pads', 'length'), 1190),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'small'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'small'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xlite-nxt') AND slug = 'small'),
 cat_attr('sleeping-pads', 'r-value'), 4.5);

-- ================================================================================
-- VARIANT ATTRIBUTES - NEOAIR XTHERM NXT
-- ================================================================================
\echo '�  Inserting NeoAir XTherm NXT attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 430),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 7.3),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'temp-rating'), -32);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'air')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'yellow'));

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 570),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 7.3);

-- Large variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 570),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'large'),
 cat_attr('sleeping-pads', 'r-value'), 7.3);

-- Max variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'max'),
 cat_attr('sleep-system', 'weight'), 680),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'max'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'max'),
 cat_attr('sleeping-pads', 'width'), 760),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt') AND slug = 'max'),
 cat_attr('sleeping-pads', 'r-value'), 7.3);

-- ================================================================================
-- VARIANT ATTRIBUTES - NEOAIR UBERLITE
-- ================================================================================
\echo '�  Inserting NeoAir UberLite attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 250),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 64),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 2.3);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), false),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'recommended-use'), 'Summer backpacking, gram-counting ultralight trips');

-- Large variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 340),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'large'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'large'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'large'),
 cat_attr('sleeping-pads', 'r-value'), 2.3);

-- Small variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'small'),
 cat_attr('sleep-system', 'weight'), 170),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'small'),
 cat_attr('sleeping-pads', 'length'), 1190),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'small'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'neoair-uberlite') AND slug = 'small'),
 cat_attr('sleeping-pads', 'r-value'), 2.3);

-- ================================================================================
-- VARIANT ATTRIBUTES - PROLITE PLUS
-- ================================================================================
\echo '�  Inserting ProLite Plus attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 64),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 3.4);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'self-inflating'));

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 710),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 3.4);

-- Large variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 660),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'large'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'large'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'prolite-plus') AND slug = 'large'),
 cat_attr('sleeping-pads', 'r-value'), 3.4);

-- ================================================================================
-- VARIANT ATTRIBUTES - Z LITE SOL
-- ================================================================================
\echo '�  Inserting Z Lite Sol attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 410),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 20),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 2.0);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'closed-cell-foam')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'yellow'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'recommended-use'), 'Ultralight backpacking, backup pad, sit pad');

-- Small variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'small'),
 cat_attr('sleep-system', 'weight'), 290),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'small'),
 cat_attr('sleeping-pads', 'length'), 1300),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'small'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'z-lite-sol') AND slug = 'small'),
 cat_attr('sleeping-pads', 'r-value'), 2.0);

-- ================================================================================
-- VARIANT ATTRIBUTES - NEMO TENSOR INSULATED
-- ================================================================================
\echo '�  Inserting NEMO Tensor Insulated attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 425),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 3.5);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'stuff-sack-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'air')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'valve-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'valve-type') AND slug = 'flat')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'green'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'fabric'), '20D polyester with Spaceframe baffles'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'warranty'), 'Limited Lifetime');

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 540),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 3.5);

-- Long Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'long-wide'),
 cat_attr('sleep-system', 'weight'), 600),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'long-wide'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'long-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-insulated') AND slug = 'long-wide'),
 cat_attr('sleeping-pads', 'r-value'), 3.5);

-- ================================================================================
-- VARIANT ATTRIBUTES - NEMO TENSOR ALL-SEASON
-- ================================================================================
\echo '�  Inserting NEMO Tensor All-Season attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 76),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 5.4);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'red'));

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 625),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 5.4);

-- Long Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'long-wide'),
 cat_attr('sleep-system', 'weight'), 710),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'long-wide'),
 cat_attr('sleeping-pads', 'length'), 1960),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'long-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'tensor-all-season') AND slug = 'long-wide'),
 cat_attr('sleeping-pads', 'r-value'), 5.4);

-- ================================================================================
-- VARIANT ATTRIBUTES - NEMO SWITCHBACK
-- ================================================================================
\echo '�  Inserting NEMO Switchback attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 410),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 19),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 2.0);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'closed-cell-foam')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'switchback') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'grey'));

-- ================================================================================
-- VARIANT ATTRIBUTES - SEA TO SUMMIT ETHER LIGHT XT
-- ================================================================================
\echo '�  Inserting Sea to Summit Ether Light XT attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 460),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 550),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 100),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 3.2);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'repair-kit-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'pad-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pad-type') AND slug = 'air')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'valve-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'valve-type') AND slug = 'double-lock')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'blue'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'fabric'), '30D/40D nylon with Air Sprung Cells'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'warranty'), 'Limited Lifetime');

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 590),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 3.2);

-- Large variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 545),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'large'),
 cat_attr('sleeping-pads', 'length'), 1980),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'large'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ether-light-xt-insulated') AND slug = 'large'),
 cat_attr('sleeping-pads', 'r-value'), 3.2);

-- ================================================================================
-- VARIANT ATTRIBUTES - SEA TO SUMMIT ULTRALIGHT INSULATED
-- ================================================================================
\echo '�  Inserting Sea to Summit Ultralight Insulated attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 490),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 550),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 50),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 2.6);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

-- Large variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 585),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'large'),
 cat_attr('sleeping-pads', 'length'), 1980),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'large'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-insulated') AND slug = 'large'),
 cat_attr('sleeping-pads', 'r-value'), 2.6);

-- ================================================================================
-- VARIANT ATTRIBUTES - BIG AGNES RAPIDE SL
-- ================================================================================
\echo '�  Inserting Big Agnes Rapide SL attributes...'

-- Regular variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 397),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'width'), 570),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'thickness'), 89),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'r-value'), 4.8);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular'),
 cat_attr('sleeping-pads', 'color'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'color') AND slug = 'grey'));

-- Long variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'long'),
 cat_attr('sleep-system', 'weight'), 454),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'long'),
 cat_attr('sleeping-pads', 'length'), 1980),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'long'),
 cat_attr('sleeping-pads', 'width'), 570),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'long'),
 cat_attr('sleeping-pads', 'r-value'), 4.8);

-- Regular Wide variant
INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular-wide'),
 cat_attr('sleep-system', 'weight'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'length'), 1830),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'width'), 640),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'rapide-sl-insulated') AND slug = 'regular-wide'),
 cat_attr('sleeping-pads', 'r-value'), 4.8);

-- ================================================================================
-- PRODUCTS - SLEEPING BAGS
-- ================================================================================

-- Western Mountaineering UltraLite
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('ultralite', 'UltraLite',
 (SELECT id FROM brand WHERE slug = 'western-mountaineering'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'ultralite'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'ultralite'), 'long', 'Long', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 652),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'temp-rating'), -7),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'long'),
 cat_attr('sleep-system', 'weight'), 737),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'long'),
 cat_attr('sleeping-bags', 'temp-rating'), -7);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-850')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'shape'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'shape') AND slug = 'mummy'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'recommended-use'), 'Three-season backpacking'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralite') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'warranty'), 'Limited Lifetime');

-- Feathered Friends Hummingbird UL
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('hummingbird-ul', 'Hummingbird UL',
 (SELECT id FROM brand WHERE slug = 'feathered-friends'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'hummingbird-ul'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'hummingbird-ul'), 'long', 'Long', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 482),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'temp-rating'), 4),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'long'),
 cat_attr('sleep-system', 'weight'), 539),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'long'),
 cat_attr('sleeping-bags', 'temp-rating'), 4);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-900')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hummingbird-ul') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'shape'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'shape') AND slug = 'mummy'));

-- ================================================================================
-- PRODUCTS - QUILTS
-- ================================================================================

-- Enlightened Equipment Revelation
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('revelation', 'Revelation',
 (SELECT id FROM brand WHERE slug = 'enlightened-equipment'),
 (SELECT id FROM category WHERE slug = 'quilts'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'revelation'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'revelation'), 'wide', 'Wide', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 369),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('quilts', 'temp-rating'), -9),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'wide'),
 cat_attr('sleep-system', 'weight'), 425),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'wide'),
 cat_attr('quilts', 'temp-rating'), -9);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('sleep-system', 'stuff-sack-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('quilts', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-850'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('quilts', 'recommended-use'), 'Three-season ultralight backpacking'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'revelation') AND slug = 'regular'),
 cat_attr('quilts', 'fabric'), '10D ripstop nylon inner and outer');

-- Zpacks Solo Quilt
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('solo-quilt', 'Solo Quilt',
 (SELECT id FROM brand WHERE slug = 'zpacks'),
 (SELECT id FROM category WHERE slug = 'quilts'),
 'public', '2023-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'solo-quilt'), 'regular', 'Regular', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'solo-quilt') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 284),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'solo-quilt') AND slug = 'regular'),
 cat_attr('quilts', 'temp-rating'), 4);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'solo-quilt') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'solo-quilt') AND slug = 'regular'),
 cat_attr('quilts', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-900'));

-- ================================================================================
-- PRODUCTS - BACKPACKS
-- ================================================================================

-- Osprey Atmos AG 65
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('atmos-ag-65', 'Atmos AG 65',
 (SELECT id FROM brand WHERE slug = 'osprey'),
 (SELECT id FROM category WHERE slug = 'backpacks'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'atmos-ag-65'), 'small-medium', 'S/M', true),
((SELECT id FROM product WHERE slug = 'atmos-ag-65'), 'medium-large', 'M/L', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('carry', 'weight'), 2180),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('carry', 'capacity'), 65000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'medium-large'),
 cat_attr('carry', 'weight'), 2250),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'medium-large'),
 cat_attr('carry', 'capacity'), 68000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('carry', 'waterproof'), false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('backpacks', 'pack-suspension'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pack-suspension') AND slug = 'internal-frame')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('backpacks', 'frame-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'frame-type') AND slug = 'aluminum')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('backpacks', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'nylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('backpacks', 'recommended-use'), 'Multi-day backpacking and trekking'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'atmos-ag-65') AND slug = 'small-medium'),
 cat_attr('backpacks', 'warranty'), 'Limited Lifetime');

-- Gossamer Gear Gorilla
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('gorilla', 'Gorilla',
 (SELECT id FROM brand WHERE slug = 'gossamer-gear'),
 (SELECT id FROM category WHERE slug = 'backpacks'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'gorilla'), 'regular', 'Regular', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('carry', 'weight'), 567),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('carry', 'capacity'), 40000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('carry', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('carry', 'waterproof'), false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('backpacks', 'pack-suspension'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pack-suspension') AND slug = 'frameless')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('backpacks', 'frame-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'frame-type') AND slug = 'none'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'gorilla') AND slug = 'regular'),
 cat_attr('backpacks', 'recommended-use'), 'Ultralight backpacking and thru-hiking');

-- Hyperlite Mountain Gear Southwest 3400
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('southwest-3400', 'Southwest 3400',
 (SELECT id FROM brand WHERE slug = 'hyperlite-mountain-gear'),
 (SELECT id FROM category WHERE slug = 'backpacks'),
 'public', '2023-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'southwest-3400'), 'medium', 'Medium', true),
((SELECT id FROM product WHERE slug = 'southwest-3400'), 'large', 'Large', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('carry', 'weight'), 737),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('carry', 'capacity'), 55000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'large'),
 cat_attr('carry', 'weight'), 794),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'large'),
 cat_attr('carry', 'capacity'), 59000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('carry', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('carry', 'waterproof'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('backpacks', 'pack-suspension'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pack-suspension') AND slug = 'internal-frame')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('backpacks', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'dyneema'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('backpacks', 'recommended-use'), 'Alpine climbing, ultralight backpacking'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'southwest-3400') AND slug = 'medium'),
 cat_attr('backpacks', 'warranty'), 'Limited Lifetime');

-- ================================================================================
-- PRODUCTS - MORE SLEEPING BAGS
-- ================================================================================

-- NEMO Disco 15
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('disco-15', 'Disco 15',
 (SELECT id FROM brand WHERE slug = 'nemo'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'disco-15'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'disco-15'), 'long', 'Long', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 935),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'temp-rating'), -9),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'long'),
 cat_attr('sleep-system', 'weight'), 1021),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'long'),
 cat_attr('sleeping-bags', 'temp-rating'), -9);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulated'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-850')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'shape'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'shape') AND slug = 'semi-rectangular'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'recommended-use'), 'Three-season backpacking, versatile shoulder-season use'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'disco-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'warranty'), 'Limited Lifetime');

-- REI Co-op Magma 15
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('magma-15', 'Magma 15',
 (SELECT id FROM brand WHERE slug = 'rei'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags'),
 'public', '2023-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'magma-15'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'magma-15'), 'long', 'Long', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 765),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'temp-rating'), -9),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'long'),
 cat_attr('sleep-system', 'weight'), 850),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'long'),
 cat_attr('sleeping-bags', 'temp-rating'), -9);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulated'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-850')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'shape'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'shape') AND slug = 'mummy'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'recommended-use'), 'Three-season backpacking'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'magma-15') AND slug = 'regular'),
 cat_attr('sleeping-bags', 'warranty'), '1 Year');

-- ================================================================================
-- PRODUCTS - MORE QUILTS
-- ================================================================================

-- Enlightened Equipment Enigma
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('enigma', 'Enigma',
 (SELECT id FROM brand WHERE slug = 'enlightened-equipment'),
 (SELECT id FROM category WHERE slug = 'quilts'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'enigma'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'enigma'), 'wide', 'Wide', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 312),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('quilts', 'temp-rating'), -7),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'wide'),
 cat_attr('sleep-system', 'weight'), 369),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'wide'),
 cat_attr('quilts', 'temp-rating'), -7);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('quilts', 'women-specific'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('quilts', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-850'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('quilts', 'fabric'), '10D ripstop nylon inner, 15D outer'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'enigma') AND slug = 'regular'),
 cat_attr('quilts', 'recommended-use'), 'Three-season ultralight backpacking, women-specific fit');

-- Zpacks Ventum 20
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('ventum-20', 'Ventum 20',
 (SELECT id FROM brand WHERE slug = 'zpacks'),
 (SELECT id FROM category WHERE slug = 'quilts'),
 'public', '2023-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'ventum-20'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'ventum-20'), 'long', 'Long', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 255),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('quilts', 'temp-rating'), -7),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'long'),
 cat_attr('sleep-system', 'weight'), 284),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'long'),
 cat_attr('quilts', 'temp-rating'), -7);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('sleep-system', 'stuff-sack-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('quilts', 'insulation-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'insulation-type') AND slug = 'down-900'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('quilts', 'fabric'), 'Dyneema Composite Fabric shell'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ventum-20') AND slug = 'regular'),
 cat_attr('quilts', 'recommended-use'), 'Ultralight backpacking, thru-hiking');

-- ================================================================================
-- PRODUCTS - MORE BACKPACKS
-- ================================================================================

-- Gregory Baltoro 65
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('baltoro-65', 'Baltoro 65',
 (SELECT id FROM brand WHERE slug = 'gregory'),
 (SELECT id FROM category WHERE slug = 'backpacks'),
 'public', '2022-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'baltoro-65'), 'small', 'S', true),
((SELECT id FROM product WHERE slug = 'baltoro-65'), 'medium', 'M', false),
((SELECT id FROM product WHERE slug = 'baltoro-65'), 'large', 'L', false),
((SELECT id FROM product WHERE slug = 'baltoro-65'), 'extra-large', 'XL', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'small'),
 cat_attr('carry', 'weight'), 2010),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'small'),
 cat_attr('carry', 'capacity'), 65000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'medium'),
 cat_attr('carry', 'weight'), 2070),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'medium'),
 cat_attr('carry', 'capacity'), 67000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'large'),
 cat_attr('carry', 'weight'), 2120),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'large'),
 cat_attr('carry', 'capacity'), 70000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'extra-large'),
 cat_attr('carry', 'weight'), 2180),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'extra-large'),
 cat_attr('carry', 'capacity'), 73000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'small'),
 cat_attr('backpacks', 'pack-suspension'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pack-suspension') AND slug = 'internal-frame')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'small'),
 cat_attr('backpacks', 'frame-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'frame-type') AND slug = 'aluminum'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'small'),
 cat_attr('backpacks', 'recommended-use'), 'Multi-day backpacking, heavy loads'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'baltoro-65') AND slug = 'small'),
 cat_attr('backpacks', 'warranty'), 'Limited Lifetime');

-- Granite Gear Crown2 60
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('crown2-60', 'Crown2 60',
 (SELECT id FROM brand WHERE slug = 'granite-gear'),
 (SELECT id FROM category WHERE slug = 'backpacks'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'crown2-60'), 'extra-small-small', 'XS/S', true),
((SELECT id FROM product WHERE slug = 'crown2-60'), 'small-medium', 'S/M', false),
((SELECT id FROM product WHERE slug = 'crown2-60'), 'medium-large', 'M/L', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('carry', 'weight'), 862),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('carry', 'capacity'), 58000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'small-medium'),
 cat_attr('carry', 'weight'), 921),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'small-medium'),
 cat_attr('carry', 'capacity'), 60000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'medium-large'),
 cat_attr('carry', 'weight'), 964),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'medium-large'),
 cat_attr('carry', 'capacity'), 63000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('carry', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('backpacks', 'pack-suspension'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pack-suspension') AND slug = 'internal-frame')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('backpacks', 'frame-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'frame-type') AND slug = 'plastic-frame-sheet'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('backpacks', 'recommended-use'), 'Long-distance hiking, thru-hiking, ultralight backpacking'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'crown2-60') AND slug = 'extra-small-small'),
 cat_attr('backpacks', 'warranty'), 'Limited Lifetime');

-- Osprey Exos 58
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('exos-58', 'Exos 58',
 (SELECT id FROM brand WHERE slug = 'osprey'),
 (SELECT id FROM category WHERE slug = 'backpacks'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'exos-58'), 'extra-small', 'XS', true),
((SELECT id FROM product WHERE slug = 'exos-58'), 'small', 'S', false),
((SELECT id FROM product WHERE slug = 'exos-58'), 'medium', 'M', false),
((SELECT id FROM product WHERE slug = 'exos-58'), 'large', 'L', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('carry', 'weight'), 1070),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('carry', 'capacity'), 53000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'small'),
 cat_attr('carry', 'weight'), 1090),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'small'),
 cat_attr('carry', 'capacity'), 55000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'medium'),
 cat_attr('carry', 'weight'), 1120),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'medium'),
 cat_attr('carry', 'capacity'), 58000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'large'),
 cat_attr('carry', 'weight'), 1160),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'large'),
 cat_attr('carry', 'capacity'), 61000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('carry', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('backpacks', 'pack-suspension'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'pack-suspension') AND slug = 'internal-frame')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('backpacks', 'frame-type'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'frame-type') AND slug = 'aluminum')),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('backpacks', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'nylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('backpacks', 'recommended-use'), 'Fast and light backpacking, multi-day trips'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'exos-58') AND slug = 'extra-small'),
 cat_attr('backpacks', 'warranty'), 'Limited Lifetime');

-- ================================================================================
-- PRODUCTS - TENTS
-- ================================================================================

-- Big Agnes Copper Spur HV UL2
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('copper-spur-hv-ul2', 'Copper Spur HV UL2',
 (SELECT id FROM brand WHERE slug = 'big-agnes'),
 (SELECT id FROM category WHERE slug = 'tents'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2'), 'standard', 'Standard', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'weight'), 1134),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'packed-weight'), 1190),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'packed-length'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'packed-diameter'), 178);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'waterproof'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('shelter', 'repair-kit-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('tents', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'ripstop-nylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('tents', 'recommended-use'), 'Three-season backpacking, two-person'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2') AND slug = 'standard'),
 cat_attr('tents', 'warranty'), 'Limited Lifetime');

-- Zpacks Duplex
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('duplex', 'Duplex',
 (SELECT id FROM brand WHERE slug = 'zpacks'),
 (SELECT id FROM category WHERE slug = 'tents'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'duplex'), 'standard', 'Standard', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('shelter', 'weight'), 510),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('shelter', 'packed-weight'), 567),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('shelter', 'packed-length'), 430),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('shelter', 'packed-diameter'), 130);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('shelter', 'waterproof'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('shelter', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('tents', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'dyneema'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('tents', 'fabric'), 'Dyneema Composite Fabric 0.51 oz/yd²'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('tents', 'recommended-use'), 'Ultralight backpacking, thru-hiking, two-person'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'duplex') AND slug = 'standard'),
 cat_attr('tents', 'warranty'), 'Limited Lifetime');

-- NEMO Dragonfly OSMO 2P
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('dragonfly-osmo-2p', 'Dragonfly OSMO 2P',
 (SELECT id FROM brand WHERE slug = 'nemo'),
 (SELECT id FROM category WHERE slug = 'tents'),
 'public', '2023-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p'), 'standard', 'Standard', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'weight'), 1077),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'packed-weight'), 1134),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'packed-length'), 480),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'packed-diameter'), 165);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'waterproof'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('shelter', 'repair-kit-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('tents', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'ripstop-nylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('tents', 'recommended-use'), 'Three-season backpacking, two-person, versatile conditions'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p') AND slug = 'standard'),
 cat_attr('tents', 'warranty'), 'Limited Lifetime');

-- MSR Hubba Hubba NX 2P
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('hubba-hubba-nx-2p', 'Hubba Hubba NX 2P',
 (SELECT id FROM brand WHERE slug = 'msr'),
 (SELECT id FROM category WHERE slug = 'tents'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p'), 'standard', 'Standard', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('shelter', 'weight'), 1540),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('shelter', 'packed-weight'), 1590),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('shelter', 'packed-length'), 530),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('shelter', 'packed-diameter'), 200);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('shelter', 'waterproof'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('shelter', 'repair-kit-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('tents', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'ripstop-nylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('tents', 'recommended-use'), 'Three-season backpacking, two-person, freestanding'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p') AND slug = 'standard'),
 cat_attr('tents', 'warranty'), 'Limited Lifetime');

-- ================================================================================
-- PRODUCTS - PILLOWS
-- ================================================================================

-- Therm-a-Rest Compressible Pillow
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('compressible-pillow', 'Compressible Pillow',
 (SELECT id FROM brand WHERE slug = 'thermarest'),
 (SELECT id FROM category WHERE slug = 'pillows'),
 'public', '2018-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'compressible-pillow'), 'small', 'Small', true),
((SELECT id FROM product WHERE slug = 'compressible-pillow'), 'medium', 'Medium', false),
((SELECT id FROM product WHERE slug = 'compressible-pillow'), 'large', 'Large', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'small'),
 cat_attr('sleep-system', 'weight'), 95),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'small'),
 cat_attr('pillows', 'packed-volume'), 690),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'medium'),
 cat_attr('sleep-system', 'weight'), 150),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'medium'),
 cat_attr('pillows', 'packed-volume'), 1200),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 215),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'large'),
 cat_attr('pillows', 'packed-volume'), 1900);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'small'),
 cat_attr('sleep-system', 'stuff-sack-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'small'),
 cat_attr('pillows', 'recommended-use'), 'Car camping, backpacking, travel'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'compressible-pillow') AND slug = 'small'),
 cat_attr('pillows', 'warranty'), 'Limited Lifetime');

-- NEMO Fillo
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('fillo', 'Fillo',
 (SELECT id FROM brand WHERE slug = 'nemo'),
 (SELECT id FROM category WHERE slug = 'pillows'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'fillo'), 'standard', 'Standard', true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'fillo') AND slug = 'standard'),
 cat_attr('sleep-system', 'weight'), 113),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'fillo') AND slug = 'standard'),
 cat_attr('pillows', 'packed-volume'), 850);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'fillo') AND slug = 'standard'),
 cat_attr('sleep-system', 'stuff-sack-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'fillo') AND slug = 'standard'),
 cat_attr('pillows', 'recommended-use'), 'Backpacking, hybrid foam and air design'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'fillo') AND slug = 'standard'),
 cat_attr('pillows', 'warranty'), 'Limited Lifetime');

-- Sea to Summit Aeros Premium
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('aeros-premium', 'Aeros Premium Pillow',
 (SELECT id FROM brand WHERE slug = 'sea-to-summit'),
 (SELECT id FROM category WHERE slug = 'pillows'),
 'public', '2021-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'aeros-premium'), 'regular', 'Regular', true),
((SELECT id FROM product WHERE slug = 'aeros-premium'), 'large', 'Large', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'regular'),
 cat_attr('sleep-system', 'weight'), 67),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'regular'),
 cat_attr('pillows', 'packed-volume'), 350),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'large'),
 cat_attr('sleep-system', 'weight'), 78),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'large'),
 cat_attr('pillows', 'packed-volume'), 450);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'regular'),
 cat_attr('sleep-system', 'ultralight'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'regular'),
 cat_attr('sleep-system', 'stuff-sack-included'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'regular'),
 cat_attr('pillows', 'recommended-use'), 'Ultralight backpacking, travel'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'aeros-premium') AND slug = 'regular'),
 cat_attr('pillows', 'warranty'), 'Limited Lifetime');

-- ================================================================================
-- PRODUCTS - STUFF SACKS
-- ================================================================================

-- Sea to Summit Ultra-Sil Nano Dry Sack
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('ultra-sil-nano-dry-sack', 'Ultra-Sil Nano Dry Sack',
 (SELECT id FROM brand WHERE slug = 'sea-to-summit'),
 (SELECT id FROM category WHERE slug = 'stuff-sacks'),
 'public', '2020-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack'), '1l', '1L', true),
((SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack'), '4l', '4L', false),
((SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack'), '8l', '8L', false),
((SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack'), '20l', '20L', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('carry', 'weight'), 8),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('carry', 'capacity'), 1000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '4l'),
 cat_attr('carry', 'weight'), 14),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '4l'),
 cat_attr('carry', 'capacity'), 4000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '8l'),
 cat_attr('carry', 'weight'), 18),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '8l'),
 cat_attr('carry', 'capacity'), 8000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '20l'),
 cat_attr('carry', 'weight'), 29),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '20l'),
 cat_attr('carry', 'capacity'), 20000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('carry', 'waterproof'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('carry', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('stuff-sacks', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'silnylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('stuff-sacks', 'recommended-use'), 'Waterproof storage for electronics, clothing, food'),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack') AND slug = '1l'),
 cat_attr('stuff-sacks', 'warranty'), 'Limited Lifetime');

-- Osprey Ultralight Pack Liner
INSERT INTO product (slug, name, brand, primary_category, visibility, release_at, release_precision) VALUES
('ultralight-pack-liner', 'Ultralight Pack Liner',
 (SELECT id FROM brand WHERE slug = 'osprey'),
 (SELECT id FROM category WHERE slug = 'stuff-sacks'),
 'public', '2019-01-01', 'year');

INSERT INTO product_variant (product, slug, name, is_default) VALUES
((SELECT id FROM product WHERE slug = 'ultralight-pack-liner'), '50-75l', '50-75L', true),
((SELECT id FROM product WHERE slug = 'ultralight-pack-liner'), '100l', '100L', false);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, number_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '50-75l'),
 cat_attr('carry', 'weight'), 85),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '50-75l'),
 cat_attr('carry', 'capacity'), 62000),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '100l'),
 cat_attr('carry', 'weight'), 128),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '100l'),
 cat_attr('carry', 'capacity'), 100000);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, bool_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '50-75l'),
 cat_attr('carry', 'waterproof'), true),
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '50-75l'),
 cat_attr('carry', 'ultralight'), true);

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, enum_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '50-75l'),
 cat_attr('stuff-sacks', 'material'),
 (SELECT id FROM enum_attribute_vals WHERE attribute = (SELECT id FROM attribute WHERE slug = 'material') AND slug = 'silnylon'));

INSERT INTO product_variant_attribute_value (product_variant, category_attribute, string_value) VALUES
((SELECT id FROM product_variant WHERE product = (SELECT id FROM product WHERE slug = 'ultralight-pack-liner') AND slug = '50-75l'),
 cat_attr('stuff-sacks', 'recommended-use'), 'Waterproof liner for backpacks, rain protection');

-- ================================================================================
-- PRODUCT CHANGE EVENTS
-- ================================================================================
\echo '=� Inserting product change events...'

INSERT INTO product_change_event (product, event, year, month, description) VALUES
((SELECT id FROM product WHERE slug = 'neoair-xlite-nxt'),
 'major_update', 2022, 1, 'Redesigned with new ThermaCapture technology and WingLock valve'),
((SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt'),
 'major_update', 2022, 1, 'Updated with improved R-value and lighter weight'),
((SELECT id FROM product WHERE slug = 'neoair-uberlite'),
 'minor_update', 2020, 3, 'Updated fabric for improved durability'),
((SELECT id FROM product WHERE slug = 'tensor-insulated'),
 'minor_update', 2023, 1, 'New color options added'),
((SELECT id FROM product WHERE slug = 'tensor-all-season'),
 'major_update', 2023, 1, 'Launch of new all-season variant with higher R-value');

-- ================================================================================
-- PRODUCT CATEGORIES (Multi-category support)
-- ================================================================================
\echo '= Inserting product category relationships...'

-- Sleeping pads
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'neoair-xlite-nxt'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'neoair-xtherm-nxt'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'neoair-uberlite'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'prolite-plus'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'z-lite-sol'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'tensor-insulated'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'tensor-all-season'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'switchback'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'ether-light-xt-insulated'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'ultralight-insulated'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads')),
((SELECT id FROM product WHERE slug = 'rapide-sl-insulated'),
 (SELECT id FROM category WHERE slug = 'sleeping-pads'));

-- Sleeping bags
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'ultralite'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags')),
((SELECT id FROM product WHERE slug = 'hummingbird-ul'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags'));

-- Quilts
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'revelation'),
 (SELECT id FROM category WHERE slug = 'quilts')),
((SELECT id FROM product WHERE slug = 'solo-quilt'),
 (SELECT id FROM category WHERE slug = 'quilts'));

-- Backpacks
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'atmos-ag-65'),
 (SELECT id FROM category WHERE slug = 'backpacks')),
((SELECT id FROM product WHERE slug = 'gorilla'),
 (SELECT id FROM category WHERE slug = 'backpacks')),
((SELECT id FROM product WHERE slug = 'southwest-3400'),
 (SELECT id FROM category WHERE slug = 'backpacks')),
((SELECT id FROM product WHERE slug = 'baltoro-65'),
 (SELECT id FROM category WHERE slug = 'backpacks')),
((SELECT id FROM product WHERE slug = 'crown2-60'),
 (SELECT id FROM category WHERE slug = 'backpacks')),
((SELECT id FROM product WHERE slug = 'exos-58'),
 (SELECT id FROM category WHERE slug = 'backpacks'));

-- More sleeping bags
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'disco-15'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags')),
((SELECT id FROM product WHERE slug = 'magma-15'),
 (SELECT id FROM category WHERE slug = 'sleeping-bags'));

-- More quilts
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'enigma'),
 (SELECT id FROM category WHERE slug = 'quilts')),
((SELECT id FROM product WHERE slug = 'ventum-20'),
 (SELECT id FROM category WHERE slug = 'quilts'));

-- Tents
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'copper-spur-hv-ul2'),
 (SELECT id FROM category WHERE slug = 'tents')),
((SELECT id FROM product WHERE slug = 'duplex'),
 (SELECT id FROM category WHERE slug = 'tents')),
((SELECT id FROM product WHERE slug = 'dragonfly-osmo-2p'),
 (SELECT id FROM category WHERE slug = 'tents')),
((SELECT id FROM product WHERE slug = 'hubba-hubba-nx-2p'),
 (SELECT id FROM category WHERE slug = 'tents'));

-- Pillows
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'compressible-pillow'),
 (SELECT id FROM category WHERE slug = 'pillows')),
((SELECT id FROM product WHERE slug = 'fillo'),
 (SELECT id FROM category WHERE slug = 'pillows')),
((SELECT id FROM product WHERE slug = 'aeros-premium'),
 (SELECT id FROM category WHERE slug = 'pillows'));

-- Stuff sacks
INSERT INTO product_category (product, category) VALUES
((SELECT id FROM product WHERE slug = 'ultra-sil-nano-dry-sack'),
 (SELECT id FROM category WHERE slug = 'stuff-sacks')),
((SELECT id FROM product WHERE slug = 'ultralight-pack-liner'),
 (SELECT id FROM category WHERE slug = 'stuff-sacks'));

-- ================================================================================
-- COMPLETION MESSAGE
-- ================================================================================
\echo ''
\echo ' Seed data insertion complete!'
\echo ''
\echo 'Summary:'
\echo '  - 5 users'
\echo '  - 17 brands'
\echo '  - 10 categories (3 parent, 7 child)'
\echo '  - 30 attributes'
\echo '  - 45+ enum attribute values'
\echo '  - 32 products'
\echo '  - 85+ product variants'
\echo '  - 500+ variant attribute values'
\echo '  - 5 product change events'
\echo '  - 32 product category relationships'
\echo ''
\echo '=� Next steps:'
\echo '  1. Verify data: SELECT COUNT(*) FROM product;'
\echo '  2. Check variants: SELECT p.name, pv.name, pv.id FROM product p JOIN product_variant pv ON p.id = pv.product;'
\echo ''
DROP FUNCTION IF EXISTS cat_attr(TEXT, TEXT);
