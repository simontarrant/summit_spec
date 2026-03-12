import { cn } from "@/lib/cn";
import React from "react";

export type LinearInputProps = React.InputHTMLAttributes<HTMLInputElement>;

export function LinearInput({ className, ...props }: LinearInputProps) {
  return (
    <input
      {...props}
      className={cn(
        "w-full bg-transparent text-sm",
        "border-0 border-b border-[var(--color-border-subtle)]",
        "focus:border-[var(--color-accent-alpine)] focus:outline-none",
        "hover:border-[var(--color-border-strong)]",
        "text-[var(--color-text-primary)] placeholder:text-[var(--color-text-muted)]",
        "py-1.5 px-1",
        "transition-colors",
        className
      )}
    />
  );
}
