# DONE
# Product Search System — Implementation Plan

## Overview

We are implementing a **product search system** for a gear comparison platform.

The system allows users to:

- select a category
- filter using category attributes
- sort results
- browse results in a table
- paginate through results

Search results are displayed at the **product_variant** level.

The system must support:

- category hierarchies
- inherited category attributes
- structured filtering
- deterministic sorting
- offset pagination

This document defines the **overall architecture and phased implementation plan**.

Implementation will proceed **phase-by-phase**, and Claude should **only implement the current phase requested**.

---

# Core Concepts

## Categories

Products belong to categories.

Rules:

- Each product has **one primary category**
- A product may also have **secondary categories**
- Categories may have a **parent category**
- Categories define **attributes**

### Attribute inheritance

Child categories inherit attributes from parent categories.

Example:

```
sleeping_gear
    weight
    packed_volume

sleeping_pads
    r_value
    thickness
```

Products in `sleeping_pads` inherit:

```
weight
packed_volume
r_value
thickness
```

---

# Result Grain

Search results are **product_variants**.

Each table row represents:

```
product_variant
```

Attribute values may come from:

- product_variant attributes
- product attributes

Rule:

```
variant value overrides product value
otherwise use product value
```

---

# Category Selection Behavior

When a user selects category `C`, search results must include products whose:

- primary category is `C`
- secondary category is `C`
- category is a **descendant of `C`**

---

# Schema Resolution

The attribute schema for category `C` is the **union of attributes from**:

- `C`
- all descendants of `C`
- inherited parent attributes

Categories outside this subtree **must not affect the schema**.

---

# Attribute Types

Supported types:

```
number
bool
enum_list
string
```

Units for numbers:

```
weight_g
length_mm
volume_ml
int
float
NA
```

---

# Filtering Rules

Filters combine using **AND logic**.

Example:

```
weight >= 500
AND
r_value >= 3
```

---

## Number Filters

Supported operations:

```
eq
gte
lte
between
```

Example:

```
weight >= 500
r_value between 3 and 5
```

Missing values:

```
do not match numeric filters
```

---

## Bool Filters

Supported values:

```
true
false
```

Missing values:

```
do not match filter
```

Sorting order:

```
false < true
```

---

## Enum Filters

Users may select **multiple enum values**.

Filter rule:

```
match ANY selected value
```

Example:

```
shape IN { mummy, rectangular }
```

Missing values:

```
do not match filter
```

Sorting:

```
NOT supported
```

---

## String Filters

Structured string fields only.

Supported filter:

```
exact match
```

Missing values:

```
do not match filter
```

Sorting:

```
lexical ordering
```

---

# Sorting Rules

Sortable types:

```
number
bool
string
```

Not sortable:

```
enum_list
```

Missing values:

```
always sorted last
```

This rule applies to both ascending and descending sorts.

---

# Stable Ordering Requirement

To support offset pagination, results must have deterministic ordering.

Tie-break ordering:

```
1. user selected sort
2. product name
3. brand name
4. product id
5. product_variant id
```

---

# Pagination

Pagination method:

```
offset pagination
```

Supported parameters:

```
limit
offset
```

---

# Column Rules

Pinned columns (always first):

```
product_name
brand_name
```

---

## Column Priority

Remaining columns ordered by:

```
1. attributes currently being filtered
2. parent category attributes
3. child category attributes
4. categories at same depth sorted by category_id
5. attribute priority
6. attribute id
```

---

## Column Display

The FE should:

- show as many columns as fit the screen
- follow column priority ordering
- hide lower priority columns if space runs out

Horizontal scrolling is allowed.

---

# Visibility Rules

Do not show:

```
deleted products
deleted product_variants
user/private products
```

---

# Out of Scope

Do NOT implement yet:

```
text search
facet counts
subjective attributes
search ranking
variant compression
advanced column customization
```

---

# Implementation Phases

The system must be implemented in **three phases**.

Claude should **only work on the phase explicitly requested**.

---

# Phase 1 — API Design ✅ COMPLETE

