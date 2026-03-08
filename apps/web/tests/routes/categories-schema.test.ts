import { describe, it, expect, beforeEach, afterAll, vi } from "vitest";
import { prisma, resetDB, disconnectDB } from "../setup/db";

vi.mock("@/lib/prisma", async () => {
  const { prisma } = await import("../setup/db");
  return { default: prisma };
});

import { GET } from "@/app/api/categories/schema/route";

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

function makeRequest() {
  return new Request("http://localhost/api/categories/schema");
}

// --- Tests ---

describe("GET /api/categories/schema", () => {
  beforeEach(async () => {
    await resetDB();
  });

  it("returns empty state when no data exists", async () => {
    const res = await GET(makeRequest());
    const body = await res.json();

    expect(res.status).toBe(200);
    expect(body).toEqual({
      categories: [],
      attributes: {},
      categoryAttributes: {},
    });
  });

  it("returns a single root category with children: []", async () => {
    const cat = await createCategory({ slug: "pads", name: "Sleeping Pads" });

    const res = await GET(makeRequest());
    const body = await res.json();

    expect(res.status).toBe(200);
    expect(body.categories).toEqual([
      {
        id: cat.id.toString(),
        slug: "pads",
        name: "Sleeping Pads",
        children: [],
      },
    ]);
  });

  it("nests children under their parent", async () => {
    const parent = await createCategory({ slug: "shelter", name: "Shelter" });
    const child1 = await createCategory({
      slug: "tents",
      name: "Tents",
      parent_category: parent.id,
    });
    const child2 = await createCategory({
      slug: "tarps",
      name: "Tarps",
      parent_category: parent.id,
    });

    const res = await GET(makeRequest());
    const body = await res.json();

    expect(body.categories).toHaveLength(1);
    expect(body.categories[0].id).toBe(parent.id.toString());
    expect(body.categories[0].children).toHaveLength(2);

    const childIds = body.categories[0].children.map(
      (c: { id: string }) => c.id
    );
    expect(childIds).toContain(child1.id.toString());
    expect(childIds).toContain(child2.id.toString());
  });

  it("excludes deleted categories", async () => {
    await createCategory({ slug: "deleted", name: "Deleted", is_deleted: true });
    await createCategory({ slug: "active", name: "Active" });

    const res = await GET(makeRequest());
    const body = await res.json();

    expect(body.categories).toHaveLength(1);
    expect(body.categories[0].slug).toBe("active");
  });

  it("excludes deleted child from parent's children", async () => {
    const parent = await createCategory({ slug: "parent", name: "Parent" });
    await createCategory({
      slug: "alive-child",
      name: "Alive Child",
      parent_category: parent.id,
    });
    await createCategory({
      slug: "dead-child",
      name: "Dead Child",
      parent_category: parent.id,
      is_deleted: true,
    });

    const res = await GET(makeRequest());
    const body = await res.json();

    expect(body.categories).toHaveLength(1);
    expect(body.categories[0].children).toHaveLength(1);
    expect(body.categories[0].children[0].slug).toBe("alive-child");
  });

  it("returns a number attribute in the attributes map", async () => {
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const attr = await createAttribute({
      slug: "weight",
      name: "Weight",
      type: "number",
      number_unit: "weight_g",
    });
    await createCategoryAttribute(cat.id, attr.id, { priority: 1 });

    const res = await GET(makeRequest());
    const body = await res.json();

    const key = attr.id.toString();
    expect(body.attributes[key]).toEqual({
      id: key,
      slug: "weight",
      name: "Weight",
      type: "number",
      numberUnit: "weight_g",
      enumOptions: null,
    });
  });

  it("returns enum attribute with sorted options", async () => {
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const attr = await createAttribute({
      slug: "shape",
      name: "Shape",
      type: "enum_list",
    });
    const val2 = await createEnumVal(attr.id, {
      slug: "rect",
      name: "Rectangular",
      display_order: 2,
    });
    const val1 = await createEnumVal(attr.id, {
      slug: "mummy",
      name: "Mummy",
      display_order: 1,
    });
    await createCategoryAttribute(cat.id, attr.id);

    const res = await GET(makeRequest());
    const body = await res.json();

    const key = attr.id.toString();
    expect(body.attributes[key].enumOptions).toEqual([
      { id: val1.id.toString(), slug: "mummy", name: "Mummy", displayOrder: 1 },
      { id: val2.id.toString(), slug: "rect", name: "Rectangular", displayOrder: 2 },
    ]);
  });

  it("excludes deleted enum options", async () => {
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const attr = await createAttribute({
      slug: "shape",
      name: "Shape",
      type: "enum_list",
    });
    await createEnumVal(attr.id, {
      slug: "active",
      name: "Active",
      display_order: 1,
    });
    await createEnumVal(attr.id, {
      slug: "deleted",
      name: "Deleted",
      display_order: 2,
      is_deleted: true,
    });
    await createCategoryAttribute(cat.id, attr.id);

    const res = await GET(makeRequest());
    const body = await res.json();

    const key = attr.id.toString();
    expect(body.attributes[key].enumOptions).toHaveLength(1);
    expect(body.attributes[key].enumOptions[0].slug).toBe("active");
  });

  it("returns category-attribute mappings", async () => {
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const attr = await createAttribute({ slug: "weight", name: "Weight" });
    await createCategoryAttribute(cat.id, attr.id, { priority: 5 });

    const res = await GET(makeRequest());
    const body = await res.json();

    const catKey = cat.id.toString();
    expect(body.categoryAttributes[catKey]).toEqual([
      { attributeId: attr.id.toString(), priority: 5 },
    ]);
  });

  it("excludes deleted category_attributes", async () => {
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const attr = await createAttribute({ slug: "weight", name: "Weight" });
    await createCategoryAttribute(cat.id, attr.id, {
      priority: 1,
      is_deleted: true,
    });

    const res = await GET(makeRequest());
    const body = await res.json();

    expect(body.categoryAttributes).toEqual({});
  });

  it("only includes attributes referenced by category_attributes", async () => {
    await createAttribute({ slug: "orphan", name: "Orphan Attribute" });
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const linked = await createAttribute({ slug: "linked", name: "Linked" });
    await createCategoryAttribute(cat.id, linked.id);

    const res = await GET(makeRequest());
    const body = await res.json();

    const attrIds = Object.keys(body.attributes);
    expect(attrIds).toHaveLength(1);
    expect(attrIds[0]).toBe(linked.id.toString());
  });

  it("excludes deleted attributes even if referenced", async () => {
    const cat = await createCategory({ slug: "pads", name: "Pads" });
    const attr = await createAttribute({
      slug: "deleted-attr",
      name: "Deleted",
      is_deleted: true,
    });
    await createCategoryAttribute(cat.id, attr.id);

    const res = await GET(makeRequest());
    const body = await res.json();

    expect(body.attributes).toEqual({});
    expect(body.categoryAttributes).toEqual({});
  });
});
