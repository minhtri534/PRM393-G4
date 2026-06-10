import React from "react";
import { cn } from "../../utils/cn";

type Props = React.LabelHTMLAttributes<HTMLLabelElement>;

export function Label({ className, ...props }: Props) {
  return (
    <label
      className={cn("block text-sm font-medium text-gray-700 mb-2", className)}
      {...props}
    />
  );
}
