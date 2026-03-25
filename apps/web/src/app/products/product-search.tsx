"use client";

import { useState, useEffect, useCallback, useRef, useMemo, Suspense } from "react";
import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { AppShell } from "@/components/ui/app_shell";
import { CategorySelector } from "./category-selector";
import { FilterPanel } from "./filter-panel";
import { ResultsTable } from "./results-table";
import { Pagination } from "./pagination";
import { useDebounce } from "./use-debounce";
import type {
  SchemaResponse,
  SearchResponse,
  GoSearchResponse,
  SearchColumn,
  AttributeDef,
  CategoryNode,
  FilterState,
  FilterStateValue,
  NumberFilterState,
  SortSpec,
  Filter,
} from "./types";

const SEARCH_API_URL = process.env.NEXT_PUBLIC_SEARCH_API_URL || "";

const tabs = [
  { label: "Example", href: "/example" },
  { label: "Products", href: "/products" },
  { label: "About", href: "/about" },
];

// --- Schema resolution helpers ---

function findCategoryById(
  nodes: CategoryNode[],
  id: string
): CategoryNode | null {
  for (const node of nodes) {
    if (node.id === id) return node;
    const found = findCategoryById(node.children, id);
    if (found) return found;
  }
  return null;
}

function getAncestorIds(
  nodes: CategoryNode[],
  targetId: string,
  path: string[] = []
): string[] | null {
  for (const node of nodes) {
    if (node.id === targetId) return path;
    const found = getAncestorIds(node.children, targetId, [
      ...path,
      node.id,
    ]);
    if (found) return found;
  }
  return null;
}

function getDescendantIds(node: CategoryNode): string[] {
  return node.children.flatMap((c) => [c.id, ...getDescendantIds(c)]);
}

function resolveAttributes(
  schema: SchemaResponse,
  categoryId: string
): AttributeDef[] {
  const node = findCategoryById(schema.categories, categoryId);
  if (!node) return [];

  const ancestorIds = getAncestorIds(schema.categories, categoryId) ?? [];
  const descendantIds = getDescendantIds(node);

  const seen = new Set<string>();
  const result: AttributeDef[] = [];

  const selectedAndAncestorEntries = [...ancestorIds, categoryId]
    .flatMap((catId) =>
      (schema.categoryAttributes[catId] ?? []).map((entry) => ({
        ...entry,
        categoryId: catId,
      }))
    )
    .sort(
      (a, b) =>
        b.priority - a.priority ||
        a.attributeId.localeCompare(b.attributeId) ||
        a.categoryId.localeCompare(b.categoryId)
    );

  for (const entry of selectedAndAncestorEntries) {
    if (seen.has(entry.attributeId)) continue;
    seen.add(entry.attributeId);
    const attr = schema.attributes[entry.attributeId];
    if (attr) result.push(attr);
  }

  const sortedDescendantIds = [...descendantIds].sort((a, b) =>
    BigInt(a) < BigInt(b) ? -1 : BigInt(a) > BigInt(b) ? 1 : 0
  );

  for (const catId of sortedDescendantIds) {
    const sortedEntries = [...(schema.categoryAttributes[catId] ?? [])].sort(
      (a, b) => b.priority - a.priority || a.attributeId.localeCompare(b.attributeId)
    );
    for (const entry of sortedEntries) {
      if (seen.has(entry.attributeId)) continue;
      seen.add(entry.attributeId);
      const attr = schema.attributes[entry.attributeId];
      if (attr) result.push(attr);
    }
  }

  return result;
}

// --- Column builder (for Go API responses without columns) ---

function buildColumns(
  resolvedAttrs: AttributeDef[],
  filters: Filter[]
): SearchColumn[] {
  const columns: SearchColumn[] = [
    { key: "productName", label: "Product", pinned: true },
    { key: "brandName", label: "Brand", pinned: true },
  ];

  const addedAttrIds = new Set<string>();

  // Filtered attributes first (in filter order)
  for (const f of filters) {
    if (addedAttrIds.has(f.attributeId)) continue;
    const attr = resolvedAttrs.find((a) => a.id === f.attributeId);
    if (!attr) continue;
    addedAttrIds.add(f.attributeId);
    columns.push(makeAttrColumn(attr));
  }

  // Then remaining resolved attributes in priority order
  for (const attr of resolvedAttrs) {
    if (addedAttrIds.has(attr.id)) continue;
    addedAttrIds.add(attr.id);
    columns.push(makeAttrColumn(attr));
  }

  return columns;
}

