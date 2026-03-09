import { describe, it, expect, beforeEach, afterAll, vi } from "vitest";
import { prisma, resetDB, disconnectDB } from "../setup/db";

vi.mock("@/lib/prisma", async () => {
  const { prisma } = await import("../setup/db");
  return { default: prisma };
});

import { POST } from "@/app/api/products/search/route";

afterAll(async () => {
  await disconnectDB();
});

// --- Seed helpers ---

async function createCategory(
  overrides: Partial<{
    slug: string;
    name: string;
    parent_category: bigint;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.category.create({
    data: {
      slug: overrides.slug ?? "cat",
      name: overrides.name ?? "Category",
      is_deleted: overrides.is_deleted ?? false,
      ...(overrides.parent_category != null
        ? { category: { connect: { id: overrides.parent_category } } }
        : {}),
    },
  });
}

async function createAttribute(
  overrides: Partial<{
    slug: string;
    name: string;
    type: "number" | "bool" | "enum_list" | "string";
    number_unit: "weight_g" | "length_mm" | "volume_ml" | "int" | "float" | "NA";
    is_deleted: boolean;
  }> = {}
) {
  return prisma.attribute.create({
    data: {
      slug: overrides.slug ?? "attr",
      name: overrides.name ?? "Attribute",
      type: overrides.type ?? "number",
      number_unit: overrides.number_unit ?? "NA",
      is_deleted: overrides.is_deleted ?? false,
    },
  });
}

async function createEnumVal(
  attributeId: bigint,
  overrides: Partial<{
    slug: string;
    name: string;
    display_order: number;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.enum_attribute_vals.create({
    data: {
      attribute_enum_attribute_vals_attributeToattribute: {
        connect: { id: attributeId },
      },
      slug: overrides.slug ?? "val",
      name: overrides.name ?? "Value",
      display_order: overrides.display_order ?? 0,
      is_deleted: overrides.is_deleted ?? false,
    },
  });
}

async function createCategoryAttribute(
  categoryId: bigint,
  attributeId: bigint,
  overrides: Partial<{
    priority: number;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.category_attribute.create({
    data: {
      category_rel: { connect: { id: categoryId } },
      attribute_rel: { connect: { id: attributeId } },
      priority: overrides.priority ?? 0,
      is_deleted: overrides.is_deleted ?? false,
    },
  });
}

async function createBrand(
  overrides: Partial<{
    slug: string;
    name: string;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.brand.create({
    data: {
      slug: overrides.slug ?? "brand",
      name: overrides.name ?? "Brand",
      is_deleted: overrides.is_deleted ?? false,
    },
  });
}

async function createProduct(
  brandId: bigint,
  categoryId: bigint,
  overrides: Partial<{
    slug: string;
    name: string;
    visibility: "public" | "private" | "link_access";
    is_deleted: boolean;
  }> = {}
) {
  return prisma.product.create({
    data: {
      slug: overrides.slug ?? "product",
      name: overrides.name ?? "Product",
      visibility: overrides.visibility ?? "public",
      is_deleted: overrides.is_deleted ?? false,
      brand_product_brandTobrand: { connect: { id: brandId } },
      category: { connect: { id: categoryId } },
    },
  });
}

async function createVariant(
  productId: bigint,
  overrides: Partial<{
    slug: string;
    name: string;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.product_variant.create({
    data: {
      slug: overrides.slug ?? "variant",
      name: overrides.name ?? "Variant",
      is_deleted: overrides.is_deleted ?? false,
      product_product_variant_productToproduct: { connect: { id: productId } },
    },
  });
}

async function createProductAttrValue(
  productId: bigint,
  catAttrId: bigint,
  values: Partial<{
    number_value: number;
    string_value: string;
    bool_value: boolean;
    enum_value: bigint;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.product_attribute_value.create({
    data: {
      product_product_attribute_value_productToproduct: { connect: { id: productId } },
      category_attribute_rel: { connect: { id: catAttrId } },
      number_value: values.number_value ?? null,
      string_value: values.string_value ?? null,
      bool_value: values.bool_value ?? null,
      ...(values.enum_value != null
        ? { enum_attribute_vals: { connect: { id: values.enum_value } } }
        : {}),
      is_deleted: values.is_deleted ?? false,
    },
  });
}

async function createVariantAttrValue(
  variantId: bigint,
  catAttrId: bigint,
  values: Partial<{
    number_value: number;
    string_value: string;
    bool_value: boolean;
    enum_value: bigint;
    is_deleted: boolean;
  }> = {}
) {
  return prisma.product_variant_attribute_value.create({
    data: {
      product_variant_product_variant_attribute_value_product_variantToproduct_variant: {
        connect: { id: variantId },
      },
      category_attribute_rel: { connect: { id: catAttrId } },
      number_value: values.number_value ?? null,
      string_value: values.string_value ?? null,
      bool_value: values.bool_value ?? null,
      ...(values.enum_value != null
        ? { enum_attribute_vals: { connect: { id: values.enum_value } } }
        : {}),
      is_deleted: values.is_deleted ?? false,
    },
  });
}

async function createProductCategory(productId: bigint, categoryId: bigint) {
  return prisma.product_category.create({
    data: {
      product_product_category_productToproduct: { connect: { id: productId } },
      category_product_category_categoryTocategory: { connect: { id: categoryId } },
    },
  });
}

function makeRequest(body: unknown) {
  return new Request("http://localhost/api/products/search", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

// --- Common seed: category + brand + product + variant ---

async function seedBasic() {
  const cat = await createCategory({ slug: "pads", name: "Pads" });
  const brand = await createBrand({ slug: "thermarest", name: "Therm-a-Rest" });
  const product = await createProduct(brand.id, cat.id, {
    slug: "xlite",
    name: "XLite",
  });
  const variant = await createVariant(product.id, {
    slug: "regular",
    name: "Regular",
  });
  return { cat, brand, product, variant };
}

// --- Tests ---

describe("POST /api/products/search", () => {
  beforeEach(async () => {
    await resetDB();
  });

  // === A. Validation ===

  describe("validation", () => {
    it("returns 400 for missing categoryId", async () => {
      const res = await POST(makeRequest({}));
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("Invalid or missing categoryId");
    });

    it("returns 400 for non-existent categoryId", async () => {
      const res = await POST(makeRequest({ categoryId: "999999" }));
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("Invalid or missing categoryId");
    });

    it("returns 400 for deleted category", async () => {
      const cat = await createCategory({ slug: "del", name: "Deleted", is_deleted: true });
      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("Invalid or missing categoryId");
    });

    it("returns 400 for filter attributeId not in resolved schema", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const attr = await createAttribute({ slug: "weight", name: "Weight" });
      // attr is NOT linked to cat via category_attribute
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: attr.id.toString(), type: "number", operator: "gte", value: 100 },
          ],
        })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe(
        `Attribute ${attr.id} is not valid for category ${cat.id}`
      );
    });

    it("returns 400 for filter type mismatch", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      await createCategoryAttribute(cat.id, attr.id);
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: attr.id.toString(), type: "bool", value: true },
          ],
        })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe(`Filter type mismatch for attribute ${attr.id}`);
    });

    it("returns 400 for between with min > max", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      await createCategoryAttribute(cat.id, attr.id);
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: attr.id.toString(), type: "number", operator: "between", value: [10, 5] },
          ],
        })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("between filter requires [min, max] where min <= max");
    });

    it("returns 400 for empty enum_list filter value", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const attr = await createAttribute({ slug: "shape", name: "Shape", type: "enum_list" });
      await createCategoryAttribute(cat.id, attr.id);
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: attr.id.toString(), type: "enum_list", value: [] },
          ],
        })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("enum_list filter requires at least one value");
    });

    it("returns 400 for sort on enum_list attribute", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const attr = await createAttribute({ slug: "shape", name: "Shape", type: "enum_list" });
      await createCategoryAttribute(cat.id, attr.id);
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          sort: { attributeId: attr.id.toString(), direction: "asc" },
        })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("Cannot sort by enum_list attribute");
    });

    it("returns 400 for sort attribute not in schema", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const attr = await createAttribute({ slug: "weight", name: "Weight" });
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          sort: { attributeId: attr.id.toString(), direction: "asc" },
        })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe(
        `Sort attribute ${attr.id} is not valid for category ${cat.id}`
      );
    });

    it("returns 400 for limit outside 1-100", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const res = await POST(
        makeRequest({ categoryId: cat.id.toString(), limit: 0 })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("limit must be between 1 and 100");

      const res2 = await POST(
        makeRequest({ categoryId: cat.id.toString(), limit: 101 })
      );
      const body2 = await res2.json();
      expect(res2.status).toBe(400);
      expect(body2.error).toBe("limit must be between 1 and 100");
    });

    it("returns 400 for offset < 0", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const res = await POST(
        makeRequest({ categoryId: cat.id.toString(), offset: -1 })
      );
      const body = await res.json();
      expect(res.status).toBe(400);
      expect(body.error).toBe("offset must be >= 0");
    });
  });

  // === B. Category Matching ===

  describe("category matching", () => {
    it("returns variants matching primary category", async () => {
      const { cat, variant } = await seedBasic();
      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(res.status).toBe(200);
      expect(body.rows).toHaveLength(1);
      expect(body.rows[0].variantId).toBe(variant.id.toString());
    });

    it("returns variants matching secondary category", async () => {
      const cat1 = await createCategory({ slug: "pads", name: "Pads" });
      const cat2 = await createCategory({ slug: "insulated", name: "Insulated" });
      const brand = await createBrand({ slug: "b", name: "Brand" });
      const product = await createProduct(brand.id, cat1.id, { slug: "p", name: "P" });
      const variant = await createVariant(product.id, { slug: "v", name: "V" });
      await createProductCategory(product.id, cat2.id);

      const res = await POST(makeRequest({ categoryId: cat2.id.toString() }));
      const body = await res.json();
      expect(res.status).toBe(200);
      expect(body.rows).toHaveLength(1);
      expect(body.rows[0].variantId).toBe(variant.id.toString());
    });

    it("returns variants from descendant categories", async () => {
      const parent = await createCategory({ slug: "sleep", name: "Sleep" });
      const child = await createCategory({
        slug: "pads",
        name: "Pads",
        parent_category: parent.id,
      });
      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, child.id, { slug: "p", name: "P" });
      const variant = await createVariant(product.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: parent.id.toString() }));
      const body = await res.json();
      expect(body.rows).toHaveLength(1);
      expect(body.rows[0].variantId).toBe(variant.id.toString());
    });

    it("excludes variants from unrelated categories", async () => {
      const cat1 = await createCategory({ slug: "pads", name: "Pads" });
      const cat2 = await createCategory({ slug: "packs", name: "Packs" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, cat2.id, { slug: "p", name: "P" });
      await createVariant(product.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: cat1.id.toString() }));
      const body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("excludes deleted products", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, cat.id, {
        slug: "p",
        name: "P",
        is_deleted: true,
      });
      await createVariant(product.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("excludes deleted variants", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, cat.id, { slug: "p", name: "P" });
      await createVariant(product.id, { slug: "v", name: "V", is_deleted: true });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("excludes private products", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, cat.id, {
        slug: "p",
        name: "P",
        visibility: "private",
      });
      await createVariant(product.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows).toHaveLength(0);
    });
  });

  // === C. Attribute Value Resolution ===

  describe("attribute value resolution", () => {
    it("returns product-level attribute value when no variant override", async () => {
      const { cat, product, variant } = await seedBasic();
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { number_value: 350 });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows[0].attributes[attr.id.toString()]).toEqual({
        type: "number",
        value: 350,
      });
    });

    it("returns variant-level value when override exists", async () => {
      const { cat, product, variant } = await seedBasic();
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { number_value: 350 });
      await createVariantAttrValue(variant.id, ca.id, { number_value: 400 });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows[0].attributes[attr.id.toString()]).toEqual({
        type: "number",
        value: 400,
      });
    });

    it("omits attribute from row when no value exists at either level", async () => {
      const { cat, variant } = await seedBasic();
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      await createCategoryAttribute(cat.id, attr.id);

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows[0].attributes[attr.id.toString()]).toBeUndefined();
    });
  });

  // === D. Filters ===

  describe("filters", () => {
    async function seedWithNumberAttr(value: number) {
      const { cat, product, variant, brand } = await seedBasic();
      const attr = await createAttribute({
        slug: "weight",
        name: "Weight",
        type: "number",
        number_unit: "weight_g",
      });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { number_value: value });
      return { cat, product, variant, brand, attr, ca };
    }

    it("number gte filter", async () => {
      const { cat, attr } = await seedWithNumberAttr(350);
      // Should match: 350 >= 300
      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "gte", value: 300 }],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      // Should not match: 350 >= 400
      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "gte", value: 400 }],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("number lte filter", async () => {
      const { cat, attr } = await seedWithNumberAttr(350);
      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "lte", value: 400 }],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "lte", value: 300 }],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("number eq filter", async () => {
      const { cat, attr } = await seedWithNumberAttr(350);
      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "eq", value: 350 }],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "eq", value: 300 }],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("number between filter", async () => {
      const { cat, attr } = await seedWithNumberAttr(350);
      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "between", value: [300, 400] }],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "between", value: [400, 500] }],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("bool filter", async () => {
      const { cat, product, variant } = await seedBasic();
      const attr = await createAttribute({ slug: "insulated", name: "Insulated", type: "bool" });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { bool_value: true });

      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "bool", value: true }],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "bool", value: false }],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("enum filter single value", async () => {
      const { cat, product } = await seedBasic();
      const attr = await createAttribute({ slug: "shape", name: "Shape", type: "enum_list" });
      const enumVal = await createEnumVal(attr.id, { slug: "mummy", name: "Mummy" });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { enum_value: enumVal.id });

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "enum_list", value: [enumVal.id.toString()] }],
        })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(1);
    });

    it("enum filter multiple values (OR)", async () => {
      const { cat, product } = await seedBasic();
      const attr = await createAttribute({ slug: "shape", name: "Shape", type: "enum_list" });
      const mummy = await createEnumVal(attr.id, { slug: "mummy", name: "Mummy", display_order: 1 });
      const rect = await createEnumVal(attr.id, { slug: "rect", name: "Rectangular", display_order: 2 });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { enum_value: mummy.id });

      // Should match: mummy is in [mummy, rect]
      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: attr.id.toString(), type: "enum_list", value: [mummy.id.toString(), rect.id.toString()] },
          ],
        })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(1);
    });

    it("string filter exact match", async () => {
      const { cat, product } = await seedBasic();
      const attr = await createAttribute({ slug: "season", name: "Season", type: "string" });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { string_value: "3-season" });

      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "string", value: "3-season" }],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "string", value: "4-season" }],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("multiple filters ANDed", async () => {
      const { cat, product, variant } = await seedBasic();
      const weightAttr = await createAttribute({
        slug: "weight",
        name: "Weight",
        type: "number",
      });
      const boolAttr = await createAttribute({
        slug: "insulated",
        name: "Insulated",
        type: "bool",
      });
      const caWeight = await createCategoryAttribute(cat.id, weightAttr.id);
      const caBool = await createCategoryAttribute(cat.id, boolAttr.id);
      await createProductAttrValue(product.id, caWeight.id, { number_value: 350 });
      await createProductAttrValue(product.id, caBool.id, { bool_value: true });

      // Both match
      let res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: weightAttr.id.toString(), type: "number", operator: "gte", value: 300 },
            { attributeId: boolAttr.id.toString(), type: "bool", value: true },
          ],
        })
      );
      let body = await res.json();
      expect(body.rows).toHaveLength(1);

      // Weight matches but bool doesn't
      res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [
            { attributeId: weightAttr.id.toString(), type: "number", operator: "gte", value: 300 },
            { attributeId: boolAttr.id.toString(), type: "bool", value: false },
          ],
        })
      );
      body = await res.json();
      expect(body.rows).toHaveLength(0);
    });

    it("missing attribute values excluded by filters", async () => {
      const { cat, attr } = await seedBasic();
      // No attribute values set, but we filter on a number attr
      const weightAttr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      await createCategoryAttribute(cat.id, weightAttr.id);

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: weightAttr.id.toString(), type: "number", operator: "gte", value: 0 }],
        })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(0);
    });
  });

  // === E. Sorting ===

  describe("sorting", () => {
    it("sort by number ascending", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const ca = await createCategoryAttribute(cat.id, attr.id);

      const p1 = await createProduct(brand.id, cat.id, { slug: "heavy", name: "Heavy" });
      const v1 = await createVariant(p1.id, { slug: "v1", name: "V1" });
      await createProductAttrValue(p1.id, ca.id, { number_value: 500 });

      const p2 = await createProduct(brand.id, cat.id, { slug: "light", name: "Light" });
      const v2 = await createVariant(p2.id, { slug: "v2", name: "V2" });
      await createProductAttrValue(p2.id, ca.id, { number_value: 200 });

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          sort: { attributeId: attr.id.toString(), direction: "asc" },
        })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(2);
      expect(body.rows[0].variantId).toBe(v2.id.toString());
      expect(body.rows[1].variantId).toBe(v1.id.toString());
    });

    it("sort by number descending", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const ca = await createCategoryAttribute(cat.id, attr.id);

      const p1 = await createProduct(brand.id, cat.id, { slug: "heavy", name: "Heavy" });
      const v1 = await createVariant(p1.id, { slug: "v1", name: "V1" });
      await createProductAttrValue(p1.id, ca.id, { number_value: 500 });

      const p2 = await createProduct(brand.id, cat.id, { slug: "light", name: "Light" });
      const v2 = await createVariant(p2.id, { slug: "v2", name: "V2" });
      await createProductAttrValue(p2.id, ca.id, { number_value: 200 });

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          sort: { attributeId: attr.id.toString(), direction: "desc" },
        })
      );
      const body = await res.json();
      expect(body.rows[0].variantId).toBe(v1.id.toString());
      expect(body.rows[1].variantId).toBe(v2.id.toString());
    });

    it("missing values sorted last (asc)", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const ca = await createCategoryAttribute(cat.id, attr.id);

      const pWithVal = await createProduct(brand.id, cat.id, { slug: "with", name: "With" });
      const vWithVal = await createVariant(pWithVal.id, { slug: "v1", name: "V1" });
      await createProductAttrValue(pWithVal.id, ca.id, { number_value: 500 });

      const pNoVal = await createProduct(brand.id, cat.id, { slug: "without", name: "Without" });
      const vNoVal = await createVariant(pNoVal.id, { slug: "v2", name: "V2" });
      // No attribute value

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          sort: { attributeId: attr.id.toString(), direction: "asc" },
        })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(2);
      expect(body.rows[0].variantId).toBe(vWithVal.id.toString());
      expect(body.rows[1].variantId).toBe(vNoVal.id.toString());
    });

    it("missing values sorted last (desc)", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      const attr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const ca = await createCategoryAttribute(cat.id, attr.id);

      const pWithVal = await createProduct(brand.id, cat.id, { slug: "with", name: "With" });
      const vWithVal = await createVariant(pWithVal.id, { slug: "v1", name: "V1" });
      await createProductAttrValue(pWithVal.id, ca.id, { number_value: 500 });

      const pNoVal = await createProduct(brand.id, cat.id, { slug: "without", name: "Without" });
      const vNoVal = await createVariant(pNoVal.id, { slug: "v2", name: "V2" });

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          sort: { attributeId: attr.id.toString(), direction: "desc" },
        })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(2);
      expect(body.rows[0].variantId).toBe(vWithVal.id.toString());
      expect(body.rows[1].variantId).toBe(vNoVal.id.toString());
    });

    it("default sort uses product_name, brand_name, product_id, variant_id", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brandA = await createBrand({ slug: "a", name: "Alpha" });
      const brandB = await createBrand({ slug: "b", name: "Beta" });

      // Same product name, different brand
      const p1 = await createProduct(brandB.id, cat.id, { slug: "pad", name: "Pad" });
      const v1 = await createVariant(p1.id, { slug: "v1", name: "V1" });
      const p2 = await createProduct(brandA.id, cat.id, { slug: "pad2", name: "Pad" });
      const v2 = await createVariant(p2.id, { slug: "v2", name: "V2" });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows).toHaveLength(2);
      // Same product name "Pad", so sorted by brand name: Alpha < Beta
      expect(body.rows[0].variantId).toBe(v2.id.toString());
      expect(body.rows[1].variantId).toBe(v1.id.toString());
    });
  });

  // === F. Pagination ===

  describe("pagination", () => {
    it("default limit=25, offset=0", async () => {
      const { cat } = await seedBasic();
      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.pagination.limit).toBe(25);
      expect(body.pagination.offset).toBe(0);
    });

    it("custom limit and offset", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      // Create 3 products with variants
      for (let i = 0; i < 3; i++) {
        const p = await createProduct(brand.id, cat.id, {
          slug: `p${i}`,
          name: `Product ${i}`,
        });
        await createVariant(p.id, { slug: `v${i}`, name: `V${i}` });
      }

      const res = await POST(
        makeRequest({ categoryId: cat.id.toString(), limit: 2, offset: 1 })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(2);
      expect(body.pagination.limit).toBe(2);
      expect(body.pagination.offset).toBe(1);
    });

    it("totalRows reflects full count", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const brand = await createBrand({ slug: "b", name: "B" });
      for (let i = 0; i < 5; i++) {
        const p = await createProduct(brand.id, cat.id, {
          slug: `p${i}`,
          name: `Product ${i}`,
        });
        await createVariant(p.id, { slug: `v${i}`, name: `V${i}` });
      }

      const res = await POST(
        makeRequest({ categoryId: cat.id.toString(), limit: 2, offset: 0 })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(2);
      expect(body.pagination.totalRows).toBe(5);
    });

    it("empty rows when offset exceeds total", async () => {
      const { cat } = await seedBasic();
      const res = await POST(
        makeRequest({ categoryId: cat.id.toString(), limit: 25, offset: 100 })
      );
      const body = await res.json();
      expect(body.rows).toHaveLength(0);
      expect(body.pagination.totalRows).toBe(1);
    });
  });

  // === G. Columns ===

  describe("columns", () => {
    it("pinned columns first", async () => {
      const { cat } = await seedBasic();
      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.columns[0]).toEqual({
        key: "productName",
        label: "Product",
        pinned: true,
      });
      expect(body.columns[1]).toEqual({
        key: "brandName",
        label: "Brand",
        pinned: true,
      });
    });

    it("filtered attributes appear after pinned", async () => {
      const { cat } = await seedBasic();
      const attr = await createAttribute({
        slug: "weight",
        name: "Weight",
        type: "number",
        number_unit: "weight_g",
      });
      await createCategoryAttribute(cat.id, attr.id);

      const res = await POST(
        makeRequest({
          categoryId: cat.id.toString(),
          filters: [{ attributeId: attr.id.toString(), type: "number", operator: "gte", value: 0 }],
        })
      );
      const body = await res.json();
      // columns[0] = productName, [1] = brandName, [2] = filtered attr
      expect(body.columns[2]).toMatchObject({
        key: `attr:${attr.id}`,
        label: "Weight",
        attributeId: attr.id.toString(),
        type: "number",
        numberUnit: "weight_g",
        sortable: true,
        pinned: false,
      });
    });

    it("selected + parent attributes share priority tier before descendants", async () => {
      const parent = await createCategory({ slug: "sleep", name: "Sleep" });
      const selected = await createCategory({
        slug: "pads",
        name: "Pads",
        parent_category: parent.id,
      });
      const child = await createCategory({
        slug: "ultralight-pads",
        name: "Ultralight Pads",
        parent_category: selected.id,
      });

      const selectedAttr = await createAttribute({
        slug: "r-value",
        name: "R Value",
        type: "number",
      });
      const parentAttr = await createAttribute({
        slug: "weight",
        name: "Weight",
        type: "number",
      });
      const childAttr = await createAttribute({
        slug: "thickness",
        name: "Thickness",
        type: "number",
      });

      await createCategoryAttribute(selected.id, selectedAttr.id, { priority: 1 });
      await createCategoryAttribute(parent.id, parentAttr.id, { priority: 5 });
      await createCategoryAttribute(child.id, childAttr.id, { priority: 0 });

      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, selected.id, { slug: "p", name: "P" });
      await createVariant(product.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: selected.id.toString() }));
      const body = await res.json();

      const attrColumnIds = body.columns
        .filter((c: { pinned: boolean }) => !c.pinned)
        .map((c: { attributeId: string }) => c.attributeId);

      expect(attrColumnIds).toEqual([
        selectedAttr.id.toString(),
        parentAttr.id.toString(),
        childAttr.id.toString(),
      ]);
    });

    it("breaks ties between selected and parent attributes using attribute priority ranking", async () => {
      const parent = await createCategory({ slug: "sleep", name: "Sleep" });
      const selected = await createCategory({
        slug: "pads",
        name: "Pads",
        parent_category: parent.id,
      });

      const selectedAttr = await createAttribute({
        slug: "thickness",
        name: "Thickness",
        type: "number",
      });
      const parentAttr = await createAttribute({
        slug: "weight",
        name: "Weight",
        type: "number",
      });

      await createCategoryAttribute(selected.id, selectedAttr.id, { priority: 1 });
      await createCategoryAttribute(parent.id, parentAttr.id, { priority: 1 });

      const brand = await createBrand({ slug: "b", name: "B" });
      const product = await createProduct(brand.id, selected.id, { slug: "p", name: "P" });
      await createVariant(product.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: selected.id.toString() }));
      const body = await res.json();

      const attrColumnIds = body.columns
        .filter((c: { pinned: boolean }) => !c.pinned)
        .map((c: { attributeId: string }) => c.attributeId);

      expect(attrColumnIds).toEqual([
        selectedAttr.id.toString(),
        parentAttr.id.toString(),
      ]);
    });

    it("enum_list has sortable=false, others sortable=true", async () => {
      const cat = await createCategory({ slug: "pads", name: "Pads" });
      const numAttr = await createAttribute({ slug: "weight", name: "Weight", type: "number" });
      const enumAttr = await createAttribute({ slug: "shape", name: "Shape", type: "enum_list" });
      const boolAttr = await createAttribute({ slug: "insulated", name: "Insulated", type: "bool" });
      const strAttr = await createAttribute({ slug: "season", name: "Season", type: "string" });
      await createCategoryAttribute(cat.id, numAttr.id, { priority: 1 });
      await createCategoryAttribute(cat.id, enumAttr.id, { priority: 2 });
      await createCategoryAttribute(cat.id, boolAttr.id, { priority: 3 });
      await createCategoryAttribute(cat.id, strAttr.id, { priority: 4 });

      const brand = await createBrand({ slug: "b", name: "B" });
      const p = await createProduct(brand.id, cat.id, { slug: "p", name: "P" });
      await createVariant(p.id, { slug: "v", name: "V" });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();

      const attrCols = body.columns.filter((c: { pinned: boolean }) => !c.pinned);
      const numCol = attrCols.find((c: { attributeId: string }) => c.attributeId === numAttr.id.toString());
      const enumCol = attrCols.find((c: { attributeId: string }) => c.attributeId === enumAttr.id.toString());
      const boolCol = attrCols.find((c: { attributeId: string }) => c.attributeId === boolAttr.id.toString());
      const strCol = attrCols.find((c: { attributeId: string }) => c.attributeId === strAttr.id.toString());

      expect(numCol.sortable).toBe(true);
      expect(enumCol.sortable).toBe(false);
      expect(boolCol.sortable).toBe(true);
      expect(strCol.sortable).toBe(true);
    });
  });

  // === H. Response Format ===

  describe("response format", () => {
    it("enum attribute values include { id, slug, name }", async () => {
      const { cat, product, variant } = await seedBasic();
      const attr = await createAttribute({ slug: "shape", name: "Shape", type: "enum_list" });
      const enumVal = await createEnumVal(attr.id, { slug: "mummy", name: "Mummy" });
      const ca = await createCategoryAttribute(cat.id, attr.id);
      await createProductAttrValue(product.id, ca.id, { enum_value: enumVal.id });

      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      expect(body.rows[0].attributes[attr.id.toString()]).toEqual({
        type: "enum_list",
        value: {
          id: enumVal.id.toString(),
          slug: "mummy",
          name: "Mummy",
        },
      });
    });

    it("all IDs are strings", async () => {
      const { cat, brand, product, variant } = await seedBasic();
      const res = await POST(makeRequest({ categoryId: cat.id.toString() }));
      const body = await res.json();
      const row = body.rows[0];
      expect(typeof row.variantId).toBe("string");
      expect(typeof row.productId).toBe("string");
      expect(typeof row.brandId).toBe("string");
      expect(typeof row.primaryCategoryId).toBe("string");
    });
  });
});
