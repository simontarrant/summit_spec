import { cn } from "@/lib/cn";
import React from "react";

export type LinearSelectProps = React.SelectHTMLAttributes<HTMLSelectElement>;

export function LinearSelect({ className, children, ...props }: LinearSelectProps) {
  return (
    <div className="relative w-full">
      <select
        {...props}
        className={cn(
          "appearance-none bg-transparent text-sm cursor-pointer",
          "border-0 border-b border-[var(--color-border-subtle)]",
          "focus:border-[var(--color-accent-alpine)] focus:outline-none",
          "hover:border-[var(--color-border-strong)]",
          "text-[var(--color-text-primary)]",
          "py-1.5 pr-6 pl-1",
          "transition-colors w-full",
          className
        )}
      >
        {children}
      </select>

      <div className="pointer-events-none absolute right-1 top-1/2 -translate-y-1/2 text-[var(--color-text-muted)] text-xs">
        ▼
      </div>
    </div>
  );
}