function makeAttrColumn(attr: AttributeDef): SearchColumn {
  return {
    key: `attr:${attr.id}`,
    label: attr.name,
    attributeId: attr.id,
    type: attr.type,
    numberUnit: attr.type === "number" ? attr.numberUnit : null,
    sortable: attr.type !== "enum_list",
    pinned: false,
  };
}

// --- Filter <-> URL serialization ---

function serializeFiltersToParams(
  filterState: FilterState,
  attributes: Record<string, AttributeDef>
): Record<string, string> {
  const params: Record<string, string> = {};

  for (const [attrId, state] of Object.entries(filterState)) {
    const attr = attributes[attrId];
    if (!attr || state == null) continue;

    if (attr.type === "number") {
      const ns = state as NumberFilterState;
      if (ns.min) params[`f.${attrId}.gte`] = ns.min;
      if (ns.max) params[`f.${attrId}.lte`] = ns.max;
    } else if (attr.type === "bool") {
      if (typeof state === "boolean") {
        params[`f.${attrId}.bool`] = String(state);
      }
    } else if (attr.type === "enum_list") {
      const selected = state as Set<string>;
      if (selected.size > 0) {
        params[`f.${attrId}.enum`] = Array.from(selected).join(",");
      }
    } else if (attr.type === "string") {
      const str = state as string;
      if (str.trim()) {
        params[`f.${attrId}.str`] = str.trim();
      }
    }
  }

  return params;
}

function parseFiltersFromParams(
  searchParams: URLSearchParams,
  attributes: Record<string, AttributeDef>
): FilterState {
  const state: FilterState = {};

  for (const [key, value] of searchParams.entries()) {
    if (!key.startsWith("f.")) continue;
    const parts = key.split(".");
    if (parts.length !== 3) continue;
    const attrId = parts[1];
    const op = parts[2];
    const attr = attributes[attrId];
    if (!attr) continue;

    if (attr.type === "number" && (op === "gte" || op === "lte")) {
      const existing = (state[attrId] as NumberFilterState) ?? {
        min: "",
        max: "",
      };
      if (op === "gte") existing.min = value;
      if (op === "lte") existing.max = value;
      state[attrId] = existing;
    } else if (attr.type === "bool" && op === "bool") {
      state[attrId] = value === "true";
    } else if (attr.type === "enum_list" && op === "enum") {
      state[attrId] = new Set(value.split(",").filter(Boolean));
    } else if (attr.type === "string" && op === "str") {
      state[attrId] = value;
    }
  }

  return state;
}

// --- Filter state -> API filters ---

function buildApiFilters(
  filterState: FilterState,
  attributes: Record<string, AttributeDef>
): Filter[] {
  const filters: Filter[] = [];

  for (const [attrId, state] of Object.entries(filterState)) {
    const attr = attributes[attrId];
    if (!attr || state == null) continue;

    if (attr.type === "number") {
      const ns = state as NumberFilterState;
      const minNum = ns.min ? parseFloat(ns.min) : NaN;
      const maxNum = ns.max ? parseFloat(ns.max) : NaN;
      if (!isNaN(minNum)) {
        filters.push({
          attributeId: attrId,
          type: "number",
          operator: "gte",
          value: minNum,
        });
      }
      if (!isNaN(maxNum)) {
        filters.push({
          attributeId: attrId,
          type: "number",
          operator: "lte",
          value: maxNum,
        });
      }
    } else if (attr.type === "bool") {
      if (typeof state === "boolean") {
        filters.push({ attributeId: attrId, type: "bool", value: state });
      }
    } else if (attr.type === "enum_list") {
      const selected = state as Set<string>;
      if (selected.size > 0) {
        filters.push({
          attributeId: attrId,
          type: "enum_list",
          value: Array.from(selected),
        });
      }
    } else if (attr.type === "string") {
      const str = state as string;
      if (str.trim()) {
        filters.push({
          attributeId: attrId,
          type: "string",
          value: str.trim(),
        });
      }
    }
  }

  return filters;
}

// --- Search params reader (isolated so Suspense only wraps this small component) ---

