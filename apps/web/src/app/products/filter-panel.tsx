import { LinearInput } from "@/components/ui/linear-input";
import { LinearNumberInput } from "@/components/ui/linear-number-input";
import { LinearSelect } from "@/components/ui/linear-select";
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
  const selected = value ?? new Set<string>();
  const options = attribute.enumOptions ?? [];

  return (
    <div className="flex flex-col gap-0.5">
      <span className="filter-group-label">{attribute.name}</span>
      <div className="flex flex-wrap gap-2">
        {options.map((opt) => (
          <label
            key={opt.id}
            className="flex items-center gap-1 text-sm cursor-pointer"
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
