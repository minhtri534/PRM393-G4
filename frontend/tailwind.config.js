/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: "#2563eb",
          foreground: "#ffffff",
          muted: "#e2e8f0"
        },
        accent: {
          from: "#2563eb",
          via: "#22d3ee",
          to: "#7c3aed"
        },
        palette: {
          blue: "#2563eb",
          indigo: "#4f46e5",
          violet: "#7c3aed",
          cyan: "#22d3ee",
          teal: "#14b8a6",
          emerald: "#10b981",
          amber: "#f59e0b",
          rose: "#f43f5e"
        },
        surface: {
          DEFAULT: "#ffffff",
          soft: "#f8fafc"
        }
      },
      boxShadow: {
        soft: "0 8px 24px rgba(0,0,0,0.08)",
        ring: "0 0 0 4px rgba(37,99,235,0.15)"
      },
      borderRadius: {
        xl: "14px"
      },
      keyframes: {
        float: {
          "0%,100%": { transform: "translateY(0)" },
          "50%": { transform: "translateY(-4px)" }
        },
        blob: {
          "0%": { transform: "translate(0px, 0px) scale(1)" },
          "33%": { transform: "translate(8px, -12px) scale(1.05)" },
          "66%": { transform: "translate(-6px, 10px) scale(0.97)" },
          "100%": { transform: "translate(0px, 0px) scale(1)" }
        },
        fadeIn: {
          "0%": { opacity: "0", transform: "translateY(6px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        }
      },
      animation: {
        float: "float 6s ease-in-out infinite",
        fadeIn: "fadeIn .35s ease-in-out both",
        blob: "blob 10s ease-in-out infinite"
      },
      backgroundImage: {
        radialSoft:
          "radial-gradient(100% 100% at 0% 0%, #eef2ff 0%, #ffffff 40%)",
        accentMesh:
          "linear-gradient(120deg, rgba(37,99,235,.12), rgba(124,58,237,.12))"
      }
    },
    fontFamily: {
      sans: ["Inter", "ui-sans-serif", "system-ui", "Segoe UI", "Arial"]
    }
  },
  plugins: [],
}
