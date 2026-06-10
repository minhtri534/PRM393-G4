export default function HeroVisual() {
  return (
    <div className="relative h-40 sm:h-48 lg:h-56">
      <div className="absolute -top-6 -left-6 w-24 h-24 rounded-full bg-gradient-to-br from-palette-blue to-palette-cyan blur-2xl opacity-30 animate-blob" />
      <div className="absolute -bottom-6 -right-6 w-28 h-28 rounded-full bg-gradient-to-br from-palette-violet to-palette-rose blur-2xl opacity-30 animate-blob" />
      <svg
        className="absolute inset-0 w-full h-full"
        viewBox="0 0 400 200"
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <linearGradient id="grad1" x1="0" x2="1" y1="0" y2="1">
            <stop offset="0%" stopColor="#2563eb" stopOpacity="0.9" />
            <stop offset="50%" stopColor="#22d3ee" stopOpacity="0.9" />
            <stop offset="100%" stopColor="#7c3aed" stopOpacity="0.9" />
          </linearGradient>
        </defs>
        <circle cx="60" cy="80" r="22" fill="url(#grad1)" />
        <rect x="110" y="60" width="46" height="46" rx="12" fill="url(#grad1)" />
        <circle cx="190" cy="90" r="14" fill="#10b981" />
        <rect x="220" y="70" width="72" height="38" rx="10" fill="#f59e0b" />
        <circle cx="320" cy="84" r="20" fill="#f43f5e" />
      </svg>
    </div>
  );
}
