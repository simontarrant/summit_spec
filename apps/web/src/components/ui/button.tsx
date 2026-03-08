import React from "react";
import { cn } from "@/lib/cn";

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement>;

export function PrimaryButton({ className, ...props }: ButtonProps) {
  return (
    <button
      className={cn("ui-button-primary", className)}
      {...props}
    />
  );
}

export function AccentButton({ className, ...props }: ButtonProps) {
  return (
    <button
      className={cn("ui-button-accent", className)}
      {...props}
    />
  );
}
