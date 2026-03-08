import { cn } from "@/lib/cn";
import React from "react";

export interface LinearNumberInputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  value: string | number;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

export function LinearNumberInput({
  className,
  value,
  onChange,
  ...props
}: LinearNumberInputProps) {

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const v = e.target.value;

    // allow empty
    if (v === "") {
      onChange(e);
      return;
    }

    // allow valid numeric patterns
    if (/^[0-9]*\.?[0-9]*$/.test(v)) {
      onChange(e);
    }
  };

  return (
    <input
      {...props}
      value={value}
      onChange={handleChange}
      inputMode="decimal"
      className={cn(
        "w-full bg-transparent text-sm",
        "border-0 border-b border-slate-200",
        "focus:border-slate-400 focus:outline-none",
        "hover:border-slate-300",
        "py-1.5 px-1",
        "transition-colors",
        className
      )}
    />
  );
}
