import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";

// --- Types ---

interface NumberFilter {
  attributeId: string;
  type: "number";
  operator: "eq" | "gte" | "lte" | "between";
  value: number | [number, number];
}

interface BoolFilter {
  attributeId: string;
  type: "bool";
  value: boolean;
}

interface EnumFilter {
  attributeId: string;
  type: "enum_list";
  value: string[];
}

interface StringFilter {
  attributeId: string;
  type: "string";
  value: string;
}

type Filter = NumberFilter | BoolFilter | EnumFilter | StringFilter;

interface SortSpec {
  attributeId: string;
  direction: "asc" | "desc";
}

interface RequestBody {
  categoryId?: string;
  filters?: Filter[];
  sort?: SortSpec | null;
  limit?: number;
  offset?: number;
}

interface AttributeInfo {
  id: bigint;
  slug: string;
  name: string;
  type: string;
  numberUnit: string;
  categoryId: bigint;
  priority: number;
  categoryAttributeId: bigint;
  enumOptions: { id: string; slug: string; name: string; displayOrder: number }[] | null;
}

interface AttrValueRow {
  variant_id: bigint;
  attribute_id: bigint;
  attr_type: string;
  number_value: number | null;
  string_value: string | null;
  bool_value: boolean | null;
  enum_value: bigint | null;
  enum_id: bigint | null;
  enum_slug: string | null;
  enum_name: string | null;
}

interface VariantRow {
  variant_id: bigint;
  variant_name: string;
  product_id: bigint;
  product_name: string;
  brand_id: bigint;
  brand_name: string;
  primary_category_id: bigint;
}

interface CountRow {
  count: bigint;
}

// --- Helpers ---

function err400(message: string) {
  return NextResponse.json({ error: message }, { status: 400 });
}

function bigintStr(v: bigint): string {
  return v.toString();
}

// --- Route Handler ---

