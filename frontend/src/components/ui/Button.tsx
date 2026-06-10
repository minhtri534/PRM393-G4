import React from "react";
import { cn } from "../../utils/cn";

type Variant = "primary" | "secondary" | "outline" | "gradient" | "ghost" | "danger";
type Size = "sm" | "md" | "lg" | "icon";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
  size?: Size;
  fullWidth?: boolean;
};

const base =
  "inline-flex items-center justify-center rounded-xl font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none";

const variants: Record<Variant, string> = {
  primary: "bg-brand text-brand-foreground hover:bg-blue-600 shadow-sm",
  secondary: "bg-surface-soft text-gray-900 hover:bg-gray-200",
  outline:
    "border border-gray-200 bg-white text-gray-700 hover:bg-gray-50 hover:text-gray-900 focus-visible:ring-brand shadow-sm",
  gradient:
    "bg-gradient-to-r from-brand to-palette-violet text-white shadow-soft hover:brightness-110 border border-transparent",
  ghost: "bg-transparent text-gray-600 hover:bg-gray-100 hover:text-gray-900",
  danger: "bg-red-600 text-white hover:bg-red-700 shadow-sm"
};

const sizes: Record<Size, string> = {
  sm: "h-9 px-3 text-sm",
  md: "h-11 px-4 text-sm",
  lg: "h-12 px-6 text-base",
  icon: "h-10 w-10",
};

export function Button({
  className,
  variant = "primary",
  size = "md",
  fullWidth,
  ...props
}: Props) {
  return (
    <button
      className={cn(
        base,
        variants[variant],
        sizes[size],
        fullWidth && "w-full",
        className
      )}
      {...props}
    />
  );
}
