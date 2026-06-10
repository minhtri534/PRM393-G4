import React from "react";
import { cn } from "../../utils/cn";

type Variant = "primary" | "secondary" | "success" | "danger" | "outline";

type Props = React.HTMLAttributes<HTMLDivElement> & {
  variant?: Variant;
};

const base =
  "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2";

const variants: Record<Variant, string> = {
  primary: "border-transparent bg-blue-100 text-blue-800",
  secondary: "border-transparent bg-gray-100 text-gray-800",
  success: "border-transparent bg-green-100 text-green-800",
  danger: "border-transparent bg-red-100 text-red-800",
  outline: "text-gray-900 border-gray-200 bg-transparent",
};

export function Badge({ className, variant = "primary", ...props }: Props) {
  return (
    <div
      className={cn(
        base,
        variants[variant],
        className
      )}
      {...props}
    />
  );
}
