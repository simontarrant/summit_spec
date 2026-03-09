import { LinearSelect } from "@/components/ui/linear-select";
import type { CategoryNode } from "./types";

interface CategorySelectorProps {
  categories: CategoryNode[];
  value: string | null;
  onChange: (id: string) => void;
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
}: CategorySelectorProps) {
  const options = flattenTree(categories);

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
