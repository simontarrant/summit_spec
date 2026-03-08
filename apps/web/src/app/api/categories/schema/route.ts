import { NextResponse } from "next/server";
import prisma from "@/lib/prisma";

interface CategoryNode {
  id: string;
  slug: string;
  name: string;
  children: CategoryNode[];
}

export async function GET() {
  try {
    const [categories, categoryAttributes] = await Promise.all([
      prisma.category.findMany({
        where: { is_deleted: false },
        select: { id: true, slug: true, name: true, parent_category: true },
        orderBy: { id: "asc" },
      }),
      prisma.category_attribute.findMany({
        where: {
          is_deleted: false,
          attribute_rel: { is_deleted: false },
          category_rel: { is_deleted: false },
        },
        select: {
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
                select: {
                  id: true,
                  slug: true,
                  name: true,
                  display_order: true,
                },
                orderBy: { display_order: "asc" },
              },
            },
          },
        },
      }),
    ]);

    // Build category tree
    const nodeMap = new Map<string, CategoryNode>();
    const parentMap = new Map<string, string>(); // childId -> parentId

    for (const cat of categories) {
      const id = cat.id.toString();
      nodeMap.set(id, { id, slug: cat.slug, name: cat.name, children: [] });
      if (cat.parent_category !== null) {
        parentMap.set(id, cat.parent_category.toString());
      }
    }

    const roots: CategoryNode[] = [];
    for (const [id, node] of nodeMap) {
      const parentId = parentMap.get(id);
      if (parentId && nodeMap.has(parentId)) {
        nodeMap.get(parentId)!.children.push(node);
      } else {
        roots.push(node);
      }
    }

    // Build attributes and categoryAttributes maps
    const attributesMap: Record<string, object> = {};
    const catAttrsMap: Record<string, { attributeId: string; priority: number }[]> = {};

    for (const ca of categoryAttributes) {
      const attrId = ca.attribute.toString();
      const catId = ca.category.toString();

      // Dedupe attributes
      if (!attributesMap[attrId]) {
        const rel = ca.attribute_rel;
        const enumVals =
          rel.enum_attribute_vals_enum_attribute_vals_attributeToattribute;
        attributesMap[attrId] = {
          id: attrId,
          slug: rel.slug,
          name: rel.name,
          type: rel.type,
          numberUnit: rel.number_unit,
          enumOptions:
            rel.type === "enum_list"
              ? enumVals.map((v) => ({
                  id: v.id.toString(),
                  slug: v.slug,
                  name: v.name,
                  displayOrder: v.display_order,
                }))
              : null,
        };
      }

      // Group category-attributes
      if (!catAttrsMap[catId]) {
        catAttrsMap[catId] = [];
      }
      catAttrsMap[catId].push({ attributeId: attrId, priority: ca.priority });
    }

    return NextResponse.json({
      categories: roots,
      attributes: attributesMap,
      categoryAttributes: catAttrsMap,
    });
  } catch (error) {
    console.error("Failed to fetch category schema:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
