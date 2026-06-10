import React from "react";
import { cn } from "../../utils/cn";

type Variant = "default" | "glass";
type Props = React.HTMLAttributes<HTMLDivElement> & {
  variant?: Variant;
};

const variants: Record<Variant, string> = {
  default: "bg-surface shadow-soft border border-gray-100",
  glass:
    "bg-white/70 backdrop-blur-md border border-white/50 shadow-soft"
};

export function Card({ className, variant = "default", ...props }: Props) {
  return (
    <div
      className={cn("rounded-xl", variants[variant], className)}
      {...props}
    />
  );
}
