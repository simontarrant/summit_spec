-- +goose Up

-- ─────────────────────────────────────────
-- ENUMS
-- ─────────────────────────────────────────

CREATE TYPE attribute_type AS ENUM ('number', 'bool', 'enum_list', 'string');

CREATE TYPE number_unit AS ENUM (
  'weight_g',
  'length_mm',
  'volume_ml',
  'int',
  'float',
  'NA'
);

CREATE TYPE product_visibility AS ENUM ('public', 'private', 'link_access');

CREATE TYPE release_precision_enum AS ENUM ('year', 'month', 'day', 'minute');

CREATE TYPE change_event_enum AS ENUM ('minor_update', 'major_update');

CREATE TYPE iso_country_code AS ENUM ('AU','US','GB','CA','NZ');

-- ─────────────────────────────────────────
-- USER
-- ─────────────────────────────────────────

CREATE TABLE "user" (
    id BIGSERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_user_username_active
  ON "user"(username)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_user_email_active
  ON "user"(email)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- ATTRIBUTE
-- ─────────────────────────────────────────

CREATE TABLE attribute (
    id BIGSERIAL PRIMARY KEY,
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    type attribute_type NOT NULL,
    number_unit number_unit NOT NULL DEFAULT 'NA',
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_attribute_name_active
  ON attribute(name)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_attribute_slug_active
  ON attribute(slug)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- ENUM ATTRIBUTE VALUES
-- ─────────────────────────────────────────

CREATE TABLE enum_attribute_vals (
    id BIGSERIAL PRIMARY KEY,
    attribute BIGINT NOT NULL REFERENCES attribute(id),
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    display_order INT NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_enum_attrvals_name_active
  ON enum_attribute_vals(attribute, name)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_enum_attrvals_slug_active
  ON enum_attribute_vals(attribute, slug)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_enum_attrvals_display_order_active
  ON enum_attribute_vals(attribute, display_order)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- BRAND
-- ─────────────────────────────────────────

CREATE TABLE brand (
    id BIGSERIAL PRIMARY KEY,
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    country iso_country_code,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_brand_name_active
  ON brand(name)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_brand_slug_active
  ON brand(slug)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- CATEGORY
-- ─────────────────────────────────────────

CREATE TABLE category (
    id BIGSERIAL PRIMARY KEY,
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    parent_category BIGINT REFERENCES category(id),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_category_slug_active
  ON category(slug)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_category_name_active
  ON category(name)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- CATEGORY ATTRIBUTE
-- ─────────────────────────────────────────

CREATE TABLE category_attribute (
    id BIGSERIAL PRIMARY KEY,
    category BIGINT NOT NULL REFERENCES category(id),
    attribute BIGINT NOT NULL REFERENCES attribute(id),
    priority INT NOT NULL DEFAULT 0,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_category_attribute_active
  ON category_attribute(category, attribute)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- PRODUCT
-- ─────────────────────────────────────────

CREATE TABLE product (
    id BIGSERIAL PRIMARY KEY,
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    brand BIGINT NOT NULL REFERENCES brand(id),
    primary_category BIGINT NOT NULL REFERENCES category(id),
    visibility product_visibility NOT NULL,
    owner_user_id BIGINT REFERENCES "user"(id),
    release_at TIMESTAMPTZ,
    release_precision release_precision_enum,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_product_name_active
  ON product(brand, name)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_product_slug_active
  ON product(brand, slug)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- PRODUCT VARIANT
-- ─────────────────────────────────────────

CREATE TABLE product_variant (
    id BIGSERIAL PRIMARY KEY,
    product BIGINT NOT NULL REFERENCES product(id),
    slug TEXT NOT NULL,
    name TEXT NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    release_at TIMESTAMPTZ,
    release_precision release_precision_enum,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_variant_name_active
  ON product_variant(product, name)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_variant_slug_active
  ON product_variant(product, slug)
  WHERE is_deleted = FALSE;

CREATE UNIQUE INDEX uniq_default_variant_per_product
  ON product_variant(product)
  WHERE is_default = TRUE AND is_deleted = FALSE;

-- ─────────────────────────────────────────
-- PRODUCT CATEGORY
-- ─────────────────────────────────────────

CREATE TABLE product_category (
    id BIGSERIAL PRIMARY KEY,
    product BIGINT NOT NULL REFERENCES product(id),
    category BIGINT NOT NULL REFERENCES category(id),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_product_category_active
  ON product_category(product, category)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- ATTRIBUTE VALUES
-- ─────────────────────────────────────────

CREATE TABLE product_attribute_value (
    id BIGSERIAL PRIMARY KEY,
    product BIGINT NOT NULL REFERENCES product(id),
    category_attribute BIGINT NOT NULL REFERENCES category_attribute(id),
    number_value DOUBLE PRECISION,
    string_value TEXT,
    bool_value BOOLEAN,
    enum_value BIGINT REFERENCES enum_attribute_vals(id),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_product_attr_value_active
  ON product_attribute_value(product, category_attribute)
  WHERE is_deleted = FALSE;

CREATE TABLE product_variant_attribute_value (
    id BIGSERIAL PRIMARY KEY,
    product_variant BIGINT NOT NULL REFERENCES product_variant(id),
    category_attribute BIGINT NOT NULL REFERENCES category_attribute(id),
    number_value DOUBLE PRECISION,
    string_value TEXT,
    bool_value BOOLEAN,
    enum_value BIGINT REFERENCES enum_attribute_vals(id),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX uniq_product_variant_attr_value_active
  ON product_variant_attribute_value(product_variant, category_attribute)
  WHERE is_deleted = FALSE;

-- ─────────────────────────────────────────
-- VALIDATION TRIGGER
-- ─────────────────────────────────────────

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION enforce_attribute_value_type()
RETURNS trigger AS $BODY$
DECLARE
    attr_type TEXT;
BEGIN
    SELECT a.type INTO attr_type
    FROM attribute a
    JOIN category_attribute ca ON ca.attribute = a.id
    WHERE ca.id = NEW.category_attribute;

    IF attr_type = 'number' THEN
        IF NEW.number_value IS NULL OR
           NEW.string_value IS NOT NULL OR
           NEW.bool_value IS NOT NULL OR
           NEW.enum_value IS NOT NULL THEN
            RAISE EXCEPTION 'Invalid number attribute_value';
        END IF;

    ELSIF attr_type = 'string' THEN
        IF NEW.string_value IS NULL OR
           NEW.number_value IS NOT NULL OR
           NEW.bool_value IS NOT NULL OR
           NEW.enum_value IS NOT NULL THEN
            RAISE EXCEPTION 'Invalid string attribute_value';
        END IF;

    ELSIF attr_type = 'bool' THEN
        IF NEW.bool_value IS NULL OR
           NEW.number_value IS NOT NULL OR
           NEW.string_value IS NOT NULL OR
           NEW.enum_value IS NOT NULL THEN
            RAISE EXCEPTION 'Invalid bool attribute_value';
        END IF;

    ELSIF attr_type = 'enum_list' THEN
        IF NEW.enum_value IS NULL OR
           NEW.number_value IS NOT NULL OR
           NEW.string_value IS NOT NULL OR
           NEW.bool_value IS NOT NULL THEN
            RAISE EXCEPTION 'Invalid enum attribute_value';
        END IF;
    END IF;

    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_enforce_attribute_value_type_variant
BEFORE INSERT OR UPDATE ON product_variant_attribute_value
FOR EACH ROW
EXECUTE FUNCTION enforce_attribute_value_type();

CREATE TRIGGER trg_enforce_attribute_value_type_product
BEFORE INSERT OR UPDATE ON product_attribute_value
FOR EACH ROW
EXECUTE FUNCTION enforce_attribute_value_type();


-- ─────────────────────────────────────────
-- SEARCH PROJECTION TABLE
-- Flattened product_variant search index
-- ─────────────────────────────────────────

CREATE TABLE search_product_variant (
    variant_id BIGINT PRIMARY KEY,
    product_id BIGINT NOT NULL,

    product_name TEXT NOT NULL,
    variant_name TEXT,

    brand_id BIGINT NOT NULL,
    brand_name TEXT NOT NULL,

    primary_category_id BIGINT NOT NULL,

    -- All categories the product belongs to including ancestors
    category_ids BIGINT[] NOT NULL,

    -- Attribute maps keyed by attribute_id (stored as string keys in JSONB)
    number_attrs JSONB NOT NULL DEFAULT '{}'::jsonb,
    bool_attrs JSONB NOT NULL DEFAULT '{}'::jsonb,
    enum_attrs JSONB NOT NULL DEFAULT '{}'::jsonb,
    string_attrs JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────

-- Category filtering
CREATE INDEX idx_spv_category_ids
ON search_product_variant
USING GIN (category_ids);

-- Attribute filtering
CREATE INDEX idx_spv_number_attrs
ON search_product_variant
USING GIN (number_attrs);

CREATE INDEX idx_spv_bool_attrs
ON search_product_variant
USING GIN (bool_attrs);

CREATE INDEX idx_spv_enum_attrs
ON search_product_variant
USING GIN (enum_attrs);

CREATE INDEX idx_spv_string_attrs
ON search_product_variant
USING GIN (string_attrs);

-- Common sort helpers
CREATE INDEX idx_spv_product_name
ON search_product_variant (product_name);

CREATE INDEX idx_spv_brand_name
ON search_product_variant (brand_name);

CREATE INDEX idx_spv_product_id
ON search_product_variant (product_id);

-- +goose Down
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;