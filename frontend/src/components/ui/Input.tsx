import React from "react";
import { cn } from "../../utils/cn";

type Props = React.InputHTMLAttributes<HTMLInputElement> & {
  leadingIcon?: React.ReactNode;
};

export function Input({ className, leadingIcon, ...props }: Props) {
  return (
    <div className={cn("relative", className)}>
      {leadingIcon ? (
        <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
          {leadingIcon}
        </div>
      ) : null}
      <input
        className={cn(
          "w-full h-11 rounded-xl border border-gray-300 bg-white px-3 py-2 text-gray-900 placeholder-gray-500 focus:border-blue-500 focus:ring-2 focus:ring-blue-200",
          leadingIcon ? "pl-10" : ""
        )}
        {...props}
      />
    </div>
  );
}
