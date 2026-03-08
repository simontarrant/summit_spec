import React from "react";
import { cn } from "@/lib/cn";

interface PageProps {
  children: React.ReactNode;
  className?: string;
}

export function Page({ children, className }: PageProps) {
  return <main className={cn("ui-page", className)}>{children}</main>;
}
