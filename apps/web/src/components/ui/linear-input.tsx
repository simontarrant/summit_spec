import { cn } from "@/lib/cn";
import React from "react";

export type LinearInputProps = React.InputHTMLAttributes<HTMLInputElement>;

export function LinearInput({ className, ...props }: LinearInputProps) {
  return (
    <input
      {...props}
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