API specification defined below. See [Phase 1 — API Specification](#phase-1--api-specification) for the full contract.

---

## Phase 1 — API Specification

### Endpoints

```
GET  /api/categories/schema
POST /api/products/search
```

---

### `GET /api/categories/schema`

Returns everything the FE needs to build the category selector, filter controls, and column headers.

No query parameters. Full tree returned; FE resolves client-side.

**Response `200 OK`:**

```jsonc
{
  // Nested category tree
  "categories": [
    {
      "id": "1",
      "slug": "sleep-system",
      "name": "Sleep System",
      "parentCategoryId": null,
      "children": [
        {
          "id": "2",
          "slug": "sleeping-pads",
          "name": "Sleeping Pads",
          "parentCategoryId": "1",
          "children": []
        }
      ]
    }
  ],

  // Flat attribute lookup map keyed by attribute ID
  "attributes": {
    "10": {
      "id": "10",
      "slug": "weight",
      "name": "Weight",
      "type": "number",           // number | bool | enum_list | string
      "numberUnit": "weight_g",   // weight_g | length_mm | volume_ml | int | float | NA
      "enumOptions": null
    },
    "12": {
      "id": "12",
      "slug": "pad-type",
      "name": "Pad Type",
      "type": "enum_list",
      "numberUnit": null,
      "enumOptions": [
        { "id": "100", "slug": "air", "name": "Air", "displayOrder": 1 }
      ]
    }
  },

  // Which attributes belong to which category, keyed by category ID
  "categoryAttributes": {
    "1": [
      { "attributeId": "10", "priority": 1 }
    ],
    "2": [
      { "attributeId": "12", "priority": 1 }
    ]
  }
}
```

**FE schema resolution:** When user selects category C, FE unions `categoryAttributes` for C + ancestors + descendants. Uses `attributes` map for type/unit/enum lookups.

---

### `POST /api/products/search`

Search, filter, sort, and paginate product variants within a category.

**Request body:**

```jsonc
{
  "categoryId": "2",                    // REQUIRED
  "filters": [                          // OPTIONAL, default []
    // Number filter (operators: eq, gte, lte, between)
    { "attributeId": "10", "type": "number", "operator": "gte", "value": 300 },
    { "attributeId": "10", "type": "number", "operator": "lte", "value": 600 },
    { "attributeId": "11", "type": "number", "operator": "between", "value": [3.0, 5.5] },
    // Bool filter
    { "attributeId": "13", "type": "bool", "value": true },
    // Enum filter (OR within, uses enum_attribute_vals IDs)
    { "attributeId": "12", "type": "enum_list", "value": ["100", "101"] },
    // String filter (exact match)
    { "attributeId": "15", "type": "string", "value": "3-season" }
  ],
  "sort": {                             // OPTIONAL, default null
    "attributeId": "10",
    "direction": "asc"                  // asc | desc
  },
  "limit": 25,                          // OPTIONAL, default 25, range 1-100
  "offset": 0                           // OPTIONAL, default 0, min 0
}
```

**Response `200 OK`:**

```jsonc
{
  "rows": [
    {
      "variantId": "501",
      "productId": "200",
      "productName": "NeoAir XLite NXT",
      "variantName": "Regular",
      "brandId": "50",
      "brandName": "Therm-a-Rest",
      "primaryCategoryId": "2",
      "attributes": {
        // keyed by attribute ID, only present if value exists
        "10": { "type": "number", "value": 340 },
        "12": { "type": "enum_list", "value": { "id": "100", "slug": "air", "name": "Air" } },
        "13": { "type": "bool", "value": true }
      }
    }
  ],

  // Pre-sorted column definitions for table rendering
  "columns": [
    { "key": "productName", "label": "Product", "pinned": true },
    { "key": "brandName", "label": "Brand", "pinned": true },
    { "key": "attr:10", "label": "Weight", "attributeId": "10", "type": "number", "numberUnit": "weight_g", "sortable": true, "pinned": false },
    { "key": "attr:12", "label": "Pad Type", "attributeId": "12", "type": "enum_list", "sortable": false, "pinned": false }
  ],

  "pagination": {
    "limit": 25,
    "offset": 0,
    "totalRows": 87
  }
}
```

---

### Filtering Rules

- Filters combine with **AND** logic
- Missing attribute values **never match** any filter
- Multiple number filters on same attribute allowed with different operators (e.g. gte + lte)
- Enum filter: match **ANY** selected value (OR within)

---

### Sorting Rules

- Sortable types: `number`, `bool`, `string`. **Not** `enum_list`
- Missing values: **always last** (both asc and desc)
- Tie-break chain: user sort → `product_name` → `brand_name` → `product_id` → `variant_id`

---

### Column Ordering (computed server-side)

1. Pinned: `productName`, `brandName`
2. Attributes with active filters (by priority)
3. Parent category attributes (root-first, then priority, then attribute id)
4. Selected category attributes (by priority, then attribute id)
5. Child category attributes (by category_id, then priority, then attribute id)

---

### Category Matching

When user selects category C, include variants whose product has C (or any descendant of C) as primary or secondary category.

The `rebuild_product_search_index.sql` query includes the primary category in the `category_ids` array so search only needs to check `category_ids` for category membership.

---

### IDs

All IDs serialized as **strings** in JSON (DB uses BIGSERIAL).

---

### Enum Values in Rows

Resolved inline with `{ id, slug, name }` — no client-side lookup needed.

---

### Validation (400 Errors)

| Condition | Error message |
|---|---|
| Missing/invalid `categoryId` | `"Invalid or missing categoryId"` |
| Filter `attributeId` not in resolved schema | `"Attribute {id} is not valid for category {categoryId}"` |
| Filter `type` doesn't match attribute type | `"Filter type mismatch for attribute {id}"` |
| `between` value not `[min, max]` or min > max | `"between filter requires [min, max] where min <= max"` |
| Empty enum_list filter value array | `"enum_list filter requires at least one value"` |
| Sort on enum_list attribute | `"Cannot sort by enum_list attribute"` |
| Sort attribute not in resolved schema | `"Sort attribute {id} is not valid for category {categoryId}"` |
| `limit` outside 1-100 | `"limit must be between 1 and 100"` |
| `offset` < 0 | `"offset must be >= 0"` |

---

# Phase 2 — Backend Implementation

Goal:

Implement the backend APIs defined in Phase 1.

Work **route-by-route**.

---

## Backend Requirements

Implement:

```
GET /api/categories/schema
POST /api/products/search
```

---

### Category Schema Route

Responsibilities:

- return category hierarchy
- return category attributes
- return enum values
- support attribute inheritance logic

---

### Product Search Route

Responsibilities:

- resolve category subtree
- apply filters
- apply sorting
- apply pagination
- return product_variant rows
- handle attribute inheritance

---

### Testing

Write tests for:

```
category hierarchy resolution
attribute inheritance
filter behavior by attribute type
sorting rules
missing value ordering
stable pagination ordering
variant/product attribute inheritance
```

---

### Output of Phase 2

Working backend APIs with tests.

---

# Phase 3 — Frontend Table

Goal:

Build the **search table UI** using the APIs.

---

## Architecture: Client Components with URL Sync

Use **client components** for all interactive parts of the search UI.

**Rationale:**

- Filter changes must feel instant. Server components require a full server round-trip on every filter change, which is unacceptable for a filter-heavy search UI.
- The POST `/api/products/search` endpoint already exists and is the correct integration point — bypassing it would duplicate logic.
- Debouncing range inputs (e.g. user typing a min weight) is trivial with local state; it is significantly harder with URL-first RSC routing.
- The app is behind auth, so SEO is irrelevant.

**Component structure:**

```
app/products/page.tsx          ← server component (layout, shell)
  └── <ProductSearch>          ← "use client" — owns all search state
        ├── <CategorySelector>
        ├── <FilterPanel>       ← renders controls per attribute type
        ├── <ResultsTable>      ← renders columns/rows from POST response
        └── <Pagination>
```

**State flow:**

1. User changes category / filter / sort / page
2. `<ProductSearch>` updates local state
3. Debounced effect fires `POST /api/products/search`
4. Response updates results; table shows loading skeleton during fetch
5. State is also synced to URL search params for shareability

**Filter debouncing:**

- Range number inputs: debounce ~400ms before triggering fetch
- Toggle, enum, pagination: trigger immediately

---

## Required UI

The page must include:

```
category selector
filters
sorting
table
pagination
```

---

## Filter UI

Recommended mapping:

| Type | UI |
| --- | --- |
| number | range inputs |
| bool | toggle |
| enum | multi-select |
| string | exact-match input |

---

## Table

Each row represents:

```
product_variant
```

Columns include:

```
product name
brand name
category attributes
```

Columns must follow the priority rules defined earlier.

---