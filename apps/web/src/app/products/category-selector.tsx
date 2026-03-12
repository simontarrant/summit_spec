import { LinearSelect } from "@/components/ui/linear-select";
import { cn } from "@/lib/cn";
import type { CategoryNode } from "./types";

interface CategorySelectorProps {
  categories: CategoryNode[];
  value: string | null;
  onChange: (id: string) => void;
  variant?: "default" | "title";
}

function flattenTree(
  nodes: CategoryNode[],
  depth: number = 0
): { id: string; label: string }[] {
  const result: { id: string; label: string }[] = [];
  for (const node of nodes) {
    const indent = "\u00A0\u00A0".repeat(depth);
    result.push({ id: node.id, label: `${indent}${node.name}` });
    result.push(...flattenTree(node.children, depth + 1));
  }
  return result;
}

export function CategorySelector({
  categories,
  value,
  onChange,
  variant = "default",
}: CategorySelectorProps) {
  const options = flattenTree(categories);

  if (variant === "title") {
    return (
      <div className="relative">
        <select
          value={value ?? ""}
          onChange={(e) => onChange(e.target.value)}
          className={cn(
            "appearance-none bg-transparent cursor-pointer",
            "border-0 focus:outline-none",
            "font-semibold pr-5",
            "text-[1.25rem] leading-tight",
            value
              ? "text-[var(--color-text-primary)]"
              : "text-[var(--color-text-muted)]"
          )}
        >
          <option value="" disabled>Select a category</option>
          {options.map((opt) => (
            <option key={opt.id} value={opt.id}>
              {opt.label}
            </option>
          ))}
        </select>
        <div className="pointer-events-none absolute right-0 top-1/2 -translate-y-1/2 text-[var(--color-text-muted)] text-xs">
          ▼
        </div>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-2">
      <span className="text-sm text-slate">Category:</span>
      <LinearSelect
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="" disabled>
          Select category...
        </option>
        {options.map((opt) => (
          <option key={opt.id} value={opt.id}>
            {opt.label}
          </option>
        ))}
      </LinearSelect>
    </div>
  );
}
