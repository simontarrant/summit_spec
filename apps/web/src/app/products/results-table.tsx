import { cn } from "@/lib/cn";
import type { SearchColumn, SearchRow, SortSpec } from "./types";

interface ResultsTableProps {
  columns: SearchColumn[];
  rows: SearchRow[];
  sort: SortSpec | null;
  onSort: (attributeId: string) => void;
  loading: boolean;
}

function formatNumberValue(value: number, unit: string | null | undefined): string {
  switch (unit) {
    case "weight_g":
      return `${value} g`;
    case "length_mm":
      return `${value} mm`;
    case "volume_ml":
      return `${value} ml`;
    default:
      return String(value);
  }
}

function renderCellValue(
  row: SearchRow,
  column: SearchColumn
): React.ReactNode {
  if (column.key === "productName") {
    return (
      <span>
        <span className="font-medium text-charcoal">{row.productName}</span>
        {row.variantName && (
          <span className="text-slate text-sm"> — {row.variantName}</span>
        )}
      </span>
    );
  }

  if (column.key === "brandName") {
    return <span className="text-slate">{row.brandName}</span>;
  }

  const attrId = column.attributeId;
  if (!attrId) return null;

  const attr = row.attributes[attrId];
  if (!attr) {
    return <span className="text-slate opacity-40">—</span>;
  }

  switch (attr.type) {
    case "number":
      return (
        <span className="font-mono text-sm tabular-nums">
          {formatNumberValue(attr.value as number, column.numberUnit)}
        </span>
      );
    case "bool":
      return attr.value ? "Yes" : "No";
    case "enum_list": {
      const enumVal = attr.value as { id: string; slug: string; name: string };
      return enumVal.name;
    }
    case "string":
      return attr.value as string;
    default:
      return String(attr.value);
  }
}

export function ResultsTable({
  columns,
  rows,
  sort,
  onSort,
  loading,
}: ResultsTableProps) {
  return (
    <div className="overflow-x-auto">
      <table className="product-table">
        <thead>
          <tr>
            {columns.map((col) => {
              const isSortable = !col.pinned && col.sortable && col.attributeId;
              const isActive =
                sort && col.attributeId && sort.attributeId === col.attributeId;

              const isNumeric = col.numberUnit != null;

              if (isSortable) {
                return (
                  <th
                    key={col.key}
                    onClick={() => onSort(col.attributeId!)}
                    className={cn("sortable-header", isNumeric && "text-right")}
                  >
                    <div className={cn("flex items-center gap-1.5", isNumeric && "justify-end")}>
                      {col.label}
                      <span className="sort-indicator">
                        {isActive ? (
                          sort!.direction === "asc" ? (
                            "▲"
                          ) : (
                            "▼"
                          )
                        ) : (
                          <span className="sort-inactive">⬍</span>
                        )}
                      </span>
                    </div>
                  </th>
                );
              }

              return <th key={col.key} className={cn(isNumeric && "text-right")}>{col.label}</th>;
            })}
          </tr>
        </thead>
        <tbody className={cn(loading && "opacity-40 pointer-events-none")}>
          {rows.length === 0 && !loading ? (
            <tr>
              <td
                colSpan={columns.length}
                className="text-center text-slate py-12"
              >
                No products found matching your filters.
              </td>
            </tr>
          ) : (
            rows.map((row) => (
              <tr key={row.variantId}>
                {columns.map((col) => (
                  <td key={col.key} className={cn(col.numberUnit != null && "text-right")}>{renderCellValue(row, col)}</td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
