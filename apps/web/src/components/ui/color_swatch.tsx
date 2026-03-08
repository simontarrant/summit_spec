import React from "react";
import { cn } from "@/lib/cn";

interface ColorSwatchProps {
  name: string;
  className?: string;
}

export function ColorSwatch({ name, className }: ColorSwatchProps) {
  return (
    <div className="space-y-2">
      <div className={cn("ui-swatch", className)} />
      <p className="text-center text-sm">{name}</p>
    </div>
  );
}
