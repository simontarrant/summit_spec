import { cn } from "@/lib/cn";
import { LinearSelect } from "@/components/ui/linear-select";

interface PaginationProps {
  totalRows: number;
  page: number;
  limit: number;
  onPageChange: (page: number) => void;
  onLimitChange: (limit: number) => void;
}

function getPageNumbers(current: number, total: number): (number | "...")[] {
  if (total <= 5) {
    return Array.from({ length: total }, (_, i) => i + 1);
  }

  const pages: (number | "...")[] = [1];

  if (current > 3) {
    pages.push("...");
  }

  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);

  for (let i = start; i <= end; i++) {
    pages.push(i);
  }

  if (current < total - 2) {
    pages.push("...");
  }

  pages.push(total);
  return pages;
}

export function Pagination({
  totalRows,
  page,
  limit,
  onPageChange,
  onLimitChange,
}: PaginationProps) {
  const totalPages = Math.max(1, Math.ceil(totalRows / limit));
  const start = Math.min((page - 1) * limit + 1, totalRows);
  const end = Math.min(page * limit, totalRows);
  const pageNumbers = getPageNumbers(page, totalPages);

  return (
    <div className="flex items-center justify-between py-3 text-sm text-slate">
      <span>
        {totalRows === 0
          ? "No results"
          : `Showing ${start}–${end} of ${totalRows}`}
      </span>

      <div className="flex items-center gap-1">
        <button
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
          className={cn(
            "pagination-button",
            page <= 1 && "opacity-40 cursor-not-allowed"
          )}
        >
          Prev
        </button>

        {pageNumbers.map((p, i) =>
          p === "..." ? (
            <span key={`ellipsis-${i}`} className="px-1">
              ...
            </span>
          ) : (
            <button
              key={p}
              onClick={() => onPageChange(p)}
              className={cn(
                "pagination-button",
                p === page && "pagination-button-active"
              )}
            >
              {p}
            </button>
          )
        )}

        <button
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
          className={cn(
            "pagination-button",
            page >= totalPages && "opacity-40 cursor-not-allowed"
          )}
        >
          Next
        </button>
      </div>

      <div className="flex items-center gap-2">
        <span>Rows:</span>
        <LinearSelect
          value={String(limit)}
          onChange={(e) => onLimitChange(Number(e.target.value))}
        >
          <option value="10">10</option>
          <option value="25">25</option>
          <option value="50">50</option>
          <option value="100">100</option>
        </LinearSelect>
      </div>
    </div>
  );
}
