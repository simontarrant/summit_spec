// --- Schema API types (GET /api/categories/schema) ---

export interface CategoryNode {
  id: string;
  slug: string;
  name: string;
  children: CategoryNode[];
}

export interface EnumOption {
  id: string;
  slug: string;
  name: string;
  displayOrder: number;
}

export interface AttributeDef {
  id: string;
  slug: string;
  name: string;
  type: "number" | "bool" | "enum_list" | "string";
  numberUnit: string;
  enumOptions: EnumOption[] | null;
}

export interface CategoryAttributeEntry {
  attributeId: string;
  priority: number;
}

export interface SchemaResponse {
  categories: CategoryNode[];
  attributes: Record<string, AttributeDef>;
  categoryAttributes: Record<string, CategoryAttributeEntry[]>;
}

// --- Search API types (POST /api/products/search) ---

export interface NumberFilter {
  attributeId: string;
  type: "number";
  operator: "eq" | "gte" | "lte" | "between";
  value: number | [number, number];
}

export interface BoolFilter {
  attributeId: string;
  type: "bool";
  value: boolean;
}

export interface EnumFilter {
  attributeId: string;
  type: "enum_list";
  value: string[];
}

export interface StringFilter {
  attributeId: string;
  type: "string";
  value: string;
}

export type Filter = NumberFilter | BoolFilter | EnumFilter | StringFilter;

export interface SortSpec {
  attributeId: string;
  direction: "asc" | "desc";
}

export interface SearchRow {
  variantId: string;
  productId: string;
  productName: string;
  variantName: string;
  brandId: string;
  brandName: string;
  primaryCategoryId: string;
  attributes: Record<string, { type: string; value: unknown }>;
}

export interface SearchColumn {
  key: string;
  label: string;
  attributeId?: string;
  type?: string;
  numberUnit?: string | null;
  sortable?: boolean;
  pinned: boolean;
}

export interface SearchResponse {
  rows: SearchRow[];
  columns: SearchColumn[];
  pagination: {
    limit: number;
    offset: number;
    totalRows: number;
  };
}

// --- Local UI state ---

export interface NumberFilterState {
  min: string;
  max: string;
}

export type FilterStateValue =
  | NumberFilterState
  | boolean
  | null
  | Set<string>
  | string;

export type FilterState = Record<string, FilterStateValue>;
