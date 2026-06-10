import { ScanLine, Box, Tag, MousePointer2 } from "lucide-react";

export default function Background({ showVisuals = true }: { showVisuals?: boolean }) {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden">
      <div className="absolute inset-0 bg-radialSoft" />
      <div className="absolute inset-0 bg-accentMesh mix-blend-multiply" />
      
      {/* Animated Gradients */}
      <div className="absolute -top-20 -left-20 w-96 h-96 rounded-full bg-gradient-to-br from-palette-blue/20 to-palette-cyan/20 blur-3xl animate-blob" />
      <div 
        className="absolute top-1/4 -right-24 w-80 h-80 rounded-full bg-gradient-to-br from-palette-violet/20 to-palette-rose/20 blur-3xl animate-blob"
        style={{ animationDelay: "2s" }}
      />
      <div 
        className="absolute -bottom-32 left-1/3 w-96 h-96 rounded-full bg-gradient-to-br from-palette-emerald/20 to-palette-teal/20 blur-3xl animate-blob"
        style={{ animationDelay: "4s" }}
      />

      {/* Grid Pattern */}
      <svg className="absolute inset-0 opacity-[0.03]" viewBox="0 0 100 100" preserveAspectRatio="none">
        <defs>
          <pattern id="grid" width="4" height="4" patternUnits="userSpaceOnUse">
            <path d="M4 0 H0 V4" fill="none" stroke="#0f172a" strokeWidth="0.5" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" />
      </svg>

      {/* AI Labeling Visuals */}
      {showVisuals && (
        <>
          {/* 1. Bounding Box Mock - Top Left */}
          <div className="absolute top-20 left-10 lg:left-20 opacity-60 rotate-[-6deg] animate-float">
            <div className="w-48 h-32 border-2 border-palette-blue/50 rounded-lg bg-palette-blue/5 backdrop-blur-sm relative">
              <div className="absolute -top-3 -left-1 bg-palette-blue/20 text-palette-blue px-2 py-0.5 text-[10px] rounded border border-palette-blue/30 font-mono flex items-center gap-1">
                <Tag size={10} /> Car: 98%
              </div>
              <div className="absolute inset-4 border border-dashed border-palette-blue/40 rounded" />
              <div className="absolute bottom-2 right-2 text-palette-blue/50">
                <ScanLine size={16} />
              </div>
            </div>
          </div>

          {/* 2. Segmentation Mock - Bottom Right */}
          <div 
            className="absolute bottom-20 right-4 lg:right-20 opacity-50 rotate-[12deg] animate-float"
            style={{ animationDelay: "2s" }}
          >
            <div className="w-40 h-40 border border-palette-violet/40 rounded-xl bg-palette-violet/5 backdrop-blur-sm relative p-3">
              <div className="absolute -top-2 -right-2 bg-palette-violet/20 text-palette-violet px-2 py-0.5 text-[10px] rounded border border-palette-violet/30 font-mono">
                Segmentation
              </div>
              <svg viewBox="0 0 100 100" className="w-full h-full stroke-palette-violet/50 fill-palette-violet/10 stroke-2">
                <path d="M10,50 Q25,25 50,10 T90,50 T50,90 T10,50 Z" />
              </svg>
              <MousePointer2 className="absolute bottom-10 right-10 text-palette-violet/70 w-4 h-4 fill-palette-violet/20" />
            </div>
          </div>

          {/* 3. Keypoints Mock - Middle Left (lower) */}
          <div 
            className="absolute bottom-1/3 -left-8 lg:left-10 opacity-40 rotate-[3deg] animate-float hidden sm:block"
            style={{ animationDelay: "1s" }}
          >
            <div className="w-36 h-36 border border-palette-emerald/40 rounded-lg bg-palette-emerald/5 backdrop-blur-sm relative p-4">
              <div className="absolute top-2 left-2 flex gap-1">
                  <div className="w-2 h-2 rounded-full bg-palette-emerald/50"></div>
                  <div className="w-2 h-2 rounded-full bg-palette-emerald/50"></div>
              </div>
              <div className="absolute inset-0 flex items-center justify-center">
                <Box className="text-palette-emerald/40 w-16 h-16" />
              </div>
              {/* Mocking connection lines */}
              <svg className="absolute inset-0 w-full h-full pointer-events-none">
                <circle cx="30%" cy="30%" r="3" className="fill-palette-emerald/50" />
                <circle cx="70%" cy="30%" r="3" className="fill-palette-emerald/50" />
                <circle cx="70%" cy="70%" r="3" className="fill-palette-emerald/50" />
                <circle cx="30%" cy="70%" r="3" className="fill-palette-emerald/50" />
                <path d="M30 30 L70 30 L70 70 L30 70 Z" className="stroke-palette-emerald/30 fill-none" />
              </svg>
            </div>
          </div>
        </>
      )}

      {/* 4. Data Particles - Floating binary/dots effect */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none opacity-20">
         {[...Array(6)].map((_, i) => (
           <div 
              key={i}
              className="absolute w-2 h-2 bg-brand rounded-full animate-float blur-[1px]"
              style={{
                top: `${Math.random() * 100}%`,
                left: `${Math.random() * 100}%`,
                animationDelay: `${i * 1.5}s`,
                opacity: 0.3 + Math.random() * 0.4
              }}
           />
         ))}
         <div className="absolute top-1/2 left-1/4 w-32 h-32 bg-gradient-to-t from-brand/10 to-transparent blur-2xl rounded-full animate-pulse" />
      </div>
    </div>
  );
}
