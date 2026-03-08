import { cn } from "@/lib/cn";

interface FieldGroupProps {
  children: React.ReactNode;
  className?: string;
}

export function FieldGroup({ children, className }: FieldGroupProps) {
  return (
    <div className={cn("space-y-0", className)}>
      {children}
    </div>
  );
}

interface FieldRowProps {
  label: string;
  children: React.ReactNode;
  className?: string;
}

export function FieldRow({ label, children, className }: FieldRowProps) {
  return (
    <div
      className={cn(
        "grid grid-cols-[150px_1fr] items-center",
        // "border-b border-slate-100",
        className
      )}
    >
      <div className="px-2 text-sm font-medium text-slate-600">
        {label}
      </div>

      <div className="
      px-3 border-l border-slate-100
      ">
        {children}
      </div>
    </div>
  );
}