function SearchParamsReader({
  onMount,
}: {
  onMount: (params: URLSearchParams) => void;
}) {
  const searchParams = useSearchParams();
  const onMountRef = useRef(onMount);
  onMountRef.current = onMount;
  useEffect(() => {
    onMountRef.current(searchParams);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps
  return null;
}

// --- Component ---

export function ProductSearch() {
  const router = useRouter();
  const pathname = usePathname();

  const [initialSearchParams, setInitialSearchParams] = useState<URLSearchParams | null>(null);

  const [schema, setSchema] = useState<SchemaResponse | null>(null);
  const [schemaLoading, setSchemaLoading] = useState(true);
  const [schemaError, setSchemaError] = useState<string | null>(null);

  const [categoryId, setCategoryId] = useState<string | null>(null);
  const [filterState, setFilterState] = useState<FilterState>({});
  const [filtersCollapsed, setFiltersCollapsed] = useState(true);
  const [sort, setSort] = useState<SortSpec | null>(null);
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(25);

  const [searchResult, setSearchResult] = useState<SearchResponse | null>(null);
  const [searching, setSearching] = useState(false);
  const [searchError, setSearchError] = useState<string | null>(null);

  // Track whether initial URL params have been applied
  const initializedRef = useRef(false);

  // Debounce filter state for number/string inputs
  const debouncedFilterState = useDebounce(filterState, 400);

  // Resolve attributes for current category
  const resolvedAttributes = useMemo(() => {
    if (!schema || !categoryId) return [];
    return resolveAttributes(schema, categoryId);
  }, [schema, categoryId]);


  const hasActiveFilters = useMemo(() => {
    if (!schema) return false;
    return buildApiFilters(filterState, schema.attributes).length > 0;
  }, [schema, filterState]);

  // Fetch schema on mount
  useEffect(() => {
    let cancelled = false;
    async function fetchSchema() {
      try {
        const res = await fetch("/api/categories/schema");
        if (!res.ok) throw new Error("Failed to load categories");
        const data: SchemaResponse = await res.json();
        if (!cancelled) {
          setSchema(data);
          setSchemaLoading(false);
        }
      } catch (e) {
        if (!cancelled) {
          setSchemaError(
            e instanceof Error ? e.message : "Failed to load categories"
          );
          setSchemaLoading(false);
        }
      }
    }
    fetchSchema();
    return () => {
      cancelled = true;
    };
  }, []);

  // Restore state from URL once schema and initial search params are loaded
  useEffect(() => {
    if (!schema || !initialSearchParams || initializedRef.current) return;
    initializedRef.current = true;

    const cat = initialSearchParams.get("cat");
    if (cat && findCategoryById(schema.categories, cat)) {
      setCategoryId(cat);
      setFilterState(parseFiltersFromParams(initialSearchParams, schema.attributes));

      const sortParam = initialSearchParams.get("sort");
      if (sortParam) {
        const [attrId, dir] = sortParam.split(".");
        if (attrId && (dir === "asc" || dir === "desc")) {
          setSort({ attributeId: attrId, direction: dir });
        }
      }

      const pageParam = initialSearchParams.get("page");
      if (pageParam) setPage(Math.max(1, parseInt(pageParam, 10) || 1));

      const limitParam = initialSearchParams.get("limit");
      if (limitParam) {
        const l = parseInt(limitParam, 10);
        if ([10, 25, 50, 100].includes(l)) setLimit(l);
      }
    }
  }, [schema, initialSearchParams]);

  // Execute search when debounced filters, sort, page, limit, or categoryId change
  useEffect(() => {
    if (!schema || !categoryId) return;

    let cancelled = false;
    async function search() {
      setSearching(true);
      setSearchError(null);

      const filters = buildApiFilters(debouncedFilterState, schema!.attributes);
      const offset = (page - 1) * limit;

      const searchUrl = SEARCH_API_URL
        ? `${SEARCH_API_URL}/products/search`
        : "/api/products/search";

      try {
        const res = await fetch(searchUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            categoryId,
            filters,
            sort,
            limit,
            offset,
          }),
        });

        if (!cancelled) {
          if (!res.ok) {
            const data = await res.json().catch(() => null);
            setSearchError(data?.error ?? `Search failed (${res.status})`);
            setSearchResult(null);
          } else if (SEARCH_API_URL) {
            // Go API response: no columns — build them client-side
            const data: GoSearchResponse = await res.json();
            const columns = buildColumns(resolvedAttributes, filters);
            setSearchResult({ ...data, columns });
          } else {
            // Next.js fallback: response includes columns
            const data: SearchResponse = await res.json();
            setSearchResult(data);
          }
          setSearching(false);
        }
      } catch (e) {
        if (!cancelled) {
          setSearchError(
            e instanceof Error ? e.message : "Search request failed"
          );
          setSearching(false);
        }
      }
    }

    search();
    return () => {
      cancelled = true;
    };
  }, [schema, categoryId, debouncedFilterState, sort, page, limit, resolvedAttributes]);

  // Sync state to URL
  useEffect(() => {
    if (!schema || !categoryId || !initializedRef.current) return;

    const params = new URLSearchParams();
    params.set("cat", categoryId);

    const filterParams = serializeFiltersToParams(
      filterState,
      schema.attributes
    );
    for (const [key, val] of Object.entries(filterParams)) {
      params.set(key, val);
    }

    if (sort) {
      params.set("sort", `${sort.attributeId}.${sort.direction}`);
    }
    if (page > 1) params.set("page", String(page));
    if (limit !== 25) params.set("limit", String(limit));

    router.replace(`${pathname}?${params.toString()}`, { scroll: false });
  }, [schema, categoryId, filterState, sort, page, limit, pathname, router]);

  // --- Handlers ---

  const handleCategoryChange = useCallback(
    (id: string) => {
      setCategoryId(id);
      setFilterState({});
      setSort(null);
      setPage(1);
      setSearchResult(null);
    },
    []
  );

  const handleFilterChange = useCallback(
    (attrId: string, value: FilterStateValue) => {
      setFilterState((prev) => ({ ...prev, [attrId]: value }));
      setPage(1);
    },
    []
  );

  const handleClearFilters = useCallback(() => {
    setFilterState({});
    setPage(1);
  }, []);

  const handleSort = useCallback(
    (attributeId: string) => {
      setSort((prev) => {
        if (prev && prev.attributeId === attributeId) {
          return prev.direction === "asc"
            ? { attributeId, direction: "desc" }
            : null;
        }
        return { attributeId, direction: "asc" };
      });
      setPage(1);
    },
    []
  );

  const handlePageChange = useCallback((p: number) => {
    setPage(p);
  }, []);

  const handleLimitChange = useCallback((l: number) => {
    setLimit(l);
    setPage(1);
  }, []);

  // --- Render ---

  const categorySelector = schema ? (
    <CategorySelector
      categories={schema.categories}
      value={categoryId}
      onChange={handleCategoryChange}
      variant="title"
    />
  ) : null;

  const filterBar = schema && categoryId ? (
    <div className="product-search-controls">
      <div className="product-search-controls-row">
        <button
          type="button"
          className="filter-toggle-btn"
          aria-expanded={!filtersCollapsed}
          aria-controls="product-filter-controls"
          onClick={() => setFiltersCollapsed((prev) => !prev)}
        >
          <span>Filters</span>
          <span className="filter-toggle-chevron">{filtersCollapsed ? "▼" : "▲"}</span>
        </button>
        {hasActiveFilters && (
          <button
            type="button"
            className="filter-clear-btn"
            onClick={handleClearFilters}
          >
            (clear)
          </button>
        )}
      </div>
      {!filtersCollapsed && (
        <section
          id="product-filter-controls"
          className="product-filter-section"
          aria-label="Filters"
        >
          <FilterPanel
            attributes={resolvedAttributes}
            filterState={filterState}
            onChange={handleFilterChange}
          />
        </section>
      )}
    </div>
  ) : null;

  return (
    <AppShell
      tabs={tabs}
      pageTitle="Product Catalog"
      pageDescription={!schemaLoading && !schemaError ? "Browse and compare hiking gear" : undefined}
      titleAddon={categorySelector}
      filterBar={filterBar}
    >
      <Suspense>
        <SearchParamsReader onMount={setInitialSearchParams} />
      </Suspense>
      <div className="ui-page">
        <div className="ui-card">
          {schemaLoading ? (
            <p className="text-slate py-8 text-center">Loading categories...</p>
          ) : schemaError ? (
            <p className="text-warning py-8 text-center">{schemaError}</p>
          ) : !categoryId ? (
            <p className="text-slate py-12 text-center">
              Select a category to browse products.
            </p>
          ) : (
            <>
              {searchError && (
                <div className="bg-warning/10 text-warning px-4 py-2 rounded mb-4 text-sm">
                  {searchError}
                </div>
              )}
              <ResultsTable
                columns={searchResult?.columns ?? []}
                rows={searchResult?.rows ?? []}
                sort={sort}
                onSort={handleSort}
                loading={searching}
              />
              {searchResult && (
                <Pagination
                  totalRows={searchResult.pagination.totalRows}
                  page={page}
                  limit={limit}
                  onPageChange={handlePageChange}
                  onLimitChange={handleLimitChange}
                />
              )}
            </>
          )}
        </div>
      </div>
    </AppShell>
  );
}
