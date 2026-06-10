import { Scan, Layers, Sparkles } from "lucide-react";

type LogoProps = {
  className?: string;
  showSlogan?: boolean;
  size?: "sm" | "md" | "lg";
};

export default function Logo({ className = "", showSlogan = true, size = "md" }: LogoProps) {
  const sizeClasses = {
    sm: "h-8 w-8",
    md: "h-10 w-10",
    lg: "h-14 w-14",
  };

  const textSizes = {
    sm: "text-lg",
    md: "text-2xl",
    lg: "text-4xl",
  };

  return (
    <div className={`flex flex-col items-start ${className}`}>
      <div className="flex items-center gap-3">
        <div className="relative flex items-center justify-center">
          <div className={`absolute inset-0 bg-gradient-to-tr from-brand to-palette-violet rounded-xl blur-lg opacity-40 animate-pulse`} />
          <div className={`${sizeClasses[size]} bg-gradient-to-br from-brand to-palette-violet rounded-xl flex items-center justify-center text-white shadow-lg relative z-10`}>
            <Scan className="w-3/5 h-3/5 absolute" strokeWidth={2.5} />
            <Layers className="w-2/5 h-2/5 text-white/90" strokeWidth={2.5} />
            <Sparkles className="absolute -top-1 -right-1 w-3 h-3 text-palette-cyan animate-pulse" fill="currentColor" />
          </div>
        </div>
        
        <div className="flex flex-col">
          <h1 className={`${textSizes[size]} font-bold bg-clip-text text-transparent bg-gradient-to-r from-gray-900 via-brand to-palette-violet tracking-tight`}>
            LabelAI
          </h1>
        </div>
      </div>
      
      {showSlogan && (
        <p className="mt-2 text-sm font-medium text-gray-500 tracking-wide flex items-center gap-2">
          <span className="w-1.5 h-1.5 rounded-full bg-palette-emerald animate-pulse" />
          Precision Data for Smarter Models
        </p>
      )}
    </div>
  );
}
