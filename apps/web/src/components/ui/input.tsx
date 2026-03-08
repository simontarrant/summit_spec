import React from "react";
import { cn } from "@/lib/cn";

export type TextInputProps = React.InputHTMLAttributes<HTMLInputElement>

export function TextInput({ className, ...props }: TextInputProps) {
  return (
    <input
      className={cn("ui-input", className)}
      {...props}
    />
  );
}