export async function POST(req: Request) {
  try {
    let body: RequestBody;
    try {
      body = await req.json();
    } catch {
      return err400("Invalid or missing categoryId");
    }

    const { filters = [], sort = null, limit = 25, offset = 0 } = body;
    const categoryIdStr = body.categoryId;

    // --- Validate categoryId ---
    if (!categoryIdStr || typeof categoryIdStr !== "string") {
      return err400("Invalid or missing categoryId");
    }

    let categoryId: bigint;
    try {
      categoryId = BigInt(categoryIdStr);
    } catch {
      return err400("Invalid or missing categoryId");
    }

    // Check category exists and not deleted
    const category = await prisma.category.findFirst({
      where: { id: categoryId, is_deleted: false },
      select: { id: true },
    });
    if (!category) {
      return err400("Invalid or missing categoryId");
    }

    // --- Validate limit/offset ---
    if (typeof limit !== "number" || limit < 1 || limit > 100) {
      return err400("limit must be between 1 and 100");
    }
    if (typeof offset !== "number" || offset < 0) {
      return err400("offset must be >= 0");
    }

    // --- Resolve category subtree (descendants) ---
    const subtreeRows = await prisma.$queryRawUnsafe<{ id: bigint }[]>(
      `WITH RECURSIVE cat_tree AS (
        SELECT id FROM category WHERE id = $1 AND is_deleted = false
        UNION ALL
        SELECT c.id FROM category c
        JOIN cat_tree ct ON c.parent_category = ct.id
        WHERE c.is_deleted = false
      )
      SELECT id FROM cat_tree`,
      categoryId
    );
    const subtreeIds = subtreeRows.map((r) => r.id);

    // --- Resolve ancestors (for attribute inheritance) ---
    const ancestorRows = await prisma.$queryRawUnsafe<{ id: bigint }[]>(
      `WITH RECURSIVE ancestors AS (
        SELECT id, parent_category FROM category WHERE id = $1 AND is_deleted = false
        UNION ALL
        SELECT c.id, c.parent_category FROM category c
        JOIN ancestors a ON c.id = a.parent_category
        WHERE c.is_deleted = false
      )
      SELECT id FROM ancestors`,
      categoryId
    );
    const ancestorIds = ancestorRows.map((r) => r.id);

    // Union of all category IDs for schema resolution
    const allCategoryIds = [...new Set([...subtreeIds, ...ancestorIds])];

    // --- Resolve attribute schema ---
    const categoryAttributes = await prisma.category_attribute.findMany({
      where: {
        category: { in: allCategoryIds },
        is_deleted: false,
        attribute_rel: { is_deleted: false },
      },
      select: {
        id: true,
        category: true,
        attribute: true,
        priority: true,
        attribute_rel: {
          select: {
            id: true,
            slug: true,
            name: true,
            type: true,
            number_unit: true,
            enum_attribute_vals_enum_attribute_vals_attributeToattribute: {
              where: { is_deleted: false },
              select: { id: true, slug: true, name: true, display_order: true },
              orderBy: { display_order: "asc" },
            },
          },
        },
      },
    });

    // Build attribute map keyed by attribute ID (bigint)
    // Use a Map to dedupe by attribute ID, keeping the first occurrence
    const attrMap = new Map<string, AttributeInfo>();
    // Also build a list of all category_attribute entries for column ordering
    const allCatAttrs: { categoryId: bigint; attributeId: bigint; priority: number; catAttrId: bigint }[] = [];

    for (const ca of categoryAttributes) {
      const attrIdStr = ca.attribute.toString();
      allCatAttrs.push({
        categoryId: ca.category,
        attributeId: ca.attribute,
        priority: ca.priority,
        catAttrId: ca.id,
      });

      if (!attrMap.has(attrIdStr)) {
        const rel = ca.attribute_rel;
        const enumVals = rel.enum_attribute_vals_enum_attribute_vals_attributeToattribute;
        attrMap.set(attrIdStr, {
          id: rel.id,
          slug: rel.slug,
          name: rel.name,
          type: rel.type,
          numberUnit: rel.number_unit,
          categoryId: ca.category,
          priority: ca.priority,
          categoryAttributeId: ca.id,
          enumOptions:
            rel.type === "enum_list"
              ? enumVals.map((v) => ({
                  id: v.id.toString(),
                  slug: v.slug,
                  name: v.name,
                  displayOrder: v.display_order,
                }))
              : null,
        });
      }
    }

    // --- Validate filters ---
    for (const filter of filters) {
      const attrInfo = attrMap.get(filter.attributeId);
      if (!attrInfo) {
        return err400(`Attribute ${filter.attributeId} is not valid for category ${categoryIdStr}`);
      }
      if (filter.type !== attrInfo.type) {
        return err400(`Filter type mismatch for attribute ${filter.attributeId}`);
      }
      if (filter.type === "number" && filter.operator === "between") {
        const val = filter.value;
        if (!Array.isArray(val) || val.length !== 2 || val[0] > val[1]) {
          return err400("between filter requires [min, max] where min <= max");
        }
      }
      if (filter.type === "enum_list") {
        if (!Array.isArray(filter.value) || filter.value.length === 0) {
          return err400("enum_list filter requires at least one value");
        }
      }
    }

    // --- Validate sort ---
    if (sort) {
      const sortAttrInfo = attrMap.get(sort.attributeId);
      if (!sortAttrInfo) {
        return err400(`Sort attribute ${sort.attributeId} is not valid for category ${categoryIdStr}`);
      }
      if (sortAttrInfo.type === "enum_list") {
        return err400("Cannot sort by enum_list attribute");
      }
    }

    // --- Build the search query ---
    const params: unknown[] = [];
    let paramIdx = 0;
    function nextParam(value: unknown): string {
      paramIdx++;
      params.push(value);
      return `$${paramIdx}`;
    }

    // Subtree IDs as array parameter
    const subtreeParam = nextParam(subtreeIds);

    // Base WHERE clause
    let whereClause = `
      pv.is_deleted = false
      AND p.is_deleted = false
      AND p.visibility = 'public'
      AND (
        p.primary_category = ANY(${subtreeParam})
        OR EXISTS (
          SELECT 1 FROM product_category pc
          WHERE pc.product = p.id AND pc.category = ANY(${subtreeParam}) AND pc.is_deleted = false
        )
      )
    `;

    // --- Filter clauses ---
    for (const filter of filters) {
      const attrInfo = attrMap.get(filter.attributeId)!;
      // Find all category_attribute IDs for this attribute (across all resolved categories)
      const catAttrIds = allCatAttrs
        .filter((ca) => ca.attributeId.toString() === filter.attributeId)
        .map((ca) => ca.catAttrId);
      const catAttrIdsParam = nextParam(catAttrIds);

      let valueCondition: string;

      if (filter.type === "number") {
        const numFilter = filter as NumberFilter;
        switch (numFilter.operator) {
          case "eq": {
            const p = nextParam(numFilter.value);
            valueCondition = `number_value = ${p}`;
            break;
          }
          case "gte": {
            const p = nextParam(numFilter.value);
            valueCondition = `number_value >= ${p}`;
            break;
          }
          case "lte": {
            const p = nextParam(numFilter.value);
            valueCondition = `number_value <= ${p}`;
            break;
          }
          case "between": {
            const val = numFilter.value as [number, number];
            const pMin = nextParam(val[0]);
            const pMax = nextParam(val[1]);
            valueCondition = `number_value >= ${pMin} AND number_value <= ${pMax}`;
            break;
          }
          default:
            valueCondition = "false";
        }

        whereClause += `
          AND (
            EXISTS (
              SELECT 1 FROM product_variant_attribute_value pvav
              WHERE pvav.product_variant = pv.id
                AND pvav.category_attribute = ANY(${catAttrIdsParam})
                AND pvav.is_deleted = false
                AND ${valueCondition}
            )
            OR (
              NOT EXISTS (
                SELECT 1 FROM product_variant_attribute_value pvav
                WHERE pvav.product_variant = pv.id
                  AND pvav.category_attribute = ANY(${catAttrIdsParam})
                  AND pvav.is_deleted = false
              )
              AND EXISTS (
                SELECT 1 FROM product_attribute_value pav
                WHERE pav.product = p.id
                  AND pav.category_attribute = ANY(${catAttrIdsParam})
                  AND pav.is_deleted = false
                  AND ${valueCondition}
              )
            )
          )
        `;
      } else if (filter.type === "bool") {
        const boolFilter = filter as BoolFilter;
        const p = nextParam(boolFilter.value);
        valueCondition = `bool_value = ${p}`;

        whereClause += `
          AND (
            EXISTS (
              SELECT 1 FROM product_variant_attribute_value pvav
              WHERE pvav.product_variant = pv.id
                AND pvav.category_attribute = ANY(${catAttrIdsParam})
                AND pvav.is_deleted = false
                AND ${valueCondition}
            )
            OR (
              NOT EXISTS (
                SELECT 1 FROM product_variant_attribute_value pvav
                WHERE pvav.product_variant = pv.id
                  AND pvav.category_attribute = ANY(${catAttrIdsParam})
                  AND pvav.is_deleted = false
              )
              AND EXISTS (
                SELECT 1 FROM product_attribute_value pav
                WHERE pav.product = p.id
                  AND pav.category_attribute = ANY(${catAttrIdsParam})
                  AND pav.is_deleted = false
                  AND ${valueCondition}
              )
            )
          )
        `;
      } else if (filter.type === "enum_list") {
        const enumFilter = filter as EnumFilter;
        const enumIds = enumFilter.value.map((v) => BigInt(v));
        const p = nextParam(enumIds);
        valueCondition = `enum_value = ANY(${p})`;

        whereClause += `
          AND (
            EXISTS (
              SELECT 1 FROM product_variant_attribute_value pvav
              WHERE pvav.product_variant = pv.id
                AND pvav.category_attribute = ANY(${catAttrIdsParam})
                AND pvav.is_deleted = false
                AND ${valueCondition}
            )
            OR (
              NOT EXISTS (
                SELECT 1 FROM product_variant_attribute_value pvav
                WHERE pvav.product_variant = pv.id
                  AND pvav.category_attribute = ANY(${catAttrIdsParam})
                  AND pvav.is_deleted = false
              )
              AND EXISTS (
                SELECT 1 FROM product_attribute_value pav
                WHERE pav.product = p.id
                  AND pav.category_attribute = ANY(${catAttrIdsParam})
                  AND pav.is_deleted = false
                  AND ${valueCondition}
              )
            )
          )
        `;
      } else if (filter.type === "string") {
        const strFilter = filter as StringFilter;
        const p = nextParam(strFilter.value);
        valueCondition = `string_value = ${p}`;

        whereClause += `
          AND (
            EXISTS (
              SELECT 1 FROM product_variant_attribute_value pvav
              WHERE pvav.product_variant = pv.id
                AND pvav.category_attribute = ANY(${catAttrIdsParam})
                AND pvav.is_deleted = false
                AND ${valueCondition}
            )
            OR (
              NOT EXISTS (
                SELECT 1 FROM product_variant_attribute_value pvav
                WHERE pvav.product_variant = pv.id
                  AND pvav.category_attribute = ANY(${catAttrIdsParam})
                  AND pvav.is_deleted = false
              )
              AND EXISTS (
                SELECT 1 FROM product_attribute_value pav
                WHERE pav.product = p.id
                  AND pav.category_attribute = ANY(${catAttrIdsParam})
                  AND pav.is_deleted = false
                  AND ${valueCondition}
              )
            )
          )
        `;
      }
    }

    // --- Sort clause ---
    let sortJoin = "";
    let orderByClause = "p.name ASC, b.name ASC, p.id ASC, pv.id ASC";

    if (sort) {
      const sortAttrInfo = attrMap.get(sort.attributeId)!;
      const sortCatAttrIds = allCatAttrs
        .filter((ca) => ca.attributeId.toString() === sort.attributeId)
        .map((ca) => ca.catAttrId);
      const sortCatAttrParam = nextParam(sortCatAttrIds);

      // Determine which value column to sort on
      let sortValueCol: string;
      if (sortAttrInfo.type === "number") {
        sortValueCol = "number_value";
      } else if (sortAttrInfo.type === "bool") {
        sortValueCol = "bool_value";
      } else {
        sortValueCol = "string_value";
      }

      sortJoin = `
        LEFT JOIN LATERAL (
          SELECT COALESCE(pvav_sort.${sortValueCol}, pav_sort.${sortValueCol}) AS sort_val
          FROM (SELECT 1) AS _dummy
          LEFT JOIN LATERAL (
            SELECT ${sortValueCol}
            FROM product_variant_attribute_value
            WHERE product_variant = pv.id
              AND category_attribute = ANY(${sortCatAttrParam})
              AND is_deleted = false
            LIMIT 1
          ) pvav_sort ON true
          LEFT JOIN LATERAL (
            SELECT ${sortValueCol}
            FROM product_attribute_value
            WHERE product = p.id
              AND category_attribute = ANY(${sortCatAttrParam})
              AND is_deleted = false
            LIMIT 1
          ) pav_sort ON pvav_sort.${sortValueCol} IS NULL
          LIMIT 1
        ) sort_data ON true
      `;

      const dir = sort.direction === "desc" ? "DESC" : "ASC";
      orderByClause = `(sort_data.sort_val IS NULL) ASC, sort_data.sort_val ${dir}, p.name ASC, b.name ASC, p.id ASC, pv.id ASC`;
    }

    // --- Count query ---
    const countSql = `
      SELECT COUNT(*) as count
      FROM product_variant pv
      JOIN product p ON pv.product = p.id
      JOIN brand b ON p.brand = b.id
      WHERE ${whereClause}
    `;
    const countResult = await prisma.$queryRawUnsafe<CountRow[]>(countSql, ...params);
    const totalRows = Number(countResult[0].count);

    // --- Data query ---
    const limitParam = nextParam(limit);
    const offsetParam = nextParam(offset);

    const dataSql = `
      SELECT
        pv.id AS variant_id, pv.name AS variant_name,
        p.id AS product_id, p.name AS product_name,
        p.brand AS brand_id, b.name AS brand_name,
        p.primary_category AS primary_category_id
      FROM product_variant pv
      JOIN product p ON pv.product = p.id
      JOIN brand b ON p.brand = b.id
      ${sortJoin}
      WHERE ${whereClause}
      ORDER BY ${orderByClause}
      LIMIT ${limitParam} OFFSET ${offsetParam}
    `;
    const variantRows = await prisma.$queryRawUnsafe<VariantRow[]>(dataSql, ...params);

    // --- Fetch attribute values for returned variants ---
    const variantIds = variantRows.map((r) => r.variant_id);
    const allCatAttrIds = allCatAttrs.map((ca) => ca.catAttrId);

    let attrValuesByVariant = new Map<string, Map<string, { type: string; value: unknown }>>();

    if (variantIds.length > 0 && allCatAttrIds.length > 0) {
      // Query for resolved attribute values (variant overrides product)
      const attrSql = `
        SELECT
          pv.id AS variant_id,
          a.id AS attribute_id,
          a.type AS attr_type,
          COALESCE(pvav.number_value, pav.number_value) AS number_value,
          COALESCE(pvav.string_value, pav.string_value) AS string_value,
          COALESCE(pvav.bool_value, pav.bool_value) AS bool_value,
          COALESCE(pvav.enum_value, pav.enum_value) AS enum_value,
          eav.id AS enum_id,
          eav.slug AS enum_slug,
          eav.name AS enum_name
        FROM product_variant pv
        JOIN product p ON pv.product = p.id
        CROSS JOIN (
          SELECT DISTINCT ca.id AS ca_id, ca.attribute AS attr_id
          FROM category_attribute ca
          WHERE ca.id = ANY($1) AND ca.is_deleted = false
        ) cats
        JOIN attribute a ON cats.attr_id = a.id AND a.is_deleted = false
        LEFT JOIN product_variant_attribute_value pvav
          ON pvav.product_variant = pv.id AND pvav.category_attribute = cats.ca_id AND pvav.is_deleted = false
        LEFT JOIN product_attribute_value pav
          ON pav.product = p.id AND pav.category_attribute = cats.ca_id AND pav.is_deleted = false
          AND pvav.id IS NULL
        LEFT JOIN enum_attribute_vals eav
          ON eav.id = COALESCE(pvav.enum_value, pav.enum_value) AND eav.is_deleted = false
        WHERE pv.id = ANY($2)
          AND (pvav.id IS NOT NULL OR pav.id IS NOT NULL)
      `;
      const attrRows = await prisma.$queryRawUnsafe<AttrValueRow[]>(
        attrSql,
        allCatAttrIds,
        variantIds
      );

      for (const row of attrRows) {
        const vId = row.variant_id.toString();
        const aId = row.attribute_id.toString();
        if (!attrValuesByVariant.has(vId)) {
          attrValuesByVariant.set(vId, new Map());
        }
        const attrMapForVariant = attrValuesByVariant.get(vId)!;

        // Skip if we already have a value for this attribute (dedup)
        if (attrMapForVariant.has(aId)) continue;

        const type = row.attr_type;
        let value: unknown = null;

        if (type === "number" && row.number_value !== null) {
          value = row.number_value;
        } else if (type === "bool" && row.bool_value !== null) {
          value = row.bool_value;
        } else if (type === "string" && row.string_value !== null) {
          value = row.string_value;
        } else if (type === "enum_list" && row.enum_id !== null) {
          value = {
            id: row.enum_id.toString(),
            slug: row.enum_slug,
            name: row.enum_name,
          };
        }

        if (value !== null) {
          attrMapForVariant.set(aId, { type, value });
        }
      }
    }

    // --- Build rows ---
    const rows = variantRows.map((r) => {
      const vId = r.variant_id.toString();
      const attrs: Record<string, { type: string; value: unknown }> = {};
      const variantAttrs = attrValuesByVariant.get(vId);
      if (variantAttrs) {
        for (const [attrId, attrVal] of variantAttrs) {
          attrs[attrId] = attrVal;
        }
      }

      return {
        variantId: bigintStr(r.variant_id),
        productId: bigintStr(r.product_id),
        productName: r.product_name,
        variantName: r.variant_name,
        brandId: bigintStr(r.brand_id),
        brandName: r.brand_name,
        primaryCategoryId: bigintStr(r.primary_category_id),
        attributes: attrs,
      };
    });

    // --- Build columns ---
    const columns: object[] = [
      { key: "productName", label: "Product", pinned: true },
      { key: "brandName", label: "Brand", pinned: true },
    ];

    // Collect filtered attribute IDs in order
    const filteredAttrIds = new Set<string>();
    for (const f of filters) {
      filteredAttrIds.add(f.attributeId);
    }

    // Dedupe attributes that have already been added as columns
    const addedAttrIds = new Set<string>();

    // 1. Filtered attributes first (in filter order, deduped)
    for (const attrId of filteredAttrIds) {
      if (addedAttrIds.has(attrId)) continue;
      const info = attrMap.get(attrId);
      if (!info) continue;
      addedAttrIds.add(attrId);
      columns.push(makeAttrColumn(info));
    }

    // 2. Build ordered category attribute list
    // Determine depth of each category for ordering
    // Ancestors are root-first, then selected category, then children
    // ancestorIds includes the selected category; subtreeIds includes selected + descendants

    // Ancestor IDs excluding the selected category, ordered root-first
    const ancestorOnlyIds = ancestorIds.filter((id) => id !== categoryId);
    // We need to order ancestors root-first. The recursive CTE returns them in
    // child-to-root order, so reverse them.
    ancestorOnlyIds.reverse();

    // Child/descendant IDs (subtree excluding selected category)
    const childIds = subtreeIds.filter((id) => id !== categoryId);

    // Build ordering: ancestors (root-first), then selected, then children (by id)
    const categoryOrder: bigint[] = [
      ...ancestorOnlyIds,
      categoryId,
      ...childIds.sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)),
    ];

    // Group catAttrs by category, sorted by priority then attribute id
    for (const catId of categoryOrder) {
      const attrsForCat = allCatAttrs
        .filter((ca) => ca.categoryId === catId)
        .sort((a, b) => a.priority - b.priority || (a.attributeId < b.attributeId ? -1 : 1));

      for (const ca of attrsForCat) {
        const attrIdStr = ca.attributeId.toString();
        if (addedAttrIds.has(attrIdStr)) continue;
        const info = attrMap.get(attrIdStr);
        if (!info) continue;
        addedAttrIds.add(attrIdStr);
        columns.push(makeAttrColumn(info));
      }
    }

    return NextResponse.json({
      rows,
      columns,
      pagination: {
        limit,
        offset,
        totalRows,
      },
    });
  } catch (error) {
    console.error("Product search failed:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

function makeAttrColumn(info: AttributeInfo) {
  return {
    key: `attr:${info.id}`,
    label: info.name,
    attributeId: info.id.toString(),
    type: info.type,
    numberUnit: info.type === "number" ? info.numberUnit : null,
    sortable: info.type !== "enum_list",
    pinned: false,
  };
}
