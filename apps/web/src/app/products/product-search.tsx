"use client";

import { useState, useEffect, useCallback, useRef, useMemo } from "react";
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
  AttributeDef,
  CategoryNode,
  FilterState,
  FilterStateValue,
  NumberFilterState,
  SortSpec,
  Filter,
} from "./types";

const tabs = [
  { label: "Example", href: "/example" },
  { label: "Products", href: "/products" },
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
  const allCatIds = [...ancestorIds, categoryId, ...descendantIds];

  const seen = new Set<string>();
  const result: AttributeDef[] = [];

  for (const catId of allCatIds) {
    const entries = schema.categoryAttributes[catId];
    if (!entries) continue;
    const sorted = [...entries].sort(
      (a, b) => a.priority - b.priority || a.attributeId.localeCompare(b.attributeId)
    );
    for (const entry of sorted) {
      if (seen.has(entry.attributeId)) continue;
      seen.add(entry.attributeId);
      const attr = schema.attributes[entry.attributeId];
      if (attr) result.push(attr);
    }
  }

  return result;
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

// --- Component ---

export function ProductSearch() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

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

  // Restore state from URL once schema is loaded
  useEffect(() => {
    if (!schema || initializedRef.current) return;
    initializedRef.current = true;

    const cat = searchParams.get("cat");
    if (cat && findCategoryById(schema.categories, cat)) {
      setCategoryId(cat);
      setFilterState(parseFiltersFromParams(searchParams, schema.attributes));

      const sortParam = searchParams.get("sort");
      if (sortParam) {
        const [attrId, dir] = sortParam.split(".");
        if (attrId && (dir === "asc" || dir === "desc")) {
          setSort({ attributeId: attrId, direction: dir });
        }
      }

      const pageParam = searchParams.get("page");
      if (pageParam) setPage(Math.max(1, parseInt(pageParam, 10) || 1));

      const limitParam = searchParams.get("limit");
      if (limitParam) {
        const l = parseInt(limitParam, 10);
        if ([10, 25, 50, 100].includes(l)) setLimit(l);
      }
    }
  }, [schema, searchParams]);

  // Execute search when debounced filters, sort, page, limit, or categoryId change
  useEffect(() => {
    if (!schema || !categoryId) return;

    let cancelled = false;
    async function search() {
      setSearching(true);
      setSearchError(null);

      const filters = buildApiFilters(debouncedFilterState, schema!.attributes);
      const offset = (page - 1) * limit;

      try {
        const res = await fetch("/api/products/search", {
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
          } else {
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
  }, [schema, categoryId, debouncedFilterState, sort, page, limit]);

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

  const filterBar = schema ? (
    <div className="flex items-center gap-4 flex-wrap">
      <CategorySelector
        categories={schema.categories}
        value={categoryId}
        onChange={handleCategoryChange}
      />
      {categoryId && (
        <>
          <button
            type="button"
            className="ui-button-primary text-sm px-3 py-1.5"
            aria-expanded={!filtersCollapsed}
            aria-controls="product-filter-controls"
            onClick={() => setFiltersCollapsed((prev) => !prev)}
          >
            {filtersCollapsed ? "Show Filters" : "Hide Filters"}
          </button>
          {!filtersCollapsed && (
            <>
              <div className="w-px h-6 bg-grey-200" />
              <div id="product-filter-controls">
                <FilterPanel
                  attributes={resolvedAttributes}
                  filterState={filterState}
                  onChange={handleFilterChange}
                />
              </div>
            </>
          )}
        </>
      )}
    </div>
  ) : null;

  if (schemaLoading) {
    return (
      <AppShell tabs={tabs} pageTitle="Product Catalog">
        <div className="ui-page">
          <div className="ui-card">
            <p className="text-slate py-8 text-center">
              Loading categories...
            </p>
          </div>
        </div>
      </AppShell>
    );
  }

  if (schemaError) {
    return (
      <AppShell tabs={tabs} pageTitle="Product Catalog">
        <div className="ui-page">
          <div className="ui-card">
            <p className="text-warning py-8 text-center">{schemaError}</p>
          </div>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell
      tabs={tabs}
      pageTitle="Product Catalog"
      pageDescription="Browse and compare hiking gear across categories"
      filterBar={filterBar}
    >
      <div className="ui-page">
        <div className="ui-card">
          {!categoryId ? (
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
