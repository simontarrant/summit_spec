import { useState, useRef, useEffect } from "react";
import { LinearInput } from "@/components/ui/linear-input";
import { LinearNumberInput } from "@/components/ui/linear-number-input";
import { LinearSelect } from "@/components/ui/linear-select";
import { cn } from "@/lib/cn";
import type {
  AttributeDef,
  FilterState,
  FilterStateValue,
  NumberFilterState,
} from "./types";

interface FilterPanelProps {
  attributes: AttributeDef[];
  filterState: FilterState;
  onChange: (attributeId: string, value: FilterStateValue) => void;
}

function unitLabel(unit: string): string {
  switch (unit) {
    case "weight_g":
      return "g";
    case "length_mm":
      return "mm";
    case "volume_ml":
      return "ml";
    default:
      return "";
  }
}

export function FilterPanel({
  attributes,
  filterState,
  onChange,
}: FilterPanelProps) {
  if (attributes.length === 0) return null;

  return (
    <div className="flex flex-wrap items-end gap-4">
      {attributes.map((attr) => (
        <FilterControl
          key={attr.id}
          attribute={attr}
          value={filterState[attr.id] ?? null}
          onChange={(val) => onChange(attr.id, val)}
        />
      ))}
    </div>
  );
}

interface FilterControlProps {
  attribute: AttributeDef;
  value: FilterStateValue;
  onChange: (value: FilterStateValue) => void;
}

function FilterControl({ attribute, value, onChange }: FilterControlProps) {
  switch (attribute.type) {
    case "number":
      return (
        <NumberFilterControl
          attribute={attribute}
          value={value as NumberFilterState | null}
          onChange={onChange}
        />
      );
    case "bool":
      return (
        <BoolFilterControl
          value={value as boolean | null}
          attribute={attribute}
          onChange={onChange}
        />
      );
    case "enum_list":
      return (
        <EnumFilterControl
          attribute={attribute}
          value={value as Set<string> | null}
          onChange={onChange}
        />
      );
    case "string":
      return (
        <StringFilterControl
          attribute={attribute}
          value={value as string | null}
          onChange={onChange}
        />
      );
    default:
      return null;
  }
}

function NumberFilterControl({
  attribute,
  value,
  onChange,
}: {
  attribute: AttributeDef;
  value: NumberFilterState | null;
  onChange: (value: FilterStateValue) => void;
}) {
  const state = value ?? { min: "", max: "" };
  const suffix = unitLabel(attribute.numberUnit);
  const label = suffix
    ? `${attribute.name} (${suffix})`
    : attribute.name;

  return (
    <div className="flex flex-col gap-0.5">
      <span className="filter-group-label">{label}</span>
      <div className="flex items-center gap-1">
        <LinearNumberInput
          value={state.min}
          onChange={(e) =>
            onChange({ ...state, min: e.target.value })
          }
          placeholder="Min"
          className="w-16"
        />
        <span className="text-xs text-slate">–</span>
        <LinearNumberInput
          value={state.max}
          onChange={(e) =>
            onChange({ ...state, max: e.target.value })
          }
          placeholder="Max"
          className="w-16"
        />
      </div>
    </div>
  );
}

function BoolFilterControl({
  attribute,
  value,
  onChange,
}: {
  attribute: AttributeDef;
  value: boolean | null;
  onChange: (value: FilterStateValue) => void;
}) {
  const selectValue = value === null ? "" : value ? "true" : "false";

  return (
    <div className="flex flex-col gap-0.5">
      <span className="filter-group-label">{attribute.name}</span>
      <LinearSelect
        value={selectValue}
        onChange={(e) => {
          const v = e.target.value;
          onChange(v === "" ? null : v === "true");
        }}
      >
        <option value="">Any</option>
        <option value="true">Yes</option>
        <option value="false">No</option>
      </LinearSelect>
    </div>
  );
}

function EnumFilterControl({
  attribute,
  value,
  onChange,
}: {
  attribute: AttributeDef;
  value: Set<string> | null;
  onChange: (value: FilterStateValue) => void;
}) {
  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const selected = value ?? new Set<string>();
  const options = attribute.enumOptions ?? [];

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    if (open) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  const triggerLabel =
    selected.size === 0
      ? "Any"
      : options
          .filter((o) => selected.has(o.id))
          .map((o) => o.name)
          .join(", ");

  return (
    <div className="flex flex-col gap-0.5" ref={containerRef}>
      <span className="filter-group-label">{attribute.name}</span>
      <div className="relative">
        <button
          type="button"
          onClick={() => setOpen((o) => !o)}
          className={cn(
            "flex items-center justify-between gap-4",
            "bg-transparent text-sm text-left cursor-pointer",
            "border-0 border-b py-1.5 pl-1 pr-6",
            "focus:outline-none transition-colors",
            open
              ? "border-slate-400"
              : "border-slate-200 hover:border-slate-300"
          )}
          style={{ minWidth: "7rem" }}
        >
          <span className={cn(selected.size === 0 && "text-slate-400")}>
            {triggerLabel}
          </span>
        </button>
        <div className="pointer-events-none absolute right-1 top-1/2 -translate-y-1/2 text-slate-500 text-xs">
          ▼
        </div>

        {open && (
          <div className="absolute z-50 top-full left-0 mt-1 bg-white border border-slate-200 rounded shadow-md py-1 min-w-full">
            {options.map((opt) => (
              <label
                key={opt.id}
                className="flex items-center gap-2 px-3 py-1.5 text-sm cursor-pointer hover:bg-[var(--color-grey-50)]"
              >
                <input
                  type="checkbox"
                  checked={selected.has(opt.id)}
                  onChange={(e) => {
                    const next = new Set(selected);
                    if (e.target.checked) {
                      next.add(opt.id);
                    } else {
                      next.delete(opt.id);
                    }
                    onChange(next);
                  }}
                  className="accent-[var(--color-primary)]"
                />
                {opt.name}
              </label>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function StringFilterControl({
  attribute,
  value,
  onChange,
}: {
  attribute: AttributeDef;
  value: string | null;
  onChange: (value: FilterStateValue) => void;
}) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="filter-group-label">{attribute.name}</span>
      <LinearInput
        value={value ?? ""}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Exact match"
        className="w-28"
      />
    </div>
  );
}
